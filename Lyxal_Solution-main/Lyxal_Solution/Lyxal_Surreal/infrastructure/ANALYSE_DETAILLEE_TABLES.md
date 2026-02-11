# 🔍 Analyse Détaillée des 93 Tables Bunny.net Restantes

**Date**: 2025-10-25  
**Après nettoyage** : 93 tables (supprimé : 88 tables)

---

## 📊 Classification Finale par Type

### 🟢 **CATÉGORIE 1 : Tables Essentielles à GARDER** (42 tables)

#### A. Entités Principales (13 tables) ✅
| # | Table | Raison | Statut |
|---|-------|--------|--------|
| 1 | `bunny_pull_zone_model` | Entité CDN principale | ✅ GARDER |
| 2 | `bunny_dns_zone_model` | Entité DNS principale | ✅ GARDER |
| 3 | `bunny_dns_record_model` | Entité DNS record principale | ✅ GARDER |
| 4 | `bunny_storage_zone_model` | Entité stockage principale | ✅ GARDER |
| 5 | `bunny_video_library_model` | Entité vidéo library principale | ✅ GARDER |
| 6 | `bunny_video_model` | Entité vidéo principale | ✅ GARDER |
| 7 | `bunny_collection_model` | Entité collection vidéo | ✅ GARDER |
| 8 | `bunny_edge_script_model` | Entité edge script principale | ✅ GARDER |
| 9 | `bunny_api_key_model` | Entité API key | ✅ GARDER |
| 10 | `bunny_country` | Référentiel pays | ✅ GARDER |
| 11 | `bunny_region_model` | Référentiel régions Bunny | ✅ GARDER |
| 12 | `bunny_team_member_model` | Entité membre d'équipe | ✅ GARDER |
| 13 | `bunny_support_ticket_model` | Entité ticket support | ✅ GARDER |

#### B. Sous-Ressources/Relations (12 tables) ✅
| # | Table | Parent | Statut |
|---|-------|--------|--------|
| 14 | `bunny_hostname_model` | Pull Zone | ✅ GARDER |
| 15 | `bunny_edge_script_variable_model` | Edge Script | ✅ GARDER |
| 16 | `bunny_edge_script_secret_model` | Edge Script | ✅ GARDER |
| 17 | `bunny_edge_script_release_model` | Edge Script | ✅ GARDER |
| 18 | `bunny_edge_rule_v2_model` | Pull Zone | ✅ GARDER |
| 19 | `bunny_caption_model` | Video | ✅ GARDER |
| 20 | `bunny_chapter_model` | Video | ✅ GARDER |
| 21 | `bunny_moment_model` | Video | ✅ GARDER |
| 22 | `bunny_meta_tag_model` | Video | ✅ GARDER |
| 23 | `bunny_support_ticket_comment_model` | Support Ticket | ✅ GARDER |
| 24 | `bunny_support_ticket_attachment_model` | Support Ticket | ✅ GARDER |
| 25 | `bunny_billing_record_model` | User/Account | ✅ GARDER |

#### C. Sécurité WAF/Shield (4 tables) ✅
| # | Table | Type | Statut |
|---|-------|------|--------|
| 26 | `bunny_custom_waf_rule` | Règle WAF custom | ✅ GARDER |
| 27 | `bunny_waf_rule_group_model` | Groupe de règles WAF | ✅ GARDER |
| 28 | `bunny_rate_limit_rule` | Règle rate limiting | ✅ GARDER |
| 29 | `bunny_drm_certificate_model` | Certificat DRM | ✅ GARDER |

#### D. Intégrations (6 tables) ✅
| # | Table | Type | Statut |
|---|-------|------|--------|
| 30 | `bunny_abuse_case_model` | Cas d'abus | ✅ GARDER |
| 31 | `bunny_abuse_case_url_model` | URL d'abus | ✅ GARDER |
| 32 | `bunny_billing_saved_payment_method` | Méthode de paiement | ✅ GARDER |
| 33 | `bunny_github_repository_model` | Repo GitHub | ✅ GARDER |
| 34 | `bunny_github_repository_branch_model` | Branche GitHub | ✅ GARDER |
| 35 | `bunny_connected_github_account_model` | Compte GitHub | ✅ GARDER |

#### E. Données Utiles (2 tables) ✅
| # | Table | Type | Statut |
|---|-------|------|--------|
| 36 | `bunny_video_heatmap_model` | Heatmap vidéo (analytics) | ✅ GARDER |
| 37 | `bunny_linked_pull_zone` | Lien entre pull zones | ✅ GARDER |

#### F. Tables Manuelles (4 tables) ✅
| # | Table | Type | Statut |
|---|-------|------|--------|
| 38 | `bunny_cdn` | Table manuelle CDN | ✅ GARDER |
| 39 | `bunny_containers` | Table manuelle Containers | ✅ GARDER |
| 40 | `bunny_storage` | Table manuelle Storage | ✅ GARDER |
| 41 | `infrastructure_logs` | Logs infrastructure | ✅ GARDER |

#### G. Objet de Stockage (1 table) ✅
| # | Table | Type | Statut |
|---|-------|------|--------|
| 42 | `bunny_storage_object` | Fichier stocké | ✅ GARDER |

---

## 🔴 **CATÉGORIE 2 : DOUBLONS à SUPPRIMER** (3 tables)

| # | Table | Doublon de | Raison | Statut |
|---|-------|------------|--------|--------|
| 1 | `bunny_waf_rule_model` | `bunny_waf_rule` | 2 tables quasi identiques pour WAF rules | ❌ SUPPRIMER |
| 2 | `bunny_storage_object_model` | `bunny_storage_object` | 2 tables identiques pour storage objects | ❌ SUPPRIMER |
| 3 | `bunny_pull_zone_optimizer_class_model` | `bunny_optimizer_class_model` | Tables identiques (même structure) | ❌ SUPPRIMER |

**Détails des doublons** :

#### 1. `bunny_waf_rule` vs `bunny_waf_rule_model`
```
bunny_waf_rule: total_triggers, blocked_requests, logged_requests, challenged_requests
bunny_waf_rule_model: rule_id, description
```
→ **Garder** : `bunny_waf_rule` (données plus riches)  
→ **Supprimer** : `bunny_waf_rule_model`

#### 2. `bunny_storage_object` vs `bunny_storage_object_model`
```
Exactement la même structure ! (guid, path, object_name, length, etc.)
```
→ **Garder** : `bunny_storage_object` (commentaires plus complets)  
→ **Supprimer** : `bunny_storage_object_model`

#### 3. `bunny_optimizer_class_model` vs `bunny_pull_zone_optimizer_class_model`
```
Exactement la même structure ! (name, properties)
```
→ **Garder** : `bunny_optimizer_class_model`  
→ **Supprimer** : `bunny_pull_zone_optimizer_class_model`

---

## 🟠 **CATÉGORIE 3 : Tables TEMPORAIRES à SUPPRIMER** (8 tables)

| # | Table | Type | Raison | Statut |
|---|-------|------|--------|--------|
| 1 | `bunny_caption_model_add` | Action temporaire | Données d'ajout de caption (action POST) | ❌ SUPPRIMER |
| 2 | `bunny_caption_validation_model` | Résultat temporaire | Résultat de validation (valid, error_list) | ❌ SUPPRIMER |
| 3 | `bunny_video_o_embed_model` | Résultat temporaire | Résultat OEmbed (généré à la demande) | ❌ SUPPRIMER |
| 4 | `bunny_transcoding_message_model` | Message temporaire | Messages de transcodage (logs) | ❌ SUPPRIMER |
| 5 | `bunny_status_model` | Résultat temporaire | Résultat d'opération API (success, message, status_code) | ❌ SUPPRIMER |
| 6 | `bunny_log` | Log temporaire | Remplacé par `infrastructure_logs` | ❌ SUPPRIMER |
| 7 | `bunny_trigger` | Trigger temporaire | Trigger générique (type indéfini) | ❌ SUPPRIMER |
| 8 | `bunny_triggered_rule_item` | Log temporaire | Règle déclenchée (log WAF) | ❌ SUPPRIMER |

---

## 🟡 **CATÉGORIE 4 : SOUS-CHAMPS à TRANSFORMER en JSON** (15 tables)

Ces tables représentent des **objets imbriqués** qui devraient être des champs JSON dans leur table parente :

### Groupe A : Configuration DRM (2 tables)
| # | Table | Champs | Parent | Statut |
|---|-------|--------|--------|--------|
| 1 | `bunny_apple_fair_play_drm` | enabled, certificate_id, certificate_expiration_date, provider | `bunny_video_library_model` | 🔄 JSON |
| 2 | `bunny_google_widevine_drm` | enabled, certificate_id, certificate_expiration_date, provider, sd_only_for_l3 | `bunny_video_library_model` | 🔄 JSON |

**Recommandation** : Ajouter un champ `drm_config: object` dans `bunny_video_library_model`

### Groupe B : Configuration DNS (3 tables)
| # | Table | Champs | Parent | Statut |
|---|-------|--------|--------|--------|
| 3 | `bunny_dns_sec_ds_record_model` | enabled, ds_record, digest, algorithm, key_tag, flags, ds_configured | `bunny_dns_zone_model` | 🔄 JSON |
| 4 | `bunny_geo_dns_location_model` | country_code, country, a_s_n, organization_name, city | `bunny_dns_record_model` | 🔄 JSON |
| 5 | `bunny_dns_record_enviromental_variable_model` | name, value | `bunny_dns_record_model` | 🔄 JSON |

**Recommandation** : 
- Ajouter `dnssec_config: object` dans `bunny_dns_zone_model`
- Ajouter `geo_location: object` dans `bunny_dns_record_model`
- Ajouter `env_variables: array<object>` dans `bunny_dns_record_model`

### Groupe C : Configuration Edge Rules (1 table)
| # | Table | Champs | Parent | Statut |
|---|-------|--------|--------|--------|
| 6 | `bunny_edge_rule_v2_action_model` | action_type, action_parameter1, action_parameter2, action_parameter3 | `bunny_edge_rule_v2_model` | 🔄 JSON |

**Recommandation** : Ajouter `actions: array<object>` dans `bunny_edge_rule_v2_model`

### Groupe D : Configuration Optimizer (2 tables)
| # | Table | Champs | Parent | Statut |
|---|-------|--------|--------|--------|
| 7 | `bunny_optimizer_class_model` | name, properties | `bunny_pull_zone_model` | 🔄 JSON |
| 8 | `bunny_resolution_reference` | name, width, height | `bunny_video_model` | 🔄 JSON |

**Recommandation** : Stocker comme champs JSON dans les tables parentes

### Groupe E : Configuration Video (1 table)
| # | Table | Champs | Parent | Statut |
|---|-------|--------|--------|--------|
| 9 | `bunny_video_resolutions_info_model` | video_id, available_resolutions, configured_resolutions, playlist_resolutions, etc. | `bunny_video_model` | 🔄 JSON |

**Recommandation** : Ajouter `resolutions_info: object` dans `bunny_video_model`

### Groupe F : Divers (6 tables)
| # | Table | Champs | Parent | Statut |
|---|-------|--------|--------|--------|
| 10 | `bunny_support_ticket_user_model` | name, external_id, alias, verified, signature, role, photo_url | `bunny_support_ticket_model` | 🔄 JSON |
| 11 | `bunny_deploy_configuration_model` | Config déploiement | `bunny_edge_script_model` | 🔄 JSON |
| 12 | `bunny_source_code_integration_model` | Config intégration | `bunny_edge_script_model` | 🔄 JSON |
| 13 | `bunny_config_variable_value_minimal` | Variable de config | Parent inconnu | 🔄 JSON |
| 14 | `bunny_transcribe_settings` | Settings transcription | `bunny_video_library_model` | 🔄 JSON |
| 15 | `bunny_dns_record_geo_location_info` | Info géo | `bunny_dns_record_model` | 🔄 JSON |

---

## 🔵 **CATÉGORIE 5 : STATISTIQUES** (10 tables) - DÉCISION UTILISATEUR

| # | Table | Type | Utilité | Recommandation |
|---|-------|------|---------|----------------|
| 1 | `bunny_dns_zone_statistics_model` | Stats DNS | Queries, bandwidth | ⚠️ À décider |
| 2 | `bunny_storage_zone_statistics_model` | Stats Storage | GB, files | ⚠️ À décider |
| 3 | `bunny_video_statistics_model` | Stats Video | Vues, durée | ⚠️ À décider |
| 4 | `bunny_video_play_data_model` | Données lecture | Play count, etc. | ⚠️ À décider |
| 5 | `bunny_edge_script_statistics_model` | Stats Edge Scripts | Exécutions | ⚠️ À décider |
| 6 | `bunny_statistics_model` | Stats globales | Global account | ⚠️ À décider |
| 7 | `bunny_optimizer_statistics_model` | Stats Optimizer | Optimisation | ⚠️ À décider |
| 8 | `bunny_origin_shield_concurrency_statistics_model` | Stats Origin Shield | Concurrency | ⚠️ À décider |
| 9 | `bunny_safe_hop_statistics_model` | Stats SafeHop | SafeHop perf | ⚠️ À décider |
| 10 | `bunny_server_zone_statistics_model` | Stats par région | Regional | ⚠️ À décider |

**Options** :
- ✅ **Garder** si vous voulez un historique des statistiques
- ❌ **Supprimer** si vous récupérez les stats en temps réel via API
- 🔄 **Créer une table générique** `infrastructure_statistics_cache` avec TTL

---

## 🟣 **CATÉGORIE 6 : WAF/Shield à CLARIFIER** (11 tables)

| # | Table | Type | Utilité | Statut |
|---|-------|------|---------|--------|
| 1 | `bunny_waf` | Config WAF globale | Configuration WAF principale | ⚠️ Vérifier utilité |
| 2 | `bunny_waf_profile_minimal` | Profil WAF | Profile de règles | ⚠️ Vérifier utilité |
| 3 | `bunny_waf_mapped_enum` | Enum mappé | Données de référence | ⚠️ Peut être JSON |
| 4 | `bunny_waf_mapped_enum_list` | Liste enums | Données de référence | ⚠️ Peut être JSON |
| 5 | `bunny_waf_rule_main_group_model` | Groupe principal | Hiérarchie WAF | ⚠️ Vérifier vs waf_rule_group_model |
| 6 | `bunny_waf_rule_metrics` | Métriques WAF | Stats règles | ⚠️ Temporaire? |
| 7 | `bunny_pull_zone_waf_config_variable_model` | Variable config WAF | Config PZ | ⚠️ Peut être JSON |
| 8 | `bunny_ratelimit` | Rate limit global | Config rate limit | ⚠️ Vérifier utilité |
| 9 | `bunny_individual_ratelimit` | Rate limit individuel | Config individuelle | ⚠️ Peut être JSON |
| 10 | `bunny_ratelimit_metrics` | Métriques rate limit | Stats | ⚠️ Temporaire? |
| 11 | `bunny_shield_overview` | Vue Shield | Dashboard | ⚠️ Temporaire? |
| 12 | `bunny_shield_zone_metrics` | Métriques Shield | Stats | ⚠️ Temporaire? |
| 13 | `bunny_shield_zone_ratelimit` | Rate limit Shield | Config | ⚠️ Vérifier utilité |
| 14 | `bunny_shield_zone_ratelimit_metrics` | Métriques Shield RL | Stats | ⚠️ Temporaire? |
| 15 | `bunny_d_do_s` | Config DDoS | Config DDoS | ⚠️ Vérifier utilité |

**Recommandation** : Besoin de voir les fonctions d'API pour comprendre lesquelles sont vraiment utilisées.

---

## 🟤 **CATÉGORIE 7 : Divers à VÉRIFIER** (4 tables)

| # | Table | Type | Utilité | Statut |
|---|-------|------|---------|--------|
| 1 | `bunny_pull_zone_purge_model` | Historique purge | Audit des purges | ⚠️ Utile pour audit? |
| 2 | `bunny_bunny_ai_image_blueprint_model` | Blueprint AI | Config AI image | ⚠️ Vérifier utilité |
| 3 | `bunny_support_ticket_upload_attachment_model` | Upload attachment | Upload temporaire | ⚠️ Temporaire? |
| 4 | `bunny_labels` | Labels génériques | Tags/labels | ⚠️ Vérifier utilité |

---

## 📊 RÉSUMÉ FINAL

| Catégorie | Nombre | Action | Priorité |
|-----------|--------|--------|----------|
| ✅ **Tables Essentielles** | 42 | **GARDER** | ✅ Fait |
| ❌ **Doublons** | 3 | **SUPPRIMER** | 🔴 Haute |
| ❌ **Tables Temporaires** | 8 | **SUPPRIMER** | 🔴 Haute |
| 🔄 **Sous-champs → JSON** | 15 | **TRANSFORMER** | 🟡 Moyenne |
| ⚠️ **Statistiques** | 10 | **À DÉCIDER** | 🔵 Utilisateur |
| ⚠️ **WAF/Shield** | 15 | **À VÉRIFIER** | 🟡 Moyenne |
| ⚠️ **Divers** | 4 | **À VÉRIFIER** | 🟢 Basse |

**Total actuel** : 93 tables

**Après nettoyage recommandé** :
- Suppressions immédiates : **-11 tables** (doublons + temporaires)
- Transformations JSON : **-15 tables** (si transformées)
- Statistiques (selon choix) : **-0 ou -10 tables**
- WAF/Shield à clarifier : **-0 à -8 tables** (selon analyse)

**Résultat optimal attendu** : **45-60 tables** (au lieu de 93)

---

## 🎯 PLAN D'ACTION RECOMMANDÉ

### Phase 1 : Suppressions Immédiates (11 tables) 🔴
1. ❌ Supprimer 3 doublons
2. ❌ Supprimer 8 tables temporaires

### Phase 2 : Décision Statistiques (10 tables) 🔵
- ⚠️ Décision utilisateur : Garder ou supprimer?

### Phase 3 : Analyse WAF/Shield (15 tables) 🟡
- 🔍 Analyser les fonctions d'API pour comprendre l'utilisation
- 📋 Déterminer lesquelles sont vraiment nécessaires

### Phase 4 : Transformation JSON (15 tables) 🟢
- 🔄 Migrer les sous-champs vers JSON dans tables parentes
- 📝 Mettre à jour les fonctions d'API en conséquence

---

## 💡 Recommandation Finale

**Suppression immédiate recommandée** : **11 tables**
- 3 doublons
- 8 temporaires

**Résultat immédiat** : **93 → 82 tables** (-12%)

**Après toutes les optimisations** : **45-60 tables** (-35% à -48%)

