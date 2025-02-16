<script setup>
import { ref ,onMounted} from 'vue'
import {
  UserIcon,
  FolderIcon,
  DocumentIcon
} from '@heroicons/vue/24/solid'
import { getAllWithToken } from '../../../lib/fetch-api'

// Mock Data
const registeredUsers = ref()
const totalFiles = ref()
const totalFolders = ref()
const fileCategoryRatios = ref([])


onMounted(async () => {
  const response = await getAllWithToken("dashboard", null);
  if(response.isSuccess){
    registeredUsers.value = response.body.user_count;
    totalFiles.value = response.body.total_files;
    totalFolders.value = response.body.total_folders;
    fileCategoryRatios.value = response.body.category_file_ratios;
  }
});
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto bg-white rounded-lg min-h-screen flex flex-col space-y-8">
    <h1 class="text-4xl font-bold text-blue-700 text-center">
      Dashboard
    </h1>

    <!-- Overview Section -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- Registered Users -->
      <div class="flex items-center p-6 bg-white border border-gray-200 rounded-lg">
        <UserIcon class="h-12 w-12 text-blue-500 mr-4" />
        <div>
          <p class="text-lg font-semibold text-blue-700">Registered Users</p>
          <p class="text-2xl font-bold text-blue-900">{{ registeredUsers }}</p>
        </div>
      </div>

      <!-- Total Files -->
      <div class="flex items-center p-6 bg-white border border-gray-200 rounded-lg">
        <DocumentIcon class="h-12 w-12 text-blue-500 mr-4" />
        <div>
          <p class="text-lg font-semibold text-blue-700">Total Files</p>
          <p class="text-2xl font-bold text-blue-900">{{ totalFiles }}</p>
        </div>
      </div>

      <!-- Total Folders -->
      <div class="flex items-center p-6 bg-white border border-gray-200 rounded-lg">
        <FolderIcon class="h-12 w-12 text-blue-500 mr-4" />
        <div>
          <p class="text-lg font-semibold text-blue-700">Total Folders</p>
          <p class="text-2xl font-bold text-blue-900">{{ totalFolders }}</p>
        </div>
      </div>
    </div>

    <!-- File Category Ratios Section -->
    <div class="bg-white p-6 rounded-lg border border-gray-200">
      <h2 class="text-2xl font-semibold text-blue-700 mb-4">
        File Category Ratios
      </h2>
      <div class="space-y-4">
        <div v-for="(category, index) in fileCategoryRatios" :key="index">
          <div class="flex justify-between mb-1">
            <span class="text-base font-medium text-blue-700">{{ category.name }}</span>
            <span class="text-base font-medium text-blue-700">{{ category.ratio }}%</span>
          </div>
          <!-- Progress Bar: track is white -->
          <div class="w-full h-4 rounded-full bg-white">
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
