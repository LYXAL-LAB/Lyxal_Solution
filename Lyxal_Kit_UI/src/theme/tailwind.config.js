/**
 * tailwind.config.ts - Configuration Tailwind CSS
 * Configuration TypeScript pour meilleure expérience développeur
 */
import themeSystem from './tailwind-theme-system';
const config = {
    content: [
        './src/**/*.{html,js,jsx,ts,tsx}',
        './ui/**/*.{html,js,jsx,ts,tsx}',
        './pages/**/*.{html,js,jsx,ts,tsx}',
        './components/**/*.{html,js,jsx,ts,tsx}',
    ],
    darkMode: 'class', // Support du mode sombre via classe
    theme: {
        extend: {
            // Couleurs custom (si besoin au-delà du système de thèmes)
            colors: {
            // Les couleurs de thème sont déjà gérées par le plugin
            // Ajoutez ici des couleurs supplémentaires spécifiques si nécessaire
            },
            // Espacements personnalisés
            spacing: {
            // Ajoutez des espacements custom si besoin
            },
            // Familles de polices
            fontFamily: {
                sans: ['Inter', 'system-ui', 'sans-serif'],
                mono: ['Fira Code', 'Consolas', 'monospace'],
            },
            // Animations personnalisées
            keyframes: {
                'fade-in': {
                    '0%': { opacity: '0', transform: 'translateY(10px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
                'slide-in': {
                    '0%': { transform: 'translateX(-100%)' },
                    '100%': { transform: 'translateX(0)' },
                },
                'slide-in-right': {
                    '0%': { transform: 'translateX(100%)' },
                    '100%': { transform: 'translateX(0)' },
                },
                'shimmer': {
                    '0%': { transform: 'translateX(-100%)' },
                    '100%': { transform: 'translateX(100%)' },
                },
                'spin': {
                    '0%': { transform: 'rotate(0deg)' },
                    '100%': { transform: 'rotate(360deg)' },
                },
                'pulse-glow': {
                    '0%, 100%': { opacity: '1' },
                    '50%': { opacity: '0.5' },
                },
            },
            animation: {
                'fade-in': 'fade-in 0.3s ease-out',
                'slide-in': 'slide-in 0.3s ease-out',
                'slide-in-right': 'slide-in-right 0.3s ease-out',
                'shimmer': 'shimmer 2s infinite',
                'spin': 'spin 0.6s linear infinite',
                'pulse-glow': 'pulse-glow 2s ease-in-out infinite',
            },
            // Ombres personnalisées
            boxShadow: {
                'neon': '0 0 10px currentColor',
                'neon-lg': '0 0 20px currentColor',
                'neon-xl': '0 0 30px currentColor',
                'inner-lg': 'inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)',
            },
            // Transitions personnalisées
            transitionTimingFunction: {
                'bounce-in': 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
                'smooth': 'cubic-bezier(0.4, 0, 0.2, 1)',
            },
        },
    },
    plugins: [
        themeSystem,
        // Ajoutez d'autres plugins ici si nécessaire
        // require('daisyui'),
    ],
};
export default config;
