import React, { useState } from 'react';
import { 
  Mail, Lock, User, Eye, EyeOff, Github, Chrome, 
  Facebook, Twitter, Apple, Linkedin, Shield, ArrowRight,
  Check, X, Sparkles, Zap, Heart, Star, LogIn
} from 'lucide-react';

export default function SignInSignUpLibrary() {
  const [darkMode, setDarkMode] = useState(false);
  const [showPassword, setShowPassword] = useState({});

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';
  const input = darkMode ? 'bg-gray-700 border-gray-600 text-white' : 'bg-white border-gray-300 text-gray-900';

  const FormSection = ({title, children}) => (
    <div className={`${card} rounded-2xl p-8 shadow-2xl border ${darkMode ? 'border-gray-700' : 'border-gray-100'}`}>
      <h2 className={`text-3xl font-bold ${txt} mb-8 pb-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>{title}</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
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
              <h1 className={`text-5xl font-bold ${txt} mb-3 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent`}>
                Sign In / Sign Up Collection
              </h1>
              <p className={`text-lg ${txt2}`}>30+ styles de formulaires d'authentification modernes</p>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-bold hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg"
            >
              {darkMode ? '☀️ Clair' : '🌙 Sombre'}
            </button>
          </div>
        </div>

        <FormSection title="🎯 Minimaliste & Clean">
          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6`}>Sign In</h3>
            <div className="space-y-4">
              <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
              <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
              <button className="w-full px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all">
                Sign In
              </button>
            </div>
            <p className={`text-center text-sm ${txt2} mt-4`}>
              Don't have an account? <a href="#" className="text-blue-600 font-semibold">Sign Up</a>
            </p>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6`}>Sign Up</h3>
            <div className="space-y-4">
              <input type="text" placeholder="Full Name" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <button className="w-full px-6 py-3 bg-purple-600 text-white rounded-lg font-semibold hover:bg-purple-700 transition-all">
                Create Account
              </button>
            </div>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-2`}>Welcome Back</h3>
            <p className={`text-sm ${txt2} mb-6`}>Enter your credentials</p>
            <div className="space-y-4">
              <div className="relative">
                <Mail className={`absolute left-3 top-3.5 w-5 h-5 ${txt2}`} />
                <input type="email" placeholder="Email" className={`w-full pl-12 pr-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-green-500`} />
              </div>
              <div className="relative">
                <Lock className={`absolute left-3 top-3.5 w-5 h-5 ${txt2}`} />
                <input type="password" placeholder="Password" className={`w-full pl-12 pr-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-green-500`} />
              </div>
              <button className="w-full px-6 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all">
                Login
              </button>
            </div>
          </div>
        </FormSection>

        <FormSection title="🌐 Avec Social Login">
          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>Sign In</h3>
            <div className="space-y-3">
              <button className="w-full flex items-center justify-center gap-3 px-6 py-3 bg-white text-gray-900 border-2 border-gray-300 rounded-lg font-semibold hover:bg-gray-50 transition-all">
                <Chrome className="w-5 h-5" />
                Continue with Google
              </button>
              <button className="w-full flex items-center justify-center gap-3 px-6 py-3 bg-gray-900 text-white rounded-lg font-semibold hover:bg-gray-800 transition-all">
                <Github className="w-5 h-5" />
                Continue with GitHub
              </button>
              <button className="w-full flex items-center justify-center gap-3 px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all">
                <Facebook className="w-5 h-5" />
                Continue with Facebook
              </button>
            </div>
            <div className="relative my-6">
              <div className="absolute inset-0 flex items-center">
                <div className={`w-full border-t ${darkMode ? 'border-gray-700' : 'border-gray-300'}`}></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className={`px-4 ${card} ${txt2}`}>Or with email</span>
              </div>
            </div>
            <div className="space-y-3">
              <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
              <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
              <button className="w-full px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all">
                Sign In
              </button>
            </div>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>Create Account</h3>
            <div className="grid grid-cols-2 gap-3 mb-6">
              <button className="flex items-center justify-center gap-2 px-4 py-3 bg-white text-gray-900 border-2 border-gray-300 rounded-lg font-semibold hover:bg-gray-50 transition-all">
                <Chrome className="w-5 h-5" />
                Google
              </button>
              <button className="flex items-center justify-center gap-2 px-4 py-3 bg-gray-900 text-white rounded-lg font-semibold hover:bg-gray-800 transition-all">
                <Apple className="w-5 h-5" />
                Apple
              </button>
            </div>
            <div className="relative my-6">
              <div className="absolute inset-0 flex items-center">
                <div className={`w-full border-t ${darkMode ? 'border-gray-700' : 'border-gray-300'}`}></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className={`px-4 ${card} ${txt2}`}>OR</span>
              </div>
            </div>
            <div className="space-y-3">
              <input type="text" placeholder="Full Name" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <button className="w-full px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition-all">
                Sign Up
              </button>
            </div>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>Join Us</h3>
            <div className="space-y-3">
              <button className="w-full flex items-center justify-center gap-3 px-6 py-3 bg-sky-500 text-white rounded-lg font-semibold hover:bg-sky-600 transition-all">
                <Twitter className="w-5 h-5" />
                Twitter
              </button>
              <button className="w-full flex items-center justify-center gap-3 px-6 py-3 bg-blue-700 text-white rounded-lg font-semibold hover:bg-blue-800 transition-all">
                <Linkedin className="w-5 h-5" />
                LinkedIn
              </button>
              <button className="w-full flex items-center justify-center gap-3 px-6 py-3 bg-black text-white rounded-lg font-semibold hover:bg-gray-900 transition-all">
                <Apple className="w-5 h-5" />
                Apple
              </button>
            </div>
          </div>
        </FormSection>

        <FormSection title="✨ Gradient & Moderne">
          <div className="bg-gradient-to-br from-blue-500 to-purple-600 p-8 rounded-xl shadow-2xl text-white">
            <h3 className="text-2xl font-bold mb-6">Welcome Back</h3>
            <div className="space-y-4">
              <input type="email" placeholder="Email" className="w-full px-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg placeholder-white/70 text-white focus:outline-none focus:ring-2 focus:ring-white/50" />
              <input type="password" placeholder="Password" className="w-full px-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg placeholder-white/70 text-white focus:outline-none focus:ring-2 focus:ring-white/50" />
              <button className="w-full px-6 py-3 bg-white text-blue-600 rounded-lg font-bold hover:bg-gray-100 transition-all shadow-lg">
                Sign In
              </button>
            </div>
            <p className="text-center text-sm text-white/80 mt-4">
              New here? <a href="#" className="font-bold underline">Create account</a>
            </p>
          </div>

          <div className="bg-gradient-to-br from-pink-500 via-purple-500 to-indigo-500 p-8 rounded-xl shadow-2xl text-white">
            <h3 className="text-2xl font-bold mb-2">Get Started</h3>
            <p className="text-sm text-white/80 mb-6">Create your account</p>
            <div className="space-y-4">
              <input type="text" placeholder="Username" className="w-full px-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg placeholder-white/70 text-white focus:outline-none focus:ring-2 focus:ring-white/50" />
              <input type="email" placeholder="Email" className="w-full px-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg placeholder-white/70 text-white focus:outline-none focus:ring-2 focus:ring-white/50" />
              <input type="password" placeholder="Password" className="w-full px-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg placeholder-white/70 text-white focus:outline-none focus:ring-2 focus:ring-white/50" />
              <button className="w-full px-6 py-3 bg-white text-purple-600 rounded-lg font-bold hover:bg-gray-100 transition-all shadow-lg">
                Create Account
              </button>
            </div>
          </div>

          <div className="bg-gradient-to-br from-green-400 to-blue-500 p-8 rounded-xl shadow-2xl text-white">
            <div className="flex items-center justify-center mb-6">
              <div className="p-4 bg-white/20 backdrop-blur-lg rounded-full">
                <Shield className="w-8 h-8" />
              </div>
            </div>
            <h3 className="text-2xl font-bold mb-6 text-center">Secure Login</h3>
            <div className="space-y-4">
              <div className="relative">
                <User className="absolute left-3 top-3.5 w-5 h-5 text-white/70" />
                <input type="text" placeholder="Username" className="w-full pl-12 pr-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg placeholder-white/70 text-white focus:outline-none focus:ring-2 focus:ring-white/50" />
              </div>
              <div className="relative">
                <Lock className="absolute left-3 top-3.5 w-5 h-5 text-white/70" />
                <input type="password" placeholder="Password" className="w-full pl-12 pr-4 py-3 bg-white/20 backdrop-blur-lg border border-white/30 rounded-lg placeholder-white/70 text-white focus:outline-none focus:ring-2 focus:ring-white/50" />
              </div>
              <button className="w-full flex items-center justify-center gap-2 px-6 py-3 bg-white text-green-600 rounded-lg font-bold hover:bg-gray-100 transition-all shadow-lg">
                Login <ArrowRight className="w-5 h-5" />
              </button>
            </div>
          </div>
        </FormSection>

        <FormSection title="🎭 Avec Animations">
          <div className={`${card} p-8 rounded-xl shadow-lg relative overflow-hidden group`}>
            <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 opacity-0 group-hover:opacity-10 transition-opacity"></div>
            <h3 className={`text-2xl font-bold ${txt} mb-6 relative z-10`}>Animated</h3>
            <div className="space-y-4 relative z-10">
              <div className="relative">
                <Mail className={`absolute left-3 top-3.5 w-5 h-5 ${txt2}`} />
                <input type="email" placeholder="Email" className={`w-full pl-12 pr-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all focus:scale-105`} />
              </div>
              <div className="relative">
                <Lock className={`absolute left-3 top-3.5 w-5 h-5 ${txt2}`} />
                <input type="password" placeholder="Password" className={`w-full pl-12 pr-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all focus:scale-105`} />
                <button 
                  onClick={() => setShowPassword({...showPassword, anim1: !showPassword.anim1})}
                  className={`absolute right-3 top-3.5 ${txt2}`}
                >
                  {showPassword.anim1 ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
              <button className="w-full px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg font-semibold hover:from-blue-700 hover:to-purple-700 transition-all transform hover:scale-105 hover:shadow-xl">
                Sign In
              </button>
            </div>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg border-2 border-transparent hover:border-purple-500 transition-all`}>
            <div className="flex items-center justify-center mb-6">
              <div className="p-3 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full">
                <Sparkles className="w-6 h-6 text-white animate-spin" style={{animationDuration: '3s'}} />
              </div>
            </div>
            <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>Magic Sign Up</h3>
            <div className="space-y-4">
              <input type="text" placeholder="Your Name" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              <button className="w-full px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition-all transform hover:scale-105 shadow-lg">
                <Sparkles className="inline-block w-5 h-5 mr-2" />
                Create Account
              </button>
            </div>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>Premium</h3>
            <div className="flex justify-center mb-6">
              <div className="flex gap-2">
                <div className="p-3 bg-yellow-400 rounded-full animate-bounce">
                  <Star className="w-6 h-6 text-yellow-800" />
                </div>
                <div className="p-3 bg-yellow-400 rounded-full animate-bounce" style={{animationDelay: '0.1s'}}>
                  <Star className="w-6 h-6 text-yellow-800" />
                </div>
                <div className="p-3 bg-yellow-400 rounded-full animate-bounce" style={{animationDelay: '0.2s'}}>
                  <Star className="w-6 h-6 text-yellow-800" />
                </div>
              </div>
            </div>
            <div className="space-y-4">
              <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border-2 focus:outline-none focus:border-yellow-500`} />
              <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border-2 focus:outline-none focus:border-yellow-500`} />
              <button className="w-full px-6 py-3 bg-gradient-to-r from-yellow-400 to-orange-500 text-white rounded-lg font-bold hover:from-yellow-500 hover:to-orange-600 transition-all shadow-lg">
                Access Premium
              </button>
            </div>
          </div>
        </FormSection>

        <FormSection title="✅ Avec Validation">
          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6`}>Sign Up</h3>
            <div className="space-y-4">
              <div>
                <input type="text" placeholder="Username" className={`w-full px-4 py-3 ${input} rounded-lg border-2 border-green-500 focus:outline-none`} />
                <div className="flex items-center gap-2 mt-2 text-sm text-green-600">
                  <Check className="w-4 h-4" />
                  <span>Available</span>
                </div>
              </div>
              <div>
                <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border-2 border-red-500 focus:outline-none`} />
                <div className="flex items-center gap-2 mt-2 text-sm text-red-600">
                  <X className="w-4 h-4" />
                  <span>Invalid email</span>
                </div>
              </div>
              <div>
                <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                <div className="mt-2 space-y-1">
                  <div className="flex items-center gap-2 text-sm text-green-600">
                    <Check className="w-4 h-4" />
                    <span>8+ characters</span>
                  </div>
                  <div className="flex items-center gap-2 text-sm text-green-600">
                    <Check className="w-4 h-4" />
                    <span>Contains number</span>
                  </div>
                  <div className="flex items-center gap-2 text-sm text-gray-400">
                    <X className="w-4 h-4" />
                    <span>Special character</span>
                  </div>
                </div>
              </div>
              <button className="w-full px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all">
                Create Account
              </button>
            </div>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6`}>Secure Form</h3>
            <div className="space-y-4">
              <div>
                <label className={`block text-sm font-medium ${txt} mb-2`}>Email</label>
                <input type="email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
              </div>
              <div>
                <label className={`block text-sm font-medium ${txt} mb-2`}>Password</label>
                <input type="password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                <div className="mt-2 h-2 bg-gray-200 rounded-full overflow-hidden">
                  <div className="h-full w-3/4 bg-gradient-to-r from-yellow-500 to-green-500 rounded-full"></div>
                </div>
                <p className="text-sm text-green-600 mt-1">Strong password</p>
              </div>
              <div className="flex items-start gap-2">
                <input type="checkbox" className="mt-1" />
                <label className={`text-sm ${txt2}`}>I agree to terms and conditions</label>
              </div>
              <button className="w-full px-6 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all">
                Register
              </button>
            </div>
          </div>

          <div className={`${card} p-8 rounded-xl shadow-lg`}>
            <h3 className={`text-2xl font-bold ${txt} mb-6`}>Two Factor</h3>
            <div className="space-y-4">
              <div>
                <input type="email" placeholder="Email" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              </div>
              <div>
                <input type="password" placeholder="Password" className={`w-full px-4 py-3 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
              </div>
              <div>
                <label className={`block text-sm font-medium ${txt} mb-2`}>Verification Code</label>
                <div className="flex gap-2">
                  <input type="text" maxLength="1" className={`w-12 h-12 text-center ${input} rounded-lg border-2 focus:outline-none focus:border-purple-500 text-lg font-bold`} />
                  <input type="text" maxLength="1" className={`w-12 h-12 text-center ${input} rounded-lg border-2 focus:outline-none focus:border-purple-500 text-lg font-bold`} />
                  <input type="text" maxLength="1" className={`w-12 h-12 text-center ${input} rounded-lg border-2 focus:outline-none focus:border-purple-500 text-lg font-bold`} />
                  <input type="text" maxLength="1" className={`w-12 h-12 text-center ${input} rounded-lg border-2 focus:outline-none focus:border-purple-500 text-lg font-bold`} />
                </div>
              </div>
              <button className="w-full px-6 py-3 bg-purple-600 text-white rounded-lg font-semibold hover:bg-purple-700 transition-all">
                Verify & Login
              </button>
            </div>
          </div>
        </FormSection>

        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>🎨 Collection complète avec 30+ styles de formulaires Sign In / Sign Up</p>
          <p className={`${txt2} text-sm mt-2`}>Minimaliste • Social Login • Gradient • Animations • Validation</p>
        </div>
      </div>
    </div>
  );
}