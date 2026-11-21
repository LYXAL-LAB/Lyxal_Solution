# `lyxal_mail` — serveur de courrier

**État : modèle de données SurrealQL (lot 4c du programme courrier) et contrat réseau des
sessions en Rust (lot 3).** Le module déclare ses tables, fonctions, gardes, erreurs `MAIL_*`,
événements et permissions (`manifest.toml`, `[resources]`) ; aucun service Rust ne les appelle
encore (lot 4d : `MailStore`, `MailIngest`, `MailContent`, `MailMaintenance`, `MailModule`), ni
aucun protocole (lots 5 à 12). Le module est installé et démarré par l'hôte
`apps/lyxal-groupware`, qui le porte par un `ManifestModule` avec ses dépendances (`lyxal_auth`,
`lyxal_secrets`, `lyxal_storage`) et lui rattache ses écoutes (workers
`lyxal_mail:mail.listener.<id>`). Inscrit au Noyau Technique dans `.agents/AGENTS.md` §6 et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md). Plan du lot en
cours : [`implementation_plan.md`](implementation_plan.md) (validé par le CTO).

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0).

## État actuel : modèle de données (SurrealQL)

Dépendances du manifeste : `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`,
`lyxal_storage`. Licence des fichiers SurrealQL : `AGPL-3.0-only` (en-tête SPDX).

### Tables (`schema/`)

Toutes `TYPE NORMAL SCHEMAFULL`, rattachées à une organisation (`tenant`, `REFERENCE ON DELETE
CASCADE`) : une organisation supprimée emporte tout son courrier.

| Table | Contenu |
| :--- | :--- |
| `mail_settings` | Réglages de l'installation et des organisations : taille d'un message (50 Mio par défaut), quota par défaut (aucun), conservation des effacements (30 jours, 7 à 365), dossiers par compte (1 000), adresses par compte (100), mots-clés par message (50) |
| `mail_domain` | Domaine de courrier repris d'un domaine **vérifié** de `lyxal_auth` (M9), forme ASCII seulement (M10), état, séparateur de sous-adresse (`+` ou aucun), nombre d'adresses ; le retrait du domaine dans `lyxal_auth` est refusé tant qu'il sert au courrier (`MAIL_DOMAIN_EXISTS`), sauf avec l'organisation |
| `mail_account` | Compte d'un membre (une identité par organisation), état (`active`, `disabled`, `deleting`), adresse principale, quota, compteurs du compte : messages, volume, **numéro de modification du compte** (M6), prochaine UIDVALIDITY, plancher des changements, dossiers, adresses |
| `mail_address` | Adresse d'un compte ou alias vers 1 à 50 comptes de l'organisation ; partie locale ASCII en minuscules |
| `mail_mailbox` | Dossier : chemin (`/`), parent, rôle SPECIAL-USE, abonnement, ordre, UIDVALIDITY, prochain UID, compteurs (total, non lus, volume, `HIGHESTMODSEQ`) |
| `mail_content` | Contenu d'un message (fichier `.eml` de `lyxal_storage`) : clé `<compte>/<UUID v7>.eml`, fiche de stockage, état `pending` → `stored` → `released`, taille, `protection` (`platform` ; `openpgp`, `client` réservés, M15), lecteurs (`refs`) |
| `mail_message` | Message d'un dossier (un seul, M5) : UID, numéros de modification, fil immuable (M7), dates, drapeaux système en booléens, mots-clés en minuscules triés, `Message-ID`, sujet de base, enveloppe typée et structure MIME facultatives (M8) |
| `mail_tombstone` | Effacements (message effacé ou déplacé hors d'un dossier, dossier supprimé) avec leur numéro de modification, pour `QRESYNC` et `Email/changes` |

### Droits (`fn::mail_can`, seed `seeds/mail_auth.surql`)

| Permission | Portée | Mot de passe d'application | Rôles | Donne |
| :--- | :--- | :-: | :--- | :--- |
| `mail.mailbox.access` | organisation | oui | membre, administrateur | sa propre boîte (identité du compte = identité de la session) |
| `mail.domain.manage` | organisation | non | administrateur | domaines, comptes, adresses, alias, réglages ; **jamais** le contenu des boîtes (M11) |
| `mail.installation.manage` | installation | non | administrateur de la plateforme | réglages de l'installation |
| `mail.worker` | installation | non | aucun (compte de service) | résolution d'adresse, dépôt dans tout compte, maintenance |

Une fiche invisible est « introuvable ». Les fonctions qui touchent aux fichiers (lien d'un
contenu, maintenance) passent par les fonctions publiques de `lyxal_storage` : elles s'exécutent
sous la session système de l'hôte (ou un compte de service qui a aussi `storage.worker`).

### Gardes et compteurs (`events/mail_guards.surql`, `functions/mail_guard.surql`)

Un événement par table appelle `fn::mail_write_refusal` (refus : `THROW` d'un code `MAIL_*`)
puis `fn::mail_counters_apply`, dans la transaction de **chaque** écriture, quelle qu'en soit
l'origine (fonction, écriture directe, cascade) : compteurs des dossiers et du compte, pierres
tombales, lecteurs des contenus, six dossiers créés avec le compte, adresses retirées d'un compte
en suppression. Les champs de compteurs ne s'écrivent pas directement (permission du compte de
service) ; une écriture de message ou de dossier qui ne fait pas avancer le numéro de modification
est refusée ; UID strictement croissants, jamais réutilisés ; identité, compte, contenu et fil
immuables. Les messages d'un compte désactivé ne changent ni ne s'effacent plus (ceux d'un compte
en suppression ne changent plus, la purge les efface), sauf par l'exploitation (session système,
compte de service). Le domaine de `lyxal_auth` est lu par son contrat public
(`fn::auth_organization_domain_get`), jamais dans sa table.

### Fonctions publiques (`functions/`)

| Domaine | Fonctions |
| :--- | :--- |
| Réglages, domaines | `mail_settings_get`, `mail_settings_set`, `mail_domain_create`, `_get`, `_list`, `_update`, `_delete` |
| Comptes, adresses | `mail_account_create` (compte, adresse principale, six dossiers), `_get`, `_list`, `_update`, `_delete` ; `mail_quota_get` ; `mail_address_create`, `_update`, `_delete`, `_list`, `_resolve` |
| Dossiers | `mail_mailbox_create`, `_get`, `_list`, `_update` (renommage, déplacement, sous-dossiers réécrits), `_delete` |
| Messages | `mail_message_create`, `_get`, `_list` (curseur de date ou plage d'UID), `_changes` (depuis un numéro de modification, effacements compris), `_flags_set` (`CONDSTORE`), `_move` (un message déjà dans le dossier cible reste inchangé), `_copy`, `_expunge` ; `mail_thread_get` |
| Contenus, maintenance | `mail_content_begin`, `_attach`, `_open`, `_expire` ; `mail_tombstone_purge` ; `mail_account_purge_step` |

Toutes : `$params: object`, entrées par le moteur de `lyxal_core`, `fn::result_ok` /
`fn::error_result`, écriture principale vérifiée (`MAIL_WRITE_FORBIDDEN`), listes par curseur.
Fonctions internes (`COMMENT` « Interne ») : `fn::mail_can`, `fn::mail_settings_effective`,
`fn::mail_session_account`, `fn::mail_address_normalize`, `fn::mail_modseq_next`,
`fn::mail_thread_assign`, `fn::mail_content_release`, `fn::mail_content_remove`,
`fn::mail_write_refusal`, `fn::mail_counters_apply`, `fn::mail_keywords_rule`,
`fn::mail_messages_rule`, `fn::mail_flags_apply`, `fn::mail_messages_load`.

### Erreurs et événements

39 codes `MAIL_*` en master data (`error/<thème>/`, traduits en français et en anglais ;
`MAIL_CONTENT_UNAVAILABLE` à réessayer). Événements publiés par `fn::event_publish`, sans donnée
personnelle (identifiants et compteurs seulement) : `mail.domain.created`, `mail.domain.deleted`,
`mail.account.created`, `mail.account.deleted` (fin de la purge), `mail.address.created`,
`mail.address.deleted`, `mail.quota.exceeded` (premier refus depuis le dernier passage sous le
quota ou le dernier changement de quota). Aucun événement par message au lot 4 (M16).

### Banc SurrealQL

`tests/*.test.surql` (`scripts/ci/test_lyxal_modules.py`) : `reglages`, `domaines`, `comptes`,
`adresses`, `dossiers`, `messages`, `synchronisation`, `contenus`, `droits`, `organisations` —
chaque fonction appelée ; sessions système, compte de service, administrateur, titulaire, autre
membre, autre organisation ; écritures filtrées (`MAIL_WRITE_FORBIDDEN`) ; écritures directes
refusées par les gardes ; compteurs égaux au contenu réel ; suppression d'une organisation.

## Mesures du lot 4c (`scripts/bench/mailbox/bench_mail_module.py`)

Mesures du 21 novembre 2026, SurrealDB 3.3.4 en mémoire, machine de développement à 4 cœurs,
boîte de 2 000 messages (`--messages 2000 --delivery 100 --repeat 15`), temps vus par le client
sur une connexion gardée ouverte. Les temps sous la session système comprennent environ 19 ms
d'authentification Basic par requête (mesuré sur `RETURN 1`). Seuils de la décision C5 (lot 0).

| Mesure | Session de membre (p50 / p95) | Session système (p50 / p95) | Seuil C5 |
| :--- | :-: | :-: | :-: |
| Remise (`fn::mail_message_create`) | 91 / 104 ms, 10,8 par seconde | 106 / 115 ms ; compte de service 89 / 105 ms | 300 par seconde : **non tenu** |
| Changement de drapeau (`_flags_set`, un message) | 27 / 37 ms | — | 20 ms : **non tenu** |
| Première page de 50 messages (`_list`) | 1 850 / 1 912 ms | 67 / 92 ms | 100 ms : **non tenu** (membre) |
| Plage de 1 000 UID | 2 279 / 2 321 ms | 123 / 158 ms | — |
| Changements du compte (1 000 drapeaux, 200 effacements) | 951 / 1 006 ms | 63 / 66 ms | 100 ms : **non tenu** (membre) |
| Changements d'un dossier | 937 / 941 ms | 67 / 69 ms | 100 ms : **non tenu** (membre) |

**Coût des permissions de table** (risque du §19 du plan) : sous une session de membre,
SurrealDB 3.3.4 évalue la permission de `mail_message` sur **chaque ligne de la plage d'index**
lue, avant `LIMIT` (plan `EXPLAIN` : index et limite poussés ; temps identique pour 51 et 1 000
lignes rendues, proportionnel à la taille du dossier : environ 0,4 ms par message à 400
messages, 0,9 ms à 2 000, `fn::mail_can` lisant le compte puis `fn::auth_has_permission`). Une
page d'une boîte de 100 000 messages prendrait donc plusieurs dizaines de secondes. Repli prévu
par le plan, à décider par le CTO : contrôle une fois par fonction, puis lecture sous la session
système du service de l'hôte.

**Coût de la validation par `lyxal_core`** : la validation des paramètres de
`fn::mail_message_create` (enveloppe typée comprise) coûte environ 85 ms ; l'écriture, ses gardes
et ses compteurs environ 6 ms (écriture directe mesurée sous la session système, hors
authentification). Une liste de 3 champs coûte déjà environ 14 ms. La remise plafonne donc vers 11
messages par seconde et par connexion, quelle que soit la session.

**Contention du compteur de modifications du compte (décision M6)** : quatre clients qui
remettent en même temps dans un même compte (25 messages chacun) : 109 conflits de transaction
rejoués et 31 remises encore refusées après trois rejeux, 8,8 remises par seconde au total (dans
un même dossier) ; 115 conflits, 32 refus, 9,1 par seconde dans quatre dossiers différents. Le
compteur unique du compte sérialise les écritures du compte, comme prévu ; le rejeu borné du
service Rust (lot 4d) ne suffit pas sous cette charge. Repli décrit au §19 du plan : compteur
par dossier et journal des changements du compte.

Cohérence vérifiée en fin de banc : compteurs du compte égaux aux messages, UID uniques dans le
dossier. Non mesuré au lot 4c : coût d'un scellement de clé de fichier par message (Rust, lot 4d).

## État actuel : `lyxal_mail::net`

| Élément | Rôle |
| :--- | :--- |
| `Session`, `ConnectionInfo`, `SessionLimits`, `TlsState`, `TlsInfo` | Ce que l'hôte remet à un protocole pour chaque connexion acceptée : flux, adresses (après PROXY), état TLS, délais, jeton d'arrêt du nœud, mémoire réservée |
| `SessionHandler`, `SessionEnd` | Ce qu'un protocole implémente (lots 5 à 10) |
| `TlsUpgrade`, `Session::start_tls` | Mise à niveau STARTTLS offerte par l'hôte (seul détenteur de `tokio-rustls`) ; refus de toute entrée lue avant la mise à niveau (`NetError::PipelinedBeforeTls` : injection de commandes en clair) ; implémentée par l'hôte (`HostTlsUpgrade` de `apps/lyxal-groupware`) |
| `MailProtocol`, `TlsMode`, `NetError` | Protocole et mode TLS d'une écoute ; erreurs du transport (internes : jamais renvoyées à un client ni écrites en base) |
| `ConnectionLimiter`, `InFlight` | Plafond de connexions simultanées d'une écoute ; place rendue à la libération (porté de Stalwart) |
| `IpRateLimiter`, `WindowLimit` | Limites par réseau à fenêtres fixes, trois niveaux (IPv4 `/32`, `/26`, `/21` ; IPv6 `/64`, `/48`, `/32`) ; fenêtre sans fin pour les connexions ouvertes ; nombre de réseaux suivis borné (transposé de Mox) |
| `MemoryBudget`, `MemoryReservation`, `MemoryClass` | Budget mémoire du processus en deux classes (réception SMTP, lecture), plancher d'un quart par classe, réservations par pas de 64 Kio rendues à la libération, portée annulable ; la somme réservée ne dépasse jamais le budget (porté de Stalwart) |
| `refusal_line`, `RefusalReason`, `UnavailableHandler` | Ligne de refus poli par protocole (`421` SMTP, `* BYE` IMAP, `-ERR` POP3, `BYE` ManageSieve), sans donnée du client ; handler « service indisponible » des protocoles pas encore écrits (retiré au lot 10) |

Dépendances au lot 3 : `tokio`, `tokio-util`, `async-trait`, `thiserror` ; aucun crate Lyxal,
aucune crate cryptographique.

Vérification : `cargo test -p lyxal_mail` (limiteur par réseau avec les cas d'essai de Mox
transposés, plafond rendu même sur annulation, budget mémoire dont une propriété `proptest`,
lignes de refus, mise à niveau STARTTLS refusée sur entrée déjà lue). L'usage réel (sockets,
runtime) est essayé par `cargo test -p lyxal-groupware`.

Le programme courrier, agendas et contacts (architecture, 23 lots, décisions F1 à F5 et P1 à P15
du CTO) est décrit par `implementation_plan.md` à la racine du dépôt. Chaque lot a son plan
détaillé, placé dans le crate qu'il modifie et supprimé une fois le lot fusionné.

## Objet

Module du Noyau Technique (SurrealQL et Rust) : un **serveur de courrier complet** pour les
identités et les organisations de Lyxal OS (décision F1).

| Partie | Contenu |
| :--- | :--- |
| Données et règles (SurrealQL) | Domaines, adresses, alias, listes, boîtes, messages (métadonnées, drapeaux, UID, numéros de modification, fils), quotas, file d'envoi et ses états, règles d'acceptation d'un destinataire, scripts Sieve, verdicts, journal des changements ; droits par organisation ; erreurs `MAIL_*` |
| Protocoles (Rust) | Sessions SMTP (réception, dépôt authentifié), envoi vers les serveurs destinataires, IMAP, POP3, ManageSieve, JMAP courrier |
| Authenticité et transport | SPF, DKIM, DMARC, ARC ; MTA-STS, DANE, TLS-RPT ; rapports DMARC reçus et émis — toute primitive cryptographique par `lyxal_crypto` |
| Filtrage | Filtres Sieve, anti-spam intégré (règles, listes DNS, classement bayésien, réputation, quarantaine), antivirus par `lyxal_storage` |
| Recherche | Texte des pièces jointes, index plein texte |
| Administration | Domaines, clés DKIM et rotation, contrôle des enregistrements DNS, file, quarantaine, certificats automatiques, configuration automatique des logiciels |

Les octets des messages (`.eml`) et des pièces jointes sont dans `lyxal_storage` : les tables
gardent une référence et des métadonnées. Les syntaxes des protocoles sont dans
[`lyxal_mail_proto`](../lyxal_mail_proto/README.md). Les ports sont écoutés par l'hôte dédié
`apps/lyxal-groupware` (décision P3), pas par `lyxal-server`.

## Licence

Le crate déclare `license = "AGPL-3.0-only"` dans son propre `Cargo.toml` (décision P2), et
non la licence `MIT OR Apache-2.0` du workspace : une grande partie de son code est portée de
Stalwart (`AGPL-3.0-only OR LicenseRef-SEL`, option AGPL retenue). Les parties reprises de Mox
(MIT) et d'autres projets permissifs gardent leurs mentions (`LICENSES/` : texte de l'AGPL-3.0
et avis MIT de Mox). Aucun paquet du workspace sous licence permissive ne dépend de ce crate
(contrôle `scripts/ci/check_agpl_isolation.py`). Les fichiers et extraits de
Stalwart sous `LicenseRef-SEL` seule (licence Entreprise, propriétaire) ne sont jamais utilisés
(décision F5) : les fonctions correspondantes, dont les organisations multiples et leurs quotas,
sont écrites pour Lyxal sur `lyxal_auth` et `lyxal_storage`. Chaque élément porté est inscrit
dans [`SOURCES.md`](SOURCES.md). Les conséquences de licence sont traitées par le CTO
(décision F2).

## Lots du programme qui le construisent

| Lot | Apport à ce crate |
| :- | :--- |
| 0 — Cadre | Ce dossier, les sources figées, le tri du code propriétaire, les mesures de SurrealDB |
| 3 — Hôte et socle réseau (réalisé) | Squelette du module (`lyxal_mail::net`) ; écoutes supervisées, TLS implicite, STARTTLS, certificats rechargés à chaud et PROXY protocol dans `apps/lyxal-groupware` |
| 4 — Socle courrier (en cours) | Modèle de données SurrealQL : domaines, adresses, alias, boîtes, messages, quotas, droits, erreurs, événements (4c, réalisé) ; service Rust de dépôt et de lecture, chiffrement au repos (niveau A) branché, maintenance (4d) |
| 5 — Réception SMTP | Serveur SMTP entrant, SPF / DKIM / DMARC, antivirus, remise en boîte |
| 6 — Envoi | File par destination, envoi vers les MX, dépôt authentifié, signature DKIM, avis de non-remise |
| 7 — Transport sûr et rapports | MTA-STS, DANE, TLS-RPT, rapports DMARC, ARC |
| 8 — IMAP | Serveur IMAP4rev2 et rev1, extensions |
| 9 — Recherche et POP3 | Texte des pièces jointes, index plein texte, POP3 |
| 10 — Sieve | Filtres à la réception, ManageSieve, réponse d'absence |
| 11 — Anti-spam | Règles, listes DNS, classement bayésien, réputation, quarantaine |
| 12 — JMAP courrier | Cœur JMAP, courrier, dépôt, push, blobs, quotas |
| 13 — Administration du courrier | Routes HTTP, certificats automatiques, configuration automatique |
| 21, 22 — Durcissement, essais réels, clôture | Fuzzing, charge, conformité, essais sur domaine et appareils réels, audit |

Les lots 1 (mots de passe d'application, dans `lyxal_auth` : réalisé) et 2 (extensions de
`lyxal_crypto`) sont des prérequis.

## Dépendances prévues

| Vers | Usage |
| :--- | :--- |
| `lyxal_mail_proto` | Syntaxes des protocoles, interprète Sieve, lecture MIME |
| `lyxal_core`, `lyxal_error`, `lyxal_surreal` | Entrées validées par le Core (§5.7.8), erreurs `MAIL_*`, wrappers `store.call_fn` |
| `lyxal_crypto` | TLS côté serveur, DKIM, ARC, DANE, ACME, chiffrement au repos — extensions validées lot par lot (décision P6) ; aucune crate crypto dans ce module |
| `lyxal_auth` | Identités, organisations, permissions `mail.*`, mots de passe d'application (décision P8) |
| `lyxal_storage` | Octets des messages et des pièces jointes, quotas, antivirus |
| `lyxal_secrets` | Clés DKIM privées, clé du compte ACME, clés privées TLS, secrets des adresses signées |
| `lyxal_scheduler` | Purges, rapports, renouvellement des certificats, apprentissage anti-spam |
| `lyxal_event`, `lyxal_runtime` | Événements `mail.*`, module, workers supervisés, sondes de santé |
| Externes (accord de principe P7) | `mail-parser`, `mail-builder`, `mail-send`, `mail-auth` (derrière `lyxal_crypto`), `rustls` côté serveur, `hickory-resolver` avec DNSSEC |

`lyxal_mail` ne dépend ni de `lyxal_notification`, ni de `lyxal_calendar`, ni de
`lyxal_contacts`. `lyxal_notification` consomme ses événements `mail.*` sans lien Cargo ;
`lyxal_calendar` dépose ses invitations par son contrat public de dépôt.

## Documents

* [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) — études des sources (courrier, Proton) et mesures de SurrealDB.
* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, rapport du tri du code propriétaire, éléments portés.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, chiffrement des boîtes, webmail et alias, essais réels à faire.
