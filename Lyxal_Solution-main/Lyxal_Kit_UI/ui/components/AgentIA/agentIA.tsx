import React, { useState } from 'react';
import { 
  MessageSquare, Send, Mic, Paperclip, X, Minimize2, Maximize2,
  Bot, Sparkles, Zap, Heart, Star, Settings, MoreVertical,
  Volume2, VolumeX, Copy, ThumbsUp, ThumbsDown, RefreshCw,
  Image, FileText, Code, Lightbulb, TrendingUp, ShoppingBag,
  Stethoscope, GraduationCap, Briefcase, Home, User, Phone
} from 'lucide-react';

export default function AIAssistantPart1() {
  const [darkMode, setDarkMode] = useState(false);
  const [messages, setMessages] = useState({});
  const [inputValue, setInputValue] = useState({});
  const [isTyping, setIsTyping] = useState({});

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';

  const handleSend = (id, value) => {
    if (!value || !value.trim()) return;
    
    const newMessages = [...(messages[id] || []), { type: 'user', text: value }];
    setMessages({ ...messages, [id]: newMessages });
    setInputValue({ ...inputValue, [id]: '' });
    
    setIsTyping({ ...isTyping, [id]: true });
    setTimeout(() => {
      const aiMessage = { type: 'ai', text: 'Voici ma réponse à votre question. Comment puis-je vous aider davantage ?' };
      setMessages({ ...messages, [id]: [...newMessages, aiMessage] });
      setIsTyping({ ...isTyping, [id]: false });
    }, 1500);
  };

  const AssistantSection = ({title, children}) => (
    <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
      <h2 className={`text-3xl font-bold ${txt} mb-8 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>{title}</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {children}
      </div>
    </div>
  );

  const ChatBubble = ({id}) => {
    const msgs = messages[id] || [];
    return (
      <div className="space-y-3">
        {msgs.slice(-3).map((msg, i) => (
          <div key={i} className={`flex ${msg.type === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-[80%] p-3 rounded-lg ${
              msg.type === 'user' 
                ? 'bg-blue-600 text-white' 
                : darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100 text-gray-900'
            }`}>
              <p className="text-sm">{msg.text}</p>
            </div>
          </div>
        ))}
        {isTyping[id] && (
          <div className="flex justify-start">
            <div className={`p-3 rounded-lg ${darkMode ? 'bg-gray-700' : 'bg-gray-100'}`}>
              <div className="flex gap-1">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.2s'}}></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.4s'}}></div>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  };

  return (
    <div className={`min-h-screen ${bg} p-8 transition-colors`}>
      <div className="max-w-7xl mx-auto space-y-8">
        
        <div className={`${card} rounded-2xl p-10 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <div className="flex justify-between items-center">
            <div>
              <h1 className={`text-5xl font-bold ${txt} mb-3 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent`}>
                Assistants IA - Partie 1/2
              </h1>
              <p className={`text-lg ${txt2}`}>Styles classiques, modernes et business</p>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-bold hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg"
            >
              {darkMode ? '☀️' : '🌙'}
            </button>
          </div>
        </div>

        <AssistantSection title="🤖 Assistants Classiques">
          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-4 text-white">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="p-2 bg-white/20 rounded-lg">
                    <Bot className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="font-bold">Assistant Pro</h3>
                    <p className="text-xs opacity-90">En ligne</p>
                  </div>
                </div>
                <div className="flex gap-2">
                  <button className="p-2 hover:bg-white/20 rounded-lg transition-all">
                    <Minimize2 className="w-4 h-4" />
                  </button>
                  <button className="p-2 hover:bg-white/20 rounded-lg transition-all">
                    <X className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <ChatBubble id="classic1" />
            </div>
            <div className="p-4 border-t border-gray-200 dark:border-gray-700">
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Tapez votre message..."
                  value={inputValue.classic1 || ''}
                  onChange={(e) => setInputValue({...inputValue, classic1: e.target.value})}
                  onKeyPress={(e) => e.key === 'Enter' && handleSend('classic1', inputValue.classic1)}
                  className={`flex-1 px-4 py-2 ${darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100'} rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500`}
                />
                <button 
                  onClick={() => handleSend('classic1', inputValue.classic1)}
                  className="p-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all"
                >
                  <Send className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden`}>
            <div className="bg-gradient-to-r from-purple-600 to-pink-600 p-4 text-white">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="p-2 bg-white/20 rounded-full">
                    <Sparkles className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="font-bold">AI Magic</h3>
                    <p className="text-xs opacity-90">Disponible</p>
                  </div>
                </div>
                <button className="p-2 hover:bg-white/20 rounded-lg">
                  <Settings className="w-5 h-5" />
                </button>
              </div>
            </div>
            <div className="p-4 h-80 overflow-y-auto">
              <div className="text-center mb-4">
                <div className="inline-flex p-4 bg-purple-100 dark:bg-purple-900/30 rounded-full mb-3">
                  <Sparkles className="w-8 h-8 text-purple-600" />
                </div>
                <h4 className={`font-bold ${txt} mb-2`}>Comment puis-je aider ?</h4>
                <p className={`text-sm ${txt2}`}>Posez votre question</p>
              </div>
              <ChatBubble id="classic2" />
            </div>
            <div className="p-4 border-t border-gray-200 dark:border-gray-700">
              <div className="flex gap-2 mb-2">
                <button className="flex-1 px-3 py-2 bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 rounded-lg text-sm font-medium">
                  💡 Idées
                </button>
                <button className="flex-1 px-3 py-2 bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 rounded-lg text-sm font-medium">
                  📝 Rédiger
                </button>
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Message..."
                  value={inputValue.classic2 || ''}
                  onChange={(e) => setInputValue({...inputValue, classic2: e.target.value})}
                  className={`flex-1 px-4 py-2 ${darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100'} rounded-lg focus:outline-none`}
                />
                <button 
                  onClick={() => handleSend('classic2', inputValue.classic2)}
                  className="p-2 bg-purple-600 text-white rounded-lg">
                  <Mic className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden border-2 border-blue-500`}>
            <div className="p-4 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-gray-700 dark:to-gray-800">
              <div className="flex items-center gap-3 mb-3">
                <div className="p-3 bg-blue-600 rounded-full animate-pulse">
                  <Zap className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className={`font-bold ${txt}`}>QuickAssist</h3>
                  <p className={`text-xs ${txt2}`}>Réponses instantanées</p>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-2">
                <button className={`px-3 py-2 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg text-sm font-medium hover:bg-blue-100 dark:hover:bg-gray-600`}>
                  ⚡ Rapide
                </button>
                <button className={`px-3 py-2 ${darkMode ? 'bg-gray-700' : 'bg-white'} rounded-lg text-sm font-medium hover:bg-blue-100 dark:hover:bg-gray-600`}>
                  🎯 Précis
                </button>
              </div>
            </div>
            <div className="p-4 h-72 overflow-y-auto">
              <ChatBubble id="classic3" />
            </div>
            <div className="p-4 border-t">
              <div className="flex gap-2">
                <button className={`p-2 ${darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'} rounded-lg`}>
                  <Paperclip className="w-5 h-5" />
                </button>
                <input
                  type="text"
                  placeholder="Question..."
                  value={inputValue.classic3 || ''}
                  onChange={(e) => setInputValue({...inputValue, classic3: e.target.value})}
                  className={`flex-1 px-4 py-2 ${darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100'} rounded-lg`}
                />
                <button onClick={() => handleSend('classic3', inputValue.classic3)} className="p-2 bg-blue-600 text-white rounded-lg">
                  <Send className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>
        </AssistantSection>

        <AssistantSection title="🎨 Styles Modernes & Minimaux">
          <div className={`${card} rounded-2xl shadow-xl overflow-hidden`}>
            <div className="p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center">
                  <Bot className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className={`font-bold text-lg ${txt}`}>Minimal AI</h3>
                  <p className={`text-xs ${txt2}`}>Clean & Simple</p>
                </div>
              </div>
              <div className="space-y-3 mb-4 h-64 overflow-y-auto">
                <div className="flex justify-start">
                  <div className={`px-4 py-2 rounded-2xl ${darkMode ? 'bg-gray-700' : 'bg-gray-100'}`}>
                    <p className="text-sm">Bonjour ! Comment puis-je vous aider aujourd'hui ?</p>
                  </div>
                </div>
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Écrivez ici..."
                  className={`flex-1 px-4 py-3 ${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500`}
                />
                <button className="w-12 h-12 bg-blue-600 text-white rounded-full flex items-center justify-center hover:bg-blue-700 transition-all">
                  <Send className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>

          <div className={`relative ${card} rounded-2xl shadow-xl overflow-hidden`}>
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500"></div>
            <div className="p-6">
              <div className="text-center mb-6">
                <div className="inline-flex p-3 bg-gradient-to-br from-blue-500 to-purple-500 rounded-2xl mb-3">
                  <Sparkles className="w-8 h-8 text-white" />
                </div>
                <h3 className={`font-bold text-lg ${txt}`}>Smart Assistant</h3>
              </div>
              <div className="space-y-3 mb-4 h-56 overflow-y-auto">
                <div className={`p-4 ${darkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-xl`}>
                  <p className="text-sm mb-2">Suggestions rapides :</p>
                  <div className="space-y-2">
                    <button className="w-full text-left px-3 py-2 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg text-sm hover:bg-blue-200 dark:hover:bg-blue-900/50">
                      💬 Commencer une discussion
                    </button>
                    <button className="w-full text-left px-3 py-2 bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 rounded-lg text-sm hover:bg-purple-200 dark:hover:bg-purple-900/50">
                      🎯 Obtenir des conseils
                    </button>
                  </div>
                </div>
              </div>
              <textarea
                placeholder="Votre message..."
                rows="2"
                className={`w-full px-4 py-3 ${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border rounded-xl resize-none focus:outline-none focus:ring-2 focus:ring-purple-500`}
              />
              <button className="w-full mt-2 px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-semibold hover:from-blue-700 hover:to-purple-700 transition-all">
                Envoyer
              </button>
            </div>
          </div>

          <div className={`${card} rounded-2xl shadow-xl overflow-hidden`}>
            <div className="p-6">
              <div className="flex justify-between items-start mb-6">
                <div className="flex items-center gap-3">
                  <div className="relative">
                    <div className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center">
                      <Bot className="w-6 h-6 text-white" />
                    </div>
                    <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-400 rounded-full border-2 border-white"></div>
                  </div>
                  <div>
                    <h3 className={`font-bold ${txt}`}>ChatBot Live</h3>
                    <p className="text-xs text-green-500">● En ligne</p>
                  </div>
                </div>
                <button className={`p-2 ${darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'} rounded-lg transition-all`}>
                  <MoreVertical className="w-5 h-5" />
                </button>
              </div>
              <div className="h-64 overflow-y-auto mb-4">
                <div className="space-y-3">
                  <div className="flex items-start gap-2">
                    <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0">
                      <Bot className="w-4 h-4 text-white" />
                    </div>
                    <div className={`flex-1 p-3 rounded-lg ${darkMode ? 'bg-gray-700' : 'bg-gray-100'}`}>
                      <p className="text-sm">Bonjour ! Je suis là pour vous aider. Que puis-je faire pour vous ?</p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="Tapez votre message..."
                    className={`flex-1 px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500`}
                  />
                  <button className="p-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-all">
                    <Send className="w-5 h-5" />
                  </button>
                </div>
                <div className="flex gap-2 text-xs">
                  <button className={`p-2 ${darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'} rounded-lg transition-all`}>
                    <Mic className="w-4 h-4" />
                  </button>
                  <button className={`p-2 ${darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'} rounded-lg transition-all`}>
                    <Image className="w-4 h-4" />
                  </button>
                  <button className={`p-2 ${darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'} rounded-lg transition-all`}>
                    <FileText className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </AssistantSection>

        <AssistantSection title="🏢 Assistants Thématiques">
          <div className={`${card} rounded-xl shadow-lg overflow-hidden border-2 border-blue-500`}>
            <div className="bg-blue-600 p-4 text-white">
              <div className="flex items-center gap-3">
                <Briefcase className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Business Assistant</h3>
                  <p className="text-xs opacity-90">Conseils professionnels</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-64 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-blue-900/20' : 'bg-blue-50'} rounded-lg mb-4`}>
                <p className="text-sm mb-3">💼 Je peux vous aider avec :</p>
                <div className="space-y-2">
                  <button className="w-full text-left px-3 py-2 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-lg text-sm hover:bg-blue-200 dark:hover:bg-blue-900/60">
                    📊 Analyse de données
                  </button>
                  <button className="w-full text-left px-3 py-2 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-lg text-sm hover:bg-blue-200 dark:hover:bg-blue-900/60">
                    📈 Stratégie marketing
                  </button>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <input
                type="text"
                placeholder="Question business..."
                className={`w-full px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500`}
              />
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden border-2 border-green-500`}>
            <div className="bg-green-600 p-4 text-white">
              <div className="flex items-center gap-3">
                <Stethoscope className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Health Assistant</h3>
                  <p className="text-xs opacity-90">Conseils santé</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-64 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-green-900/20' : 'bg-green-50'} rounded-lg`}>
                <p className="text-sm mb-2">🏥 Services disponibles :</p>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2">
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span>Conseils bien-être</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span>Suivi nutrition</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span>Exercices quotidiens</span>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <input
                type="text"
                placeholder="Question santé..."
                className={`w-full px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500`}
              />
            </div>
          </div>

          <div className={`${card} rounded-xl shadow-lg overflow-hidden border-2 border-purple-500`}>
            <div className="bg-purple-600 p-4 text-white">
              <div className="flex items-center gap-3">
                <GraduationCap className="w-6 h-6" />
                <div>
                  <h3 className="font-bold">Learning Assistant</h3>
                  <p className="text-xs opacity-90">Aide à l'apprentissage</p>
                </div>
              </div>
            </div>
            <div className="p-4 h-64 overflow-y-auto">
              <div className={`p-4 ${darkMode ? 'bg-purple-900/20' : 'bg-purple-50'} rounded-lg`}>
                <p className="text-sm mb-3">📚 Matières disponibles :</p>
                <div className="grid grid-cols-2 gap-2">
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm hover:bg-purple-200 dark:hover:bg-purple-900/60">
                    Math
                  </button>
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm hover:bg-purple-200 dark:hover:bg-purple-900/60">
                    Sciences
                  </button>
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm hover:bg-purple-200 dark:hover:bg-purple-900/60">
                    Langues
                  </button>
                  <button className="px-3 py-2 bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 rounded-lg text-sm hover:bg-purple-200 dark:hover:bg-purple-900/60">
                    Histoire
                  </button>
                </div>
              </div>
            </div>
            <div className="p-4 border-t">
              <input
                type="text"
                placeholder="Question cours..."
                className={`w-full px-4 py-2 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'} rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500`}
              />
            </div>
          </div>
        </AssistantSection>

        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>🎨 Partie 1/2 - Assistants Classiques, Modernes et Thématiques (Business, Santé, Éducation)</p>
          <p className={`${txt2} text-sm mt-2`}>Partie 2 arrive : E-commerce, Support, Créatifs, Widgets & plus...</p>
        </div>
      </div>
    </div>
  );
}