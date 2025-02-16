<script setup>
import { ref, onMounted } from 'vue'
import { getAllWithToken, postWithToken, putWithToken, delWithToken } from '../../../lib/fetch-api'

// Reactive state for folders and the new folder name.
const folders = ref([])
const newFolder = ref('')

// Helper: Fetch folders from the backend.
const fetchFolders = async () => {
  const response = await getAllWithToken("folders", null)
  if (response.isSuccess) {
    folders.value = response.body
  } else {
    alert(response.message)
  }
}

onMounted(async () => {
  await fetchFolders()
})


const addFolder = async () => {
  if (newFolder.value.trim() === '') {
    alert('Folder name cannot be empty.')
    return
  }
  const newFolderData = { name: newFolder.value.trim() }
  const response = await postWithToken("folders", newFolderData)
  if (response.isSuccess) {
    newFolder.value = ''
    await fetchFolders()
  } else {
    alert(response.message)
  }
}

// Handler: Delete a folder.
const deleteFolder = async (folderId) => {
  if (window.confirm('Are you sure you want to delete this folder?')) {
    const response = await delWithToken("folders", folderId)
    if (response.isSuccess) {
      await fetchFolders()
    } else {
      alert(response.message)
    }
  }
}

// Handler: Rename a folder.
const renameFolder = async (folder) => {
  const currentName = folder.name
  const newName = prompt('Enter the new folder name:', currentName)
  if (newName && newName.trim() !== '') {
    const updatedFolder = { id: folder.id, name: newName.trim() }
    const response = await putWithToken("folders", updatedFolder)
    if (response.isSuccess) {
      await fetchFolders()
    } else {
      alert(response.message)
    }
  } else {
    alert('Folder name cannot be empty.')
  }
}
</script>

<template>
  <div class="p-8 max-w-3xl mx-auto bg-blue-50 rounded-lg min-h-screen flex flex-col space-y-8">
    <h1 class="text-3xl font-bold text-blue-700 text-center">
      Folder Management
    </h1>

    <!-- Add Folder Section -->
    <div class="flex flex-col md:flex-row items-center space-y-4 md:space-y-0 md:space-x-4">
      <input
        type="text"
        v-model="newFolder"
        placeholder="New Folder"
        class="flex-1 p-3 bg-blue-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        @keyup.enter="addFolder"
      />
      <button
        @click="addFolder"
        class="w-full md:w-auto bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors"
      >
        Add Folder
      </button>
    </div>

    <!-- Folders List -->
    <ul class="space-y-4">
      <li
        v-for="folder in folders"
        :key="folder.id"
        class="flex justify-between items-center p-4 bg-blue-100 rounded-md"
      >
        <span class="text-lg font-medium text-blue-800">{{ folder.name }}</span>
        <div class="flex space-x-2">
          <button
            @click="renameFolder(folder)"
            class="bg-yellow-500 text-white px-4 py-2 rounded-md hover:bg-yellow-600 transition-colors"
          >
            Rename
          </button>
          <button
            @click="deleteFolder(folder.id)"
            class="bg-red-500 text-white px-4 py-2 rounded-md hover:bg-red-600 transition-colors"
          >
            Delete
          </button>
        </div>
      </li>
      <li v-if="folders.length === 0" class="text-center text-gray-500">
        No folders available.
      </li>
    </ul>
  </div>
</template>
