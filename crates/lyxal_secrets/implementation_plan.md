# Plan d'implémentation — `lyxal_secrets`, lot 4 : accès avancés

Quatrième lot du programme `lyxal_secrets` (`implementation_plan.md` à la racine, décision A1).
Il ajoute ce que Vault Enterprise et Infisical réservent à leurs offres payantes :

* les **accès temporaires** limités à un dossier ou un secret ;
* les **demandes d'accès** approuvées ;
* l'**approbation des changements** par une ou plusieurs personnes ;
* l'**accès d'urgence** tracé et signalé.

Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

Aujourd'hui, un droit `lyxal_auth` (`secrets.value.read`…) vaut pour **toute** l'organisation et
sans limite de temps. Ce lot ajoute des droits plus fins, en plus de ceux-là, jamais à leur place.

## 1. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **D1** | Portée d'un accès | **Un secret précis ou un dossier entier** (`notification/` couvre tout ce qui est dessous). Pas de motifs à jokers (`*/smtp/**`) : `lyxal_core` n'a pas de comparaison de motifs, il faudrait l'y ajouter (extension du Core à valider). Le dossier couvre les besoins courants |
| **D2** | Durée d'un accès | **Toujours limitée** : 8 heures par défaut, 90 jours au plus (réglables par organisation). Pas d'accès permanent par ce moyen : le permanent reste un rôle `lyxal_auth`. Retrait immédiat possible à tout moment |
| **D3** | Qui accorde et approuve | Nouvelle permission **`secrets.access.manage`** (accorder, retirer, approuver), donnée au rôle `organization_admin`. **On n'approuve jamais sa propre demande**, même avec ce droit |
| **D4** | Demandes d'accès | Une personne ou un programme demande un accès (dossier ou secret, opérations, durée, motif). Il est accordé **dès que le nombre d'approbations requis est atteint** (1 par défaut, réglable de 1 à 5). Un seul refus clôt la demande. Une demande sans réponse expire au bout de **7 jours** |
| **D5** | Changements à approuver | L'organisation **protège** des dossiers ou des secrets : y changer la valeur en service, revenir à une ancienne version, désactiver, supprimer ou détruire passe par une **demande de changement**. La nouvelle valeur est scellée tout de suite, mais **pas mise en service**. Une fois les approbations reçues, **l'auteur applique** le changement. Les approbateurs ne voient jamais la valeur. La rotation automatique par un rotateur n'est pas soumise à approbation |
| **D6** | Accès d'urgence | Nouvelle permission **`secrets.access.emergency`**, attribuée explicitement (aucun rôle ne la reçoit d'office). Elle permet de **s'accorder seul un accès d'1 heure au plus**, ou de passer outre une protection. Il faut un motif, le double facteur récent, et l'acte est **journalisé et publié** (`secrets.access.emergency`) pour que les responsables soient prévenus |
| **D7** | Prévenir les approbateurs | Par **événements** sur le bus (demande créée, approuvée, refusée, accès d'urgence). L'envoi par e-mail relèvera de `lyxal_notification`, comme pour les alertes du lot 3 |

## 2. Fonctionnement

### 2.1. Accès temporaire (`secrets_grant`)

* **Bénéficiaire** : une identité membre de l'organisation, ou une application de l'organisation.
* **Portée** : le chemin d'un secret, ou un dossier (chemin finissant par `/`).
* **Opérations** : `list`, `read_value`, `write`, `delete` (sous-ensemble).
* **Durée et motif** : dates de début et de fin, motif ; auteur, ou demande d'origine.
* **Contrôle unique des droits** : `fn::secrets_can({ action, tenant, path })` accepte le droit
  `lyxal_auth` **ou** un accès en cours qui couvre le chemin et l'opération.
  * Les fonctions qui visent un secret passent son chemin.
  * Les droits des tables `secrets_secret`, `secrets_version` et `secrets_read_ticket` lisent le
    chemin du secret.
  * La liste des secrets ne montre que ceux qu'un accès couvre.
* **Non couvert par un accès** (droits `lyxal_auth` seulement) : réglages, journal, purge,
  restauration et gestion des accès.

### 2.2. Demande d'accès et demande de changement (`secrets_request`)

**Contenu d'une demande**

| Élément | Valeur |
| :--- | :--- |
| Type | `access` (accès) ou `change` (changement) |
| Demandeur | identité ou application |
| Organisation | celle de la demande |
| Objet | chemin, opérations et durée (accès) ; ou secret, opération et numéro de la version proposée (changement) |
| Motif | texte libre |
| Approbations | qui, quand |
| Refus | qui, quand |
| État | `pending` → `approved` / `rejected` / `cancelled` / `expired` → `applied` (changement) |

**Cycle d'une demande**

* **Accès** : à l'approbation finale, l'accès est créé, avec la demande comme origine.
* **Changement de valeur** : la nouvelle valeur est ajoutée comme version **sans étiquette
  `current`** (étape `proposed`). Une fois la demande approuvée, l'auteur l'applique
  (`fn::secrets_request_apply`) : l'étiquette `current` passe sur la version proposée.
* **Désactiver, supprimer, détruire, revenir en arrière** : l'opération et ses paramètres sont
  conservés dans la demande, et l'auteur l'exécute à l'application, avec ses propres droits.
* **Une demande de changement ouverte par secret** au plus.

**Protections (`secrets_policy`)**

* **Contenu** : organisation, dossier ou secret, nombre d'approbations (1 à 5), opérations
  protégées, durée maximale des accès demandés.
* **Effet** : sur un chemin protégé, une écriture directe des opérations protégées est refusée
  (`SECRETS_APPROVAL_REQUIRED`), même par une écriture directe dans les tables (gardes).
  * Exceptions : l'application d'une demande approuvée, le worker (rotation automatique) et
    l'accès d'urgence.
* **Plusieurs protections** sur un même chemin : la plus exigeante s'applique.

### 2.3. Accès d'urgence

`fn::secrets_access_emergency` crée un accès d'une heure au plus pour l'appelant lui-même.

* **Conditions** : motif, permission `secrets.access.emergency`, assurance la plus haute et
  récente.
* **Traçabilité** : entrée de journal `access.emergency` et événement
  `secrets.access.emergency`.
* **Passer outre une protection** : l'auteur applique sa demande de changement avant les
  approbations (`emergency: true`, motif), avec la même trace.

## 3. SurrealQL

### Schéma (nouveaux fichiers et champs)

| Élément | Contenu |
| :--- | :--- |
| `schema/08_secrets_grant.surql` | accès : `tenant`, `subject_identity` ou `subject_application`, `path`, `folder` (bool), `actions`, `starts_at`, `expires_at`, `reason`, `granted_by`, `request`, `emergency`, `revoked_at`, `revoked_by` ; index par organisation et bénéficiaire. Lecture : bénéficiaire et `secrets.access.manage` ; aucune écriture directe hors fonctions (gardes) |
| `schema/09_secrets_request.surql` | demandes : champs du §2.2, `expires_at` (7 jours), `decided_at`, `applied_at` ; index unique : une demande de changement ouverte par secret |
| `schema/10_secrets_policy.surql` | protections : `tenant`, `path`, `folder`, `required_approvals`, `operations` (`value`, `rollback`, `disable`, `delete`, `destroy`), `max_grant_duration` |
| `secrets_settings` | `grant_default_duration` (8 h), `grant_max_duration` (90 jours), `request_ttl` (7 jours) |
| `secrets_version_add` | étape `stage: "proposed"` (aucune étiquette `current` posée), refusée hors d'une demande de changement |

### Fonctions (`DEFINE FUNCTION OVERWRITE fn::<nom>($params: object)`, résultat `fn::result_ok` ou `fn::error_result`)

| Fonction | `$params` (**obligatoires**) | Droit |
| :--- | :--- | :--- |
| `secrets_grant_create` | **tenant**, **subject**, **path**, **actions**, `duration`, `reason` | `secrets.access.manage` |
| `secrets_grant_revoke` | **grant**, `reason` | `secrets.access.manage` |
| `secrets_grant_list` | `tenant`, `subject`, `path`, `active_only`, `limit`, `start` | `secrets.access.manage` ; chacun voit les siens |
| `secrets_access_emergency` | **tenant**, **path**, **actions**, **reason**, `duration` (1 h au plus) | `secrets.access.emergency` + assurance |
| `secrets_request_access` | **tenant**, **path**, **actions**, **reason**, `duration` | membre de l'organisation |
| `secrets_request_change` | **secret**, **operation**, `number` (version proposée), `target` (retour arrière), **reason** | écriture sur le secret |
| `secrets_request_approve` | **request**, `comment` | `secrets.access.manage`, pas le demandeur |
| `secrets_request_reject` | **request**, **reason** | `secrets.access.manage`, pas le demandeur |
| `secrets_request_cancel` | **request** | demandeur |
| `secrets_request_apply` | **request**, `emergency`, `reason` (si urgence) | demandeur (changement approuvé, ou urgence) |
| `secrets_request_get`, `secrets_request_list` | `request` / `tenant`, `state`, `kind`, `mine`, `limit`, `start` | demandeur ; `secrets.access.manage` |
| `secrets_policy_set`, `secrets_policy_delete`, `secrets_policy_list` | **tenant**, **path**, `required_approvals`, `operations`, `max_grant_duration` | `secrets.access.manage` |
| `secrets_access_due` (worker) | `limit` | expire les demandes échues, retire les accès échus depuis 30 jours (journal conservé) |

**Fonctions modifiées**

* `fn::secrets_can` reçoit `path`.
* Les fonctions de fiche, de version et de lecture passent le chemin.
* Les gardes de version et de fiche vérifient les protections.

**Entrées** : validées par `fn::validation_object_execute`. Les chemins utilisent la règle
existante `lyxal_storage_path` ; un dossier se termine par `/`.

**Fonctions Core réutilisées** : moteur de validation, `fn::security_audit_entry` (journal).

**Fonctions Core manquantes** : aucune (décision D1).

### Événements (`fn::event_publish`, jamais de valeur)

* **Accès** : `secrets.access.granted`, `.revoked`, `.emergency`.
* **Demandes** : `secrets.request.created`, `.approved`, `.rejected`, `.cancelled`, `.expired`,
  `.applied`.
* **Protections** : `secrets.policy.updated`.
* **Charge** : organisation, demandeur, chemin, opérations, durée, approbateurs.

### Erreurs (`error/acces/`)

`SECRETS_GRANT_NOT_FOUND`, `SECRETS_GRANT_INVALID` (durée, bénéficiaire hors organisation),
`SECRETS_REQUEST_NOT_FOUND`, `SECRETS_REQUEST_STATE_INVALID`, `SECRETS_REQUEST_SELF_APPROVAL`,
`SECRETS_REQUEST_ALREADY_DECIDED`, `SECRETS_CHANGE_IN_PROGRESS`, `SECRETS_APPROVAL_REQUIRED`,
`SECRETS_POLICY_NOT_FOUND`.

### Droits (`seeds/secrets_auth.surql`)

* **Nouvelles permissions** : `secrets.access.manage` (rôle `organization_admin`) et
  `secrets.access.emergency` (aucun rôle).
* **Installation** : `secrets.installation.manage` couvre les deux.

## 4. Rust

| Élément | Contenu |
| :--- | :--- |
| Modèles | `Grant`, `GrantCreateParams`, `GrantListParams`, `EmergencyAccessParams`, `AccessRequest`, `RequestKind`, `RequestState`, `RequestAccessParams`, `RequestChangeParams`, `RequestDecisionParams`, `RequestApplyParams`, `Policy`, `PolicySetParams`, wrappers `store.call_fn` |
| `SecretsService::propose` | comme `put`, mais avec l'étape `proposed` et la création de la demande de changement ; renvoie la demande |
| `SecretsMaintenanceWorker` | en plus : `secrets_access_due` ; `MaintenanceReport` complété (`requests_expired`, `grants_removed`) |
| Lecture (`reveal`) | inchangée : les accès sont contrôlés par la base |

## 5. Tests

* **Banc SurrealQL** :
  * accès par secret et par dossier, opérations, début et fin, retrait ;
  * accès d'une autre organisation refusé ;
  * liste filtrée par les accès ;
  * demande d'accès approuvée par N personnes, auto-approbation refusée, refus, expiration,
    annulation ;
  * protection : écriture directe refusée, demande de changement, application après
    approbation, valeur proposée jamais en service avant, une seule demande ouverte par secret ;
  * accès d'urgence (droit, assurance, durée, trace, événement), passer outre une protection ;
  * worker ;
  * journal et bus.
* **Rust** :
  * `propose` puis lecture : l'ancienne valeur reste servie jusqu'à l'application ;
  * lecture permise par un accès temporaire, puis refusée après son échéance ;
  * worker des demandes et des accès.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 6. Documents

* `README.md` et `ROADMAP.md` du module mis à jour.
* Ligne 4 du plan racine passée à « Réalisé ».
* Ce plan supprimé à la fusion de l'implémentation.

## 7. Checklist (§13)

* **Core** : aucune extension (D1).
* **Crypto** : aucune primitive nouvelle.
* **Droits** : toujours par `lyxal_auth`. Un accès ne retire jamais un droit et n'en donne
  aucun hors de son chemin.
* **Rust** : aucun `panic!`, aucune erreur silencieuse, aucune valeur dans un journal.
* **Zéro dette** : `0.1.0`, aucune migration.
