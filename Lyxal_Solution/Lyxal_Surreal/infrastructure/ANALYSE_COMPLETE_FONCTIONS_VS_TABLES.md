# 📖 Analyse Complète : Fonctions API vs Tables SurrealDB

**Date**: 2025-10-25  
**But**: Comprendre quelles tables sont vraiment nécessaires pour votre infrastructure

---

## 🎯 **Principe Fondamental**

### Comment ça fonctionne :

1. **Les Fonctions d'API** (`fn_bunny_*`) :
   - Appellent l'API Bunny.net
   - Retournent les données JSON brutes
   - **Ne persistent RIEN automatiquement**
   - Loggent juste l'appel dans `infrastructure_log`

2. **Les Tables SurrealDB** (`bunny_*`) :
   - Stockent les données persistantes
   - Vous décidez quand et quoi persister
   - Permettent de travailler hors-ligne
   - Créent un cache local des ressources

### Exemple Concret :

```javascript
// 1. Appeler l'API pour lister les DNS zones
const result = await fn::bunny_list_dns_zones(1, 100, "");

// 2. Les données sont retournées mais PAS persistées
// result.zones contient les zones DNS

// 3. SI vous voulez les persister, vous devez le faire manuellement :
FOR $zone IN result.zones {
  CREATE bunny_dns_zone_model CONTENT $zone;
}
```

---

## 📊 **Vue d'Ensemble : 124 Fonctions d'API Générées**

### Répartition par Service

| Service | Fonctions | Description |
|---------|-----------|-------------|
| **DNS Zone** | ~18 | Gestion des zones DNS et records |
| **Pull Zone (CDN)** | ~25 | Gestion du CDN (cache, edge rules, etc.) |
| **Video/Stream** | ~30 | Gestion des vidéos et collections |
| **Edge Scripts** | ~15 | Gestion des scripts edge computing |
| **Storage** | ~8 | Gestion du stockage de fichiers |
| **API Keys** | ~3 | Gestion des clés API |
| **Shield/WAF** | ~12 | Sécurité et protection |
| **Autres** | ~13 | Support, billing, regions, etc. |

**Total** : **124 fonctions**

---

## 🔍 **CATÉGORIE 1 : Ressources à PERSISTER (Tables Essentielles)**

Ces tables stockent des **entités métier** que vous créez et gérez via Bunny.net.

### A. DNS (3 tables) ✅

| Table | Fonction d'API | Utilité |
|-------|----------------|---------|
| `bunny_dns_zone_model` | `fn::bunny_list_dns_zones()` | Zones DNS créées (ex: exemple.com) |
| `bunny_dns_record_model` | `fn::bunny_dns_zone_public__index()` | Records DNS (A, CNAME, MX, etc.) |
| `bunny_dns_zone_statistics_model` | `fn::bunny_dns_zone_public__statistics()` | **Statistiques DNS (queries/jour)** |

**Recommandation** :
- ✅ Garder `bunny_dns_zone_model` (liste de vos zones)
- ✅ Garder `bunny_dns_record_model` (vos records DNS)
- ⚠️ `bunny_dns_zone_statistics_model` → **STATISTIQUES** (voir section dédiée)

---

### B. CDN / Pull Zones (7 tables) ✅

| Table | Fonction d'API | Utilité |
|-------|----------------|---------|
| `bunny_pull_zone_model` | `fn::bunny_pull_zone_public__index()` | Vos pull zones CDN |
| `bunny_hostname_model` | `fn::bunny_pull_zone_public__load_free_certificate()` | Hostnames custom (cdn.exemple.com) |
| `bunny_edge_rule_v2_model` | `fn::bunny_pull_zone_public__add_edge_rule()` | Règles edge (redirections, cache, etc.) |
| `bunny_optimizer_class_model` | Intégré dans pull zone | Classes d'optimisation d'images |
| `bunny_pull_zone_purge_model` | `fn::bunny_purge_public__index_post()` | Historique des purges de cache |

**Recommandation** :
- ✅ Garder toutes ces tables (vos ressources CDN)

---

### C. Vidéo / Stream (9 tables) ✅

| Table | Fonction d'API | Utilité |
|-------|----------------|---------|
| `bunny_video_library_model` | `fn::bunny_video_library_public__index()` | Vos libraries vidéo |
| `bunny_video_model` | `fn::bunny_video_public__index()` | Vos vidéos |
| `bunny_collection_model` | `fn::bunny_collection_public__index()` | Collections de vidéos |
| `bunny_caption_model` | `fn::bunny_caption_public__index()` | Sous-titres des vidéos |
| `bunny_chapter_model` | `fn::bunny_chapter_public__index()` | Chapitres des vidéos |
| `bunny_moment_model` | Sous-ressource | Moments clés dans vidéos |
| `bunny_meta_tag_model` | Sous-ressource | Meta tags SEO |
| `bunny_video_heatmap_model` | `fn::bunny_video_public__get_heatmap()` | Analytics heatmap (où regardent users) |
| `bunny_drm_certificate_model` | `fn::bunny_d_r_m_certificate_public__index()` | Certificats DRM (protection) |

**Recommandation** :
- ✅ Garder toutes ces tables (votre contenu vidéo)

---

### D. Storage (2 tables) ✅

| Table | Fonction d'API | Utilité |
|-------|----------------|---------|
| `bunny_storage_zone_model` | `fn::bunny_storage_zone_public__index()` | Vos zones de stockage |
| `bunny_storage_object` | API Storage séparée | Fichiers stockés |

**Recommandation** :
- ✅ Garder ces tables (votre stockage)

---

### E. Edge Scripts (4 tables) ✅

| Table | Fonction d'API | Utilité |
|-------|----------------|---------|
| `bunny_edge_script_model` | `fn::bunny_edge_script_public__index()` | Vos edge scripts |
| `bunny_edge_script_variable_model` | `fn::bunny_variables_public__list_variables()` | Variables d'environnement |
| `bunny_edge_script_secret_model` | `fn::bunny_secrets_public__index()` | Secrets (API keys, etc.) |
| `bunny_edge_script_release_model` | `fn::bunny_releases_public__index()` | Releases/versions déployées |

**Recommandation** :
- ✅ Garder toutes ces tables (votre code edge computing)

---

### F. Sécurité / WAF / Shield (4 tables) ✅

| Table | Fonction d'API | Utilité |
|-------|----------------|---------|
| `bunny_custom_waf_rule` | API Shield | Vos règles WAF custom |
| `bunny_waf_rule_group_model` | API Shield | Groupes de règles WAF |
| `bunny_rate_limit_rule` | API Shield | Vos règles de rate limiting |
| `bunny_abuse_case_model` | `fn::bunny_abuse_case_public__index()` | Cas d'abus signalés |

#### 🛡️ **C'est quoi WAF / Shield ?**

**WAF (Web Application Firewall)** = Pare-feu web
- Bloque les attaques (SQL injection, XSS, etc.)
- Protège votre site contre les hackers
- Bunny Shield = Service de protection DDoS et WAF de Bunny.net

**Rate Limiting** = Limitation de débit
- Limite le nombre de requêtes par IP/pays
- Protection contre le spam et DDoS
- Ex: Max 100 requêtes/minute par IP

**Recommandation** :
- ✅ Garder si vous utilisez Bunny Shield
- ❌ Supprimer si vous n'utilisez PAS Bunny Shield

---

### G. Intégrations & Autres (8 tables) ✅

| Table | Fonction d'API | Utilité |
|-------|----------------|---------|
| `bunny_api_key_model` | `fn::bunny_api_key_public__list_api_keys()` | Vos clés API |
| `bunny_team_member_model` | `fn::bunny_user_public__index()` | Membres de votre équipe |
| `bunny_support_ticket_model` | `fn::bunny_support_ticket_public__index()` | Tickets de support |
| `bunny_billing_record_model` | `fn::bunny_billing_public__index()` | Factures |
| `bunny_github_repository_model` | `fn::bunny_get_connected_git_hub_repos()` | Repos GitHub liés |
| `bunny_region_model` | `fn::bunny_get_country_list()` | Régions Bunny.net |
| `bunny_country` | `fn::bunny_sync_countries()` | Liste des pays |
| `bunny_linked_pull_zone` | Sous-ressource | Liens entre pull zones |

**Recommandation** :
- ✅ Garder toutes ces tables (métadonnées importantes)

---

## 📊 **CATÉGORIE 2 : STATISTIQUES** (10 tables) - À DÉCIDER

### 🤔 **C'est quoi les "Statistiques" ?**

Les statistiques sont des **données de performance et d'utilisation** :
- Nombre de requêtes DNS par jour
- Bande passante consommée
- Nombre de vues vidéo
- Hits du CDN
- Performances des edge scripts

### Tables de Statistiques :

| Table | API | Données |
|-------|-----|---------|
| `bunny_dns_zone_statistics_model` | `fn::bunny_dns_zone_public__statistics()` | Queries DNS (nombre/jour, par pays, etc.) |
| `bunny_storage_zone_statistics_model` | Intégré | GB stockés, nb fichiers, bande passante |
| `bunny_video_statistics_model` | `fn::bunny_video_public__get_statistics()` | Vues, durée regardée, engagement |
| `bunny_video_play_data_model` | Sous-ressource | Données de lecture détaillées |
| `bunny_edge_script_statistics_model` | `fn::bunny_edge_script_public__get_statistics()` | Exécutions, erreurs, latence |
| `bunny_statistics_model` | `fn::bunny_statistics_public__index()` | Stats globales du compte |
| `bunny_optimizer_statistics_model` | Intégré | Stats d'optimisation d'images |
| `bunny_origin_shield_concurrency_statistics_model` | Intégré | Stats de concurrence origin shield |
| `bunny_safe_hop_statistics_model` | Intégré | Stats SafeHop |
| `bunny_server_zone_statistics_model` | Intégré | Stats par région serveur |

### ✅ **Pourquoi GARDER les statistiques ?**

1. **Historique** : Analyser l'évolution dans le temps
2. **Dashboards** : Créer des tableaux de bord sans appeler l'API
3. **Analytics** : Faire des requêtes complexes (ex: "Top 10 vidéos du mois")
4. **Cache** : Éviter de surcharger l'API Bunny.net
5. **Offline** : Consulter les stats même sans connexion
6. **Audit** : Prouver les performances historiques

### ❌ **Pourquoi SUPPRIMER les statistiques ?**

1. **Temps réel** : Les stats sont disponibles en direct via API
2. **Espace disque** : Les stats prennent beaucoup de place (croissance continue)
3. **Maintenance** : Il faut les mettre à jour régulièrement (cron job)
4. **Redondance** : Dupliquer des données déjà dans Bunny.net
5. **Complexité** : Plus de tables = plus de gestion

### 💡 **Recommandation** :

**Option 1** : **SUPPRIMER toutes les stats** (-10 tables)
- ✅ Simple et propre
- ✅ Récupération en temps réel via API
- ❌ Pas d'historique

**Option 2** : **GARDER uniquement** `bunny_video_heatmap_model` (-9 tables)
- ✅ Heatmap utile pour analytics vidéo
- ✅ Supprimer le reste (stats temps réel suffisantes)
- ⚠️ Compromis

**Option 3** : **GARDER toutes les stats** (0 tables supprimées)
- ✅ Historique complet
- ❌ Beaucoup de données à gérer

**Mon conseil** : **Option 2** (garder uniquement heatmap vidéo)

---

## 🛡️ **CATÉGORIE 3 : WAF / SHIELD** (15 tables) - À ANALYSER

### 🤔 **C'est quoi Bunny Shield ?**

**Bunny Shield** est un service de protection avancée :
- **WAF** : Pare-feu contre les attaques web (SQL injection, XSS, etc.)
- **DDoS Protection** : Protection contre les attaques par déni de service
- **Rate Limiting** : Limitation du débit pour éviter le spam
- **Bot Protection** : Détection et blocage des bots malveillants
- **Geo-blocking** : Bloquer des pays/régions

### Tables WAF/Shield :

| Table | Type | Utilité | Recommandation |
|-------|------|---------|----------------|
| `bunny_custom_waf_rule` | Entité | Vos règles WAF custom | ✅ GARDER si Shield activé |
| `bunny_waf_rule` | Entité | Règles WAF avec métriques | ✅ GARDER si Shield activé |
| `bunny_waf_rule_group_model` | Entité | Groupes de règles | ✅ GARDER si Shield activé |
| `bunny_waf_rule_main_group_model` | Hiérarchie | Groupes principaux | ⚠️ Peut être JSON |
| `bunny_rate_limit_rule` | Entité | Règles de rate limiting | ✅ GARDER si Shield activé |
| `bunny_waf` | Config | Config WAF globale | ⚠️ Probablement inutile |
| `bunny_waf_profile_minimal` | Config | Profil WAF | ⚠️ Peut être JSON |
| `bunny_waf_mapped_enum` | Référence | Enums mappés | ❌ SUPPRIMER (données ref) |
| `bunny_waf_mapped_enum_list` | Référence | Liste enums | ❌ SUPPRIMER (données ref) |
| `bunny_waf_rule_metrics` | Stats | Métriques règles WAF | ⚠️ Statistiques |
| `bunny_pull_zone_waf_config_variable_model` | Config | Variables config WAF | ⚠️ Peut être JSON |
| `bunny_ratelimit` | Config | Config rate limit global | ⚠️ Peut être JSON |
| `bunny_individual_ratelimit` | Config | Rate limit individuel | ⚠️ Peut être JSON |
| `bunny_ratelimit_metrics` | Stats | Métriques rate limit | ⚠️ Statistiques |
| `bunny_shield_overview` | Stats | Vue d'ensemble Shield | ❌ SUPPRIMER (temporaire) |
| `bunny_shield_zone_metrics` | Stats | Métriques Shield zone | ⚠️ Statistiques |
| `bunny_shield_zone_ratelimit` | Config | Config rate limit Shield | ⚠️ Peut être JSON |
| `bunny_shield_zone_ratelimit_metrics` | Stats | Métriques RL Shield | ⚠️ Statistiques |
| `bunny_d_do_s` | Config | Config DDoS | ⚠️ Peut être JSON |

### 💡 **Recommandation Bunny Shield** :

#### **SI vous utilisez Bunny Shield** :
✅ **GARDER** (5 tables) :
- `bunny_custom_waf_rule`
- `bunny_waf_rule`
- `bunny_waf_rule_group_model`
- `bunny_rate_limit_rule`
- `bunny_abuse_case_model`

❌ **SUPPRIMER** (10 tables) :
- 2 tables enum (référence)
- 1 table overview (temporaire)
- 7 tables de stats/config (peuvent être JSON ou temporaires)

#### **SI vous N'utilisez PAS Bunny Shield** :
❌ **SUPPRIMER TOUTES** (15 tables)

---

## 🔄 **CATÉGORIE 4 : Sous-Champs à Transformer en JSON** (15 tables)

Ces tables représentent des **objets imbriqués** qui devraient être des champs JSON :

### Tables à Transformer :

| Table | Parent | Action |
|-------|--------|--------|
| `bunny_apple_fair_play_drm` | `bunny_video_library_model` | → Champ `drm_config.apple` |
| `bunny_google_widevine_drm` | `bunny_video_library_model` | → Champ `drm_config.google` |
| `bunny_dns_sec_ds_record_model` | `bunny_dns_zone_model` | → Champ `dnssec_config` |
| `bunny_geo_dns_location_model` | `bunny_dns_record_model` | → Champ `geo_location` |
| `bunny_dns_record_enviromental_variable_model` | `bunny_dns_record_model` | → Champ `env_variables` |
| `bunny_edge_rule_v2_action_model` | `bunny_edge_rule_v2_model` | → Champ `actions` |
| `bunny_video_resolutions_info_model` | `bunny_video_model` | → Champ `resolutions_info` |
| `bunny_support_ticket_user_model` | `bunny_support_ticket_model` | → Champ `user_info` |
| `bunny_resolution_reference` | `bunny_video_model` | → Champ dans resolutions |
| ... (6 autres) | ... | ... |

**Avantage de la transformation** :
- ✅ Moins de tables
- ✅ Plus simple à maintenir
- ✅ Requêtes plus rapides
- ⚠️ Mais nécessite du refactoring

**Recommandation** : **À faire plus tard** (optimisation non prioritaire)

---

## 🟢 **CATÉGORIE 5 : Divers à Vérifier** (4 tables)

| Table | Utilité | Recommandation |
|-------|---------|----------------|
| `bunny_pull_zone_purge_model` | Historique purges cache | ⚠️ Utile pour audit? |
| `bunny_bunny_ai_image_blueprint_model` | Blueprint AI images | ⚠️ Utilisé? |
| `bunny_support_ticket_upload_attachment_model` | Upload temporaire | ❌ SUPPRIMER |
| `bunny_labels` | Labels génériques | ⚠️ Utilisé? |

**Recommandation** : Supprimer `bunny_support_ticket_upload_attachment_model` (temporaire)

---

## 📊 **RÉSUMÉ FINAL & RECOMMANDATIONS**

### **État Actuel : 82 Tables**

| Catégorie | Tables | Action Recommandée | Résultat |
|-----------|--------|-------------------|----------|
| ✅ **Essentielles** | 42 | **GARDER** | 42 tables |
| 📊 **Statistiques** | 10 | **SUPPRIMER 9, GARDER heatmap** | -9 tables |
| 🛡️ **Shield** (si pas utilisé) | 15 | **SUPPRIMER toutes** | -15 tables |
| 🛡️ **Shield** (si utilisé) | 15 | **GARDER 5, SUPPRIMER 10** | -10 tables |
| ⚠️ **Divers** | 1 | **SUPPRIMER** | -1 table |
| 🔄 **À transformer JSON** | 15 | **Plus tard** | 0 |

### **Résultat Attendu** :

#### **Scénario 1 : SANS Bunny Shield**
- Tables actuelles : 82
- Supprimer stats : -9
- Supprimer Shield : -15
- Supprimer divers : -1
- **TOTAL FINAL : 57 tables** (-30%)

#### **Scénario 2 : AVEC Bunny Shield**
- Tables actuelles : 82
- Supprimer stats : -9
- Supprimer Shield partiel : -10
- Supprimer divers : -1
- **TOTAL FINAL : 62 tables** (-24%)

---

## 🎯 **PLAN D'ACTION RECOMMANDÉ**

### **Étape 1 : Décision Utilisateur** 🔴

**Question 1** : Utilisez-vous **Bunny Shield** (WAF/protection DDoS) ?
- ✅ **OUI** → Garder 5 tables Shield essentielles (-10 tables Shield)
- ❌ **NON** → Supprimer toutes les tables Shield (-15 tables)

**Question 2** : Voulez-vous un **historique des statistiques** ?
- ✅ **OUI** → Garder toutes les stats (0 suppression)
- ⚠️ **PARTIELLEMENT** → Garder uniquement heatmap vidéo (-9 tables)
- ❌ **NON** → Supprimer toutes les stats (-10 tables)

### **Étape 2 : Suppression Automatique** 🤖

Après vos réponses, je peux supprimer automatiquement les tables inutiles.

### **Étape 3 : Optimisation Future** 🔄

Plus tard, transformer les sous-champs en JSON (-15 tables optionnelles).

---

## 💡 **MES RECOMMANDATIONS FINALES**

### **Recommandation Standard** ⭐

Si vous débutez avec Bunny.net :

1. ❌ **Supprimer statistiques** (sauf heatmap) → -9 tables
   - Vous pouvez toujours les récupérer via API
   
2. ❓ **Shield : À déterminer**
   - Si vous ne savez pas → **Supprimer** (-15 tables)
   - Vous pourrez toujours les recréer si besoin

3. ❌ **Supprimer divers** → -1 table

**Résultat** : **57 tables** (propre et minimaliste)

### **Recommandation Avancée** ⭐⭐⭐

Si vous voulez une infrastructure optimale :

1. ❌ Supprimer stats (sauf heatmap) → -9
2. ❌ Supprimer Shield (si pas utilisé) → -15
3. ❌ Supprimer divers → -1
4. 🔄 Transformer JSON → -15

**Résultat** : **42 tables** (optimal)

---

## ❓ **Vos Décisions**

Pour que je puisse continuer, répondez :

1. **Bunny Shield** : Utilisez-vous la protection WAF/DDoS de Bunny.net ?
   - [ ] OUI → Garder 5 tables essentielles
   - [ ] NON → Supprimer toutes les tables Shield
   - [ ] JE NE SAIS PAS → Supprimer (on peut recréer si besoin)

2. **Statistiques** : Voulez-vous stocker l'historique des statistiques ?
   - [ ] OUI → Garder toutes les stats
   - [ ] SEULEMENT HEATMAP → Garder uniquement heatmap vidéo
   - [ ] NON → Supprimer toutes les stats

Dites-moi vos choix et je supprime automatiquement les tables inutiles ! 🚀

