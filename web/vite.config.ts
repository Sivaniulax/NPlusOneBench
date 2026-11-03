import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Served from https://sivaniulax.github.io/NPlusOneBench/
export default defineConfig({
  base: '/NPlusOneBench/',
  plugins: [react()],
})
