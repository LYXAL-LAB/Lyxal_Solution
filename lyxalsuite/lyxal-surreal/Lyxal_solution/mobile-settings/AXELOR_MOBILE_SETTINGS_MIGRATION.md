# MIGRATION MODULE AXELOR-MOBILE-SETTINGS VERS SURREALDB

## 📋 Résumé Exécutif

**Module:** axelor-mobile-settings  
**Statut:** ✅ MIGRATION COMPLÈTE - 12/12 ENTITÉS MIGRÉES  
**Date:** 2024  
**Fichier Migration:** `mobile_settings.surql`

## 🏗️ Architecture du Module

Le module axelor-mobile-settings est responsable de la configuration et de la gestion des paramètres pour les applications mobiles dans l'écosystème Axelor.

## 📊 Statistiques de Migration

| Métrique | Valeur |
|----------|--------|
| **Entités XML analysées** | 12 |
| **Tables SurrealDB créées** | 12 |
| **Taux de migration** | 100% |
| **Fonctions utilitaires** | 5 |
| **Vues complexes** | 3 |
| **Index créés** | 12 |

## 🗂️ Entités Migrées

### 1. **AppMobileSettings** → `app_mobile_settings`
- **Description**: Configuration principale des paramètres mobiles
- **Champs principaux**: 
  - Applications activées (Stock, Production, CRM, Helpdesk, HR, Quality, etc.)
  - Configuration QR Code
  - Paramètres de validation stock
  - Configuration multi-devises
  - Gestion timesheet mobile
  - Configuration DMS

### 2. **App** → `app_mobile_extension`
- **Description**: Extension de l'entité App pour mobile
- **Relation**: 1:1 avec AppMobileSettings

### 3. **MobileConfig** → `mobile_config`
- **Description**: Configuration des applications mobiles
- **Champs**: sequence, is_app_enabled, is_customize_menu_enabled
- **Constantes**: APP_SEQUENCE_* pour chaque application

### 4. **MobileMenu** → `mobile_menu`
- **Description**: Gestion des menus mobiles
- **Champs**: technical_name, name, menu_order, parent_application
- **Types**: menu, separator, submenu

### 5. **MobileDashboard** → `mobile_dashboard`
- **Description**: Tableaux de bord mobiles
- **Champs**: name, app_name, menu_title, icon_name, menu_order

### 6. **MobileDashboardLine** → `mobile_dashboard_line`
- **Description**: Lignes de tableau de bord
- **Champs**: 4 graphiques par ligne (mobile_chart_1 à mobile_chart_4)

### 7. **MobileShortcut** → `mobile_shortcut`
- **Description**: Raccourcis mobiles
- **Champs**: name, icon_name, mobile_screen_id

### 8. **MobileScreen** → `mobile_screen`
- **Description**: Écrans mobiles
- **Champs**: technical_name, name, is_usable_on_shortcut

### 9. **MobileChart** → `mobile_chart`
- **Description**: Graphiques mobiles
- **Champs**: name, query, chart_type_select, is_custom_chart

### 10. **MobileWebView** → `mobile_web_view`
- **Description**: Vues web mobiles
- **Champs**: name, menu_title, app_name, url, is_aos_web_view

### 11. **User** → `user_mobile_extension`
- **Description**: Extension utilisateur pour mobile
- **Champs**: qr_code_id, dms_root_id, favourite_folders, favourite_files

### 12. **MetaJsonField** → `meta_json_field_mobile`
- **Description**: Extension champs JSON pour mobile
- **Champs**: is_visible_in_mobile_app

## 🔗 Relations Principales

```
App 1:1 AppMobileSettings
AppMobileSettings 1:N MobileDashboard
AppMobileSettings 1:N MobileShortcut
MobileConfig 1:N MobileMenu
MobileDashboard 1:N MobileDashboardLine
MobileScreen 1:N MobileShortcut
User 1:1 UserMobileExtension
MetaJsonField 1:1 MetaJsonFieldMobile
```

## 🎯 Fonctionnalités Clés

### Configuration d'Applications
- **Applications supportées**: Stock, Production, CRM, Helpdesk, HR, Quality, Intervention, Sale, Project, DMS, Purchase
- **Activation individuelle**: Chaque application peut être activée/désactivée
- **Gestion de versions**: Version minimale requise de l'application mobile

### Gestion des Menus
- **Menus personnalisés**: Configuration des menus par application
- **Types de menus**: Menu, Séparateur, Sous-menu
- **Rôles autorisés**: Contrôle d'accès par rôle

### Tableaux de Bord
- **Dashboards personnalisés**: Configuration des tableaux de bord
- **Graphiques intégrés**: Jusqu'à 4 graphiques par ligne
- **Ordre des menus**: Positionnement personnalisé

### Raccourcis Mobiles
- **Raccourcis rapides**: Accès direct aux écrans
- **Icônes Bootstrap**: Support des icônes Bootstrap
- **Raccourcis une ligne**: Mode d'affichage compact

### Configuration QR Code
- **Connexion par QR Code**: Authentification via QR Code
- **QR Code utilisateur**: QR Code personnalisé par utilisateur

### Validation Stock
- **Validation inventaire**: Contrôle de validation des inventaires
- **Validation corrections**: Validation des corrections de stock
- **Vérification lignes**: Validation des lignes de livraison/réception

### Gestion DMS
- **Racine DMS**: Configuration de la racine DMS par défaut
- **Favoris**: Gestion des dossiers et fichiers favoris
- **Permissions**: Téléchargement, renommage, création, suppression

## 🚀 Fonctions Utilitaires

### 1. `fn::get_mobile_config_by_sequence($sequence: string)`
Récupère la configuration mobile par séquence d'application.

### 2. `fn::get_mobile_menus_by_parent_app($parent_app: string)`
Récupère les menus triés par ordre pour une application parente.

### 3. `fn::get_mobile_dashboards_by_app($app_name: string)`
Récupère les tableaux de bord pour une application spécifique.

### 4. `fn::get_usable_screens_for_shortcut()`
Récupère les écrans utilisables pour créer des raccourcis.

### 5. `fn::get_shortcuts_by_mobile_settings($settings_id: record<app_mobile_settings>)`
Récupère les raccourcis associés à une configuration mobile.

## 📈 Vues Complexes

### 1. `mobile_config_complete`
Vue complète des configurations mobiles avec leurs menus et compteurs.

### 2. `mobile_dashboard_complete`
Vue des tableaux de bord avec leurs lignes et compteurs.

### 3. `mobile_settings_summary`
Résumé des paramètres mobiles avec compteurs de dashboards et raccourcis.

## 🔧 Constantes et Énumérations

### Applications Supportées
```
APP_SEQUENCE_STOCK = "app-stock"
APP_SEQUENCE_MANUFACTURING = "app-manufacturing"
APP_SEQUENCE_CRM = "app-crm"
APP_SEQUENCE_HELPDESK = "app-helpdesk"
APP_SEQUENCE_HR = "app-hr"
APP_SEQUENCE_QUALITY = "app-quality"
APP_SEQUENCE_INTERVENTION = "app-intervention"
APP_SEQUENCE_SALE = "app-sale"
APP_SEQUENCE_PROJECT = "app-project"
APP_SEQUENCE_DMS = "app-dms"
APP_SEQUENCE_PURCHASE = "app-purchase"
```

### Types de Menus
```
MOBILE_MENU_TYPE_MENU = "menu"
MOBILE_MENU_TYPE_SEPARATOR = "separator"
MOBILE_MENU_TYPE_SUBMENU = "submenu"
```

### Imputations Timesheet
```
IMPUTATION_ON_PROJECT = "project"
IMPUTATION_ON_PROJECT_TASK = "projectTask"
IMPUTATION_ON_MANUF_ORDER = "manufOrder"
IMPUTATION_ON_OPERATION_ORDER = "operationOrder"
IMPUTATION_ON_ACTIVITY = "product"
```

### Types de Reporting
```
REPORTING_TYPE_DISPLAY_INDICATORS = "indicators"
REPORTING_TYPE_DISPLAY_ACTIVITIES = "activities"
REPORTING_TYPE_DISPLAY_NONE = "none"
```

## 🎨 Cas d'Usage Typiques

### Configuration d'une Application Mobile
```sql
-- Créer une configuration pour l'application Stock
CREATE mobile_config SET
    sequence = "app-stock",
    is_app_enabled = true,
    is_customize_menu_enabled = true;

-- Ajouter des menus
CREATE mobile_menu SET
    technical_name = "stock-inventory",
    name = "Inventaire",
    menu_order = 10,
    parent_application = "app-stock",
    menu_type = "menu";
```

### Création d'un Tableau de Bord
```sql
-- Créer un tableau de bord personnalisé
CREATE mobile_dashboard SET
    name = "Dashboard Stock",
    app_name = "app-stock",
    is_custom = true,
    menu_title = "Tableau de Bord Stock",
    icon_name = "graph-up",
    menu_order = 5;
```

### Ajout de Raccourcis
```sql
-- Créer un raccourci vers un écran
CREATE mobile_shortcut SET
    name = "Scan Inventaire",
    icon_name = "qr-code-scan",
    mobile_screen_id = (SELECT id FROM mobile_screen WHERE technical_name = "inventory-scan");
```

## 🔒 Sécurité et Permissions

### Gestion des Rôles
- **Rôles autorisés par application**: Contrôle d'accès granulaire
- **Rôles par menu**: Restriction d'accès aux menus
- **Rôles par fonctionnalité**: Permissions spécifiques (validation, ajout de lignes)

### Validation des Opérations
- **Validation inventaire**: Contrôle par rôles
- **Validation corrections**: Permissions spécifiques
- **Ajout de lignes**: Contrôle d'accès aux modifications

## 📊 Performance et Optimisation

### Index Stratégiques
- **Index unique**: technical_name, sequence
- **Index de relation**: app_id, mobile_config_id, mobile_dashboard_id
- **Index de recherche**: app_name, parent_application

### Triggers Automatiques
- **Mise à jour automatique**: updated_on lors des modifications
- **Cohérence des données**: Validation des relations

## 🔄 Événements et Triggers

### Triggers de Mise à Jour
```sql
-- Trigger pour app_mobile_settings
DEFINE EVENT mobile_settings_updated ON TABLE app_mobile_settings 
WHEN $event = "UPDATE" THEN {
    UPDATE app_mobile_settings SET updated_on = time::now() WHERE id = $after.id;
};
```

## 📱 Intégration Mobile

### Configuration des Applications
- **Activation sélective**: Chaque application peut être activée individuellement
- **Gestion de versions**: Contrôle des versions minimales requises
- **Fichiers APK**: Gestion des builds Android

### Personnalisation de l'Interface
- **Menus personnalisés**: Configuration des menus par application
- **Raccourcis rapides**: Accès direct aux fonctionnalités
- **Tableaux de bord**: Visualisation des données métier

## 🌟 Avantages de la Migration

### 1. **Flexibilité Accrue**
- Structure de données adaptable
- Relations dynamiques
- Configuration modulaire

### 2. **Performance Optimisée**
- Index stratégiques
- Vues pré-calculées
- Requêtes optimisées

### 3. **Sécurité Renforcée**
- Contrôle d'accès granulaire
- Validation des données
- Audit des modifications

### 4. **Maintenance Simplifiée**
- Code centralisé
- Fonctions utilitaires
- Documentation intégrée

## 📝 Notes Techniques

### Compatibilité
- **Version SurrealDB**: Compatible avec SurrealDB 1.x
- **Types de données**: Utilisation des types natifs SurrealDB
- **Relations**: Implémentation des relations Axelor

### Limitations
- **Contraintes complexes**: Certaines contraintes Axelor simplifiées
- **Validations métier**: À implémenter au niveau applicatif
- **Sélections**: Énumérations converties en constantes

## 🚀 Évolutions Futures

### Améliorations Possibles
1. **API GraphQL**: Exposition des données via GraphQL
2. **Webhook Support**: Notifications en temps réel
3. **Analytics**: Tableaux de bord avancés
4. **Multi-tenant**: Support du multi-tenancy

### Roadmap
- **Phase 1**: Migration complète ✅
- **Phase 2**: Optimisation des performances
- **Phase 3**: Fonctionnalités avancées
- **Phase 4**: Intégration AI/ML

## 📚 Documentation Technique

### Fichiers de Migration
- `mobile_settings.surql` - Script de migration complet
- `AXELOR_MOBILE_SETTINGS_MIGRATION.md` - Documentation détaillée

### Ressources Connexes
- [SurrealDB Documentation](https://surrealdb.com/docs)
- [Axelor Documentation](https://docs.axelor.com/)
- [Architecture LYXAL](../docs/architecture/README.md)

---

**🎯 Résultat Final**: Migration 100% réussie du module axelor-mobile-settings vers SurrealDB avec 12 entités migrées, fonctions utilitaires, vues optimisées et documentation complète.