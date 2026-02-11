import React, { useState, useMemo, useEffect } from 'react';
import { UniversalButton } from './UniversalButton';
import { buttonDesignAI, AppType, ButtonIntent, AppContext } from './ButtonDesignAI';
import { themeManager } from '../../../src/theme';
import { Download, Trash2, Heart, Share2 } from 'lucide-react';

/**
 * Composant ButtonCustom - Interface de test de l'Agent IA Design
 * Permet de tester toutes les recommandations de l'IA selon différents contextes
 */
export default function ButtonCustom() {
  const [darkMode, setDarkMode] = useState(false);
  const [selectedAppType, setSelectedAppType] = useState<AppType>('saas');
  const [selectedIntent, setSelectedIntent] = useState<ButtonIntent>('primary-action');
  const [currentTheme, setCurrentTheme] = useState(themeManager.getCurrentTheme());

  // Context de l'application
  const appContext: AppContext = useMemo(() => ({
    type: selectedAppType,
    theme: selectedAppType === 'gaming' ? 'cyberpunk' : selectedAppType === 'creative' ? 'glassmorphism' : 'modern',
    industry: selectedAppType === 'finance' ? 'finance' : selectedAppType === 'health' ? 'health' : 'tech',
    audience: selectedAppType === 'corporate' ? 'b2b' : 'b2c'
  }), [selectedAppType]);

  // Recommandation de l'IA
  const recommendation = useMemo(() => 
    buttonDesignAI.recommend(selectedIntent, appContext),
    [selectedIntent, appContext]
  );

  // Alternatives
  const alternatives = useMemo(() => 
    buttonDesignAI.getAlternatives(selectedIntent, appContext, 3),
    [selectedIntent, appContext]
  );

  // Écouter les changements de thème
  useEffect(() => {
    const unsubscribe = themeManager.onThemeChange((theme) => {
      setCurrentTheme(theme);
    });
    return unsubscribe;
  }, []);

  // Changer le thème
  const handleThemeChange = (theme: string) => {
    themeManager.applyTheme(theme);
    setCurrentTheme(theme);
  };

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';

  return (
    <div className={`min-h-screen ${bg} p-8 transition-colors`}>
      <div className="max-w-7xl mx-auto space-y-8">
        
        {/* Header */}
        <div className={`${card} rounded-2xl p-10 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <div className="flex justify-between items-center">
            <div>
              <h1 className={`text-5xl font-bold ${txt} mb-3 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent`}>
                🤖 Agent IA Design - Boutons
              </h1>
              <p className={`text-lg ${txt2}`}>L'IA choisit le meilleur style selon votre contexte</p>
            </div>
            <button
              type="button"
              onClick={() => setDarkMode(!darkMode)}
              className="px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-bold hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg"
            >
              {darkMode ? '☀️' : '🌙'}
            </button>
          </div>
        </div>

        {/* Sélecteur de Thème */}
        <div className={`${card} rounded-2xl p-8 shadow-2xl border-2 border-purple-500`}>
          <div className="flex items-center gap-3 mb-6">
            <div className="p-3 bg-purple-600 rounded-full">
              <span className="text-2xl">🎨</span>
            </div>
            <div>
              <h2 className={`text-3xl font-bold ${txt}`}>Thème Actif</h2>
              <p className={`text-sm ${txt2}`}>Les boutons s'adaptent automatiquement</p>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-4">
            {(['light', 'dark', 'ocean'] as const).map(theme => (
              <button
                key={theme}
                type="button"
                onClick={() => handleThemeChange(theme)}
                className={`px-6 py-4 rounded-lg font-bold transition-all ${
                  currentTheme === theme
                    ? 'bg-purple-600 text-white shadow-lg scale-105'
                    : `${darkMode ? 'bg-gray-700 text-gray-300' : 'bg-gray-100 text-gray-700'} hover:bg-purple-100`
                }`}
              >
                <div className="text-lg mb-1">
                  {theme === 'light' ? '☀️' : theme === 'dark' ? '🌙' : '🌊'}
                </div>
                <div className="text-sm capitalize">{theme}</div>
                {currentTheme === theme && (
                  <div className="text-xs mt-1 opacity-80">✓ Actif</div>
                )}
              </button>
            ))}
          </div>

          <div className={`mt-6 p-4 ${darkMode ? 'bg-purple-900/20' : 'bg-purple-50'} rounded-lg border border-purple-500`}>
            <p className={`text-sm ${txt}`}>
              <span className="font-bold">Thème actuel : </span>
              <span className="text-purple-600 font-bold">{currentTheme}</span>
            </p>
            <p className={`text-xs ${txt2} mt-2`}>
              Changez le thème pour voir les boutons ci-dessous s'adapter automatiquement !
            </p>
          </div>
        </div>

        {/* Configuration */}
        <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <h2 className={`text-3xl font-bold ${txt} mb-6 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
            ⚙️ Configuration
          </h2>
          
          <div className="grid md:grid-cols-2 gap-8">
            {/* Type d'Application */}
            <div>
              <label className={`block text-sm font-bold ${txt} mb-3`}>Type d'Application</label>
              <div className="grid grid-cols-2 gap-3">
                {(['saas', 'e-commerce', 'corporate', 'creative', 'gaming', 'health', 'education', 'finance'] as AppType[]).map(type => (
                  <button
                    key={type}
                    type="button"
                    onClick={() => setSelectedAppType(type)}
                    className={`px-4 py-3 rounded-lg font-medium transition-all ${
                      selectedAppType === type
                        ? 'bg-blue-600 text-white shadow-lg'
                        : `${darkMode ? 'bg-gray-700 text-gray-300' : 'bg-gray-100 text-gray-700'} hover:bg-blue-50`
                    }`}
                  >
                    {type.charAt(0).toUpperCase() + type.slice(1)}
                  </button>
                ))}
              </div>
            </div>

            {/* Intention du bouton */}
            <div>
              <label className={`block text-sm font-bold ${txt} mb-3`}>Intention du Bouton</label>
              <div className="grid grid-cols-2 gap-3">
                {(['primary-action', 'secondary-action', 'destructive', 'navigation', 'toggle', 'submit', 'success', 'premium', 'social'] as ButtonIntent[]).map(intent => (
                  <button
                    key={intent}
                    type="button"
                    onClick={() => setSelectedIntent(intent)}
                    className={`px-4 py-3 rounded-lg font-medium transition-all ${
                      selectedIntent === intent
                        ? 'bg-purple-600 text-white shadow-lg'
                        : `${darkMode ? 'bg-gray-700 text-gray-300' : 'bg-gray-100 text-gray-700'} hover:bg-purple-50`
                    }`}
                  >
                    {intent.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Recommandation IA */}
        <div className={`${card} rounded-2xl p-8 shadow-2xl border-2 border-blue-500`}>
          <div className="flex items-center gap-3 mb-6">
            <div className="p-3 bg-blue-600 rounded-full">
              <span className="text-2xl">🤖</span>
            </div>
            <div>
              <h2 className={`text-3xl font-bold ${txt}`}>Recommandation IA</h2>
              <p className={`text-sm ${txt2}`}>Confiance : {(recommendation.confidence * 100).toFixed(0)}%</p>
            </div>
          </div>

          {/* Aperçu du bouton recommandé */}
          <div className={`p-12 ${darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-gray-50 to-gray-100'} rounded-xl mb-6 flex items-center justify-center`}>
            <UniversalButton
              size={recommendation.size}
              color={recommendation.color}
              variant={recommendation.variant}
              shape={recommendation.shape}
              animation={recommendation.animation}
              visualTheme={recommendation.visualTheme}
              icon={selectedIntent === 'destructive' ? <Trash2 className="w-5 h-5" /> : 
                    selectedIntent === 'social' ? <Share2 className="w-5 h-5" /> : 
                    selectedIntent === 'premium' ? <Heart className="w-5 h-5" /> :
                    selectedIntent === 'primary-action' ? <Download className="w-5 h-5" /> : undefined}
              iconPosition={['destructive', 'social', 'premium'].includes(selectedIntent) ? 'left' : 'none'}
              hasRipple={recommendation.animation === 'ripple'}
            >
              {selectedIntent === 'primary-action' ? 'Commencer' :
               selectedIntent === 'secondary-action' ? 'En savoir plus' :
               selectedIntent === 'destructive' ? 'Supprimer' :
               selectedIntent === 'navigation' ? 'Accueil' :
               selectedIntent === 'toggle' ? 'Activer' :
               selectedIntent === 'submit' ? 'Envoyer' :
               selectedIntent === 'success' ? 'Validé' :
               selectedIntent === 'premium' ? 'Passer Premium' :
               selectedIntent === 'social' ? 'Partager' :
               'Action'}
            </UniversalButton>
          </div>

          {/* Détails techniques */}
          <div className={`${darkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-lg p-6 mb-6`}>
            <h3 className={`text-lg font-bold ${txt} mb-4`}>📋 Spécifications</h3>
            <div className="grid md:grid-cols-2 gap-4">
              <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-4 rounded-lg`}>
                <p className={`text-sm font-semibold ${txt2} mb-2`}>Taille</p>
                <p className={`text-lg font-bold ${txt}`}>{recommendation.size.toUpperCase()}</p>
              </div>
              <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-4 rounded-lg`}>
                <p className={`text-sm font-semibold ${txt2} mb-2`}>Couleur</p>
                <p className={`text-lg font-bold ${txt}`}>{recommendation.color}</p>
              </div>
              <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-4 rounded-lg`}>
                <p className={`text-sm font-semibold ${txt2} mb-2`}>Variant</p>
                <p className={`text-lg font-bold ${txt}`}>{recommendation.variant}</p>
              </div>
              <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-4 rounded-lg`}>
                <p className={`text-sm font-semibold ${txt2} mb-2`}>Animation</p>
                <p className={`text-lg font-bold ${txt}`}>{recommendation.animation}</p>
              </div>
            </div>
          </div>

          {/* Raisonnement IA */}
          <div className={`${darkMode ? 'bg-blue-900/20' : 'bg-blue-50'} border-2 border-blue-500 rounded-lg p-6`}>
            <h3 className={`text-lg font-bold ${txt} mb-3 flex items-center gap-2`}>
              <span>💡</span>
              Pourquoi ce choix ?
            </h3>
            <p className={`text-sm ${txt2} leading-relaxed`}>
              {recommendation.reasoning}
            </p>
          </div>
        </div>

        {/* Alternatives */}
        <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <h2 className={`text-3xl font-bold ${txt} mb-6 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
            🎨 Alternatives Proposées
          </h2>
          
          <div className="grid md:grid-cols-3 gap-6">
            {alternatives.map((alt, idx) => (
              <div key={idx} className={`${darkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-xl p-6`}>
                <div className="flex justify-between items-center mb-4">
                  <h3 className={`text-lg font-bold ${txt}`}>
                    {idx === 0 ? '⭐ Recommandé' : `Option ${idx + 1}`}
                  </h3>
                  <span className={`text-xs font-bold px-2 py-1 rounded-full ${
                    alt.confidence > 0.8 ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
                  }`}>
                    {(alt.confidence * 100).toFixed(0)}%
                  </span>
                </div>

                <div className="flex justify-center py-8">
                  <UniversalButton
                    size={alt.size}
                    color={alt.color}
                    variant={alt.variant}
                    shape={alt.shape}
                    animation={alt.animation}
                    visualTheme={alt.visualTheme}
                  >
                    Exemple
                  </UniversalButton>
                </div>

                <div className="space-y-2 text-sm">
                  <p className={txt2}>
                    <span className="font-semibold">Variant:</span> {alt.variant}
                  </p>
                  <p className={txt2}>
                    <span className="font-semibold">Taille:</span> {alt.size}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Démonstration Adaptation au Thème */}
        <div className={`${card} rounded-2xl p-8 shadow-2xl border-2 border-green-500`}>
          <div className="flex items-center gap-3 mb-6">
            <div className="p-3 bg-green-600 rounded-full">
              <span className="text-2xl">✨</span>
            </div>
            <div>
              <h2 className={`text-3xl font-bold ${txt}`}>Démo : Adaptation Automatique</h2>
              <p className={`text-sm ${txt2}`}>Ces boutons utilisent les couleurs du thème</p>
            </div>
          </div>

          <div className={`p-8 ${darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-gray-50 to-gray-100'} rounded-xl mb-6`}>
            <div className="flex flex-wrap gap-4 justify-center">
              {/* Boutons qui s'adaptent au thème */}
              <UniversalButton size="lg" variant="solid" color="primary">
                Primary (thème)
              </UniversalButton>
              <UniversalButton size="lg" variant="solid" color="secondary">
                Secondary (thème)
              </UniversalButton>
              <UniversalButton size="lg" variant="solid" color="accent">
                Accent (thème)
              </UniversalButton>
            </div>
          </div>

          <div className={`${darkMode ? 'bg-green-900/20' : 'bg-green-50'} border-2 border-green-500 rounded-lg p-6`}>
            <h3 className={`text-lg font-bold ${txt} mb-3 flex items-center gap-2`}>
              <span>💡</span>
              Testez l'adaptation !
            </h3>
            <p className={`text-sm ${txt2} mb-4`}>
              1. Regardez les 3 boutons ci-dessus<br/>
              2. Changez le thème (Light / Dark / Ocean)<br/>
              3. Observez : Les boutons changent de couleur automatiquement ! ✨
            </p>
            <div className="grid grid-cols-3 gap-3 text-xs">
              <div className={`p-3 ${darkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg`}>
                <p className="font-bold mb-1">Light</p>
                <p className={txt2}>Primary = Bleu</p>
              </div>
              <div className={`p-3 ${darkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg`}>
                <p className="font-bold mb-1">Dark</p>
                <p className={txt2}>Primary = Bleu clair</p>
              </div>
              <div className={`p-3 ${darkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg`}>
                <p className="font-bold mb-1">Ocean</p>
                <p className={txt2}>Primary = Cyan</p>
              </div>
            </div>
          </div>
        </div>

        {/* Exemples par contexte */}
        <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <h2 className={`text-3xl font-bold ${txt} mb-6 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
            🎯 Exemples par Contexte
          </h2>
          
          <div className="grid gap-6">
            {/* SaaS */}
            <div className={`${darkMode ? 'bg-gradient-to-r from-blue-900/20 to-purple-900/20' : 'bg-gradient-to-r from-blue-50 to-purple-50'} p-6 rounded-xl border-2 border-blue-500`}>
              <h3 className={`text-xl font-bold ${txt} mb-4 flex items-center gap-2`}>
                💼 SaaS Application
                <span className="text-xs font-normal px-2 py-1 bg-blue-600 text-white rounded-full">Utilise Primary</span>
              </h3>
              <div className="flex flex-wrap gap-4">
                <UniversalButton size="lg" variant="gradient" color="primary" animation="scale">
                  Démarrer gratuitement
                </UniversalButton>
                <UniversalButton size="md" variant="outline" color="primary">
                  En savoir plus
                </UniversalButton>
                <UniversalButton size="md" variant="ghost" color="gray">
                  Documentation
                </UniversalButton>
              </div>
              <p className={`text-xs ${txt2} mt-3`}>
                ✨ Changez le thème ci-dessus pour voir ces boutons s'adapter !
              </p>
            </div>

            {/* E-commerce */}
            <div className={`${darkMode ? 'bg-gradient-to-r from-green-900/20 to-emerald-900/20' : 'bg-gradient-to-r from-green-50 to-emerald-50'} p-6 rounded-xl border-2 border-green-500`}>
              <h3 className={`text-xl font-bold ${txt} mb-4`}>🛍️ E-commerce</h3>
              <div className="flex flex-wrap gap-4">
                <UniversalButton size="lg" variant="solid" color="green" animation="scale" icon={<Download className="w-5 h-5" />} iconPosition="left">
                  Ajouter au panier
                </UniversalButton>
                <UniversalButton size="md" variant="outline" color="orange">
                  Liste de souhaits
                </UniversalButton>
                <UniversalButton size="sm" variant="ghost" color="gray">
                  Comparer
                </UniversalButton>
              </div>
            </div>

            {/* Gaming */}
            <div className={`${darkMode ? 'bg-gradient-to-r from-cyan-900/20 to-purple-900/20' : 'bg-gradient-to-r from-cyan-50 to-purple-50'} p-6 rounded-xl border-2 border-cyan-500`}>
              <h3 className={`text-xl font-bold ${txt} mb-4`}>🎮 Gaming</h3>
              <div className="flex flex-wrap gap-4">
                <UniversalButton size="lg" variant="solid" color="cyan" visualTheme="cyberpunk" animation="glitch">
                  PLAY NOW
                </UniversalButton>
                <UniversalButton size="md" variant="outline" color="purple" visualTheme="cyberpunk">
                  LEADERBOARD
                </UniversalButton>
              </div>
            </div>

            {/* Corporate */}
            <div className={`${darkMode ? 'bg-gradient-to-r from-gray-900/20 to-blue-900/20' : 'bg-gradient-to-r from-gray-50 to-blue-50'} p-6 rounded-xl border-2 border-gray-400`}>
              <h3 className={`text-xl font-bold ${txt} mb-4`}>🏢 Corporate</h3>
              <div className="flex flex-wrap gap-4">
                <UniversalButton size="md" variant="solid" color="blue" visualTheme="corporate">
                  Contactez-nous
                </UniversalButton>
                <UniversalButton size="md" variant="outline" color="gray" visualTheme="corporate">
                  Télécharger le rapport
                </UniversalButton>
              </div>
            </div>
          </div>
        </div>

        {/* Guide de l'IA */}
        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>
            🤖 L'Agent IA analyse {Object.keys(appContext).length} paramètres de contexte pour recommander le style optimal
          </p>
          <p className={`${txt2} text-sm mt-2`}>
            89 variantes disponibles • Recommandations en temps réel • Confiance calculée
          </p>
        </div>
      </div>
    </div>
  );
}


