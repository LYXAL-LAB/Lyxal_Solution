# Patrons de Logique Métier Complexe (Point 4)

Ce document répertorie les cas de figure où le moteur Rust (**Lyxal Bridge**) doit appliquer une intelligence spécifique au-delà d'une simple requête HTTP standard. Ces patrons sont inspirés du fonctionnement interne des nœuds n8n.

## 1. Transformations de Données (Data Morphing)
Cas où la structure d'entrée utilisateur doit être radicalement modifiée pour l'API cible.

| Patron | Description | Exemple Service |
| :--- | :--- | :--- |
| **Multipart/Form-Data** | Mélange de métadonnées JSON et de fichiers binaires. | Google Drive, Slack Upload |
| **XML / SOAP Conversion** | Conversion d'un objet JSON Lyxal en structure XML stricte. | APIs Bancaires, Services Legacy |
| **Base64 Encoding** | Encodage automatique de champs binaires dans un JSON. | GitHub (Content API), Email Attachments |

## 2. Pré-traitements de Sécurité (Security Hooks)
Calculs dynamiques requis juste avant l'émission de la requête.

| Patron | Description | Exemple Service |
| :--- | :--- | :--- |
| **HMAC Signing** | Signature du corps de la requête avec une clé secrète et un timestamp. | Binance, Stripe, AWS SigV4 |
| **Nonce Generation** | Génération d'un nombre unique à usage unique pour éviter le "replay". | APIs de Crypto-monnaies |
| **Dynamic Token Exchange** | Échange d'un rafraîchissement de jeton (Refresh Token) si expiré. | OAuth2 (Google, Microsoft) |

## 3. Stratégies de Pagination (Auto-Pagination)
Gestion automatique de la récupération de gros volumes de données.

| Patron | Description | Identifiant n8n |
| :--- | :--- | :--- |
| **Cursor-based** | Utilisation d'un pointeur (`next_cursor`) fourni dans la réponse. | Slack, Stripe, Twitter |
| **Offset/Limit** | Incrémentation mathématique de l'index de départ. | Airtable, SQL-based APIs |
| **Page-based** | Incrémentation simple du numéro de page (`page=1, 2...`). | GitHub, HubSpot |

## 4. Normalisation de Sortie (Output Mapping)
Nettoyage et standardisation de la réponse API pour le système Lyxal.

| Patron | Description | Outil suggéré |
| :--- | :--- | :--- |
| **JSONPath Filtering** | Extraction d'un sous-ensemble spécifique d'un gros JSON. | `$.data.records[*].fields` |
| **HTML/Crawl Extraction** | Extraction de données depuis du HTML brut (Scraping). | Sélecteurs CSS / XPath |
| **Type Casting** | Conversion forcée (ex: transformer une string "10.5" en float). | Schéma de typage Lyxal |

## 5. Gestion des Quotas (Rate Limiting)
Respect des limites imposées par les fournisseurs pour éviter le bannissement.

| Patron | Description | Stratégie |
| :--- | :--- | :--- |
| **Throttling** | Limitation du nombre de requêtes par seconde (RPS). | Token Bucket / Leaky Bucket |
| **Concurrency Control** | Limitation du nombre de requêtes simultanées. | Sémaphores Rust |
| **Wait & Retry** | Pause automatique basée sur le header `Retry-After`. | Backoff Exponentiel |
