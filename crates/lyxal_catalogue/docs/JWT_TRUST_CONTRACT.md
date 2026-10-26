# 🔐 Contrat de Confiance JWT — Lyxal Master Catalogue (V1.1)

Ce document formalise les règles cryptographiques, les politiques d'émission, d'attribution et de rotation des jetons d'accès JWT pour le module `lyxal_catalogue`, conformément à la Directive CTO de clôture V1.1.

---

## 1. Autorité d'Émission, Émetteur et Audience

| Paramètre | Valeur Requise | Description & Règle de Sécurité |
| :--- | :--- | :--- |
| **Autorité d'Émission** | `lyxal_auth` | Seul le module central d'authentification de la suite Lyxal OS est habilité à signer et émettre des jetons valides. |
| **`iss` (Issuer)** | `"lyxal-auth"` (ou `"lyxal-os"`) | Identifie la source de confiance. Tout jeton émis par un tiers non approuvé est rejeté dès l'étape `AUTHENTICATE`. |
| **`aud` (Audience)** | `"lyxal-catalogue"` | Cloisonnement strict d'audience. Empêche toute attaque par rejeu d'un jeton émis pour un autre module (ex: `lyxal_booking`, `lyxal_notification`). |
| **`sub` (Subject)** | `user:<id>` ou `service:<id>` | Identifiant unique et immuable du sujet (associé 1:1 à son enregistrement dans `catalogue_session`). |
| **Algorithme** | `HS256` (ou `RS256` / `EdDSA`) | Signature cryptographique obligatoire avec clé forte d'au minimum 256 bits (CSPRNG). |

---

## 2. Attribution des Rôles (`role`)

Le modèle de permissions `lyxal_catalogue` repose sur deux rôles strictement exclusifs :

### 2.1. `catalogue_sync_agent` (Service Machine-to-Machine)
* **Finalité :** Alimentation et synchronisation du référentiel public Master Catalogue (`is_custom = false`).
* **Attribution :** Attribué exclusivement à un service d'arrière-plan authentifié par identifiants machine supervisés (mTLS ou secret machine de haute sécurité).
* **Droits effectifs :**
  - Écriture et mise à jour des articles maîtres (`catalogue_item` où `is_custom = false`).
  - Gestion des nomenclatures et relations maîtresses.
  - **Interdiction absolue** de lire, modifier ou supprimer des articles ou compositions privées d'entreprises clientes (`is_custom = true`).

### 2.2. `tenant_user` (Utilisateur Locataire / Client)
* **Finalité :** Exploitation du catalogue par les artisans et entreprises clientes.
* **Attribution :** Attribué aux utilisateurs finaux authentifiés appartenant à une organisation cliente.
* **Droits effectifs :**
  - Lecture des articles maîtres publics.
  - Personnalisation locale des champs maîtres autorisés (`libelle_personnalise`, `code_interne_client`, `enabled`).
  - Création, lecture, modification et suppression exclusive de ses propres articles privés (`is_custom = true` et `tenant_id = $token.tenant_id`).
  - **Interdiction absolue** de modifier les caractéristiques techniques maîtresses ou d'accéder aux données privées d'autres locataires.

> ⚠️ **Règle absolue :** Les rôles ne sont JAMAIS acceptés depuis les données transmises dans la requête utilisateur. Ils sont extraits exclusivement du corps cryptographiquement scellé du token JWT.

---

## 3. Attribution et Immuabilité du `tenant_id`

1. **Dérivation Centralisée :**
   - Le claim `tenant_id` est injecté par `lyxal_auth` lors de la signature du jeton, après vérification de l'appartenance organisationnelle de l'utilisateur.
2. **Exigence Obligatoire pour les Articles Privés :**
   - Tout article privé (`is_custom = true`) requiert obligatoirement `tenant_id != NONE`.
   - Si un utilisateur possède le rôle `tenant_user` mais présente un jeton sans claim `tenant_id`, toute tentative de création ou de modification d'article privé est rejetée (`CTO-TEST-9A1`, `9A2`).
3. **Scellement et Immuabilité (`READONLY`) :**
   - Le champ `tenant_id` de `catalogue_item` est défini `READONLY`. Une fois créé, il ne peut plus être modifié, ni directement ni via fonction métier (`CTO-TEST-9C1`, `9C2`).

---

## 4. Délivrance du Scope Privilégié `catalogue:sync:write`

* Le scope `"catalogue:sync:write"` est une habilitation à privilèges élevés.
* Il est délivré **uniquement** aux identités présentant le rôle `catalogue_sync_agent`.
* Un utilisateur `tenant_user` ne peut en aucun cas obtenir ou utiliser ce scope.
* Les clauses RLS (`PERMISSIONS FOR create, update WHERE ...`) et les gardiens d'événements (`evt_catalogue_item_guard`, `evt_catalogue_relation_guard`) vérifient la présence conjointe :
  ```surql
  $token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope
  ```

---

## 5. Révocation et Durée de Vie des Jetons

1. **Jetons à Courte Durée de Vie (`exp`) :**
   - Les jetons d'accès ont une validité maximale de **1 heure** (`exp = iat + 3600`).
   - Tout jeton dont `exp < time::now()` est immédiatement rejeté au niveau de la couche d'accès (`401 Unauthorized`, `CTO-TEST-4D`).
2. **Révocation Immédiate de Session :**
   - En cas de suspension de compte ou de révocation de droits, la session correspondante dans `catalogue_session` peut être invalidée ou supprimée par le Runtime `lyxal_runtime`.
   - `catalogue_session` applique `PERMISSIONS FOR create, update, delete NONE` pour les Record Users, empêchant tout utilisateur de prolonger ou altérer artificiellement sa session.

---

## 6. Rotation des Clés Cryptographiques

1. **Isolation des Environnements :**
   - **Développement / Tests :** Clé injectée dynamiquement via `$env:LYXAL_JWT_SECRET` ou générée aléatoirement via CSPRNG 256-bit (`System.Security.Cryptography.RandomNumberGenerator`).
   - **Production :** Clés gérées par le coffre de secrets Lyxal OS (KMS / HashiCorp Vault / Variables d'orchestrateur scellées).
2. **Procédure de Rotation sans Rupture (Zero-Downtime Key Rotation) :**
   - Le moteur d'accès supporte la configuration de clés actives et de clés en cours de retrait (`retiring_key`).
   - Lors d'une rotation :
     1. Déploiement de la nouvelle clé $K_{n+1}$ comme clé de signature principale.
     2. Maintien de l'ancienne clé $K_n$ en validation seule pendant la durée maximale de validité d'un token (1 heure).
     3. Révocation définitive de $K_n$ au terme de la fenêtre de grâce.
