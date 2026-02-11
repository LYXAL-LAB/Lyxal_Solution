# 🚀 Architecture SAAS Globale - Lyxal

Architecture d'initialisation complète Lyxal SAAS basée sur des **templates de configuration**.

## 🎯 Vision Globale

### Hiérarchie Complète d'Orchestration
```
🚀 NIVEAU SAAS (axelor/saas/)                    # 🔝 ORCHESTRATEUR SUPRÊME
├── 🏗️ NIVEAU BASE (axelor/base/)               # 🏗️ ORCHESTRATEUR MODULES
│   ├── 🌍 NIVEAU GEOGRAPHIC (entities/geographic/)  # 🌍 ORCHESTRATEUR ENTITÉS GÉO
│   │   ├── 🏔️  Continent (entities/continent/)     # 🏔️  INSTALLATEUR ENTITÉ
│   │   ├── 🏛️  Country [futur]
│   │   └── 🗺️  Region [futur]
│   ├── 💰 Currency [futur]
│   └── 🏢 Organisation [futur]
├── 💼 CRM [futur]
├── 📊 Accounting [futur]
└── 🏭 Production [futur]
```

### Points d'Entrée par Niveau
| Niveau | Script | Responsabilité | Template |
|--------|--------|----------------|----------|
| **🚀 SAAS** | `init-lyxal-saas.ts` | Initialisation complète | ✅ Selon template |
| **🏗️ BASE** | `install-base.ts` | Modules base | ✅ Mappé depuis template |
| **🌍 GEOGRAPHIC** | `install-geographic.ts` | Entités géographiques | ✅ Mappé depuis template |
| **🏔️  CONTINENT** | `install-complete.ts` | Continent uniquement | ⚙️ Options passées |

## 📋 Templates SAAS Disponibles

### 🎯 **Template Starter** (`starter.json`)
```json
{
  "name": "Lyxal Starter",
  "target": "small_business",
  "modules": {
    "base": { "geographic": { "continent": true } }
  },
  "features": {
    "user_limit": 5,
    "storage_limit": "1GB"
  }
}
```
**Idéal pour :** Petites entreprises, tests, découverte

### 🏢 **Template Professional** (`professional.json`)
```json
{
  "name": "Lyxal Professional", 
  "target": "medium_business",
  "modules": {
    "base": { "geographic": { "continent": true, "country": true } },
    "crm": { "enabled": true },
    "accounting": { "enabled": true }
  },
  "features": {
    "user_limit": 100,
    "storage_limit": "50GB"
  }
}
```
**Idéal pour :** Entreprises moyennes, gestion complète

### 🏭 **Template Enterprise** (`enterprise.json`)
```json
{
  "name": "Lyxal Enterprise",
  "target": "large_business", 
  "modules": { "ALL": "enabled" },
  "features": {
    "user_limit": "unlimited",
    "compliance": ["gdpr", "sox", "hipaa"]
  }
}
```
**Idéal pour :** Grandes entreprises, multinationales

## 🚀 Utilisation

### 1. **Initialisation Simple** (Recommandée)
```bash
# Aller au niveau SAAS
cd axelor/saas/initialisation/

# Initialisation avec template starter (par défaut)
ts-node init-lyxal-saas.ts

# Avec template spécifique
ts-node init-lyxal-saas.ts professional
ts-node init-lyxal-saas.ts enterprise
```

### 2. **Liste des Templates**
```bash
# Voir tous les templates disponibles
ts-node init-lyxal-saas.ts --list-templates

# Résultat :
# 📋 === TEMPLATES LYXAL SAAS DISPONIBLES ===
# 🏷️  Lyxal Starter
#    📄 Fichier: starter.json
#    📝 Description: Configuration minimale pour débuter
#    🎯 Cible: small_business
```

### 3. **Options Avancées**
```bash
# Mode dry-run (simulation)
ts-node init-lyxal-saas.ts professional --dry-run

# Mode verbose avec backup
ts-node init-lyxal-saas.ts enterprise --verbose --skip-backup

# Toutes les options
ts-node init-lyxal-saas.ts starter --dry-run --verbose --skip-backup
```

## 🔧 Flux d'Initialisation

### Séquence Complète
```
1. 📄 CHARGEMENT TEMPLATE
   ├── Lecture du fichier JSON
   ├── Validation de la structure
   └── Extraction des configurations

2. 🗄️ CONFIGURATION DATABASE
   ├── Connexion selon template.database
   ├── Création namespace/database
   └── Configuration clustering (si enterprise)

3. 🏗️ INSTALLATION MODULES
   ├── Base Module (geographic, currency, etc.)
   ├── CRM Module (si activé)
   ├── Accounting Module (si activé) 
   └── Production Module (si activé)

4. ⚙️ POST-CONFIGURATION
   ├── Features selon template.features
   ├── Intégrations selon template.integrations
   ├── Sécurité selon template.security
   └── Données de démonstration (si activé)
```

### Mapping Template → Options
```typescript
// Template JSON → Options Modules
const baseOptions = {
  modules: {
    geographic: template.modules.base.submodules.geographic?.enabled,
    currency: template.modules.base.submodules.currency?.enabled
  },
  geographicOptions: {
    continent: template.modules.base.submodules.geographic?.entities?.continent,
    country: template.modules.base.submodules.geographic?.entities?.country
  }
};
```

## 📊 Configuration par Template

### Modules Activés par Template
| Module | Starter | Professional | Enterprise |
|--------|---------|--------------|------------|
| **Base** | ✅ Minimal | ✅ Complet | ✅ Complet |
| Geographic → Continent | ✅ | ✅ | ✅ |
| Geographic → Country | ❌ | ✅ | ✅ |
| Geographic → Region | ❌ | ✅ | ✅ |
| **CRM** | ❌ | ✅ | ✅ |
| **Accounting** | ❌ | ✅ | ✅ |
| **Production** | ❌ | ❌ | ✅ |
| **HR** | ❌ | ✅ | ✅ |

### Fonctionnalités par Template
| Fonctionnalité | Starter | Professional | Enterprise |
|----------------|---------|--------------|------------|
| **Utilisateurs** | 5 | 100 | Illimité |
| **Stockage** | 1GB | 50GB | Illimité |
| **Multi-tenant** | ❌ | ✅ | ✅ |
| **API Access** | Basic | Advanced | Enterprise |
| **Audit Log** | ❌ | ✅ | ✅ |
| **Backup** | Manuel | Quotidien | Temps réel |

## 🔒 Gestion de la Connexion DB

### Principe : Une Seule Connexion Globale
```typescript
// SAAS Level - Connexion principale
init-lyxal-saas.ts
├── 🔌 Connexion DB globale selon template
├── 📞 Appelle install-base.ts (passe la connexion)
│   ├── 📞 Appelle install-geographic.ts (réutilise connexion)
│   │   └── 📞 Appelle install-complete.ts (réutilise connexion)
│   └── 📞 Appelle install-currency.ts (réutilise connexion)
└── 🔌 Déconnexion DB globale
```

### Configuration DB selon Template
```typescript
// Template starter
{
  "database": {
    "namespace": "lyxal_starter",
    "database": "main",
    "url": "ws://127.0.0.1:8000"
  }
}

// Template enterprise  
{
  "database": {
    "namespace": "lyxal_enterprise",
    "database": "main",
    "url": "ws://127.0.0.1:8000",
    "clustering": {
      "enabled": true,
      "nodes": 3
    }
  }
}
```

## 🎯 Exemples Concrets

### Initialisation Production
```bash
# Pour un client PME
cd axelor/saas/initialisation/
ts-node init-lyxal-saas.ts professional

# Résultat attendu :
# 🚀 LYXAL SAAS
#    📄 Template ✅ Lyxal Professional chargé
#    🗄️ Database ✅ lyxal_professional/main configurée  
#    🏗️ Modules ✅ base, crm, accounting installés
#    ⚙️ Post-config ✅ Multi-tenant, audit log activés
```

### Initialisation Développement
```bash
# Pour tests rapides
ts-node init-lyxal-saas.ts starter --dry-run

# Voir ce qui serait installé sans l'exécuter
```

### Initialisation Enterprise
```bash
# Pour grande entreprise
ts-node init-lyxal-saas.ts enterprise --verbose

# Installation complète avec tous les modules
```

## ⚡ Avantages de cette Architecture

### 🎯 **Configuration Déclarative**
- ✅ Templates JSON lisibles
- ✅ Pas de code pour configurer
- ✅ Versioning des configurations

### 🚀 **Déploiement Simplifié** 
- ✅ Une seule commande d'initialisation
- ✅ Configuration automatique selon template
- ✅ Déploiement reproductible

### 🔧 **Maintenance Facilitée**
- ✅ Modification des templates sans code
- ✅ Ajout de nouveaux templates facile
- ✅ Mise à jour centralisée

### 📈 **Évolutivité**
- ✅ Ajout de nouveaux modules transparent
- ✅ Templates personnalisés clients
- ✅ Déploiement multi-environnement

## 🔮 Roadmap

### Templates Futurs
```
🏥 healthcare.json          # Secteur santé (HIPAA, etc.)
🏦 banking.json             # Secteur bancaire (SOX, etc.)  
🏭 manufacturing.json       # Secteur industriel
📚 education.json           # Secteur éducation
🛒 ecommerce.json          # Commerce électronique
```

### Fonctionnalités Futures
```
🌐 Multi-région             # Déploiement géographique
🔄 Migration automatique    # Passage d'un template à l'autre
📊 Monitoring intégré       # Supervision template-aware
🧪 A/B Testing             # Test de configurations
```

## 🤝 Contribution

### Ajouter un Nouveau Template
1. Créer `templates/mon-template.json`
2. Suivre la structure des templates existants
3. Tester avec `--dry-run`
4. Documenter les use cases

### Ajouter un Nouveau Module
1. Créer le module dans l'architecture existante
2. Ajouter dans les templates appropriés
3. Mettre à jour le mapping dans `init-lyxal-saas.ts`

---

**Architecture SAAS v1.0.0** - Lyxal Team 🚀 