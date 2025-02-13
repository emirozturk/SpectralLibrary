
<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Plotly from 'plotly.js-dist'

// Define interfaces
const props = defineProps({
  yourFiles: {
    type: Array,
    required: true
  }
})

const route = useRoute()
const router = useRouter()

const selectedFileItems = ref([])
const plotData = ref([])
const layout = ref({})

// Watch for changes in route query params
watch(() => route.query.files, (newFiles) => {
  setupPlot(newFiles)
}, { immediate: true })

const setupPlot = async (filesParam) => {
  if (!filesParam) {
    alert('No files selected for plotting.')
    router.push('/file-management') // Adjust route as needed
    return
  }

  const fileIds = filesParam.split(',').map(id => parseInt(id, 10))
  const filesToPlot = props.yourFiles.filter(file => fileIds.includes(file.id))

  if (filesToPlot.length === 0) {
    alert('Selected files not found.')
    router.push('/file-management') // Adjust route as needed
    return
  }

  selectedFileItems.value = filesToPlot

  // Prepare Plotly data
  plotData.value = filesToPlot.map(file => ({
    x: file.data.x,
    y: file.data.y,
    mode: 'lines+markers',
    type: 'scatter',
    name: file.name
  }))

  // Define layout
  layout.value = {
    title: 'Files Data Plot',
    xaxis: {
      title: 'X Axis',
      showgrid: true,
      zeroline: false
    },
    yaxis: {
      title: 'Y Axis',
      showline: false
    },
    autosize: true
  }

  // Create plot
  Plotly.newPlot('plotly-chart', plotData.value, layout.value, {
    displayModeBar: true,
    responsive: true
  })
}

const handleDownload = () => {
  const plotElement = document.getElementById('plotly-chart')
  if (plotElement) {
    Plotly.toImage(plotElement, { format: 'png', height: 600, width: 800 })
      .then(url => {
        const link = document.createElement('a')
        link.href = url
        link.download = 'plot.png'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
      })
  }
}

onMounted(() => {
  setupPlot(route.query.files)
})
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto bg-blue-50 rounded-lg min-h-screen flex flex-col space-y-8">
    <h1 class="text-4xl font-bold text-blue-700 mb-6 text-center">Plot Drawing</h1>

    <!-- Plotly Chart -->
    <div class="bg-white p-6 rounded-lg flex-1">
      <div id="plotly-chart" style="width: 100%; height: 100%"></div>
    </div>

    <!-- Download and Zoom Buttons -->
    <div class="flex space-x-4">
      <button
        @click="handleDownload"
        class="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors"
      >
        Download Plot
      </button>
    </div>
  </div>
</template>

<style scoped>
#plotly-chart {
  min-height: 500px;
}
</style>
