<script>
export default {
  name: 'UserLayout',
  data() {
    return {
      // Replace with your actual user data retrieval method (Vuex, Pinia, etc.)
      userEmail: JSON.parse(localStorage.getItem('user'))["email"]
    };
  },
  methods: {
    logout() {
      // Clear the token and redirect to login (or any logout logic you have)
      localStorage.removeItem('token');
      this.$router.push('/login');
    }
  }
};
</script>

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
            <router-link to="/user/mainpage" class="hover:text-blue-700">
              Main Page
            </router-link>
          </li>
          <li>
            <router-link to="/user/folder-management" class="hover:text-blue-700">
              Folder Management
            </router-link>
          </li>
          <li>
            <router-link to="/user/upload-file" class="hover:text-blue-700">
              Upload File
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

<style scoped>
</style>
