# 🚀 **PLAN D'IMPLEMENTATION - ROUTES DYNAMIQUES**

## 📋 **TABLE DES MATIÈRES**

1. [Vue d'Ensemble](#-vue-densemble)
2. [Prérequis & Dépendances](#-prérequis--dépendances)
3. [Phase 1 : Types & Schémas (2 jours)](#-phase-1--types--schémas-2-jours)
4. [Phase 2 : Base de Données (1 jour)](#-phase-2--base-de-données-1-jour)
5. [Phase 3 : Services & Registry (2 jours)](#-phase-3--services--registry-2-jours)
6. [Phase 4 : Guards System (2 jours)](#-phase-4--guards-system-2-jours)
7. [Phase 5 : Composants UI (2 jours)](#-phase-5--composants-ui-2-jours)
8. [Phase 6 : Intégration & Migration (2 jours)](#-phase-6--intégration--migration-2-jours)
9. [Tests & Validation (1 jour)](#-tests--validation-1-jour)
10. [Déploiement & Monitoring (1 jour)](#-déploiement--monitoring-1-jour)

---

## 🎯 **VUE D'ENSEMBLE**

### **Objectif Global**
Implémenter un système de routes dynamiques 100% DB-driven avec sécurité intégrée, remplaçant le système actuel hardcodé.

### **Résultat Attendu**
- ✅ Routes modifiables en production sans redéploiement
- ✅ Permissions et guards dynamiques par route
- ✅ Validation stricte des données
- ✅ Cache performant et sécurité intégrée

### **Métriques de Succès**
- **Fonctionnalité** : 100% des routes actuelles migrées
- **Performance** : Temps de chargement < 500ms
- **Sécurité** : 0 faille de permission
- **Fiabilité** : 99.9% uptime routes

### **Échéance Totale : 11 Jours**

---

## 🔗 **PRÉREQUIS & DÉPENDANCES**

### **Technologies Requises**
- ✅ **SurrealDB** (déjà configuré)
- ✅ **TypeScript** (déjà configuré)
- ✅ **React Router** (vérifier présence)
- ✅ **Zod** pour validation (installer si besoin)

### **Dépendances Applicatives**
- ✅ **SurrealClient** (service existant)
- ✅ **SystemConfigService** (service existant)
- ✅ **StudioPageRenderer** (composant existant)
- ✅ **useStudioState** (hook existant)

### **Dépendances Métier**
- ✅ **studio_page** table (déjà existante)
- ✅ **studio_component** table (déjà existante)
- ✅ **Permissions existantes** (authenticated, admin, etc.)

---

## 🏗️ **PHASE 1 : TYPES & SCHÉMAS (2 JOURS)**

### **Objectif : Fondation Type-Safe**
Définir tous les types TypeScript et schémas de validation pour garantir la sécurité des données.

### **Tâches Détaillées**

#### **Jour 1 : Types de Base**
```typescript
// 1.1 Types principaux (src/lib/studio/types/route.ts)
interface StudioRoute {
  id: string;
  identity: RouteIdentity;
  page: RoutePageRef;
  permissions: Permission[];
  guards: RouteGuard[];
  metadata: RouteMetadata;
  status: RouteStatus;
}

// 1.2 Types utilitaires
type Permission = 'guest' | 'authenticated' | 'admin' | 'manager';
type GuardType = 'auth' | 'role' | 'subscription' | 'feature';
```

#### **Jour 2 : Schémas de Validation**
```typescript
// 2.1 Schéma route (src/lib/studio/routes/schemas/routeSchema.ts)
export const StudioRouteSchema = z.object({
  identity: z.object({
    value: z.string().regex(/^\/.*/),
    slug: z.string().regex(/^[a-z0-9-]+$/),
    code: z.string().regex(/^[a-z_]+$/)
  }),
  page: z.object({
    identity: z.object({
      code: z.string()
    })
  }),
  permissions: z.array(z.enum(['guest', 'authenticated', 'admin', 'manager'])),
  guards: z.array(RouteGuardSchema).optional(),
  metadata: RouteMetadataSchema,
  status: RouteStatusSchema
});

// 2.2 Export validateRoute function
export function validateRoute(data: unknown): RouteValidationResult {
  return StudioRouteSchema.safeParse(data);
}
```

### **Critères de Succès**
- ✅ Tous les types TypeScript compilés sans erreur
- ✅ Schémas Zod valides et testés
- ✅ 100% type safety sur les routes

### **Risques & Mitigations**
- **Risque** : Types incompatibles → **Solution** : Revue de code systématique
- **Risque** : Schémas trop stricts → **Solution** : Tests avec données réelles

---

## 🗄️ **PHASE 2 : BASE DE DONNÉES (1 JOUR)**

### **Objectif : Schémas DB Solides**
Créer les tables SurrealDB avec contraintes et indexes appropriés.

### **Tâches Détaillées**

#### **Matin : Schéma Principal**
```sql
-- database/studio/routes/studio_route.surql
DEFINE TABLE studio_route SCHEMAFULL;

DEFINE FIELD identity ON studio_route TYPE object;
DEFINE FIELD identity.value ON studio_route TYPE string ASSERT $value =~ /^\/.*/;
DEFINE FIELD identity.slug ON studio_route TYPE string ASSERT $value =~ /^[a-z0-9-]+$/;
DEFINE FIELD identity.code ON studio_route TYPE string ASSERT $value =~ /^[a-z_]+$/;

DEFINE FIELD page ON studio_route TYPE record<studio_page>;
DEFINE FIELD permissions ON studio_route TYPE array<string>;
DEFINE FIELD guards ON studio_route TYPE array<object>;

DEFINE FIELD metadata ON studio_route TYPE object;
DEFINE FIELD status.is_active ON studio_route TYPE bool DEFAULT true;

-- Indexes pour performance
DEFINE INDEX idx_route_path ON studio_route FIELDS identity.value UNIQUE;
DEFINE INDEX idx_route_active ON studio_route FIELDS status.is_active;
DEFINE INDEX idx_route_permissions ON studio_route FIELDS permissions;
```

#### **Après-midi : Données de Référence**
```sql
-- reference/studio/routes/route_permissions_seeds.surql
CREATE route_permission:guest SET
  code = "guest",
  name_i18n = "permission.guest.name",
  category = "auth";

CREATE route_permission:authenticated SET
  code = "authenticated",
  name_i18n = "permission.authenticated.name",
  category = "auth";
```

### **Critères de Succès**
- ✅ Tables créées sans erreur
- ✅ Contraintes respectées
- ✅ Indexes performants
- ✅ Données de référence insérées

### **Risques & Mitigations**
- **Risque** : Schéma incompatible → **Solution** : Tests avec données existantes
- **Risque** : Migration casse → **Solution** : Backup systématique

---

## 🔧 **PHASE 3 : SERVICES & REGISTRY (2 JOURS)**

### **Objectif : Couche d'Accès DB**
Implémenter les services et registry pour gérer les routes en DB.

### **Tâches Détaillées**

#### **Jour 1 : RouteService**
```typescript
// src/services/RouteService.ts
export class RouteService {
  static async getActiveRoutes(): Promise<StudioRoute[]> {
    const query = `
      SELECT *, page.* as page
      FROM studio_route
      WHERE status.is_active = true
      ORDER BY identity.value ASC
    `;
    const result = await SurrealClient.query(query);
    return result || [];
  }

  static async createRoute(route: Omit<StudioRoute, 'id'>): Promise<StudioRoute> {
    // Validation AVANT insertion
    const validation = validateRoute(route);
    if (!validation.success) {
      throw new ValidationError(validation.errors);
    }

    const query = `CREATE studio_route CONTENT $route`;
    const result = await SurrealClient.query(query, { route });
    return result?.[0];
  }
}
```

#### **Jour 2 : Registry & Cache**
```typescript
// src/lib/studio/routes/registry/RouteRegistry.ts
export class RouteRegistry {
  private cache = new Map<string, StudioRoute>();
  private lastFetch = 0;
  private readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes

  async getActiveRoutes(): Promise<StudioRoute[]> {
    if (this.shouldRefetch()) {
      const routes = await RouteService.getActiveRoutes();
      this.updateCache(routes);
    }
    return Array.from(this.cache.values());
  }

  private shouldRefetch(): boolean {
    return Date.now() - this.lastFetch > this.CACHE_TTL;
  }
}
```

### **Critères de Succès**
- ✅ Service CRUD fonctionnel
- ✅ Cache opérationnel
- ✅ Gestion d'erreurs robuste
- ✅ Performance acceptable

### **Risques & Mitigations**
- **Risque** : Cache stale → **Solution** : TTL court + invalidation manuelle
- **Risque** : DB down → **Solution** : Fallback + retry logic

---

## 🛡️ **PHASE 4 : GUARDS SYSTEM (2 JOURS)**

### **Objectif : Sécurité des Routes**
Implémenter le système de guards pour contrôler l'accès aux routes.

### **Tâches Détaillées**

#### **Jour 1 : Guards de Base**
```typescript
// src/lib/studio/routes/guards/authGuard.ts
export class AuthGuard {
  static async check(guard: RouteGuard, context: RouteContext): Promise<boolean> {
    const { user } = context;

    switch (guard.type) {
      case 'auth':
        return !!user;

      case 'role':
        if (!user) return false;
        const requiredRole = guard.condition?.role;
        return user.roles?.includes(requiredRole) ?? false;

      default:
        return false;
    }
  }
}
```

#### **Jour 2 : Guards Avancés & Registry**
```typescript
// src/lib/studio/routes/guards/index.ts
import { AuthGuard } from './authGuard';
import { RoleGuard } from './roleGuard';
import { SubscriptionGuard } from './subscriptionGuard';
import { FeatureGuard } from './featureGuard';

export const GuardRegistry = {
  auth: AuthGuard,
  role: RoleGuard,
  subscription: SubscriptionGuard,
  feature: FeatureGuard
};

export async function executeGuard(
  guard: RouteGuard,
  context: RouteContext
): Promise<boolean> {
  const guardClass = GuardRegistry[guard.type as keyof typeof GuardRegistry];
  if (!guardClass) return false;

  return await guardClass.check(guard, context);
}
```

### **Critères de Succès**
- ✅ Tous les types de guards implémentés
- ✅ Registry fonctionnel
- ✅ Intégration avec context utilisateur
- ✅ Gestion d'erreurs des guards

### **Risques & Mitigations**
- **Risque** : Guards trop permissifs → **Solution** : Tests de sécurité approfondis
- **Risque** : Context manquant → **Solution** : Validation context obligatoire

---

## 🎨 **PHASE 5 : COMPOSANTS UI (2 JOURS)**

### **Objectif : Interface Utilisateur**
Créer les composants React pour l'intégration des routes dynamiques.

### **Tâches Détaillées**

#### **Jour 1 : Composants de Base**
```tsx
// src/components/router/RouteGuard.tsx
export const RouteGuard: React.FC<RouteGuardProps> = ({
  permissions,
  guards,
  children,
  fallbackPath = '/signin'
}) => {
  const user = useUser();
  const context: RouteContext = { user, tenant: useTenant() };

  // Vérifier permissions
  const hasPermissions = checkPermissions(permissions, user);

  // Vérifier guards
  const [guardsValid, setGuardsValid] = useState<boolean | null>(null);

  useEffect(() => {
    const checkGuards = async () => {
      for (const guard of guards) {
        const valid = await executeGuard(guard, context);
        if (!valid) {
          setGuardsValid(false);
          return;
        }
      }
      setGuardsValid(true);
    };

    if (guards.length > 0) {
      checkGuards();
    } else {
      setGuardsValid(true);
    }
  }, [guards, context]);

  if (!hasPermissions || guardsValid === false) {
    return <Navigate to={fallbackPath} replace />;
  }

  if (guardsValid === null) {
    return <RouteLoading />;
  }

  return <>{children}</>;
};
```

#### **Jour 2 : DynamicRouter & Hooks**
```tsx
// src/components/router/DynamicRouter.tsx
export const DynamicRouter: React.FC = () => {
  const { routes, loading, error } = useStudioRoutes();

  if (loading) return <RouteLoading />;
  if (error) return <RouteErrorBoundary error={error} />;

  const routeElements = routes.map(route => (
    <Route
      key={route.identity.value}
      path={route.identity.value}
      element={
        <RouteGuard
          permissions={route.permissions}
          guards={route.guards}
        >
          <StudioPageRenderer pageCode={route.page.identity.code} />
        </RouteGuard>
      }
    />
  ));

  return (
    <BrowserRouter>
      <Routes>
        {routeElements}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
};

// src/lib/studio/hooks/useStudioRoutes.ts
export const useStudioRoutes = (): UseStudioRoutesResult => {
  const [routes, setRoutes] = useState<StudioRoute[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadRoutes = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const fetchedRoutes = await RouteService.getActiveRoutes();
      setRoutes(fetchedRoutes);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur chargement routes');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadRoutes(); }, [loadRoutes]);

  return { routes, loading, error, refetch: loadRoutes };
};
```

### **Critères de Succès**
- ✅ Composants React fonctionnels
- ✅ Hooks opérationnels
- ✅ Gestion d'états (loading/error)
- ✅ Navigation fluide

### **Risques & Mitigations**
- **Risque** : Re-renders excessifs → **Solution** : Memoization + useCallback
- **Risque** : Memory leaks → **Solution** : Cleanup effects

---

## 🔗 **PHASE 6 : INTÉGRATION & MIGRATION (2 JOURS)**

### **Objectif : Migration Progressive**
Migrer les routes existantes et intégrer le nouveau système.

### **Tâches Détaillées**

#### **Jour 1 : Migration Données**
```sql
-- Migrer les routes existantes
CREATE studio_route:dashboard SET
  identity = {
    value: "/app/dashboard",
    slug: "dashboard",
    code: "dashboard"
  },
  page = (SELECT id FROM studio_page WHERE identity.code = "dashboard")[0],
  permissions = ["authenticated"],
  metadata = {
    title_i18n = "page.dashboard.title"
  };

CREATE studio_route:signin SET
  identity = { value: "/signin", slug: "signin", code: "signin" },
  page = (SELECT id FROM studio_page WHERE identity.code = "signin")[0],
  permissions = ["guest"];
```

#### **Jour 2 : Intégration App**
```tsx
// src/AppRouter.tsx - Remplacement progressif
const AppRouter: React.FC = () => {
  const { useDynamicRoutes } = useFeatureFlag('dynamic-routes');

  if (useDynamicRoutes) {
    return <DynamicRouter />;
  }

  // Fallback vers routes hardcodées
  return <LegacyRouter />;
};
```

### **Critères de Succès**
- ✅ Toutes les routes existantes migrées
- ✅ Feature flag opérationnel
- ✅ Rollback possible
- ✅ Performance équivalente

### **Risques & Mitigations**
- **Risque** : Migration casse l'app → **Solution** : Feature flag + rollback immédiat
- **Risque** : Données corrompues → **Solution** : Validation stricte + backup

---

## 🧪 **TESTS & VALIDATION (1 JOUR)**

### **Objectif : Qualité & Fiabilité**
Tests complets pour garantir le fonctionnement en production.

### **Tâches Détaillées**

#### **Matin : Tests Unitaires**
```typescript
// Tests des guards
describe('AuthGuard', () => {
  it('should allow authenticated users', async () => {
    const guard = { type: 'auth' as const };
    const context = { user: { id: '1' } };

    const result = await AuthGuard.check(guard, context);
    expect(result).toBe(true);
  });
});

// Tests des services
describe('RouteService', () => {
  it('should fetch active routes', async () => {
    const routes = await RouteService.getActiveRoutes();
    expect(Array.isArray(routes)).toBe(true);
  });
});
```

#### **Après-midi : Tests d'Intégration**
```typescript
// Test flux complet
describe('Dynamic Routing', () => {
  it('should render protected route for authenticated user', async () => {
    // Setup user authentifié
    // Naviguer vers route protégée
    // Vérifier rendu correct
  });
});
```

### **Critères de Succès**
- ✅ Coverage > 80%
- ✅ Tests passant
- ✅ Performance validée
- ✅ Sécurité testée

---

## 🚀 **DÉPLOIEMENT & MONITORING (1 JOUR)**

### **Objectif : Production Ready**
Mise en production avec monitoring et rollback.

### **Tâches Détaillées**

#### **Matin : Déploiement**
```bash
# Migration DB
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db studio database/studio/routes/*.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db studio reference/studio/routes/*.surql

# Build et déploiement
npm run build
# Deploy to staging
# Tests fonctionnels
# Deploy to production
```

#### **Après-midi : Monitoring**
```typescript
// Métriques à surveiller
const routeMetrics = {
  loadTime: 'routes_load_duration',
  errorRate: 'routes_error_rate',
  cacheHitRate: 'routes_cache_hit_rate',
  authFailureRate: 'routes_auth_failure_rate'
};
```

### **Critères de Succès**
- ✅ Déploiement réussi
- ✅ Monitoring opérationnel
- ✅ Rollback planifié
- ✅ Documentation mise à jour

---

## 📊 **SUIVI & REPORTING**

### **Daily Standup**
- ✅ **Avancement** : % complété par phase
- ✅ **Blocages** : Issues identifiées
- ✅ **Risques** : Nouveaux risques apparus
- ✅ **Qualité** : Tests passant, code review

### **Métriques Clés**
- **Qualité** : Tests passant, linting OK, types stricts
- **Performance** : Temps chargement routes < 500ms
- **Sécurité** : Guards fonctionnels, permissions respectées
- **Fiabilité** : 0 erreur en prod pendant 1 semaine

### **Gates de Validation**
- **Fin Phase N** : Revue code + tests automatisés
- **Fin Implémentation** : Tests d'intégration complets
- **Avant Prod** : Tests de charge + sécurité

---

## 🎯 **PLAN D'ACTION COORDONNÉ**

### **Semaine 1-2**
- **Lundi** : Phase 1 (Types & Schémas)
- **Mardi** : Phase 2 (DB Schemas)
- **Mercredi** : Phase 3 (Services)
- **Jeudi** : Phase 4 (Guards)
- **Vendredi** : Revue semaine 1

### **Semaine 3-4**
- **Lundi** : Phase 5 (UI Components)
- **Mardi** : Phase 6 (Intégration)
- **Mercredi** : Tests & Validation
- **Jeudi** : Déploiement & Monitoring
- **Vendredi** : Revue finale & Go-live

---

## 🚨 **PLAN DE CONTINGENCE**

### **Risques Majeurs**
- **DB Migration Fails** → Backup automatique + rollback script
- **Performance Issue** → Cache désactivable + monitoring temps réel
- **Security Breach** → Guards bypass → Audit sécurité immédiat
- **Breaking Change** → Feature flag + versionning sémantique

### **Points de Rollback**
- **Phase 3** : Désactiver RouteService → utiliser routes hardcodées
- **Phase 5** : Feature flag `useDynamicRoutes = false`
- **Phase 6** : Revenir à AppRouter legacy

---

## 🎯 **RÉUSSITE GLOBALE**

**Critères de Succès Final :**
- ✅ **Fonctionnalité** : Routes 100% dynamiques opérationnelles
- ✅ **Performance** : < 500ms chargement, < 100ms navigation
- ✅ **Sécurité** : Guards infaillibles, permissions respectées
- ✅ **Fiabilité** : 99.9% uptime, 0 erreur production
- ✅ **Maintenabilité** : Code documenté, tests complets

**Résultat : Un système de routes enterprise-grade, scalable et sécurisé !** 🚀

---

**Prêt à commencer la Phase 1 ?** 🎯

**Par quoi voulez-vous commencer : Types ou Base de Données ?** 🤔
