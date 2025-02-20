<script>
export default {
  name: 'UserLayout',
  data() {
    return {
      collapsed: false, // Controls whether the sidebar is collapsed
      // Replace with your actual user data retrieval (e.g., from Vuex, Pinia, etc.)
      userEmail: JSON.parse(localStorage.getItem('user'))["email"]
    };
  },
  methods: {
    logout() {
      localStorage.removeItem('token');
      this.$router.push('/login');
    },
    toggleSidebar() {
      this.collapsed = !this.collapsed;
    }
  }
};
</script>

<template>
  <div class="min-h-screen flex">
    <!-- Sidebar -->
    <aside
      :class="[
        collapsed ? 'w-16' : 'w-64',
        'bg-blue-200 text-blue-900 flex flex-col transition-all duration-300'
      ]"
    >
      <div class="p-6 border-b border-blue-300 flex items-center justify-between">
        <!-- Show user email only when expanded -->
        <p v-if="!collapsed" class="text-lg font-semibold">{{ userEmail }}</p>
        <!-- Toggle button with icons -->
        <button @click="toggleSidebar" class="focus:outline-none">
          <svg v-if="collapsed" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none"
            viewBox="0 0 24 24" stroke="currentColor">
            <!-- Expand Icon (right arrow) -->
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none"
            viewBox="0 0 24 24" stroke="currentColor">
            <!-- Collapse Icon (left arrow) -->
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
      </div>
      <!-- Navigation (visible only when expanded) -->
      <nav v-if="!collapsed" class="flex-1 p-6">
        <ul class="space-y-4">
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
          <li>
            <router-link to="/user/update-info" class="hover:text-blue-700">
              Update Info
            </router-link>
          </li>
        </ul>
      </nav>
      <!-- Logout (visible only when expanded) -->
      <div v-if="!collapsed" class="p-6 border-t border-blue-300">
        <button
          @click="logout"
          class="mt-2 text-sm underline hover:text-blue-700 focus:outline-none"
        >
          Logout
        </button>
      </div>
    </aside>
    <!-- Main Content -->
    <main class="flex-1 p-8 bg-white-50">
      <router-view></router-view>
    </main>
  </div>
</template>

<style scoped>
/* You can adjust additional styles as needed */
</style>
