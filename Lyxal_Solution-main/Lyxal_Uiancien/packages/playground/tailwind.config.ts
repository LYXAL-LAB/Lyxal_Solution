import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/**/*.{html,js,jsx,ts,tsx}',
    './index.html',
  ],

  darkMode: 'class',

  theme: {
    extend: {
      // Lyxal UI gère déjà toutes les couleurs de thème
      colors: {
        // Couleurs supplémentaires si nécessaire
      },

      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['Fira Code', 'Consolas', 'monospace'],
      },
    },
  },

  plugins: [
    // Lyxal UI gère tous les composants et thèmes via @plugin dans index.css
  ],
};

export default config;
