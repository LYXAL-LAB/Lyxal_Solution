# 🗄️ Base de données centralisée LYXAL

Cette structure centralise tous les fichiers `.surql` de LyxalSuite pour une gestion unifiée et simplifiée.

## 📁 Structure

```
database/
├── modules/                    # Schémas par module
│   ├── base/                  # Module de base (entités core)
│   │   ├── base_structure.surql
│   │   ├── base_relations.surql
│   │   ├── base_index.surql
│   │   ├── base_triggers.surql
│   │   └── base_reference_data.surql
│   ├── cash-management/       # Gestion de trésorerie
│   │   ├── cash-management_structure.surql
│   │   ├── cash-management_indexes.surql
│   │   ├── cash-management_triggers.surql
│   │   └── referenceCashManagementData.surql
│   ├── config/                # Configuration système
│   │   ├── investor_config_structure.surql
│   │   └── investor_config_ultimate.surql
│   ├── crm/                   # CRM
│   ├── marketing/             # Marketing
│   ├── production/            # Production
│   ├── helpdesk/              # Support client
│   ├── gdpr/                  # Conformité GDPR
│   ├── business-production/   # Production business
│   ├── business-project/      # Gestion de projets
│   ├── business-support/      # Support business
│   └── client-portal/         # Portail client
├── monitoring_structure.surql  # Monitoring système
├── monitoring_functions.surql
├── monitoring_events.surql
└── monitoring_permissions.surql
```

## 🎯 Avantages de la centralisation

### ✅ **Simplicité**
- Un seul point d'entrée pour tous les schémas
- Gestion unifiée des migrations
- Évite la duplication de code

### ✅ **Responsabilité unique**
- `lyxal-surreal` devient le gestionnaire unique des schémas
- Architecture cohérente avec SurrealDB comme backend unique
- Maintenance simplifiée

### ✅ **Évite la duplication IA**
- Plus de scripts de déploiement dupliqués dans chaque module
- Logique centralisée et réutilisable
- Processus standardisé

## 🚀 Utilisation

### Déploiement complet
```bash
# Déployer tous les modules
npm run deploy:all
```

### Déploiement par module
```bash
# Déployer un module spécifique
npm run deploy:module base
npm run deploy:module crm
```

### Scripts disponibles
- `deploy-all.js` - Déploie tous les modules
- `deploy-module.js` - Déploie un module spécifique
- `migrate-from-old.js` - Migration depuis l'ancienne structure

## 📋 Convention de nommage

Chaque module suit cette convention :
- `{module}_structure.surql` - Tables et types
- `{module}_relations.surql` - Relations entre entités  
- `{module}_index.surql` - Index de performance
- `{module}_triggers.surql` - Triggers et événements
- `reference{Module}Data.surql` - Données de référence

## 🔧 Maintenance

### Ajouter un nouveau module
1. Créer le dossier `modules/{nouveau-module}/`
2. Ajouter les fichiers `.surql` selon la convention
3. Mettre à jour les scripts de déploiement

### Migration depuis l'ancienne structure
Les anciens fichiers `.surql` dispersés dans chaque module ont été centralisés ici.
Les références dans le code pointent maintenant vers cette structure unifiée.

---

**Architecture par:** LyxalSuite Team  
**Dernière mise à jour:** 25/06/2025 