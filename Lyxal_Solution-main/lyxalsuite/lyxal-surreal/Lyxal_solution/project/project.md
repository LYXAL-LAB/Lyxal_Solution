# MIGRATION MODULE AXELOR-PROJECT VERS SURREALDB

## Vue d'ensemble

**Module :** axelor-project  
**Description :** Gestion complète de projets et tâches  
**Date de migration :** 2024  
**Statut :** ✅ COMPLET - 33/33 entités migrées  

## Structure de la migration

La migration du module axelor-project a été organisée en **3 fichiers logiques** pour une meilleure lisibilité et maintenance :

### 1. Gestion de base des projets et tâches

- **AppProject** - Configuration principale de l'application projet
- **Project** - Projet (entité centrale)
- **ProjectTask** - Tâche de projet
- **ProjectStatus** - Statut de projet
- **TaskStatus** - Statut de tâche
- **ProjectPriority** - Priorité de projet et tâche
- **ProjectTaskCategory** - Catégorie de tâche
- **ProjectTaskLinkType** - Type de lien entre tâches
- **ProjectTaskLink** - Lien entre tâches de projet
- **ProjectConfig** - Configuration de projet
- **ProjectCheckListItem** - Élément de check-list
- **ProjectCheckListTemplate** - Modèle de check-list

### 2. Gestion des ressources, templates et fonctionnalités avancées

- **ProjectTemplate** - Modèle de projet pour création rapide
- **TaskTemplate** - Modèle de tâche pour création rapide
- **ResourceType** - Type de ressource
- **Resource** - Ressource de projet
- **ResourceBooking** - Réservation de ressource
- **ProjectVersion** - Version/Roadmap de projet
- **Sprint** - Sprint pour gestion agile
- **TaskStatusProgressByCategory** - Progression des statuts par catégorie
- **ProjectBatch** - Traitement par lot des projets
- **Site** - Site de projet
- **Topic** - Sujet/Topic de discussion

### 3. Wiki, collaboration et extensions système

- **Wiki** - Wiki de projet pour documentation collaborative
- **WikiFolder** - Dossier de wiki pour organisation
- **UserProjectExtension** - Extension utilisateur pour projets
- **UnitConversion** - Conversion d'unités pour projets
- **SequenceProject** - Séquence pour projets
- **MetaJsonFieldProject** - Champ JSON métadonnées
- **CompanyProjectExtension** - Extension entreprise pour projets
- **BatchProject** - Traitement par lot spécifique projets
- **AppBaseProject** - Configuration de base pour projets
- **AppProjectExtension** - Extension application pour projets

## Fonctionnalités clés à insérer

### 🎯 Gestion de projets
- Hiérarchie de projets et sous-projets
- Statuts configurables et workflow
- Planification et suivi temporel
- Gestion des équipes et membres
- Relations clients et partenaires

### 📋 Gestion des tâches
- Hiérarchie de tâches et sous-tâches
- Statuts et priorités personnalisables
- Catégorisation des tâches
- Liens et dépendances entre tâches
- Suivi du temps et progression

### 🔄 Gestion agile
- Sprints et backlog
- Versions et roadmap
- Tableaux Kanban
- Gestion des cycles de développement

### 🛠️ Ressources et templates
- Gestion des ressources physiques
- Réservation et planification des ressources
- Templates de projets et tâches
- Création rapide depuis templates

### 📚 Collaboration
- Wiki collaboratif avec hiérarchie
- Documentation structurée par dossiers
- Partage de connaissances
- Suivi des modifications

### ⚙️ Extensions système
- Configuration par entreprise
- Préférences utilisateur
- Champs personnalisés
- Séquences automatiques
- Traitements par lot

## Relations principales

### Relations centrales
- **Project** 1:N **ProjectTask** (Projet vers Tâches)
- **Project** N:1 **ProjectStatus** (Projet vers Statut)
- **ProjectTask** N:1 **TaskStatus** (Tâche vers Statut)
- **ProjectTask** N:1 **ProjectPriority** (Tâche vers Priorité)
- **ProjectTask** N:1 **ProjectTaskCategory** (Tâche vers Catégorie)

### Relations hiérarchiques
- **Project** N:1 **Project** (Projet parent)
- **ProjectTask** N:1 **ProjectTask** (Tâche parent)
- **WikiFolder** N:1 **WikiFolder** (Dossier parent)

### Relations de ressources
- **Resource** N:1 **ResourceType** (Ressource vers Type)
- **ResourceBooking** N:1 **Resource** (Réservation vers Ressource)
- **ResourceBooking** N:1 **Project** (Réservation vers Projet)
- **ResourceBooking** N:1 **ProjectTask** (Réservation vers Tâche)

### Relations de templates
- **ProjectTemplate** 1:N **TaskTemplate** (Template projet vers tâches)
- **TaskTemplate** N:1 **TaskTemplate** (Template parent)

### Relations de collaboration
- **Wiki** N:1 **Project** (Wiki vers Projet)
- **Wiki** N:1 **WikiFolder** (Wiki vers Dossier)
- **Topic** N:1 **Project** (Sujet vers Projet)

### Relations d'extensions
- **UserProjectExtension** 1:1 **User** (Extension utilisateur)
- **CompanyProjectExtension** 1:1 **Company** (Extension entreprise)

## Fonctions utilitaires

### Calculs et statistiques
- `fn::calculate_project_progress()` - Calcul progression projet
- `fn::calculate_sprint_progress()` - Calcul progression sprint
- `fn::calculate_total_estimated_time()` - Calcul temps total estimé
- `fn::get_user_workload()` - Calcul charge utilisateur

### Gestion des ressources
- `fn::calculate_resource_availability()` - Vérification disponibilité ressource
- `fn::get_project_resource_bookings()` - Réservations d'un projet

### Templates et création
- `fn::create_project_from_template()` - Création projet depuis template
- `fn::create_wiki_from_template()` - Création wiki depuis template

### Utilitaires système
- `fn::get_overdue_tasks()` - Tâches en retard
- `fn::get_projects_by_status()` - Projets par statut
- `fn::convert_unit()` - Conversion d'unités
- `fn::generate_project_sequence()` - Génération séquences

### Collaboration
- `fn::get_wiki_folder_hierarchy()` - Hiérarchie dossiers wiki
- `fn::get_project_wikis()` - Wikis d'un projet
- `fn::get_sprint_tasks()` - Tâches d'un sprint

## Triggers et événements

### Mise à jour automatique
- **project_updated** - Mise à jour date modification projet
- **project_task_updated** - Mise à jour date modification tâche
- **wiki_updated** - Mise à jour date modification wiki

### Gestion des séquences
- **increment_task_sequence** - Incrémentation séquence tâches
- **project_auto_numbering** - Auto-numérotation projets
- **task_auto_numbering** - Auto-numérotation tâches

### Contrôles de cohérence
- **check_resource_availability** - Vérification conflits ressources
- **wiki_folder_hierarchy_check** - Vérification hiérarchie dossiers

## Vues complexes et tableaux de bord

### Tableaux de bord projets
- **project_dashboard** - Projets avec statistiques complètes
- **project_task_complete** - Tâches avec détails complets
- **project_template_dashboard** - Templates avec compteurs

### Tableaux de bord ressources
- **resource_dashboard** - Ressources avec réservations
- **sprint_dashboard** - Sprints avec progression

### Tableaux de bord collaboration
- **wiki_hierarchy** - Wikis avec hiérarchie complète
- **wiki_folder_dashboard** - Dossiers avec compteurs

### Tableaux de bord utilisateurs
- **user_project_dashboard** - Utilisateurs avec préférences
- **company_project_dashboard** - Entreprises avec configuration

## Index et optimisations

### Index principaux
- Relations critiques (project_id, assigned_to_id, status_id)
- Codes uniques (project.code, sequence.code)
- Dates importantes (task_date, task_deadline, from_date, to_date)
- Hiérarchies (parent_project_id, parent_task_id, parent_folder_id)

### Optimisations performance
- Index composites sur dates
- Index sur statuts et priorités
- Index sur relations entreprise
- Index sur séquences et codes

## Constantes et paramètres

### Gestion des statuts
- `$TASK_STATUS_MANAGEMENT_NONE` = 1
- `$TASK_STATUS_MANAGEMENT_PROJECT` = 2
- `$TASK_STATUS_MANAGEMENT_CATEGORY` = 4

### Types de projets
- `$GEN_PROJ_TYPE_BUSINESS_PROJECT` = "BUSINESS_PROJECT"
- `$GEN_PROJ_TYPE_PHASE_BY_LINE` = "PHASE_BY_LINE"
- `$GEN_PROJ_TYPE_TASK_BY_LINE` = "TASK_BY_LINE"
- `$GEN_PROJ_TYPE_PROJECT_ALONE` = "PROJECT_ALONE"

### Gestion des sprints
- `$SPRINT_MANAGEMENT_NONE` = "none"
- `$SPRINT_MANAGEMENT_PROJECT` = "project"
- `$SPRINT_MANAGEMENT_VERSION` = "version"

### Statuts de traitement
- `$BATCH_STATUS_READY` = 0
- `$BATCH_STATUS_RUNNING` = 1
- `$BATCH_STATUS_SUCCESS` = 2
- `$BATCH_STATUS_ANOMALY` = 3
- `$BATCH_STATUS_TERMINATED` = 4

### Vues utilisateur
- `$PREFERRED_TASK_VIEW_LIST` = "list"
- `$PREFERRED_TASK_VIEW_KANBAN` = "kanban"
- `$PREFERRED_TASK_VIEW_GANTT` = "gantt"
- `$PREFERRED_TASK_VIEW_CALENDAR` = "calendar"

## Utilisation et intégration

### Création d'un projet
```sql
-- Création d'un projet simple
CREATE project SET
    name = "Nouveau Projet",
    code = "PROJ001",
    company_id = company:acme,
    assigned_to_id = user:john,
    project_status_id = project_status:active,
    from_date = "2024-01-01T00:00:00Z",
    to_date = "2024-06-30T23:59:59Z";
```

### Création d'une tâche
```sql
-- Création d'une tâche avec dépendances
CREATE project_task SET
    name = "Développement fonctionnalité",
    project_id = project:PROJ001,
    assigned_to_id = user:developer,
    status_id = task_status:todo,
    priority_id = project_priority:high,
    task_date = "2024-01-15T08:00:00Z",
    task_deadline = "2024-02-15T17:00:00Z",
    budgeted_time = 40.0;
```

### Réservation d'une ressource
```sql
-- Réservation d'une ressource
CREATE resource_booking SET
    name = "Réservation salle de réunion",
    resource_id = resource:meeting_room_1,
    project_id = project:PROJ001,
    from_date = "2024-01-20T09:00:00Z",
    to_date = "2024-01-20T17:00:00Z",
    user_id = user:john;
```

### Requêtes analytiques
```sql
-- Progression des projets
SELECT 
    p.name,
    fn::calculate_project_progress(p.id) as progress,
    COUNT(pt.id) as task_count
FROM project p
LEFT JOIN project_task pt ON pt.project_id = p.id
GROUP BY p.id, p.name;

-- Charge de travail utilisateur
SELECT 
    u.name,
    fn::get_user_workload(u.id, "2024-01-01", "2024-01-31") as workload
FROM user u;
```

## Migration et compatibilité

### Données préservées
- ✅ Toutes les entités Axelor migrées
- ✅ Relations et contraintes maintenues
- ✅ Logique métier préservée
- ✅ Performances optimisées

### Améliorations SurrealDB
- 🚀 Requêtes plus performantes
- 🔄 Relations directes sans jointures complexes
- 📊 Fonctions analytiques intégrées
- 🔒 Contrôles de cohérence automatiques

### Compatibilité
- Support des fonctionnalités Axelor existantes
- Extensions natives SurrealDB
- API REST automatique
- Intégration temps réel

## Conclusion

La migration du module **axelor-project** vers SurrealDB est **100% complète** avec :

- ✅ **33/33 entités migrées** dans 3 fichiers logiques
- ✅ **Toutes les relations préservées** et optimisées
- ✅ **Fonctions utilitaires complètes** pour tous les besoins
- ✅ **Triggers et événements** pour maintenir la cohérence
- ✅ **Vues et tableaux de bord** pour l'analyse
- ✅ **Performance optimisée** avec index appropriés
- ✅ **Configuration système complète** avec extensions

Cette migration offre une base solide pour la gestion de projets dans l'écosystème LYXAL avec toutes les fonctionnalités avancées de SurrealDB.