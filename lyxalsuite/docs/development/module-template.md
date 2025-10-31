# 📘 Spécification Structurée - Module `lyxal<module>` (Template Officiel)

> Ce document doit être rempli **avant de commencer le développement** de tout nouveau module dans `lyxalsuite/`. Il permet à Cursor d'avoir une référence stricte et unique tout au long du développement.
>
> Toute incohérence (variable, logique, nommage) devra être corrigée AVANT de coder. Ce document fait office de contrat de cohérence technique.

---

## 🔢 1. Informations générales

* **Nom du module** : `lyxal<module>`
* **Version référence Axelor** : `Axelor Open Suite vX.X`
* **Module Axelor étudié** : `<nom original dans Axelor>`
* **Objectif fonctionnel** :

  * \<Décrire à quoi sert ce module>
  * <Quels processus il couvre>

---

## 🧱 2. Architecture technique globale (règles transverses)

### 🔌 Authentification (Logto)

* L’authentification centrale est gérée par **Logto**, intégré dans le module `lyxalauth`
* Tous les tokens JWT, sessions, OTP, magic links, etc. sont fournis et validés via **Logto**
* SurrealDB **ne gère pas directement les tokens**, mais peut stocker des données secondaires (logs, liens, etc.)

### 🧩 Base de données

* Chaque module métier utilise **SurrealDB**, avec des tables du type `crm_client`, `lms_course`, etc.
* Les entités auth sont externalisées (Logto) mais peuvent être mappées en lecture (via userId, email, etc.)
* L’accès à SurrealDB est toujours effectué via le microservice `gateway/`

### 🧠 Agents IA

* Tous les modules peuvent définir des agents IA (dans `interface/agents/`) exploitables via studio.lyxal
* Structure IA : prompts + actions + API compatibles assistant

### 🎨 Frontend

* Framework officiel : **React 18**
* Style : **Tailwind CSS + variables CSS custom (`--color-*`)**
* Les composants doivent respecter une structure : 1 `.tsx` + 1 `.css`
* Tous les composants réutilisables (Button, Input...) sont centralisés dans `uicomponents/`

---

## 📋 3. Intégration Auth obligatoire (cross-module)

> Chaque module **doit intégrer** les mécanismes d'authentification/autorisation fournis par `lyxalauth`

### 🔐 Sécurité backend

* Middleware `requireAuth` appliqué à toutes les routes sensibles
* Injection de `ctx.user` à partir du token JWT fourni par Logto

### 🧑‍⚖️ RBAC

* Vérification du rôle utilisateur (`user.role`) dans les services métiers
* Refus explicite si rôle insuffisant

### 🧾 Journalisation

* Usage de `logEvent('<module>:<action>_success|_failed')` pour tout changement de données

### 🌐 SDK

* Tous les appels vers la Gateway utilisent automatiquement le token JWT actuel
* Possibilité de filtrage `byUser` dans les listes si logique métier le justifie

### 🎨 UI (optionnel)

* Affichage du rôle via composant `<RoleBadge />` si pertinent dans l’interface

---

## 📑 4. Entités à implémenter (structure de données)

Pour chaque entité listée ci-dessous, créer une fiche technique complète dans `model/`.

### Exemple : `Client`

* **Nom DB Surreal** : `crm_client`

* **Clés primaires** : `id`

* **Champs :**

  | Nom         | Type       | Obligatoire | Défaut | Description           |
  | ----------- | ---------- | ----------- | ------ | --------------------- |
  | `name`      | `string`   | ✅           | -      | Nom complet du client |
  | `email`     | `string`   | ❌           | -      | Email du contact      |
  | `createdAt` | `datetime` | ✅           | now()  | Date de création      |

* **Relations :**

  * `company` : lien vers une autre entité

---

## 🛠️ 5. API à exposer (gateway)

Liste des routes à créer dans `gateway/routes/` avec leur validation (Zod) et service appelé.

### Exemple : `/clients`

* **GET /clients** : retourne la liste des clients
* **POST /clients** : crée un nouveau client (valider via Zod)
* **PUT /clients/\:id** : met à jour un client
* **DELETE /clients/\:id** : supprime un client

---

## ⚖️ 6. Règles métier

Lister ici les règles métier importantes à respecter dans `gateway/services/`.

### Exemple :

* Impossible de créer un client sans `name`
* Les emails doivent être uniques dans la base

---

## 📦 7. SDK frontend

Liste des fonctions à exposer dans `sdk/<entity>/` avec leurs types.

### Exemple :

* `getClients(): Promise<Client[]>`
* `createClient(data: Partial<Client>): Promise<Client>`

Inclure les types définis dans `sdk/types.ts` ou spécifiques.

---

## 🎨 8. UI Components

Composants à créer dans `ui/<entity>/` avec un mapping clair des éléments (formulaires, tableaux, etc.).

### Exemple :

* `ClientTable.tsx` : tableau listant tous les clients (colonnes + actions)
* `ClientForm.tsx` : formulaire de création/édition

> Tous les composants doivent utiliser les **variables CSS du thème** et se baser sur les composants de base (ex: `Button`, `Input`).

---

## 🤖 9. Interface (IA / Actions / Prompts)

* **Agent IA** : `agents/<entity>Agent.ts`

  * Rôle : permet à une IA de lire écrire interagir avec ce module
* **Actions** : `actions/` : boutons ou workflows liés aux données de ce module
* **Prompts** : prompts système si nécessaire

---

## ⚙️ 10. Tests

Liste des tests à prévoir et structure attendue dans `tests/`

* **Unitaires :** services + validations Zod + SDK
* **Fonctionnels :** routes REST

---

## 📂 11. Fichiers à créer dans chaque dossier

Liste stricte des fichiers à créer avec leur nom exact. Aucune variation n’est permise.

### Exemple pour une entité `Client`

```
model/client.model.ts
gateway/routes/client.route.ts
gateway/services/client.service.ts
gateway/validators/client.validator.ts
sdk/client/useClient.ts
sdk/client/types.ts
ui/client/ClientTable.tsx
ui/client/ClientForm.tsx
ui/css/client.css
interface/agents/crmAgent.ts
constants/index.ts
tests/client.test.ts
```

---

## 🔐 12. Normes de nommage, logs, audit

* **Nom des tables Surreal** : préfixe obligatoire `crm_`, `lms_`, etc.
* **Variables** : camelCase
* **Logs** : tous les appels modifiants doivent utiliser `logEvent('<module>:<action>_success|_failed')`
* **Audit** : toutes les créations / updates passent par un log automatique

---

## 📘 13. Documentation finale attendue

Cursor doit à la fin fournir un fichier `README.md` clair contenant :

* Description du module
* Schémas de données
* Liste des routes REST
* Aperçu UI
* Tests inclus
* Limitations / TODO
* dependances aux autres modules

---

**⚠️ Toute implémentation sans ce fichier .md prévalidé est considérée comme non conforme.**
