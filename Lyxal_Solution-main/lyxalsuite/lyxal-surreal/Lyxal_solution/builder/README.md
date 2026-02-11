# 🏗️ BUILDER - Système de Métadonnées et Outils de Développement

## 📋 Vue d'ensemble

Le dossier `builder/` centralise tous les **outils de développement**, **métadonnées** et **systèmes d'aide** pour créer et maintenir l'application Lyxal. Il sépare clairement les outils de développement du code métier.

## 🎯 Principe d'organisation

```
📁 Lyxal_solution/
├── 📁 builder/           ← 🛠️ OUTILS DE DÉVELOPPEMENT
│   ├── entities/         ← Métadonnées de toutes les entités
│   ├── functions/        ← Fonctions utilitaires pour l'IA
│   ├── generators/       ← Outils de génération de code
│   ├── interface/        ← Interface de développement web
│   └── docs/            ← Documentation système
│
├── 📁 base/             ← 💼 CODE MÉTIER
├── 📁 crm/              ← 💼 CODE MÉTIER
├── 📁 stock/            ← 💼 CODE MÉTIER
└── 📁 [autres modules]/ ← 💼 CODE MÉTIER
```

## 🏗️ Structure détaillée recommandée

```
builder/
├── 📁 entities/                    ← Métadonnées des entités
│   ├── table_module/              ← Métadonnées des modules
│   │   ├── structures/
│   │   │   └── table_module.surql
│   │   ├── functions/
│   │   │   └── table_module_functions.surql
│   │   └── data/
│   │       └── initial_modules.surql
│   │
│   ├── table_mapping/             ← Mapping des tables existantes
│   │   ├── structures/
│   │   ├── functions/
│   │   └── data/
│   │
│   ├── table_functions/           ← Catalogue des fonctions
│   │   ├── structures/
│   │   ├── functions/
│   │   └── data/
│   │
│   └── table_sous_module/         ← Organisation hiérarchique
│       ├── structures/
│       ├── functions/
│       └── data/
│
├── 📁 functions/                   ← Fonctions utilitaires globales
│   ├── navigation/                ← Navigation automatique IA
│   ├── generation/                ← Génération de code
│   ├── validation/                ← Validation des dépendances
│   └── analysis/                  ← Analyse d'impact
│
├── 📁 generators/                  ← Outils de génération
│   ├── module_generator/          ← Générateur de modules
│   ├── function_generator/        ← Générateur de fonctions
│   ├── crud_generator/            ← Générateur CRUD
│   └── documentation_generator/   ← Générateur de docs
│
├── 📁 interface/                   ← Interface web de développement
│   ├── src/                       ← Code source React/Vue
│   ├── components/                ← Composants UI
│   ├── pages/                     ← Pages de l'interface
│   └── api/                       ← API pour communiquer avec SurrealDB
│
├── 📁 docs/                        ← Documentation système
│   ├── VISION-INTERFACE-DEVELOPPEMENT-METADATA.md
│   ├── architecture/              ← Guides d'architecture
│   ├── tutorials/                 ← Tutoriels d'usage
│   └── api/                       ← Documentation API
│
├── 📁 scripts/                     ← Scripts d'automatisation
│   ├── migrate_existing_modules/  ← Migration modules existants
│   ├── generate_metadata/         ← Génération métadonnées
│   └── setup/                     ← Configuration initiale
│
└── 📄 README.md                    ← Ce fichier
```

## 🎯 Rôles et responsabilités

### **📊 entities/** - Métadonnées système
- **Objectif** : Stocker toutes les métadonnées permettant à l'IA de naviguer
- **Contenu** : Tables de référence, structures, fonctions, données initiales
- **Usage** : Requêtes automatiques de l'IA pour comprendre l'architecture

### **⚙️ functions/** - Fonctions utilitaires globales  
- **Objectif** : Fonctions réutilisables pour manipulation des métadonnées
- **Contenu** : Navigation, génération, validation, analyse
- **Usage** : Appelées par l'interface et les scripts d'automatisation

### **🔧 generators/** - Outils de génération
- **Objectif** : Génération automatique de code basée sur métadonnées
- **Contenu** : Templates, moteurs de génération, validateurs
- **Usage** : Interface web et ligne de commande

### **🖥️ interface/** - Interface de développement
- **Objectif** : Interface web pour développement visuel
- **Contenu** : Application React/Vue complète
- **Usage** : Développeurs pour créer modules visuellement

### **📚 docs/** - Documentation système
- **Objectif** : Documentation complète du système builder
- **Contenu** : Guides, tutoriels, références API
- **Usage** : Onboarding et référence pour développeurs

### **🤖 scripts/** - Automatisation
- **Objectif** : Scripts de maintenance et migration
- **Contenu** : Migration, setup, génération batch
- **Usage** : Opérations ponctuelles et déploiement

## 🔄 Workflow de développement

### **1. Développement traditionnel** (modules métier)
```
base/entities/partner/structures/partner.surql
crm/functions/lead_management.surql
stock/structures/inventory.surql
```

### **2. Développement assisté** (via builder)
```
1. Interface web (builder/interface/) 
2. → Métadonnées (builder/entities/)
3. → Génération (builder/generators/)
4. → Code final (modules métier)
```

## 🚀 Avantages de cette organisation

### **Séparation claire** :
✅ **Outils** vs **Métier** séparés  
✅ **Développement** vs **Runtime** distincts  
✅ **Métadonnées** centralisées  

### **Évolutivité** :
✅ **Interface** développée indépendamment  
✅ **Générateurs** ajoutés facilement  
✅ **Métadonnées** étendues progressivement  

### **Maintenabilité** :
✅ **Documentation** centralisée  
✅ **Fonctions** réutilisables  
✅ **Architecture** claire  

## 📦 Installation et setup

### **Initialisation du builder** :
```bash
# Setup initial des métadonnées
./builder/scripts/setup/init_metadata.sh

# Migration des modules existants  
./builder/scripts/migrate_existing_modules/scan_and_create.sh

# Lancement de l'interface de développement
cd builder/interface && npm run dev
```

## 🎯 Prochaines étapes

### **Phase actuelle** :
- [x] Structure `table_module` ✅
- [x] Fonctions utilitaires ✅  
- [x] Documentation vision ✅

### **Phase suivante** :
- [ ] Créer `table_mapping` dans `builder/entities/`
- [ ] Migrer le contenu existant vers `builder/`
- [ ] Développer premiers générateurs
- [ ] Prototyper interface web

## 📞 Contact et contribution

Cette architecture `builder/` est **évolutive** et **modulaire**. Toute contribution pour améliorer les outils de développement est bienvenue !

**Principe** : Tout ce qui aide à développer plus efficacement va dans `builder/` ! 