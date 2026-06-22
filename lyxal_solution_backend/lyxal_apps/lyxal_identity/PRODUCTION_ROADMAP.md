# Lyxal Identity - Guide de Passage en Production & Roadmap Sécurité

Ce document répertorie les points critiques identifiés lors de l'audit final du 22/02/2026. Bien que le code soit actuellement 100% fonctionnel et dépourvu de placeholders, ces étapes sont indispensables pour une mise en production industrielle.

## 1. Gestion des Certificats et Cryptographie

### A. Signature des Jetons (OIDC/JWT)
*   **État actuel :** Génération dynamique d'une paire RSA 2048-bit au démarrage dans `jwks.rs`.
*   **Action Prod :** 
    *   Extraire la clé privée du code et la stocker dans un **Secret Manager** (AWS Secrets Manager, HashiCorp Vault).
    *   Modifier `JwksService` pour charger cette clé fixe au démarrage afin d'assurer la persistance des sessions utilisateur après un redémarrage du serveur.
    *   Mettre en place une procédure de **Key Rotation** (rotation des clés) tous les 6 à 12 mois.

### B. HTTPS & TLS
*   **État actuel :** Serveur Axum en HTTP brut.
*   **Action Prod :**
    *   **Ne pas** implémenter le TLS directement en Rust (sauf besoin spécifique).
    *   Déployer un **Reverse Proxy** (Nginx, Caddy ou Traefik) devant l'application.
    *   Utiliser des certificats **Let's Encrypt** avec renouvellement automatique.
    *   Forcer le HSTS (HTTP Strict Transport Security) pour interdire les connexions non sécurisées.

## 2. Configuration WebAuthn (Passkeys)

*   **Contrainte :** WebAuthn échouera systématiquement en production sans HTTPS et sans un domaine valide.
*   **Action Prod :**
    *   Configurer le `RP_ID` (Relying Party ID) avec votre nom de domaine final (ex: `auth.lyxal.com`).
    *   Configurer le `RP_ORIGIN` (ex: `https://auth.lyxal.com`).
    *   Vérifier que le domaine est présent dans la liste des domaines autorisés de l'application cliente.

## 3. Infrastructure et Persistance

### A. Base de données PostgreSQL
*   **Indexation :** Vérifier que tous les champs de recherche (`email`, `username`, `tenant_id`) possèdent des index B-Tree pour les performances à grande échelle.
*   **Sauvegardes :** Mettre en place un backup automatique (journalier) de la base de données.
*   **Migrations :** Bien que `sqlx::migrate!` soit activé, tester chaque migration sur un environnement de staging avant la prod pour éviter tout verrouillage de table (Table Locking).

### B. Connecteurs Sociaux & Notification
*   **Audit des Secrets :** S'assurer qu'aucun `client_secret` (Google, Facebook, Twilio) n'est présent dans les logs.
*   **Validation des Redirect URIs :** En production, restreindre strictement les `redirect_uris` dans le dashboard Google/Facebook aux URLs de production de Lyxal Identity.

## 4. Sécurité Applicative

*   **Rate Limiting :** Ajouter un middleware de limitation de débit (Rate Limiting) sur les endpoints sensibles (`/api/login`, `/api/register`, `/api/mfa/verify`) pour prévenir les attaques par force brute.
*   **Audit Logging :** La table `audit_logs` est présente. Il faut s'assurer que chaque action de "Tenant Admin" ou "User Admin" y est enregistrée (Qui a fait quoi, et quand).
*   **Headers de Sécurité :** Configurer les headers suivants sur le Reverse Proxy :
    *   `X-Frame-Options: DENY` (Anti-Clickjacking)
    *   `X-Content-Type-Options: nosniff`
    *   `Content-Security-Policy (CSP)` appropriée.

## 5. Monitoring & Observabilité

*   **Télémétrie :** Le module `lyxal_telemetry` est prêt. En production, le connecter à une instance **Azure App Insights** ou **OpenTelemetry/Prometheus**.
*   **Alerting :** Configurer des alertes sur les erreurs 500 et les échecs de connexion répétés (signe potentiel d'attaque).

---
*Document généré le 22/02/2026 pour le projet Lyxal Identity.*
