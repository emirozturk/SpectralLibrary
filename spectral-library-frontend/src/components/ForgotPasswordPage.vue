<script setup>
import { ref } from 'vue'
import { post } from '../../lib/fetch-api'
import { useRouter } from 'vue-router'

const email = ref('')
const message = ref(null)
const error = ref(null)
const loading = ref(false)
const router = useRouter()

const handleSubmit = async (e) => {
  e.preventDefault()
  loading.value = true
  error.value = null
  message.value = null

  try {
    const response = await post('users/forgot-password', { email: email.value })

    if (response.isSuccess) {
      message.value = response.message
      router.push("/login")
    } else {
      error.value = response.message || 'Request failed'
    }
  } catch (err) {
    error.value = err
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-blue-50">
    <div class="bg-white p-8 rounded-lg shadow-xl w-full max-w-md">
      <h2 class="text-3xl font-semibold text-blue-800 mb-6 text-center">
        Forgot Password
      </h2>
      <div v-if="error" class="bg-red-100 text-red-600 p-3 rounded mb-4">
        {{ error }}
      </div>
      <div v-if="message" class="bg-green-100 text-green-600 p-3 rounded mb-4">
        {{ message }}
      </div>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <div>
          <label for="email" class="block text-sm font-medium text-blue-800">
            Email
          </label>
          <input
            type="email"
            id="email"
            required
            v-model="email"
            placeholder="Email"
            class="mt-1 block w-full px-3 py-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <button
          type="submit"
          :disabled="loading"
          class="w-full py-2 px-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ loading ? "Sending..." : "Send Reset Link" }}
        </button>
      </form>
      <div class="mt-6 text-center text-sm">
        <p>
          Remembered your password?
          <RouterLink to="/login" class="text-blue-600 hover:underline">
            Login
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
</style>
