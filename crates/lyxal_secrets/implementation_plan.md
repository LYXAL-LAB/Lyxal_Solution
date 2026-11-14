# Plan d'implémentation — `lyxal_secrets`, lot 6 : clôture

Dernier lot du programme `lyxal_secrets` (`implementation_plan.md` à la racine). Il contient :

* les **corrections de l'audit de clôture** (skill `lyxal-audit`) ;
* les **procédures écrites** ;
* la **remise au propre de la documentation**.

Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Résultat de l'audit

**Verdict : non conforme (P1)** :

* aucun écart P0 ;
* **5 écarts P1**, chacun démontré par une sonde exécutée sur SurrealDB 3.3.4 ou par le code cité ;
* **9 écarts P2**.

**Contrôles passés** :

* `surreal validate` (44 fichiers) ;
* banc (226 assertions, chaque fonction publique appelée) ;
* `cargo clippy -D warnings` ;
* `cargo test` (42 tests) ;
* correspondance des DTO Rust avec `$params` SurrealQL : aucun écart ;
* aucune crate crypto directe, aucun `panic!` hors tests ;
* types scellés `pub(crate)` au `Debug` masqué ;
* valeurs jamais dans une adresse ;
* champs scellés illisibles, y compris par `WHERE`.

### Écarts P1

| N° | Constat | Correction |
| :- | :--- | :--- |
| **A1** | Un rédacteur sans double facteur récent crée directement une rotation « d'urgence » dans la table, puis coupe la version en service d'un secret protégé : la vérification d'assurance n'existe que dans la fonction, pas dans la garde | La garde de création d'une rotation exige, pour une urgence, le droit d'écriture et, pour une personne, l'assurance la plus haute et récente (comme pour les accès d'urgence) |
| **A2** | Un rédacteur pose lui-même l'étiquette `pending` pendant une rotation d'un secret protégé ; le worker reprend cette valeur et la met en service sans approbation | L'étiquette `pending` est réservée au worker et à la session système (garde et `version_add`) ; le worker ne reprend qu'une version qu'il a écrite pour cette rotation |
| **A3** | Une écriture directe qui ajoute une version **et** change la visibilité ou les consommateurs n'est ni journalisée ni publiée | La garde refuse de mêler l'avancée de version et un changement de fiche ; le journal ne saute plus de changement |
| **A4** | Un gestionnaire des accès s'accorde à lui-même un accès (même `read_value`, 90 jours) sans approbation : la séparation des tâches (« on n'approuve jamais sa propre demande ») est contournée | **Décision F1** |
| **A5** | La comparaison « en temps constant » de l'empreinte d'un partage est écrite à la main dans le module, sans validation CTO (§11.3) | **Décision F2** |

### Écarts P2

| N° | Constat | Correction |
| :- | :--- | :--- |
| A6 | Champs d'attribution (`granted_by`, `revoked_by`, `started_by`, `decided_by`, `updated_by` des protections) modifiables par écriture directe ; pas de garde sur `secrets_policy` | Gardes : attribution = appelant ; champs de décision posés seulement à la transition correspondante ; garde de `secrets_policy` |
| A7 | La garde de création d'une demande de changement ne revérifie pas le droit d'écriture sur le secret ni l'auteur de la version proposée | Contrôles reportés dans la garde |
| A8 | `purge_at` comparé sans `IS NOT NONE` ; un secret supprimé sans date de purge serait purgé tout de suite par le worker | `purge_at` obligatoire tant que l'état est `deleted` ; comparaisons protégées |
| A9 | La vue d'une rotation rend le jeton de réservation (`lease`) à tout lecteur | `lease` rendu seulement par `rotation_claim` |
| A10 | `check_rotation` lit la valeur et appelle le service extérieur avant de vérifier le droit `worker` ; la route `/check` échoue toujours pour une personne | Droit vérifié avant la lecture ; route réservée au worker |
| A11 | Un partage de l'installation réservé aux membres s'ouvre par toute session sans organisation | Réservé, pour l'installation, aux détenteurs de `secrets.installation.manage` |
| A12 | Une valeur JSON avec une clé vide, très longue ou plus de 200 clés est refusée avec un code trompeur | Noms de clés gardés seulement dans les bornes, sinon aucun |
| A13 | `SECRETS_ROTATION_TEST_FAILED` n'est émis par aucun code | Émis par le moteur quand le test d'un rotateur échoue |
| A14 | README inexact par endroits (clés d'organisation « sans accès utilisateur », gardes, doublon) ; bilan du worker sans les partages | Corrigés |

**Non vérifiés faute de moyen dans le banc** :

* filtrage des champs scellés par un `LIVE SELECT` : un test Rust est ajouté (base embarquée, requête en direct sur `secrets_version`) ;
* fuite par `ORDER BY` / `GROUP BY` : sonde ajoutée au banc.

## 2. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **F1** | Un gestionnaire des accès peut-il s'accorder un accès à lui-même ? | **Non.** Il passe par une demande d'accès, approuvée par un autre gestionnaire ; ou, en cas d'urgence, par l'accès d'urgence (1 heure, tracé, signalé). La séparation des tâches devient réelle |
| **F2** | Comment comparer la clé d'un lien de partage sans primitive nouvelle ? | Utiliser **le HMAC-SHA256 de `lyxal_crypto`** (primitive STABLE, vérification en temps constant déjà fournie). La base garde le HMAC d'un texte fixe calculé avec la clé du lien, au lieu de l'empreinte SHA-256. À l'ouverture, `verify_hmac_sha256`. La comparaison écrite à la main est supprimée. Aucune primitive nouvelle, rien à ajouter à `lyxal_crypto` |
| **F3** | Où ranger les procédures ? | **`crates/lyxal_secrets/PROCEDURES.md`**, écrit pour une personne d'exploitation, étape par étape (§3) |

## 3. Procédures écrites (`PROCEDURES.md`)

1. **Sauvegarde et restauration**
   * Ce qui est sauvegardé : la base, et la clé maîtresse **à part**. Une base sans clé ne s'ouvre pas.
   * Vérification d'une restauration : santé du module, lecture d'essai, `secrets_audit_verify`.
   * Limite : une version détruite reste dans les sauvegardes plus anciennes jusqu'à leur expiration.
2. **Garde et rotation de la clé maîtresse**
   * Génération, rangement hors de la base, variables `LYXAL__SECRETS__MASTER_KEY` et `LYXAL__SECRETS__PREVIOUS_MASTER_KEY`.
   * Rotation pas à pas : rescellement par le worker, suivi par la sonde, retrait de l'ancienne clé.
   * Perte de la clé : ce qui est perdu, et pourquoi rien ne peut le rouvrir.
3. **Accès d'urgence**
   * Qui reçoit `secrets.access.emergency` et comment.
   * Usage : accès d'une heure, changement appliqué avant les approbations.
   * Revue après coup : journal, événements, retrait de la permission.
4. **Compromission**
   * **Un secret a fuité** : rotation d'urgence, partages retirés, accès revus, journal vérifié.
   * **Une clé d'organisation est en cause** : rotation de la clé, rescellement.
   * **La clé maîtresse est en cause** : rotation de la clé maîtresse, rotation de toutes les clés d'organisation, puis des secrets.
   * **Le journal semble altéré** : `secrets_audit_verify`, puis conduite à tenir.

## 4. Documentation

* `RECHERCHE_SOURCES.md` réduit en **`MODELE_SOURCES.md`** : ce qui a réellement inspiré le module, par fonction et par produit (Vault, OpenBao, Infisical, Doppler, AWS, Azure, Google, Bitwarden, OWASP), sans le reste de l'étude.
* `README.md` corrigé (A14).
* `ROADMAP.md` : programme V1 retiré, il ne reste que « Après la V1 ».
* Plan racine :
  * ligne 6 passée à « Réalisé » ;
  * programme `lyxal_secrets` déclaré terminé ;
  * le plan racine est supprimé à la fusion, puisqu'il est exécuté (§0.3).
* `.agents/AGENTS.md` §6.
* `docs/14-roadmap/ROADMAP_NOYAU.md` : `lyxal_secrets` livré, prochain service du Noyau.

## 5. Contrats modifiés (§0.3)

* **`secrets_share.key_fingerprint`** : devient le HMAC-SHA256 du texte fixe `lyxal_secrets.share.v1` sous la clé du lien (hexadécimal, 64 caractères), selon la décision F2. `share_create` et `share_open` sont modifiés.
* **`fn::secrets_grant_create`** : refuse un bénéficiaire égal à l'appelant (`SECRETS_GRANT_INVALID`, raison `self`), selon la décision F1 ; la garde fait de même.
* **`fn::secrets_rotation_view`** : ne rend plus `lease` ; `RotationRecord.lease` reste rempli par `rotation_claim` seulement.
* **Route `POST /secrets/{id}/check`** : réservée à la session système et au worker. Elle est retirée de l'API HTTP, l'essai sans bascule restant fait par le worker et le service.

## 6. Tests

Chaque correction reprend la sonde de l'audit dans le banc, et la sonde doit désormais échouer :

| Écarts | Essai |
| :--- | :--- |
| A1 | rotation d'urgence directe sans assurance |
| A2 | étiquette `pending` posée par un rédacteur |
| A3 | méta et version mêlées |
| A4 | accès à soi-même |
| A6 | attribution falsifiée |
| A7 | demande trompeuse |
| A8 | purge sans date |
| A9 | `lease` invisible |
| A11 | partage de l'installation |

S'y ajoutent :

* **Rust** : `LIVE SELECT` sans enveloppe ; partage ouvert après le passage au HMAC ; test de rotateur en échec qui produit `SECRETS_ROTATION_TEST_FAILED` ; valeur JSON aux noms de clés hors bornes acceptée.
* **Hôte** : routes inchangées sauf `/check`.
* **Contrôle complet** : `scripts/ci/ci_local.sh`.

## 7. Checklist (§13)

* **Core** : aucune extension.
* **Crypto** : aucune primitive nouvelle ; la comparaison locale est supprimée (F2).
* **Zéro dette** :
  * `RECHERCHE_SOURCES.md` remplacé ;
  * plans exécutés supprimés ;
  * `SECRETS_ROTATION_TEST_FAILED` utilisé ;
  * versions `0.1.0`.
