import { useState, useEffect, useCallback } from 'react';

export interface ThemeConfig {
  name: string;
  displayName: string;
  isDark: boolean;
  colors: {
    primary: string;
    secondary: string;
    accent: string;
    base: string;
  };
}

const THEME_STORAGE_KEY = 'lyxal-theme';

// Configuration des thèmes avec métadonnées
const THEME_CONFIGS: Record<string, ThemeConfig> = {
  light: {
    name: 'light',
    displayName: 'Clair',
    isDark: false,
    colors: { primary: '#570df8', secondary: '#f000b8', accent: '#37cdbe', base: '#ffffff' }
  },
  dark: {
    name: 'dark',
    displayName: 'Sombre',
    isDark: true,
    colors: { primary: '#661ae6', secondary: '#d926aa', accent: '#1fb2a5', base: '#2a303c' }
  },
  synthwave: {
    name: 'synthwave',
    displayName: 'Synthwave',
    isDark: true,
    colors: { primary: '#e779c1', secondary: '#58c7f3', accent: '#f3cc30', base: '#2d1b69' }
  },
  cyberpunk: {
    name: 'cyberpunk',
    displayName: 'Cyberpunk',
    isDark: true,
    colors: { primary: '#ff7598', secondary: '#75d1f0', accent: '#c7f59b', base: '#2a2a2a' }
  },
  corporate: {
    name: 'corporate',
    displayName: 'Corporate',
    isDark: false,
    colors: { primary: '#4b6bfb', secondary: '#7b92ff', accent: '#67cba0', base: '#ffffff' }
  },
  dracula: {
    name: 'dracula',
    displayName: 'Dracula',
    isDark: true,
    colors: { primary: '#ff79c6', secondary: '#bd93f9', accent: '#50fa7b', base: '#282a36' }
  }
};

export const useTheme = () => {
  const [currentTheme, setCurrentTheme] = useState<string>('light');
  const [isLoading, setIsLoading] = useState(true);

  // Appliquer un thème à l'HTML
  const applyTheme = useCallback((themeName: string) => {
    const html = document.documentElement;
    
    // Retirer tous les anciens thèmes
    html.removeAttribute('data-theme');
    
    // Appliquer le nouveau thème
    html.setAttribute('data-theme', themeName);
    
    // Sauvegarder dans localStorage
    localStorage.setItem(THEME_STORAGE_KEY, themeName);
    
    // Mettre à jour l'état
    setCurrentTheme(themeName);
    
    // Émettre un événement personnalisé pour les autres composants
    window.dispatchEvent(new CustomEvent('theme-changed', { 
      detail: { theme: themeName, config: THEME_CONFIGS[themeName] } 
    }));
  }, []);

  // Charger le thème au démarrage
  useEffect(() => {
    const loadTheme = () => {
      try {
        // Récupérer depuis localStorage ou utiliser le thème par défaut
        const savedTheme = localStorage.getItem(THEME_STORAGE_KEY);
        const themeToApply = savedTheme && THEME_CONFIGS[savedTheme] ? savedTheme : 'light';
        
        applyTheme(themeToApply);
      } catch (error) {
        console.warn('Erreur lors du chargement du thème:', error);
        applyTheme('light');
      } finally {
        setIsLoading(false);
      }
    };

    loadTheme();
  }, [applyTheme]);

  // Détecter les changements de préférences système
  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = (e: MediaQueryListEvent) => {
      // Seulement si aucun thème n'est sauvegardé
      if (!localStorage.getItem(THEME_STORAGE_KEY)) {
        applyTheme(e.matches ? 'dark' : 'light');
      }
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, [applyTheme]);

  // Changer de thème
  const changeTheme = useCallback((themeName: string) => {
    if (THEME_CONFIGS[themeName]) {
      applyTheme(themeName);
    } else {
      console.warn(`Thème "${themeName}" non trouvé`);
    }
  }, [applyTheme]);

  // Basculer entre clair/sombre
  const toggleDarkMode = useCallback(() => {
    const config = THEME_CONFIGS[currentTheme];
    if (config) {
      const newTheme = config.isDark ? 'light' : 'dark';
      applyTheme(newTheme);
    }
  }, [currentTheme, applyTheme]);

  // Obtenir la configuration du thème actuel
  const getCurrentConfig = useCallback((): ThemeConfig | null => {
    return THEME_CONFIGS[currentTheme] || null;
  }, [currentTheme]);

  // Obtenir tous les thèmes disponibles
  const getAvailableThemes = useCallback((): ThemeConfig[] => {
    return Object.values(THEME_CONFIGS);
  }, []);

  return {
    // État
    currentTheme,
    isLoading,
    isDarkMode: THEME_CONFIGS[currentTheme]?.isDark || false,
    
    // Actions
    changeTheme,
    toggleDarkMode,
    
    // Utilitaires
    getCurrentConfig,
    getAvailableThemes,
    
    // Configuration
    themeConfig: THEME_CONFIGS[currentTheme] || null
  };
};

export default useTheme; 