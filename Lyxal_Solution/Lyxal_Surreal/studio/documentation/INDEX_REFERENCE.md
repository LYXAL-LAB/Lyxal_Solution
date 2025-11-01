# 📚 Index de Référence - Lyxal Studio Runtime

**Guide de navigation** : Ce document liste tous les fichiers de référence essentiels pour le développement du Lyxal Studio Runtime et indique **quand consulter chaque fichier**.

---

## 🎯 Fichiers Principaux (À Lire en Priorité)

### 1. 📘 [AMELIORATIONS_RENDU.md](./runtime/AMELIORATIONS_RENDU.md) ⭐ **DÉMARRE ICI**

**Rôle** : Spécification technique complète du Runtime

**Contenu** :
- ✅ Architecture globale (préambule)
- ✅ Pipeline modulaire (parser, resolver, etc.)
- ✅ State management et bindings
- ✅ ContextManager multi-source
- ✅ Cache intelligent
- ✅ Validation runtime
- ✅ Optimisations performance
- ✅ Structure des tests
- ✅ Dépendances NPM
- ✅ Convention de nomenclature
- ✅ Roadmap en 4 phases

**Quand le consulter** :
- 🔴 **Avant de commencer** l'implémentation
- 🔴 Pour comprendre l'architecture complète
- 🔴 Pour voir les exemples de code
- 🔴 Pour la roadmap et prioritisation

**Temps de lecture** : ~45 minutes

---

### 2. 🚀 [documentation/runtime/README_RUNTIME.md](./runtime/README_RUNTIME.md) ⭐ **GUIDE RAPIDE**

**Rôle** : Guide de référence rapide pour le Runtime

**Contenu** :
- ✅ Philosophie du Runtime
- ✅ Pipeline global (schéma visuel)
- ✅ Description des modules clés
- ✅ Flux complet DB → DOM
- ✅ Exemples d'utilisation
- ✅ Architecture des fichiers
- ✅ Démarrage rapide

**Quand le consulter** :
- 🔴 **Première lecture** pour comprendre la vision
- 🔴 Pour avoir une vue d'ensemble rapide
- 🔴 Pour comprendre le pipeline
- 🔴 Comme référence pendant le développement

**Temps de lecture** : ~20 minutes

---

### 3. 🔧 [SYSTEME_RENDU.md](./runtime/SYSTEME_RENDU.md) ⭐ **SYSTÈME DE RENDU**

**Rôle** : Guide détaillé du système de rendu contrôlé

**Contenu** :
- ✅ Pourquoi un système contrôlé vs HTML brut
- ✅ Architecture du système
- ✅ Implémentation complète (ComponentParser)
- ✅ StructureRenderer et StructureRenderer
- ✅ ActionHandler
- ✅ Exemples 100% DB-Driven
- ✅ Principe fondamental : Tout est template JSON

**Quand le consulter** :
- 🔴 Pour comprendre **comment** le rendu fonctionne
- 🔴 Avant d'implémenter le parser
- 🔴 Pour voir les exemples de structures JSON
- 🔴 Pour comprendre le principe "template JSON en DB"

**Temps de lecture** : ~35 minutes

---

### 4. 🧩 [COMPOSANTS_DB.md](./runtime/COMPOSANTS_DB.md) ⭐ **COMPOSANTS DB**

**Rôle** : Guide des composants pilotés par DB

**Contenu** :
- ✅ Vision des composants Database-Driven
- ✅ Architecture proposée (tables, structure)
- ✅ Exemples de composants (button, card, input, table)
- ✅ Moteur de rendu React
- ✅ Utilisation dans les pages Studio

**Quand le consulter** :
- 🔴 Pour comprendre la structure des composants DB
- 🔴 Avant de créer des seeds de composants
- 🔴 Pour voir des exemples complets de composants

**Temps de lecture** : ~30 minutes

---

### 5. 🗂️ [ORDRE_IMPLEMENTATION.md](./runtime/ORDRE_IMPLEMENTATION.md) ⭐ **PAR OÙ COMMENCER**

**Rôle** : Guide d'ordre d'implémentation

**Contenu** :
- ✅ Réponse : DB ou TypeScript en premier ?
- ✅ Ordre recommandé (approche itérative)
- ✅ Checklist de démarrage
- ✅ Plan d'action concret (première semaine)
- ✅ Justification de l'ordre

**Quand le consulter** :
- 🔴 **Avant de commencer** le développement
- 🔴 Pour savoir par quoi commencer
- 🔴 Pour avoir un plan jour par jour
- 🔴 Pour la checklist complète

**Temps de lecture** : ~15 minutes

---

## 📊 Fichiers de Référence Complémentaires

### 6. 🗄️ [DATABASE.md](./database/DATABASE.md) - Schémas SurrealDB

**Rôle** : Référence complète de toutes les tables Studio

**Contenu** :
- ✅ Schémas de toutes les tables (`studio_config`, `studio_menu`, `studio_page`, etc.)
- ✅ Champs complets avec types et validations
- ✅ Exemples de seeds
- ✅ Relations entre tables
- ✅ Index et contraintes

**Quand le consulter** :
- 🔴 Pour créer/mettre à jour les schémas DB
- 🔴 Pour comprendre la structure des données
- 🔴 Pour voir les exemples de seeds
- 🔴 Avant de créer de nouvelles tables

**Temps de lecture** : ~40 minutes (référence)

---

### 7. 🏗️ [ARCHITECTURE.md](./architecture/ARCHITECTURE.md) - Architecture Technique

**Rôle** : Architecture détaillée du système Studio

**Contenu** :
- ✅ Flux de rendu complet (5 étapes)
- ✅ Architecture en couches
- ✅ Composants principaux (Engine, Menu, Page, Form)
- ✅ Système de permissions
- ✅ Réactivité avec LIVE QUERY
- ✅ Performance et optimisations
- ✅ Architecture multi-tenant

**Quand le consulter** :
- 🔴 Pour comprendre l'architecture globale Studio (pas seulement Runtime)
- 🔴 Pour voir comment le Runtime s'intègre dans Studio
- 🔴 Pour comprendre les flux de données

**Temps de lecture** : ~32 minutes

---

### 8. 🔗 [INTEGRATION.md](./integration/INTEGRATION.md) - Intégration

**Rôle** : Guide d'intégration React + React Native

**Contenu** :
- ✅ Installation Web (React + Tailwind)
- ✅ Configuration SurrealDB Client
- ✅ Composants React (StudioEngine, StudioMenu, etc.)
- ✅ Intégration Mobile (React Native)
- ✅ Architecture multi-plateforme

**Quand le consulter** :
- 🔴 Pour intégrer le Runtime dans une app React
- 🔴 Pour configurer SurrealDB client
- 🔴 Pour comprendre les composants Studio existants
- 🔴 Pour l'intégration mobile

**Temps de lecture** : ~42 minutes

---

### 9. 📖 [GUIDE.md](./guides/GUIDE.md) - Guide d'Utilisation

**Rôle** : Guide pratique avec cas d'usage

**Contenu** :
- ✅ Cas d'usage 1 : Créer un tenant White-Label
- ✅ Cas d'usage 2 : Créer un dashboard
- ✅ Cas d'usage 3 : Créer un formulaire
- ✅ Cas d'usage 4 : Activer/désactiver modules
- ✅ Exemples concrets pas à pas

**Quand le consulter** :
- 🔴 Pour voir des exemples concrets d'utilisation
- 🔴 Pour comprendre les cas d'usage Studio (pas seulement Runtime)
- 🔴 Pour tester le système après implémentation

**Temps de lecture** : ~24 minutes

---

### 10. ⚙️ [FUNCTIONS.md](./functions/FUNCTIONS.md) - Fonctions SurrealDB

**Rôle** : Fonctions SurrealDB du système Studio

**Contenu** :
- ✅ `fn::studio_get_config`
- ✅ `fn::studio_get_menu`
- ✅ `fn::studio_render_page`
- ✅ `fn::studio_validate_form`
- ✅ Code complet de chaque fonction

**Quand le consulter** :
- 🔴 Pour implémenter les fonctions SurrealDB
- 🔴 Pour comprendre les fonctions backend existantes
- 🔴 Pour voir comment les fonctions sont utilisées

**Temps de lecture** : ~32 minutes

---

### 11. 📱 [MOBILE.md](./mobile/MOBILE.md) - Guide React Native

**Rôle** : Guide complet pour React Native

**Contenu** :
- ✅ Architecture React Native
- ✅ Composants natifs
- ✅ Navigation dynamique
- ✅ Synchronisation Web ↔ Mobile

**Quand le consulter** :
- 🔴 Pour développer la version mobile du Runtime
- 🔴 Pour comprendre l'architecture multi-plateforme
- 🔴 Pour les composants React Native

**Temps de lecture** : ~27 minutes

---

### 12. 🎨 [DAISYUI.md](./daisyui/DAISYUI.md) - Guide DaisyUI

**Rôle** : Intégration DaisyUI (optionnel, si vous utilisez DaisyUI)

**Contenu** :
- ✅ Installation et configuration
- ✅ Thèmes dynamiques depuis DB
- ✅ Composants Studio avec DaisyUI
- ✅ 33 thèmes disponibles

**Quand le consulter** :
- 🔴 **Seulement si** vous utilisez DaisyUI
- 🔴 Pour intégrer les thèmes DaisyUI
- ⚠️ **Note** : Vous pouvez vous passer de DaisyUI (voir COMPOSANTS_DB.md)

**Temps de lecture** : ~24 minutes

---

### 13. 📊 [ANALYSE_MODULE.md](./ANALYSE_MODULE.md) - Analyse du Module

**Rôle** : Analyse complète du module Studio

**Contenu** :
- ✅ Vue d'ensemble du module
- ✅ Structure complète
- ✅ Fonctionnalités clés
- ✅ Points forts et points d'attention

**Quand le consulter** :
- 🔴 Pour avoir une vue d'ensemble du module Studio
- 🔴 Pour comprendre le contexte global
- 🔴 Pour voir les statistiques et métriques

**Temps de lecture** : ~30 minutes

---

### 14. 📑 [INDEX.md](./INDEX.md) - Index Complet

**Rôle** : Index de toute la documentation Studio

**Contenu** :
- ✅ Vue d'ensemble de tous les fichiers
- ✅ Parcours de lecture recommandé
- ✅ Guide par profil (dev backend, frontend, mobile, etc.)

**Quand le consulter** :
- 🔴 Pour découvrir toute la documentation disponible
- 🔴 Pour choisir quoi lire selon votre profil
- 🔴 Pour avoir une vue d'ensemble complète

**Temps de lecture** : ~25 minutes

---

## 🗺️ Parcours de Lecture Recommandé

### Pour Développer le Runtime (Nouveau sur le projet)

```
1. runtime/ORDRE_IMPLEMENTATION.md (15 min)  → Par où commencer
2. runtime/README_RUNTIME.md (20 min)        → Vision globale
3. runtime/AMELIORATIONS_RENDU.md (45 min)   → Spécification complète
4. runtime/SYSTEME_RENDU.md (35 min)         → Comment ça fonctionne
5. runtime/COMPOSANTS_DB.md (30 min)         → Exemples composants
6. database/DATABASE.md (référence)         → Schémas à créer
```

**Total** : ~2h30 pour être opérationnel

---

### Pour Comprendre l'Architecture (Architecte Tech)

```
1. ANALYSE_MODULE.md (30 min)                  → Vue d'ensemble
2. architecture/ARCHITECTURE.md (32 min)     → Architecture technique
3. runtime/README_RUNTIME.md (20 min)         → Runtime spécifiquement
4. runtime/AMELIORATIONS_RENDU.md (45 min)   → Améliorations techniques
```

**Total** : ~2h07

---

### Pour Intégrer le Runtime (Développeur Frontend)

```
1. runtime/README_RUNTIME.md (20 min)         → Guide rapide
2. integration/INTEGRATION.md (42 min)       → Intégration React
3. runtime/SYSTEME_RENDU.md (35 min)        → Système de rendu
4. runtime/COMPOSANTS_DB.md (30 min)        → Exemples
```

**Total** : ~2h07

---

### Pour Créer les Schémas DB (Développeur Backend)

```
1. runtime/AMELIORATIONS_RENDU.md Section 5 (15 min) → Schéma studio_component
2. database/DATABASE.md (40 min)                    → Tous les schémas
3. runtime/SYSTEME_RENDU.md Section Structure (20 min) → Structure JSON
4. runtime/COMPOSANTS_DB.md Section Exemples (20 min) → Seeds
```

**Total** : ~1h35

---

## 📋 Checklist par Phase de Développement

### Phase 0 : Préparation (Avant de Coder)

- [ ] Lire **runtime/ORDRE_IMPLEMENTATION.md** (15 min)
- [ ] Lire **runtime/README_RUNTIME.md** (20 min)
- [ ] Lire **runtime/AMELIORATIONS_RENDU.md** Préambule + Prérequis (10 min)
- [ ] Installer dépendances NPM
- [ ] Créer structure de dossiers

**Total Phase 0** : ~45 minutes

---

### Phase 1 : SurrealDB (Semaine 1 - Jour 1)

- [ ] Consulter **runtime/AMELIORATIONS_RENDU.md** Section 5 (schéma)
- [ ] Consulter **database/DATABASE.md** (référence)
- [ ] Créer `database/studio/studio_component.surql`
- [ ] Créer seed test `test_button.surql`
- [ ] Valider dans SurrealDB

**Fichiers de référence** :
- `runtime/AMELIORATIONS_RENDU.md` (Section 5)
- `database/DATABASE.md` (Référence complète)

---

### Phase 2 : Parser TypeScript (Semaine 1 - Jour 2-4)

- [ ] Consulter **runtime/AMELIORATIONS_RENDU.md** Section 1 (Pipeline)
- [ ] Consulter **runtime/SYSTEME_RENDU.md** Section Implémentation
- [ ] Implémenter `resolveTemplate.ts`
- [ ] Implémenter `resolveProps.ts`
- [ ] Implémenter `resolveChildren.ts`
- [ ] Implémenter `createReactElement.ts`
- [ ] Créer tests unitaires

**Fichiers de référence** :
- `runtime/AMELIORATIONS_RENDU.md` (Section 1)
- `runtime/SYSTEME_RENDU.md` (Section Implémentation complète)
- `runtime/COMPOSANTS_DB.md` (Exemples de structures)

---

### Phase 3 : Connexion DB ↔ React (Semaine 1 - Jour 5)

- [ ] Consulter **runtime/AMELIORATIONS_RENDU.md** Section 4 (Hooks)
- [ ] Consulter **integration/INTEGRATION.md** (Configuration SurrealDB)
- [ ] Créer `useStudioComponent.ts`
- [ ] Créer `StudioComponentRenderer.tsx`
- [ ] Tester avec seed `test_button`

**Fichiers de référence** :
- `runtime/AMELIORATIONS_RENDU.md` (Section 4)
- `integration/INTEGRATION.md` (Configuration DB)
- `runtime/SYSTEME_RENDU.md` (StructureRenderer)

---

### Phase 4 : Fonctionnalités Avancées (Semaine 2)

- [ ] Consulter **runtime/AMELIORATIONS_RENDU.md** Sections 2, 3, 6 (State, Context, Actions)
- [ ] Implémenter StateManager
- [ ] Implémenter ContextManager
- [ ] Implémenter ActionRegistry

**Fichiers de référence** :
- `runtime/AMELIORATIONS_RENDU.md` (Sections 2, 3, 6)

---

### Phase 5 : Optimisations (Semaine 3)

- [ ] Consulter **runtime/AMELIORATIONS_RENDU.md** Sections 9, 10, 11 (Cache, Validation, Performance)
- [ ] Implémenter ComponentCache
- [ ] Implémenter PropsValidator
- [ ] Optimisations performance

**Fichiers de référence** :
- `runtime/AMELIORATIONS_RENDU.md` (Sections 9, 10, 11)

---

## 🎯 Fichiers par Rôle

### 🧠 Architecte Technique

**À lire** :
1. ANALYSE_MODULE.md
2. architecture/ARCHITECTURE.md
3. runtime/AMELIORATIONS_RENDU.md
4. runtime/README_RUNTIME.md

---

### 💻 Développeur Backend (SurrealDB)

**À lire** :
1. database/DATABASE.md
2. runtime/AMELIORATIONS_RENDU.md Section 5
3. runtime/SYSTEME_RENDU.md (structure JSON)
4. runtime/COMPOSANTS_DB.md (exemples structures)

---

### 🎨 Développeur Frontend (React)

**À lire** :
1. runtime/README_RUNTIME.md
2. runtime/AMELIORATIONS_RENDU.md (toutes sections)
3. runtime/SYSTEME_RENDU.md
4. integration/INTEGRATION.md
5. runtime/COMPOSANTS_DB.md

---

### 📱 Développeur Mobile (React Native)

**À lire** :
1. mobile/MOBILE.md
2. runtime/README_RUNTIME.md
3. integration/INTEGRATION.md (section Mobile)
4. runtime/AMELIORATIONS_RENDU.md (sections pertinentes)

---

### 🧪 QA / Testeur

**À lire** :
1. runtime/AMELIORATIONS_RENDU.md Section Tests
2. runtime/COMPOSANTS_DB.md (exemples)
3. guides/GUIDE.md (cas d'usage)

---

### 🎨 Développeur Icônes / UI

**À lire** :
1. runtime/ICONS_RUNTIME.md (utilisation dans Runtime)
2. icon/ICONS.md (gestion complète du système)
3. icon/README.md (extraction et structure)

---

### 🎨 Développeur Thèmes / Design

**À lire** :
1. runtime/THEMES_RUNTIME.md (utilisation dans Runtime)
2. runtime/ICONS_RUNTIME.md (intégration avec icônes)

---

## 📊 Tableau Récapitulatif

| Fichier | Rôle | Priorité | Temps Lecture |
|---------|------|----------|---------------|
| **ORDRE_IMPLEMENTATION.md** | Par où commencer | 🔴 Critique | 15 min |
| **README_RUNTIME.md** | Guide rapide | 🔴 Critique | 20 min |
| **AMELIORATIONS_RENDU.md** | Spécification complète | 🔴 Critique | 45 min |
| **SYSTEME_RENDU.md** | Comment ça marche | 🔴 Critique | 35 min |
| **COMPOSANTS_DB.md** | Exemples composants | 🟠 Haute | 30 min |
| **DATABASE.md** | Référence schémas | 🟠 Haute | 40 min (ref) |
| **ARCHITECTURE.md** | Architecture globale | 🟡 Moyenne | 32 min |
| **INTEGRATION.md** | Intégration React | 🟡 Moyenne | 42 min |
| **GUIDE.md** | Cas d'usage | 🟡 Moyenne | 24 min |
| **FUNCTIONS.md** | Fonctions SurrealDB | 🟡 Moyenne | 32 min |
| **MOBILE.md** | React Native | 🟢 Optionnel | 27 min |
| **DAISYUI.md** | DaisyUI (optionnel) | 🟢 Optionnel | 24 min |
| **ICONS_RUNTIME.md** | Utilisation icônes Runtime | 🟡 Moyenne | 25 min |
| **THEMES_RUNTIME.md** | Utilisation thèmes Runtime | 🟡 Moyenne | 30 min |

---

## 🔗 Liens Rapides

### Pour Commencer Maintenant

```
📁 studio/documentation/
├── runtime/
│   ├── ORDRE_IMPLEMENTATION.md      → Par où commencer ?
│   ├── README_RUNTIME.md            → Guide rapide
│   ├── AMELIORATIONS_RENDU.md      → Spécification complète
│   └── SYSTEME_RENDU.md             → Comment ça fonctionne
```

---

## 💡 Astuce

**Workflow recommandé** :

1. **Premier jour** : Lire les 4 fichiers critiques (2h)
2. **Avant chaque phase** : Consulter la section correspondante dans runtime/AMELIORATIONS_RENDU.md
3. **Pendant le dev** : Garder runtime/README_RUNTIME.md ouvert comme référence
4. **Référence** : Consulter database/DATABASE.md quand vous avez besoin des schémas

---

**Index créé pour faciliter la navigation dans la documentation du Lyxal Studio Runtime** 🎨🚀

