# Lyxal Vault : Gestion Centralisée des Secrets et de l'Identité

## 1. Vision et Concept
Le **Lyxal Vault** est le coffre-fort sécurisé intégré au cœur de la Lyxal Solution. Plutôt que de disperser les identifiants et les clés d'accès dans chaque module, le Vault centralise la gestion, le chiffrement et la distribution des secrets. Il sert de "système nerveux de confiance" pour l'ensemble des composants (Bridge, Dav, Scheduler, Storage).

L'objectif est de garantir qu'aucun secret (clé API, mot de passe, certificat) ne soit jamais stocké en clair ou exposé par inadvertance.

## 2. Architecture Technique

### Emplacement suggéré
`surrealdb/core/src/vault/` (ou extension de `core/src/iam/`)

### Structure des composants
- **`vault/mod.rs`** : Interface unifiée pour la récupération et l'enregistrement des secrets.
- **`vault/crypto/`** : Moteur de chiffrement (AES-256-GCM / ChaCha20-Poly1305) utilisant la clé maîtresse de l'instance.
- **`vault/store/`** : Adaptateurs de stockage (Local chiffré, KMS externe, ou Hardware Security Module).
- **`vault/policy/`** : Moteur de règles définissant quel module (ex: Bridge) a le droit d'accéder à quel secret.
- **`vault/rotator/`** : Logique de rotation automatique des clés et des jetons (ex: rafraîchissement OAuth2).

## 3. Typologie des Secrets Gérés

| Type | Usage | Exemples |
| :--- | :--- | :--- |
| **External API** | Lyxal Bridge | Slack Token, Stripe Secret, OpenAI Key. |
| **Infrastructure** | Core Storage | AWS S3 Access Keys, TiKV TLS Certs. |
| **Filesystem** | Lyxal Dav | FTP Credentials, Dropbox OAuth2 Tokens. |
| **Inter-Service** | Lyxal Cluster | Jetons de communication entre nœuds, clés mTLS. |
| **User Auth** | Identity | Hashes de mots de passe, clés privées JWT. |

## 4. Fonctionnement du Flux de Confiance

1. **Enregistrement** : Un administrateur via le `Lyxal SDK` ou `Lyxal Admin` enregistre un secret. Le Vault le chiffre immédiatement avant de l'écrire sur le disque.
2. **Requête** : Le module `Lyxal Bridge` demande un secret : `vault::get("slack_prod_key")`.
3. **Validation** : Le Vault vérifie que l'appel provient bien d'un module autorisé et dans un contexte valide.
4. **Délivrance** : Le secret est déchiffré en mémoire, utilisé pour la requête sortante, puis immédiatement purgé de la mémoire (Memory Zeroing).

## 5. Sécurité Avancée

- **Sealing/Unsealing** : Au démarrage, la base de données peut nécessiter une clé maîtresse (Master Key) pour "déverrouiller" le Vault.
- **Audit Logs** : Chaque accès à un secret est enregistré de manière immuable (Qui a accédé à quoi, et quand).
- **Dynamic Secrets** : Capacité à générer des identifiants temporaires à durée de vie limitée pour certaines opérations critiques.

## 6. Intégration dans l'Écosystème Lyxal

- **Bridge & Vault** : Le Bridge ne stocke aucune configuration sensible ; il référence des identifiants stockés dans le Vault via un `Alias`.
- **Scheduler & Vault** : Les tâches planifiées s'exécutent avec des "Scoped Identities" fournies par le Vault pour limiter le rayon d'action en cas de compromission.
- **Dav & Vault** : Permet de monter des partages réseaux de manière transparente en gérant l'authentification en arrière-plan.

---
*Ce document fait partie de la documentation technique de Lyxal Solution.*