<script setup>
import { ref } from 'vue'
import { post } from '../../../lib/fetch-api'

const files = ref([])
const category = ref('')
const subcategory = ref('')
const folder = ref('')
const error = ref(null)

const handleFileChange = (event) => {
  files.value = Array.from(event.target.files || [])
}

const handleUpload = async () => {
  if (!category.value || !subcategory.value || !folder.value) {
    error.value = "Please select a category, subcategory, and folder."
    return
  }

  if (files.value.length === 0) {
    error.value = "Please select at least one file to upload."
    return
  }

  try {
    // Implement your upload logic here
    alert("Files uploaded successfully!")

    // Reset the form
    files.value = []
    category.value = ''
    subcategory.value = ''
    folder.value = ''
    error.value = null
  } catch (err) {
    error.value = "Upload failed: " + err.message
  }
}
</script>

<template>
  <div class="p-8 max-w-4xl mx-auto bg-blue-50 rounded-lg min-h-screen flex flex-col space-y-8">
    <h2 class="text-3xl font-bold text-blue-700 text-center">
      Upload Files
    </h2>

    <div v-if="error" class="bg-red-100 text-red-700 p-3 rounded mb-4">
      {{ error }}
    </div>

    <!-- Dropdowns -->
    <div class="space-y-6">
      <!-- Category Dropdown -->
      <div>
        <label class="text-blue-700 block mb-2 font-medium">
          Category
        </label>
        <select
          v-model="category"
          class="w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="">Select Category</option>
          <option value="category1">Category 1</option>
          <option value="category2">Category 2</option>
        </select>
      </div>

      <!-- Subcategory Dropdown -->
      <div>
        <label class="text-blue-700 block mb-2 font-medium">
          Subcategory
        </label>
        <select
          v-model="subcategory"
          class="w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="">Select Subcategory</option>
          <option value="subcategory1">Subcategory 1</option>
          <option value="subcategory2">Subcategory 2</option>
        </select>
      </div>

      <!-- Folder Dropdown -->
      <div>
        <label class="text-blue-700 block mb-2 font-medium">
          Folder
        </label>
        <select
          v-model="folder"
          class="w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="">Select Folder</option>
          <option value="folder1">Folder 1</option>
          <option value="folder2">Folder 2</option>
        </select>
      </div>
    </div>

    <!-- File Upload -->
    <div>
      <label class="text-blue-700 block mb-2 font-medium">
        Select Files
      </label>
      <input
        type="file"
        multiple
        @change="handleFileChange"
        class="block w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
    </div>

    <!-- File List -->
    <div v-if="files.length > 0" class="space-y-4">
      <div
        v-for="(file, index) in files"
        :key="index"
        class="p-4 bg-blue-100 rounded-md flex flex-col space-y-2"
      >
        <p class="font-semibold text-blue-700">{{ file.name }}</p>
        <input
          type="text"
          class="p-2 bg-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="File Name"
          :value="file.name"
        />
        <textarea
          class="p-2 bg-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="Description"
          rows="3"
        ></textarea>
      </div>
    </div>

    <!-- Upload Button -->
    <button
      @click="handleUpload"
      class="bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors w-full"
    >
      Upload
    </button>
  </div>
</template>

<style scoped>
</style>
