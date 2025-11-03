# 📋 Décisions Critiques – Knowledge System

**Date** : 2024  
**Statut** : ✅ Validé

---

## ✅ Décisions prises

### Décision 1 : Modèle de données officiel

**Choix** : ✅ `knowledge_domain/topic/content` est le modèle officiel

**Action** :
- ✅ Supprimer ou archiver les références à `knowledge_pack_*` 
- ✅ **TERMINÉ** : Le fichier `knowledge_documentation.md` a été supprimé

**Statut** : ✅ **COMPLÉTÉ** - Le modèle officiel est maintenant unifié et toutes les références à l'ancien modèle ont été supprimées.

**Justification** : Le modèle `knowledge_domain/topic/content` est implémenté et documenté dans la majorité des fichiers.

---

### Décision 2 : Système de keywords

**Choix** : ✅ Conserver les tables relationnelles `knowledge_domain_keyword` et `knowledge_topic_keyword` (déjà implémentées)

**Action** :
- ✅ **TERMINÉ** : La documentation reflète maintenant la réalité : strings libres dans les relations
- ✅ **TERMINÉ** : Toutes les références à la table `knowledge_keyword` ont été supprimées de la documentation
- ✅ **TERMINÉ** : `08_Knowledge_Keyword.md` réécrit pour refléter l'implémentation réelle
- ✅ **TERMINÉ** : `09_Knowledge_Relations.md` corrigé pour utiliser uniquement des strings

**Statut** : ✅ **COMPLÉTÉ** - La documentation est maintenant alignée avec l'implémentation réelle.

**Justification** : Les tables relationnelles sont déjà implémentées et fonctionnelles. La documentation doit être alignée avec l'implémentation réelle.

---

### Décision 3 : Tables `knowledge_category` et `knowledge_sub_category`

**Choix** : ✅ Conserver les références vers ces tables, elles seront créées plus tard

**Action** :
- ✅ Garder les références dans `knowledge_topic.surql`
- ✅ **TERMINÉ** : Fichiers `.surql` créés pour `knowledge_category` et `knowledge_sub_category`
- ✅ **TERMINÉ** : Index ajoutés sur les deux tables (code, slug, active, et category pour sub_category)
- ✅ **TERMINÉ** : Documentation créée (`04_Knowledge_Category.md` et `04_Knowledge_Sub_Category.md`)
- ✅ **TERMINÉ** : Rôle dans le système documenté avec exemples d'utilisation

**Statut** : ✅ **COMPLÉTÉ** - Les tables sont créées, indexées et documentées.

**Justification** : Ces tables sont nécessaires pour la catégorisation des topics. Elles seront créées lors de la complétion du système.

---

### Décision 4 : Approche i18n pour `knowledge_content`

**Choix** : ✅ Utiliser des clés i18n (aligné avec la vision multi-langue de l'application)

**⚠️ INCOHÉRENCE IDENTIFIÉE** :
- L'implémentation actuelle utilise du contenu direct (`identity.title`, `identity.description` en strings)
- La décision est d'utiliser des clés i18n
- **MIGRATION NÉCESSAIRE** : Modifier `knowledge_content.surql` pour utiliser des clés i18n

**Champs à migrer** :
- ✅ `identity.title` (option<string>) → `identity.title_key` (option<record<i18n_key>>) **TERMINÉ**
- ✅ `identity.description` (option<string>) → `identity.description_key` (option<record<i18n_key>>) **TERMINÉ**
- ✅ `content.text` (option<string>) → `content.text_key` (option<record<i18n_key>>) **TERMINÉ**
- ✅ `content.code.explanation` (option<string>) → `content.code.*.explanation_key` (option<record<i18n_key>>) **TERMINÉ** (avec wildcard *)
- ✅ `content.examples.correct.text` (option<string>) → `content.examples.correct.*.text_key` (option<record<i18n_key>>) **TERMINÉ** (avec wildcard *)
- ✅ `content.examples.incorrect.text` (option<string>) → `content.examples.incorrect.*.text_key` (option<record<i18n_key>>) **TERMINÉ** (avec wildcard *)
- ✅ `content.context` (option<string>) → `content.context_key` (option<record<i18n_key>>) **TERMINÉ**

**Champs qui restent en strings** (pas de traduction nécessaire) :
- `identity.slug` (string) → reste string
- `content.code.value` (string) → reste string (code source)
- `content.prompt` (option<string>) → peut rester string OU migrer vers clé i18n selon besoin
- `content.json` (option<object>) → reste object (données structurées)

**Action requise** :
- ✅ **TERMINÉ** : `knowledge_content.surql` modifié pour utiliser des clés i18n
- ✅ **TERMINÉ** : Syntaxe corrigée avec wildcard `*` pour les arrays d'objets (`content.code.*.explanation_key`, etc.)
- ✅ **TERMINÉ** : Document créé : `16_SurrealDB_Arrays_Objects_Syntax.md` (syntaxe essentielle pour création de données)
- ⏸️ Script de migration pour données existantes : **NON CRÉÉ** (les données de référence seront ré-alignées plus tard selon décision utilisateur)
- ✅ **TERMINÉ** : Documentation `06_Knowledge_Content.md` complètement réécrite avec structure U3-FLEX et i18n

**Statut** : ✅ **COMPLÉTÉ** - Le schéma est migré vers i18n et la documentation est à jour.

**Justification** : L'application est conçue multi-langue dès le départ, donc les clés i18n sont nécessaires pour tous les contenus textuels.

---

### Décision 5 : Tags vs Keywords

**Choix** : ✅ Conserver les deux systèmes (Tags ET Keywords), ils servent des objectifs différents

**Clarification** :
- **Tags** : Référentiel structuré via table globale `tag` (partagée entre tous les modules) → Catégorisation hiérarchique et organisation
- **Keywords** : Strings libres dans relations → Recherche sémantique full-text BM25

**Architecture Tags (modèle hybride)** :
- Table globale `tag` : Tags partagés entre tous les modules de Lyxal
- Table relation `tag_module` (optionnelle) : Métadonnées spécifiques par module (couleur, poids, etc.)
- **Règle** : Les records des modules référencent toujours `tag` (pas `knowledge_tag`)

**⚠️ INCOHÉRENCE IDENTIFIÉE ET CORRIGÉE** :
- ✅ `knowledge_topic.tags` utilise maintenant `record<tag>` → **CORRIGÉ**
- ✅ `knowledge_content.tags` utilise `record<tag>` → ✅ Correct
- ✅ `knowledge_domain.tags` utilise `record<tag>` → ✅ Correct

**Action requise** :
- ✅ **TERMINÉ** : `knowledge_topic.surql` corrigé : `record<knowledge_tag>` → `record<tag>`
- ✅ **TERMINÉ** : Différence entre Tags et Keywords documentée dans `08_Knowledge_Keyword.md`
- ✅ **TERMINÉ** : Architecture hybride Tags expliquée dans `08_Knowledge_Keyword.md`
- ✅ **TERMINÉ** : Guide complet d'utilisation Tags vs Keywords créé dans `08_Knowledge_Keyword.md`

**Statut** : ✅ **COMPLÉTÉ** - Toutes les tables utilisent la table globale `tag` et le guide est complet.

**Justification** : 
- Tags = organisation structurée et catégorisation hiérarchique (système global partagé)
- Keywords = recherche sémantique flexible et full-text (spécifique au Knowledge System)
- Architecture hybride permet tags partagés entre modules tout en gardant métadonnées spécifiques

---

## 📋 Plan d'actions immédiates

### ✅ Priorité CRITIQUE 🔴 - TERMINÉE

#### 1. Supprimer/migrer `knowledge_documentation.md`
- [x] ✅ **TERMINÉ** : Fichier supprimé
- [x] ✅ **TERMINÉ** : Aucune référence trouvée ailleurs
- [x] ✅ **TERMINÉ** : Index à jour (document non référencé)

#### 2. Corriger la documentation des keywords
- [x] ✅ **TERMINÉ** : Toutes les références à `knowledge_keyword` supprimées
- [x] ✅ **TERMINÉ** : `08_Knowledge_Keyword.md` réécrit pour refléter la réalité (strings libres)
- [x] ✅ **TERMINÉ** : `09_Knowledge_Relations.md` corrigé pour utiliser uniquement des strings

#### 3. Migration i18n de `knowledge_content`
- [x] ✅ **TERMINÉ** : `knowledge_content.surql` modifié pour utiliser des clés i18n
- [x] ✅ **TERMINÉ** : Syntaxe corrigée avec wildcard `*` pour arrays d'objets
- [x] ✅ **TERMINÉ** : Document créé : `16_SurrealDB_Arrays_Objects_Syntax.md`
- [x] ⏸️ Script de migration : **NON CRÉÉ** (décision utilisateur : données ré-alignées plus tard)

### ✅ Priorité HAUTE 🟡 - TERMINÉE

#### 4. Documenter `knowledge_category` et `knowledge_sub_category`
- [x] ✅ **TERMINÉ** : Fichiers `.surql` créés avec index complets
- [x] ✅ **TERMINÉ** : Documentation créée (`04_Knowledge_Category.md` et `04_Knowledge_Sub_Category.md`)
- [x] ✅ **TERMINÉ** : Rôle dans le système et utilisation documentés avec exemples

#### 5. Corriger et clarifier Tags vs Keywords
- [x] ✅ **TERMINÉ** : `knowledge_topic.surql` corrigé : `record<knowledge_tag>` → `record<tag>`
- [x] ✅ **TERMINÉ** : Différence entre Tags et Keywords documentée dans `08_Knowledge_Keyword.md`
- [x] ✅ **TERMINÉ** : Architecture hybride Tags expliquée
- [x] ✅ **TERMINÉ** : Guide complet d'utilisation Tags vs Keywords créé dans `08_Knowledge_Keyword.md`

---

## ✅ État d'avancement global

### Accomplissements majeurs

1. ✅ **Modèle de données unifié** : `knowledge_domain/topic/content` confirmé comme modèle officiel
2. ✅ **Documentation alignée** : Keywords, Relations, et Tags documentés selon l'implémentation réelle
3. ✅ **Système i18n cohérent** : Schéma `knowledge_content` migré vers clés i18n avec syntaxe correcte
4. ✅ **Clarification Tags vs Keywords** : Standardisation complète vers table globale `tag`
5. ✅ **Tables créées** : `knowledge_category` et `knowledge_sub_category` avec index complets
6. ✅ **Documentation technique** : `16_SurrealDB_Arrays_Objects_Syntax.md` créé pour référence future

---

## 🎯 Prochaines étapes

### ✅ Priorité IMMÉDIATE 🟡 - TERMINÉE

#### 1. Documentation des tables créées
- [x] ✅ **TERMINÉ** : Créé `04_Knowledge_Category.md` (documentation complète de la table)
- [x] ✅ **TERMINÉ** : Créé `04_Knowledge_Sub_Category.md` (documentation complète de la table)
- [x] ✅ **TERMINÉ** : Expliqué leur rôle dans le système de catégorisation
- [x] ✅ **TERMINÉ** : Donné des exemples d'utilisation pour chaque table

#### 2. Mise à jour de la documentation `knowledge_content`
- [x] ✅ **TERMINÉ** : Réécrit `06_Knowledge_Content.md` avec :
  - Structure U3-FLEX complète documentée
  - Clés i18n au lieu de strings (tous les champs migrés)
  - Syntaxe wildcard `*` pour arrays d'objets expliquée
  - Exemples de CREATE avec la nouvelle structure (4 exemples complets)

#### 3. Guide d'utilisation Tags vs Keywords
- [x] ✅ **TERMINÉ** : Enrichi `08_Knowledge_Keyword.md` avec :
  - Guide complet : quand utiliser Tags vs Keywords
  - Tableau comparatif détaillé
  - Cas d'usage concrets pour chaque système
  - Scénarios combinés (Tags + Keywords)
  - Bonnes pratiques et pièges à éviter
  - Résumé décisionnel clair

#### 6. API de requête optimisée IA (Tâche 18)
- [x] ✅ **TERMINÉ** : Créé 5 fonctions SurrealDB pour requêtes optimisées IA
  - ✅ `fn::knowledge_get_topic_bundle_for_ai()` - Bundle complet pour un topic avec filtrage par intention
  - ✅ `fn::knowledge_search_keywords_for_ai()` - Recherche par keywords avec scoring BM25
  - ✅ `fn::knowledge_get_content_by_type_for_ai()` - Contenus filtrés par type
  - ✅ `fn::knowledge_get_best_content_for_ai()` - Meilleur contenu selon critères
  - ✅ `fn::knowledge_get_domain_overview_for_ai()` - Vue d'ensemble domaine avec statistiques
- [x] ✅ **TERMINÉ** : Format de réponse optimisé pour prompts IA avec métadonnées
- [x] ✅ **TERMINÉ** : Filtrage automatique par qualité (`quality_score >= 0.7`)
- [x] ✅ **TERMINÉ** : Filtrage par intention (GENERATE_CODE, TEACH, VALIDATE, QUICK_HELP)
- [x] ✅ **TERMINÉ** : Documentation complète dans `function/README.md`
- [x] ✅ **TERMINÉ** : Script d'import mis à jour pour inclure les fonctions (`function/`)

### Priorité MOYENNE 🟢

#### 4. Vérification et tests
- [x] ✅ **TERMINÉ** : Vérification de cohérence des schémas complétée (rapport `18_Coherence_Verification_Report.md`)
- [x] ✅ **TERMINÉ** : Tests CREATE avec structure i18n effectués (rapport `19_Test_Report.md`)
  - ✅ Création de données complètes (domain, category, topic, content) avec i18n
  - ✅ Validation des index UNIQUE
  - ✅ Validation des relations CASCADE/REJECT
  - ✅ Structure U3-FLEX validée
- [x] ✅ **TERMINÉ** : Correction du modèle keywords (table `knowledge_keyword` créée)
  - ✅ Table `knowledge_keyword` créée (référentiel centralisé)
  - ✅ Tables relationnelles modifiées (`out` : `string` → `record<knowledge_keyword>`)
  - ✅ Recherche full-text validée
  - ✅ Relations avec records validées
- [x] ✅ **TERMINÉ** : Tests keywords et recherche full-text
  - ✅ Création de keywords fonctionne
  - ✅ Relations RELATE fonctionnent avec records
  - ✅ Recherche full-text opérationnelle (`@1@` sur `identity.value`)

#### 5. Documentation de référence
- [x] ✅ **TERMINÉ** : `00_INDEX.md` mis à jour avec tous les nouveaux documents
- [x] ✅ **TERMINÉ** : Guide de patterns de création créé (`17_Knowledge_Creation_Patterns.md`)
- [x] ✅ **TERMINÉ** : Schéma de référence unifié créé (`SCHEMA_Knowledge_System.md`)
- [x] ✅ **TERMINÉ** : Modèle de données complété (`10_Knowledge_Data_Model.md`)
- [x] ✅ **TERMINÉ** : Data Flow complété (`11_Knowledge_Data_Flow.md`)
- [x] ✅ **TERMINÉ** : Guide d'ajout corrigé (`08_How_to_Add_Knowledge.md`)
- [x] ✅ **TERMINÉ** : Métadonnées IA complétées (`07_Knowledge_Content_Type.md`)
- [ ] 🔄 Créer un guide de migration pour les données existantes (quand nécessaire - données de référence à ré-aligner plus tard)

---

## 📊 Résumé des fichiers modifiés/créés

### Fichiers supprimés
- ✅ `knowledge/documentation/knowledge_documentation.md` (ancien modèle)

### Fichiers modifiés
- ✅ `knowledge/database/knowledge_topic.surql` (tags corrigés)
- ✅ `knowledge/database/knowledge_content.surql` (migration i18n + syntaxe wildcard + quality_score)
- ✅ `knowledge/database/knowledge_domain_keyword.surql` (modifié : `out` devient `record<knowledge_keyword>`)
- ✅ `knowledge/database/knowledge_topic_keyword.surql` (modifié : `out` devient `record<knowledge_keyword>`)
- ✅ `knowledge/script/import/import-knowledge.mjs` (ajout support `function/` + vérification fonctions)
- ✅ `knowledge/documentation/08_Knowledge_Keyword.md` (réécrit + enrichi avec guide Tags vs Keywords)
- ✅ `knowledge/documentation/09_Knowledge_Relations.md` (corrigé)
- ✅ `knowledge/documentation/06_Knowledge_Content.md` (réécrit complètement avec U3-FLEX + quality_score)
- ✅ `knowledge/documentation/00_INDEX.md` (mis à jour avec nouveaux documents)
- ✅ `knowledge/documentation/📄 08_How_to_Add_Knowledge.md` (corrigé : types, syntaxe keywords, U3-FLEX)
- ✅ `knowledge/documentation/📄 10_Knowledge_Data_Model.md` (complété : schéma complet, diagramme, relations)
- ✅ `knowledge/documentation/📄 11_Knowledge_Data_Flow.md` (complété : cycle complet, métriques)
- ✅ `knowledge/documentation/07_Knowledge_Content_Type.md` (complété : métadonnées IA, guide d'utilisation)
- ✅ `knowledge/documentation/ANALYSIS_Knowledge_System_Review.md` (mis à jour : Tâche 17 et 18 terminées)
- ✅ `knowledge/documentation/SCHEMA_Knowledge_System.md` (mis à jour : quality_score ajouté)

### Fichiers créés
- ✅ `knowledge/database/knowledge_category.surql` (nouveau avec index)
- ✅ `knowledge/database/knowledge_sub_category.surql` (nouveau avec index)
- ✅ `knowledge/database/knowledge_keyword.surql` (nouveau - référentiel centralisé des keywords)
- ✅ `knowledge/function/fn_knowledge_get_topic_bundle_for_ai.surql` (nouveau - API IA)
- ✅ `knowledge/function/fn_knowledge_search_keywords_for_ai.surql` (nouveau - API IA)
- ✅ `knowledge/function/fn_knowledge_get_content_by_type_for_ai.surql` (nouveau - API IA)
- ✅ `knowledge/function/fn_knowledge_get_best_content_for_ai.surql` (nouveau - API IA)
- ✅ `knowledge/function/fn_knowledge_get_domain_overview_for_ai.surql` (nouveau - API IA)
- ✅ `knowledge/function/README.md` (nouveau - documentation API IA)
- ✅ `knowledge/documentation/04_Knowledge_Category.md` (nouveau)
- ✅ `knowledge/documentation/04_Knowledge_Sub_Category.md` (nouveau)
- ✅ `knowledge/documentation/05_Knowledge_Keyword.md` (nouveau - documentation table knowledge_keyword)
- ✅ `knowledge/documentation/16_SurrealDB_Arrays_Objects_Syntax.md` (nouveau)
- ✅ `knowledge/documentation/17_Knowledge_Creation_Patterns.md` (nouveau - guide complet)
- ✅ `knowledge/documentation/18_Coherence_Verification_Report.md` (nouveau - rapport de vérification)
- ✅ `knowledge/documentation/19_Test_Report.md` (nouveau - rapport de tests)
- ✅ `knowledge/documentation/SCHEMA_Knowledge_System.md` (nouveau - schéma de référence unifié)

---

## 🎉 Statut actuel

**Phase 1 : Décisions et corrections critiques** → ✅ **TERMINÉE**

**Phase 2 : Documentation et finalisation** → ✅ **TERMINÉE**

**Phase 3 : Vérification et tests** → ✅ **TERMINÉE** (tests principaux réussis - 95%+ de réussite)

Le système Knowledge est maintenant :
- ✅ Cohérent au niveau schéma
- ✅ Aligné avec la vision stratégique
- ✅ Prêt pour l'internationalisation
- ✅ Testé et validé avec données réelles
- ✅ **Modèle keywords corrigé** (référentiel centralisé avec records)
- ✅ **Recherche full-text opérationnelle**
- ✅ **API de requête optimisée IA** (5 fonctions disponibles)
- ✅ Prêt pour utilisation en production
- ✅ Documentation complète pour toutes les tables
- ✅ Guide Tags vs Keywords complet
- ✅ Documentation U3-FLEX complète
- ✅ Toutes les tables documentées avec exemples
- ✅ **Score de qualité implémenté** (`metadata.quality_score`)
- ✅ **Analytics & métriques de base** (`metadata.analytics` : view_count, last_viewed, ai_usage_count)
- ✅ **Fonctions de tracking** (dans `function/tracking/` : 4 fonctions pour automatiser le tracking)
- ✅ **Table `knowledge_feedback`** (feedback sur les contenus pour amélioration continue v3)
- ✅ **Table `knowledge_gap` + fonctions de détection** (détection automatique de lacunes pour v3 – Self-Learning)