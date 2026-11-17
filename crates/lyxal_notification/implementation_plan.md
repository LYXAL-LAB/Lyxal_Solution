# Plan d'implémentation — `lyxal_notification`, lot 7 : clôture

Dernier lot du programme `lyxal_notification` V1 complet (`implementation_plan.md` à la racine,
décisions K1 à K10 validées ; lots 1 à 6 livrés). Ce lot ne change pas ce que fait le module : il
corrige les écarts trouvés par l'audit `lyxal-audit`, complète la documentation d'exploitation et
ramène la feuille de route aux évolutions V2 / V3. Aucune ligne de code avant la validation du CTO
(`.agents/AGENTS.md` §3).

## 1. Décisions du CTO

À valider par le CTO.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **H1** | Relais SMTP d'une organisation (écart R1, P1) | Le nom de l'hôte SMTP est résolu à chaque envoi et chaque adresse obtenue passe le **même contrôle** que les messageries et adresses web (`OutboundClient` : plages privées, locales, réservées refusées) ; la connexion se fait à l'adresse vérifiée, le nom servant au TLS. Vaut pour l'envoi et pour l'essai d'une intégration (`POST /integrations/{id}/test`), qui ne peut donc plus sonder le réseau interne. Le relais de l'**installation** garde le droit d'être local (`local_plain`, boucle locale), réglé par l'exploitant. La limite connue correspondante est retirée de la feuille de route. |
| **H2** | Appareils et adresses de la personne (petit manque connu) | Ajouter les routes de l'hôte manquantes : liste et retrait de ses appareils (`GET /my/devices`, `DELETE /my/devices/{appareil}`) et de ses adresses de messagerie et web (`GET /my/endpoints`, `DELETE /my/endpoints/{adresse}`), sur les fonctions existantes `fn::notification_my_device_list`, `_delete`, `fn::notification_my_endpoint_list`, `_delete`. Aucune nouvelle règle. |
| **H3** | Langue de l'organisation lue par le module (écart S5) | L'événement `notification_run_organization_locale` lit directement le champ `locale` de `auth_organization` (table de `lyxal_auth`, module dont `lyxal_notification` dépend déjà). `fn::auth_organization_get` ne convient pas : il vérifie les droits de la personne qui déclenche, alors que la langue doit être lue quels que soient ses droits. **Proposition** : garder cette lecture et la consigner comme exception documentée (README, section Droits), plutôt que d'ajouter une fonction à `lyxal_auth`. |
| **H4** | Taille de `data` d'un abonné (besoin du Core) | Le module borne lui-même `data` à 8 Kio (`string::len(<string> data)`), faute de règle du Core sur la taille d'un objet. **Proposition** : ajouter à `lyxal_core/validation` une règle générique `max_serialized_length` (taille d'une valeur une fois écrite en JSON, pour un objet ou un tableau), au catalogue du moteur, avec ses tests ; le module l'utilise et retire son contrôle local (§5.7.7, extension du Core soumise au CTO). |

## 2. Corrections de l'audit

Audit lancé le 17 novembre 2026 sur `main` (lot 6 fusionné) : SurrealQL (contrôles 1, 3, 5,
7 bis) et Rust / hôte (contrôles 2, 4, 6, 7, 7 bis). Aucun P0. Chaque écart a été relu dans le code.

### 2.1. P1

| N° | Écart | Correction |
| :- | :--- | :--- |
| R1 | Relais SMTP sans contrôle des adresses résolues (worker et route d'essai) | Décision H1 ; test : hôte dont le nom se résout en adresse privée refusé, à l'envoi et à l'essai |
| R2 | `EndpointCreateParams` et `MyEndpointCreateParams` montrent l'adresse (secrète : jeton du salon) dans leur `Debug` | `Debug` écrit à la main, adresse masquée (`[REDACTED]`), comme `DeviceRegisterParams` ; test |
| R3 | `ModuleDescriptor` différent de `manifest.toml` (capacité `push` absente, description incomplète) | Descripteur aligné sur le manifeste ; test qui compare les deux |
| S1 | `fn::notification_feed_view($item: object)` appelée par l'hôte (requête `LIVE SELECT`) : contrat public sans `$params: object` | Signature `($params: object)` avec `$params.item` ; appels internes, hôte, test `fil.test.surql` et README mis à jour |
| S2 | Numéro de SMS nettoyé par un `string::trim` local après `fn::validation_phone` | Valeur nettoyée par le Core (règle `e164` du moteur) |
| S3 | Hôtes autorisés remis en minuscules et dédoublonnés localement | Moteur `fn::sanitize_object_execute` (minuscules) et règle `array_unique` du Core |

### 2.2. P2

| N° | Écart | Correction |
| :- | :--- | :--- |
| R4 | Données personnelles visibles dans le `Debug` de `SubscriberUpsertParams`, `IntegrationTestParams`, `IntegrationTestTarget`, `SecurityAlertPayload` (aucun journal ne les écrit aujourd'hui) | `Debug` masquant e-mail, téléphone, adresse |
| R5 | Champs scellés publics (`ClaimedEndpoint`, `ClaimedJob.secret`) | `pub(crate)` (l'hôte ne les lit pas) |
| R6 | Dépendances inutilisées : `lyxal_error`, `tokio-util` | Retirées de `Cargo.toml` |
| R7 | Commentaires renvoyant à des plans exécutés (« plan V1-a », « plan du lot 3 », numéros de lot) | Réécrits pour décrire le code tel qu'il est |
| R8 | 31 des 74 fonctions Rust du store jamais appelées par un test Rust (contrat prouvé seulement à la lecture) | Test d'intégration qui appelle chacune une fois et relit son résultat typé |
| S4 | Garde mort dans `notification_topic_member_event` (champs absents de la table, condition toujours fausse) | Retiré |
| S6 | Écriture principale non vérifiée dans `notification_job_fail`, `job_complete`, `inbox_deliver` | Résultat vérifié, `NOTIFICATION_WRITE_FORBIDDEN` sinon ; test sous une identité non autorisée |
| S7 | Trois `string::lowercase` inutiles sur des adresses déjà normalisées | Retirés |
| S8 | Liste des fonctions internes du README incomplète (10 absentes) | Complétée |
| S9 | Feuille de route : ligne « V1-e Terminée » | Retirée (§4) |
| S10 | `MODELE_SOURCES.md` périmé (push « plus tard » avec d'autres crates, conditions « à fournir », tables dites « relation », fil sur `notification_message`) | Mis à jour sur l'état réel |
| S11 | `implementation_plan.md` du programme à la racine | Supprimé (programme terminé) |

## 3. Documentation d'exploitation

`README.md` §6 « Exploitation » (déjà présent) complété pour couvrir tout le module, au même
niveau que `lyxal_scheduler` :

* mise en service : intégrations par canal, secrets à créer dans `lyxal_secrets` (chemins, droits),
  paire VAPID, compte de service FCM, clé APNs ; réglages de l'installation (hôtes autorisés,
  rétentions) ;
* surveillance : file d'envoi, échecs, retours des fournisseurs, appareils retirés, sondes de
  santé, événements à suivre ;
* incidents : fournisseur en panne (bascule), clé VAPID changée, secret tourné, jeton révoqué,
  abonné qui ne reçoit rien (préférences, heures calmes, suppression) ;
* purge et rétentions.

Titres du README débarrassés des numéros de lot (« (lot 4) » …). `AGENTS.md` §6 et
`docs/14-roadmap/ROADMAP_NOYAU.md` décrivent `lyxal_notification` comme livré, avec tous ses
canaux.

## 4. Feuille de route

`ROADMAP.md` ramenée aux évolutions à venir :

* **Après V1** : choix de l'intégration dans les surcharges d'un déclenchement, fournisseurs Amazon
  SES / SendGrid / OVHcloud, retours de toutes les parties d'un SMS Vonage, Vonage par l'API
  Messages, clé VAPID par appareil, boutons d'action et regroupement des notifications push ;
* **V2** et **V3** inchangées ;
* « Essais réels à faire » **conservée telle quelle** ;
* « Limites connues » : celles du relais SMTP (H1) et des routes de la personne (H2) retirées ;
* « Points à décider par le CTO » conservés.

## 5. Tests

* Banc SurrealQL : S1 (nouvelle signature), S2, S3, S6 (refus sous identité non autorisée).
* Rust : R2, R4 (`Debug` masqué), R3 (descripteur = manifeste), R8 (toutes les fonctions du store).
* Hôte : H1 (hôte SMTP résolu en adresse privée refusé à l'envoi et à l'essai), H2 (liste et retrait
  par la personne ; refus pour l'appareil d'un autre).
* H4 : tests de la nouvelle règle dans le banc `lyxal_core`.
* `scripts/ci/ci_local.sh` complet avant la demande de fusion.

## 6. Checklist (§13)

* Core : H4 soumis au CTO ; S2, S3 ramenés au Core ; aucune autre primitive locale.
* SurrealQL : signatures `$params: object` (S1), écritures vérifiées (S6), `COMMENT` partout.
* Rust : aucun secret ni donnée personnelle dans un `Debug` (R2, R4), champs scellés internes (R5).
* Sécurité : appels sortants SMTP contrôlés (H1).
* Zéro dette : dépendances, commentaires, garde mort, documents périmés, plan du programme
  supprimés ; ce plan supprimé une fois exécuté.
* Aucun besoin cryptographique nouveau.
