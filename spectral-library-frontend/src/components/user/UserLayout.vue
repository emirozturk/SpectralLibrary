<template>
  <div class="user-layout">
    <aside class="sidebar">
      <div class="user-info">
        <!-- Display the user email (get it from a global store or localStorage) -->
        <p>{{ userEmail }}</p>
        <button @click="logout">Logout</button>
      </div>
      <nav>
        <ul>
          <li><router-link to="/user/mainpage">Main Page</router-link></li>
          <li><router-link to="/user/folder-management">Folder Management</router-link></li>
          <li><router-link to="/user/upload-file">Upload File</router-link></li>
        </ul>
      </nav>
    </aside>
    <main class="content">
      <!-- This will render the child route component -->
      <router-view></router-view>
    </main>
  </div>
</template>

<script>
export default {
  name: 'UserLayout',
  data() {
    return {
      // Replace with your actual user data retrieval method (Vuex, Pinia, etc.)
      userEmail: localStorage.getItem('userEmail') || 'user@example.com'
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

<style scoped>
.user-layout {
  display: flex;
}
.sidebar {
  width: 200px;
  background-color: #f1f1f1;
  padding: 1rem;
}
.content {
  flex: 1;
  padding: 1rem;
}
</style>
