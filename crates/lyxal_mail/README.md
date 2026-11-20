# `lyxal_mail` — serveur de courrier (squelette)

**État : squelette (lot 3 du programme courrier).** Le crate est membre du workspace et ne
contient que du Rust : le contrat réseau des sessions (`lyxal_mail::net`), les limites appliquées
à l'acceptation et les lignes de refus poli. Aucune table, aucune fonction SurrealQL, aucun code
d'erreur `MAIL_*` : ils arrivent au lot 4 (écart E3 du plan du lot 3). Le module est installé et
démarré par l'hôte `apps/lyxal-groupware`, qui le porte par un `ManifestModule` et lui rattache
ses écoutes (workers `lyxal_mail:mail.listener.<id>`). Inscrit au Noyau Technique dans
`.agents/AGENTS.md` §6 et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md).

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0).

## État actuel : `lyxal_mail::net`

| Élément | Rôle |
| :--- | :--- |
| `Session`, `ConnectionInfo`, `SessionLimits`, `TlsState`, `TlsInfo` | Ce que l'hôte remet à un protocole pour chaque connexion acceptée : flux, adresses (après PROXY), état TLS, délais, jeton d'arrêt du nœud, mémoire réservée |
| `SessionHandler`, `SessionEnd` | Ce qu'un protocole implémente (lots 5 à 10) |
| `TlsUpgrade`, `Session::start_tls` | Mise à niveau STARTTLS offerte par l'hôte (seul détenteur de `tokio-rustls`) ; refus de toute entrée lue avant la mise à niveau (`NetError::PipelinedBeforeTls` : injection de commandes en clair) ; implémentation par l'hôte au lot 3c |
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
| 3 — Hôte et socle réseau | Squelette du module (fait : `lyxal_mail::net`) ; écoutes supervisées dans `apps/lyxal-groupware` ; TLS implicite, STARTTLS et PROXY à venir (3c) |
| 4 — Socle courrier | Domaines, adresses, alias, boîtes, messages, quotas, droits, erreurs, événements ; chiffrement au repos (niveau A) |
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
