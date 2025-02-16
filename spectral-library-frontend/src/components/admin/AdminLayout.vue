
<script>
export default {
  name: 'AdminLayout',
  data() {
    return {
      userEmail: localStorage.getItem('email') || 'admin@example.com'
    };
  },
  methods: {
    logout() {
      localStorage.removeItem('token');
      this.$router.push('/login');
    }
  }
};
</script>

<style scoped>
</style>


<template>
  <div class="min-h-screen flex">
    <!-- Sidebar -->
    <aside class="w-64 bg-blue-200 text-blue-900 flex flex-col">
      <div class="p-6 border-b border-blue-300">
        <p class="text-lg font-semibold">{{ userEmail }}</p>
        <button
          @click="logout"
          class="mt-2 text-sm underline hover:text-blue-700 focus:outline-none"
        >
          Logout
        </button>
      </div>
      <nav class="flex-1 p-6">
        <ul class="space-y-4">
          <li>
            <router-link to="/admin/mainpage" class="hover:text-blue-700">
              Admin Main Page
            </router-link>
          </li>
          <li>
            <router-link to="/admin/category-management" class="hover:text-blue-700">
              Category Management
            </router-link>
          </li>
          <li>
            <router-link to="/admin/user-management" class="hover:text-blue-700">
              User Management
            </router-link>
          </li>
        </ul>
      </nav>
    </aside>
    <!-- Main Content -->
    <main class="flex-1 p-8 bg-white-50">
      <router-view></router-view>
    </main>
  </div>
</template>
