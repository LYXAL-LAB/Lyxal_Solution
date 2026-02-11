import React, { useState, useEffect } from 'react';
import { DaisyUIExample } from './examples/DaisyUIExample';
import { SurrealMonitoringExample } from './examples/SurrealMonitoringExample';
import './styles/globals.css';
import './styles/ui-animations.css';

type PageType = 'dashboard' | 'monitoring' | 'components';

// Tous les thèmes DaisyUI disponibles
const THEMES = [
  { name: 'light', icon: '☀️', label: 'Light' },
  { name: 'dark', icon: '🌙', label: 'Dark' },
  { name: 'cupcake', icon: '🧁', label: 'Cupcake' },
  { name: 'bumblebee', icon: '🐝', label: 'Bumblebee' },
  { name: 'emerald', icon: '💎', label: 'Emerald' },
  { name: 'corporate', icon: '🏢', label: 'Corporate' },
  { name: 'synthwave', icon: '🌆', label: 'Synthwave' },
  { name: 'retro', icon: '📻', label: 'Retro' },
  { name: 'cyberpunk', icon: '🤖', label: 'Cyberpunk' },
  { name: 'valentine', icon: '💝', label: 'Valentine' },
  { name: 'halloween', icon: '🎃', label: 'Halloween' },
  { name: 'garden', icon: '🌸', label: 'Garden' },
  { name: 'forest', icon: '🌲', label: 'Forest' },
  { name: 'aqua', icon: '🌊', label: 'Aqua' },
  { name: 'lofi', icon: '🎵', label: 'Lo-Fi' },
  { name: 'pastel', icon: '🎨', label: 'Pastel' },
  { name: 'fantasy', icon: '🦄', label: 'Fantasy' },
  { name: 'wireframe', icon: '📐', label: 'Wireframe' },
  { name: 'black', icon: '⚫', label: 'Black' },
  { name: 'luxury', icon: '✨', label: 'Luxury' },
  { name: 'dracula', icon: '🧛', label: 'Dracula' },
  { name: 'cmyk', icon: '🖨️', label: 'CMYK' },
  { name: 'autumn', icon: '🍂', label: 'Autumn' },
  { name: 'business', icon: '💼', label: 'Business' },
  { name: 'acid', icon: '🧪', label: 'Acid' },
  { name: 'lemonade', icon: '🍋', label: 'Lemonade' },
  { name: 'night', icon: '🌃', label: 'Night' },
  { name: 'coffee', icon: '☕', label: 'Coffee' },
  { name: 'winter', icon: '❄️', label: 'Winter' }
];

function App() {
  const [mounted, setMounted] = useState(false);
  const [currentPage, setCurrentPage] = useState<PageType>('monitoring');
  const [currentTheme, setCurrentTheme] = useState('light');

  useEffect(() => {
    setMounted(true);
    // Définir le thème par défaut
    document.documentElement.setAttribute('data-theme', 'light');
  }, []);

  const changeTheme = (themeName: string) => {
    setCurrentTheme(themeName);
    document.documentElement.setAttribute('data-theme', themeName);
  };

  if (!mounted) {
    return (
      <div className="min-h-screen min-w-[320px] bg-base-100 flex items-center justify-center">
        <div className="loading loading-spinner loading-lg"></div>
      </div>
    );
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'monitoring':
        return <SurrealMonitoringExample />;
      case 'components':
        return <DaisyUIExample />;
      default:
        return <SurrealMonitoringExample />;
    }
  };

  return (
    <div className="min-h-screen min-w-[320px] bg-base-100">
      {/* Navigation améliorée */}
      <div className="navbar bg-primary text-primary-content shadow-xl sticky top-0 z-50">
        <div className="navbar-start">
          <div className="dropdown">
            <div tabIndex={0} role="button" className="btn btn-ghost lg:hidden">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h8m-8 6h16" />
              </svg>
            </div>
            <ul tabIndex={0} className="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
              <li>
                <a 
                  onClick={() => setCurrentPage('monitoring')} 
                  className={`text-base-content ${currentPage === 'monitoring' ? 'active' : ''}`}
                >
                  🎯 Monitoring SurrealDB
                </a>
              </li>
              <li>
                <a 
                  onClick={() => setCurrentPage('components')} 
                  className={`text-base-content ${currentPage === 'components' ? 'active' : ''}`}
                >
                  🎨 Composants DaisyUI
                </a>
              </li>
            </ul>
          </div>
          <a className="btn btn-ghost text-xl font-bold">
            🚀 LyxalKitUI
            <div className="badge badge-secondary badge-sm">v1.0</div>
          </a>
        </div>
        
        <div className="navbar-center hidden lg:flex">
          <ul className="menu menu-horizontal px-1">
            <li>
              <a 
                onClick={() => setCurrentPage('monitoring')}
                className={`font-medium ${currentPage === 'monitoring' ? 'active bg-primary-focus' : ''}`}
              >
                🎯 Monitoring SurrealDB
              </a>
            </li>
            <li>
              <a 
                onClick={() => setCurrentPage('components')}
                className={`font-medium ${currentPage === 'components' ? 'active bg-primary-focus' : ''}`}
              >
                🎨 Composants DaisyUI
              </a>
            </li>
          </ul>
        </div>
        
        <div className="navbar-end gap-2">
          {/* Indicateur de thème actuel */}
          <div className="badge badge-outline">
            {THEMES.find(t => t.name === currentTheme)?.icon} {THEMES.find(t => t.name === currentTheme)?.label}
          </div>
          
          {/* Sélecteur de thèmes complet */}
          <div className="dropdown dropdown-end">
            <div tabIndex={0} role="button" className="btn btn-ghost btn-circle">
              🎨
            </div>
            <ul tabIndex={0} className="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-64">
              <li className="menu-title">
                <span className="text-base-content">Choisir un thème</span>
              </li>
              {THEMES.map((theme) => (
                <li key={theme.name}>
                  <a 
                    onClick={() => changeTheme(theme.name)}
                    className={`text-base-content ${currentTheme === theme.name ? 'active' : ''}`}
                  >
                    <span className="text-lg">{theme.icon}</span>
                    {theme.label}
                    {currentTheme === theme.name && <span className="badge badge-primary badge-sm">✓</span>}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      {/* Contenu principal avec meilleure mise en page */}
      <main>
        {renderPage()}
      </main>
      
      {/* Footer */}
      <footer className="footer footer-center p-4 bg-base-300 text-base-content">
        <div>
          <p>© 2024 LyxalSuite - Interface de monitoring SurrealDB</p>
        </div>
      </footer>
    </div>
  );
}

export default App;