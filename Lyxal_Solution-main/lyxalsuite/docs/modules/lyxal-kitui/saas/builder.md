# 🚀 Générateur SaaS Automatique

Le **SaaS Builder** de LyxalKitUI permet de créer automatiquement des applications SaaS complètes en quelques clics, avec génération de builds individuels et déploiement en marque blanche.

## 🎯 Vue d'ensemble

### Concept
Le SaaS Builder transforme une configuration simple en application SaaS complète :
- **Interface wizard** intuitive
- **Sélection modules** LyxalSuite (Auth, CRM, Analytics, etc.)
- **Thème optimal** selon l'industrie
- **Build individuel** pour chaque SaaS
- **Déploiement marque blanche** avec domaine personnalisé

### Architecture générée
```
Generated-SaaS/
├── src/
│   ├── layouts/           # Layouts depuis lyxalkitui
│   ├── components/        # Composants DaisyUI
│   ├── pages/
│   │   ├── auth/         # Pages LyxalAuth
│   │   ├── crm/          # Pages LyxalCRM (si sélectionné)
│   │   ├── analytics/    # Pages LyxalAnalytics (si sélectionné)
│   │   └── dashboard/    # Dashboard principal
│   ├── theme/
│   │   └── globals.css   # DaisyUI + thème sélectionné
│   └── config/
│       └── saas.config.ts # Configuration SaaS
├── package.json          # Dépendances spécifiques
├── vite.config.ts        # Build configuration
└── README.md             # Documentation SaaS
```

## 🛠️ Interface SaaS Builder

### Composant principal
```tsx
import React, { useState, useEffect } from 'react';
import { SaasThemeGenerator } from './SaasThemeGenerator';
import { SaasAIAgent } from './SaasAIAgent';

interface SaasConfig {
  name: string;
  industry: string;
  style: 'professional' | 'modern' | 'creative';
  theme: string;
  modules: string[];
  domain?: string;
  branding: {
    logo?: string;
    primaryColor?: string;
    companyName: string;
  };
}

function SaasBuilder() {
  const [step, setStep] = useState(1);
  const [config, setConfig] = useState<SaasConfig>({
    name: '',
    industry: '',
    style: 'modern',
    theme: 'light',
    modules: ['auth'],
    branding: {
      companyName: ''
    }
  });
  const [isGenerating, setIsGenerating] = useState(false);
  const [aiPrompt, setAiPrompt] = useState('');

  // Auto-sélection du thème optimal
  useEffect(() => {
    if (config.industry) {
      const optimalTheme = SaasThemeGenerator.getOptimalTheme(config.industry, config.style);
      setConfig(prev => ({ ...prev, theme: optimalTheme }));
    }
  }, [config.industry, config.style]);

  const handleAIGeneration = async () => {
    if (!aiPrompt.trim()) return;
    
    setIsGenerating(true);
    try {
      const aiConfig = await SaasAIAgent.generateFromPrompt(aiPrompt);
      setConfig(prev => ({ ...prev, ...aiConfig }));
      setStep(2); // Passer à la validation
    } catch (error) {
      console.error('Erreur génération IA:', error);
    } finally {
      setIsGenerating(false);
    }
  };

  const handleGenerate = async () => {
    setIsGenerating(true);
    try {
      // Appel API pour générer le SaaS
      const response = await fetch('/api/saas/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(config)
      });
      
      const result = await response.json();
      
      if (result.success) {
        // Rediriger vers le SaaS généré
        window.open(result.url, '_blank');
      }
    } catch (error) {
      console.error('Erreur génération SaaS:', error);
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="min-h-screen bg-base-100">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          
          {/* En-tête */}
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold mb-4">
              🚀 Générateur SaaS
            </h1>
            <p className="text-lg text-base-content/70">
              Créez votre application SaaS en quelques minutes
            </p>
            <div className="flex justify-center mt-4">
              <div className="stats shadow">
                <div className="stat">
                  <div className="stat-title">SaaS générés</div>
                  <div className="stat-value text-primary">1,247</div>
                </div>
                <div className="stat">
                  <div className="stat-title">Modules disponibles</div>
                  <div className="stat-value text-secondary">6</div>
                </div>
                <div className="stat">
                  <div className="stat-title">Thèmes DaisyUI</div>
                  <div className="stat-value text-accent">35</div>
                </div>
              </div>
            </div>
          </div>

          {/* Steps indicator */}
          <div className="steps w-full mb-8">
            <div className={`step ${step >= 1 ? 'step-primary' : ''}`}>
              Configuration
            </div>
            <div className={`step ${step >= 2 ? 'step-primary' : ''}`}>
              Validation
            </div>
            <div className={`step ${step >= 3 ? 'step-primary' : ''}`}>
              Génération
            </div>
            <div className={`step ${step >= 4 ? 'step-primary' : ''}`}>
              Déploiement
            </div>
          </div>

          {/* Étape 1: Configuration */}
          {step === 1 && (
            <div className="card bg-base-200 shadow-xl">
              <div className="card-body">
                <h2 className="card-title mb-6">
                  ⚙️ Configuration du SaaS
                </h2>

                {/* Génération IA */}
                <div className="alert alert-info mb-6">
                  <div className="flex-1">
                    <h3 className="font-bold">🤖 Génération par IA</h3>
                    <p className="text-sm">Décrivez votre SaaS en langage naturel</p>
                  </div>
                </div>

                <div className="form-control mb-4">
                  <label className="label">
                    <span className="label-text">Prompt IA (optionnel)</span>
                  </label>
                  <textarea
                    className="textarea textarea-bordered h-24"
                    placeholder="Ex: Je veux créer un SaaS de gestion de restaurants avec thème sombre et fonctionnalités de commande en ligne"
                    value={aiPrompt}
                    onChange={(e) => setAiPrompt(e.target.value)}
                  />
                  <div className="label">
                    <span className="label-text-alt">L'IA configurera automatiquement votre SaaS</span>
                  </div>
                </div>

                <button 
                  className="btn btn-secondary mb-6"
                  onClick={handleAIGeneration}
                  disabled={!aiPrompt.trim() || isGenerating}
                >
                  {isGenerating ? (
                    <>
                      <span className="loading loading-spinner loading-sm"></span>
                      Génération IA...
                    </>
                  ) : (
                    '🤖 Générer avec IA'
                  )}
                </button>

                <div className="divider">OU configuration manuelle</div>

                {/* Configuration manuelle */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  
                  {/* Informations de base */}
                  <div className="space-y-4">
                    <h3 className="text-lg font-semibold">Informations de base</h3>
                    
                    <div className="form-control">
                      <label className="label">
                        <span className="label-text">Nom du SaaS *</span>
                      </label>
                      <input
                        type="text"
                        className="input input-bordered"
                        placeholder="MonSaaS"
                        value={config.name}
                        onChange={(e) => setConfig(prev => ({ ...prev, name: e.target.value }))}
                      />
                    </div>

                    <div className="form-control">
                      <label className="label">
                        <span className="label-text">Nom de l'entreprise *</span>
                      </label>
                      <input
                        type="text"
                        className="input input-bordered"
                        placeholder="Mon Entreprise"
                        value={config.branding.companyName}
                        onChange={(e) => setConfig(prev => ({ 
                          ...prev, 
                          branding: { ...prev.branding, companyName: e.target.value }
                        }))}
                      />
                    </div>

                    <div className="form-control">
                      <label className="label">
                        <span className="label-text">Secteur d'activité *</span>
                      </label>
                      <select
                        className="select select-bordered"
                        value={config.industry}
                        onChange={(e) => setConfig(prev => ({ ...prev, industry: e.target.value }))}
                      >
                        <option value="">Choisir un secteur</option>
                        <option value="finance">💰 Finance & Banque</option>
                        <option value="healthcare">🏥 Santé & Médical</option>
                        <option value="technology">💻 Technologie & IT</option>
                        <option value="ecommerce">🛒 E-commerce & Retail</option>
                        <option value="education">📚 Éducation & Formation</option>
                        <option value="restaurant">🍽️ Restauration & Hôtellerie</option>
                        <option value="fitness">💪 Sport & Fitness</option>
                        <option value="creative">🎨 Créatif & Design</option>
                        <option value="legal">⚖️ Juridique & Conseil</option>
                        <option value="real_estate">🏠 Immobilier</option>
                      </select>
                    </div>

                    <div className="form-control">
                      <label className="label">
                        <span className="label-text">Style d'interface</span>
                      </label>
                      <div className="flex gap-2">
                        {['professional', 'modern', 'creative'].map(style => (
                          <button
                            key={style}
                            className={`btn btn-sm ${config.style === style ? 'btn-primary' : 'btn-outline'}`}
                            onClick={() => setConfig(prev => ({ ...prev, style: style as any }))}
                          >
                            {style === 'professional' && '💼'}
                            {style === 'modern' && '✨'}
                            {style === 'creative' && '🎨'}
                            {' '}
                            {style}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Modules et thème */}
                  <div className="space-y-4">
                    <h3 className="text-lg font-semibold">Modules & Apparence</h3>
                    
                    <div className="form-control">
                      <label className="label">
                        <span className="label-text">Modules LyxalSuite</span>
                      </label>
                      <div className="space-y-2">
                        {[
                          { id: 'auth', name: '🔐 LyxalAuth', desc: 'Authentification & autorisation' },
                          { id: 'crm', name: '👥 LyxalCRM', desc: 'Gestion relation client' },
                          { id: 'analytics', name: '📊 LyxalAnalytics', desc: 'Analytics & reporting' },
                          { id: 'dashboard', name: '📈 LyxalDashboard', desc: 'Tableaux de bord' },
                          { id: 'ai', name: '🤖 LyxalAI', desc: 'Agent IA & automatisation' },
                          { id: 'ecommerce', name: '🛒 LyxalEcommerce', desc: 'E-commerce (bientôt)' }
                        ].map(module => (
                          <label key={module.id} className="label cursor-pointer justify-start gap-3">
                            <input
                              type="checkbox"
                              className="checkbox checkbox-primary"
                              checked={config.modules.includes(module.id)}
                              onChange={(e) => {
                                if (e.target.checked) {
                                  setConfig(prev => ({ 
                                    ...prev, 
                                    modules: [...prev.modules, module.id] 
                                  }));
                                } else {
                                  setConfig(prev => ({ 
                                    ...prev, 
                                    modules: prev.modules.filter(m => m !== module.id) 
                                  }));
                                }
                              }}
                              disabled={module.id === 'ecommerce'}
                            />
                            <div>
                              <span className="label-text font-medium">{module.name}</span>
                              <div className="text-xs text-base-content/70">{module.desc}</div>
                            </div>
                          </label>
                        ))}
                      </div>
                    </div>

                    {/* Thème recommandé */}
                    {config.industry && (
                      <div className="alert alert-success">
                        <div>
                          <h4 className="font-bold">🎨 Thème recommandé</h4>
                          <div className="text-sm">
                            <span className="badge badge-primary">{config.theme}</span>
                            {' '}optimal pour {config.industry}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                <div className="card-actions justify-end mt-6">
                  <button 
                    className="btn btn-primary"
                    onClick={() => setStep(2)}
                    disabled={!config.name || !config.industry || !config.branding.companyName}
                  >
                    Suivant: Validation
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Étape 2: Validation */}
          {step === 2 && (
            <div className="card bg-base-200 shadow-xl">
              <div className="card-body">
                <h2 className="card-title mb-6">
                  ✅ Validation de la configuration
                </h2>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  
                  {/* Résumé configuration */}
                  <div className="space-y-4">
                    <h3 className="text-lg font-semibold">Résumé</h3>
                    
                    <div className="bg-base-100 p-4 rounded-lg space-y-3">
                      <div className="flex justify-between">
                        <span className="font-medium">Nom du SaaS:</span>
                        <span>{config.name}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="font-medium">Entreprise:</span>
                        <span>{config.branding.companyName}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="font-medium">Secteur:</span>
                        <span>{config.industry}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="font-medium">Style:</span>
                        <span>{config.style}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="font-medium">Thème:</span>
                        <div className="badge badge-primary">{config.theme}</div>
                      </div>
                      <div className="flex justify-between">
                        <span className="font-medium">Modules:</span>
                        <span>{config.modules.length}</span>
                      </div>
                    </div>

                    <div className="space-y-2">
                      <h4 className="font-medium">Modules sélectionnés:</h4>
                      <div className="flex flex-wrap gap-2">
                        {config.modules.map(module => (
                          <div key={module} className="badge badge-outline">
                            {module}
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Prévisualisation */}
                  <div className="space-y-4">
                    <h3 className="text-lg font-semibold">Prévisualisation</h3>
                    
                    <div className="mockup-browser border bg-base-300">
                      <div className="mockup-browser-toolbar">
                        <div className="input">{config.name.toLowerCase()}.com</div>
                      </div>
                      <div className="flex justify-center px-4 py-16 bg-base-200">
                        <div className="text-center">
                          <h1 className="text-2xl font-bold">{config.branding.companyName}</h1>
                          <p className="text-sm text-base-content/70 mt-2">
                            Thème: {config.theme}
                          </p>
                          <div className="mt-4 space-x-2">
                            <button className="btn btn-primary btn-sm">Connexion</button>
                            <button className="btn btn-outline btn-sm">Inscription</button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="card-actions justify-between mt-6">
                  <button 
                    className="btn btn-outline"
                    onClick={() => setStep(1)}
                  >
                    Retour
                  </button>
                  <button 
                    className="btn btn-primary"
                    onClick={() => setStep(3)}
                  >
                    Générer le SaaS
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Étape 3: Génération */}
          {step === 3 && (
            <div className="card bg-base-200 shadow-xl">
              <div className="card-body text-center">
                <h2 className="card-title justify-center mb-6">
                  🔄 Génération en cours...
                </h2>

                <div className="space-y-6">
                  <div className="loading loading-spinner loading-lg text-primary"></div>
                  
                  <div className="space-y-2">
                    <p className="text-lg">Création de votre SaaS personnalisé</p>
                    <p className="text-sm text-base-content/70">
                      Cela peut prendre quelques minutes...
                    </p>
                  </div>

                  <div className="steps steps-vertical lg:steps-horizontal">
                    <div className="step step-primary">Configuration validée</div>
                    <div className="step step-primary">Build en cours</div>
                    <div className="step">Déploiement</div>
                    <div className="step">Finalisation</div>
                  </div>
                </div>

                <button 
                  className="btn btn-primary btn-lg mt-6"
                  onClick={handleGenerate}
                  disabled={isGenerating}
                >
                  {isGenerating ? (
                    <>
                      <span className="loading loading-spinner loading-sm"></span>
                      Génération...
                    </>
                  ) : (
                    'Lancer la génération'
                  )}
                </button>
              </div>
            </div>
          )}

        </div>
      </div>
    </div>
  );
}

export default SaasBuilder;
```

## 🎯 Configuration SaaS

### Structure du fichier de configuration
```typescript
// saas.config.ts
export interface SaasConfig {
  // Métadonnées
  name: string;
  version: string;
  description: string;
  
  // Branding
  branding: {
    companyName: string;
    logo?: string;
    favicon?: string;
    primaryColor: string;
    secondaryColor: string;
  };
  
  // Thème et apparence
  theme: {
    name: string; // Thème DaisyUI
    customizations?: Record<string, string>;
  };
  
  // Modules activés
  modules: {
    auth: boolean;
    crm?: boolean;
    analytics?: boolean;
    dashboard?: boolean;
    ai?: boolean;
    ecommerce?: boolean;
  };
  
  // Configuration déploiement
  deployment: {
    domain?: string;
    subdomain?: string;
    environment: 'development' | 'staging' | 'production';
  };
  
  // Base de données
  database: {
    namespace: string;
    tables: string[];
  };
  
  // Permissions et rôles
  permissions: {
    roles: string[];
    features: Record<string, string[]>;
  };
}

// Exemple de configuration générée
export const exampleConfig: SaasConfig = {
  name: "restaurant-manager",
  version: "1.0.0",
  description: "SaaS de gestion de restaurants",
  
  branding: {
    companyName: "RestaurantPro",
    primaryColor: "#8B4513",
    secondaryColor: "#D2691E"
  },
  
  theme: {
    name: "coffee"
  },
  
  modules: {
    auth: true,
    crm: true,
    analytics: true,
    dashboard: true
  },
  
  deployment: {
    domain: "restaurantpro.com",
    environment: "production"
  },
  
  database: {
    namespace: "restaurant_pro",
    tables: ["users", "customers", "orders", "analytics"]
  },
  
  permissions: {
    roles: ["admin", "manager", "staff"],
    features: {
      "crm": ["admin", "manager"],
      "analytics": ["admin"],
      "orders": ["admin", "manager", "staff"]
    }
  }
};
```

## 🔧 API de génération

### Endpoint de génération
```typescript
// /api/saas/generate
export async function POST(request: Request) {
  const config: SaasConfig = await request.json();
  
  try {
    // 1. Validation de la configuration
    const validation = validateSaasConfig(config);
    if (!validation.valid) {
      return Response.json({ error: validation.errors }, { status: 400 });
    }
    
    // 2. Génération du projet
    const projectPath = await generateSaasProject(config);
    
    // 3. Installation des dépendances
    await installDependencies(projectPath, config.modules);
    
    // 4. Configuration du thème
    await setupTheme(projectPath, config.theme);
    
    // 5. Génération des pages selon les modules
    await generatePages(projectPath, config.modules);
    
    // 6. Configuration de la base de données
    await setupDatabase(config.database);
    
    // 7. Build de production
    const buildResult = await buildProject(projectPath);
    
    // 8. Déploiement (optionnel)
    let deploymentUrl = null;
    if (config.deployment.domain) {
      deploymentUrl = await deployToCustomDomain(buildResult, config.deployment);
    }
    
    return Response.json({
      success: true,
      projectPath,
      buildPath: buildResult.outputPath,
      url: deploymentUrl || `http://localhost:3000`,
      config
    });
    
  } catch (error) {
    console.error('Erreur génération SaaS:', error);
    return Response.json({ 
      error: 'Erreur lors de la génération du SaaS' 
    }, { status: 500 });
  }
}
```

### Fonctions utilitaires
```typescript
// Génération du projet
async function generateSaasProject(config: SaasConfig): Promise<string> {
  const projectName = config.name.toLowerCase().replace(/[^a-z0-9]/g, '-');
  const projectPath = path.join(process.cwd(), 'generated-saas', projectName);
  
  // Créer la structure de base
  await fs.ensureDir(projectPath);
  await fs.copy(path.join(__dirname, 'templates/base'), projectPath);
  
  // Générer package.json
  const packageJson = {
    name: projectName,
    version: config.version,
    description: config.description,
    dependencies: getRequiredDependencies(config.modules),
    scripts: {
      "dev": "vite",
      "build": "vite build",
      "preview": "vite preview"
    }
  };
  
  await fs.writeJSON(path.join(projectPath, 'package.json'), packageJson, { spaces: 2 });
  
  return projectPath;
}

// Installation des dépendances selon les modules
function getRequiredDependencies(modules: SaasConfig['modules']): Record<string, string> {
  const baseDeps = {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "@lyxal/ui-kit": "^1.0.0",
    "daisyui": "^5.0.0",
    "tailwindcss": "^4.0.0"
  };
  
  if (modules.auth) {
    baseDeps["@lyxal/auth"] = "^1.0.0";
  }
  
  if (modules.crm) {
    baseDeps["@lyxal/crm"] = "^1.0.0";
  }
  
  if (modules.analytics) {
    baseDeps["@lyxal/analytics"] = "^1.0.0";
    baseDeps["chart.js"] = "^4.0.0";
  }
  
  return baseDeps;
}
```

## 📦 Templates de génération

### Template de base
```
templates/base/
├── src/
│   ├── App.tsx
│   ├── main.tsx
│   ├── layouts/
│   │   ├── MainLayout.tsx
│   │   └── AuthLayout.tsx
│   ├── pages/
│   │   ├── HomePage.tsx
│   │   └── NotFoundPage.tsx
│   ├── components/
│   │   └── common/
│   └── theme/
│       └── globals.css
├── public/
├── index.html
├── vite.config.ts
├── tailwind.config.js
└── tsconfig.json
```

### Template App.tsx
```tsx
// templates/base/src/App.tsx
import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { MainLayout } from './layouts/MainLayout';
import { HomePage } from './pages/HomePage';
import { NotFoundPage } from './pages/NotFoundPage';

// Import conditionnel des modules selon la configuration
{{#if modules.auth}}
import { AuthProvider } from '@lyxal/auth';
import { LoginPage, SignupPage } from './pages/auth';
{{/if}}

{{#if modules.crm}}
import { CRMDashboard } from './pages/crm';
{{/if}}

{{#if modules.analytics}}
import { AnalyticsDashboard } from './pages/analytics';
{{/if}}

function App() {
  useEffect(() => {
    // Appliquer le thème configuré
    document.documentElement.setAttribute('data-theme', '{{theme.name}}');
  }, []);

  return (
    {{#if modules.auth}}
    <AuthProvider>
    {{/if}}
      <Router>
        <Routes>
          <Route path="/" element={<MainLayout />}>
            <Route index element={<HomePage />} />
            
            {{#if modules.auth}}
            <Route path="/login" element={<LoginPage />} />
            <Route path="/signup" element={<SignupPage />} />
            {{/if}}
            
            {{#if modules.crm}}
            <Route path="/crm" element={<CRMDashboard />} />
            {{/if}}
            
            {{#if modules.analytics}}
            <Route path="/analytics" element={<AnalyticsDashboard />} />
            {{/if}}
            
            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Routes>
      </Router>
    {{#if modules.auth}}
    </AuthProvider>
    {{/if}}
  );
}

export default App;
```

## 🚀 Déploiement automatique

### Configuration Vercel/Netlify
```typescript
// Génération automatique de vercel.json
async function generateDeploymentConfig(config: SaasConfig, projectPath: string) {
  if (config.deployment.domain) {
    const vercelConfig = {
      "name": config.name,
      "version": 2,
      "builds": [
        {
          "src": "package.json",
          "use": "@vercel/static-build",
          "config": {
            "distDir": "dist"
          }
        }
      ],
      "routes": [
        {
          "src": "/(.*)",
          "dest": "/index.html"
        }
      ],
      "env": {
        "VITE_SAAS_NAME": config.name,
        "VITE_COMPANY_NAME": config.branding.companyName,
        "VITE_THEME": config.theme.name
      }
    };
    
    await fs.writeJSON(
      path.join(projectPath, 'vercel.json'), 
      vercelConfig, 
      { spaces: 2 }
    );
  }
}
```

---

**🚀 Génération SaaS automatique - De l'idée au déploiement en minutes**