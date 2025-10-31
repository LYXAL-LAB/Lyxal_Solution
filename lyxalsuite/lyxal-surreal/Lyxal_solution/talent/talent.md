# Module Axelor Talent - Migration SurrealDB

## Vue d'ensemble

Le module **axelor-talent** est un module de gestion des talents et des ressources humaines dans Axelor Open Suite. Il couvre le recrutement, la formation, l'évaluation des employés et la gestion des compétences. Avec **17 entités** migrées vers SurrealDB, ce module est organisé en 3 domaines fonctionnels principaux.

## Architecture de la migration

### 📂 **Fichiers créés**

1. **`talent_01_recruitment.surql`** (7,044 bytes - 7 entités)
   - Recrutement et gestion des postes
   - Applications et candidatures
   - Étapes de recrutement

2. **`talent_02_training.surql`** (5,802 bytes - 7 entités)
   - Formations et sessions
   - Compétences et niveaux d'éducation
   - Inscriptions et évaluations

3. **`talent_03_evaluation.surql`** (5,578 bytes - 5 entités)
   - Évaluations d'employés
   - Types d'évaluation
   - Structures organisationnelles

## Domaines fonctionnels

### 🎯 **1. Recrutement & Postes (7 entités)**

**Entités principales :**
- `app_recruitment` - Configuration du module
- `job_position` - Postes de travail avec critères
- `job_application` - Candidatures avec profils complets
- `hiring_stage` - Étapes du processus de recrutement
- `talent_source` - Sources de recrutement
- `sequence` - Séquences de numérotation
- `app` - Configuration application

**Fonctionnalités :**
- Création et gestion des postes
- Suivi des candidatures
- Processus de recrutement structuré
- Intégration avec les sources de talents

### 📚 **2. Formation & Compétences (7 entités)**

**Entités principales :**
- `training` - Formations avec programmes détaillés
- `training_category` - Catégories de formation
- `training_session` - Sessions programmées
- `training_register` - Inscriptions et participation
- `training_skill` - Compétences acquises
- `skill` - Référentiel de compétences
- `education_level` - Niveaux d'éducation

**Fonctionnalités :**
- Catalogue de formations
- Planification des sessions
- Gestion des inscriptions
- Suivi des compétences
- Certifications et évaluations

### ⭐ **3. Évaluation & Employés (5 entités)**

**Entités principales :**
- `appraisal` - Évaluations détaillées
- `appraisal_type` - Types d'évaluation
- `employee` - Profils employés étendus
- `company` - Structures d'entreprise
- `company_department` - Départements

**Fonctionnalités :**
- Évaluations périodiques
- Gestion de la performance
- Plans de développement
- Structure organisationnelle

## Champs clés et relations

### **Relations inter-modules**
- `job_application` → `job_position` (candidature vers poste)
- `training_register` → `training_session` (inscription vers session)
- `appraisal` → `employee` (évaluation vers employé)
- `employee` → `company_department` (employé vers département)

### **Champs métier importants**
- **Recrutement** : `status_select`, `hiring_stage`, `appreciation`
- **Formation** : `duration`, `rating`, `mandatory_training`
- **Évaluation** : `overall_rating`, `development_plan`, `next_review_date`

## Statuts et sélections

### **Statuts de candidature**
- `0` : Ouverte
- `1` : Embauchée
- `2` : Rejetée
- `3` : Annulée

### **Statuts de formation**
- `1` : Planifiée
- `2` : En cours
- `3` : Terminée
- `4` : Annulée

### **Statuts d'évaluation**
- `1` : Brouillon
- `2` : En cours
- `3` : Terminée
- `4` : Validée

## Intégrations

### **Modules dépendants**
- `axelor-base` (Company, Address, Sequence)
- `axelor-human-resource` (Employee, Department)
- `axelor-message` (EmailAddress, EmailAccount)

### **Fonctionnalités transversales**
- Gestion documentaire (MetaFile, DMSFile)
- Workflow de validation
- Notifications et emails
- Reporting et tableaux de bord

## Utilisation recommandée

### **Processus de recrutement**
1. Créer des postes (`job_position`)
2. Configurer les étapes (`hiring_stage`)
3. Recevoir les candidatures (`job_application`)
4. Suivre le processus jusqu'à l'embauche

### **Cycle de formation**
1. Définir les formations (`training`)
2. Programmer les sessions (`training_session`)
3. Gérer les inscriptions (`training_register`)
4. Suivre les compétences acquises (`training_skill`)

### **Évaluation des employés**
1. Configurer les types d'évaluation (`appraisal_type`)
2. Planifier les évaluations (`appraisal`)
3. Suivre les performances
4. Créer des plans de développement

## Migration technique

**Total des entités migrées :** 17/17 (100%)
**Fichiers SurrealDB :** 3
**Taille totale :** 18,424 bytes

**Statut :** ✅ Migration complète

---

*Module talent prêt pour la plateforme LYXAL - Décembre 2024* 