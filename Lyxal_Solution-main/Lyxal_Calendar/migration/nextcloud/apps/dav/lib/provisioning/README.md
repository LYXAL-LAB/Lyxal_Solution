# Analyse du Répertoire `Provisioning` de Nextcloud DAV

Ce répertoire gère le provisioning automatique pour les clients (2 fichiers dans `Apple/`).

---

## Sous-répertoire `Apple/`

### `AppleProvisioningPlugin.php`
-   **Type** : Plugin Sabre
-   **Endpoint** : `/.well-known/caldav`, `/.well-known/carddav`
-   **Fonction** : Génère un profil de configuration Apple (.mobileconfig)
-   **Contenu** :
    -   Configuration CalDAV automatique
    -   Configuration CardDAV automatique
    -   Certificats et identifiants

### `AppleProvisioningNode.php`
-   **Fonction** : Représente le nœud WebDAV pour le fichier .mobileconfig
-   **Nom** : `apple-provisioning.mobileconfig`
-   **Type MIME** : `application/x-apple-aspen-config`

---

## Usage
Permet aux utilisateurs iOS/macOS de configurer automatiquement leur calendrier et contacts Nextcloud en téléchargeant un profil de configuration.
