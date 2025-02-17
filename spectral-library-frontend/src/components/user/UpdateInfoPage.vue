<template>
  <div class="min-h-screen flex">
    <!-- Main Content -->
    <main class="flex-1 p-8 bg-white-50">
      <div class="p-8 max-w-4xl mx-auto bg-white rounded-lg min-h-screen flex flex-col space-y-8">
        <h1 class="text-3xl font-bold text-blue-700 text-center mb-6">Update User Information</h1>
        <form @submit.prevent="updateUserInfo" class="space-y-6">
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">Email:</label>
            <input type="email" v-model="user.email" id="email" class="mt-1 block w-full p-3 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required />
          </div>
          <div>
            <label for="company" class="block text-sm font-medium text-gray-700">Company:</label>
            <input type="text" v-model="user.company" id="company" class="mt-1 block w-full p-3 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required />
          </div>
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">New Password:</label>
            <input type="password" v-model="user.password" id="password" class="mt-1 block w-full p-3 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
          </div>
          <button type="submit" class="w-full bg-blue-600 text-white py-3 rounded-md hover:bg-blue-700 transition-colors">Update</button>
        </form>
      </div>
    </main>
  </div>
</template>

<script>
import md5 from 'md5';
import { putWithToken } from '../../../lib/fetch-api';

export default {
  name: 'UpdateInfoPage',
  data() {
    return {
      user: {
        email: '',
        company: '',
        password: ''
      }
    };
  },
  created() {
    this.fetchUserInfo();
  },
  methods: {
    async fetchUserInfo() {
      const userStr = localStorage.getItem('user');
      if (userStr) {
        const user = JSON.parse(userStr);
        this.user.email = user.email;
        this.user.company = user.company;
      }
    },
    async updateUserInfo() {
      try {
        this.user.password = md5(this.user.password);
        const response = await putWithToken('users', this.user);
        if (response.isSuccess) {
          alert('User information updated successfully');
          localStorage.setItem('user', JSON.stringify(this.user));
        } else {
          alert('Failed to update user information');
        }
      } catch (error) {
        console.error('Error updating user information:', error);
        alert('An error occurred while updating user information');
      }
    },
    logout() {
      localStorage.removeItem('token');
      this.$router.push('/login');
    }
  }
};
</script>

<style scoped>
/* Add any additional scoped styles here */
</style>
