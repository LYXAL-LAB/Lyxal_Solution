# Plan du lot 7 — `lyxal_auth` : finition (purge des supprimés, langue des erreurs)

Programme : `implementation_plan.md` à la racine. Lot de finition de la V1, ouvert à la demande du
CTO après la clôture (lot 6). Aucune ligne de code avant la validation du CTO
(`.agents/AGENTS.md` §3).

## 1. Constat

| Sujet | État actuel |
| :--- | :--- |
| Organisations et identités supprimées | Passage à l'état `deleted` (révocation des sessions, `not_before`), puis plus rien : l'enregistrement, ses identifiants, ses adresses, ses moyens d'authentification et les données métier de l'organisation restent en base indéfiniment. Inscrit à `ROADMAP.md` au lot 6 |
| Références vers une organisation | Champs `tenant` / `organization` dans `lyxal_auth`, `lyxal_catalogue` (`catalogue_item.tenant`, `catalogue_item_personnalisation.tenant`) et `lyxal_notification` (réglages, parcours, gabarits, mises en page, exécutions, liste de suppression) ; seule `notification_suppression.tenant` déclare un comportement à la suppression (`REFERENCE ON DELETE CASCADE`) |
| Références vers une identité | Moyens d'authentification, codes de secours, clés d'API, parcours, actions imposées, changements d'adresse : `REFERENCE ON DELETE CASCADE`. Traces (`invited_by`, `granted_by`, `inviter`, `accepted_by`, sessions) : aucun comportement déclaré |
| Langue des erreurs | L'hôte lit `Accept-Language` et résout dans cette langue les codes qu'il lève lui-même ; une erreur renvoyée par une fonction SurrealQL (`fn::error_result`) reste résolue dans la langue par défaut (`fr`), car aucun `*Params` ne transmet `language` |

## 2. Purge des organisations et identités supprimées

* **Date de suppression** : champ `deleted_at` (`option<datetime>`, écrit par un événement de la
  base au passage à `deleted`, non modifiable par les sessions) sur `auth_organization` et
  `auth_identity`.
* **Purge** dans `fn::auth_purge` (worker existant, par paquets, interruptible) : organisations
  et identités `deleted` depuis plus que la durée de conservation (Q1) supprimées physiquement.
  Événements `auth.organization.purged` et `auth.identity.purged` (identifiant seulement, aucune
  donnée personnelle) publiés avant la suppression, pour les modules qui gardent des données hors
  de la base.
* **Ce qui disparaît avec une identité** : identifiants, adresses, moyens d'authentification,
  codes de secours, clés d'API, parcours, actions imposées, changements d'adresse (déjà
  `CASCADE`) ; adhésions et rôles (`auth_member_of`, `auth_has_role` : relations supprimées avec
  leur extrémité) ; sessions et jetons de renouvellement (`CASCADE` ajouté). Traces
  (`invited_by`, `granted_by`, `inviter`, `accepted_by`) : `REFERENCE ON DELETE UNSET` (la trace
  reste, sans désigner la personne).
* **Ce qui disparaît avec une organisation** (Q2) : domaines, invitations, rôles et politique
  propres, applications de l'organisation et leurs secrets, adhésions, sessions (`CASCADE` dans
  `lyxal_auth`) ; données métier des modules : chaque module déclare lui-même, sur ses champs
  `tenant`, le comportement voulu (`REFERENCE ON DELETE CASCADE`) — `lyxal_auth` ne connaît pas
  ses consommateurs (§5.6.1). Ce lot le déclare pour `lyxal_catalogue` (articles privés et
  personnalisations) et `lyxal_notification` (tous ses champs `tenant`).
* **Garde** : une identité ou une organisation encore `active` ne peut pas être supprimée
  physiquement, même par `auth.identity.manage` / `auth.organization.manage` (`DELETE` refusé
  par les permissions, comme aujourd'hui) ; seule la purge (session système) supprime.
* **Tests** : banc SurrealQL (purge avant et après la durée, cascade et `UNSET`, événements,
  identité active intouchée) ; banc du catalogue et des notifications (données de l'organisation
  supprimées avec elle).

## 3. Langue des erreurs

* L'hôte (`render_error`, `apps/lyxal-server/src/http/auth.rs`) résout aussi les erreurs métier
  renvoyées par SurrealQL dans la langue de la requête : code repris de l'erreur, définition
  relue par `fn::error_result($code, $language, $details)` avec les détails d'origine. Un seul
  endroit, aucun changement des 74 `*Params` ni des fonctions SurrealQL.
* Langue de la requête (Q3) : `Accept-Language`, sinon le trait `locale` de l'identité
  connectée, sinon `fr`.
* Test : même erreur métier rendue en français et en anglais selon l'en-tête.

## 4. Fonctions Core

Réutilisées : `fn::validation_object_execute`, `fn::sanitize_object_execute`. Aucune fonction
Core manquante. Aucune cryptographie nouvelle.

## 5. Contrats modifiés

| Élément | Avant | Après |
| :--- | :--- | :--- |
| `auth_organization`, `auth_identity` | état `deleted` conservé | champ `deleted_at`, suppression physique après la durée de conservation |
| `fn::auth_purge` (résultat) | 9 compteurs | + `organizations_purged`, `identities_purged` (et `AuthPurgeResult` en Rust) |
| Événements | — | `auth.organization.purged`, `auth.identity.purged` |
| Champs `tenant` de `lyxal_catalogue` et `lyxal_notification` | sans comportement à la suppression | `REFERENCE ON DELETE CASCADE` |
| Erreurs métier de l'hôte | langue par défaut | langue de la requête |

Tous les appelants et tests du dépôt sont mis à jour dans le même changement.

## 6. Questions au CTO

| N° | Question | Recommandation |
| :--- | :--- | :--- |
| Q1 | Durée de conservation avant la purge d'un élément supprimé | 30 jours (réglable par la politique de l'installation, thème `retention`) : délai pour annuler une suppression faite par erreur |
| Q2 | Données métier d'une organisation purgée | Supprimées avec elle (chaque module le déclare sur ses champs `tenant`) ; aucune donnée d'un client supprimé n'est gardée |
| Q3 | Langue des messages d'erreur | `Accept-Language`, puis la langue de l'identité connectée, puis `fr` |
