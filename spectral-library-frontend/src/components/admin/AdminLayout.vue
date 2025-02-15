<template>
  <div class="admin-layout">
    <aside class="sidebar">
      <div class="user-info">
        <p>{{ userEmail }}</p>
        <button @click="logout">Logout</button>
      </div>
      <nav>
        <ul>
          <li><router-link to="/admin/mainpage">Admin Main Page</router-link></li>
          <li><router-link to="/admin/category-management">Category Management</router-link></li>
          <li><router-link to="/admin/user-management">User Management</router-link></li>
        </ul>
      </nav>
    </aside>
    <main class="content">
      <router-view></router-view>
    </main>
  </div>
</template>

<script>
export default {
  name: 'AdminLayout',
  data() {
    return {
      userEmail: localStorage.getItem('userEmail') || 'admin@example.com'
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
.admin-layout {
  display: flex;
}
.sidebar {
  width: 200px;
  background-color: #ddd;
  padding: 1rem;
}
.content {
  flex: 1;
  padding: 1rem;
}
</style>
