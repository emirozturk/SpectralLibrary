<script setup>
import { ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Plotly from 'plotly.js-dist'
import { getAllWithToken } from '../../../lib/fetch-api'

const route = useRoute()
const router = useRouter()

const selectedFileItems = ref([])
const plotData = ref([])
const layout = ref({})

const setupPlot = async (idsParam) => {
  console.log("setupPlot called with idsParam:", idsParam)
  if (!idsParam) {
    alert('No files selected for plotting.')
    router.push('/user/mainpage') // Adjust route as needed
    return
  }

  try {
    // Build the URL manually to include the query parameter "ids"
    const apiUrl = `spectfiles/draw?ids=${idsParam}`
    console.log("Calling API with URL:", apiUrl)
    const response = await getAllWithToken(apiUrl, null)

    if (!response.isSuccess) {
      throw new Error(response.message || 'Failed to fetch files.')
    }

    const filesToPlot = response.body
    if (!filesToPlot || filesToPlot.length === 0) {
      alert('Selected files not found.')
      router.push('/user/mainpage')
      return
    }

    // Prepare Plotly data based on the file data from backend.
    // Transform the array of objects to separate x and y arrays.
    // Change mode to 'lines' to not show the individual points.
    plotData.value = filesToPlot.map(file => ({
      x: file.data.map(point => point.x),
      y: file.data.map(point => point.y),
      mode: 'lines',
      type: 'scatter',
      name: file.description
    }))

    // Define layout for the plot.
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

    // Create the Plotly chart.
    Plotly.newPlot('plotly-chart', plotData.value, layout.value, {
      displayModeBar: true,
      responsive: true
    })
  } catch (error) {
    console.error("Error in setupPlot:", error)
    alert(error.message)
    router.push('/user/mainpage')
  }
}

// Watch for changes in the route query parameter "ids" and call setupPlot immediately.
watch(
  () => route.query.ids,
  (newIds) => {
    setupPlot(newIds)
  },
  { immediate: true }
)

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
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto bg-blue-50 rounded-lg min-h-screen flex flex-col space-y-8">
    <h1 class="text-4xl font-bold text-blue-700 mb-6 text-center">Plot Drawing</h1>

    <!-- Plotly Chart -->
    <div class="bg-white p-6 rounded-lg flex-1">
      <div id="plotly-chart" style="width: 100%; height: 100%"></div>
    </div>

    <!-- Download Button -->
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
