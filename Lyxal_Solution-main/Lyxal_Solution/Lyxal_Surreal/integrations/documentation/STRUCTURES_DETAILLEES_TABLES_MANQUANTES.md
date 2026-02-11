# 📐 Structures Détaillées - Tables Manquantes

**Date** : 2025-01-27  
**Objectif** : Structures complètes en SurrealQL des 4 tables manquantes pour validation

---

## 1. **user_service_credential**

**Fichier** : `integrations/database/credentials/user_service_credential.surql`

Voir structure complète dans le document principal (VALIDATION_STRUCTURE_TABLES.md)

**Points à valider** :
- Structure des credentials (OAuth2, API Key, Basic Auth)
- Chiffrement (comment gérer ?)
- Expiration (automatique ?)
- Permissions (utilisateur peut modifier ses credentials ?)

---

## 2. **integration_log**

**Fichier** : `integrations/database/integration_log/integration_log.surql`

Voir structure complète dans le document principal (VALIDATION_STRUCTURE_TABLES.md)

**Points à valider** :
- Champs request/response (suffisants ?)
- Rotation/archivage des logs (nécessaire ?)
- Anonymisation (quels champs ?)
- Permissions (utilisateur voit ses logs ?)

---

## 3. **response_mapping**

**Fichier** : `integrations/database/response_mapping/response_mapping.surql`

Voir structure complète dans le document principal (VALIDATION_STRUCTURE_TABLES.md)

**Points à valider** :
- Types de mapping (suffisants ?)
- Structure des transformations (flexible ?)
- Pagination (complète ?)

---

## 4. **webhook_config**

**Fichier** : `integrations/database/webhook_config/webhook_config.surql`

Voir structure complète dans le document principal (VALIDATION_STRUCTURE_TABLES.md)

**Points à valider** :
- Structure external_config (complète ?)
- Structure surreal_api (correspond à DEFINE API ?)
- Signature (flexible ?)

---

**Les structures complètes sont dans VALIDATION_STRUCTURE_TABLES.md** 📋

