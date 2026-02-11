import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      // Alias pour accéder aux autres modules
      'lyxalkitui': path.resolve(__dirname, '../lyxalkitui/src'),
      'lyxal-surreal': path.resolve(__dirname, '../lyxal-surreal/src'),
    }
  },
  server: {
    port: 3001, // Port différent de lyxalkitui (3000)
    host: true
  },
  build: {
    outDir: 'dist',
    sourcemap: true
  }
}); 