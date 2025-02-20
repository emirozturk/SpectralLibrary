// router.js
import { createRouter, createWebHistory } from 'vue-router';

import LoginPage from '@/components/LoginPage.vue';
import RegisterPage from '@/components/RegisterPage.vue';
import ForgotPasswordPage from '@/components/ForgotPasswordPage.vue';
import UserLayout from '@/components/user/UserLayout.vue';
import FolderManagement from '@/components/user/FolderManagement.vue';
import UploadFilePage from '@/components/user/UploadFilePage.vue';
import DrawPlot from '@/components/user/DrawPlot.vue';
import UpdateInfoPage from '@/components/user/UpdateInfoPage.vue';
import AdminLayout from '@/components/admin/AdminLayout.vue';
import AdminMainPage from '@/components/admin/AdminMainPage.vue';
import CategoryManagement from '@/components/admin/CategoryManagement.vue';
import UserManagement from '@/components/admin/UserManagement.vue';
import MainLayout from '@/components/user/MainLayout.vue';

const routes = [
  { path: '', name: 'LoginMain', component: LoginPage },
  { path: '/', name: 'LoginMain2', component: LoginPage },
  { path: '/login', name: 'Login', component: LoginPage },
  { path: '/register', name: 'Register', component: RegisterPage },
  { path: '/forgot-password', name: 'ForgotPassword', component: ForgotPasswordPage },
  // User routes under UserLayout
  {
    path: '/user',
    component: UserLayout,
    children: [
      { path: 'main-layout', name: 'MainLayout', component: MainLayout },
      { path: 'folder-management', name: 'FolderManagement', component: FolderManagement },
      { path: 'upload-file', name: 'UploadFile', component: UploadFilePage },
      { path: 'update-info', name: 'UpdateInfo', component: UpdateInfoPage },
      { path: 'draw-plot', name: 'DrawPlot', component: DrawPlot },
    ]
  },
  // Admin routes under AdminLayout
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      { path: 'mainpage', name: 'AdminMainPage', component: AdminMainPage },
      { path: 'category-management', name: 'CategoryManagement', component: CategoryManagement },
      { path: 'user-management', name: 'UserManagement', component: UserManagement },
    ]
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  // Define public routes (that don't require auth)
  const publicPages = ['/login', '/register', '/forgot-password'];
  const authRequired = !publicPages.includes(to.path);

  const token = localStorage.getItem("token");
  const userStr = localStorage.getItem("user");
  const user = userStr ? JSON.parse(userStr) : null;

  // If the route requires auth but there's no token, redirect to login.
  if (authRequired && !token) {
    return next('/login');
  }

  // If the route has meta.roles, check if the user’s role is allowed.
  if (to.meta && to.meta.roles && user) {
    // For example, if the route only allows "user" and the logged-in user is admin,
    // then block the route.
    if (!to.meta.roles.includes(user.type)) {
      // Optionally, redirect to an "unauthorized" page or back to login.
      return next('/login');
    }
  }

  next();
});

export default router;
