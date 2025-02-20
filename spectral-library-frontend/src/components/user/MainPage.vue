<script setup lang="js">
import { ref, computed, onMounted,defineEmits } from 'vue'
import { Disclosure, DisclosureButton, DisclosurePanel, Dialog } from '@headlessui/vue'
import { getAllWithToken, putWithToken, delWithToken } from '../../../lib/fetch-api'
import { EyeIcon, EyeSlashIcon, ShareIcon, TrashIcon } from '@heroicons/vue/24/solid'

const emit = defineEmits(['draw']) // <-- Declare an event to send selected file IDs to the parent

// --- Reactive state for file groups (from backend) ---
const files = ref([])           // Owned files (My Spectra)
const sharedFiles = ref([])     // Shared files (Shared Spectra)
const publicFiles = ref([])     // Public files (Public Spectra)

// --- Selections for drawing plots ---
const selectedMyFiles = ref([])
const selectedSharedFiles = ref([])
const selectedPublicFiles = ref([])

// --- Search query strings for filtering files ---
const searchMyFiles = ref('')
const searchSharedFiles = ref('')
const searchPublicFiles = ref('')

// --- Distinct filter state for each group ---
// For My Spectra (owned files)
const myFilterCategory = ref('')
const myFilterSubcategory = ref('')
const myFilterFolder = ref('')

// For Shared Spectra
const sharedFilterCategory = ref('')
const sharedFilterSubcategory = ref('')
const sharedFilterFolder = ref('')

// For Public Spectra
const publicFilterCategory = ref('')
const publicFilterSubcategory = ref('')
const publicFilterFolder = ref('')

// --- Data for dropdown options (global) ---
const categories = ref([])   // Fetched categories (each with a subcategories array)
const folderList = ref([])   // Fetched folders

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

/*
  --- Computed: Filtered Lists ---
  Note: Files store the category by name in file.category (and similarly for subcategory and folder).
*/

// My Spectra filtering
const filteredMyFiles = computed(() => {
  return files.value.filter(file => {
    let match = true
    if (myFilterCategory.value) {
      match = match && (file.category === myFilterCategory.value)
    }
    if (myFilterSubcategory.value) {
      match = match && (file.subcategory === myFilterSubcategory.value)
    }
    if (myFilterFolder.value) {
      match = match && (file.folder === myFilterFolder.value)
    }
    if (searchMyFiles.value.trim()) {
      const q = searchMyFiles.value.toLowerCase()
      match = match && ((file.description || file.name).toLowerCase().includes(q))
    }
    return match
  })
})

// Shared Spectra filtering
const filteredSharedFiles = computed(() => {
  return sharedFiles.value.filter(file => {
    let match = true
    if (sharedFilterCategory.value) {
      match = match && (file.category === sharedFilterCategory.value)
    }
    if (sharedFilterSubcategory.value) {
      match = match && (file.subcategory === sharedFilterSubcategory.value)
    }
    if (sharedFilterFolder.value) {
      match = match && (file.folder === sharedFilterFolder.value)
    }
    if (searchSharedFiles.value.trim()) {
      const q = searchSharedFiles.value.toLowerCase()
      match = match && ((file.description || file.name).toLowerCase().includes(q))
    }
    return match
  })
})

// Public Spectra filtering
const filteredPublicFiles = computed(() => {
  return publicFiles.value.filter(file => {
    let match = true
    if (publicFilterCategory.value) {
      match = match && (file.category === publicFilterCategory.value)
    }
    if (publicFilterSubcategory.value) {
      match = match && (file.subcategory === publicFilterSubcategory.value)
    }
    if (publicFilterFolder.value) {
      match = match && (file.folder === publicFilterFolder.value)
    }
    if (searchPublicFiles.value.trim()) {
      const q = searchPublicFiles.value.toLowerCase()
      match = match && ((file.description || file.name).toLowerCase().includes(q))
    }
    return match
  })
})

/*
  --- Computed: Dropdown Options ---
  We build the dropdown options from the fetched categories and folders.
  We assume the category name to be used as both id and display text.
*/

const categoryOptions = computed(() => {
  return categories.value.map(cat => ({
    id: cat.name_en, // using the name as key (e.g. "c1")
    name: cat.name_en
  }))
})

// For subcategories, each group’s options depend on the group’s selected category.
const mySubcategoryOptions = computed(() => {
  if (!myFilterCategory.value) return []
  const selectedCat = categories.value.find(cat => cat.name_en === myFilterCategory.value)
  return selectedCat && selectedCat.subcategories
    ? selectedCat.subcategories.filter(sub => !sub.deleted_at).map(sub => ({
        id: sub.name_en,
        name: sub.name_en
      }))
    : []
})

const sharedSubcategoryOptions = computed(() => {
  if (!sharedFilterCategory.value) return []
  const selectedCat = categories.value.find(cat => cat.name_en === sharedFilterCategory.value)
  return selectedCat && selectedCat.subcategories
    ? selectedCat.subcategories.filter(sub => !sub.deleted_at).map(sub => ({
        id: sub.name_en,
        name: sub.name_en
      }))
    : []
})

const publicSubcategoryOptions = computed(() => {
  if (!publicFilterCategory.value) return []
  const selectedCat = categories.value.find(cat => cat.name_en === publicFilterCategory.value)
  return selectedCat && selectedCat.subcategories
    ? selectedCat.subcategories.filter(sub => !sub.deleted_at).map(sub => ({
        id: sub.name_en,
        name: sub.name_en
      }))
    : []
})

// Folder options (global)
const folderOptions = computed(() => {
  return folderList.value.map(fold => ({
    id: fold.name, // assuming file.folder stores folder name
    name: fold.name
  }))
})

/*
  --- Handlers ---
*/

const togglePublic = async (file) => {
  const updated = { ...file, is_public: !file.is_public }
  const res = await putWithToken("spectfiles", updated)
  if (res.isSuccess) {
    await fetchInitialData()
  } else {
    alert(res.message)
  }
}

const deleteFile = async (file) => {
  if (!confirm("Are you sure you want to delete this file?")) return
  const res = await delWithToken("spectfiles", file.id)
  if (res.isSuccess) {
    await fetchInitialData()
  } else {
    alert(res.message)
  }
}

// --- Share Modal Reactive State and Functions ---
const showShareModal = ref(false)
const currentFileToShare = ref(null)
const allUsers = ref([])
const searchUsers = ref('')
const selectedUserEmails = ref([])

const fetchUsers = async () => {
  const res = await getAllWithToken("users", null)
  if (res.isSuccess) {
    allUsers.value = res.body
  } else {
    alert(res.message)
  }
}

const filteredUsers = computed(() => {
  if (!searchUsers.value.trim()) return allUsers.value
  const q = searchUsers.value.toLowerCase()
  return allUsers.value.filter(user =>
    user.email.toLowerCase().includes(q) ||
    (user.name && user.name.toLowerCase().includes(q))
  )
})

const shareFile = async (file) => {
  currentFileToShare.value = file
  if (allUsers.value.length === 0) {
    await fetchUsers()
  }
  if (file.shared_with && Array.isArray(file.shared_with)) {
    selectedUserEmails.value = [...file.shared_with]
  } else {
    selectedUserEmails.value = []
  }
  searchUsers.value = ''
  showShareModal.value = true
}

const confirmShare = async () => {
  if (selectedUserEmails.value.length === 0) {
    alert("Please select at least one user to share with.")
    return
  }
  const payload = {
    file_id: currentFileToShare.value.id,
    shared_with: selectedUserEmails.value,
  }
  const res = await putWithToken("spectfiles/share", payload)
  if (res.isSuccess) {
    await fetchInitialData()
    alert(`File ${currentFileToShare.value.description || currentFileToShare.value.name} shared successfully.`)
    showShareModal.value = false
    currentFileToShare.value = null
  } else {
    alert(res.message)
  }
}

const drawPlot = () => {
  // Combine selected files from all groups
  const allSelected = [
    ...selectedMyFiles.value,
    ...selectedSharedFiles.value,
    ...selectedPublicFiles.value
  ]
  if (allSelected.length === 0) {
    alert("No files selected for plotting.")
    return
  }
  // Get an array of file IDs (do not join them to a string here)
  const ids = allSelected.map(file => file.id)
  // Emit the event with the selected file IDs.
  emit('draw', ids)
}

// --- Pagination State ---
const itemsPerPage = 10
const currentPageMyFiles = ref(1)
const currentPageSharedFiles = ref(1)
const currentPagePublicFiles = ref(1)

// --- Computed: Paginated Lists ---
const paginatedMyFiles = computed(() => {
  const start = (currentPageMyFiles.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredMyFiles.value.slice(start, end)
})

const paginatedSharedFiles = computed(() => {
  const start = (currentPageSharedFiles.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredSharedFiles.value.slice(start, end)
})

const paginatedPublicFiles = computed(() => {
  const start = (currentPagePublicFiles.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredPublicFiles.value.slice(start, end)
})

// --- Computed: Total Pages ---
const totalPagesMyFiles = computed(() => Math.ceil(filteredMyFiles.value.length / itemsPerPage))
const totalPagesSharedFiles = computed(() => Math.ceil(filteredSharedFiles.value.length / itemsPerPage))
const totalPagesPublicFiles = computed(() => Math.ceil(filteredPublicFiles.value.length / itemsPerPage))

// --- Methods: Pagination Handlers ---
const changePageMyFiles = (page) => {
  if (page >= 1 && page <= totalPagesMyFiles.value) {
    currentPageMyFiles.value = page
  }
}

const changePageSharedFiles = (page) => {
  if (page >= 1 && page <= totalPagesSharedFiles.value) {
    currentPageSharedFiles.value = page
  }
}

const changePagePublicFiles = (page) => {
  if (page >= 1 && page <= totalPagesPublicFiles.value) {
    currentPagePublicFiles.value = page
  }
}


</script>

<template>
   <div class="p-8 max-w-7xl mx-auto bg-white rounded-lg h-full flex flex-col space-y-8">

    <!-- Public Spectra Section -->
    <Disclosure>
      <template #default="{ open }">
        <DisclosureButton class="flex justify-between items-center w-full px-4 py-2 bg-white border border-gray-200 rounded-lg">
          <span class="text-blue-700 font-medium">Public Spectra</span>
          <span class="text-xl text-blue-700">{{ open ? '-' : '+' }}</span>
        </DisclosureButton>
        <DisclosurePanel class="px-4 py-2 bg-white">
          <!-- Filter Dropdowns for Public Spectra -->
          <div class="flex flex-col md:flex-row gap-4 mb-4">
            <select v-model="publicFilterCategory" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Categories</option>
              <option v-for="opt in categoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <select v-model="publicFilterSubcategory" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Subcategories</option>
              <option v-for="opt in publicSubcategoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <select v-model="publicFilterFolder" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Folders</option>
              <option v-for="opt in folderOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
          </div>
          <!-- Search Input -->
          <input type="text" v-model="searchPublicFiles" placeholder="Search public files..." class="w-full p-2 border border-gray-300 rounded-md mb-4" />
          <!-- Files List -->
          <div class="grid gap-4">
            <div v-for="file in paginatedPublicFiles" :key="file.id" class="bg-white border border-gray-200 rounded-lg p-4">
              <div class="flex items-center space-x-2">
                <input type="checkbox" v-model="selectedPublicFiles" :value="file" class="mr-2" />
                <h3 class="text-xl font-bold">{{ file.description || file.name }}</h3>
              </div>
              <p class="mt-1 text-sm">
                Category: {{ file.category || 'N/A' }} |
                Subcategory: {{ file.subcategory || 'N/A' }} |
                Folder: {{ file.folder || 'N/A' }} |
                Public: {{ file.is_public ? 'Yes' : 'No' }}
              </p>
            </div>
          </div>
          <!-- Pagination Controls -->
          <div class="flex justify-center mt-4">
            <button @click="changePagePublicFiles(currentPagePublicFiles - 1)" :disabled="currentPagePublicFiles === 1" class="px-3 py-1 bg-gray-300 rounded-l-md">Previous</button>
            <span class="px-3 py-1 bg-gray-100">{{ currentPagePublicFiles }} / {{ totalPagesPublicFiles }}</span>
            <button @click="changePagePublicFiles(currentPagePublicFiles + 1)" :disabled="currentPagePublicFiles === totalPagesPublicFiles" class="px-3 py-1 bg-gray-300 rounded-r-md">Next</button>
          </div>
        </DisclosurePanel>
      </template>
    </Disclosure>

    <!-- Shared Spectra Section -->
    <Disclosure>
      <template #default="{ open }">
        <DisclosureButton class="flex justify-between items-center w-full px-4 py-2 bg-white border border-gray-200 rounded-lg">
          <span class="text-blue-700 font-medium">Shared Spectra</span>
          <span class="text-xl text-blue-700">{{ open ? '-' : '+' }}</span>
        </DisclosureButton>
        <DisclosurePanel class="px-4 py-2 bg-white">
          <!-- Filter Dropdowns for Shared Spectra -->
          <div class="flex flex-col md:flex-row gap-4 mb-4">
            <select v-model="sharedFilterCategory" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Categories</option>
              <option v-for="opt in categoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <select v-model="sharedFilterSubcategory" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Subcategories</option>
              <option v-for="opt in sharedSubcategoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <select v-model="sharedFilterFolder" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Folders</option>
              <option v-for="opt in folderOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
          </div>
          <!-- Search Input -->
          <input type="text" v-model="searchSharedFiles" placeholder="Search shared files..." class="w-full p-2 border border-gray-300 rounded-md mb-4" />
          <!-- Files List -->
          <div class="grid gap-4">
            <div v-for="file in paginatedSharedFiles" :key="file.id" class="bg-white border border-gray-200 rounded-lg p-4">
              <div class="flex items-center space-x-2">
                <input type="checkbox" v-model="selectedSharedFiles" :value="file" class="mr-2" />
                <h3 class="text-xl font-bold">{{ file.description || file.name }}</h3>
              </div>
              <p class="mt-1 text-sm">
                Category: {{ file.category || 'N/A' }} |
                Subcategory: {{ file.subcategory || 'N/A' }} |
                Folder: {{ file.folder || 'N/A' }} |
                Public: {{ file.is_public ? 'Yes' : 'No' }}
              </p>
            </div>
          </div>
          <!-- Pagination Controls -->
          <div class="flex justify-center mt-4">
            <button @click="changePageSharedFiles(currentPageSharedFiles - 1)" :disabled="currentPageSharedFiles === 1" class="px-3 py-1 bg-gray-300 rounded-l-md">Previous</button>
            <span class="px-3 py-1 bg-gray-100">{{ currentPageSharedFiles }} / {{ totalPagesSharedFiles }}</span>
            <button @click="changePageSharedFiles(currentPageSharedFiles + 1)" :disabled="currentPageSharedFiles === totalPagesSharedFiles" class="px-3 py-1 bg-gray-300 rounded-r-md">Next</button>
          </div>
        </DisclosurePanel>
      </template>
    </Disclosure>

    <!-- My Spectra Section -->
    <Disclosure>
      <template #default="{ open }">
        <DisclosureButton class="flex justify-between items-center w-full px-4 py-2 bg-white border border-gray-200 rounded-lg">
          <span class="text-blue-700 font-medium">My Spectra</span>
          <span class="text-xl text-blue-700">{{ open ? '-' : '+' }}</span>
        </DisclosureButton>
        <DisclosurePanel class="px-4 py-2 bg-white">
          <!-- Filter Dropdowns for My Spectra -->
          <div class="flex flex-col md:flex-row gap-4 mb-4">
            <select v-model="myFilterCategory" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Categories</option>
              <option v-for="opt in categoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <select v-model="myFilterSubcategory" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Subcategories</option>
              <option v-for="opt in mySubcategoryOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
            <select v-model="myFilterFolder" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="">All Folders</option>
              <option v-for="opt in folderOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
          </div>
          <!-- Search Input -->
          <input type="text" v-model="searchMyFiles" placeholder="Search your files..." class="w-full p-2 border border-gray-300 rounded-md mb-4" />
          <!-- Files List -->
          <div class="grid gap-4">
            <div v-for="file in paginatedMyFiles" :key="file.id" class="bg-white border border-gray-200 rounded-lg p-4 flex flex-col md:flex-row justify-between items-center">
              <div>
                <div class="flex items-center space-x-2">
                  <input type="checkbox" v-model="selectedMyFiles" :value="file" class="mr-2" />
                  <h3 class="text-xl font-bold">{{ file.description || file.name }}</h3>
                </div>
                <p class="mt-1 text-sm">
                  Category: {{ file.category || 'N/A' }} |
                  Subcategory: {{ file.subcategory || 'N/A' }} |
                  Folder: {{ file.folder || 'N/A' }} |
                  Public: {{ file.is_public ? 'Yes' : 'No' }}
                </p>
              </div>
              <div class="flex space-x-2 mt-4 md:mt-0">
                <button @click="togglePublic(file)" class="p-2 bg-yellow-500 hover:bg-yellow-600 rounded">
                  <component :is="file.is_public ? EyeIcon : EyeSlashIcon" class="w-6 h-6 text-white" />
                </button>
                <button @click="shareFile(file)" class="p-2 bg-blue-500 hover:bg-blue-600 rounded">
                  <ShareIcon class="w-6 h-6 text-white" />
                </button>
                <button @click="deleteFile(file)" class="p-2 bg-red-500 hover:bg-red-600 rounded">
                  <TrashIcon class="w-6 h-6 text-white" />
                </button>
              </div>
            </div>
          </div>
          <!-- Pagination Controls -->
          <div class="flex justify-center mt-4">
            <button @click="changePageMyFiles(currentPageMyFiles - 1)" :disabled="currentPageMyFiles === 1" class="px-3 py-1 bg-gray-300 rounded-l-md">Previous</button>
            <span class="px-3 py-1 bg-gray-100">{{ currentPageMyFiles }} / {{ totalPagesMyFiles }}</span>
            <button @click="changePageMyFiles(currentPageMyFiles + 1)" :disabled="currentPageMyFiles === totalPagesMyFiles" class="px-3 py-1 bg-gray-300 rounded-r-md">Next</button>
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

    <!-- Share Modal (using Headless UI Dialog) -->
    <Dialog :open="showShareModal" as="div" class="fixed inset-0 z-10 overflow-y-auto" @close="showShareModal = false">
      <div class="min-h-screen px-4 text-center">
        <Dialog.Overlay class="fixed inset-0 bg-black opacity-30" />
        <span class="inline-block h-screen align-middle" aria-hidden="true">&#8203;</span>
        <div class="inline-block w-full max-w-md p-6 my-8 overflow-hidden text-left align-middle transition-all transform bg-white shadow-xl rounded-lg">
          <Dialog.Title class="text-lg font-medium leading-6 text-gray-900">
            Share File: {{ currentFileToShare?.description || currentFileToShare?.name }}
          </Dialog.Title>
          <div class="mt-4">
            <input type="text" v-model="searchUsers" placeholder="Search users..." class="w-full p-2 border border-gray-300 rounded-md mb-4" />
            <div class="max-h-60 overflow-y-auto border border-gray-200 rounded-md p-2">
              <div v-for="user in filteredUsers" :key="user.id" class="flex items-center py-1">
                <input type="checkbox" :value="user.email" v-model="selectedUserEmails" class="mr-2" />
                <span>{{ user.name }} ({{ user.email }})</span>
              </div>
              <div v-if="filteredUsers.length === 0" class="text-gray-500 text-center py-2">
                No users found.
              </div>
            </div>
          </div>
          <div class="mt-6 flex justify-end space-x-2">
            <button @click="showShareModal = false" class="px-4 py-2 bg-gray-300 text-gray-800 rounded-md hover:bg-gray-400">
              Cancel
            </button>
            <button @click="confirmShare" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
              Share
            </button>
          </div>
        </div>
      </div>
    </Dialog>
  </div>
</template>
