<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { EnvelopeIcon, LockClosedIcon } from '@heroicons/vue/24/outline'
import { post } from '../../lib/fetch-api'

const email = ref('')
const password = ref('')
const error = ref(null)
const isPending = ref(false)
const router = useRouter()

const handleSubmit = async () => {
  error.value = null
  isPending.value = true

  const user = {
    email: email.value,
    password: password.value,
    type: "user",
    id: -1,
    is_confirmed: false,
    created_at: new Date(),
  }

  try {
    const response = await post("user/checklogin", user)
    if (response.is_success) {
      router.push("/user/mainpage")
    } else {
      error.value = response.message || "Login failed"
    }
  } catch (err) {
    error.value = err
  } finally {
    isPending.value = false
  }
}

</script>


<template>
  <div class="min-h-screen flex items-center justify-center bg-primary-light">
    <div class="bg-background p-8 rounded shadow-md w-full max-w-md">
      <h2 class="text-2xl font-bold text-primary-dark mb-6 text-center">
        Login
      </h2>
      <div v-if="error" class="bg-red-100 text-red-700 p-3 rounded mb-4">
        {{ error }}
      </div>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div class="flex items-center border border-primary-dark rounded">
          <div class="flex-shrink-0 px-3">
            <EnvelopeIcon class="h-4 w-4 text-primary-dark" />
          </div>
          <input
            type="email"
            id="email"
            required
            v-model="email"
            class="flex-1 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary rounded-r"
            placeholder="Email"
          />
        </div>
        <div class="flex items-center border border-primary-dark rounded">
          <div class="flex-shrink-0 px-3">
            <LockClosedIcon class="h-4 w-4 text-primary-dark" />
          </div>
          <input
            type="password"
            id="password"
            required
            v-model="password"
            class="flex-1 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary rounded-r"
            placeholder="Password"
          />
        </div>
        <button
          type="submit"
          :disabled="isPending"
          :class="[
            'w-full py-2 px-4 bg-primary hover:bg-primary-dark text-black font-semibold rounded focus:outline-none focus:ring-2 focus:ring-primary',
            isPending ? 'opacity-50 cursor-not-allowed' : ''
          ]"
        >
          {{ isPending ? "Logging in..." : "Login" }}
        </button>
      </form>
      <div class="mt-6 flex justify-between">
        <RouterLink  to="/register" class="text-primary hover:underline">
          Register
        </RouterLink >
        <RouterLink  to="/forgot-password" class="text-primary hover:underline">
          Forgot Password?
        </RouterLink >
      </div>
    </div>
  </div>
</template>


<style scoped>

</style>
