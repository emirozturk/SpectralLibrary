<script setup lang="js">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Disclosure, DisclosureButton, DisclosurePanel } from '@headlessui/vue'
import { getAllWithToken, putWithToken, delWithToken } from '../../../lib/fetch-api'
// Import icons from heroicons
import { EyeIcon, EyeSlashIcon, ShareIcon, TrashIcon } from '@heroicons/vue/24/solid'

const router = useRouter()

// --- Reactive state for file groups (from backend) ---
const files = ref([])           // Owned files (your files)
const sharedFiles = ref([])     // Files shared with you
const publicFiles = ref([])     // Public files

// --- Selections for drawing plots ---
const selectedFiles = ref([])
const selectedSharedFiles = ref([])
const selectedPublicFiles = ref([])

// --- Search query strings for filtering files ---
const searchFiles = ref('')
const searchSharedFiles = ref('')
const searchPublicFiles = ref('')

// --- Additional filter state for "Your Files" ---
const filterCategory = ref('')      // Selected category id (string); empty means no filter.
const filterSubcategory = ref('')   // Selected subcategory id
const filterFolder = ref('')        // Selected folder id

// --- Data for dropdown options ---
const categories = ref([])   // Fetched categories (each with a subcategories array)
const folderList = ref([])   // Fetched folders (all folders owned by the user)

// --- Fetch Data Functions ---
const fetchInitialData = async () => {
  // Owned Files:
  const filesRes = await getAllWithToken("spectfiles", null)
  if (filesRes.isSuccess) {
    files.value = filesRes.body
  } else {
    alert(filesRes.message)
  }
  // Shared Files:
  const sharedRes = await getAllWithToken("spectfiles/shared", null)
  if (sharedRes.isSuccess) {
    sharedFiles.value = sharedRes.body
  } else {
    alert(sharedRes.message)
  }
  // Public Files:
  const publicRes = await getAllWithToken("spectfiles/public", null)
  if (publicRes.isSuccess) {
    publicFiles.value = publicRes.body
  } else {
    alert(publicRes.message)
  }
}

const fetchCategories = async () => {
  const catRes = await getAllWithToken("categories", null)
  if (catRes.isSuccess) {
    categories.value = catRes.body
  } else {
    alert(catRes.message)
  }
}

const fetchFolders = async () => {
  const foldRes = await getAllWithToken("folders", null)
  if (foldRes.isSuccess) {
    folderList.value = foldRes.body
  } else {
    alert(foldRes.message)
  }
}

onMounted(async () => {
  await fetchInitialData()
  await fetchCategories()
  await fetchFolders()
})

// --- Computed: Filtered Lists ---
// For Owned Files, we apply the search query and our three additional filters.
const filteredMyFiles = computed(() => {
  return files.value.filter(file => {
    let match = true
    if (filterCategory.value) {
      match = match && (String(file.category_id) === filterCategory.value)
    }
    if (filterSubcategory.value) {
      match = match && (String(file.subcategory_id) === filterSubcategory.value)
    }
    if (filterFolder.value) {
      match = match && (String(file.folder_id) === filterFolder.value)
    }
    if (searchFiles.value.trim()) {
      const q = searchFiles.value.toLowerCase()
      match = match && ( (file.description || file.name).toLowerCase().includes(q) )
    }
    return match
  })
})

// For shared and public files, we use the search query only.
const filteredSharedFiles = computed(() => {
  if (!searchSharedFiles.value.trim()) return sharedFiles.value
  const q = searchSharedFiles.value.toLowerCase()
  return sharedFiles.value.filter(file =>
    (file.description || file.name).toLowerCase().includes(q)
  )
})
const filteredPublicFiles = computed(() => {
  if (!searchPublicFiles.value.trim()) return publicFiles.value
  const q = searchPublicFiles.value.toLowerCase()
  return publicFiles.value.filter(file =>
    (file.description || file.name).toLowerCase().includes(q)
  )
})

// --- Computed: Dropdown Options for Filtering ---
// Category dropdown options:
const categoryOptions = computed(() => {
  return categories.value.map(cat => ({
    id: String(cat.id),
    name: cat.name
  }))
})
// Subcategory dropdown options: if a category is selected, return its subcategories.
const subcategoryOptions = computed(() => {
  if (!filterCategory.value) return []
  const selectedCat = categories.value.find(cat => String(cat.id) === filterCategory.value)
  return selectedCat && selectedCat.subcategories
    ? selectedCat.subcategories.filter(sub => !sub.deleted_at).map(sub => ({
        id: String(sub.id),
        name: sub.name
      }))
    : []
})
// Folder dropdown options:
const folderOptions = computed(() => {
  return folderList.value.map(fold => ({
    id: String(fold.id),
    name: fold.name
  }))
})

// --- Handlers ---
// Toggle public/private status for a file
const togglePublic = async (file) => {
  const updated = { ...file, is_public: !file.is_public }
  const res = await putWithToken("spectfiles", updated)
  if (res.isSuccess) {
    await fetchInitialData()
  } else {
    alert(res.message)
  }
}

// Delete a file
const deleteFile = async (file) => {
  if (!confirm("Are you sure you want to delete this file?")) return
  const res = await delWithToken("spectfiles", file.id)
  if (res.isSuccess) {
    await fetchInitialData()
  } else {
    alert(res.message)
  }
}

// Share a file (using a simple prompt to get comma‑separated emails)
const shareFile = async (file) => {
  const emails = prompt("Enter comma-separated user emails to share with:")
  if (!emails) return
  const updated = { ...file, shared_with: emails.split(",").map(e => e.trim()) }
  const res = await putWithToken("spectfiles", updated)
  if (res.isSuccess) {
    await fetchInitialData()
    alert(`File ${file.description || file.name} shared successfully.`)
  } else {
    alert(res.message)
  }
}

// Draw Plot: gather selected file IDs from all sections and navigate to DrawPlot page.
const drawPlot = () => {
  const allSelected = [
    ...selectedFiles.value,
    ...selectedSharedFiles.value,
    ...selectedPublicFiles.value
  ]
  if (allSelected.length === 0) {
    alert("No files selected for plotting.")
    return
  }
  const ids = allSelected.map(file => file.id).join(',')
  router.push({ name: 'DrawPlot', query: { ids } })
}
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto bg-white rounded-lg min-h-screen flex flex-col space-y-8">
    <h1 class="text-4xl font-bold text-blue-700 text-center mb-6">User Main Page</h1>

    <!-- Owned Files Collapsible Group with Extra Filters -->
    <Disclosure>
      <template #default="{ open }">
        <DisclosureButton class="flex justify-between items-center w-full px-4 py-2 bg-white border border-gray-200 rounded-lg">
          <span class="text-blue-700 font-medium">Files</span>
          <span class="text-xl text-blue-700">{{ open ? '-' : '+' }}</span>
        </DisclosureButton>
        <DisclosurePanel class="px-4 py-2 bg-white">
          <!-- Extra Filter Dropdowns -->
          <div class="flex flex-col md:flex-row gap-4 mb-4">
            <!-- Category Filter -->
            <select v-model="filterCategory" class="w-full p-2 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value="">All Categories</option>
              <option v-for="opt in categoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <!-- Subcategory Filter -->
            <select v-model="filterSubcategory" class="w-full p-2 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value="">All Subcategories</option>
              <option v-for="opt in subcategoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <!-- Folder Filter -->
            <select v-model="filterFolder" class="w-full p-2 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value="">All Folders</option>
              <option v-for="opt in folderOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
          </div>
          <!-- Search Bar for Owned Files -->
          <input type="text" v-model="searchFiles" placeholder="Search your files..." class="w-full p-2 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 mb-4" />
          <!-- Files List (Modern Card Layout) -->
          <div class="grid gap-4">
            <div
              v-for="file in filteredMyFiles"
              :key="file.id"
              class="bg-white border border-gray-200 rounded-lg p-4 flex flex-col md:flex-row justify-between items-center"
            >
              <div>
                <div class="flex items-center space-x-2">
                  <input type="checkbox" v-model="selectedFiles" :value="file" class="mr-2" />
                  <h3 class="text-xl font-bold text-gray-800">
                    {{ file.description || file.name }}
                  </h3>
                </div>
                <p class="mt-1 text-sm text-gray-600">
                  Category: {{ file.category || 'N/A' }} |
                  Subcategory: {{ file.subcategory || 'N/A' }} |
                  Folder: {{ file.folder || 'N/A' }} |
                  Public: {{ file.is_public ? 'Yes' : 'No' }}
                </p>
              </div>
              <div class="flex space-x-2 mt-4 md:mt-0">
                <!-- Toggle Public Button with Icon -->
                <button @click="togglePublic(file)" class="p-2 bg-yellow-500 hover:bg-yellow-600 rounded">
                  <component :is="file.is_public ? EyeIcon : EyeSlashIcon" class="w-6 h-6 text-white" />
                </button>
                <!-- Share Button with Icon -->
                <button @click="shareFile(file)" class="p-2 bg-blue-500 hover:bg-blue-600 rounded">
                  <ShareIcon class="w-6 h-6 text-white" />
                </button>
                <!-- Delete Button with Icon -->
                <button @click="deleteFile(file)" class="p-2 bg-red-500 hover:bg-red-600 rounded">
                  <TrashIcon class="w-6 h-6 text-white" />
                </button>
              </div>
            </div>
          </div>
        </DisclosurePanel>
      </template>
    </Disclosure>

    <!-- Shared Files Collapsible Group (Modern Card Layout, No Action Buttons) -->
    <Disclosure>
      <template #default="{ open }">
        <DisclosureButton class="flex justify-between items-center w-full px-4 py-2 bg-white border border-gray-200 rounded-lg">
          <span class="text-blue-700 font-medium">Shared Files</span>
          <span class="text-xl text-blue-700">{{ open ? '-' : '+' }}</span>
        </DisclosureButton>
        <DisclosurePanel class="px-4 py-2 bg-white">
          <input type="text" v-model="searchSharedFiles" placeholder="Search shared files..." class="w-full p-2 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 mb-4" />
          <div class="grid gap-4">
            <div
              v-for="file in filteredSharedFiles"
              :key="file.id"
              class="bg-white border border-gray-200 rounded-lg p-4 flex flex-col justify-between items-center"
            >
              <div class="flex items-center space-x-2">
                <input type="checkbox" v-model="selectedSharedFiles" :value="file" class="mr-2" />
                <h3 class="text-xl font-bold text-gray-800">
                  {{ file.description || file.name }}
                </h3>
              </div>
              <p class="mt-1 text-sm text-gray-600">
                Category: {{ file.category?.name || 'N/A' }} |
                Subcategory: {{ file.subcategory?.name || 'N/A' }} |
                Folder: {{ file.folder?.name || 'N/A' }} |
                Public: {{ file.is_public ? 'Yes' : 'No' }}
              </p>
            </div>
          </div>
        </DisclosurePanel>
      </template>
    </Disclosure>

    <!-- Public Files Collapsible Group (Modern Card Layout, No Action Buttons) -->
    <Disclosure>
      <template #default="{ open }">
        <DisclosureButton class="flex justify-between items-center w-full px-4 py-2 bg-white border border-gray-200 rounded-lg">
          <span class="text-blue-700 font-medium">Public Files</span>
          <span class="text-xl text-blue-700">{{ open ? '-' : '+' }}</span>
        </DisclosureButton>
        <DisclosurePanel class="px-4 py-2 bg-white">
          <input type="text" v-model="searchPublicFiles" placeholder="Search public files..." class="w-full p-2 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 mb-4" />
          <div class="grid gap-4">
            <div
              v-for="file in filteredPublicFiles"
              :key="file.id"
              class="bg-white border border-gray-200 rounded-lg p-4 flex flex-col justify-between items-center"
            >
              <div class="flex items-center space-x-2">
                <input type="checkbox" v-model="selectedPublicFiles" :value="file" class="mr-2" />
                <h3 class="text-xl font-bold text-gray-800">
                  {{ file.description || file.name }}
                </h3>
              </div>
              <p class="mt-1 text-sm text-gray-600">
                Category: {{ file.category?.name || 'N/A' }} |
                Subcategory: {{ file.subcategory?.name || 'N/A' }} |
                Folder: {{ file.folder?.name || 'N/A' }} |
                Public: {{ file.is_public ? 'Yes' : 'No' }}
              </p>
            </div>
          </div>
        </DisclosurePanel>
      </template>
    </Disclosure>

    <!-- Draw Plot Button -->
    <div class="mt-6">
      <button @click="drawPlot" class="w-full bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors">
        Draw Plot
      </button>
    </div>
  </div>
</template>

<style scoped>
/* Additional styling can be added here */
</style>
