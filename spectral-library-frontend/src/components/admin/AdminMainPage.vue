<script setup>
import { ref } from 'vue'
import {
  UserIcon,
  FolderIcon,
  DocumentIcon
} from '@heroicons/vue/24/solid'

// Mock Data
const registeredUsers = ref(150)
const totalFiles = ref(1200)
const totalFolders = ref(300)

const fileCategoryRatios = ref([
  { name: 'Category 1', ratio: 40 },
  { name: 'Category 2', ratio: 35 },
  { name: 'Category 3', ratio: 25 }
])
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto bg-blue-50 shadow-md rounded-lg min-h-screen flex flex-col space-y-8">
    <h1 class="text-4xl font-bold text-blue-700 text-center">
      Admin Dashboard
    </h1>

    <!-- Overview Section -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- Registered Users -->
      <div class="flex items-center p-6 bg-blue-100 rounded-lg shadow">
        <UserIcon class="h-12 w-12 text-blue-500 mr-4" />
        <div>
          <p class="text-lg font-semibold text-blue-700">Registered Users</p>
          <p class="text-2xl font-bold text-blue-900">{{ registeredUsers }}</p>
        </div>
      </div>

      <!-- Total Files -->
      <div class="flex items-center p-6 bg-blue-100 rounded-lg shadow">
        <DocumentIcon class="h-12 w-12 text-blue-500 mr-4" />
        <div>
          <p class="text-lg font-semibold text-blue-700">Total Files</p>
          <p class="text-2xl font-bold text-blue-900">{{ totalFiles }}</p>
        </div>
      </div>

      <!-- Total Folders -->
      <div class="flex items-center p-6 bg-blue-100 rounded-lg shadow">
        <FolderIcon class="h-12 w-12 text-blue-500 mr-4" />
        <div>
          <p class="text-lg font-semibold text-blue-700">Total Folders</p>
          <p class="text-2xl font-bold text-blue-900">{{ totalFolders }}</p>
        </div>
      </div>
    </div>

    <!-- File Category Ratios Section -->
    <div class="bg-white p-6 rounded-lg shadow">
      <h2 class="text-2xl font-semibold text-blue-700 mb-4">
        File Category Ratios
      </h2>
      <div class="space-y-4">
        <div v-for="(category, index) in fileCategoryRatios" :key="index">
          <div class="flex justify-between mb-1">
            <span class="text-base font-medium text-blue-700">{{ category.name }}</span>
            <span class="text-base font-medium text-blue-700">{{ category.ratio }}%</span>
          </div>
          <div class="w-full bg-blue-200 rounded-full h-4">
            <div
              class="bg-blue-600 h-4 rounded-full"
              :style="{ width: `${category.ratio}%` }"
            ></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Add any component-specific styles here */
</style>
