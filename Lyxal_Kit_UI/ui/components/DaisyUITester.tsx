/**
 * Composant pour tester les thèmes DaisyUI
 * À ajouter dans votre ContentWrapper pour visualiser les thèmes
 */

import React, { useState } from 'react';
import { DaisyUIIntegration, DaisyUIThemeName } from '../../src/theme';

const DaisyUITester: React.FC = () => {
  const [currentTheme, setCurrentTheme] = useState<DaisyUIThemeName>('light');
  const [searchTerm, setSearchTerm] = useState('');

  const allThemes = DaisyUIIntegration.getAvailableThemes();
  const filteredThemes = allThemes.filter(theme =>
    theme.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const applyTheme = (themeName: DaisyUIThemeName) => {
    DaisyUIIntegration.applyTheme(themeName);
    setCurrentTheme(themeName);
  };

  const getThemeInfo = (themeName: DaisyUIThemeName) => {
    return DaisyUIIntegration.getThemeInfo(themeName);
  };

  return (
    <div className="p-6 space-y-6">
      <div className="text-center">
        <h2 className="text-2xl font-bold mb-2">🎨 Testeur de Thèmes DaisyUI</h2>
        <p className="text-gray-600 dark:text-gray-400">
          Testez les {allThemes.length} thèmes importés de DaisyUI
        </p>
        <p className="text-sm text-primary font-semibold mt-1">
          Thème actuel: {currentTheme}
        </p>
      </div>

      {/* Barre de recherche */}
      <div className="flex justify-center">
        <input
          type="text"
          placeholder="Rechercher un thème..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="input input-bordered w-full max-w-xs"
        />
      </div>

      {/* Boutons de test rapide */}
      <div className="flex flex-wrap justify-center gap-2">
        {['light', 'dark', 'cupcake', 'synthwave', 'retro', 'cyberpunk'].map(theme => (
          <button
            key={theme}
            onClick={() => applyTheme(theme as DaisyUIThemeName)}
            className={`btn btn-sm ${currentTheme === theme ? 'btn-primary' : 'btn-outline'}`}
          >
            {theme}
          </button>
        ))}
      </div>

      {/* Grille de tous les thèmes */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
        {filteredThemes.map(themeName => {
          const info = getThemeInfo(themeName);
          return (
            <div
              key={themeName}
              className={`card border cursor-pointer transition-all hover:shadow-lg ${
                currentTheme === themeName ? 'border-primary shadow-primary/20' : 'border-base-300'
              }`}
              onClick={() => applyTheme(themeName)}
            >
              <div className="card-body p-3 text-center">
                <h3 className="card-title text-sm font-semibold">{themeName}</h3>
                <div className="flex justify-center space-x-1 mt-2">
                  {/* Aperçu des couleurs */}
                  <div
                    className="w-4 h-4 rounded-full border border-gray-300"
                    style={{ backgroundColor: info?.primary.includes('oklch') ? '#3b82f6' : info?.primary }}
                    title={`Primary: ${info?.primary}`}
                  />
                  <div
                    className="w-4 h-4 rounded-full border border-gray-300"
                    style={{ backgroundColor: info?.secondary.includes('oklch') ? '#10b981' : info?.secondary }}
                    title={`Secondary: ${info?.secondary}`}
                  />
                  <div
                    className="w-4 h-4 rounded-full border border-gray-300"
                    style={{ backgroundColor: info?.accent.includes('oklch') ? '#f59e0b' : info?.accent }}
                    title={`Accent: ${info?.accent}`}
                  />
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  {info?.variables} vars
                </p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Boutons d'exemple avec le thème actuel */}
      <div className="mt-8 p-6 bg-base-200 rounded-lg">
        <h3 className="text-lg font-semibold mb-4">📋 Aperçu des composants</h3>
        <div className="flex flex-wrap gap-3 justify-center">
          <button className="btn btn-primary">Primary</button>
          <button className="btn btn-secondary">Secondary</button>
          <button className="btn btn-accent">Accent</button>
          <button className="btn btn-neutral">Neutral</button>
          <button className="btn btn-info">Info</button>
          <button className="btn btn-success">Success</button>
          <button className="btn btn-warning">Warning</button>
          <button className="btn btn-error">Error</button>
        </div>

        <div className="mt-4 flex flex-wrap gap-3 justify-center">
          <button className="btn btn-outline">Outline</button>
          <button className="btn btn-ghost">Ghost</button>
          <button className="btn btn-gradient">Gradient</button>
          <button className="btn btn-glass">Glass</button>
          <button className="btn btn-neon">Neon</button>
          <button className="btn btn-3d">3D</button>
        </div>
      </div>

      {/* Informations du thème actuel */}
      {(() => {
        const info = getThemeInfo(currentTheme);
        return info ? (
          <div className="mt-6 p-4 bg-base-100 rounded-lg border">
            <h4 className="font-semibold mb-2">📊 Informations du thème "{currentTheme}"</h4>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
              <div>
                <span className="font-medium">Variables:</span> {info.variables}
              </div>
              <div>
                <span className="font-medium">Primary:</span>
                <div className="w-4 h-4 rounded-full bg-primary inline-block ml-2 border"></div>
              </div>
              <div>
                <span className="font-medium">Secondary:</span>
                <div className="w-4 h-4 rounded-full bg-secondary inline-block ml-2 border"></div>
              </div>
              <div>
                <span className="font-medium">Accent:</span>
                <div className="w-4 h-4 rounded-full bg-accent inline-block ml-2 border"></div>
              </div>
            </div>
          </div>
        ) : null;
      })()}
    </div>
  );
};

export default DaisyUITester;
