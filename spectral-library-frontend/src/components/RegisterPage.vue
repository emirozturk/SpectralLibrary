<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { EnvelopeIcon, LockClosedIcon, BuildingOfficeIcon } from '@heroicons/vue/24/outline'
import { post } from '../../lib/fetch-api'
import { calculateMD5 } from '../../lib/auth'

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const company = ref('')
const error = ref(null)
const isPending = ref(false)
const router = useRouter()

const handleSubmit = async (e) => {
  e.preventDefault()
  error.value = null

  if (password.value !== confirmPassword.value) {
    error.value = "Passwords do not match"
    return
  }

  try {
    const user = {
      email: email.value,
      password: calculateMD5(password.value),
      company: company.value,
    }
    const response = await post("users/register", user)
    if (response.isSuccess) {
      router.push("/login")
    } else {
      error.value = response.message || "Registration failed"
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
      <h2 class="text-3xl font-semibold text-blue-800 mb-6 text-center">
        Register
      </h2>
      <div v-if="error" class="bg-red-100 text-red-600 p-3 rounded mb-4">
        {{ error }}
      </div>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- Email Field -->
        <div class="relative">
          <EnvelopeIcon class="h-5 w-5 text-blue-600 absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="email"
            id="email"
            required
            v-model="email"
            placeholder="Email"
            class="pl-10 pr-3 py-2 w-full border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <!-- Password Field -->
        <div class="relative">
          <LockClosedIcon class="h-5 w-5 text-blue-600 absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="password"
            id="password"
            required
            v-model="password"
            placeholder="Password"
            class="pl-10 pr-3 py-2 w-full border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <!-- Confirm Password Field -->
        <div class="relative">
          <LockClosedIcon class="h-5 w-5 text-blue-600 absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="password"
            id="confirmPassword"
            required
            v-model="confirmPassword"
            placeholder="Confirm Password"
            class="pl-10 pr-3 py-2 w-full border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <!-- Company Field -->
        <div class="relative">
          <BuildingOfficeIcon class="h-5 w-5 text-blue-600 absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="text"
            id="company"
            required
            v-model="company"
            placeholder="Company"
            class="pl-10 pr-3 py-2 w-full border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
        <button
          type="submit"
          :disabled="isPending"
          class="w-full py-2 px-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          {{ isPending ? "Registering..." : "Register" }}
        </button>
      </form>
      <div class="mt-6 text-center text-sm">
        <p>
          Already have an account?
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
