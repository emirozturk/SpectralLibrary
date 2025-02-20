<script setup>
import { ref, watch, defineProps, onMounted, onBeforeUnmount } from 'vue'
import Plotly from 'plotly.js-dist'
import { getAllWithToken } from '../../../lib/fetch-api'

const props = defineProps({
  selectedIds: {
    type: Array,
    default: () => []
  }
})

const plotData = ref([])
const layout = ref({})
const useSeparateYAxes = ref(false)
const plotContainer = ref(null)  // Ref for the chart container element
let resizeObserver = null

const setupPlot = async () => {
  if (!props.selectedIds || props.selectedIds.length === 0) {
    // Optionally, clear the plot if no IDs are provided.
    return
  }
  const fileIds = props.selectedIds.join(',')
  const apiUrl = `spectfiles/draw?ids=${fileIds}`
  const response = await getAllWithToken(apiUrl, null)

  if (!response.isSuccess) {
    alert(response.message || 'Failed to fetch files.')
    return
  }

  const filesToPlot = response.body
  if (!filesToPlot || filesToPlot.length === 0) {
    alert('Selected files not found.')
    return
  }

  plotData.value = filesToPlot.map((file, index) => ({
    x: file.data.map(point => point.x),
    y: file.data.map(point => point.y),
    mode: 'lines',
    type: 'scatter',
    name: file.description,
    yaxis: useSeparateYAxes.value ? `y${index + 1}` : 'y'
  }))

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

  if (useSeparateYAxes.value) {
    plotData.value.forEach((_, index) => {
      if (index > 0) {
        layout.value[`yaxis${index + 1}`] = {
          title: `Y Axis ${index + 1}`,
          overlaying: 'y',
          side: 'right'
        }
      }
    })
  }

  Plotly.newPlot('plotly-chart', plotData.value, layout.value, {
    displayModeBar: true,
    responsive: true
  })
}

// Watch for changes in selectedIds and update the plot.
watch(() => props.selectedIds, () => {
  setupPlot()
}, { immediate: true })

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

const toggleYAxes = () => {
  useSeparateYAxes.value = !useSeparateYAxes.value
  setupPlot()
}

// Use a ResizeObserver to trigger Plotly resize when the container changes.
onMounted(() => {
  if (plotContainer.value) {
    resizeObserver = new ResizeObserver(() => {
      Plotly.Plots.resize(plotContainer.value)
    })
    resizeObserver.observe(plotContainer.value)
  }
})
onBeforeUnmount(() => {
  if (resizeObserver) {
    resizeObserver.disconnect()
  }
})
</script>

<template>
  <!-- Remove min-h-screen and use h-full to fill the available space -->
  <div class="p-8 h-full max-w-full mx-auto bg-white-50 rounded-lg flex flex-col">
    <!-- Chart Container -->
    <div class="flex-1 overflow-hidden">
      <div class="bg-white p-6 rounded-lg h-full" ref="plotContainer">
        <div id="plotly-chart" class="w-full h-full"></div>
      </div>
    </div>
    <!-- Controls (centered) -->
    <div class="flex justify-center space-x-4 mt-4">
      <button
        @click="handleDownload"
        class="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors"
      >
        Download Plot
      </button>
      <button
        @click="toggleYAxes"
        class="bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 transition-colors"
      >
        Toggle Separate Y-Axes
      </button>
    </div>
  </div>
</template>


<style scoped>
/* Ensure the Plotly chart fills its container */
#plotly-chart {
  width: 100%;
  height: 100%;
}
</style>
