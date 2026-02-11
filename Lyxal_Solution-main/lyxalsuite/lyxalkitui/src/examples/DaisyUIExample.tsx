import React, { useState } from 'react';

// Utilisation DIRECTE de DaisyUI 5 avec Tailwind CSS v4 !
export function DaisyUIExample() {
  const [currentTheme, setCurrentTheme] = useState('light');

  const themes = [
    'light', 'dark', 'lyxal', 'cupcake', 'bumblebee', 'emerald', 'corporate',
    'synthwave', 'retro', 'cyberpunk', 'valentine', 'halloween',
    'garden', 'forest', 'aqua', 'lofi', 'pastel', 'fantasy',
    'wireframe', 'black', 'luxury', 'dracula', 'cmyk', 'autumn',
    'business', 'acid', 'lemonade', 'night', 'coffee', 'winter',
    'dim', 'nord', 'sunset'
  ];

  const changeTheme = (theme: string) => {
    setCurrentTheme(theme);
    document.documentElement.setAttribute('data-theme', theme);
  };

  return (
    <div className="min-h-screen bg-base-100 p-8" data-theme={currentTheme}>
      <div className="max-w-6xl mx-auto space-y-8">
        
        {/* En-tête */}
        <div className="text-center">
          <h1 className="text-4xl font-bold text-base-content mb-4">
            🚀 LyxalKitUI - DaisyUI 5 + Tailwind v4
          </h1>
          <p className="text-base-content/70">
            Utilisation DIRECTE des composants et thèmes DaisyUI 5 avec la nouvelle architecture CSS
          </p>
          <div className="badge badge-accent badge-lg mt-2">
            DaisyUI 5.0 + Tailwind CSS v4.1
          </div>
        </div>

        {/* Sélecteur de thème */}
        <div className="card bg-base-200 shadow-xl">
          <div className="card-body">
            <h2 className="card-title">🎨 Sélectionner un thème DaisyUI</h2>
            <p className="text-base-content/70 mb-4">
              Thème actuel : <span className="badge badge-primary">{currentTheme}</span>
              {currentTheme === 'lyxal' && <span className="badge badge-accent ml-2">Custom LyxalKitUI</span>}
            </p>
            
            <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-2">
              {themes.map(theme => (
                <button
                  key={theme}
                  className={`btn btn-sm ${currentTheme === theme ? 'btn-primary' : 'btn-outline'} ${theme === 'lyxal' ? 'btn-accent' : ''}`}
                  onClick={() => changeTheme(theme)}
                >
                  {theme === 'lyxal' ? '🎯 ' + theme : theme}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Notice sur l'architecture */}
        <div className="alert alert-info">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="stroke-current shrink-0 w-6 h-6">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <div>
            <h3 className="font-bold">Nouvelle architecture !</h3>
            <div className="text-xs">
              ✅ DaisyUI 5.0 configuré dans CSS (plus de tailwind.config.js)<br/>
              ✅ Tailwind CSS v4.1 avec @plugin "daisyui"<br/>
              ✅ Thème personnalisé "lyxal" avec couleurs OKLCH<br/>
              ✅ 30+ thèmes DaisyUI natifs disponibles
            </div>
          </div>
        </div>

        {/* Démonstration des composants DaisyUI */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          
          {/* Boutons */}
          <div className="card bg-base-200 shadow-xl">
            <div className="card-body">
              <h2 className="card-title">🔘 Boutons DaisyUI</h2>
              <div className="space-y-2">
                <button className="btn btn-primary w-full">Primary</button>
                <button className="btn btn-secondary w-full">Secondary</button>
                <button className="btn btn-accent w-full">Accent</button>
                <button className="btn btn-outline w-full">Outline</button>
                <button className="btn btn-ghost w-full">Ghost</button>
                <button className="btn btn-success w-full">Success</button>
                <button className="btn btn-warning w-full">Warning</button>
                <button className="btn btn-error w-full">Error</button>
              </div>
            </div>
          </div>

          {/* Badges */}
          <div className="card bg-base-200 shadow-xl">
            <div className="card-body">
              <h2 className="card-title">🏷️ Badges</h2>
              <div className="flex flex-wrap gap-2">
                <div className="badge badge-primary">Primary</div>
                <div className="badge badge-secondary">Secondary</div>
                <div className="badge badge-accent">Accent</div>
                <div className="badge badge-ghost">Ghost</div>
                <div className="badge badge-success">Success</div>
                <div className="badge badge-warning">Warning</div>
                <div className="badge badge-error">Error</div>
                <div className="badge badge-info">Info</div>
              </div>
            </div>
          </div>

          {/* Inputs */}
          <div className="card bg-base-200 shadow-xl">
            <div className="card-body">
              <h2 className="card-title">📝 Inputs</h2>
              <div className="space-y-4">
                <input type="text" placeholder="Input normal" className="input input-bordered w-full" />
                <input type="text" placeholder="Input primary" className="input input-bordered input-primary w-full" />
                <input type="text" placeholder="Input success" className="input input-bordered input-success w-full" />
                <input type="text" placeholder="Input error" className="input input-bordered input-error w-full" />
              </div>
            </div>
          </div>

          {/* Loading States */}
          <div className="card bg-base-200 shadow-xl">
            <div className="card-body">
              <h2 className="card-title">⚡ Loading</h2>
              <div className="space-y-4">
                <button className="btn btn-primary loading w-full">Loading</button>
                <div className="flex gap-2">
                  <span className="loading loading-spinner loading-xs"></span>
                  <span className="loading loading-spinner loading-sm"></span>
                  <span className="loading loading-spinner loading-md"></span>
                  <span className="loading loading-spinner loading-lg"></span>
                </div>
                <div className="flex gap-2">
                  <span className="loading loading-dots loading-xs"></span>
                  <span className="loading loading-dots loading-sm"></span>
                  <span className="loading loading-dots loading-md"></span>
                  <span className="loading loading-dots loading-lg"></span>
                </div>
              </div>
            </div>
          </div>

          {/* Alerts */}
          <div className="card bg-base-200 shadow-xl">
            <div className="card-body">
              <h2 className="card-title">⚠️ Alerts</h2>
              <div className="space-y-2">
                <div className="alert alert-info">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="stroke-current shrink-0 w-6 h-6">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  <span>Information alert</span>
                </div>
                
                <div className="alert alert-success">
                  <svg xmlns="http://www.w3.org/2000/svg" className="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span>Success alert</span>
                </div>
                
                <div className="alert alert-warning">
                  <svg xmlns="http://www.w3.org/2000/svg" className="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.728-.833-2.498 0L3.732 16c-.77.833.192 2.5 1.732 2.5z" />
                  </svg>
                  <span>Warning alert</span>
                </div>
                
                <div className="alert alert-error">
                  <svg xmlns="http://www.w3.org/2000/svg" className="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span>Error alert</span>
                </div>
              </div>
            </div>
          </div>

          {/* Tabs */}
          <div className="card bg-base-200 shadow-xl">
            <div className="card-body">
              <h2 className="card-title">📑 Tabs</h2>
              <div className="tabs tabs-boxed">
                <a className="tab tab-active">Tab 1</a>
                <a className="tab">Tab 2</a>
                <a className="tab">Tab 3</a>
              </div>
              <div className="tabs tabs-lifted mt-4">
                <a className="tab tab-active">Lifted</a>
                <a className="tab">Tab</a>
                <a className="tab">Example</a>
              </div>
            </div>
          </div>

        </div>

        {/* Navbar Example */}
        <div className="navbar bg-base-200 shadow-xl rounded-box">
          <div className="navbar-start">
            <div className="dropdown">
              <div tabIndex={0} role="button" className="btn btn-ghost lg:hidden">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h8m-8 6h16" />
                </svg>
              </div>
            </div>
            <a className="btn btn-ghost text-xl">🚀 LyxalKitUI</a>
          </div>
          <div className="navbar-center hidden lg:flex">
            <ul className="menu menu-horizontal px-1">
              <li><a>Item 1</a></li>
              <li><a>Item 2</a></li>
              <li><a>Item 3</a></li>
            </ul>
          </div>
          <div className="navbar-end">
            <a className="btn btn-primary">Get started</a>
          </div>
        </div>

        {/* Modal Example */}
        <div className="card bg-base-200 shadow-xl">
          <div className="card-body">
            <h2 className="card-title">🪟 Modal DaisyUI 5</h2>
            <p>Modal utilisant la méthode DaisyUI 5 native avec checkbox toggle</p>
            <label htmlFor="my-modal" className="btn btn-primary">Ouvrir Modal</label>
            
            <input type="checkbox" id="my-modal" className="modal-toggle" />
            <div className="modal">
              <div className="modal-box">
                <h3 className="font-bold text-lg">Modal DaisyUI 5 !</h3>
                <p className="py-4">Ceci utilise directement les classes DaisyUI 5 avec Tailwind CSS v4.1</p>
                <div className="modal-action">
                  <label htmlFor="my-modal" className="btn">Fermer</label>
                  <label htmlFor="my-modal" className="btn btn-primary">Action</label>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Stats avec données dynamiques */}
        <div className="stats shadow w-full">
          <div className="stat">
            <div className="stat-figure text-primary">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="inline-block w-8 h-8 stroke-current">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
              </svg>
            </div>
            <div className="stat-title">Thèmes DaisyUI</div>
            <div className="stat-value text-primary">{themes.length}</div>
            <div className="stat-desc">+ 1 thème LyxalKitUI custom</div>
          </div>
          
          <div className="stat">
            <div className="stat-figure text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="inline-block w-8 h-8 stroke-current">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
            </div>
            <div className="stat-title">Composants</div>
            <div className="stat-value text-secondary">60+</div>
            <div className="stat-desc">Composants DaisyUI natifs</div>
          </div>
          
          <div className="stat">
            <div className="stat-figure text-accent">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="inline-block w-8 h-8 stroke-current">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"></path>
              </svg>
            </div>
            <div className="stat-title">Versions</div>
            <div className="stat-value">v5.0</div>
            <div className="stat-desc text-accent">DaisyUI + Tailwind v4</div>
          </div>
        </div>

      </div>
    </div>
  );
} 