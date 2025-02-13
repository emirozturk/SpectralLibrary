<script setup>
import { ref } from 'vue'

const folders = ref(['Folder 1', 'Folder 2'])
const newFolder = ref('')

const addFolder = () => {
  if (newFolder.value.trim() === '') {
    alert('Folder name cannot be empty.')
    return
  }
  folders.value.push(newFolder.value.trim())
  newFolder.value = ''
}

const deleteFolder = (index) => {
  if (window.confirm('Are you sure you want to delete this folder?')) {
    folders.value = folders.value.filter((_, i) => i !== index)
  }
}

const renameFolder = (index) => {
  const currentName = folders.value[index]
  const newName = prompt('Enter the new folder name:', currentName)
  if (newName && newName.trim() !== '') {
    folders.value[index] = newName.trim()
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
        v-for="(folder, index) in folders"
        :key="index"
        class="flex justify-between items-center p-4 bg-blue-100 rounded-md"
      >
        <span class="text-lg font-medium text-blue-800">{{ folder }}</span>
        <div class="flex space-x-2">
          <button
            @click="renameFolder(index)"
            class="bg-yellow-500 text-white px-4 py-2 rounded-md hover:bg-yellow-600 transition-colors"
          >
            Rename
          </button>
          <button
            @click="deleteFolder(index)"
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

<style scoped>
</style>
