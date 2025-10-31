# Analyse Complète des Tables Bunny.net

**Date**: 2025-10-25  
**Total des tables restantes**: 106 tables

## Légende

- ✅ **GARDER** : Table représentant une entité réelle à persister
- ⚠️ **À VÉRIFIER** : Table potentiellement inutile ou à clarifier
- ❌ **SUPPRIMER** : Table temporaire ou inutile
- 🔄 **RELATION** : Table de relation/sous-ressource

---

## 📊 Analyse par Catégorie

### 1️⃣ **Tables Principales (Entités Core)** - 13 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_pull_zone_model` | ✅ **GARDER** | Entité principale - Pull Zone CDN |
| `bunny_dns_zone_model` | ✅ **GARDER** | Entité principale - Zone DNS |
| `bunny_dns_record_model` | ✅ **GARDER** | Entité principale - Record DNS |
| `bunny_storage_zone_model` | ✅ **GARDER** | Entité principale - Zone de stockage |
| `bunny_video_library_model` | ✅ **GARDER** | Entité principale - Library vidéo |
| `bunny_video_model` | ✅ **GARDER** | Entité principale - Vidéo |
| `bunny_collection_model` | ✅ **GARDER** | Entité principale - Collection vidéo |
| `bunny_edge_script_model` | ✅ **GARDER** | Entité principale - Edge Script |
| `bunny_api_key_model` | ✅ **GARDER** | Entité principale - API Key |
| `bunny_country` | ✅ **GARDER** | Entité principale - Pays (implémenté manuellement) |
| `bunny_region_model` | ✅ **GARDER** | Entité principale - Régions Bunny.net |
| `bunny_team_member_model` | ✅ **GARDER** | Entité principale - Membres d'équipe |
| `bunny_support_ticket_model` | ✅ **GARDER** | Entité principale - Tickets de support |

**Total : 13 tables ✅**

---

### 2️⃣ **Tables de Relations/Sous-Ressources** - 15 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_hostname_model` | ✅ **GARDER** | Sous-ressource - Hostname d'une Pull Zone |
| `bunny_edge_script_variable_model` | ✅ **GARDER** | Sous-ressource - Variable d'un Edge Script |
| `bunny_edge_script_secret_model` | ✅ **GARDER** | Sous-ressource - Secret d'un Edge Script |
| `bunny_edge_script_release_model` | ✅ **GARDER** | Sous-ressource - Release d'un Edge Script |
| `bunny_edge_rule_v2_model` | ✅ **GARDER** | Sous-ressource - Edge Rule d'une Pull Zone |
| `bunny_edge_rule_v2_action_model` | ⚠️ **À VÉRIFIER** | Sous-sous-ressource - Action d'une Edge Rule (peut-être juste un champ JSON?) |
| `bunny_caption_model` | ✅ **GARDER** | Sous-ressource - Caption d'une vidéo |
| `bunny_chapter_model` | ✅ **GARDER** | Sous-ressource - Chapitre d'une vidéo |
| `bunny_moment_model` | ✅ **GARDER** | Sous-ressource - Moment d'une vidéo |
| `bunny_meta_tag_model` | ✅ **GARDER** | Sous-ressource - Meta tag d'une vidéo |
| `bunny_support_ticket_comment_model` | ✅ **GARDER** | Sous-ressource - Commentaire d'un ticket |
| `bunny_support_ticket_attachment_model` | ✅ **GARDER** | Sous-ressource - Pièce jointe d'un ticket |
| `bunny_support_ticket_user_model` | ⚠️ **À VÉRIFIER** | Peut-être juste une référence user? |
| `bunny_billing_record_model` | ✅ **GARDER** | Sous-ressource - Facture/record de billing |
| `bunny_dns_record_enviromental_variable_model` | ⚠️ **À VÉRIFIER** | Variable d'environnement pour DNS Record (utilisé?) |

**Total : 12 tables ✅ / 3 tables ⚠️**

---

### 3️⃣ **Tables de Statistiques** - 11 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_dns_zone_statistics_model` | ⚠️ **À VÉRIFIER** | Statistiques temporaires ou à persister? |
| `bunny_storage_zone_statistics_model` | ⚠️ **À VÉRIFIER** | Statistiques temporaires ou à persister? |
| `bunny_video_statistics_model` | ⚠️ **À VÉRIFIER** | Statistiques temporaires ou à persister? |
| `bunny_video_heatmap_model` | ✅ **GARDER** | Heatmap vidéo (données utiles à persister) |
| `bunny_video_play_data_model` | ⚠️ **À VÉRIFIER** | Données de lecture (temporaire?) |
| `bunny_edge_script_statistics_model` | ⚠️ **À VÉRIFIER** | Statistiques temporaires ou à persister? |
| `bunny_statistics_model` | ⚠️ **À VÉRIFIER** | Statistiques globales (temporaire?) |
| `bunny_optimizer_statistics_model` | ⚠️ **À VÉRIFIER** | Stats optimizer (temporaire?) |
| `bunny_origin_shield_concurrency_statistics_model` | ⚠️ **À VÉRIFIER** | Stats origin shield (temporaire?) |
| `bunny_safe_hop_statistics_model` | ⚠️ **À VÉRIFIER** | Stats SafeHop (temporaire?) |
| `bunny_server_zone_statistics_model` | ⚠️ **À VÉRIFIER** | Stats server zone (temporaire?) |

**Recommandation** : Les statistiques sont généralement **temporaires** et récupérées via API. À moins d'avoir un besoin de cache ou d'historique, ces tables peuvent être **supprimées**.

**Total : 1 table ✅ / 10 tables ⚠️**

---

### 4️⃣ **Tables de Configuration/Métadonnées** - 12 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_dns_sec_ds_record_model` | ⚠️ **À VÉRIFIER** | Record DNSSEC (peut-être juste un champ dans bunny_dns_zone?) |
| `bunny_geo_dns_location_model` | ⚠️ **À VÉRIFIER** | Localisation géo pour DNS (sous-champ?) |
| `bunny_dns_record_geo_location_info` | ⚠️ **À VÉRIFIER** | Info géo pour DNS record (sous-champ?) |
| `bunny_drm_certificate_model` | ✅ **GARDER** | Certificat DRM (entité) |
| `bunny_apple_fair_play_drm` | ⚠️ **À VÉRIFIER** | Config DRM spécifique (sous-champ?) |
| `bunny_google_widevine_drm` | ⚠️ **À VÉRIFIER** | Config DRM spécifique (sous-champ?) |
| `bunny_optimizer_class_model` | ⚠️ **À VÉRIFIER** | Classe optimizer (enum/config?) |
| `bunny_pull_zone_optimizer_class_model` | ⚠️ **À VÉRIFIER** | Classe optimizer pour PZ (sous-champ?) |
| `bunny_deploy_configuration_model` | ⚠️ **À VÉRIFIER** | Config déploiement (temporaire?) |
| `bunny_source_code_integration_model` | ⚠️ **À VÉRIFIER** | Config intégration code source (sous-champ?) |
| `bunny_config_variable_value_minimal` | ⚠️ **À VÉRIFIER** | Variable de config (sous-champ?) |
| `bunny_transcribe_settings` | ⚠️ **À VÉRIFIER** | Settings transcription (config temporaire?) |

**Recommandation** : La plupart sont probablement des **sous-champs JSON** plutôt que des tables séparées.

**Total : 1 table ✅ / 11 tables ⚠️**

---

### 5️⃣ **Tables WAF/Shield (Bunny Shield)** - 20 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_custom_waf_rule` | ✅ **GARDER** | Règle WAF custom (entité) |
| `bunny_waf_rule` | ✅ **GARDER** | Règle WAF (entité) |
| `bunny_waf_rule_model` | ⚠️ **À VÉRIFIER** | Doublon de waf_rule? |
| `bunny_waf_rule_group_model` | ✅ **GARDER** | Groupe de règles WAF |
| `bunny_waf_rule_main_group_model` | ⚠️ **À VÉRIFIER** | Groupe principal (hiérarchie?) |
| `bunny_waf_rule_metrics` | ⚠️ **À VÉRIFIER** | Métriques WAF (temporaire?) |
| `bunny_waf` | ⚠️ **À VÉRIFIER** | Configuration WAF globale? |
| `bunny_waf_profile_minimal` | ⚠️ **À VÉRIFIER** | Profil WAF minimal (config?) |
| `bunny_waf_mapped_enum` | ⚠️ **À VÉRIFIER** | Enum mappé (données de ref?) |
| `bunny_waf_mapped_enum_list` | ⚠️ **À VÉRIFIER** | Liste d'enums (données de ref?) |
| `bunny_pull_zone_waf_config_variable_model` | ⚠️ **À VÉRIFIER** | Variable de config WAF (sous-champ?) |
| `bunny_rate_limit_rule` | ✅ **GARDER** | Règle de rate limiting (entité) |
| `bunny_ratelimit` | ⚠️ **À VÉRIFIER** | Config rate limit globale? |
| `bunny_individual_ratelimit` | ⚠️ **À VÉRIFIER** | Rate limit individuel (sous-champ?) |
| `bunny_ratelimit_metrics` | ⚠️ **À VÉRIFIER** | Métriques rate limit (temporaire?) |
| `bunny_shield_overview` | ⚠️ **À VÉRIFIER** | Vue d'ensemble shield (temporaire?) |
| `bunny_shield_zone_metrics` | ⚠️ **À VÉRIFIER** | Métriques shield zone (temporaire?) |
| `bunny_shield_zone_ratelimit` | ⚠️ **À VÉRIFIER** | Rate limit shield zone (config?) |
| `bunny_shield_zone_ratelimit_metrics` | ⚠️ **À VÉRIFIER** | Métriques (temporaire?) |
| `bunny_d_do_s` | ⚠️ **À VÉRIFIER** | Config DDoS? |

**Recommandation** : Garder les **entités principales** (règles WAF custom, groupes), supprimer les **métriques et configs temporaires**.

**Total : 4 tables ✅ / 16 tables ⚠️**

---

### 6️⃣ **Tables de Support/Métadonnées Système** - 15 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_abuse_case_model` | ✅ **GARDER** | Cas d'abus (entité) |
| `bunny_abuse_case_url_model` | 🔄 **GARDER** | URL d'un cas d'abus (relation) |
| `bunny_api_error_data` | ❌ **SUPPRIMER** | Données d'erreur API (temporaire, jamais persisté) |
| `bunny_error_object` | ❌ **SUPPRIMER** | Objet erreur générique (temporaire) |
| `bunny_status_model` | ⚠️ **À VÉRIFIER** | Statut générique (enum?) |
| `bunny_trigger` | ⚠️ **À VÉRIFIER** | Trigger générique? |
| `bunny_triggered_rule_item` | ⚠️ **À VÉRIFIER** | Règle déclenchée (log?) |
| `bunny_log` | ⚠️ **À VÉRIFIER** | Log générique (remplacé par infrastructure_log?) |
| `bunny_labels` | ⚠️ **À VÉRIFIER** | Labels génériques (config?) |
| `bunny_billing_saved_payment_method` | ✅ **GARDER** | Méthode de paiement sauvegardée |
| `bunny_github_repository_model` | ✅ **GARDER** | Repo GitHub lié (Edge Scripting) |
| `bunny_github_repository_branch_model` | 🔄 **GARDER** | Branche d'un repo GitHub |
| `bunny_connected_github_account_model` | ✅ **GARDER** | Compte GitHub connecté |
| `bunny_linked_pull_zone` | 🔄 **GARDER** | Pull Zone liée (relation) |
| `bunny_server_zone_results_model` | ⚠️ **À VÉRIFIER** | Résultats server zone (temporaire?) |

**Total : 6 tables ✅ / 2 tables 🔄 / 1 table ❌ / 6 tables ⚠️**

---

### 7️⃣ **Tables Vidéo Stream (Spécifiques)** - 8 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_transcoding_message_model` | ⚠️ **À VÉRIFIER** | Message de transcodage (temporaire/queue?) |
| `bunny_caption_model_add` | ⚠️ **À VÉRIFIER** | Caption add (doublon?) |
| `bunny_caption_validation_model` | ⚠️ **À VÉRIFIER** | Validation caption (temporaire?) |
| `bunny_video_library_drm_statistics_model` | ⚠️ **À VÉRIFIER** | Stats DRM (temporaire?) |
| `bunny_video_library_transcription_statistics_model` | ⚠️ **À VÉRIFIER** | Stats transcription (temporaire?) |
| `bunny_video_o_embed_model` | ⚠️ **À VÉRIFIER** | Données OEmbed (temporaire?) |
| `bunny_video_resolutions_info_model` | ⚠️ **À VÉRIFIER** | Info résolutions (config?) |
| `bunny_resolution_reference` | ⚠️ **À VÉRIFIER** | Référence résolution (enum?) |

**Recommandation** : La plupart sont **temporaires** ou des **configs**.

**Total : 0 table ✅ / 8 tables ⚠️**

---

### 8️⃣ **Tables Edge Scripting (Spécifiques)** - 7 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_edge_script_add_secret_model` | ⚠️ **À VÉRIFIER** | Secret add (doublon avec edge_script_secret_model?) |
| `bunny_edge_script_update_secret_model` | ⚠️ **À VÉRIFIER** | Secret update (doublon?) |
| `bunny_edge_script_upsert_secret_model` | ⚠️ **À VÉRIFIER** | Secret upsert (doublon?) |
| `bunny_upsert_edge_script_variable_model` | ⚠️ **À VÉRIFIER** | Variable upsert (doublon?) |
| `bunny_list_edge_script_secrets_model` | ⚠️ **À VÉRIFIER** | Liste de secrets (pagination?) |
| `bunny_publish_edge_script_model` | ⚠️ **À VÉRIFIER** | Modèle de publication (temporaire?) |
| `bunny_smart_generate_model` | ⚠️ **À VÉRIFIER** | Smart generate (temporaire?) |

**Recommandation** : Probablement tous **inutiles** (add/update/upsert sont des actions temporaires).

**Total : 0 table ✅ / 7 tables ⚠️**

---

### 9️⃣ **Tables Storage** - 3 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_storage_object` | ✅ **GARDER** | Objet stocké (fichier) |
| `bunny_storage_object_model` | ⚠️ **À VÉRIFIER** | Doublon de storage_object? |
| `bunny_storage_zone_model_add` | ❌ **SUPPRIMER** | Model add (action temporaire, déjà supprimé normalement?) |

**Total : 1 table ✅ / 1 table ⚠️ / 1 table ❌**

---

### 🔟 **Tables Diverses** - 5 tables

| Table | Status | Justification |
|-------|--------|---------------|
| `bunny_pull_zone_purge_model` | ⚠️ **À VÉRIFIER** | Historique de purge (utile pour audit?) |
| `bunny_bunny_ai_image_blueprint_model` | ⚠️ **À VÉRIFIER** | Blueprint AI image (config?) |
| `bunny_support_ticket_upload_attachment_model` | ⚠️ **À VÉRIFIER** | Upload attachment (temporaire?) |
| `bunny_cdn` | ✅ **GARDER** | Table manuelle CDN |
| `bunny_containers` | ✅ **GARDER** | Table manuelle Containers |
| `bunny_storage` | ✅ **GARDER** | Table manuelle Storage |
| `infrastructure_logs` | ✅ **GARDER** | Table manuelle Logs |

**Total : 4 tables ✅ / 3 tables ⚠️**

---

## 📊 Résumé Global

| Catégorie | ✅ GARDER | ⚠️ À VÉRIFIER | ❌ SUPPRIMER | Total |
|-----------|-----------|---------------|--------------|-------|
| Tables Principales | 13 | 0 | 0 | 13 |
| Relations/Sous-ressources | 12 | 3 | 0 | 15 |
| Statistiques | 1 | 10 | 0 | 11 |
| Configuration/Métadonnées | 1 | 11 | 0 | 12 |
| WAF/Shield | 4 | 16 | 0 | 20 |
| Support/Système | 6 | 6 | 2 | 14 |
| Vidéo Stream | 0 | 8 | 0 | 8 |
| Edge Scripting | 0 | 7 | 0 | 7 |
| Storage | 1 | 1 | 1 | 3 |
| Diverses | 4 | 3 | 0 | 7 |
| **TOTAL** | **42** | **65** | **3** | **106** |

---

## 🎯 Recommandations par Priorité

### ❌ **À SUPPRIMER IMMÉDIATEMENT** (3 tables)
1. `bunny_api_error_data` - Erreurs API temporaires
2. `bunny_error_object` - Objet erreur temporaire
3. `bunny_storage_zone_model_add` - Action temporaire

### ⚠️ **À SUPPRIMER PROBABLEMENT** (Statistiques temporaires - 10 tables)
- `bunny_dns_zone_statistics_model`
- `bunny_storage_zone_statistics_model`
- `bunny_video_statistics_model`
- `bunny_video_play_data_model`
- `bunny_edge_script_statistics_model`
- `bunny_statistics_model`
- `bunny_optimizer_statistics_model`
- `bunny_origin_shield_concurrency_statistics_model`
- `bunny_safe_hop_statistics_model`
- `bunny_server_zone_statistics_model`

**Justification** : Les statistiques sont récupérées en temps réel via API, pas besoin de les persister sauf si on veut un historique.

### ⚠️ **À SUPPRIMER PROBABLEMENT** (Edge Scripting doublons - 7 tables)
- `bunny_edge_script_add_secret_model` (add/update/upsert sont des actions, pas des entités)
- `bunny_edge_script_update_secret_model`
- `bunny_edge_script_upsert_secret_model`
- `bunny_upsert_edge_script_variable_model`
- `bunny_list_edge_script_secrets_model`
- `bunny_publish_edge_script_model`
- `bunny_smart_generate_model`

### ⚠️ **À CLARIFIER** (Config/Sous-champs - 20 tables)
Ces tables représentent probablement des **sous-champs JSON** plutôt que des tables séparées :
- Toutes les tables de config DRM (3)
- Toutes les tables de géolocalisation DNS (3)
- Toutes les tables optimizer class (2)
- Etc.

---

## ✅ **Tables Essentielles à Garder** (42 tables)

### Entités Principales (13)
1. `bunny_pull_zone_model`
2. `bunny_dns_zone_model`
3. `bunny_dns_record_model`
4. `bunny_storage_zone_model`
5. `bunny_video_library_model`
6. `bunny_video_model`
7. `bunny_collection_model`
8. `bunny_edge_script_model`
9. `bunny_api_key_model`
10. `bunny_country`
11. `bunny_region_model`
12. `bunny_team_member_model`
13. `bunny_support_ticket_model`

### Relations/Sous-ressources (12)
14. `bunny_hostname_model`
15. `bunny_edge_script_variable_model`
16. `bunny_edge_script_secret_model`
17. `bunny_edge_script_release_model`
18. `bunny_edge_rule_v2_model`
19. `bunny_caption_model`
20. `bunny_chapter_model`
21. `bunny_moment_model`
22. `bunny_meta_tag_model`
23. `bunny_support_ticket_comment_model`
24. `bunny_support_ticket_attachment_model`
25. `bunny_billing_record_model`

### WAF/Shield (4)
26. `bunny_custom_waf_rule`
27. `bunny_waf_rule`
28. `bunny_waf_rule_group_model`
29. `bunny_rate_limit_rule`

### Support/Système (7)
30. `bunny_abuse_case_model`
31. `bunny_abuse_case_url_model`
32. `bunny_billing_saved_payment_method`
33. `bunny_github_repository_model`
34. `bunny_github_repository_branch_model`
35. `bunny_connected_github_account_model`
36. `bunny_linked_pull_zone`

### Storage (1)
37. `bunny_storage_object`

### Autres (1)
38. `bunny_video_heatmap_model`

### Tables Manuelles (4)
39. `bunny_cdn`
40. `bunny_containers`
41. `bunny_storage`
42. `infrastructure_logs`

---

## 🎯 **Prochaines Actions Recommandées**

### Action 1 : Suppression Immédiate (3 tables)
Supprimer les tables d'erreurs temporaires.

### Action 2 : Décision sur Statistiques (10 tables)
**Question** : Voulez-vous garder un historique des statistiques ou les récupérer uniquement via API?
- **Si historique** → Garder
- **Si temps réel uniquement** → Supprimer

### Action 3 : Simplification Edge Scripting (7 tables)
Supprimer les doublons add/update/upsert.

### Action 4 : Analyse des Sous-champs (20 tables)
Vérifier si ces tables peuvent être remplacées par des champs JSON dans les tables principales.

---

## 💡 **Résultat Final Attendu**

Après nettoyage complet :
- **Tables essentielles** : ~40-45 tables
- **Tables de statistiques** (optionnel) : +0-10 tables
- **Total optimal** : ~40-55 tables (au lieu de 106)

Cela représenterait une **réduction de 50%** tout en conservant toutes les fonctionnalités essentielles.

