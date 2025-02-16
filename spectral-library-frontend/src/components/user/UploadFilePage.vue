<script setup lang="js">
import { ref, computed, onMounted } from 'vue'
import { postWithToken, getAllWithToken } from '../../../lib/fetch-api'

// Create a ref for the file input element.
const fileInput = ref(null)

// --- Reactive State ---
const files = ref([])                      // Array to hold selected File objects
const category = ref('')                   // Selected category id
const subcategory = ref('')                // Selected subcategory id
const folder = ref('')                     // Selected folder id
const description = ref('')                // Optional file description
const error = ref(null)

// Options fetched from backend endpoints
const categoryOptions = ref([])            // List of categories (each with subcategories)
const folderOptions = ref([])              // List of folders for the current user

// File properties (example: number of data points, computed from file text)
const fileProperties = ref(null)

// --- Computed: Filter Subcategories Based on Selected Category ---
const filteredSubcategories = computed(() => {
  if (!category.value) return []
  const selectedCat = categoryOptions.value.find(
    (cat) => cat.id === Number(category.value)
  )
  return selectedCat && selectedCat.subcategories
    ? selectedCat.subcategories.filter(sub => sub.deleted_at === null)
    : []
})

// --- Data Fetching Functions ---
const fetchCategories = async () => {
  const response = await getAllWithToken("categories", null)
  if (response.isSuccess) {
    categoryOptions.value = response.body
  } else {
    error.value = response.message
  }
}

const fetchFolders = async () => {
  const response = await getAllWithToken("folders", null)
  if (response.isSuccess) {
    folderOptions.value = response.body
  } else {
    error.value = response.message
  }
}

onMounted(async () => {
  await fetchCategories()
  await fetchFolders()
})

// --- File Selection & Processing ---
// Returns the first selected file (if any)
const selectedFile = computed(() => files.value[0] || null)

const handleFileChange = (event) => {
  files.value = Array.from(event.target.files || [])
  if (selectedFile.value) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const content = e.target.result
      // Count nonempty lines to estimate data points.
      const lines = content.split(/\r?\n/).filter(line => line.trim() !== '')
      fileProperties.value = { dataPointCount: lines.length }
    }
    reader.readAsText(selectedFile.value)
  } else {
    fileProperties.value = null
  }
}

// Helper to convert a File object to a Base64 string (without data URL prefix)
const convertFileToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => {
      // reader.result is a data URL string like "data:text/plain;base64,AAAA..."
      const result = reader.result
      const base64String = result.split(",")[1] // Remove the prefix
      resolve(base64String)
    }
    reader.onerror = (error) => reject(error)
    reader.readAsDataURL(file)
  })
}

// --- Upload Handler ---
const handleUpload = async () => {
  // Validate required selections
  if (!category.value || !subcategory.value || !folder.value) {
    error.value = "Please select a category, subcategory, and folder."
    return
  }
  if (!selectedFile.value) {
    error.value = "Please select a file to upload."
    return
  }

  try {
    // Convert the file to a Base64 string.
    const fileContentBase64 = await convertFileToBase64(selectedFile.value)

    // Build the JSON payload.
    const payload = {
      folder_id: folder.value,
      subcategory_id: subcategory.value,
      file_name: selectedFile.value.name,
      file_content: fileContentBase64,
      description: description.value,
      is_public: false
    }

    // Send the payload to the backend.
    const response = await postWithToken("spectfiles/upload", payload)
    if (response.isSuccess) {
      alert("File uploaded successfully!")
      // Reset the form.
      files.value = []
      category.value = ''
      subcategory.value = ''
      folder.value = ''
      description.value = ''
      fileProperties.value = null
      error.value = null
      // Clear the file input element so a new selection will fire change event.
      if (fileInput.value) {
        fileInput.value.value = ''
      }
      // Optionally re-fetch folders or categories if needed.
      await fetchFolders()
      await fetchCategories()
    } else {
      error.value = response.message
    }
  } catch (err) {
    error.value = "Upload failed: " + err.message
  }
}
</script>

<template>
  <div class="p-8 max-w-4xl mx-auto bg-blue-50 rounded-lg min-h-screen flex flex-col space-y-8">
    <h2 class="text-3xl font-bold text-blue-700 text-center">Upload Spectral File</h2>

    <!-- Error Message -->
    <div v-if="error" class="bg-red-100 text-red-700 p-3 rounded mb-4">
      {{ error }}
    </div>

    <!-- Dropdowns Section -->
    <div class="space-y-6">
      <!-- Category Dropdown -->
      <div>
        <label class="text-blue-700 block mb-2 font-medium">Category</label>
        <select v-model="category" class="w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
          <option value="">Select Category</option>
          <option v-for="cat in categoryOptions" :key="cat.id" :value="cat.id">
            {{ cat.name_en }}
          </option>
        </select>
      </div>

      <!-- Subcategory Dropdown (filtered by selected category) -->
      <div>
        <label class="text-blue-700 block mb-2 font-medium">Subcategory</label>
        <select v-model="subcategory" class="w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
          <option value="">Select Subcategory</option>
          <option v-for="sub in filteredSubcategories" :key="sub.id" :value="sub.id">
            {{ sub.name_en }}
          </option>
        </select>
      </div>

      <!-- Folder Dropdown -->
      <div>
        <label class="text-blue-700 block mb-2 font-medium">Folder</label>
        <select v-model="folder" class="w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
          <option value="">Select Folder</option>
          <option v-for="f in folderOptions" :key="f.id" :value="f.id">
            {{ f.name }}
          </option>
        </select>
      </div>

      <!-- Description Field -->
      <div>
        <label class="text-blue-700 block mb-2 font-medium">Description (optional)</label>
        <textarea v-model="description" rows="3" class="w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter file description"></textarea>
      </div>
    </div>

    <!-- File Input -->
    <div>
      <label class="text-blue-700 block mb-2 font-medium">Select File</label>
      <!-- Added ref="fileInput" to get a reference to the element -->
      <input type="file" @change="handleFileChange" ref="fileInput" class="block w-full p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
    </div>

    <!-- Display File Properties (e.g. data point count) -->
    <div v-if="fileProperties" class="p-4 bg-blue-100 rounded-md">
      <p class="text-blue-700">Data Points: {{ fileProperties.dataPointCount }}</p>
    </div>

    <!-- Upload Button -->
    <button @click="handleUpload" class="bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors w-full">
      Upload
    </button>
  </div>
</template>

<style scoped>
/* Add any additional scoped styles here */
</style>
