# ⚙️ Lyxal Studio Runtime - Guide Complet

## 🎯 Vue d'Ensemble

Le **Lyxal Studio Runtime** est un moteur de rendu universel qui transforme des **définitions JSON stockées dans SurrealDB** en **interfaces React complètes et interactives**.

### Principe Fondamental : 100% Database-Driven

**Aucun code frontend en dur** — Tout est défini dans SurrealDB :
- ✅ Composants UI (boutons, inputs, tables, etc.)
- ✅ Pages complètes (structure, layout, widgets)
- ✅ Actions (navigation, submit, search, etc.)
- ✅ Styles et thèmes
- ✅ Permissions et règles d'accès

**Résultat** : Déployer des SaaS entiers sans redéploiement de code, uniquement via des `UPDATE` SurrealDB.

---

## 🔄 Pipeline Global

### Schéma Visuel du Runtime

```
┌─────────────────────────────────────────────────────────────┐
│                    SURREALDB CLOUD                          │
│  ┌────────────────────────────────────────────────────┐     │
│  │ studio_component                                   │     │
│  │   • code: "button"                                 │     │
│  │   • structure: { type, props, children }           │     │
│  │   • props_schema: [...]                            │     │
│  │   • variants: {...}                                │     │
│  └────────────────────────────────────────────────────┘     │
│  ┌────────────────────────────────────────────────────┐     │
│  │ studio_page                                        │     │
│  │   • code: "contact_list"                           │     │
│  │   • content_structure: { ... }                     │     │
│  └────────────────────────────────────────────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓ WebSocket (WSS)
┌─────────────────────────────────────────────────────────────┐
│              REACT APPLICATION                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 1. useStudioComponent                              │     │
│  │    → Charge composant depuis DB (avec cache)       │     │
│  └────────────────────────┬───────────────────────────┘     │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 2. ComponentParser                                 │     │
│  │    ├─ resolveTemplate()                            │     │
│  │    ├─ resolveProps()                               │     │
│  │    ├─ applyVariants()                              │     │
│  │    └─ createReactElement()                         │     │
│  └────────────────────────┬───────────────────────────┘     │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 3. StructureRenderer                               │     │
│  │    → Rendu récursif avec ContextManager            │     │
│  └────────────────────────┬───────────────────────────┘     │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 4. ActionHandler                                   │     │
│  │    → Exécute actions (navigate, submit, etc.)      │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    DOM RENDU                                │
│  • Composants React natifs                                  │
│  • Styles appliqués                                         │
│  • Interactivité complète                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧩 Architecture Détaillée

### Prérequis Techniques

#### Dépendances NPM
```json
{
  "dependencies": {
    "@tanstack/react-query": "^4.29.19",
    "react": "^18.2.0",
    "surrealdb": "^0.5.0",
    "lucide-react": "^0.263.1",
    "react-native-vector-icons": "^10.0.3"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "typescript": "^5.1.6"
  }
}
```

#### Structure des Dossiers
```
src/
├── lib/
│   └── studio/
│       ├── parser/
│       │   ├── ComponentParser.ts      → Parse structures JSON
│       │   ├── StructureRenderer.tsx   → Rendu récursif
│       │   ├── ActionHandler.ts        → Gestion actions
│       │   └── TemplateEngine.ts       → Résolution templates
│       ├── hooks/
│       │   ├── useStudioComponent.ts   → Hook composant
│       │   ├── useStudioPage.ts        → Hook page
│       │   └── useStudioState.ts       → État global
│       ├── context/
│       │   └── ContextManager.ts       → Fusion contextes
│       └── utils/
│           └── validation.ts           → Validation runtime
├── components/
│   └── studio/
│       ├── StudioEngine.tsx            → Point d'entrée
│       ├── StudioComponentRenderer.tsx → Rendu composant
│       ├── StudioPageRenderer.tsx      → Rendu page
│       └── StudioWidget.tsx            → Rendu widget
└── types/
    └── studio.ts                       → Types TypeScript
```

---

## 🔧 Modules Clés du Runtime

### 1. Parser (`lib/studio/parser/`)

**Rôle** : Transformer structure JSON → Composant React

**Pipeline** :
1. `resolveTemplate` → Remplace `{{props.x}}` par valeurs réelles
2. `resolveProps` → Fusionne props structure + props composant
3. `applyVariants` → Applique styles selon variant
4. `resolveChildren` → Parse récursivement les enfants
5. `createReactElement` → Crée l'élément React final

**Exemple** :
```typescript
import { parseComponent } from '@/lib/studio/parser';

const structure = {
  type: "button",
  props: { className: ["btn"], onClick: { type: "action", action: "navigate" } },
  children: [{ type: "text", content: "{{props.label}}" }]
};

const props = { label: "Cliquez-moi", onClick: { url: "/contact" } };
const Component = parseComponent(structure, props);
// → <button className="btn" onClick={navigateTo('/contact')}>Cliquez-moi</button>
```

### 2. Hooks React (`lib/studio/hooks/`)

#### useStudioComponent
```typescript
const useStudioComponent = (code: string, props?: any) => {
  const query = useQuery({
    queryKey: ['studio-component', code],
    queryFn: () => db.select(`studio_component:${code}`),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });

  return {
    component: query.data,
    loading: query.isLoading,
    error: query.error,
    Component: query.data ? parseComponent(query.data.structure, props) : null
  };
};
```

#### useStudioPage
```typescript
const useStudioPage = (code: string) => {
  const query = useQuery({
    queryKey: ['studio-page', code],
    queryFn: () => db.select(`studio_page:${code}`),
  });

  return {
    page: query.data,
    loading: query.isLoading,
    error: query.error
  };
};
```

### 3. Gestion du Cache

#### Stratégie de Cache Multi-Niveau
```typescript
const CACHE_STRATEGY = {
  // Cache React Query (court terme)
  staleTime: 5 * 60 * 1000, // 5 minutes

  // Cache HTTP (moyen terme)
  headers: { 'Cache-Control': 'max-age=300' }, // 5 minutes

  // Cache CDN Bunny (long terme)
  bunny: { ttl: 3600 }, // 1 heure

  // Cache Browser (session)
  sessionStorage: true
};
```

#### Cache Intelligent des Composants
- **Préchargement** : Composants fréquemment utilisés
- **Invalida tion** : Sur modification DB (LIVE QUERY)
- **Compression** : Structures JSON optimisées
- **Lazy Loading** : Chargement à la demande

---

## 🔄 Système de Rendu Contrôlé

### Pourquoi un Système Contrôlé ?

**Approche Traditionnelle** : Composants hard-codés
```jsx
// ❌ HARD-CODÉ - Nécessite rebuild
const ContactForm = () => (
  <form>
    <input name="name" />
    <input name="email" />
    <button>Submit</button>
  </form>
);
```

**Approche Lyxal** : Rendu contrôlé depuis DB
```surql
-- ✅ DYNAMIQUE - Modifiable sans rebuild
CREATE studio_component:contact_form SET
  structure = {
    type: "form",
    children: [
      { type: "input", props: { name: "name", required: true } },
      { type: "input", props: { name: "email", type: "email" } },
      { type: "button", props: { type: "submit" } }
    ]
  };
```

### Architecture du Parser

#### ComponentParser.ts
```typescript
export class ComponentParser {
  private contextManager: ContextManager;
  private actionHandler: ActionHandler;

  async parse(structure: any, props: any = {}): Promise<ReactElement> {
    // 1. Résoudre les templates
    const resolvedStructure = this.resolveTemplates(structure, props);

    // 2. Fusionner les contextes
    const context = await this.contextManager.mergeContexts(props);

    // 3. Appliquer les variants
    const variantStructure = this.applyVariants(resolvedStructure, context);

    // 4. Créer l'élément React
    return this.createReactElement(variantStructure, context);
  }
}
```

#### StructureRenderer.tsx
```typescript
export const StructureRenderer: React.FC<{
  structure: any;
  context: any;
  onAction?: (action: any) => void;
}> = ({ structure, context, onAction }) => {
  const renderChild = (child: any, index: number) => {
    switch (child.type) {
      case 'text':
        return <TextRenderer key={index} {...child} />;
      case 'button':
        return <ButtonRenderer key={index} {...child} onAction={onAction} />;
      case 'input':
        return <InputRenderer key={index} {...child} />;
      default:
        return <GenericRenderer key={index} {...child} />;
    }
  };

  return (
    <View style={structure.props?.style}>
      {structure.children?.map(renderChild)}
    </View>
  );
};
```

---

## 🧩 Composants Database-Driven

### Vision des Composants DB

**Définition** : Composants UI réutilisables définis en JSON dans SurrealDB

**Avantages** :
- ✅ **Modification sans code** : UPDATE DB suffit
- ✅ **Réutilisabilité** : Même composant partout
- ✅ **Consistency** : Apparence uniforme
- ✅ **Maintenance** : Un seul endroit à modifier

### Structure d'un Composant DB

```surql
CREATE studio_component:button_primary SET
  identity = {
    code = "button_primary",
    name = "Bouton Principal",
    version = "1.0.0"
  },

  presentation = {
    name_i18n = i18n_key:button_primary_name,
    label_i18n = i18n_key:button_primary_label,
    description_i18n = i18n_key:button_primary_desc
  },

  structure = {
    type = "button",
    props = {
      className = ["btn", "btn-primary"],
      onClick = {
        type = "action",
        action = "navigate",
        params = { url = "{{props.url}}" }
      }
    },
    children = [
      {
        type = "text",
        content = "{{props.label}}"
      }
    ]
  },

  config = {
    props_schema = [
      {
        name = "label",
        type = "string",
        required = true,
        description = "Texte du bouton"
      },
      {
        name = "url",
        type = "string",
        required = false,
        description = "URL de destination"
      }
    ],
    category = "button",
    version = "1.0.0"
  },

  context = {
    usage_hints = ["primary_action", "cta"],
    semantic_meaning = "action"
  },

  status = {
    is_active = true,
    is_system_component = false
  },

  metadata = {
    author_user_id = "system",
    tags = ["button", "primary", "action"],
    created_at = time::now(),
    updated_at = time::now()
  }
;
```

### Utilisation en React

```typescript
// Dans un composant React
import { useStudioComponent } from '@/lib/studio/hooks';

const MyPage = () => {
  const { Component: ButtonPrimary, loading } = useStudioComponent('button_primary', {
    label: "Créer Contact",
    url: "/contacts/new"
  });

  if (loading) return <div>Chargement...</div>;

  return (
    <div>
      <h1>Gestion Contacts</h1>
      <ButtonPrimary />
    </div>
  );
};
```

### Exemples de Composants

#### Bouton d'Action
```surql
CREATE studio_component:action_button SET
  structure = {
    type = "button",
    props = {
      className = ["btn", "{{props.variant}}"],
      onClick = "{{props.onClick}}"
    },
    children = [
      {
        type = "icon",
        condition = "{{props.icon}}",
        props = { name = "{{props.icon}}", size = 16 }
      },
      {
        type = "text",
        content = "{{props.label}}"
      }
    ]
  };
```

#### Champ de Formulaire
```surql
CREATE studio_component:form_field SET
  structure = {
    type = "div",
    props = { className = ["form-control"] },
    children = [
      {
        type = "label",
        props = { htmlFor = "{{props.name}}" },
        children = [{ type = "text", content = "{{props.label}}" }]
      },
      {
        type = "input",
        props = {
          id = "{{props.name}}",
          name = "{{props.name}}",
          type = "{{props.type}}",
          placeholder = "{{props.placeholder}}",
          required = "{{props.required}}"
        }
      },
      {
        type = "div",
        condition = "{{props.error}}",
        props = { className = ["error-message"] },
        children = [{ type = "text", content = "{{props.error}}" }]
      }
    ]
  };
```

---

## 📋 Démarrage et Ordre d'Implémentation

### Phase 0 : Préparation (1-2h)

#### Objectifs
- ✅ Comprendre l'architecture Database-Driven
- ✅ Installer les dépendances
- ✅ Configurer l'environnement de développement

#### Tâches
1. **Lire la documentation**
   - `README.md` - Vue d'ensemble
   - `ANALYSE_MODULE.md` - Architecture complète
   - `ARCHITECTURE.md` - Patterns techniques

2. **Installer les dépendances**
   ```bash
   npm install @tanstack/react-query surrealdb lucide-react
   npm install -D @types/react typescript
   ```

3. **Configurer SurrealDB**
   ```bash
   surreal start --user root --pass root memory
   ```

### Phase 1 : Schémas DB (2-3h)

#### Objectifs
- ✅ Créer les tables SurrealDB
- ✅ Importer les données de base
- ✅ Tester les connexions

#### Tâches
1. **Créer les schémas**
   ```sql
   -- Exécuter DATABASE.md pour créer toutes les tables
   -- studio_config, studio_menu, studio_page, etc.
   ```

2. **Importer les données système**
   ```bash
   # Importer configurations de base
   surreal import seeds/studio_default_config.surql
   surreal import seeds/studio_default_menus.surql

   # Importer icônes (optionnel pour commencer)
   surreal import seeds/icon_seeds_lucide_all.surql
   ```

3. **Tester la connexion**
   ```typescript
   import { db } from '@/lib/surrealdb';

   // Test basique
   const config = await db.select('studio_config');
   console.log('Configuration chargée:', config);
   ```

### Phase 2 : Parser TypeScript (4-6h)

#### Objectifs
- ✅ Implémenter le ComponentParser
- ✅ Créer le système de templates
- ✅ Développer les hooks React

#### Tâches
1. **Implémenter le TemplateEngine**
   ```typescript
   // Résoudre {{props.label}} → "Cliquez-moi"
   export const resolveTemplate = (template: string, context: any): string => {
     return template.replace(/\{\{([^}]+)\}\}/g, (match, path) => {
       return get(context, path) || match;
     });
   };
   ```

2. **Créer le ComponentParser**
   ```typescript
   export const parseComponent = async (
     structure: any,
     props: any = {},
     context: any = {}
   ): Promise<React.ComponentType> => {
     // Résoudre templates
     // Fusionner props
     // Appliquer variants
     // Créer élément React
   };
   ```

3. **Développer les hooks**
   ```typescript
   export const useStudioComponent = (code: string, props?: any) => {
     return useQuery({
       queryKey: ['studio-component', code],
       queryFn: () => db.select(`studio_component:${code}`),
       staleTime: 5 * 60 * 1000,
     });
   };
   ```

### Phase 3 : Intégration React (3-4h)

#### Objectifs
- ✅ Intégrer dans l'application React
- ✅ Implémenter le cache
- ✅ Gérer les erreurs

#### Tâches
1. **Créer le StudioProvider**
   ```typescript
   export const StudioProvider: React.FC = ({ children }) => {
     return (
       <QueryClientProvider client={queryClient}>
         <StudioContext.Provider value={{ config, theme }}>
           {children}
         </StudioContext.Provider>
       </QueryClientProvider>
     );
   };
   ```

2. **Implémenter le cache intelligent**
   ```typescript
   const queryClient = new QueryClient({
     defaultOptions: {
       queries: {
         staleTime: 5 * 60 * 1000, // 5 minutes
         cacheTime: 10 * 60 * 1000, // 10 minutes
       },
     },
   });
   ```

3. **Créer les composants de base**
   ```typescript
   export const StudioEngine: React.FC = () => {
     const { config } = useStudioConfig();

     return (
       <div data-theme={config.theme}>
         <StudioMenu />
         <StudioPage />
       </div>
     );
   };
   ```

### Phase 4 : Composants et Pages (4-6h)

#### Objectifs
- ✅ Créer des composants DB
- ✅ Développer des pages
- ✅ Implémenter des actions

#### Tâches
1. **Créer des composants de base**
   ```surql
   CREATE studio_component:button SET structure = {
     type = "button",
     props = { className = ["btn"] },
     children = [{ type = "text", content = "{{props.label}}" }]
   };
   ```

2. **Développer une page simple**
   ```surql
   CREATE studio_page:home SET
     title = "Accueil",
     layout = "grid",
     widgets = [
       studio_widget:welcome_message,
       studio_widget:quick_actions
     ];
   ```

3. **Implémenter des actions**
   ```typescript
   const ActionHandler = {
     navigate: (params: any) => navigate(params.url),
     submit: (params: any) => submitForm(params.formId),
     update: (params: any) => updateRecord(params.table, params.id, params.data)
   };
   ```

### Phase 5 : Optimisations (2-3h)

#### Objectifs
- ✅ Optimiser les performances
- ✅ Implémenter le cache avancé
- ✅ Gérer les erreurs

#### Tâches
1. **Optimiser le cache**
   - Préchargement des composants fréquents
   - Invalidation intelligente
   - Compression des structures

2. **Gérer les erreurs**
   ```typescript
   export const ErrorBoundary: React.FC = ({ children }) => {
     const [error, setError] = useState<Error | null>(null);

     if (error) {
       return <div>Erreur de rendu: {error.message}</div>;
     }

     return <ErrorContext.Provider value={setError}>
       {children}
     </ErrorContext.Provider>;
   };
   ```

3. **Monitoring et debug**
   ```typescript
   // Logs de performance
   console.log(`Component ${code} rendered in ${duration}ms`);

   // Debug mode
   if (process.env.NODE_ENV === 'development') {
     console.log('Component structure:', structure);
     console.log('Resolved props:', props);
   }
   ```

---

## 🧪 Tests et Validation

### Tests Unitaires
```typescript
describe('ComponentParser', () => {
  test('should resolve templates', () => {
    const template = '{{user.name}} - {{user.email}}';
    const context = { user: { name: 'John', email: 'john@example.com' } };
    expect(resolveTemplate(template, context)).toBe('John - john@example.com');
  });

  test('should parse button component', async () => {
    const structure = { type: 'button', props: { label: 'Click me' } };
    const Component = await parseComponent(structure);
    expect(Component).toBeDefined();
  });
});
```

### Tests d'Intégration
```typescript
describe('Studio Runtime', () => {
  test('should render page from DB', async () => {
    // Setup DB avec page de test
    await db.create('studio_page:test', { /* ... */ });

    // Render component
    const { findByText } = render(<StudioPage pageCode="test" />);

    // Vérifier rendu
    expect(await findByText('Test Page')).toBeInTheDocument();
  });
});
```

---

## 🔧 Dépannage

### Problèmes Courants

#### Composant ne se charge pas
```typescript
// Vérifier dans la console
console.log('Component data:', componentData);
console.log('Structure:', componentData?.structure);
console.log('Parse error:', parseError);
```

#### Template ne se résout pas
```typescript
// Debug template resolution
const template = '{{user.name}}';
const context = { user: { name: 'John' } };
console.log('Resolved:', resolveTemplate(template, context));
// Expected: "John"
```

#### Action ne s'exécute pas
```typescript
// Vérifier action handler
console.log('Action received:', action);
console.log('Handler exists:', ActionHandler[action.type]);
```

### Outils de Debug

#### Debug Component
```typescript
const DebugComponent: React.FC = ({ structure, props, context }) => {
  return (
    <details>
      <summary>Debug Info</summary>
      <pre>{JSON.stringify({ structure, props, context }, null, 2)}</pre>
    </details>
  );
};
```

#### Performance Monitor
```typescript
const PerformanceMonitor: React.FC = ({ children }) => {
  const [metrics, setMetrics] = useState({});

  useEffect(() => {
    // Monitor render time, cache hits, etc.
    const observer = new PerformanceObserver((list) => {
      setMetrics(prev => ({ ...prev, ...list.getEntries() }));
    });
    observer.observe({ entryTypes: ['measure'] });

    return () => observer.disconnect();
  }, []);

  return (
    <>
      {children}
      <debug-panel metrics={metrics} />
    </>
  );
};
```

---

## 📚 Ressources Supplémentaires

### Liens Externes
- [📚 **Documentation SurrealDB**](https://surrealdb.com/docs)
- [⚛️ **React Documentation**](https://react.dev)
- [🔄 **React Query**](https://tanstack.com/query)
- [🎨 **Lucide Icons**](https://lucide.dev)

### Lectures Recommandées
1. `ANALYSE_MODULE.md` - Vue d'ensemble architecturale
2. `DATABASE.md` - Schémas détaillés
3. `ARCHITECTURE.md` - Patterns et bonnes pratiques
4. `MOBILE.md` - Adaptation mobile
5. `INTEGRATION.md` - Guide d'intégration React

---

## 🎯 Check-list Finale

- [ ] Schémas DB créés et testés
- [ ] Parser TypeScript implémenté
- [ ] Hooks React développés
- [ ] Composants de base créés
- [ ] Cache configuré
- [ ] Actions implémentées
- [ ] Tests unitaires passés
- [ ] Performance optimisée
- [ ] Documentation lue

**Le Lyxal Studio Runtime est maintenant opérationnel !** 🚀✨
