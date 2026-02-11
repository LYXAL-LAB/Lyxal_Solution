import React, { createContext, useContext, ReactNode } from 'react';
import { useTheme, ThemeConfig } from '../hooks/useTheme';

interface ThemeContextType {
  currentTheme: string;
  isLoading: boolean;
  isDarkMode: boolean;
  changeTheme: (themeName: string) => void;
  toggleDarkMode: () => void;
  getCurrentConfig: () => ThemeConfig | null;
  getAvailableThemes: () => ThemeConfig[];
  themeConfig: ThemeConfig | null;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

interface ThemeProviderProps {
  children: ReactNode;
  defaultTheme?: string;
}

export const ThemeProvider: React.FC<ThemeProviderProps> = ({ 
  children, 
  defaultTheme = 'light' 
}) => {
  const themeState = useTheme();

  return (
    <ThemeContext.Provider value={themeState}>
      {children}
    </ThemeContext.Provider>
  );
};

// Hook pour utiliser le contexte de thème
export const useThemeContext = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  
  if (!context) {
    throw new Error('useThemeContext doit être utilisé dans un ThemeProvider');
  }
  
  return context;
};

// HOC pour les composants qui ont besoin du thème
export const withTheme = <P extends object>(
  Component: React.ComponentType<P & { theme: ThemeContextType }>
): React.FC<P> => {
  return (props: P) => {
    const theme = useThemeContext();
    return <Component {...props} theme={theme} />;
  };
};

export default ThemeContext; 