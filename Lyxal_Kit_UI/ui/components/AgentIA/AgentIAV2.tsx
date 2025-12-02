import React, { useState } from 'react';
import { 
  MessageSquare, Send, Mic, Paperclip, X, Minimize2, Maximize2,
  Bot, Sparkles, Zap, Heart, Star, Settings, MoreVertical,
  Volume2, VolumeX, Copy, ThumbsUp, ThumbsDown, RefreshCw,
  Image, FileText, Code, Lightbulb, TrendingUp, ShoppingBag,
  Palette, Pencil, Camera, Music, Video, Globe, Wifi, Phone,
  Headphones, Home, DollarSign, CreditCard, Gift, Package
} from 'lucide-react';

export default function AIAssistantPart2() {
  const [darkMode, setDarkMode] = useState(false);
  const [showWidget, setShowWidget] = useState(true);

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-purple-50 via-pink-50 to-orange-50';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';

  const AssistantSection = ({title, children}) => (
    <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
      <h2 className={`text-3xl font-bold ${txt} mb-8 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>{title}</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {children}
      </div>
    </div>
  );

  return (
    <div className={`min-h-screen ${bg} p-8 transition-colors`}>
      <div className="max-w-7xl mx-auto space-y-8">
        
        <div className={`${card} rounded-2xl p-10 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <div className="flex justify-between items-center">
            <div>
              <h1 className={`text-5xl font-bold ${txt} mb-3 bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent`}>
                Assistants IA - Partie 2/2
              </h1>
              <p className={`text-lg ${txt2}`}>E-commerce, Support, Créatifs & Widgets</p>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-xl font-bold hover:from-purple-700 hover:to-pink-700 transition-all shadow-lg"
            >
              {darkMode ? '☀️' : '🌙'}
            </button>
          </div>
        </div>

        <AssistantSection title="🛍️ E-commerce & Shopping">
          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-orange-500 to-red-500 p-4 text-white">
              <div className="flex items-center gap-3">
                <ShoppingBag className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Shopping Assistant</h3>
                  <p className="text-xs opacity-90">Aide à l'achat</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-orange-900/20' : 'bg-orange-50'} rounded-lg mb-4`}>
                <p className="text-sm font-semibold mb-3">🛒 Suggestions :</p>
                <div className="space-y-3">
                  <div className={`p-3 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg flex items-center gap-3 hover:shadow-md transition-all cursor-pointer`}>
                    <div className="w-12 h-12 bg-orange-200 rounded-lg flex items-center justify-center">
                      <Package className="w-6 h-6 text-orange-600" />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Produit similaire</p>
                      <p className="text-xs text-orange-600">-20% aujourd'hui</p>
                    </div>
                  </div>
                  <div className={`p-3 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg flex items-center gap-3 hover:shadow-md transition-all cursor-pointer`}>
                    <div className="w-12 h-12 bg-red-200 rounded-lg flex items-center justify-center">
                      <Gift className="w-6 h-6 text-red-600" />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Offre spéciale</p>
                      <p className="text-xs text-red-600">Livraison gratuite</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <button className="w-full px-4 py-3 bg-gradient-to-r from-orange-600 to-red-600 text-white rounded-lg font-semibold hover:from-orange-700 hover:to-red-700 transition-all">
                Voir les offres
              </button>
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-purple-500 to-pink-500 p-4 text-white">
              <div className="flex items-center gap-3">
                <CreditCard className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Payment Helper</h3>
                  <p className="text-xs opacity-90">Aide paiement</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-purple-900/20' : 'bg-purple-50'} rounded-lg mb-4`}>
                <p className="text-sm font-semibold mb-3">💳 Méthodes :</p>
                <div className="space-y-2">
                  <button className="w-full text-left px-4 py-3 bg-white dark:bg-gray-700 rounded-lg flex items-center gap-3 hover:bg-purple-100 dark:hover:bg-gray-600 transition-all">
                    <CreditCard className="w-5 h-5 text-purple-600" />
                    <span className="text-sm font-medium">Carte bancaire</span>
                  </button>
                  <button className="w-full text-left px-4 py-3 bg-white dark:bg-gray-700 rounded-lg flex items-center gap-3 hover:bg-purple-100 dark:hover:bg-gray-600 transition-all">
                    <DollarSign className="w-5 h-5 text-green-600" />
                    <span className="text-sm font-medium">PayPal</span>
                  </button>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <input
                type="text"
                placeholder="Besoin d'aide ?"
                className={`w-full px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none`}
              />
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-pink-500 to-rose-500 p-4 text-white">
              <div className="flex items-center gap-3">
                <Heart className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Personal Shopper</h3>
                  <p className="text-xs opacity-90">Conseils perso</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-pink-900/20' : 'bg-pink-50'} rounded-lg mb-4`}>
                <p className="text-sm mb-3">👗 Recommandé :</p>
                <div className="grid grid-cols-2 gap-2">
                  <div className={`p-3 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg text-center`}>
                    <div className="w-full h-20 bg-pink-200 rounded-lg mb-2"></div>
                    <p className="text-xs font-medium">Tendance</p>
                  </div>
                  <div className={`p-3 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg text-center`}>
                    <div className="w-full h-20 bg-rose-200 rounded-lg mb-2"></div>
                    <p className="text-xs font-medium">Populaire</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <button className="w-full px-4 py-3 bg-gradient-to-r from-pink-600 to-rose-600 text-white rounded-lg font-semibold">
                Personnaliser
              </button>
            </div>
          </div>
        </AssistantSection>

        <AssistantSection title="🎧 Support Client">
          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-blue-500 to-cyan-500 p-4 text-white">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Phone className="w-6 h-6" />
                  <div>
                    <h3 className="font-bold">Support 24/7</h3>
                    <p className="text-xs opacity-90">Disponible</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  <span className="text-xs">En ligne</span>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-blue-900/20' : 'bg-blue-50'} rounded-lg mb-4`}>
                <p className="text-sm mb-3 font-semibold">Comment aider ?</p>
                <div className="space-y-2">
                  <button className="w-full text-left px-4 py-3 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-lg text-sm hover:bg-blue-200 dark:hover:bg-blue-900/60 transition-all">
                    💬 Chat direct
                  </button>
                  <button className="w-full text-left px-4 py-3 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-lg text-sm hover:bg-blue-200 dark:hover:bg-blue-900/60 transition-all">
                    📞 Rappel
                  </button>
                  <button className="w-full text-left px-4 py-3 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-lg text-sm hover:bg-blue-200 dark:hover:bg-blue-900/60 transition-all">
                    📧 Email
                  </button>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <input
                type="text"
                placeholder="Votre problème..."
                className={`w-full px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none`}
              />
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-green-500 to-emerald-500 p-4 text-white">
              <div className="flex items-center gap-3">
                <Headphones className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Expert Help</h3>
                  <p className="text-xs opacity-90">Technique</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-green-900/20' : 'bg-green-50'} rounded-lg mb-4`}>
                <p className="text-sm mb-3">🔧 Support :</p>
                <div className="space-y-3">
                  <div className={`p-3 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg`}>
                    <p className="text-sm font-medium mb-1">Installation</p>
                    <p className="text-xs text-gray-500">Configuration</p>
                  </div>
                  <div className={`p-3 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg`}>
                    <p className="text-sm font-medium mb-1">Dépannage</p>
                    <p className="text-xs text-gray-500">Résolution</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <button className="w-full px-4 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all">
                Contacter
              </button>
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-yellow-500 to-orange-500 p-4 text-white">
              <div className="flex items-center gap-3">
                <Star className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Premium Support</h3>
                  <p className="text-xs opacity-90">Prioritaire</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-yellow-900/20' : 'bg-yellow-50'} rounded-lg mb-4 border border-yellow-500`}>
                <div className="flex items-center gap-2 mb-3">
                  <Star className="w-5 h-5 text-yellow-600" />
                  <p className="text-sm font-bold text-yellow-700 dark:text-yellow-500">Avantages :</p>
                </div>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 bg-yellow-600 rounded-full"></div>
                    <span>Réponse rapide</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 bg-yellow-600 rounded-full"></div>
                    <span>Expert dédié</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 bg-yellow-600 rounded-full"></div>
                    <span>Support 24/7</span>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <button className="w-full px-4 py-3 bg-gradient-to-r from-yellow-600 to-orange-600 text-white rounded-lg font-bold">
                Passer Premium
              </button>
            </div>
          </div>
        </AssistantSection>

        <AssistantSection title="🎨 Assistants Créatifs">
          <div className={`${card} rounded-xl shadow-lg overflow-hidden border-2 border-purple-500`}>
            <div className="bg-purple-600 p-4 text-white">
              <div className="flex items-center gap-3">
                <Palette className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Design Assistant</h3>
                  <p className="text-xs opacity-90">Création</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-purple-900/20' : 'bg-purple-50'} rounded-lg mb-4`}>
                <p className="text-sm mb-3">🎨 Outils :</p>
                <div className="grid grid-cols-2 gap-2">
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm">
                    <Palette className="w-4 h-4 mx-auto mb-1" />
                    Couleurs
                  </button>
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm">
                    <Image className="w-4 h-4 mx-auto mb-1" />
                    Images
                  </button>
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm">
                    <Pencil className="w-4 h-4 mx-auto mb-1" />
                    Logos
                  </button>
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm">
                    <FileText className="w-4 h-4 mx-auto mb-1" />
                    Templates
                  </button>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <input
                type="text"
                placeholder="Décrivez votre projet..."
                className={`w-full px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none`}
              />
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden border-2 border-blue-500`}>
            <div className="bg-blue-600 p-4 text-white">
              <div className="flex items-center gap-3">
                <Code className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Code Assistant</h3>
                  <p className="text-xs opacity-90">Développement</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-blue-900/20' : 'bg-blue-50'} rounded-lg mb-4`}>
                <p className="text-sm mb-3">💻 Langages :</p>
                <div className="flex flex-wrap gap-2">
                  <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-full text-xs font-medium">
                    JavaScript
                  </span>
                  <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-full text-xs font-medium">
                    Python
                  </span>
                  <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-full text-xs font-medium">
                    React
                  </span>
                </div>
                <div className={`mt-4 p-3 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg font-mono text-xs`}>
                  <p className="text-green-500">// Code example</p>
                  <p>function hello() {'{'}</p>
                  <p className="ml-4">return 'Hello!';</p>
                  <p>{'}'}</p>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <button className="w-full px-4 py-3 bg-blue-600 text-white rounded-lg font-semibold">
                Générer code
              </button>
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden border-2 border-green-500`}>
            <div className="bg-green-600 p-4 text-white">
              <div className="flex items-center gap-3">
                <Pencil className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Writing Assistant</h3>
                  <p className="text-xs opacity-90">Rédaction</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-green-900/20' : 'bg-green-50'} rounded-lg mb-4`}>
                <p className="text-sm mb-3">✍️ Types :</p>
                <div className="space-y-2">
                  <button className="w-full text-left px-3 py-2 bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-300 rounded-lg text-sm">
                    📝 Article blog
                  </button>
                  <button className="w-full text-left px-3 py-2 bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-300 rounded-lg text-sm">
                    📧 Email pro
                  </button>
                  <button className="w-full text-left px-3 py-2 bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-300 rounded-lg text-sm">
                    📱 Post social
                  </button>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <textarea
                placeholder="Décrivez..."
                rows="2"
                className={`w-full px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg resize-none focus:outline-none`}
              />
            </div>
          </div>
        </AssistantSection>

        <AssistantSection title="💬 Widgets Flottants">
          <div className="relative h-96">
            <div className={`${card} rounded-2xl shadow-2xl p-6 h-full flex flex-col`}>
              <h3 className={`text-lg font-bold ${txt} mb-4`}>Compact Widget</h3>
              <div className="flex-1 overflow-y-auto mb-4">
                <div className="space-y-3">
                  <div className={`p-3 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg`}>
                    <p className="text-sm">Bonjour ! Comment puis-je aider ?</p>
                  </div>
                </div>
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Message..."
                  className={`flex-1 px-3 py-2 text-sm ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none`}
                />
                <button className="p-2 bg-blue-600 text-white rounded-lg">
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          <div className="relative h-96">
            <div className={`${card} rounded-xl shadow-xl p-4`}>
              <p className={`text-sm ${txt} text-center mb-4`}>Widget Bubble</p>
              <div className={`${card} rounded-full shadow-2xl p-4 flex items-center gap-3 cursor-pointer hover:shadow-3xl transition-all`}>
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center animate-pulse">
                  <Bot className="w-6 h-6 text-white" />
                </div>
                <div className="pr-2">
                  <p className={`font-bold text-sm ${txt}`}>Aide ?</p>
                  <p className={`text-xs ${txt2}`}>Cliquez ici</p>
                </div>
              </div>
            </div>
          </div>

          <div className="relative h-96">
            <div className={`${card} rounded-2xl shadow-2xl p-6`}>
              <div className="flex items-center justify-between mb-4">
                <h3 className={`text-lg font-bold ${txt}`}>Mini Chat</h3>
                <button className={`p-2 ${darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'} rounded-lg`}>
                  <Minimize2 className="w-4 h-4" />
                </button>
              </div>
              <div className="h-64 overflow-y-auto mb-4">
                <div className={`p-3 ${darkMode ? 'bg-blue-900/20' : 'bg-blue-50'} rounded-lg mb-3`}>
                  <p className="text-sm">Salut ! Je suis votre assistant. 👋</p>
                </div>
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Tapez..."
                  className={`flex-1 px-3 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg text-sm focus:outline-none`}
                />
                <button className="p-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg">
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </AssistantSection>

        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>🎨 Partie 2/2 Complete - E-commerce, Support Client, Assistants Créatifs & Widgets</p>
          <p className={`${txt2} text-sm mt-2`}>Collection complète de 30+ composants d'assistants IA prêts à l'emploi!</p>
        </div>
      </div>
    </div>
  );
}