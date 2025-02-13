import { createRouter, createWebHistory } from 'vue-router'

import LoginPage from '@/components/LoginPage.vue'
import RegisterPage from '@/components/RegisterPage.vue'
import ForgotPasswordPage from '@/components/ForgotPasswordPage.vue'
import MainPage from '@/components/user/MainPage.vue'
import FolderManagement from '@/components/user/FolderManagement.vue'
import UploadFilePage from '@/components/user/UploadFilePage.vue'
import DrawPlot from '@/components/user/DrawPlot.vue'
import AdminMainPage from '@/components/admin/AdminMainPage.vue'
import CategoryManagement from '@/components/admin/CategoryManagement.vue'
import UserManagement from '@/components/admin/UserManagement.vue'

const routes = [
  {
    path: '/',
    name: 'Login',
    component: LoginPage,
  },
  {
    path: '/register',
    name: 'Register',
    component: RegisterPage,
  },
  {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: ForgotPasswordPage,
  },
  {
    path: '/user-mainpage',
    name: 'UserContainer',
    component: () => import('@/components/user/MainPage.vue'),
  },
  {
    path: '/mainpage',
    name: 'MainPage',
    component: MainPage,
  },
  {
    path: '/folder-management',
    name: 'FolderManagement',
    component: FolderManagement,
  },
  {
    path: '/upload-file',
    name: 'UploadFile',
    component: UploadFilePage,
  },
  {
    path: '/draw-plot',
    name: 'DrawPlot',
    component: DrawPlot,
  },
  {
    path: '/admin-mainpage',
    name: 'AdminMainPage',
    component: AdminMainPage,
  },
  {
    path: '/category-management',
    name: 'CategoryManagement',
    component: CategoryManagement,
  },
  {
    path: '/user-management',
    name: 'UserManagement',
    component: UserManagement,
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
