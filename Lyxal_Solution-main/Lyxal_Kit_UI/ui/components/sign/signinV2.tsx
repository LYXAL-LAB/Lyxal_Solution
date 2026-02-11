import React, { useState } from 'react';
import { 
  Mail, Lock, User, ArrowRight, ArrowLeft, Check, Smartphone,
  Shield, Zap, Heart, Sparkles, Calendar, Briefcase, MapPin,
  Send, CheckCircle, XCircle, Loader, Key, QrCode, Fingerprint
} from 'lucide-react';

export default function SignInV2Part1() {
  const [darkMode, setDarkMode] = useState(false);
  const [step, setStep] = useState(1);
  const [activeTab, setActiveTab] = useState('signin');
  const [emailSent, setEmailSent] = useState(false);
  const [verified, setVerified] = useState(false);

  const bg = darkMode ? 'bg-gray-900' : 'bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50';
  const card = darkMode ? 'bg-gray-800' : 'bg-white';
  const txt = darkMode ? 'text-gray-100' : 'text-gray-900';
  const txt2 = darkMode ? 'text-gray-400' : 'text-gray-600';
  const input = darkMode ? 'bg-gray-700 border-gray-600 text-white' : 'bg-white border-gray-300 text-gray-900';

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
              <h1 className={`text-5xl font-bold ${txt} mb-3 bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent`}>
                Sign In/Up V2 Ultra - Partie 1
              </h1>
              <p className={`text-lg ${txt2}`}>Styles avancés avec animations et interactions complexes</p>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className="px-6 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white rounded-xl font-bold hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg"
            >
              {darkMode ? '☀️' : '🌙'}
            </button>
          </div>
        </div>

        <FormSection title="🎬 Split Screen Animé">
          <div className="grid lg:grid-cols-2 gap-8">
            <div className={`${card} rounded-xl shadow-2xl overflow-hidden`}>
              <div className="grid md:grid-cols-2 min-h-[500px]">
                <div className={`${activeTab === 'signin' ? 'order-1' : 'order-2'} transition-all duration-500 bg-gradient-to-br from-blue-600 to-purple-600 p-8 flex flex-col justify-center text-white`}>
                  <h2 className="text-3xl font-bold mb-4">
                    {activeTab === 'signin' ? 'Hello!' : 'Welcome!'}
                  </h2>
                  <p className="text-base mb-6 text-white/90">
                    {activeTab === 'signin' ? 'Start your journey' : 'Keep connected'}
                  </p>
                  <button
                    onClick={() => setActiveTab(activeTab === 'signin' ? 'signup' : 'signin')}
                    className="px-6 py-2 border-2 border-white rounded-full font-bold hover:bg-white hover:text-purple-600 transition-all"
                  >
                    {activeTab === 'signin' ? 'Sign Up' : 'Sign In'}
                  </button>
                </div>
                <div className={`${activeTab === 'signin' ? 'order-2' : 'order-1'} transition-all duration-500 p-8 flex flex-col justify-center`}>
                  <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>
                    {activeTab === 'signin' ? 'Sign In' : 'Sign Up'}
                  </h3>
                  <div className="space-y-3">
                    {activeTab === 'signup' && (
                      <input type="text" placeholder="Name" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
                    )}
                    <input type="email" placeholder="Email" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
                    <input type="password" placeholder="Password" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
                    <button className="w-full px-6 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg font-bold hover:from-blue-700 hover:to-purple-700 transition-all">
                      {activeTab === 'signin' ? 'Sign In' : 'Sign Up'}
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div className={`${card} rounded-xl shadow-2xl overflow-hidden`}>
              <div className="relative min-h-[500px]">
                <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 flex gap-2 z-10">
                  <button
                    onClick={() => setActiveTab('signin')}
                    className={`w-3 h-3 rounded-full transition-all ${activeTab === 'signin' ? 'bg-indigo-600 w-8' : 'bg-gray-300'}`}
                  />
                  <button
                    onClick={() => setActiveTab('signup')}
                    className={`w-3 h-3 rounded-full transition-all ${activeTab === 'signup' ? 'bg-purple-600 w-8' : 'bg-gray-300'}`}
                  />
                </div>
                <div className="h-full flex flex-col justify-center p-8">
                  <h3 className={`text-2xl font-bold ${txt} mb-6 text-center`}>
                    {activeTab === 'signin' ? 'Welcome Back' : 'Join Us'}
                  </h3>
                  <div className="space-y-3">
                    {activeTab === 'signup' && (
                      <input type="text" placeholder="Full Name" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} />
                    )}
                    <input type="email" placeholder="Email" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-indigo-500`} />
                    <input type="password" placeholder="Password" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-indigo-500`} />
                    <button className={`w-full px-6 py-2 ${activeTab === 'signin' ? 'bg-indigo-600 hover:bg-indigo-700' : 'bg-purple-600 hover:bg-purple-700'} text-white rounded-lg font-bold transition-all`}>
                      {activeTab === 'signin' ? 'Login' : 'Register'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </FormSection>

        <FormSection title="📋 Multi-Steps Onboarding">
          <div className="grid lg:grid-cols-2 gap-8">
            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <div className="flex justify-between mb-8">
                {[1, 2, 3, 4].map((s) => (
                  <div key={s} className="flex items-center">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold transition-all ${
                      step > s ? 'bg-green-500 text-white' : 
                      step === s ? 'bg-blue-600 text-white' : 
                      'bg-gray-200 text-gray-500'
                    }`}>
                      {step > s ? <Check className="w-5 h-5" /> : s}
                    </div>
                    {s < 4 && <div className={`w-12 h-1 mx-1 ${step > s ? 'bg-green-500' : 'bg-gray-200'}`} />}
                  </div>
                ))}
              </div>

              <div className="space-y-4">
                {step === 1 && (
                  <div className="space-y-3">
                    <h3 className={`text-xl font-bold ${txt} mb-3`}>Account Info</h3>
                    <input type="email" placeholder="Email" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                    <input type="password" placeholder="Password" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                    <input type="password" placeholder="Confirm" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                  </div>
                )}

                {step === 2 && (
                  <div className="space-y-3">
                    <h3 className={`text-xl font-bold ${txt} mb-3`}>Personal Details</h3>
                    <input type="text" placeholder="First Name" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                    <input type="text" placeholder="Last Name" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                    <input type="tel" placeholder="Phone" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                  </div>
                )}

                {step === 3 && (
                  <div className="space-y-3">
                    <h3 className={`text-xl font-bold ${txt} mb-3`}>Additional Info</h3>
                    <input type="date" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                    <select className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`}>
                      <option>Country</option>
                      <option>France</option>
                      <option>USA</option>
                    </select>
                    <input type="text" placeholder="City" className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} />
                  </div>
                )}

                {step === 4 && (
                  <div className="text-center py-6">
                    <div className="w-20 h-20 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-4 animate-bounce">
                      <Check className="w-10 h-10 text-white" />
                    </div>
                    <h3 className={`text-2xl font-bold ${txt} mb-2`}>All Set!</h3>
                    <p className={txt2}>Account created successfully</p>
                  </div>
                )}

                <div className="flex gap-3 mt-6">
                  {step > 1 && step < 4 && (
                    <button
                      onClick={() => setStep(step - 1)}
                      className="flex-1 px-4 py-2 border-2 border-gray-300 rounded-lg font-semibold hover:bg-gray-50 transition-all"
                    >
                      Back
                    </button>
                  )}
                  {step < 4 && (
                    <button
                      onClick={() => setStep(step + 1)}
                      className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all"
                    >
                      {step === 3 ? 'Finish' : 'Next'}
                    </button>
                  )}
                  {step === 4 && (
                    <button className="w-full px-4 py-2 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all">
                      Dashboard
                    </button>
                  )}
                </div>
              </div>
            </div>

            <div className={`${card} p-8 rounded-xl shadow-lg`}>
              <div className="mb-6">
                <div className="flex justify-between mb-2">
                  <span className={`text-sm font-medium ${txt2}`}>Progress</span>
                  <span className={`text-sm font-bold ${txt}`}>{Math.round((step / 4) * 100)}%</span>
                </div>
                <div className="w-full h-3 bg-gray-200 rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-gradient-to-r from-blue-600 to-purple-600 transition-all duration-500"
                    style={{width: `${(step / 4) * 100}%`}}
                  />
                </div>
              </div>

              <h3 className={`text-xl font-bold ${txt} mb-4`}>Steps</h3>
              
              <div className="space-y-3">
                {[
                  {icon: Mail, title: 'Account', desc: 'Email & password', num: 1},
                  {icon: User, title: 'Personal', desc: 'Name & contact', num: 2},
                  {icon: MapPin, title: 'Location', desc: 'Country & city', num: 3},
                  {icon: Sparkles, title: 'Complete', desc: 'All done!', num: 4}
                ].map((item) => {
                  const Icon = item.icon;
                  return (
                    <div key={item.num} className={`p-4 rounded-lg border-2 transition-all ${step >= item.num ? 'border-green-500 bg-green-50 dark:bg-green-900/20' : 'border-gray-300'}`}>
                      <div className="flex items-center gap-3">
                        <div className={`p-2 rounded-full ${step >= item.num ? 'bg-green-500' : 'bg-gray-300'}`}>
                          {step > item.num ? <Check className="w-5 h-5 text-white" /> : <Icon className="w-5 h-5 text-white" />}
                        </div>
                        <div>
                          <p className={`font-semibold ${txt}`}>{item.title}</p>
                          <p className={`text-sm ${txt2}`}>{item.desc}</p>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </FormSection>

        <FormSection title="✨ Magic Link & Passwordless">
          <div className="grid md:grid-cols-3 gap-6">
            <div className={`${card} p-6 rounded-xl shadow-lg`}>
              <div className="flex justify-center mb-4">
                <div className="p-3 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full">
                  <Zap className="w-6 h-6 text-white" />
                </div>
              </div>
              <h3 className={`text-xl font-bold ${txt} mb-2 text-center`}>Magic Link</h3>
              <p className={`text-sm ${txt2} mb-4 text-center`}>No password needed</p>
              
              {!emailSent ? (
                <div className="space-y-3">
                  <input 
                    type="email" 
                    placeholder="Email" 
                    className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-purple-500`} 
                  />
                  <button 
                    onClick={() => setEmailSent(true)}
                    className="w-full px-4 py-2 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition-all"
                  >
                    Send Link
                  </button>
                </div>
              ) : (
                <div className="text-center py-4">
                  <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-3 animate-bounce">
                    <CheckCircle className="w-8 h-8 text-white" />
                  </div>
                  <p className={`${txt} font-semibold mb-1`}>Check email!</p>
                  <p className={`text-sm ${txt2}`}>Link sent</p>
                  <button 
                    onClick={() => setEmailSent(false)}
                    className="mt-3 text-sm text-purple-600 hover:underline"
                  >
                    Resend
                  </button>
                </div>
              )}
            </div>

            <div className={`${card} p-6 rounded-xl shadow-lg`}>
              <div className="flex justify-center mb-4">
                <div className="p-3 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full">
                  <Smartphone className="w-6 h-6 text-white" />
                </div>
              </div>
              <h3 className={`text-xl font-bold ${txt} mb-2 text-center`}>SMS Code</h3>
              <p className={`text-sm ${txt2} mb-4 text-center`}>Login with phone</p>
              
              <div className="space-y-3">
                <input 
                  type="tel" 
                  placeholder="Phone" 
                  className={`w-full px-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} 
                />
                <div className="flex gap-1 justify-center">
                  {[1,2,3,4,5,6].map((i) => (
                    <input key={i} maxLength="1" className={`w-10 h-10 text-center ${input} rounded-lg border-2 focus:outline-none focus:border-blue-500 font-bold`} />
                  ))}
                </div>
                <button className="w-full px-4 py-2 bg-gradient-to-r from-blue-600 to-cyan-600 text-white rounded-lg font-semibold hover:from-blue-700 hover:to-cyan-700 transition-all">
                  Verify
                </button>
              </div>
            </div>

            <div className={`${card} p-6 rounded-xl shadow-lg`}>
              <div className="flex justify-center mb-4">
                <div className="p-3 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full">
                  <QrCode className="w-6 h-6 text-white" />
                </div>
              </div>
              <h3 className={`text-xl font-bold ${txt} mb-2 text-center`}>QR Login</h3>
              <p className={`text-sm ${txt2} mb-4 text-center`}>Scan to login</p>
              
              <div className="flex justify-center mb-4">
                <div className="p-3 bg-gray-100 dark:bg-gray-700 rounded-lg">
                  <div className="w-32 h-32 bg-white dark:bg-gray-600 rounded-lg flex items-center justify-center">
                    <QrCode className="w-24 h-24 text-gray-400" />
                  </div>
                </div>
              </div>
              
              <div className="space-y-2">
                {['Open app', 'Scan QR', 'Confirm'].map((text, i) => (
                  <div key={i} className="flex items-center gap-2">
                    <div className="w-5 h-5 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0">
                      <span className="text-white text-xs font-bold">{i + 1}</span>
                    </div>
                    <p className={`text-sm ${txt2}`}>{text}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </FormSection>

        <FormSection title="🔑 Password Recovery">
          <div className="grid md:grid-cols-3 gap-6">
            <div className={`${card} p-6 rounded-xl shadow-lg`}>
              <h3 className={`text-xl font-bold ${txt} mb-4`}>Reset Password</h3>
              <p className={`text-sm ${txt2} mb-4`}>Enter email to reset</p>
              <div className="space-y-3">
                <div className="relative">
                  <Mail className={`absolute left-3 top-2.5 w-5 h-5 ${txt2}`} />
                  <input 
                    type="email" 
                    placeholder="Email" 
                    className={`w-full pl-10 pr-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500`} 
                  />
                </div>
                <button className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all">
                  Send Link
                </button>
                <button className="w-full text-sm text-blue-600 hover:underline">
                  Back to Login
                </button>
              </div>
            </div>

            <div className={`${card} p-6 rounded-xl shadow-lg`}>
              <h3 className={`text-xl font-bold ${txt} mb-4`}>New Password</h3>
              <p className={`text-sm ${txt2} mb-4`}>Create new password</p>
              <div className="space-y-3">
                <div className="relative">
                  <Lock className={`absolute left-3 top-2.5 w-5 h-5 ${txt2}`} />
                  <input 
                    type="password" 
                    placeholder="Password" 
                    className={`w-full pl-10 pr-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-green-500`} 
                  />
                </div>
                <div className="relative">
                  <Lock className={`absolute left-3 top-2.5 w-5 h-5 ${txt2}`} />
                  <input 
                    type="password" 
                    placeholder="Confirm" 
                    className={`w-full pl-10 pr-4 py-2 ${input} rounded-lg border focus:outline-none focus:ring-2 focus:ring-green-500`} 
                  />
                </div>
                <button className="w-full px-4 py-2 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-all">
                  Reset Password
                </button>
              </div>
            </div>

            <div className={`${card} p-6 rounded-xl shadow-lg`}>
              <div className="flex justify-center mb-4">
                <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center animate-bounce">
                  <Check className="w-8 h-8 text-white" />
                </div>
              </div>
              <h3 className={`text-xl font-bold ${txt} mb-2 text-center`}>Success!</h3>
              <p className={`text-sm ${txt2} mb-6 text-center`}>Password changed successfully</p>
              <button className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-all">
                Login Now
              </button>
            </div>
          </div>
        </FormSection>

        <div className={`${card} rounded-xl p-6 shadow-lg text-center`}>
          <p className={txt2}>🎨 Partie 1/2 - Split Screen, Multi-Steps, Magic Link, QR Code, Password Recovery</p>
          <p className={`${txt2} text-sm mt-2`}>Partie 2 arrive avec: Biometric, Modal Login, Video Background, Gaming Styles...</p>
        </div>
      </div>
    </div>
  );
}