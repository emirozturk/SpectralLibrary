import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
    tailwindcss(),
  ],
  base: '/',  // Ensures correct routing
  server: {
    port: 5173, // Adjust if needed
    sourcemap: true,
    historyApiFallback: true  // Enables fallback for Vue Router
  },
  build: {
    sourcemap: true, // Enable source maps
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
})
