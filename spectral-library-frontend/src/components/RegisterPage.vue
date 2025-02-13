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
      is_confirmed: false,
      type: "user",
      company: company.value,
      id: -1,
      created_at: new Date(),
    }
    const response = await post("user/register", user)
    if (response.is_success) {
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
  <div class="min-h-screen flex items-center justify-center bg-primary-light">
    <div class="bg-background p-8 rounded shadow-md w-full max-w-md">
      <h2 class="text-2xl font-bold text-primary-dark mb-6 text-center">
        Register
      </h2>
      <div v-if="error" class="bg-red-100 text-red-700 p-3 rounded mb-4">
        {{ error }}
      </div>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Email Field -->
        <div class="relative">
          <EnvelopeIcon class="h-4 w-4 text-primary-dark absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="email"
            id="email"
            required
            v-model="email"
            class="pl-10 pr-3 py-2 w-full border border-primary-dark rounded focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="Email"
          />
        </div>
        <!-- Password Field -->
        <div class="relative">
          <LockClosedIcon class="h-5 w-5 text-primary-dark absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="password"
            id="password"
            required
            v-model="password"
            class="pl-10 pr-3 py-2 w-full border border-primary-dark rounded focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="Password"
          />
        </div>
        <!-- Confirm Password Field -->
        <div class="relative">
          <LockClosedIcon class="h-5 w-5 text-primary-dark absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="password"
            id="confirmPassword"
            required
            v-model="confirmPassword"
            class="pl-10 pr-3 py-2 w-full border border-primary-dark rounded focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="Confirm Password"
          />
        </div>
        <!-- Company Field -->
        <div class="relative">
          <BuildingOfficeIcon class="h-5 w-5 text-primary-dark absolute left-3 top-1/2 transform -translate-y-1/2" />
          <input
            type="text"
            id="company"
            required
            v-model="company"
            class="pl-10 pr-3 py-2 w-full border border-primary-dark rounded focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="Company"
          />
        </div>
        <button
          type="submit"
          :disabled="isPending"
          class="w-full py-2 px-4 bg-primary hover:bg-primary-dark text-white font-semibold rounded focus:outline-none focus:ring-2 focus:ring-primary"
        >
          {{ isPending ? "Registering..." : "Register" }}
        </button>
      </form>
      <div class="mt-6 text-center">
        <p>
          Already have an account?
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
