import React, { useState } from 'react';
import { 
  Mail, Lock, User, X, Fingerprint, Gamepad2, Zap, Eye,
  Shield, Unlock, ChevronRight, Cpu, Radio, Wifi, Camera,
  Play, Volume2, Headphones, Terminal, Code2, Binary
} from 'lucide-react';

export default function SignInV2Part2() {
  const [darkMode, setDarkMode] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [biometricStatus, setBiometricStatus] = useState('idle');
  const [unlockProgress, setUnlockProgress] = useState(0);
  const [isDragging, setIsDragging] = useState(false);

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-cyan-50 via-blue-50 to-purple-50';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';
  const input = darkMode ? 'bg-gray-700 border-gray-600 text-white' : 'bg-white border-gray-300 text-gray-900';

  const handleBiometric = () => {
    setBiometricStatus('scanning');
    setTimeout(() => setBiometricStatus('success'), 2000);
    setTimeout(() => setBiometricStatus('idle'), 4000);
  };

  const handleDragStart = () => {
    setIsDragging(true);
  };

  const handleDrag = (e) => {
    if (isDragging) {
      const slider = e.currentTarget;
      const rect = slider.getBoundingClientRect();
      const progress = Math.min(100, Math.max(0, ((e.clientX - rect.left) / rect.width) * 100));
      setUnlockProgress(progress);
      if (progress >= 95) {
        setUnlockProgress(100);
        setIsDragging(false);
      }
    }
  };

  const FormSection = ({title, children}) => (
    <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
      <h2 className={`text-3xl font-bold ${txt} mb-8 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>{title}</h2>
      {children}
    </div>
  );

  return (
    <div className={`min-h-screen ${bg} p-8 transition-colors`}>
      <div className="max-w-7xl mx-auto space-y-8">
        
        <div className={`${card} rounded-2xl p-10 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <div className="flex justify-between items-center">
            <div>
              <h1 className={`text-5xl font-bold ${txt} mb-3 bg-gradient-to-r from-cyan-600 to-blue-600 bg-clip-text text-transparent`}>
                Sign In/Up V2 Ultra - Partie 2
              </h1>
              <p className={`text-lg ${txt2}`}>Biometric, Modal, Gaming, Video Background & More</p>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="px-6 py-3 bg-gradient-to-r from-cyan-600 to-blue-600 text-white rounded-xl font-bold hover:from-cyan-700 hover:to-blue-700 transition-all shadow-lg"
            >
              {darkMode ? '☀️' : '🌙'}
            </button>
          </div>
        </div>

        <FormSection title="🔐 Biometric & Advanced Security">
          <div className="grid md:grid-cols-3 gap-6">
            <div className={`${card} p-8 rounded-xl shadow-lg border-2 ${biometricStatus === 'success' ? 'border-green-500' : 'border-gray-200 dark:border-gray-700'}`}>
              <div className="flex justify-center mb-6">
                <div className={`p-6 rounded-full transition-all ${
                  biometricStatus === 'scanning' ? 'bg-blue-500 animate-pulse' :
                  biometricStatus === 'success' ? 'bg-green-500' :
                  'bg-gradient-to-br from-purple-500 to-pink-500'
                }`}>
                  <Fingerprint className="w-12 h-12 text-white" />
                </div>
              </div>
              <h3 className={`text-2xl font-bold ${txt} mb-2 text-center`}>Biometric Login</h3>
              <p className={`text-sm ${txt2} mb-6 text-center`}>
                {biometricStatus === 'scanning' ? 'Scanning...' :
                 biometricStatus === 'success' ? 'Verified!' :
                 'Touch to authenticate'}
              </p>
              <button 
                onClick={handleBiometric}
                disabled={biometricStatus !== 'idle'}
                className={`w-full px-6 py-3 rounded-lg font-bold transition-all ${
                  biometricStatus === 'success' ? 'bg-green-600 text-white' :
                  'bg-gradient-to-r from-purple-600 to-pink-600 text-white hover:from-purple-700 hover:to-pink-700'
                } disabled:opacity-50`}
              >
                {biometricStatus === 'success' ? 'Authenticated' : 'Use Fingerprint'}
              </button>
            </div>

            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <div className="flex justify-center mb-6">
                <div className="p-6 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-full">
                  <Camera className="w-12 h-12 text-white" />
                </div>
              </div>
              <h3 className={`text-2xl font-bold ${txt} mb-2 text-center`}>Face Recognition</h3>
              <p className={`text-sm ${txt2} mb-6 text-center`}>Instant secure access</p>
              <div className="relative mb-6">
                <div className="w-full h-40 bg-gray-200 dark:bg-gray-700 rounded-lg flex items-center justify-center overflow-hidden">
                  <div className="w-32 h-32 border-4 border-blue-500 rounded-full animate-ping"></div>
                  <Eye className="w-16 h-16 text-blue-500 absolute" />
                </div>
              </div>
              <button className="w-full px-6 py-3 bg-gradient-to-r from-blue-600 to-cyan-600 text-white rounded-lg font-bold hover:from-blue-700 hover:to-cyan-700 transition-all">
                Scan Face
              </button>
            </div>

            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <div className="flex justify-center mb-6">
                <div className="p-6 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full">
                  <Shield className="w-12 h-12 text-white" />
                </div>
              </div>
              <h3 className={`text-2xl font-bold ${txt} mb-2 text-center`}>Multi-Factor</h3>
              <p className={`text-sm ${txt2} mb-6 text-center`}>Extra security layer</p>
              <div className="space-y-3 mb-6">
                <div className={`p-3 rounded-lg ${darkMode ? 'bg-gray-700' : 'bg-green-50'} border border-green-500`}>
                  <div className="flex items-center justify-between">
                    <span className={`text-sm font-medium ${txt}`}>Password</span>
                    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-xs">✓</span>
                    </div>
                  </div>
                </div>
                <div className={`p-3 rounded-lg ${darkMode ? 'bg-gray-700' : 'bg-blue-50'} border border-blue-500`}>
                  <div className="flex items-center justify-between">
                    <span className={`text-sm font-medium ${txt}`}>SMS Code</span>
                    <div className="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-xs">2</span>
                    </div>
                  </div>
                </div>
              </div>
              <button className="w-full px-6 py-3 bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-lg font-bold hover:from-green-700 hover:to-emerald-700 transition-all">
                Continue
              </button>
            </div>
          </div>
        </FormSection>

        <FormSection title="🎮 Gaming & Cyberpunk Styles">
          <div className="grid md:grid-cols-2 gap-6">
            <div className="relative bg-black rounded-xl overflow-hidden shadow-2xl border-2 border-cyan-500">
              <div className="absolute inset-0 bg-gradient-to-br from-cyan-500/20 to-purple-500/20"></div>
              
              <div className="relative p-8">
                <div className="flex items-center gap-3 mb-6">
                  <Gamepad2 className="w-8 h-8 text-cyan-400" />
                  <h3 className="text-3xl font-bold text-cyan-400">CYBERPUNK</h3>
                </div>
                <div className="space-y-4">
                  <input 
                    type="text" 
                    placeholder="USERNAME" 
                    className="w-full px-4 py-3 bg-black/50 border-2 border-cyan-500 text-cyan-400 rounded-none font-mono uppercase placeholder-cyan-700 focus:outline-none focus:border-cyan-300" 
                  />
                  <input 
                    type="password" 
                    placeholder="PASSWORD" 
                    className="w-full px-4 py-3 bg-black/50 border-2 border-cyan-500 text-cyan-400 rounded-none font-mono uppercase placeholder-cyan-700 focus:outline-none focus:border-cyan-300" 
                  />
                  <button className="w-full px-6 py-3 bg-cyan-500 text-black rounded-none font-bold uppercase tracking-wider hover:bg-cyan-400 transition-all">
                    <Terminal className="inline-block w-5 h-5 mr-2" />
                    ACCESS SYSTEM
                  </button>
                  <div className="flex gap-2 text-xs text-cyan-500 font-mono">
                    <span className="animate-pulse">&gt;</span>
                    <span>SECURITY_LEVEL: MAX</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="relative bg-gradient-to-br from-purple-900 via-pink-900 to-red-900 rounded-xl overflow-hidden shadow-2xl">
              <div className="relative p-8">
                <div className="flex items-center justify-center mb-6">
                  <div className="p-4 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full">
                    <Zap className="w-10 h-10 text-white" />
                  </div>
                </div>
                <h3 className="text-3xl font-bold text-center mb-2 text-transparent bg-clip-text bg-gradient-to-r from-purple-300 to-pink-300">
                  NEON GAMING
                </h3>
                <p className="text-center text-purple-300 mb-6 text-sm">Enter the arena</p>
                
                <div className="space-y-4">
                  <input 
                    type="text" 
                    placeholder="Player Name" 
                    className="w-full px-4 py-3 bg-black/30 backdrop-blur-sm border-2 border-purple-500 text-white rounded-lg placeholder-purple-300 focus:outline-none focus:border-pink-500" 
                  />
                  <input 
                    type="password" 
                    placeholder="Password" 
                    className="w-full px-4 py-3 bg-black/30 backdrop-blur-sm border-2 border-purple-500 text-white rounded-lg placeholder-purple-300 focus:outline-none focus:border-pink-500" 
                  />
                  <button className="w-full px-6 py-3 bg-gradient-to-r from-purple-600 via-pink-600 to-red-600 text-white rounded-lg font-bold uppercase tracking-wider hover:from-purple-500 hover:via-pink-500 hover:to-red-500 transition-all">
                    <Headphones className="inline-block w-5 h-5 mr-2" />
                    JOIN GAME
                  </button>
                </div>
              </div>
            </div>

            <div className="relative bg-gradient-to-br from-green-900 to-emerald-900 rounded-xl overflow-hidden shadow-2xl border-2 border-green-500">
              <div className="relative p-8">
                <div className="flex items-center gap-3 mb-6">
                  <Code2 className="w-8 h-8 text-green-400" />
                  <h3 className="text-2xl font-bold text-green-400 font-mono">TERMINAL</h3>
                </div>
                <div className="space-y-3">
                  <div className="flex items-center gap-2 text-green-400 font-mono text-sm">
                    <span>&gt;</span>
                    <span>root@system</span>
                  </div>
                  <input 
                    type="text" 
                    placeholder="username" 
                    className="w-full px-4 py-2 bg-black/50 border border-green-500 text-green-400 rounded font-mono placeholder-green-700 focus:outline-none focus:border-green-300" 
                  />
                  <input 
                    type="password" 
                    placeholder="password" 
                    className="w-full px-4 py-2 bg-black/50 border border-green-500 text-green-400 rounded font-mono placeholder-green-700 focus:outline-none focus:border-green-300" 
                  />
                  <button className="w-full px-6 py-2 bg-green-500 text-black rounded font-bold font-mono hover:bg-green-400 transition-all">
                    [EXECUTE]
                  </button>
                </div>
              </div>
            </div>

            <div className="relative bg-gradient-to-br from-red-900 via-orange-900 to-yellow-900 rounded-xl overflow-hidden shadow-2xl">
              <div className="relative p-8">
                <div className="flex justify-center mb-4">
                  <div className="p-4 bg-gradient-to-r from-red-500 to-orange-500 rounded-full">
                    <Cpu className="w-10 h-10 text-white animate-pulse" />
                  </div>
                </div>
                <h3 className="text-3xl font-bold text-center mb-2 text-transparent bg-clip-text bg-gradient-to-r from-red-300 to-orange-300">
                  FIRE MODE
                </h3>
                <p className="text-center text-orange-300 mb-6 text-sm uppercase tracking-wider">Maximum Security</p>
                
                <div className="space-y-4">
                  <input 
                    type="text" 
                    placeholder="Access Code" 
                    className="w-full px-4 py-3 bg-black/40 backdrop-blur-sm border-2 border-red-500 text-white rounded-lg placeholder-red-300 focus:outline-none focus:border-orange-500" 
                  />
                  <input 
                    type="password" 
                    placeholder="Security Key" 
                    className="w-full px-4 py-3 bg-black/40 backdrop-blur-sm border-2 border-red-500 text-white rounded-lg placeholder-red-300 focus:outline-none focus:border-orange-500" 
                  />
                  <button className="w-full px-6 py-3 bg-gradient-to-r from-red-600 to-orange-600 text-white rounded-lg font-bold uppercase tracking-wider hover:from-red-500 hover:to-orange-500 transition-all">
                    🔥 AUTHENTICATE
                  </button>
                </div>
              </div>
            </div>
          </div>
        </FormSection>

        <FormSection title="🎭 Modal & Popup Login">
          <div className="grid md:grid-cols-2 gap-6">
            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <h3 className={`text-2xl font-bold ${txt} mb-6`}>Trigger Modal</h3>
              <p className={`text-sm ${txt2} mb-6`}>Click button to open popup login</p>
              <button 
                onClick={() => setShowModal(true)}
                className="w-full px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg font-bold hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg"
              >
                Open Login Modal
              </button>
            </div>

            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <h3 className={`text-2xl font-bold ${txt} mb-6`}>Inline Preview</h3>
              <div className="relative">
                <div className={`p-6 ${darkMode ? 'bg-gray-700' : 'bg-gray-50'} rounded-lg border-2 border-dashed ${darkMode ? 'border-gray-600' : 'border-gray-300'}`}>
                  <div className="space-y-3">
                    <input type="email" placeholder="Email" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                    <input type="password" placeholder="Password" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                    <button className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg font-semibold">
                      Sign In
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </FormSection>

        <FormSection title="🔓 Drag to Unlock">
          <div className="grid md:grid-cols-2 gap-6">
            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>Slide to Login</h3>
              <div 
                className="relative w-full h-16 bg-gradient-to-r from-gray-300 to-gray-200 dark:from-gray-700 dark:to-gray-600 rounded-full overflow-hidden mb-6 cursor-pointer"
                onMouseMove={handleDrag}
                onMouseUp={() => setIsDragging(false)}
              >
                <div 
                  className="absolute inset-0 bg-gradient-to-r from-green-500 to-emerald-500 transition-all duration-300"
                  style={{width: `${unlockProgress}%`}}
                ></div>
                <div 
                  className="absolute top-2 left-2 w-12 h-12 bg-white rounded-full shadow-lg flex items-center justify-center cursor-grab active:cursor-grabbing transition-all"
                  style={{left: `calc(${unlockProgress}% - 24px + 8px)`}}
                  onMouseDown={handleDragStart}
                >
                  {unlockProgress >= 100 ? (
                    <Unlock className="w-6 h-6 text-green-500" />
                  ) : (
                    <ChevronRight className="w-6 h-6 text-gray-500" />
                  )}
                </div>
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                  <span className={`font-semibold ${unlockProgress > 50 ? 'text-white' : txt2}`}>
                    {unlockProgress >= 100 ? 'Unlocked!' : 'Slide to unlock'}
                  </span>
                </div>
              </div>
              {unlockProgress >= 100 && (
                <div className="text-center space-y-3">
                  <input type="email" placeholder="Email" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-green-500`} />
                  <input type="password" placeholder="Password" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-green-500`} />
                  <button className="w-full px-6 py-2 bg-green-600 text-white rounded-lg font-bold hover:bg-green-700 transition-all">
                    Continue
                  </button>
                </div>
              )}
            </div>

            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>Pattern Lock</h3>
              <div className="grid grid-cols-3 gap-4 mb-6">
                {[1,2,3,4,5,6,7,8,9].map((i) => (
                  <button
                    key={i}
                    className={`aspect-square ${darkMode ? 'bg-gray-700' : 'bg-gray-200'} rounded-full hover:bg-blue-500 hover:scale-110 transition-all flex items-center justify-center font-bold text-xl ${txt}`}
                  >
                    {i}
                  </button>
                ))}
              </div>
              <p className={`text-center text-sm ${txt2}`}>Draw pattern to unlock</p>
            </div>
          </div>
        </FormSection>

        <FormSection title="🎬 Fullscreen & Video Background">
          <div className="grid md:grid-cols-2 gap-6">
            <div className="relative h-96 rounded-xl overflow-hidden shadow-2xl">
              <div className="absolute inset-0 bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 opacity-90"></div>
              
              <div className="relative h-full flex flex-col items-center justify-center p-8 text-white">
                <h3 className="text-4xl font-bold mb-4 text-center">Welcome</h3>
                <p className="text-lg mb-8 opacity-90 text-center">Sign in to continue</p>
                <div className="w-full max-w-sm space-y-4">
                  <input 
                    type="email" 
                    placeholder="Email" 
                    className="w-full px-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-white/50" 
                  />
                  <input 
                    type="password" 
                    placeholder="Password" 
                    className="w-full px-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-white/50" 
                  />
                  <button className="w-full px-6 py-3 bg-white text-purple-600 rounded-lg font-bold hover:bg-gray-100 transition-all">
                    Sign In
                  </button>
                </div>
              </div>
            </div>

            <div className="relative h-96 rounded-xl overflow-hidden shadow-2xl bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900">
              <div className="absolute inset-0 opacity-30">
                {[...Array(30)].map((_, i) => (
                  <div 
                    key={i}
                    className="absolute w-px h-20 bg-white"
                    style={{
                      left: `${Math.random() * 100}%`,
                      top: `${Math.random() * 100}%`,
                      animationDelay: `${Math.random() * 3}s`,
                      animation: 'float 3s infinite'
                    }}
                  />
                ))}
              </div>
              
              <div className="relative h-full flex flex-col items-center justify-center p-8 text-white">
                <div className="mb-6">
                  <Play className="w-16 h-16 text-white opacity-80" />
                </div>
                <h3 className="text-3xl font-bold mb-8 text-center">Immersive Login</h3>
                <div className="w-full max-w-sm space-y-4">
                  <input 
                    type="email" 
                    placeholder="Email" 
                    className="w-full px-4 py-3 bg-black/30 backdrop-blur-sm border-2 border-white/30 rounded-lg text-white placeholder-white/60 focus:outline-none focus:border-white/50" 
                  />
                  <input 
                    type="password" 
                    placeholder="Password" 
                    className="w-full px-4 py-3 bg-black/30 backdrop-blur-sm border-2 border-white/30 rounded-lg text-white placeholder-white/60 focus:outline-none focus:border-white/50" 
                  />
                  <button className="w-full px-6 py-3 bg-gradient-to-r from-pink-500 to-purple-500 text-white rounded-lg font-bold hover:from-pink-600 hover:to-purple-600 transition-all">
                    Enter
                  </button>
                </div>
              </div>
            </div>
          </div>
        </FormSection>

        {showModal && (
          <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50" onClick={() => setShowModal(false)}>
            <div className={`${card} rounded-2xl shadow-2xl max-w-md w-full p-8`} onClick={(e) => e.stopPropagation()}>
              <div className="flex justify-between items-center mb-6">
                <h3 className={`text-2xl font-bold ${txt}`}>Login</h3>
                <button onClick={() => setShowModal(false)} className={txt2}>
                  <X className="w-6 h-6" />
                </button>
              </div>
              <div className="space-y-4">
                <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                <button className="w-full px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg font-bold hover:from-blue-700 hover:to-purple-700 transition-all">
                  Sign In
                </button>
              </div>
            </div>
          </div>
        )}

        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>🎨 Partie 2/2 Complete - Biometric, Gaming Styles, Modal, Drag to Unlock, Fullscreen</p>
          <p className={`${txt2} text-sm mt-2`}>Collection V2 Ultra terminée avec 50+ styles avancés!</p>
        </div>
      </div>
    </div>
  );
}