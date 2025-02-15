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
  <div class="min-h-screen flex items-center justify-center bg-primary-light">
    <div class="bg-background p-8 rounded shadow-md w-full max-w-md">
      <h2 class="text-2xl font-bold text-primary-dark mb-6 text-center">Forgot Password</h2>
      <div v-if="error" class="bg-red-100 text-red-700 p-3 rounded mb-4">
        {{ error }}
      </div>
      <div v-if="message" class="bg-green-100 text-green-700 p-3 rounded mb-4">
        {{ message }}
      </div>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label for="email" class="block text-sm font-medium text-primary-dark">
            Email
          </label>
          <input
            type="email"
            id="email"
            required
            v-model="email"
            class="mt-1 block w-full px-3 py-2 border border-primary-dark rounded focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>
        <button
          type="submit"
          :disabled="loading"
          class="w-full py-2 px-4 bg-primary hover:bg-primary-dark text-white font-semibold rounded focus:outline-none focus:ring-2 focus:ring-primary"
        >
          {{ loading ? 'Sending...' : 'Send Reset Link' }}
        </button>
      </form>
      <div class="mt-6 text-center">
        <p>
          Remembered your password?
          <RouterLink to="/login" class="text-primary hover:underline">
            Login
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
</style>
