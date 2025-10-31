# 🔗 Intégration modules LyxalSuite

Guide complet pour intégrer les modules LyxalSuite (LyxalAuth, LyxalCRM, LyxalAnalytics, etc.) avec LyxalKitUI et DaisyUI 5.

## 🏗️ Architecture modulaire

### Vue d'ensemble
```
Application SaaS/
├── src/
│   ├── layouts/           # Layouts génériques (lyxalkitui)
│   ├── components/        # Composants DaisyUI partagés
│   ├── pages/
│   │   ├── auth/         # Pages LyxalAuth
│   │   ├── crm/          # Pages LyxalCRM
│   │   ├── analytics/    # Pages LyxalAnalytics
│   │   ├── dashboard/    # Pages LyxalDashboard
│   │   └── ai/           # Pages LyxalAI
│   ├── hooks/            # Hooks partagés
│   ├── utils/            # Utilitaires
│   └── theme/            # Configuration DaisyUI
```

### Principe de séparation
- **lyxalkitui** : Layouts, navigation, thèmes DaisyUI, composants génériques
- **Modules backend** : Logique métier, API, SDK
- **Pages spécifiques** : UI dédiée à chaque module dans l'application

## 🔐 Intégration LyxalAuth

### Installation
```bash
npm install @lyxal/auth @lyxal/ui-kit
```

### Configuration de base
```tsx
// src/providers/AuthProvider.tsx
import React, { createContext, useContext, useEffect, useState } from 'react';
import { LyxalAuth } from '@lyxal/auth';

interface AuthContextType {
  user: any | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
  permissions: string[];
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [permissions, setPermissions] = useState<string[]>([]);

  useEffect(() => {
    // Initialiser LyxalAuth
    LyxalAuth.init({
      apiUrl: process.env.VITE_LYXAL_AUTH_URL,
      clientId: process.env.VITE_LYXAL_CLIENT_ID
    });

    // Vérifier si l'utilisateur est connecté
    checkAuthStatus();
  }, []);

  const checkAuthStatus = async () => {
    try {
      const currentUser = await LyxalAuth.getCurrentUser();
      if (currentUser) {
        setUser(currentUser);
        setPermissions(currentUser.permissions || []);
      }
    } catch (error) {
      console.error('Erreur vérification auth:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const result = await LyxalAuth.login(email, password);
      setUser(result.user);
      setPermissions(result.user.permissions || []);
    } catch (error) {
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    await LyxalAuth.logout();
    setUser(null);
    setPermissions([]);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isLoading, permissions }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### Pages d'authentification avec DaisyUI
```tsx
// src/pages/auth/LoginPage.tsx
import React, { useState } from 'react';
import { useAuth } from '../../providers/AuthProvider';
import { useNavigate } from 'react-router-dom';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login, isLoading } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    try {
      await login(email, password);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Erreur de connexion');
    }
  };

  return (
    <div className="min-h-screen bg-base-200 flex items-center justify-center">
      <div className="card w-full max-w-md bg-base-100 shadow-xl">
        <div className="card-body">
          <h2 className="card-title justify-center text-2xl mb-6">
            🔐 Connexion
          </h2>

          {error && (
            <div className="alert alert-error mb-4">
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="form-control">
              <label className="label">
                <span className="label-text">Email</span>
              </label>
              <input
                type="email"
                className="input input-bordered"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="form-control">
              <label className="label">
                <span className="label-text">Mot de passe</span>
              </label>
              <input
                type="password"
                className="input input-bordered"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <label className="label">
                <a href="/forgot-password" className="label-text-alt link link-hover">
                  Mot de passe oublié ?
                </a>
              </label>
            </div>

            <div className="form-control mt-6">
              <button 
                type="submit" 
                className="btn btn-primary"
                disabled={isLoading}
              >
                {isLoading ? (
                  <>
                    <span className="loading loading-spinner loading-sm"></span>
                    Connexion...
                  </>
                ) : (
                  'Se connecter'
                )}
              </button>
            </div>
          </form>

          <div className="divider">OU</div>

          <div className="text-center">
            <p className="text-sm">
              Pas encore de compte ?{' '}
              <a href="/signup" className="link link-primary">
                S'inscrire
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
```

### Navigation avec permissions
```tsx
// src/components/Navigation.tsx
import React from 'react';
import { useAuth } from '../providers/AuthProvider';

export function Navigation() {
  const { user, logout, permissions } = useAuth();

  const hasPermission = (permission: string) => {
    return permissions.includes(permission) || permissions.includes('admin');
  };

  return (
    <div className="navbar bg-base-300">
      <div className="navbar-start">
        <div className="dropdown">
          <div tabIndex={0} role="button" className="btn btn-ghost lg:hidden">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h8m-8 6h16"></path>
            </svg>
          </div>
          <ul tabIndex={0} className="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
            <li><a href="/dashboard">📊 Dashboard</a></li>
            {hasPermission('crm:read') && (
              <li><a href="/crm">👥 CRM</a></li>
            )}
            {hasPermission('analytics:read') && (
              <li><a href="/analytics">📈 Analytics</a></li>
            )}
          </ul>
        </div>
        <a className="btn btn-ghost text-xl">LyxalSuite</a>
      </div>

      <div className="navbar-center hidden lg:flex">
        <ul className="menu menu-horizontal px-1">
          <li><a href="/dashboard">📊 Dashboard</a></li>
          {hasPermission('crm:read') && (
            <li><a href="/crm">👥 CRM</a></li>
          )}
          {hasPermission('analytics:read') && (
            <li><a href="/analytics">📈 Analytics</a></li>
          )}
        </ul>
      </div>

      <div className="navbar-end">
        <div className="dropdown dropdown-end">
          <div tabIndex={0} role="button" className="btn btn-ghost btn-circle avatar">
            <div className="w-10 rounded-full">
              <img alt="Avatar" src={user?.avatar || '/default-avatar.png'} />
            </div>
          </div>
          <ul tabIndex={0} className="mt-3 z-[1] p-2 shadow menu menu-sm dropdown-content bg-base-100 rounded-box w-52">
            <li>
              <a className="justify-between">
                Profil
                <span className="badge">Nouveau</span>
              </a>
            </li>
            <li><a>Paramètres</a></li>
            <li><button onClick={logout}>Déconnexion</button></li>
          </ul>
        </div>
      </div>
    </div>
  );
}
```

## 👥 Intégration LyxalCRM

### Configuration CRM
```tsx
// src/providers/CRMProvider.tsx
import React, { createContext, useContext } from 'react';
import { LyxalCRM } from '@lyxal/crm';
import { useAuth } from './AuthProvider';

interface CRMContextType {
  customers: any[];
  leads: any[];
  createCustomer: (data: any) => Promise<any>;
  updateCustomer: (id: string, data: any) => Promise<any>;
  deleteCustomer: (id: string) => Promise<void>;
}

const CRMContext = createContext<CRMContextType | undefined>(undefined);

export function CRMProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();

  // Initialiser LyxalCRM avec les credentials de l'utilisateur
  React.useEffect(() => {
    if (user) {
      LyxalCRM.init({
        apiUrl: process.env.VITE_LYXAL_CRM_URL,
        token: user.token
      });
    }
  }, [user]);

  const createCustomer = async (data: any) => {
    return await LyxalCRM.customers.create(data);
  };

  const updateCustomer = async (id: string, data: any) => {
    return await LyxalCRM.customers.update(id, data);
  };

  const deleteCustomer = async (id: string) => {
    await LyxalCRM.customers.delete(id);
  };

  // Valeurs mockées pour l'exemple
  const value = {
    customers: [],
    leads: [],
    createCustomer,
    updateCustomer,
    deleteCustomer
  };

  return (
    <CRMContext.Provider value={value}>
      {children}
    </CRMContext.Provider>
  );
}

export const useCRM = () => {
  const context = useContext(CRMContext);
  if (!context) {
    throw new Error('useCRM must be used within CRMProvider');
  }
  return context;
};
```

### Page CRM avec DaisyUI
```tsx
// src/pages/crm/CRMDashboard.tsx
import React, { useState } from 'react';
import { useCRM } from '../../providers/CRMProvider';

export function CRMDashboard() {
  const { customers, createCustomer } = useCRM();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newCustomer, setNewCustomer] = useState({
    name: '',
    email: '',
    phone: '',
    company: ''
  });

  const handleCreateCustomer = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await createCustomer(newCustomer);
      setIsModalOpen(false);
      setNewCustomer({ name: '', email: '', phone: '', company: '' });
    } catch (error) {
      console.error('Erreur création client:', error);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      
      {/* En-tête */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold">👥 CRM Dashboard</h1>
          <p className="text-base-content/70">Gestion de la relation client</p>
        </div>
        <button 
          className="btn btn-primary"
          onClick={() => setIsModalOpen(true)}
        >
          + Nouveau client
        </button>
      </div>

      {/* Stats */}
      <div className="stats shadow w-full mb-8">
        <div className="stat">
          <div className="stat-figure text-primary">
            <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <div className="stat-title">Total Clients</div>
          <div className="stat-value text-primary">1,247</div>
          <div className="stat-desc">+12% ce mois</div>
        </div>
        
        <div className="stat">
          <div className="stat-figure text-secondary">
            <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
              <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z"></path>
            </svg>
          </div>
          <div className="stat-title">Leads Actifs</div>
          <div className="stat-value text-secondary">89</div>
          <div className="stat-desc">+5 aujourd'hui</div>
        </div>
        
        <div className="stat">
          <div className="stat-figure text-accent">
            <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M4 4a2 2 0 00-2 2v4a2 2 0 002 2V6h10a2 2 0 00-2-2H4zm2 6a2 2 0 012-2h8a2 2 0 012 2v4a2 2 0 01-2 2H8a2 2 0 01-2-2v-4zm6 4a2 2 0 100-4 2 2 0 000 4z" clipRule="evenodd"></path>
            </svg>
          </div>
          <div className="stat-title">CA Mensuel</div>
          <div className="stat-value text-accent">€125K</div>
          <div className="stat-desc">+18% vs mois dernier</div>
        </div>
      </div>

      {/* Table des clients */}
      <div className="card bg-base-100 shadow-xl">
        <div className="card-body">
          <h2 className="card-title mb-4">Clients récents</h2>
          
          <div className="overflow-x-auto">
            <table className="table table-zebra">
              <thead>
                <tr>
                  <th>Nom</th>
                  <th>Email</th>
                  <th>Entreprise</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="avatar">
                        <div className="mask mask-squircle w-12 h-12">
                          <img src="/avatars/01.jpg" alt="Avatar" />
                        </div>
                      </div>
                      <div>
                        <div className="font-bold">Jean Dupont</div>
                        <div className="text-sm opacity-50">France</div>
                      </div>
                    </div>
                  </td>
                  <td>jean.dupont@email.com</td>
                  <td>TechCorp</td>
                  <td>
                    <div className="badge badge-success">Actif</div>
                  </td>
                  <td>
                    <div className="dropdown dropdown-end">
                      <div tabIndex={0} role="button" className="btn btn-ghost btn-xs">⋮</div>
                      <ul tabIndex={0} className="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                        <li><a>Voir détails</a></li>
                        <li><a>Modifier</a></li>
                        <li><a className="text-error">Supprimer</a></li>
                      </ul>
                    </div>
                  </td>
                </tr>
                {/* Plus de lignes... */}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Modal nouveau client */}
      {isModalOpen && (
        <dialog className="modal modal-open">
          <div className="modal-box">
            <h3 className="font-bold text-lg mb-4">Nouveau client</h3>
            
            <form onSubmit={handleCreateCustomer} className="space-y-4">
              <div className="form-control">
                <label className="label">
                  <span className="label-text">Nom complet</span>
                </label>
                <input
                  type="text"
                  className="input input-bordered"
                  value={newCustomer.name}
                  onChange={(e) => setNewCustomer(prev => ({ ...prev, name: e.target.value }))}
                  required
                />
              </div>

              <div className="form-control">
                <label className="label">
                  <span className="label-text">Email</span>
                </label>
                <input
                  type="email"
                  className="input input-bordered"
                  value={newCustomer.email}
                  onChange={(e) => setNewCustomer(prev => ({ ...prev, email: e.target.value }))}
                  required
                />
              </div>

              <div className="form-control">
                <label className="label">
                  <span className="label-text">Téléphone</span>
                </label>
                <input
                  type="tel"
                  className="input input-bordered"
                  value={newCustomer.phone}
                  onChange={(e) => setNewCustomer(prev => ({ ...prev, phone: e.target.value }))}
                />
              </div>

              <div className="form-control">
                <label className="label">
                  <span className="label-text">Entreprise</span>
                </label>
                <input
                  type="text"
                  className="input input-bordered"
                  value={newCustomer.company}
                  onChange={(e) => setNewCustomer(prev => ({ ...prev, company: e.target.value }))}
                />
              </div>

              <div className="modal-action">
                <button 
                  type="button" 
                  className="btn btn-outline"
                  onClick={() => setIsModalOpen(false)}
                >
                  Annuler
                </button>
                <button type="submit" className="btn btn-primary">
                  Créer
                </button>
              </div>
            </form>
          </div>
        </dialog>
      )}

    </div>
  );
}
```

## 📊 Intégration LyxalAnalytics

### Configuration Analytics
```tsx
// src/providers/AnalyticsProvider.tsx
import React, { createContext, useContext, useEffect, useState } from 'react';
import { LyxalAnalytics } from '@lyxal/analytics';
import { useAuth } from './AuthProvider';

interface AnalyticsContextType {
  metrics: any;
  charts: any;
  reports: any[];
  generateReport: (type: string, filters: any) => Promise<any>;
}

const AnalyticsContext = createContext<AnalyticsContextType | undefined>(undefined);

export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  const [metrics, setMetrics] = useState({});
  const [charts, setCharts] = useState({});
  const [reports, setReports] = useState([]);

  useEffect(() => {
    if (user) {
      LyxalAnalytics.init({
        apiUrl: process.env.VITE_LYXAL_ANALYTICS_URL,
        token: user.token
      });
      
      loadAnalytics();
    }
  }, [user]);

  const loadAnalytics = async () => {
    try {
      const [metricsData, chartsData, reportsData] = await Promise.all([
        LyxalAnalytics.getMetrics(),
        LyxalAnalytics.getCharts(),
        LyxalAnalytics.getReports()
      ]);
      
      setMetrics(metricsData);
      setCharts(chartsData);
      setReports(reportsData);
    } catch (error) {
      console.error('Erreur chargement analytics:', error);
    }
  };

  const generateReport = async (type: string, filters: any) => {
    return await LyxalAnalytics.generateReport(type, filters);
  };

  return (
    <AnalyticsContext.Provider value={{ metrics, charts, reports, generateReport }}>
      {children}
    </AnalyticsContext.Provider>
  );
}

export const useAnalytics = () => {
  const context = useContext(AnalyticsContext);
  if (!context) {
    throw new Error('useAnalytics must be used within AnalyticsProvider');
  }
  return context;
};
```

## 🤖 Intégration LyxalAI

### Configuration Agent IA
```tsx
// src/providers/AIProvider.tsx
import React, { createContext, useContext } from 'react';
import { LyxalAI } from '@lyxal/ai';
import { useAuth } from './AuthProvider';

interface AIContextType {
  generateSuggestions: (context: string) => Promise<string[]>;
  analyzeData: (data: any) => Promise<any>;
  chatWithAgent: (message: string) => Promise<string>;
}

const AIContext = createContext<AIContextType | undefined>(undefined);

export function AIProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();

  React.useEffect(() => {
    if (user) {
      LyxalAI.init({
        apiUrl: process.env.VITE_LYXAL_AI_URL,
        token: user.token
      });
    }
  }, [user]);

  const generateSuggestions = async (context: string) => {
    return await LyxalAI.suggestions.generate(context);
  };

  const analyzeData = async (data: any) => {
    return await LyxalAI.analysis.analyze(data);
  };

  const chatWithAgent = async (message: string) => {
    return await LyxalAI.chat.send(message);
  };

  return (
    <AIContext.Provider value={{ generateSuggestions, analyzeData, chatWithAgent }}>
      {children}
    </AIContext.Provider>
  );
}

export const useAI = () => {
  const context = useContext(AIContext);
  if (!context) {
    throw new Error('useAI must be used within AIProvider');
  }
  return context;
};
```

## 🔧 Configuration globale

### App.tsx avec tous les providers
```tsx
// src/App.tsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './providers/AuthProvider';
import { CRMProvider } from './providers/CRMProvider';
import { AnalyticsProvider } from './providers/AnalyticsProvider';
import { AIProvider } from './providers/AIProvider';
import { MainLayout } from './layouts/MainLayout';
import { LoginPage } from './pages/auth/LoginPage';
import { Dashboard } from './pages/Dashboard';
import { CRMDashboard } from './pages/crm/CRMDashboard';
import { AnalyticsDashboard } from './pages/analytics/AnalyticsDashboard';

function App() {
  return (
    <AuthProvider>
      <CRMProvider>
        <AnalyticsProvider>
          <AIProvider>
            <Router>
              <Routes>
                <Route path="/login" element={<LoginPage />} />
                <Route path="/" element={<MainLayout />}>
                  <Route index element={<Dashboard />} />
                  <Route path="dashboard" element={<Dashboard />} />
                  <Route path="crm" element={<CRMDashboard />} />
                  <Route path="analytics" element={<AnalyticsDashboard />} />
                </Route>
              </Routes>
            </Router>
          </AIProvider>
        </AnalyticsProvider>
      </CRMProvider>
    </AuthProvider>
  );
}

export default App;
```

### Variables d'environnement
```env
# .env
VITE_LYXAL_AUTH_URL=https://auth.lyxalsuite.com/api
VITE_LYXAL_CRM_URL=https://crm.lyxalsuite.com/api
VITE_LYXAL_ANALYTICS_URL=https://analytics.lyxalsuite.com/api
VITE_LYXAL_AI_URL=https://ai.lyxalsuite.com/api
VITE_LYXAL_CLIENT_ID=your-client-id
```

## 🎯 Bonnes pratiques

### 1. Gestion des erreurs
```tsx
// src/hooks/useErrorHandler.ts
import { useState } from 'react';

export function useErrorHandler() {
  const [error, setError] = useState<string | null>(null);

  const handleError = (err: any) => {
    const message = err.response?.data?.message || err.message || 'Une erreur est survenue';
    setError(message);
    
    // Log pour debugging
    console.error('Erreur:', err);
  };

  const clearError = () => setError(null);

  return { error, handleError, clearError };
}
```

### 2. Loading states
```tsx
// src/hooks/useLoading.ts
import { useState } from 'react';

export function useLoading() {
  const [isLoading, setIsLoading] = useState(false);

  const withLoading = async (fn: () => Promise<any>) => {
    setIsLoading(true);
    try {
      return await fn();
    } finally {
      setIsLoading(false);
    }
  };

  return { isLoading, withLoading };
}
```

### 3. Permissions granulaires
```tsx
// src/hooks/usePermissions.ts
import { useAuth } from '../providers/AuthProvider';

export function usePermissions() {
  const { permissions } = useAuth();

  const hasPermission = (permission: string) => {
    return permissions.includes(permission) || permissions.includes('admin');
  };

  const hasAnyPermission = (perms: string[]) => {
    return perms.some(p => hasPermission(p));
  };

  const hasAllPermissions = (perms: string[]) => {
    return perms.every(p => hasPermission(p));
  };

  return { hasPermission, hasAnyPermission, hasAllPermissions };
}
```

---

**🔗 Intégration modulaire LyxalSuite - Architecture scalable et maintenable**