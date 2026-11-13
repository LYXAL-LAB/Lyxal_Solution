# Plan d'implémentation — programme `lyxal_secrets` V1

Création du crate du Noyau Technique `lyxal_secrets` (rang 4 de
[`docs/14-roadmap/ROADMAP_NOYAU.md`](docs/14-roadmap/ROADMAP_NOYAU.md)) : coffre-fort des secrets
applicatifs (clés de fournisseurs, identifiants de canaux, jetons, secrets de signature), avec
le contrôle de qui les lit. Étude des produits du marché, offres payantes comprises, et de
SurrealDB 3.3.4 : [`crates/lyxal_secrets/RECHERCHE_SOURCES.md`](crates/lyxal_secrets/RECHERCHE_SOURCES.md).

**Deux niveaux de validation** (`AGENTS.md` §3) : ce plan fixe le programme (architecture,
modèle, lots, décisions). Chaque lot a ensuite son propre plan détaillé, soumis au CTO avant
toute ligne de code : contrats Rust `XxxParams` / `XxxResult`, signatures SurrealQL, codes
d'erreurs, tests.

## 1. Architecture

### 1.1. Répartition SurrealQL / Rust

SurrealDB 3.3.4 ne chiffre rien (ni fonction de chiffrement, ni fichiers chiffrés sur disque)
et ne déclenche rien sur une lecture (`RECHERCHE_SOURCES.md` §4). Le travail est donc partagé :

| SurrealQL (données et règles) | Rust (crate `lyxal_secrets`, `lyxal_crypto`) |
| :--- | :--- |
| Fiche de chaque secret : chemin, organisation, type, propriétaire, contact, consommateurs, étiquettes, expiration, rotation | Scellement et ouverture de chaque version (`CryptoEngine`, AES-256-GCM, contexte lié) |
| Versions : numéro, état, étiquettes `current` / `previous` / `pending`, enveloppe scellée | Clés par organisation, scellées par la clé maîtresse de l'hôte |
| Droits par opération (`lyxal_auth`), accès temporaires, approbations | Lecture d'une valeur : contrôle, **trace écrite avant toute remise**, puis ouverture |
| Journal chaîné de toutes les opérations (`fn::security_audit_entry`) | Rescellement après rotation de clé, purge, échéances (workers supervisés) |
| États, transitions, rétention, événements `secrets.*` sans valeur | Interface Rust pour les autres modules ; routes HTTP de l'hôte |

### 1.2. Clés

```text
clé maîtresse (environnement de l'hôte, LYXAL__CRYPTO__APPLICATION_KEY, jamais en base)
   └── scelle la clé de chaque organisation (secrets_tenant_key, contexte global du module)
          └── scelle chaque version d'un secret (enc:v2, contexte lié à l'organisation,
              au secret et au numéro de version)
```

* Une valeur copiée vers un autre secret, une autre version ou une autre organisation ne
  s'ouvre pas : le contexte de scellement l'en empêche (modèle AWS `SecretARN` + `SecretVersionId`).
* Supprimer la clé d'une organisation rend illisibles tous ses secrets **dans la base en
  service** (effacement cryptographique, utile à la fermeture d'un compte). Une sauvegarde
  antérieure contient encore cette clé, scellée par la clé maîtresse : elle reste lisible tant
  que la sauvegarde est conservée **et** que la clé maîtresse qui l'a scellée existe. L'effacement
  n'est donc complet qu'à l'expiration des sauvegardes, ou après rotation de la clé maîtresse
  suivie de la destruction de l'ancienne (ce qui rend illisibles toutes les sauvegardes
  antérieures). La procédure de sauvegarde du lot 6 fixe cette règle.
* Après rotation de la clé maîtresse ou d'une clé d'organisation, un worker rescelle **toutes**
  les versions conservées (`reencrypt_if_needed`), sans exposer de valeur ; l'ancienne clé est
  ensuite révoquée.
* Aucune primitive nouvelle : seules les fonctions STABLE de `lyxal_crypto` sont utilisées
  (`EncryptionKey::generate` / `import`, `KeyRingBuilder`, `CryptoEngine::seal` / `open` /
  `reencrypt_if_needed`). La hiérarchie de clés est soumise au CTO (décision K1, §11.3).

### 1.3. Lecture d'une valeur

1. Droits vérifiés (`lyxal_auth`, accès temporaires, visibilité, double facteur pour un humain) ;
2. version choisie (étiquette `current` par défaut), refusée si désactivée, détruite, expirée ou
   secret supprimé ;
3. **trace écrite au journal** (qui, quoi, quelle version, type de session, adresse) ; si elle
   ne peut pas l'être, la lecture est refusée (modèle Vault) ;
4. ouverture en mémoire (`SecretBytes`, effacé à la libération) et remise.

Un refus est aussi journalisé (OWASP 8.3). Aucune valeur n'apparaît jamais dans un journal, une
erreur ou un événement.

### 1.4. Modèle (SurrealDB, préfixe `secrets_`)

| Table | Contenu |
| :--- | :--- |
| `secrets_settings` | réglages de l'installation, surchargés par organisation : versions gardées, durée de suppression douce, protection contre la purge, taille maximale, visibilité par défaut, délai d'alerte avant échéance |
| `secrets_tenant_key` | clé d'une organisation, scellée par la clé maîtresse ; identifiant et état (`active`, `decrypt_only`, `revoked`) |
| `secrets_secret` | `tenant` (`NONE` : installation), chemin (`/notification/smtp`), type, description, propriétaire, contact, consommateurs prévus, métadonnées libres, visibilité (`restricted` / `revealable`), écriture conditionnelle exigée, expiration, période de rotation, prochaine échéance, état (`active`, `disabled`, `deleted`), date de purge, version courante |
| `secrets_version` | secret, numéro, enveloppe scellée (`select NONE` pour tout utilisateur), identifiant de clé, état (`enabled`, `disabled`, `destroyed`), étiquettes, auteur, date ; la structure des clés d'un secret JSON sans ses valeurs |
| `secrets_grant` | accès additionnel d'une identité ou d'une application : portée par chemin (jokers), opérations, expiration, motif, auteur |
| `secrets_request` | demande d'accès ou de changement : demandeur, objet, approbations reçues, état, expiration |
| `secrets_audit` | journal en ajout seul, chaîné ; aucune valeur |

* **Droits** par `fn::auth_has_permission`, par opération (modèle Azure) :
  `secrets.secret.list` (fiches sans valeur), `secrets.value.read`, `secrets.secret.write`,
  `secrets.secret.delete`, `secrets.secret.restore`, `secrets.secret.purge`,
  `secrets.access.manage`, `secrets.audit.read`, `secrets.settings.manage`,
  `secrets.installation.manage`, `secrets.worker`.
* `secrets_grant` donne un droit **en plus**, limité à des chemins et le plus souvent à une
  durée (accès temporaire) ; il ne retire jamais un droit.
* Données d'une organisation supprimées avec elle (`REFERENCE ON DELETE CASCADE` sur `tenant`).
* Tables sans `CHANGEFEED` ni historique natif : une version détruite disparaît vraiment
  (`RECHERCHE_SOURCES.md` §4).

## 2. Dépendances

`lyxal_secrets` dépend de `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` et, en Rust,
de `lyxal_surreal`, `lyxal_runtime` et `lyxal_crypto`. Aucune bibliothèque nouvelle. Aucun module
existant ne dépend de `lyxal_secrets` dans ce programme (décision B1).

## 3. Fonctions publiques (`fn::secrets_*($params: object)`)

| Domaine | Fonctions |
| :--- | :--- |
| Réglages | `secrets_settings_get`, `secrets_settings_set` |
| Secrets | `secrets_secret_create`, `_update` (métadonnées), `_get`, `_list` (par chemin), `_disable`, `_enable`, `_delete` (douce), `_restore`, `_purge` |
| Versions | `secrets_version_add` (enveloppe scellée par Rust, écriture conditionnelle), `_list`, `_label` (déplacer une étiquette, retour arrière compris), `_disable`, `_enable`, `_destroy` |
| Accès | `secrets_grant_create`, `_list`, `_revoke` ; `secrets_request_create`, `_approve`, `_reject`, `_list` |
| Journal | `secrets_audit_list`, `secrets_audit_verify` (chaîne intacte) ; `secrets_read_begin` (droits + trace, appelé par Rust avant d'ouvrir) |
| Workers | `secrets_due_list` (échéances), `secrets_purge_due`, `secrets_rewrap_list` |

Entrées par le moteur `fn::validation_object_execute` de `lyxal_core` ; erreurs `SECRETS_*` en
master data ; écriture principale vérifiée (`SECRETS_WRITE_FORBIDDEN`).

Côté Rust, les autres modules utilisent `SecretsClient` (lecture par référence de secret,
écriture, rotation), jamais les tables.

## 4. Événements (`fn::event_publish`)

`secrets.secret.created`, `.updated`, `.deleted`, `.restored`, `.purged`,
`secrets.version.created`, `.disabled`, `.destroyed`, `secrets.secret.expiring`,
`.expired`, `.rotation_due`, `secrets.access.granted`, `.revoked`,
`secrets.request.created`, `.decided`, `secrets.emergency.used` : identifiants, chemin,
version, auteur ; **jamais de valeur**. `lyxal_notification` pourra s'y abonner pour les alertes
et rappels, sans que `lyxal_secrets` le connaisse.

## 5. Lots

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **1** | **Réalisé.** Socle SurrealQL : réglages, fiches, versions, étiquettes, états, suppression en trois temps, écriture conditionnelle, droits par opération, visibilité, journal chaîné des écritures, événements, erreurs, banc | `lyxal_secrets` |
| **2** | Rust : clés par organisation, scellement et ouverture, lecture tracée avant remise, `SecretsClient`, workers de rescellement et de purge, module et sonde de santé, hébergement par l'hôte | `lyxal_secrets`, `apps/lyxal-server` |
| **3** | Cycle de vie : expiration appliquée, alertes avant échéance, rotation en quatre étapes (`pending` → test → `current`, ancienne en `previous`) pour les modules qui savent tourner leurs identifiants, essai de rotation sans bascule, rotation manuelle d'urgence, worker des échéances | `lyxal_secrets` |
| **4** | Accès avancés : accès temporaires par chemin, demandes d'accès approuvées, approbation des changements par N personnes (auto-approbation interdite), accès d'urgence tracé et signalé | `lyxal_secrets` |
| **5** | Hôte : routes HTTP (fiches, écriture, révélation avec double facteur, versions, retour arrière, restauration, journal), partage à usage unique (lien à durée et nombre d'ouvertures limités) | `apps/lyxal-server` |
| **6** | Clôture : audit `lyxal-audit`, procédures écrites (sauvegarde et restauration, garde de la clé maîtresse, accès d'urgence, compromission), `README.md`, `ROADMAP.md`, `AGENTS.md` §6, `ROADMAP_NOYAU.md`, `RECHERCHE_SOURCES.md` réduit en `MODELE_SOURCES.md` | docs |

**Feuille de route après la V1** : secrets dynamiques (identifiants créés à la demande, avec
bail), synchronisation vers AWS, Azure, Google ou GitHub, références entre secrets, retour d'un
dossier entier à un état passé, clé maîtresse dans un KMS ou un HSM, organisation « scellable »,
envoi du journal vers un outil de sécurité (SIEM) et durée de conservation réglable.

## 6. Tests et critères de production

* **Banc SurrealQL** : chaque fonction ; isolation entre organisations ; chaque droit refusé
  sans permission ; enveloppe jamais lisible par un utilisateur (ni `SELECT`, ni `WHERE`, ni
  `LIVE`) ; écriture conditionnelle ; étiquettes ; transitions d'état ; journal chaîné vérifié,
  modification détectée.
* **Rust** : valeur écrite puis relue à l'identique ; enveloppe déplacée vers un autre secret ou
  une autre organisation refusée ; lecture refusée si le journal est indisponible ; rotation de
  clé puis rescellement complet ; clé d'organisation supprimée → secrets illisibles dans la base en service ; aucune
  valeur dans les journaux, erreurs et `Debug`.
* **Hôte** : parcours de bout en bout, révélation refusée sans double facteur, partage à usage
  unique ouvert une seule fois.
* Contrôle complet : `scripts/ci/ci_local.sh` à chaque lot.

## 7. Checklist (§13)

* Core : règles de validation existantes ; `fn::security_audit_entry` / `_verify` pour le
  journal, `fn::security_secret_mask` pour les aperçus ; aucune extension demandée à ce stade.
* Crypto : uniquement les fonctions STABLE de `lyxal_crypto` ; la hiérarchie de clés (K1) est
  soumise au CTO ; aucune dépendance de chiffrement ajoutée.
* Rust : aucun `panic!`, aucune erreur silencieuse ; valeurs en `SecretBytes` / `SecretString`.
* Zéro dette : versions `0.y.z`, une seule migration par module.
* Licences : aucun code repris ; Vault (BUSL), Doppler, AWS, Azure, Google, Bitwarden et
  Akeyless en conception seule ; OpenBao (MPL-2.0) et Infisical (MIT) en conception seule.

## 8. Décisions du CTO (13 novembre 2026)

K1 à B1 validées selon les recommandations.

| # | Question | Décision |
| :- | :--- | :--- |
| K1 | Hiérarchie de clés | **Une clé par organisation**, scellée par la clé maîtresse de l'hôte (modèle Infisical) : isolation entre organisations et effacement d'une organisation entière par sa clé (base en service ; sauvegardes antérieures effacées à leur expiration, §1.2) |
| K2 | Après rotation d'une clé | **Rescellement automatique de toutes les versions conservées**, puis révocation de l'ancienne clé (AWS ne rescelle que les versions étiquetées) |
| V1 | Qui peut relire une valeur | **Visibilité restreinte par défaut** : un humain écrit mais ne relit pas ; seuls les modules et applications autorisés lisent (modèle Doppler). Un secret peut être déclaré « révélable », lu alors avec la permission dédiée et le **double facteur** |
| V2 | Versions conservées | **10 par défaut** (Vault), réglable par organisation jusqu'à 100 ; au-delà, la plus ancienne non étiquetée est détruite |
| V3 | Suppression | **Suppression douce de 30 jours** (réglable de 7 à 90), puis purge ; purge = droit distinct ; protection contre la purge activable par organisation, irréversible une fois activée (modèle Azure) |
| V4 | Secret expiré | **Refusé à la lecture** (contrairement à Azure, où l'échéance n'est qu'indicative) ; alerte avant l'échéance |
| A1 | Approbations et accès temporaires | **Dans la V1** (lot 4) : fonctions payantes chez Vault et Infisical, et attendues d'un coffre-fort de référence |
| A2 | Partage à usage unique | **Dans la V1** (lot 5) |
| M1 | Identités machine | **Par `lyxal_auth`** (applications et clés d'API existantes), pas par les accès `BEARER` de SurrealDB, dont la révocation ne coupe pas une connexion ouverte |
| H1 | Historique natif de SurrealDB | **Non activé** : une version détruite doit disparaître vraiment |
| B1 | Bascule de modules | **Aucune dans ce programme** : `lyxal_notification` basculera dans son lot V1-e, `lyxal_connect` sera créé dessus. Les identifiants des supports de `lyxal_storage` et la clé maîtresse **restent dans l'environnement de l'hôte** (racines de confiance, nécessaires avant que la base soit lisible ; OWASP 2.2) |
