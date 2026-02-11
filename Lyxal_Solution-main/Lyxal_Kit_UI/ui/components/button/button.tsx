import React, { useState } from "react";
import {
  Loader,
  Check,
  X,
  ArrowRight,
  Download,
  Upload,
  Trash2,
  Edit,
  Plus,
  Minus,
  Search,
  Heart,
  Star,
  Share2,
  Send,
  Save,
  Play,
  Pause,
  Volume2,
  Settings,
  User,
  Bell,
  ShoppingCart,
  Eye,
  EyeOff,
  Lock,
  Unlock,
  Mail,
  Phone,
  Home,
  Menu,
  ChevronRight,
  ChevronLeft,
  ChevronUp,
  ChevronDown,
  Copy,
  ExternalLink,
  Zap,
  Award,
  Gift,
  TrendingUp,
  AlertCircle,
} from "lucide-react";

export default function ButtonLibrary() {
  const [loading, setLoading] = useState({});
  const [liked, setLiked] = useState({});
  const [darkMode, setDarkMode] = useState(false);

  const toggleLoading = (id) => {
    setLoading({...loading, [id]: !loading[id]});
    setTimeout(() => setLoading({...loading, [id]: false}), 2000);
  };

  const bg = darkMode
    ? "bg-gray-900"
    : "bg-gradient-to-br from-gray-50 to-gray-100";
  const card = darkMode ? "bg-gray-800" : "bg-white";
  const txt = darkMode ? "text-gray-100" : "text-gray-900";
  const txt2 = darkMode ? "text-gray-400" : "text-gray-600";

  const ButtonSection = ({title, children}) => (
    <div className={`${card} rounded-xl p-6 shadow-lg`}>
      <h2 className={`text-2xl font-bold ${txt} mb-6 pb-3 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>{title}</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {children}
      </div>
    </div>
  );

  const ButtonDemo = ({children, label}) => (
    <div className="flex flex-col items-center gap-2 p-4 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
      {children}
      <span className={`text-xs ${txt2} text-center`}>{label}</span>
    </div>
  );

  return (
    <div className={`min-h-screen ${bg} p-8 transition-colors`}>
      <div className="max-w-7xl mx-auto space-y-8">
        {/* Header */}
        <div className={`${card} rounded-xl p-8 shadow-lg`}>
          <div className="flex justify-between items-center">
            <div>
              <h1 className={`text-4xl font-bold ${txt} mb-2`}>
                Bibliothèque de Boutons
              </h1>
              <p className={txt2}>
                Collection complète de styles de boutons React avec Tailwind CSS
              </p>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="p-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all"
            >
              {darkMode ? "☀️ Clair" : "🌙 Sombre"}
            </button>
          </div>
        </div>

        {/* Boutons Primaires */}
        <ButtonSection title="🎯 Boutons Primaires">
          <ButtonDemo label="Primary">
            <button className="px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all transform hover:scale-105">
              Cliquer
            </button>
          </ButtonDemo>

          <ButtonDemo label="Primary Large">
            <button className="px-8 py-4 bg-blue-600 text-white rounded-xl font-bold text-lg hover:bg-blue-700 transition-all shadow-lg hover:shadow-xl">
              Action
            </button>
          </ButtonDemo>

          <ButtonDemo label="Primary Small">
            <button className="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700 transition-all">
              Petit
            </button>
          </ButtonDemo>

          <ButtonDemo label="Primary Outline">
            <button className="px-6 py-3 border-2 border-blue-600 text-blue-600 rounded-lg font-semibold hover:bg-blue-600 hover:text-white transition-all">
              Outline
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons avec Icônes */}
        <ButtonSection title="🎨 Boutons avec Icônes">
          <ButtonDemo label="Icon Left">
            <button className="flex items-center gap-2 px-6 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all">
              <Download className="w-5 h-5" />
              Télécharger
            </button>
          </ButtonDemo>

          <ButtonDemo label="Icon Right">
            <button className="flex items-center gap-2 px-6 py-3 bg-purple-600 text-white rounded-lg font-semibold hover:bg-purple-700 transition-all">
              Suivant
              <ArrowRight className="w-5 h-5" />
            </button>
          </ButtonDemo>

          <ButtonDemo label="Icon Only">
            <button className="p-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-all">
              <Trash2 className="w-5 h-5" />
            </button>
          </ButtonDemo>

          <ButtonDemo label="Icon Circle">
            <button className="p-4 bg-indigo-600 text-white rounded-full hover:bg-indigo-700 transition-all shadow-lg hover:shadow-xl">
              <Plus className="w-6 h-6" />
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons de Couleurs */}
        <ButtonSection title="🌈 Variantes de Couleurs">
          <ButtonDemo label="Success">
            <button className="px-6 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all">
              Succès
            </button>
          </ButtonDemo>

          <ButtonDemo label="Danger">
            <button className="px-6 py-3 bg-red-600 text-white rounded-lg font-semibold hover:bg-red-700 transition-all">
              Danger
            </button>
          </ButtonDemo>

          <ButtonDemo label="Warning">
            <button className="px-6 py-3 bg-yellow-500 text-white rounded-lg font-semibold hover:bg-yellow-600 transition-all">
              Attention
            </button>
          </ButtonDemo>

          <ButtonDemo label="Info">
            <button className="px-6 py-3 bg-cyan-600 text-white rounded-lg font-semibold hover:bg-cyan-700 transition-all">
              Info
            </button>
          </ButtonDemo>

          <ButtonDemo label="Dark">
            <button className="px-6 py-3 bg-gray-800 text-white rounded-lg font-semibold hover:bg-gray-900 transition-all">
              Sombre
            </button>
          </ButtonDemo>

          <ButtonDemo label="Light">
            <button className="px-6 py-3 bg-gray-200 text-gray-800 rounded-lg font-semibold hover:bg-gray-300 transition-all">
              Clair
            </button>
          </ButtonDemo>

          <ButtonDemo label="Pink">
            <button className="px-6 py-3 bg-pink-600 text-white rounded-lg font-semibold hover:bg-pink-700 transition-all">
              Rose
            </button>
          </ButtonDemo>

          <ButtonDemo label="Orange">
            <button className="px-6 py-3 bg-orange-600 text-white rounded-lg font-semibold hover:bg-orange-700 transition-all">
              Orange
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons Gradients */}
        <ButtonSection title="✨ Boutons Gradients">
          <ButtonDemo label="Blue Gradient">
            <button className="px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-700 text-white rounded-lg font-semibold hover:from-blue-600 hover:to-blue-800 transition-all shadow-lg">
              Gradient Bleu
            </button>
          </ButtonDemo>

          <ButtonDemo label="Purple Gradient">
            <button className="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg font-semibold hover:from-purple-600 hover:to-pink-600 transition-all shadow-lg">
              Gradient Violet
            </button>
          </ButtonDemo>

          <ButtonDemo label="Green Gradient">
            <button className="px-6 py-3 bg-gradient-to-r from-green-400 to-cyan-500 text-white rounded-lg font-semibold hover:from-green-500 hover:to-cyan-600 transition-all shadow-lg">
              Gradient Vert
            </button>
          </ButtonDemo>

          <ButtonDemo label="Sunset Gradient">
            <button className="px-6 py-3 bg-gradient-to-r from-orange-500 via-red-500 to-pink-500 text-white rounded-lg font-semibold hover:from-orange-600 hover:via-red-600 hover:to-pink-600 transition-all shadow-lg">
              Coucher de soleil
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons Animés */}
        <ButtonSection title="🎭 Boutons Animés">
          <ButtonDemo label="Pulse">
            <button className="px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all animate-pulse">
              Pulse
            </button>
          </ButtonDemo>

          <ButtonDemo label="Bounce">
            <button className="px-6 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all hover:animate-bounce">
              Bounce
            </button>
          </ButtonDemo>

          <ButtonDemo label="Spin Icon">
            <button className="flex items-center gap-2 px-6 py-3 bg-purple-600 text-white rounded-lg font-semibold hover:bg-purple-700 transition-all">
              <Settings className="w-5 h-5 hover:animate-spin" />
              Paramètres
            </button>
          </ButtonDemo>

          <ButtonDemo label="Shake">
            <button className="px-6 py-3 bg-red-600 text-white rounded-lg font-semibold hover:bg-red-700 transition-all hover:animate-ping">
              Shake
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons avec États */}
        <ButtonSection title="⚡ Boutons avec États">
          <ButtonDemo label="Loading">
            <button
              onClick={() => toggleLoading("btn1")}
              disabled={loading.btn1}
              className="flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading.btn1 ? (
                <Loader className="w-5 h-5 animate-spin" />
              ) : (
                <Send className="w-5 h-5" />
              )}
              {loading.btn1 ? "Chargement..." : "Envoyer"}
            </button>
          </ButtonDemo>

          <ButtonDemo label="Success State">
            <button
              onClick={() => toggleLoading("btn2")}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-semibold transition-all ${
                loading.btn2 ? "bg-green-600" : "bg-blue-600"
              } text-white`}
            >
              {loading.btn2 ? (
                <Check className="w-5 h-5" />
              ) : (
                <Save className="w-5 h-5" />
              )}
              {loading.btn2 ? "Sauvegardé !" : "Sauvegarder"}
            </button>
          </ButtonDemo>

          <ButtonDemo label="Disabled">
            <button
              disabled
              className="px-6 py-3 bg-gray-400 text-gray-200 rounded-lg font-semibold cursor-not-allowed"
            >
              Désactivé
            </button>
          </ButtonDemo>

          <ButtonDemo label="Toggle Like">
            <button
              onClick={() => setLiked({ ...liked, btn1: !liked.btn1 })}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-semibold transition-all ${
                liked.btn1
                  ? "bg-red-600 text-white"
                  : "bg-gray-200 text-gray-700"
              }`}
            >
              <Heart
                className={`w-5 h-5 ${liked.btn1 ? "fill-current" : ""}`}
              />
              {liked.btn1 ? "Aimé" : "Aimer"}
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons Spéciaux */}
        <ButtonSection title="🎪 Boutons Spéciaux">
          <ButtonDemo label="Glass Effect">
            <button className="px-6 py-3 bg-white bg-opacity-20 backdrop-blur-lg border border-white border-opacity-30 text-gray-800 dark:text-white rounded-lg font-semibold hover:bg-opacity-30 transition-all shadow-lg">
              Glassmorphism
            </button>
          </ButtonDemo>

          <ButtonDemo label="Neon">
            <button className="px-6 py-3 bg-purple-600 text-white rounded-lg font-semibold transition-all shadow-lg shadow-purple-500/50 hover:shadow-purple-500/70 hover:shadow-xl">
              Neon Glow
            </button>
          </ButtonDemo>

          <ButtonDemo label="3D Effect">
            <button className="px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold transition-all shadow-lg transform hover:-translate-y-1 hover:shadow-2xl active:translate-y-0">
              3D Button
            </button>
          </ButtonDemo>

          <ButtonDemo label="Outline Gradient">
            <button className="px-6 py-3 bg-transparent border-2 border-transparent bg-gradient-to-r from-purple-500 to-pink-500 bg-clip-text text-transparent font-bold rounded-lg hover:from-purple-600 hover:to-pink-600 transition-all">
              Outline Gradient
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Groupes de Boutons */}
        <ButtonSection title="👥 Groupes de Boutons">
          <ButtonDemo label="Button Group">
            <div className="flex rounded-lg overflow-hidden border border-gray-300">
              <button className="px-4 py-2 bg-white hover:bg-gray-100 text-gray-700 border-r border-gray-300 transition-all">
                <ChevronLeft className="w-5 h-5" />
              </button>
              <button className="px-4 py-2 bg-white hover:bg-gray-100 text-gray-700 border-r border-gray-300 transition-all">
                Home
              </button>
              <button className="px-4 py-2 bg-white hover:bg-gray-100 text-gray-700 transition-all">
                <ChevronRight className="w-5 h-5" />
              </button>
            </div>
          </ButtonDemo>

          <ButtonDemo label="Segmented Control">
            <div className="flex gap-1 p-1 bg-gray-200 rounded-lg">
              <button className="px-4 py-2 bg-white text-gray-700 rounded-md font-medium shadow-sm">
                Liste
              </button>
              <button className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md font-medium transition-all">
                Grille
              </button>
              <button className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md font-medium transition-all">
                Carte
              </button>
            </div>
          </ButtonDemo>

          <ButtonDemo label="Icon Group">
            <div className="flex gap-2">
              <button className="p-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all">
                <Heart className="w-5 h-5" />
              </button>
              <button className="p-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-all">
                <Star className="w-5 h-5" />
              </button>
              <button className="p-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-all">
                <Share2 className="w-5 h-5" />
              </button>
            </div>
          </ButtonDemo>

          <ButtonDemo label="Toolbar">
            <div className="flex gap-1 p-1 bg-gray-100 rounded-lg">
              <button className="p-2 hover:bg-white rounded transition-all">
                <Edit className="w-4 h-4" />
              </button>
              <button className="p-2 hover:bg-white rounded transition-all">
                <Copy className="w-4 h-4" />
              </button>
              <button className="p-2 hover:bg-white rounded transition-all">
                <Trash2 className="w-4 h-4 text-red-600" />
              </button>
            </div>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons Sociaux */}
        <ButtonSection title="📱 Boutons Sociaux & Actions">
          <ButtonDemo label="Facebook Style">
            <button className="flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all shadow-lg">
              <Share2 className="w-5 h-5" />
              Partager
            </button>
          </ButtonDemo>

          <ButtonDemo label="Twitter Style">
            <button className="flex items-center gap-2 px-6 py-3 bg-sky-500 text-white rounded-full font-semibold hover:bg-sky-600 transition-all shadow-lg">
              <Send className="w-5 h-5" />
              Tweet
            </button>
          </ButtonDemo>

          <ButtonDemo label="WhatsApp Style">
            <button className="flex items-center gap-2 px-6 py-3 bg-green-500 text-white rounded-lg font-semibold hover:bg-green-600 transition-all shadow-lg">
              <Phone className="w-5 h-5" />
              Envoyer
            </button>
          </ButtonDemo>

          <ButtonDemo label="Subscribe">
            <button className="flex items-center gap-2 px-6 py-3 bg-red-600 text-white rounded-lg font-semibold hover:bg-red-700 transition-all shadow-lg">
              <Bell className="w-5 h-5" />
              S'abonner
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons CTA */}
        <ButtonSection title="🎯 Call-to-Action Premium">
          <ButtonDemo label="Premium CTA">
            <button className="flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-yellow-400 to-orange-500 text-white rounded-xl font-bold text-lg hover:from-yellow-500 hover:to-orange-600 transition-all shadow-2xl transform hover:scale-105">
              <Zap className="w-6 h-6" />
              Passer Pro
            </button>
          </ButtonDemo>

          <ButtonDemo label="Shopping Cart">
            <button className="flex items-center gap-2 px-6 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all shadow-lg">
              <ShoppingCart className="w-5 h-5" />
              Acheter Maintenant
            </button>
          </ButtonDemo>

          <ButtonDemo label="Get Started">
            <button className="flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-full font-bold text-lg hover:from-blue-700 hover:to-purple-700 transition-all shadow-2xl">
              Commencer
              <ArrowRight className="w-6 h-6" />
            </button>
          </ButtonDemo>

          <ButtonDemo label="Award Winner">
            <button className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-amber-400 to-yellow-500 text-gray-900 rounded-lg font-bold hover:from-amber-500 hover:to-yellow-600 transition-all shadow-xl">
              <Award className="w-5 h-5" />
              Récompensé
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Boutons Tailles */}
        <ButtonSection title="📏 Différentes Tailles">
          <ButtonDemo label="Extra Small">
            <button className="px-2 py-1 bg-blue-600 text-white rounded text-xs font-medium hover:bg-blue-700 transition-all">
              XS
            </button>
          </ButtonDemo>

          <ButtonDemo label="Small">
            <button className="px-3 py-1.5 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700 transition-all">
              Small
            </button>
          </ButtonDemo>

          <ButtonDemo label="Medium">
            <button className="px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all">
              Medium
            </button>
          </ButtonDemo>

          <ButtonDemo label="Large">
            <button className="px-8 py-4 bg-blue-600 text-white rounded-xl text-lg font-bold hover:bg-blue-700 transition-all">
              Large
            </button>
          </ButtonDemo>

          <ButtonDemo label="Extra Large">
            <button className="px-10 py-5 bg-blue-600 text-white rounded-2xl text-xl font-bold hover:bg-blue-700 transition-all shadow-2xl">
              XL
            </button>
          </ButtonDemo>
        </ButtonSection>

        {/* Footer */}
        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>
            🎨 Collection complète de {8 * 4} styles de boutons différents
          </p>
          <p className={`${txt2} text-sm mt-2`}>
            Personnalisables avec Tailwind CSS • Réactifs • Accessibles
          </p>
        </div>
      </div>
    </div>
  );
}
