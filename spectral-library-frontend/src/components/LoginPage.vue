<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { EnvelopeIcon, LockClosedIcon } from '@heroicons/vue/24/outline'
import { post } from '../../lib/fetch-api'
import { calculateMD5 } from '../../lib/auth'

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
    password: calculateMD5(password.value),
  }

  try {
    const response = await post("auth/login", user)
    if (response.isSuccess) {
      localStorage.setItem("token", JSON.stringify(response.body.token))
      localStorage.setItem("user", JSON.stringify(response.body.user))
      if (response.body.user.type === "admin") {
        router.push("/admin/mainpage")
      } else
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
  <div class="min-h-screen flex items-center justify-center bg-blue-50">
    <div class="bg-white p-8 rounded-lg shadow-xl w-full max-w-md">
      <h2 class="text-3xl font-semibold text-blue-800 mb-6 text-center">Login</h2>
      <div v-if="error" class="bg-red-100 text-red-600 p-3 rounded mb-4">
        {{ error }}
      </div>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <div class="flex items-center border border-blue-300 rounded-lg overflow-hidden">
          <span class="px-3">
            <EnvelopeIcon class="h-5 w-5 text-blue-600" />
          </span>
          <input
            type="email"
            id="email"
            required
            v-model="email"
            placeholder="Email"
            class="flex-1 py-2 px-3 focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <div class="flex items-center border border-blue-300 rounded-lg overflow-hidden">
          <span class="px-3">
            <LockClosedIcon class="h-5 w-5 text-blue-600" />
          </span>
          <input
            type="password"
            id="password"
            required
            v-model="password"
            placeholder="Password"
            class="flex-1 py-2 px-3 focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <button
          type="submit"
          :disabled="isPending"
          class="w-full py-2 px-4 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ isPending ? "Logging in..." : "Login" }}
        </button>
      </form>
      <div class="mt-6 flex justify-between text-sm">
        <RouterLink to="/register" class="text-blue-600 hover:underline">
          Register
        </RouterLink>
        <RouterLink to="/forgot-password" class="text-blue-600 hover:underline">
          Forgot Password?
        </RouterLink>
      </div>
    </div>
  </div>
</template>



<style scoped></style>
