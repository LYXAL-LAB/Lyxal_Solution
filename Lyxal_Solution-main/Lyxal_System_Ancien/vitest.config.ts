import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './ui/setupTests.ts',
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, './ui'),
      '@hooks': resolve(__dirname, './ui/hooks'),
      '@services': resolve(__dirname, './ui/services'),
      '@utils': resolve(__dirname, './ui/utils'),
      '@pages': resolve(__dirname, './ui/pages'),
    },
  },
});

