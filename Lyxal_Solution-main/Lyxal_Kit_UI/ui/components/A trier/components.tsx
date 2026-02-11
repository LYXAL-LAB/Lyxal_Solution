import React, { useState, useEffect } from 'react';
import { 
  Sparkles, Zap, Rocket, Crown, Flame, Music, Code, Coffee,
  ChevronDown, Bell, ShoppingBag, Camera, Wifi, Bluetooth,
  Battery, Signal, TrendingUp, Activity, BarChart, Layers,
  Box, Package, Truck, MapPin, Navigation, Compass, Target, Heart
} from 'lucide-react';

interface Ripple {
  id: number;
  x: number;
  y: number;
}

interface ConfettiParticle {
  id: number;
  left: number;
  delay: number;
  duration: number;
  rotate: number;
  color: string;
}

interface BurstParticle {
  id: number;
  angle: number;
  distance: number;
}

export default function ButtonLibraryV2() {
  const [darkMode, setDarkMode] = useState(false);
  const [ripples, setRipples] = useState<Ripple[]>([]);
  const [progress, setProgress] = useState<Record<string, number>>({});
  const [countdown, setCountdown] = useState<Record<string, number>>({});
  const [expanded, setExpanded] = useState<Record<string, boolean | string>>({});
  const [confetti, setConfetti] = useState<ConfettiParticle[]>([]);
  const [burst, setBurst] = useState<BurstParticle[]>([]);
  const [glitching, setGlitching] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      setCountdown(prev => {
        const newState: Record<string, number> = {};
        Object.keys(prev).forEach(key => {
          newState[key] = prev[key] > 0 ? prev[key] - 1 : 0;
        });
        return newState;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const startCountdown = (id: string, e?: React.MouseEvent) => {
    e?.preventDefault();
    setCountdown({...countdown, [id]: 10});
  };

  const startProgress = (id: string, e?: React.MouseEvent) => {
    e?.preventDefault();
    setProgress({...progress, [id]: 0});
    const interval = setInterval(() => {
      setProgress(prev => {
        const val = (prev[id] || 0) + 10;
        if (val >= 100) {
          clearInterval(interval);
          return {...prev, [id]: 100};
        }
        return {...prev, [id]: val};
      });
    }, 200);
  };

  const handleRipple = (e: React.MouseEvent<HTMLButtonElement>, id: string) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    setRipples([...ripples, {id: Date.now(), x, y}]);
    setTimeout(() => setRipples(r => r.slice(1)), 600);
  };

  const launchConfetti = (e?: React.MouseEvent) => {
    e?.preventDefault();
    const particles = Array.from({length: 50}, (_, i) => ({
      id: Date.now() + i,
      left: 50 + (Math.random() - 0.5) * 30,
      delay: Math.random() * 0.3,
      duration: 1 + Math.random() * 0.5,
      rotate: Math.random() * 360,
      color: ['#ef4444', '#3b82f6', '#fbbf24', '#10b981', '#ec4899'][Math.floor(Math.random() * 5)]
    }));
    setConfetti(particles);
    setTimeout(() => setConfetti([]), 2000);
  };

  const launchBurst = (e?: React.MouseEvent) => {
    e?.preventDefault();
    const particles = Array.from({length: 12}, (_, i) => ({
      id: Date.now() + i,
      angle: (i * 30),
      distance: 80 + Math.random() * 40
    }));
    setBurst(particles);
    setTimeout(() => setBurst([]), 800);
  };

  const triggerGlitch = () => {
    setGlitching(true);
    setTimeout(() => setGlitching(false), 500);
  };

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';

  const ButtonSection = ({title, emoji, children}: {title: string; emoji: string; children: React.ReactNode}) => (
    <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
      <h2 className={`text-3xl font-bold ${txt} mb-8 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'} flex items-center gap-3`}>
        <span className="text-4xl">{emoji}</span>
        {title}
      </h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {children}
      </div>
    </div>
  );

  const ButtonDemo = ({children, label}: {children: React.ReactNode; label: string}) => (
    <div className="flex flex-col items-center gap-3 p-6 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700 transition-all">
      {children}
      <span className={`text-sm ${txt2} text-center font-medium`}>{label}</span>
    </div>
  );

  return (
    <div className={`min-h-screen ${bg} p-8 transition-colors`}>
      <style>{`
        @keyframes explode {
          to { transform: rotate(var(--rotate)) translateX(30px); opacity: 0; }
        }
        @keyframes confettiFall {
          0% { 
            transform: translateY(0) rotate(0deg); 
            opacity: 1; 
          }
          100% { 
            transform: translateY(300px) rotate(720deg); 
            opacity: 0; 
          }
        }
        @keyframes burstOut {
          0% { 
            transform: translate(0, 0) scale(1); 
            opacity: 1; 
          }
          100% { 
            transform: translate(var(--tx), var(--ty)) scale(0); 
            opacity: 0; 
          }
        }
        @keyframes glitchAnim {
          0%, 100% { transform: translate(0); }
          20% { transform: translate(-2px, 2px); }
          40% { transform: translate(2px, -2px); }
          60% { transform: translate(-2px, -2px); }
          80% { transform: translate(2px, 2px); }
        }
      `}</style>
      
      <div className="max-w-7xl mx-auto space-y-8">
        
        <div className={`${card} rounded-2xl p-10 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
          <div className="flex justify-between items-center">
            <div>
              <h1 className={`text-5xl font-bold ${txt} mb-3 bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent`}>
                Bibliothèque V2 - Effets Avancés
              </h1>
              <p className={`text-lg ${txt2}`}>Nouveaux styles ultra-modernes et interactions avancées</p>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-xl font-bold hover:from-purple-700 hover:to-pink-700 transition-all shadow-lg"
            >
              {darkMode ? '☀️ Mode Clair' : '🌙 Mode Sombre'}
            </button>
          </div>
        </div>

        <ButtonSection title="Bordures Animées" emoji="🌊">
          <ButtonDemo label="Border Spin">
            <button className="relative px-8 py-4 bg-gray-900 text-white rounded-xl font-bold overflow-hidden group">
              <span className="relative z-10">Border Spin</span>
              <div className="absolute inset-[-2px] rounded-xl bg-gradient-to-r from-purple-600 via-pink-600 to-blue-600 animate-spin" style={{animationDuration: '3s'}}></div>
              <div className="absolute inset-[2px] rounded-xl bg-gray-900"></div>
              <span className="relative z-10">Border Spin</span>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Glowing Border">
            <button className="px-8 py-4 bg-gray-900 text-white rounded-xl font-bold border-2 border-cyan-400 shadow-lg shadow-cyan-400/50 hover:shadow-cyan-400/80 hover:shadow-2xl transition-all animate-pulse">
              Glowing Border
            </button>
          </ButtonDemo>

          <ButtonDemo label="Neon Pulse">
            <button className="px-8 py-4 bg-purple-900 text-purple-200 rounded-xl font-bold border-2 border-purple-400 shadow-lg shadow-purple-400/50 hover:shadow-purple-400/80 transition-all">
              Neon Pulse
            </button>
          </ButtonDemo>

          <ButtonDemo label="Rainbow Border">
            <button className="px-8 py-4 bg-gradient-to-r from-red-500 via-yellow-500 via-green-500 via-blue-500 to-purple-500 text-white rounded-xl font-bold hover:scale-105 transition-all shadow-xl">
              Rainbow
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="Effets Ripple & Particules" emoji="💫">
          <ButtonDemo label="Material Ripple">
            <button 
              type="button"
              onClick={(e) => handleRipple(e, 'ripple1')}
              className="relative px-8 py-4 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-all overflow-hidden"
            >
              Ripple Effect
              {ripples.map(r => (
                <span
                  key={r.id}
                  className="absolute bg-white rounded-full opacity-50 animate-ping"
                  style={{
                    left: r.x,
                    top: r.y,
                    width: '20px',
                    height: '20px',
                    transform: 'translate(-50%, -50%)'
                  }}
                />
              ))}
            </button>
          </ButtonDemo>

          <ButtonDemo label="Sparkle Button">
            <button className="relative px-8 py-4 bg-gradient-to-r from-yellow-400 to-orange-500 text-white rounded-xl font-bold hover:from-yellow-500 hover:to-orange-600 transition-all shadow-lg group overflow-hidden">
              <Sparkles className="w-5 h-5 inline-block mr-2 animate-spin" style={{animationDuration: '3s'}} />
              Sparkle
              <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity">
                <div className="absolute top-1/4 left-1/4 w-2 h-2 bg-white rounded-full animate-ping"></div>
                <div className="absolute top-3/4 left-3/4 w-2 h-2 bg-white rounded-full animate-ping" style={{animationDelay: '0.3s'}}></div>
                <div className="absolute top-1/2 right-1/4 w-2 h-2 bg-white rounded-full animate-ping" style={{animationDelay: '0.6s'}}></div>
                <div className="absolute top-1/3 left-2/3 w-1.5 h-1.5 bg-yellow-200 rounded-full animate-ping" style={{animationDelay: '0.2s'}}></div>
                <div className="absolute top-2/3 left-1/3 w-1.5 h-1.5 bg-yellow-200 rounded-full animate-ping" style={{animationDelay: '0.5s'}}></div>
                <div className="absolute top-1/2 left-1/2 w-2 h-2 bg-white rounded-full animate-ping" style={{animationDelay: '0.4s'}}></div>
                <div className="absolute top-1/5 right-1/3 w-1 h-1 bg-yellow-100 rounded-full animate-ping" style={{animationDelay: '0.7s'}}></div>
                <div className="absolute bottom-1/4 right-1/4 w-1.5 h-1.5 bg-white rounded-full animate-ping" style={{animationDelay: '0.1s'}}></div>
              </div>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Particle Burst">
            <button 
              type="button"
              onClick={(e) => launchBurst(e)}
              className="relative px-8 py-4 bg-purple-600 text-white rounded-xl font-bold hover:bg-purple-700 transition-all group overflow-visible"
            >
              <Zap className="w-5 h-5 inline-block mr-2" />
              Burst
              {burst.map(p => (
                <div
                  key={p.id}
                  className="absolute top-1/2 left-1/2 w-3 h-3 bg-yellow-400 rounded-full"
                  style={{
                    animation: 'burstOut 0.8s ease-out forwards',
                    '--tx': `${Math.cos(p.angle * Math.PI / 180) * p.distance}px`,
                    '--ty': `${Math.sin(p.angle * Math.PI / 180) * p.distance}px`
                  } as React.CSSProperties}
                />
              ))}
            </button>
          </ButtonDemo>

          <ButtonDemo label="Confetti">
            <button 
              type="button"
              onClick={(e) => launchConfetti(e)}
              className="relative px-8 py-4 bg-gradient-to-r from-pink-500 to-purple-500 text-white rounded-xl font-bold hover:from-pink-600 hover:to-purple-600 transition-all shadow-lg overflow-visible"
            >
              🎉 Confetti
              {confetti.map(p => (
                <div
                  key={p.id}
                  className="absolute w-2 h-3 rounded-sm"
                  style={{
                    backgroundColor: p.color,
                    left: `${p.left}%`,
                    top: '50%',
                    animation: `confettiFall ${p.duration}s ease-in forwards`,
                    animationDelay: `${p.delay}s`,
                    transform: `rotate(${p.rotate}deg)`
                  }}
                />
              ))}
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="Effets Shine & Reflets" emoji="✨">
          <ButtonDemo label="Shine Sweep">
            <button className="relative px-8 py-4 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-bold overflow-hidden group">
              <span className="relative z-10">Shine Sweep</span>
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-0 group-hover:opacity-30 transform -skew-x-12 group-hover:translate-x-full transition-all duration-1000"></div>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Holographic">
            <button className="px-8 py-4 bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400 text-white rounded-xl font-bold shadow-2xl hover:shadow-3xl transition-all relative overflow-hidden group">
              <span className="relative z-10">Holographic</span>
              <div className="absolute inset-0 bg-gradient-to-r from-pink-400 via-yellow-400 to-cyan-400 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              <span className="relative z-10">Holographic</span>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Metallic">
            <button className="px-8 py-4 bg-gradient-to-br from-gray-300 via-gray-100 to-gray-300 text-gray-800 rounded-xl font-bold shadow-lg hover:shadow-2xl transition-all border border-gray-400">
              Metallic
            </button>
          </ButtonDemo>

          <ButtonDemo label="Chrome">
            <button className="px-8 py-4 bg-gradient-to-r from-gray-800 via-gray-600 to-gray-800 text-white rounded-xl font-bold shadow-2xl hover:shadow-3xl transition-all border-2 border-gray-500">
              Chrome
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="Morphing & Transformation" emoji="🔄">
          <ButtonDemo label="Expand Hover">
            <button className="px-6 py-3 bg-green-600 text-white rounded-lg font-bold hover:px-12 hover:rounded-2xl transition-all duration-300 shadow-lg hover:shadow-2xl">
              Expand Me
            </button>
          </ButtonDemo>

          <ButtonDemo label="Shape Morph">
            <button className="px-8 py-4 bg-blue-600 text-white rounded-full hover:rounded-lg font-bold transition-all duration-500 shadow-lg">
              Morph
            </button>
          </ButtonDemo>

          <ButtonDemo label="Split Button">
            <div className="relative group">
              <button className="flex items-center gap-2 px-6 py-3 bg-purple-600 text-white rounded-lg font-bold hover:bg-purple-700 transition-all">
                Action
                <ChevronDown className="w-5 h-5" />
              </button>
              <div className="absolute top-full mt-2 left-0 w-full opacity-0 group-hover:opacity-100 invisible group-hover:visible transition-all z-10">
                <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl border border-gray-200 dark:border-gray-700 py-2">
                  <button className="w-full px-4 py-2 text-left hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-900 dark:text-white">Option 1</button>
                  <button className="w-full px-4 py-2 text-left hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-900 dark:text-white">Option 2</button>
                </div>
              </div>
            </div>
          </ButtonDemo>

          <ButtonDemo label="Icon Transform">
            <button className="group px-8 py-4 bg-orange-600 text-white rounded-xl font-bold hover:bg-orange-700 transition-all">
              <Rocket className="inline-block w-5 h-5 mr-2 transition-transform group-hover:translate-y-[-4px] group-hover:rotate-[-15deg]" />
              Launch
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="Progress & Loading" emoji="⏳">
          <ButtonDemo label="Progress Bar">
            <button 
              type="button"
              onClick={(e) => startProgress('prog1', e)}
              className="relative px-8 py-4 bg-blue-600 text-white rounded-xl font-bold overflow-hidden hover:bg-blue-700 transition-all"
            >
              <span className="relative z-10">Start Progress</span>
              <div 
                className="absolute bottom-0 left-0 h-1 bg-white/50 transition-all duration-200"
                style={{width: `${progress.prog1 || 0}%`}}
              ></div>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Circular Progress">
            <button 
              type="button"
              onClick={(e) => startProgress('prog2', e)}
              className="relative px-8 py-4 bg-green-600 text-white rounded-full font-bold hover:bg-green-700 transition-all"
            >
              <span className="relative z-10">Loading</span>
              {progress.prog2 > 0 && (
                <svg className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full" style={{transform: 'translate(-50%, -50%) rotate(-90deg)'}}>
                  <circle
                    cx="50%"
                    cy="50%"
                    r="45%"
                    fill="none"
                    stroke="rgba(255,255,255,0.3)"
                    strokeWidth="3"
                  />
                  <circle
                    cx="50%"
                    cy="50%"
                    r="45%"
                    fill="none"
                    stroke="white"
                    strokeWidth="3"
                    strokeDasharray={`${2 * Math.PI * 45} ${2 * Math.PI * 45}`}
                    strokeDashoffset={`${2 * Math.PI * 45 * (1 - (progress.prog2 || 0) / 100)}`}
                    style={{transition: 'stroke-dashoffset 0.2s'}}
                  />
                </svg>
              )}
            </button>
          </ButtonDemo>

          <ButtonDemo label="Countdown">
            <button 
              type="button"
              onClick={(e) => startCountdown('count1', e)}
              className="px-8 py-4 bg-red-600 text-white rounded-xl font-bold hover:bg-red-700 transition-all shadow-lg"
            >
              {countdown.count1 > 0 ? `${countdown.count1}s` : 'Start Timer'}
            </button>
          </ButtonDemo>

          <ButtonDemo label="Pulse Loading">
            <button className="relative px-8 py-4 bg-purple-600 text-white rounded-xl font-bold hover:bg-purple-700 transition-all">
              Loading
              <span className="absolute top-2 right-2 w-3 h-3 bg-white rounded-full animate-ping"></span>
              <span className="absolute top-2 right-2 w-3 h-3 bg-white rounded-full"></span>
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="Styles Thématiques" emoji="🎨">
          <ButtonDemo label="Retro Gaming">
            <button className="px-8 py-4 bg-yellow-400 text-black rounded-none font-bold border-4 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] transition-all uppercase">
              Press Start
            </button>
          </ButtonDemo>

          <ButtonDemo label="Cyberpunk">
            <button className="relative px-8 py-4 bg-black text-cyan-400 rounded-none font-bold border-2 border-cyan-400 shadow-[0_0_10px_rgba(0,255,255,0.5)] hover:shadow-[0_0_20px_rgba(0,255,255,0.8)] transition-all uppercase tracking-wider">
              Cyberpunk
            </button>
          </ButtonDemo>

          <ButtonDemo label="Brutalist">
            <button className="px-8 py-4 bg-black text-white rounded-none font-black uppercase border-4 border-white hover:bg-white hover:text-black transition-all shadow-lg">
              Brutalist
            </button>
          </ButtonDemo>

          <ButtonDemo label="Neumorphism">
            <button className="px-8 py-4 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-2xl font-bold shadow-[8px_8px_16px_#b3b3b3,-8px_-8px_16px_#ffffff] dark:shadow-[8px_8px_16px_#1a1a1a,-8px_-8px_16px_#2a2a2a] hover:shadow-[4px_4px_8px_#b3b3b3,-4px_-4px_8px_#ffffff] transition-all">
              Soft UI
            </button>
          </ButtonDemo>

          <ButtonDemo label="Japanese">
            <button className="px-8 py-4 bg-white text-gray-900 rounded-sm font-light border border-gray-300 hover:border-gray-900 transition-all tracking-wide">
              禅 Zen
            </button>
          </ButtonDemo>

          <ButtonDemo label="Glitch">
            <button 
              onMouseEnter={triggerGlitch}
              className="relative px-8 py-4 bg-red-600 text-white rounded-lg font-bold overflow-hidden group"
            >
              <span className={`relative z-10 ${glitching ? 'inline-block' : ''}`} style={glitching ? {animation: 'glitchAnim 0.5s ease-in-out'} : {}}>
                Glitch
              </span>
              {glitching && (
                <>
                  <span className="absolute inset-0 flex items-center justify-center text-white opacity-80" style={{transform: 'translate(-2px, -2px)', color: '#00ffff'}}>
                    Glitch
                  </span>
                  <span className="absolute inset-0 flex items-center justify-center text-white opacity-80" style={{transform: 'translate(2px, 2px)', color: '#ff00ff'}}>
                    Glitch
                  </span>
                </>
              )}
            </button>
          </ButtonDemo>

          <ButtonDemo label="Vaporwave">
            <button className="px-8 py-4 bg-gradient-to-r from-pink-500 via-purple-500 to-cyan-500 text-white rounded-lg font-bold shadow-[0_0_20px_rgba(255,0,255,0.5)] hover:shadow-[0_0_30px_rgba(255,0,255,0.8)] transition-all uppercase tracking-widest">
              Aesthetic
            </button>
          </ButtonDemo>

          <ButtonDemo label="Premium Gold">
            <button className="px-8 py-4 bg-gradient-to-br from-yellow-400 via-yellow-500 to-yellow-600 text-gray-900 rounded-xl font-bold shadow-xl border-2 border-yellow-300 hover:shadow-2xl hover:scale-105 transition-all">
              <Crown className="inline-block w-5 h-5 mr-2" />
              Premium
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="Badges & Notifications" emoji="🔔">
          <ButtonDemo label="Badge Counter">
            <button className="relative px-8 py-4 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-all">
              <Bell className="inline-block w-5 h-5 mr-2" />
              Notifications
              <span className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold">
                9
              </span>
            </button>
          </ButtonDemo>

          <ButtonDemo label="New Badge">
            <button className="relative px-8 py-4 bg-green-600 text-white rounded-xl font-bold hover:bg-green-700 transition-all">
              Features
              <span className="absolute -top-2 -right-2 px-2 py-1 bg-yellow-400 text-gray-900 text-xs rounded-full font-bold">
                NEW
              </span>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Sale Badge">
            <button className="relative px-8 py-4 bg-purple-600 text-white rounded-xl font-bold hover:bg-purple-700 transition-all">
              <ShoppingBag className="inline-block w-5 h-5 mr-2" />
              Shop Now
              <span className="absolute -top-3 -right-3 px-3 py-1 bg-red-500 text-white text-sm rounded-lg font-bold transform rotate-12 shadow-lg">
                -50%
              </span>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Live Status">
            <button className="relative px-8 py-4 bg-gray-600 text-white rounded-xl font-bold hover:bg-gray-700 transition-all">
              <Activity className="inline-block w-5 h-5 mr-2" />
              Live
              <span className="absolute top-2 right-2 w-3 h-3 bg-green-400 rounded-full animate-pulse"></span>
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="Toggle & Switch" emoji="🎚️">
          <ButtonDemo label="Slider Toggle">
            <button 
              type="button"
              onClick={(e) => {
                e.preventDefault();
                setExpanded({...expanded, tog1: !expanded.tog1});
              }}
              className={`relative w-20 h-10 rounded-full transition-all ${expanded.tog1 ? 'bg-green-500' : 'bg-gray-300'}`}
            >
              <div className={`absolute top-1 w-8 h-8 bg-white rounded-full shadow-md transition-all ${expanded.tog1 ? 'left-11' : 'left-1'}`}></div>
            </button>
          </ButtonDemo>

          <ButtonDemo label="iOS Style">
            <button 
              type="button"
              onClick={(e) => {
                e.preventDefault();
                setExpanded({...expanded, tog2: !expanded.tog2});
              }}
              className={`relative w-16 h-8 rounded-full transition-all shadow-inner ${expanded.tog2 ? 'bg-blue-500' : 'bg-gray-300'}`}
            >
              <div className={`absolute top-0.5 w-7 h-7 bg-white rounded-full shadow-lg transition-all ${expanded.tog2 ? 'left-8' : 'left-0.5'}`}></div>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Icon Toggle">
            <button 
              type="button"
              onClick={(e) => {
                e.preventDefault();
                setExpanded({...expanded, tog3: !expanded.tog3});
              }}
              className={`px-6 py-3 rounded-xl font-bold transition-all ${expanded.tog3 ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-700'}`}
            >
              <Wifi className={`w-5 h-5 ${expanded.tog3 ? '' : 'opacity-30'}`} />
            </button>
          </ButtonDemo>

          <ButtonDemo label="Battery State">
            <button 
              type="button"
              onClick={(e) => {
                e.preventDefault();
                const states = ['low', 'medium', 'high'];
                const current = typeof expanded.tog4 === 'string' ? expanded.tog4 : 'low';
                const next = states[(states.indexOf(current) + 1) % 3];
                setExpanded({...expanded, tog4: next});
              }}
              className={`px-6 py-3 rounded-xl font-bold transition-all ${
                expanded.tog4 === 'high' ? 'bg-green-500 text-white' :
                expanded.tog4 === 'medium' ? 'bg-yellow-500 text-white' :
                'bg-red-500 text-white'
              }`}
            >
              <Battery className="w-5 h-5" />
            </button>
          </ButtonDemo>
        </ButtonSection>

        <ButtonSection title="E-commerce" emoji="🛍️">
          <ButtonDemo label="Add to Cart">
            <button className="flex items-center gap-3 px-8 py-4 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl font-bold hover:from-green-600 hover:to-emerald-700 transition-all shadow-lg hover:shadow-xl transform hover:scale-105">
              <ShoppingBag className="w-5 h-5" />
              <div className="text-left">
                <div className="text-xs opacity-80">Ajouter</div>
                <div>49.99€</div>
              </div>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Buy Now">
            <button className="relative px-8 py-4 bg-red-600 text-white rounded-xl font-bold hover:bg-red-700 transition-all overflow-hidden">
              <span className="relative z-10">Acheter</span>
            </button>
          </ButtonDemo>

          <ButtonDemo label="Quick View">
            <button className="flex items-center gap-2 px-6 py-3 bg-white dark:bg-gray-800 text-gray-900 dark:text-white border-2 border-gray-300 dark:border-gray-600 rounded-xl font-bold hover:border-blue-500 transition-all">
              <Camera className="w-5 h-5" />
              Aperçu
            </button>
          </ButtonDemo>

          <ButtonDemo label="Wishlist">
            <button 
              type="button"
              onClick={(e) => {
                e.preventDefault();
                setExpanded({...expanded, wish: !expanded.wish});
              }}
              className={`p-4 rounded-full font-bold transition-all ${
                expanded.wish ? 'bg-red-500 text-white scale-110' : 'bg-gray-200 text-gray-600'
              }`}
            >
              <Heart className={`w-6 h-6 ${expanded.wish ? 'fill-current' : ''}`} />
            </button>
          </ButtonDemo>
        </ButtonSection>

        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>🎨 Collection V2 avec 60+ nouveaux styles de boutons ultra-modernes</p>
          <p className={`${txt2} text-sm mt-2`}>Effets avancés • Animations complexes • Styles thématiques</p>
        </div>
      </div>
    </div>
  );
}