<script setup>
import { ref, onMounted } from 'vue'
import Split from 'split.js'
import MainPage from './MainPage.vue'
import DrawPlot from './DrawPlot.vue'

const selectedFileIds = ref([]) // Stores selected file IDs

// Function to update selected files and trigger plot update.
const updatePlot = (ids) => {
  selectedFileIds.value = ids
}

// Create refs for the left and right panels.
const leftPanel = ref(null)
const rightPanel = ref(null)

onMounted(() => {
  // Ensure the panels exist before initializing Split.js.
  if (leftPanel.value && rightPanel.value) {
    Split([leftPanel.value, rightPanel.value], {
      sizes: [50, 50],   // initial sizes in percentages
      minSize: [200, 300], // minimum pixel sizes for each panel
      gutterSize: 10,      // width of the draggable divider
      cursor: 'col-resize'
    })
  }
})
</script>

<template>
  <div class="flex">
    <div ref="leftPanel" class="bg-white ">
      <MainPage @draw="updatePlot" />
    </div>
    <div ref="rightPanel" class="bg-white">
      <DrawPlot :selectedIds="selectedFileIds" />
    </div>
  </div>
</template>

<style>
.gutter {
  background-color: #eee; /* Light gray background */
  background-repeat: no-repeat;
  background-position: 50%;
}

.gutter.gutter-horizontal {
  cursor: col-resize;
}
</style>
