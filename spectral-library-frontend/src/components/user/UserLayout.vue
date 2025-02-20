<script>
export default {
  name: 'UserLayout',
  data() {
    return {
      // Retrieve the user's email from local storage
      userEmail: JSON.parse(localStorage.getItem('user'))["email"]
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

<template>
  <div class="min-h-screen flex flex-col">
    <!-- Top Navigation Bar -->
    <header class="bg-blue-200 text-blue-900 p-4 flex items-center justify-between shadow-md">
      <div class="flex items-center space-x-8">
        <!-- User email display -->
        <span class="text-lg font-semibold">{{ userEmail }}</span>
        <!-- Navigation links -->
        <nav>
          <ul class="flex space-x-6">
            <li>
              <router-link to="/user/main-layout" class="hover:text-blue-700">
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
      </div>
      <!-- Logout button -->
      <button @click="logout" class="text-sm underline hover:text-blue-700 focus:outline-none">
        Logout
      </button>
    </header>
    <!-- Main Content Area -->
    <main class="flex-1 p-8 bg-white">
      <router-view></router-view>
    </main>
  </div>
</template>

<style scoped>
/* Additional modern styling can be added as needed */
</style>
