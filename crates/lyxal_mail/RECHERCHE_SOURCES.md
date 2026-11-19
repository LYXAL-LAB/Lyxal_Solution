# `lyxal_mail` — recherche de sources

Études de sources du programme courrier, agendas et contacts, pour la partie courrier, et
mesures de SurrealDB faites au lot 0. Le programme (architecture, lots, décisions F1 à F5 et P1
à P15 du CTO) est décrit par `implementation_plan.md` à la racine du dépôt ; l'objet du crate
par son [`README.md`](README.md), la provenance du code porté par [`SOURCES.md`](SOURCES.md), les
évolutions par sa [`ROADMAP.md`](ROADMAP.md). L'étude des agendas et des contacts est dans
[`crates/lyxal_calendar/RECHERCHE_SOURCES.md`](../lyxal_calendar/RECHERCHE_SOURCES.md).

Ce document a trois parties :

1. **Serveurs de courrier** : sources, licences, normes, besoins cryptographiques (étude du
   18 novembre 2026) ;
2. **Proton** : ce que Proton publie, son modèle de sécurité, les niveaux de chiffrement des
   boîtes (étude du 18 novembre 2026, décision P15) ;
3. **Mesures SurrealDB** : banc d'une boîte de 100 000 puis 1 000 000 de messages (lot 0,
   décision C5), conclusion sur la décision P4.

Les deux études ont été écrites **avant** les décisions du CTO. Leur contenu est conservé
(sources, licences, adresses, points non vérifiés). Les passages qui recommandaient un périmètre
réduit ou de ne pas reprendre de code AGPL ont été retirés et remplacés par une « Note du
lot 0 » qui renvoie à la décision prise : le CTO a décidé une suite complète, portée de projets
open source quelle que soit leur licence, la licence AGPL étant déclarée crate par crate, et il
a gardé le chiffrement complet des boîtes (niveau C) dans le programme. Les numéros de
paragraphe (« §3 », « §10 »…) renvoient à la partie où ils sont écrits.

---

## Partie 1 — Serveurs de courrier : sources et licences

Étude en lecture seule, faite le 18 novembre 2026, avant les décisions du CTO. Licences lues
dans les fichiers `LICENSE` / `LICENSES/` des dépôts clonés (`git clone --depth 1`) et dans les
métadonnées de crates.io ; versions lues sur crates.io et sur les étiquettes Git. Ce qui n'a pas
pu être lu à la source est listé au §10. **Je ne suis pas juriste** : le §3 résume les textes de
licence, il ne remplace pas un avis juridique.

---

### 1. Résumé pour le CTO

1. **Stalwart est le serveur de courrier libre le plus complet écrit en Rust.** Il est sous
   licence AGPL-3.0 (plus une licence payante, `LicenseRef-SEL`, pour certaines fonctions). Les
   crates existants de Lyxal sont sous MIT ou Apache-2.0 : un crate qui copie ou lie du code
   AGPL doit lui-même être diffusé sous AGPL (§3.2).
2. **Stalwart publie à part de petites bibliothèques libres (Apache-2.0 ou MIT) que nous
   pouvons utiliser** : lecture des messages (`mail-parser`), écriture (`mail-builder`), envoi
   (`mail-send`), contrôle d'authenticité SPF/DKIM/DMARC (`mail-auth`), langage SMTP
   (`smtp-proto`). Ce sont des briques, pas un serveur : le serveur reste à écrire.
3. **Attention** : deux de ces bibliothèques ont été reprises dans le dépôt AGPL et leurs dépôts
   libres sont archivés (`sieve-rs`, `calcard`). `smtp-proto` suit peut-être le même chemin.
4. **Aucun serveur SMTP Rust sous licence compatible n'est à la fois complet et entretenu.**
   Les meilleurs modèles de comportement sous licence permissive sont **Mox** (Go, MIT),
   **Postal** (Ruby, MIT, déjà notre modèle) et **KumoMTA** (Rust, Apache-2.0, envoi seulement).
5. **« Serveur de courrier complet » recouvre quatre chantiers très différents** :
   (a) recevoir du courrier ; (b) en envoyer nous-mêmes sans relais ; (c) offrir de vraies boîtes
   aux lettres (IMAP/JMAP) ; (d) une suite complète comme Stalwart. L'effort va de quelques mois
   (a) à plusieurs années d'une équipe (d).
6. **Le vrai risque n'est pas le code, c'est l'exploitation** : un port SMTP ouvert sur Internet
   est attaqué en permanence ; envoyer du courrier sans relais demande une adresse IP réputée,
   et beaucoup d'hébergeurs bloquent le port 25.
7. **Suite donnée** : l'étude recommandait de se limiter à la réception. Le CTO a décidé une
   suite complète, portée de projets open source quelle que soit leur licence (décisions F1 et
   F2 du programme) : voir le §7.
8. **Raccourci possible avant tout serveur** : Brevo, Mailgun, Postmark et Resend (déjà branchés
   dans `lyxal_notification`) savent transmettre le courrier reçu par webhook. Cela débloque
   « courrier entrant » et « réponse à un e-mail » sans ouvrir de port SMTP.
9. **Décisions crypto à prendre** (§6) : la vérification DKIM demande des vérifications de
   signature RSA et Ed25519 absentes de `lyxal_crypto` (Ed25519 est aujourd'hui « hors scope »).

---

### 2. Tableau des sources

Légende « Reprise » : **Code** = dépendance ou copie permise par une licence permissive ;
**Modèle** = lecture pour la conception ; **Rien** = non retenu par l'étude. Cette colonne date
d'avant les décisions du CTO : pour Stalwart et ses crates internes, elle a été mise à jour
d'après les décisions F2, F5 et P5 ; la carte des sources qui fait foi est celle du programme
(`implementation_plan.md` à la racine, §3.2).

#### 2.1. Stalwart : serveur et bibliothèques

| Projet | Rôle | Langage | Licence vérifiée | Version / date | Reprise |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Stalwart** (serveur, `stalwartlabs/stalwart`) | Serveur tout-en-un : SMTP, IMAP4rev2, JMAP, POP3, ManageSieve, CalDAV, CardDAV, WebDAV, anti-spam, ACME | Rust | **AGPL-3.0-only OU SELv2 (propriétaire)** ; certains fichiers **SELv2 seule** | 1.1.1, 16 nov. 2026 (1.0.0 le 26 oct. 2026) | **Source principale du programme** (décisions F2, P5), sans ses parties sous SELv2 (F5) |
| `mail-parser` | Lecture RFC 5322 + MIME, 41 jeux de caractères, sans dépendance crypto | Rust | **Apache-2.0 OR MIT** | 1.0.1, 2 nov. 2026 ; dépôt actif (commit 15 nov. 2026) | **Code** |
| `mail-builder` | Écriture de messages MIME | Rust | **Apache-2.0 OR MIT** | 2.0.1, 2 nov. 2026 | **Code** |
| `mail-send` | Client SMTP (STARTTLS, AUTH, signature DKIM) | Rust | **Apache-2.0 OR MIT** | 0.7.0, 1er nov. 2026 | **Code** (alternative à `lettre`) |
| `mail-auth` | DKIM (v1 et brouillon v2), SPF, DMARC, ARC, rapports ; résolution DNS | Rust | **Apache-2.0 OR MIT** | 0.15.1, 30 oct. 2026 (0.16.0 en préparation) | **Code**, mais c'est de la crypto : à loger derrière `lyxal_crypto` (§6) |
| `smtp-proto` (dépôt séparé) | Analyse des commandes et réponses SMTP/LMTP, toutes extensions | Rust | **Apache-2.0 OR MIT** | 0.2.5, 1er oct. 2026 ; dépôt non archivé | **Code**, version figée à surveiller (voir note) |
| `smtp-proto` (copie dans le serveur, `crates/smtp-proto`) | idem, version du serveur | Rust | **AGPL-3.0-only OR SELv2** | 1.1.1 | **Source du programme** (P5 : version du serveur) |
| `sieve-rs` | Interprète de filtres Sieve | Rust | **AGPL-3.0-only** (crates.io et dépôt) | 0.7.3, août 2026 ; **dépôt archivé** | Le programme porte la copie du serveur (`crates/sieve`, P5) |
| `calcard` (crates.io) | iCalendar, vCard, JSCalendar, JSContact | Rust | **Apache-2.0 OR MIT** | 0.3.14, sept. 2026 ; **dépôt archivé**, suite sous AGPL dans le serveur | **Code** pour la 0.3.14 seulement, sans suite |
| `jmap-client` | Client JMAP (pas un serveur) | Rust | **Apache-2.0 OR MIT** | 0.4.3, 28 sept. 2026 | **Code** (utile pour piloter un Stalwart voisin) |
| `imap_proto`, `jmap-proto`, `dav-proto`, `store`, `smtp`, `imap`, `jmap`, `email`, `spam-filter`… (crates internes du serveur) | Protocoles serveur, stockage, files | Rust | **AGPL-3.0-only OR SELv2** ; non publiés sur crates.io | 1.1.1 | **Sources du programme** (P5 ; `store` : modèle seulement, décision P4) |

Notes vérifiées dans le clone du serveur (commit `3adead9`, 16 nov. 2026) :

* Le serveur dépend de `mail-parser` 1.0, `mail-builder` 2.0 et `mail-auth` 0.15.1 **depuis
  crates.io** : ces trois-là restent des bibliothèques vivantes. En revanche il utilise
  `smtp-proto`, `sieve-rs` et `calcard` **par chemin local** (`path = "../…"`), sous AGPL. Le
  `smtp-proto` libre (0.2.5) n'est donc plus celui du serveur. Il est petit (analyse de texte,
  dépendance unique `memchr`) : s'il est abandonné, nous pouvons en garder une copie sous
  Apache-2.0/MIT.
* Le crate crates.io nommé `imap-proto` (0.17.0, MIT OR Apache-2.0) **n'est pas de Stalwart** :
  c'est un analyseur de réponses IMAP côté client (dépôt `djc/imap-proto`).
* En-têtes SPDX par fichier : la plupart en `AGPL-3.0-only OR LicenseRef-SEL`. Une partie du
  code est sous `LicenseRef-SEL` **seule** (propriétaire) : 66 fichiers entiers (dossiers
  `common/enterprise`, `scim`, `scim-proto`, `spam-filter/analysis/ai`,
  `store/backend/composite`…) et 2 067 extraits marqués dans 151 fichiers à double licence,
  dont 1 447 extraits dans 11 fichiers de `crates/registry`, 166 dans `crates/common`, 98 dans
  `crates/store`. (L'étude d'origine parlait à tort de « 1 447 fichiers » dans `registry` : ce
  sont des extraits, pas des fichiers.) Ces parties ne sont jamais utilisées (décision F5) :
  `scripts/sources/strip_sel.py` les retire de la copie de travail ; rapport par crate dans
  [`SOURCES.md`](SOURCES.md).
* Stockage : RocksDB, FoundationDB, PostgreSQL, MySQL, SQLite ; blobs S3 et Azure ; Redis en
  mémoire (fonctionnalités Cargo de `crates/store`). **Pas de SurrealDB.**
* Administration : « la plupart de la configuration et des données est gérée par JMAP
  (`POST /jmap/`) » ; l'API REST (`api/v1/openapi.yml`) ne couvre que la connexion, le schéma et
  des flux SSE. Webhooks et « MTA hooks » (appel HTTP/JSON à chaque étape SMTP) existent.
* Réservé à l'édition payante selon le README : multi-locataires, SCIM, stockage réparti,
  télémétrie en direct ; le journal 1.0.0 y ajoute l'anti-spam par IA. Les adresses masquées
  sont passées en libre en 1.1.1.
* Depuis la 1.0.0, les tests sont dans un dépôt privé et les nouvelles fonctions sont
  développées en privé avant publication ; seuls les correctifs de contributeurs « parrainés »
  sont acceptés. Rythme : une version par semaine.
* Schéma de base incompatible entre 0.16 et 1.0 (outil de migration obligatoire) : le projet
  bouge vite.

#### 2.2. Autres briques Rust

| Projet | Rôle | Licence vérifiée | Version / date | Reprise |
| :--- | :--- | :--- | :--- | :--- |
| `lettre` | Client SMTP (déjà notre dépendance) ; pas de serveur | MIT | 0.11.24, 17 nov. 2026 | **Code** (en place) |
| `mailin` / `mailin-embedded` | Machine d'états de serveur SMTP en réception / petit serveur embarquable | MIT OR Apache-2.0 | 0.6.5 / 0.8.3, **août 2024** (plus de version depuis) | **Code** possible, mais peu actif ; plutôt **Modèle** |
| `samotop` | Serveur SMTP asynchrone | MIT OR Apache-2.0 | 0.13.2, **janv. 2022** | **Rien** (abandonné) |
| `rust-smtp-server` | Serveur SMTP minimal | MIT | 0.1.1, avr. 2023, sans dépôt déclaré | **Rien** |
| `smtp-server` (Kannader) | Serveur SMTP | MIT OR Apache-2.0 | 0.1.0, oct. 2022 | **Rien** (abandonné) |
| `smtpd` | Serveur SMTP | MIT OR Apache-2.0 | 0.1.0, oct. 2025, 605 téléchargements | **Rien** (trop jeune) |
| **KumoMTA** (`KumoCorp/kumomta`) | MTA d'**envoi** à haut débit : files, spool, limitation par destination, DKIM, MTA-STS, classement des rejets | Apache-2.0 (dépôt) ; `kumo-dkim` sous MIT (origine Cloudflare) | version `2026.09.29` ; commit du 11 nov. 2026 | **Modèle et code** pour (b) ; ses crates (`rfc5321`, `mailparsing`, `spool`, `mta-sts`, `bounce-classify`) ne sont pas publiés sur crates.io et `kumo-dkim` dépend d'OpenSSL |
| `cfdkim` (Cloudflare) | DKIM | MIT | 0.3.0, sept. 2023 | **Modèle** (peu actif) |
| `mailparse` | Lecture MIME | 0BSD | 0.18.0, oct. 2026 | **Code** (alternative à `mail-parser`) |
| `imap-codec` / `imap-types` | Analyse et écriture IMAP4rev1, côtés client **et serveur** | MIT OR Apache-2.0 | 1.0.0 (2023) ; 2.0 en alpha (nov. 2026) | **Code** pour (c) |
| `hickory-resolver` | Résolution DNS (MX, TXT, TLSA, DNSSEC) ; déjà dans `lyxal_auth` | MIT OR Apache-2.0 | 0.26.3, sept. 2026 | **Code** (en place) |
| `rustls` / `tokio-rustls` | TLS (déjà dans le dépôt) | Apache-2.0 OR ISC OR MIT / MIT OR Apache-2.0 | 0.23.46 / 0.26.6 | **Code** (en place) |
| `instant-acme`, `rustls-acme` | Certificats automatiques (ACME) | Apache-2.0 / Apache-2.0 OR MIT | 0.8.5 / 0.15.4 | **Code**, sous réserve crypto (§6) |
| `mailcrab` | Serveur de test (capture) | Apache-2.0 OR MIT (dépôt : Apache-2.0) | 1.10.0, sept. 2026 | Outil d'essai |
| vSMTP | Serveur SMTP | GPL-3.0-only | 2.2.1, mars 2023 | **Rien** |
| `viaspf`, `indymilter`, `spf-milter`, `dkimdo` | SPF, milter | GPL-3.0-or-later | — | **Rien** |
| `melib` | Bibliothèque client de courrier | EUPL-1.2 OR GPL-3.0-or-later | 0.9.0 | **Rien** |

#### 2.3. Serveurs et outils hors Rust

| Projet | Rôle | Langage | Licence vérifiée | Version / date | Reprise |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mox** | Serveur complet et simple : SMTP, IMAP, webmail, SPF/DKIM/DMARC, DANE, MTA-STS, ACME, réputation, API et webhooks | Go | **MIT** | v0.0.17, 19 août 2026 | **Modèle principal** de comportement (code très annoté par RFC) |
| **Postal** | Plate-forme d'envoi et de réception pour applications : routes entrantes, file, rejets, suppression | Ruby | **MIT** | 3.4.0 | **Modèle** de données (déjà retenu par `lyxal_notification`) |
| Haraka | Serveur SMTP à greffons | Node | MIT | v3.4.0 | **Modèle** (découpage en étapes / greffons) |
| aiosmtpd | Serveur SMTP bibliothèque | Python | Apache-2.0 | v1.4.6 | **Modèle** (interface de gestionnaire) |
| chasquid | Serveur SMTP simple | Go | Apache-2.0 | v1.19.0 | **Modèle** |
| go-smtp | Bibliothèque SMTP serveur/client | Go | MIT | v0.26.0 | **Modèle** |
| `smtp-server` (Nodemailer) | Bibliothèque serveur SMTP | Node | MIT (texte de type MIT) | v3.21.6 | **Modèle** |
| Apache James | Serveur SMTP/IMAP/JMAP | Java | Apache-2.0 | 3.9.1 | **Modèle** |
| maddy | Serveur tout-en-un | Go | **GPL-3.0** | v0.9.7 | **Rien** (idées seulement) |
| WildDuck / ZoneMTA | IMAP sur MongoDB / MTA d'envoi | Node | **EUPL-1.2** | v1.55.3 / — | **Rien** (idées seulement) |
| Hyvor Relay | Relais d'envoi | PHP/Go | **AGPL-3.0** | 0.0.48 | **Rien** |
| Mailu | Assemblage Postfix + Dovecot + Rspamd en conteneurs | Python | MIT (l'assemblage) | 2024.06 | Modèle d'exploitation ; composants sous leurs licences |
| mailcow | idem | PHP | **GPL-3.0** | 2026-11 | **Rien** |
| docker-mailserver | idem | Shell | MIT (l'assemblage) | v17.0.0 | Modèle d'exploitation |
| Inbucket | Serveur de test | Go | MIT | v3.2.0 | Outil d'essai |
| MailHog | Serveur de test | Go | MIT | v1.0.1 (ancien) | Écarté (plus entretenu) |
| **Mailpit** | Serveur de test (capture SMTP, interface web, API) | Go | MIT | v1.34.0 | **Outil d'essai recommandé** |
| smtp4dev | Serveur de test | C# | BSD-3-Clause (texte lu) | v3.16.0 | Outil d'essai |
| **Rspamd** | Anti-spam (service séparé, protocole HTTP) | C/Lua | Apache-2.0 | 4.3.0 | **Service séparé** appelé par HTTP |
| SpamAssassin | Anti-spam | Perl | Apache-2.0 | 4.0.2 | Service séparé (alternative) |
| OpenDKIM | Signature et vérification DKIM (milter) | C | BSD (texte lu) | 2.10.3 (ancien) | **Rien** (inutile en Rust) |
| ClamAV | Antivirus (déjà appelé par `lyxal_storage` via `clamd`) | C | **GPL-2.0** (`COPYING.txt`) | — | **Service séparé** (déjà le cas) |

---

### 3. Analyse de licence (en langage simple)

> Avertissement : ce qui suit résume des textes de licence. Pour un engagement commercial,
> faire confirmer par un juriste.

#### 3.1. Ce que l'on peut lier ou copier dans Lyxal (MIT OR Apache-2.0)

* **MIT, BSD, 0BSD, ISC, Apache-2.0** : utilisables comme dépendances ou copiés, à condition de
  conserver l'avis de droit d'auteur et le texte de licence (et, pour Apache-2.0, le fichier
  `NOTICE` s'il existe et la mention des fichiers modifiés). C'est le cas de `mail-parser`,
  `mail-builder`, `mail-send`, `mail-auth`, `smtp-proto` 0.2.5, `imap-codec`, `lettre`,
  `hickory-resolver`, `rustls`, du code de Mox, Postal, Haraka, KumoMTA.
* Traduire du code MIT/Apache d'un autre langage (Go de Mox → Rust) est permis avec mention
  d'origine ; en pratique on transcrit le **fonctionnement**, pas le code.

#### 3.2. Sources sous AGPL, GPL, EUPL ou licence propriétaire

* **AGPL-3.0 / GPL-3.0** (serveur Stalwart, `sieve-rs`, maddy, mailcow, vSMTP, `viaspf`) : toute
  œuvre « fondée sur » ce code doit être diffusée sous la même licence. Copier un fichier, le
  traduire ligne à ligne ou lier le crate dans un binaire fait de ce binaire une œuvre dérivée.
* **SELv2** (fichiers propriétaires de Stalwart) : aucun droit sans abonnement ; interdiction de
  redistribuer (art. 2.3).
* **Une idée, un protocole, un schéma de fonctionnement décrit dans une documentation publique
  ne sont pas du code** : on peut reconcevoir.

> **Note du lot 0.** L'étude concluait que ces sources ne pouvaient qu'inspirer. Le CTO en a
> décidé autrement (décisions F2, F4, F5 et P2 du programme) : les sources AGPL et GPL sont
> portées ; chaque crate qui en dérive déclare `AGPL-3.0-only` et tient un `SOURCES.md` ; aucun
> crate existant ne reçoit de code AGPL ou GPL ; les parties sous SELv2 ne sont jamais utilisées.
> Le CTO traite lui-même les conséquences de licence.

#### 3.3. Texte de l'AGPL, et voie étudiée d'un Stalwart voisin (non retenue)

Textes lus (fichier `LICENSES/AGPL-3.0-only.txt` du dépôt Stalwart) :

* Article 2 : « This License explicitly affirms your unlimited permission to run the unmodified
  Program. »
* Article 13 : « if you modify the Program, your modified version must prominently offer all
  users interacting with it remotely through a computer network […] an opportunity to receive
  the Corresponding Source of your version ». L'obligation réseau vise la **version modifiée**.
* Article 5, dernier alinéa : un regroupement d'œuvres « separate and independent […] not
  combined with it such as to form a larger program » est un « aggregate » ; la licence ne
  s'étend pas aux autres parties.

Lecture générale (non juridique) de la voie « faire tourner Stalwart à côté, sans le
modifier », que l'étude proposait pour de vraies boîtes aux lettres et que le CTO n'a pas
retenue (décision F1 : le serveur est écrit dans Lyxal) :

* Faire tourner le binaire officiel de Stalwart, **non modifié**, comme service distinct, et lui
  parler par ses protocoles réseau (SMTP, JMAP, webhooks, MTA hooks) ne place pas Lyxal sous
  AGPL : ce sont deux programmes séparés. La FAQ GPL de la FSF donne les tubes, sockets et
  arguments de ligne de commande comme moyens de communication entre programmes séparés, tout en
  précisant qu'un échange de structures internes complexes peut faire basculer vers un programme
  unique, et qu'il n'y a pas de frontière nette (FAQ non relue à la source, §10).
* Si nous **modifions** Stalwart, la version modifiée doit être proposée en source à ses
  utilisateurs réseau.
* Si nous **distribuons** Stalwart avec Lyxal (image, installeur), il faut fournir sa licence et
  son code source correspondant ; plus simple : le laisser installer par l'exploitant depuis la
  source officielle.
* Les fonctions de l'édition payante (dont le **multi-locataires**, central pour Lyxal)
  demandent un abonnement par boîte aux lettres. Tarif non vérifié à la source (§10).
* Point d'attention : un greffon chargé **dans** le processus de Stalwart serait une œuvre
  dérivée. Les « MTA hooks » (HTTP/JSON) et webhooks sont des appels réseau, donc du bon côté.

Conséquences techniques de cette voie :

* Deux systèmes à exploiter : Stalwart a sa propre base (RocksDB, PostgreSQL…), ses comptes, ses
  sauvegardes. Les données de courrier ne sont **pas** dans SurrealDB ; les règles de
  `LYXAL_ARCHITECTURE` (données dans SurrealDB, métier en SurrealQL) ne s'y appliquent pas.
* Comptes : synchronisation `lyxal_auth` → Stalwart par OIDC (annoncé dans le README de Stalwart)
  ou par l'API JMAP d'administration ; SCIM est payant.
* Intégration : `jmap-client` (Apache-2.0 OR MIT) pour lire et envoyer ; webhooks de Stalwart
  vers une route de l'hôte, convertis en événements `lyxal_event`.
* Dépendance à un éditeur qui change vite (schéma cassé entre 0.16 et 1.0, version hebdomadaire).

---

### 4. Options de périmètre

#### 4.0. Option préalable : réception par les fournisseurs (sans serveur)

Brevo, Mailgun, Postmark et Resend transmettent le courrier reçu par webhook (sources
secondaires, §9). `lyxal_notification` a déjà les routes de retour signées pour ces quatre
fournisseurs. Normes à notre charge : aucune (le fournisseur tient le MX). Crypto : celle des
webhooks, déjà en place (HMAC). Limites : dépendance au fournisseur, formats différents par
fournisseur (Resend n'envoie que des métadonnées, le contenu est à relire par API), pas
d'installation autonome.

#### 4.1. Tableau comparatif

Les efforts sont des **ordres de grandeur** de l'étude pour une personne expérimentée, tests
et documentation compris, hors exploitation ; ils ne viennent d'aucune source. Le programme
retient l'option (d) (décision F1) et a ses propres tailles par lot (§5 du plan).

| Option | Contenu | Normes principales | Briques reprises | À écrire par nous | Effort | Risque |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Courrier reçu par webhook du fournisseur | — | routes de retour existantes | 4 adaptateurs, modèle du message reçu, événement | 2 à 4 semaines | Faible |
| **(a)** | Réception SMTP : MX → contrôle → lecture → stockage → événement | RFC 5321, 5322, 2045-2049, 3207 (STARTTLS), 1870 (SIZE), 2920 (PIPELINING), 6152 (8BITMIME), 6531 (SMTPUTF8), 3463/2034 (codes d'état), 7208 (SPF), 6376/8301/8463 (DKIM), 7489 (DMARC), 8601 (Authentication-Results), 3464 (lecture des avis de non-remise), 5965 (plaintes ARF) | `smtp-proto`, `mail-parser`, `tokio-rustls`, `hickory-resolver`, `mail-auth` ; Rspamd et ClamAV en services ; `lyxal_storage` | Session SMTP (machine d'états, limites, délais), domaines et routes entrantes, quarantaine, rattachement des réponses et des rejets, schéma SurrealQL, tests avec Mailpit et un vrai MX | **2 à 4 mois** | **Moyen** : port 25 exposé, spam |
| **(b)** | (a) + envoi direct : file, nouvelles tentatives, signature DKIM, traitement des rejets | + RFC 5321 côté client (MX, repli), 3461 (DSN), 8461 (MTA-STS), 8460 (TLS-RPT), 7672/6698 (DANE), 8058/2369 (désabonnement), 6409/4954/8314 si dépôt authentifié | `mail-send` ou `lettre`, `mail-auth` (signature), `mail-builder` ; KumoMTA et Postal en modèle ; `lyxal_scheduler` | File par domaine de destination, limitation par destinataire, classement des réponses, montée en charge des IP, génération d'avis de non-remise, rotation des clés DKIM, contrôle DNS des domaines d'envoi | **+4 à 6 mois**, puis suivi permanent de la délivrabilité | **Élevé** : réputation, listes noires, port 25 sortant |
| **(c)** | (b) + boîtes aux lettres pour des personnes : IMAP et/ou JMAP, dépôt authentifié, filtres | + RFC 9051/3501 (IMAP) et extensions (IDLE, CONDSTORE, QRESYNC…), 8620/8621 (JMAP), 5228 (Sieve), 6409, 4954 | `imap-codec` (syntaxe seulement), `mail-parser` ; **aucun** serveur IMAP ou JMAP sous licence permissive en Rust ; pas d'interprète Sieve permissif (`sieve-rs` est AGPL) | Serveur IMAP complet (UID, drapeaux, recherche, synchronisation), stockage des boîtes dans SurrealDB, quotas, recherche plein texte, compatibilité Outlook / Apple Mail / Thunderbird, webmail | **+12 à 24 mois** | **Très élevé** : compatibilité des logiciels de courrier, perte de courrier inacceptable |
| **(d)** | Suite complète type Stalwart : + POP3, ManageSieve, CalDAV, CardDAV, WebDAV, anti-spam intégré, chiffrement, grappe | + RFC 1939, 5804, 4791, 6352, 4918, 6638… | `calcard` 0.3.14 (figé) | Tout le reste | **Plusieurs années d'une équipe** (Stalwart : équipe à plein temps, droits d'auteur depuis 2020) | **Très élevé** ; périmètre retenu par le CTO (F1) |

#### 4.2. Réalités communes

**Sécurité d'un port SMTP ouvert sur Internet (a, b, c, d)**

* Trafic hostile permanent : spam, essais de relais ouvert, recherche d'adresses, connexions
  lentes pour épuiser la mémoire. Même Stalwart, audité, a publié des avis de déni de service
  par mémoire (CVE-2025-61600, CVE-2026-26312) et un signalement de saturation par connexions
  SMTP non authentifiées traité comme un réglage.
* À écrire dès (a) : plafonds de taille, de destinataires, de connexions par IP, délais,
  budget mémoire, refus de tout relais vers un domaine non hébergé, analyse stricte des fins de
  ligne (attaques dites « SMTP smuggling », non revérifiées ici), fuzzing de l'analyseur.
* `smtp-proto` et `mail-parser` ont des cibles de fuzzing dans leurs dépôts (dossier `fuzz/`).

**Anti-spam et anti-abus**

* L'étude proposait de ne pas écrire de filtre et d'appeler **Rspamd** (Apache-2.0) comme
  service HTTP. Décision P13 : l'anti-spam est intégré (lot 11), porté de Stalwart sans sa
  partie IA propriétaire ; Rspamd n'est pas utilisé. Sans filtre : SPF/DKIM/DMARC, listes DNS,
  limitation, liste verte.
* Pour (a) limité aux réponses et aux adresses techniques, le risque est borné : on n'accepte
  que des destinataires connus (adresse de réponse signée, routes déclarées), on refuse le reste
  dès `RCPT TO`.

**Délivrabilité (b, c, d)**

* Google et Yahoo exigent depuis février 2024 : SPF ou DKIM pour tous, SPF **et** DKIM **et**
  DMARC aligné pour les gros expéditeurs (environ 5 000 messages par jour), DNS inverse valide,
  TLS, taux de plaintes sous 0,3 %, désabonnement en un clic (RFC 8058). Microsoft applique des
  règles proches depuis mai 2025 (sources secondaires, §10).
* Une adresse IP neuve n'a aucune réputation : montée en charge sur des semaines, surveillance
  des listes noires, boucles de retour de plaintes. C'est un métier d'exploitation, pas du code.
* **Port 25 sortant bloqué par défaut** chez AWS, Google Cloud, Azure, DigitalOcean ; variable
  chez Hetzner et OVH (sources secondaires contradictoires, §10). Le port 25 **entrant** est en
  général ouvert : (a) est faisable presque partout, (b) non.

**Charge d'exploitation**

* (a) : un enregistrement MX par domaine de réception, un certificat TLS, la surveillance de la
  quarantaine. (b) : SPF, DKIM, DMARC, DNS inverse par IP, rotation de clés, suivi de
  réputation. (c) : sauvegarde et restauration de boîtes, support des logiciels clients.

---

### 5. Détail par option : ce qui existe, ce qui manque

#### (a) Réception

| Étape | Brique | Reste à faire |
| :--- | :--- | :--- |
| Écoute TCP, STARTTLS | `tokio`, `tokio-rustls` | Worker `LyxalWorker` supervisé, certificat fourni par l'exploitant |
| Dialogue SMTP | `smtp-proto` (analyse) ; `mailin` en modèle | Machine d'états, limites, réponses, journal |
| Destinataire accepté ? | — | `fn::mail_recipient_resolve` (SurrealQL) : domaine hébergé, route, adresse de réponse signée (HMAC existant) |
| SPF, DKIM, DMARC | `mail-auth` | Emballage dans `lyxal_crypto` (§6), en-tête `Authentication-Results` |
| Antivirus, anti-spam | ClamAV via `lyxal_storage` ; anti-spam intégré (P13, lot 11) | Décision (accepter, quarantaine, refuser) |
| Lecture du message | `mail-parser` | Extraction : en-têtes, corps texte/HTML, pièces jointes, `In-Reply-To`, `References` |
| Stockage | `lyxal_storage` (message brut `.eml` et pièces jointes) | Fiche `mail_message` en SurrealDB (métadonnées, pas les octets) |
| Diffusion | `lyxal_event` | Événements `mail.message.received`, `mail.bounce.received`, `mail.complaint.received` |

#### (b) Envoi direct

Modèle : Postal (`queued_messages`, déjà repris par `lyxal_notification`), KumoMTA (files par
domaine, limitation, classement des rejets), Mox (DANE, MTA-STS, rapports).
Manques sans équivalent en bibliothèque : ordonnancement par destination, politique de
tentatives par code de réponse, génération des avis de non-remise, réchauffement d'IP.

#### (c) Boîtes aux lettres

Aucune bibliothèque permissive ne fournit un serveur IMAP ou JMAP. `imap-codec` ne traite que la
syntaxe. Le stockage (UID stables, MODSEQ, fils de discussion, recherche) serait à concevoir sur
SurrealDB, sans modèle permissif en Rust ; Mox (MIT, Go) et Apache James (Apache-2.0, Java)
serviraient de modèles.

---

### 6. Besoins cryptographiques face à `lyxal_crypto`

État lu : `lyxal_crypto` offre AES-256-GCM, SHA-256, BLAKE3, Argon2id, HMAC-SHA256, HKDF, TOTP,
**signature** ES256 et RS256 (`EcdsaP256SigningKey`, `RsaSigningKey::sign_rs256`, via `ring`),
chiffrement Web Push. **Aucune vérification de signature asymétrique.** Ed25519 est listé
« HORS SCOPE » (règles §11.3).

| Besoin | Option | Dans `lyxal_crypto` aujourd'hui ? | Statut |
| :--- | :--- | :--- | :--- |
| TLS serveur (STARTTLS, RFC 3207) avec `rustls` | a, b, c | `rustls` est déjà dans le dépôt (client, par `lettre` et `reqwest`) | **À confirmer par le CTO** : premier usage de `rustls` côté serveur dans un module ; fournisseur `ring` comme ailleurs |
| **Vérification DKIM** : RSA-SHA256 (clés 1024 à 4096 bits), **Ed25519-SHA256** (RFC 8463), canonicalisation, hachage du corps | a | Non | **Extension crypto — validation CTO.** Ed25519 en vérification est aujourd'hui hors scope |
| Vérification ARC (RFC 8617) | a | Non | Retenue au lot 7 (P6 e) ; le README de `mail-auth` la dit en voie de classement « historique » |
| SPF, DMARC | a | Pas de crypto (lecture DNS et règles) | Aucune extension ; DNS par `hickory-resolver` |
| DKIM v2 (brouillon IETF), signatures post-quantiques ML-DSA | — | Non | **Hors périmètre** (norme non publiée, post-quantique hors scope) |
| **Signature DKIM** RSA-SHA256 | b | **Oui en pratique** : `sign_rs256` est le même algorithme (RSASSA-PKCS1-v1_5 + SHA-256) | Extension **mineure** : exposer l'usage DKIM (en-tête, canonicalisation) ; à valider |
| Génération de clés RSA pour DKIM | b | Non (`ring` ne génère pas de clés RSA) | **Extension crypto** ou clé fournie par l'exploitant et rangée dans `lyxal_secrets` |
| Signature DKIM Ed25519 | b | Non | **Extension crypto** (hors scope actuel) ; facultative, RSA suffit |
| Adresses de retour et de réponse signées (VERP, jeton de réponse) | 0, a, b | Oui (`HmacKey`, HMAC-SHA256) | Aucune extension |
| MTA-STS (RFC 8461) : lecture d'une politique en HTTPS | b | Pas de primitive nouvelle (`reqwest` + `rustls`) | Aucune extension crypto |
| **DANE** (RFC 7672, 6698) : DNSSEC validé + contrôle du certificat contre l'enregistrement TLSA | b | SHA-256 oui ; vérificateur de certificat `rustls` sur mesure non | **Extension crypto** ; lot 7 (P6 f) |
| **ACME** (RFC 8555) : certificats automatiques | a, b | Clé de compte ES256 oui ; demande de certificat (CSR) non | **Extension crypto** ; lot 13 (P6 g) |
| AUTH SMTP / IMAP : PLAIN, LOGIN sur TLS | b (dépôt), c | Oui (Argon2id par `lyxal_auth`) | Aucune extension |
| AUTH SCRAM-SHA-256, OAUTHBEARER | c | Non (assemblage HMAC/PBKDF2) | **Extension crypto** ; SCRAM si retenu au lot 8 (P6 h) |
| S/MIME, OpenPGP | d | Non | Chiffrement des boîtes : partie 2 de ce document et décision C7 (niveau B, OpenPGP, en lot optionnel) |

**Point de conception à trancher (K-mail-1).** `mail-auth` fait lui-même la crypto DKIM, avec
au choix `aws-lc-rs` (bibliothèque C, par défaut) ou `rust-crypto` (`rsa`, `ed25519-dalek`,
`sha1`, `sha2`, `ml-dsa`). Aucun des deux n'est `ring`. Trois voies :

1. Dépendre de `mail-auth` **depuis `lyxal_crypto` seulement** (nouveau module
   `lyxal_crypto::mailauth`), `lyxal_mail` n'important aucune crate crypto. Le moins de code,
   mais de nouvelles crates crypto entrent dans le dépôt. Avec `rust-crypto`, la crate `rsa` 0.9
   porte l'avis RUSTSEC-2023-0071 (« Marvin », canal temporel sur les opérations à clé privée,
   sans version corrigée connue) : sans effet sur la **vérification**, à éviter pour la
   **signature**.
2. Écrire la vérification DKIM dans `lyxal_crypto` sur `ring` (qui vérifie RSA PKCS#1 et
   Ed25519) et ne prendre de `mail-auth` que l'idée ; modèles sous MIT : `kumo-dkim`, `cfdkim`.
   Aucune nouvelle crate crypto, mais du code sensible à écrire et à tester (canonicalisation).
3. Ne pas vérifier DKIM nous-mêmes en V1 : s'appuyer sur Rspamd (qui vérifie SPF/DKIM/DMARC) et
   lire son verdict. Aucune extension, mais Rspamd devient obligatoire. (Voie écartée par la
   décision P13.)

> **Note du lot 0.** Les extensions de `lyxal_crypto` ont reçu un accord de principe, détail
> validé lot par lot : décision P6 du programme (TLS serveur, vérification RSA et Ed25519,
> DKIM, génération de clés au lot 2 ; ARC et DANE au lot 7 ; ACME au lot 13 ; SCRAM au lot 8).

---

### 7. Suite donnée par le CTO

> **Note du lot 0.** L'étude recommandait ici de créer `lyxal_mail` limité à la réception, de
> garder un relais pour l'envoi et de ne pas écrire de boîtes aux lettres. Cette recommandation
> est caduque : le CTO a décidé une suite complète, portée de projets open source quelle que
> soit leur licence, la licence AGPL étant déclarée crate par crate. Les décisions qui font foi
> sont dans `implementation_plan.md` à la racine du dépôt :
>
> * **F1** — cible : serveur de courrier complet (SMTP entrant et sortant, IMAP, JMAP, POP3,
>   Sieve et ManageSieve, anti-spam, DKIM / SPF / DMARC / ARC, MTA-STS / DANE / TLS-RPT,
>   boîtes aux lettres) ;
> * **F2, F4, F5, P2** — méthode et licences : portage de Stalwart, Mox et autres ; licence
>   `AGPL-3.0-only` déclarée par crate ; `SOURCES.md` ; code sous SELv2 jamais utilisé ;
> * **P1, P3** — cinq crates du Noyau Technique et un hôte dédié `apps/lyxal-groupware` ;
> * **P4** — stockage : modèle SurrealQL (voie B), mesuré au lot 0 (section « Mesures
>   SurrealDB » de ce document) ;
> * **P5, P7** — sources principales et dépendances (`mail-parser`, `mail-builder`,
>   `mail-send`, `mail-auth`, `rustls` côté serveur, `hickory-resolver` avec DNSSEC) ;
> * **P6** — extensions de `lyxal_crypto` ; **P13** — anti-spam intégré, sans Rspamd.
>
> La place de `lyxal_mail` dans l'architecture, ses relations avec `lyxal_auth`,
> `lyxal_storage`, `lyxal_secrets`, `lyxal_scheduler`, `lyxal_event` et `lyxal_notification`
> sont décrites au §4 du programme.

---

### 8. Questions posées par l'étude et décisions

| Question de l'étude | Décision |
| :--- | :--- |
| Périmètre : réception seule, ou vraies boîtes aux lettres ? | F1 : suite complète, écrite dans Lyxal |
| Étape préalable : courrier reçu par les webhooks des fournisseurs | Non retenue dans le programme ; le courrier entrant arrive au lot 5 |
| Nom et place | P1 : `lyxal_mail` et `lyxal_mail_proto`, Noyau Technique, après `lyxal_notification` |
| Vérification DKIM, Ed25519, TLS côté serveur, ACME | P6 (lots 2, 7 et 13) |
| Anti-spam : Rspamd ou non | P13 : intégré, sans Rspamd |
| Hébergement du port 25 | P3 : hôte dédié `apps/lyxal-groupware` |
| Suivi de `smtp-proto` | P5 : version du dépôt Stalwart, portée dans `lyxal_mail_proto` |
| Envoi direct sans relais | F1 : oui (lot 6) ; moyens d'exploitation fournis par le CTO (P11) |
| Stalwart en service voisin | Non retenu |

---

### 9. Sources

Dépôts clonés et lus (18 nov. 2026) :

* Stalwart, commit `3adead9` du 16 nov. 2026 : <https://github.com/stalwartlabs/stalwart> —
  `README.md`, `CHANGELOG.md`, `LICENSES/AGPL-3.0-only.txt`, `LICENSES/LicenseRef-SEL.txt`,
  `Cargo.toml`, `crates/*/Cargo.toml`, en-têtes SPDX, `api/v1/openapi.yml`
* <https://github.com/stalwartlabs/mail-parser> (commit `8e149db`, 15 nov. 2026)
* <https://github.com/stalwartlabs/mail-builder> (`2fc4a94`, 2 nov. 2026)
* <https://github.com/stalwartlabs/mail-send> (`d67abf2`, 1er nov. 2026)
* <https://github.com/stalwartlabs/mail-auth> (`c862df2`, 17 nov. 2026)
* <https://github.com/stalwartlabs/smtp-proto> (`f9c4edf`, 1er oct. 2026)
* <https://github.com/stalwartlabs/sieve> (archivé, `f213a84`)
* <https://github.com/stalwartlabs/calcard> (archivé, `ef896a8`)
* <https://github.com/stalwartlabs/jmap-client> (`f5556ff`, 28 sept. 2026)
* Mox : <https://github.com/mjl-/mox> (`LICENSE.MIT`, `README.md`, étiquette `v0.0.17`)
* KumoMTA : <https://github.com/KumoCorp/kumomta> (commit `81f191d`, 11 nov. 2026 ;
  `crates/dkim/LICENSE`)
* mailcrab : <https://github.com/tweedegolf/mailcrab>

Registre crates.io (API `https://crates.io/api/v1/crates/<nom>`) pour : `mail-parser`,
`mail-builder`, `mail-send`, `mail-auth`, `smtp-proto`, `sieve-rs`, `calcard`, `jmap-client`,
`imap-proto`, `mailin`, `mailin-embedded`, `samotop`, `rust-smtp-server`, `smtp-server`, `smtpd`,
`lettre`, `mailparse`, `imap-codec`, `imap-types`, `hickory-resolver`, `rustls`, `tokio-rustls`,
`rustls-acme`, `instant-acme`, `cfdkim`, `viaspf`, `vsmtp`, `indymilter`, `melib`, `mailcrab`.

Fichiers de licence lus sur `raw.githubusercontent.com` et étiquettes lues par `git ls-remote` :

* <https://github.com/foxcpp/maddy> · <https://github.com/haraka/Haraka> ·
  <https://github.com/aio-libs/aiosmtpd> · <https://github.com/albertito/chasquid> ·
  <https://github.com/postalserver/postal> · <https://github.com/inbucket/inbucket> ·
  <https://github.com/mailhog/MailHog> · <https://github.com/axllent/mailpit> ·
  <https://github.com/rspamd/rspamd> · <https://github.com/apache/spamassassin> ·
  <https://github.com/trusteddomainproject/OpenDKIM> · <https://github.com/Cisco-Talos/clamav> ·
  <https://github.com/mailcow/mailcow-dockerized> · <https://github.com/Mailu/Mailu> ·
  <https://github.com/docker-mailserver/docker-mailserver> ·
  <https://github.com/apache/james-project> · <https://github.com/zone-eu/wildduck> ·
  <https://github.com/zone-eu/zone-mta> · <https://github.com/emersion/go-smtp> ·
  <https://github.com/nodemailer/smtp-server> · <https://github.com/hyvor/relay> ·
  <https://github.com/rnwood/smtp4dev>

Pages et recherches web :

* API et crochets de Stalwart : <https://stalw.art/docs/mta/filter/mtahooks/>,
  <https://stalw.art/docs/ref/object/web-hook/>, <https://stalw.art/docs/ref/> (vus par
  recherche, non ouverts directement)
* Tests privés de Stalwart : <https://stalw.art/blog/protecting-stalwart/> ; adresses masquées :
  <https://stalw.art/blog/masked-email-open-source/>
* Avis de sécurité Stalwart :
  <https://github.com/stalwartlabs/stalwart/security/advisories/GHSA-jm95-876q-c9gw>,
  <https://github.com/stalwartlabs/stalwart/security/advisories/GHSA-8jqj-qj5p-v5rr>,
  <https://support.stalw.art/t/unauthenticated-oom-denial-of-service-via-incoming-smtp-connections/1665>
* Avis `rsa` : <https://rustsec.org/advisories/RUSTSEC-2023-0071>,
  <https://osv.dev/vulnerability/RUSTSEC-2023-0071>
* AGPL, lecture secondaire : <https://choosealicense.com/licenses/agpl-3.0/>,
  <https://www.ifross.org/en/when-does-independently-developed-software-have-be-licensed-under-gpl>,
  FAQ FSF : <https://www.gnu.org/licenses/gpl-faq.html#MereAggregation>
* Port 25 chez les hébergeurs (sources secondaires) :
  <https://mailtester.com/blog/why-cloud-providers-block-outbound-port-25/>,
  <https://cli.nylas.com/guides/smtp-ports-blocked-on-cloud-servers>,
  <https://mailflowauthority.com/self-hosted-smtp/vps-blocked-port-25>
* Exigences des grands destinataires (sources secondaires) :
  <https://powerdmarc.com/bulk-email-sender-requirements/>,
  <https://www.courier.com/blog/email-sender-requirements>
* Courrier reçu par webhook : <https://developers.brevo.com/docs/inbound-parse-webhooks.md>,
  <https://mailtrap.io/blog/best-inbound-email-api/>

Fichiers du dépôt Lyxal lus : `.agents/AGENTS.md`, `.agents/rules/lyxal_standards_and_checklist.md`,
`crates/lyxal_notification/{README.md,ROADMAP.md,MODELE_SOURCES.md,Cargo.toml}`,
`crates/lyxal_scheduler/MODELE_SOURCES.md`, `crates/lyxal_crypto/{Cargo.toml,src/signing.rs}`,
`crates/lyxal_storage/README.md`, `crates/lyxal_connect/RECHERCHE_SOURCES.md`,
`docs/14-roadmap/ROADMAP_NOYAU.md`.

---

### 10. Ce qui n'a pas pu être vérifié

Le réseau de la session n'atteint pas `stalw.art`, `www.gnu.org`, `docs.aws.amazon.com`,
`learn.microsoft.com`, `support.google.com`, `docs.cloud.google.com`, `code.alienscience.org`.

* **Documentation et tarifs de Stalwart** : page de comparaison des éditions et prix non
  ouverts. La liste des fonctions payantes vient du `README.md` et du `CHANGELOG.md` du dépôt ;
  les prix cités par des tiers (environ 2 à 2,40 par boîte et par an, minimum 25 boîtes) se
  contredisent et ne sont pas retenus.
* **FAQ GPL/AGPL de la FSF** : non relue à la source ; le résumé du §3.3 s'appuie sur le texte
  de l'AGPL (lu en entier dans le dépôt Stalwart) et sur des citations de seconde main.
* **Blocage du port 25** et **exigences Google / Yahoo / Microsoft** : sources secondaires
  seulement ; elles se contredisent sur Hetzner, OVH et sur le désabonnement chez Microsoft.
* **`mailin`** : dépôt source inaccessible ; licence, version et date viennent de crates.io
  seulement ; état d'entretien réel non constaté.
* **Dates de version** de Postal, Haraka, maddy, chasquid, Rspamd, Mailpit, Mailu, mailcow,
  docker-mailserver, James, Inbucket : seules les étiquettes Git ont été lues (pas les dates) ;
  le tri des étiquettes peut être imparfait (Mailu, ClamAV, SpamAssassin : version non établie).
* **Licences de Postfix, Dovecot, Exim, OpenSMTPD, Cyrus** (composants de Mailu, mailcow,
  docker-mailserver) : non lues ; ces assemblages ne sont de toute façon pas embarquables.
* **Numéros de RFC** : cités de mémoire ou d'après le README de Stalwart ; `datatracker.ietf.org`
  non consulté. L'état exact de DMARC (révision en cours à l'IETF) et d'ARC n'a pas été vérifié.
* **« SMTP smuggling »** (attaques de 2023 sur les fins de ligne) : cité de mémoire.
* **Avis RUSTSEC-2023-0071** : absence de version corrigée d'après des bases secondaires ; page
  RustSec non ouverte.
* **CVE-2026-81036** (OAuth de Stalwart jusqu'à 0.16.19) : vu en base secondaire, correctif non
  confirmé ; non retenu dans l'analyse.
* **`smtp-proto` séparé** : non archivé à ce jour, mais son avenir (le serveur utilise sa propre
  copie AGPL) n'est annoncé nulle part.
* **Aucun essai** : rien n'a été compilé ni exécuté ; la compatibilité de `mail-auth` avec le
  fournisseur `ring` du dépôt et la facilité d'emploi de `smtp-proto` (non documenté, selon son
  README) restent à prouver par un prototype.
* **Efforts du §4** : estimations de l'auteur, sans source.

---

## Partie 2 — Proton comme source d'inspiration (décision P15)

Étude en lecture seule, faite le 18 novembre 2026 pour le lot 0 du programme (décision P15).
Rien n'a été compilé ni exécuté.

**Méthode.** Licences lues dans le fichier `LICENSE` de chaque dépôt (clones Git partiels,
sans extraction des fichiers, hors dépôt) ; commits et dates lus par `git log -1`. Le modèle de
sécurité est tiré, dans cet ordre de confiance : (1) du **code publié** par Proton (constantes
et commentaires lus dans les dépôts) ; (2) des résumés rendus par la recherche web sur les pages
de Proton ; (3) de la mémoire de l'auteur, signalée par « (mémoire) ».
**Limite importante** : le site `proton.me` n'était pas joignable depuis la session d'étude, ni
l'API de GitHub, ni crates.io. Les pages de Proton n'ont donc pas été lues directement. Détail
au §10. **Je ne suis pas juriste** : les remarques de licence sont des lectures de texte, pas un
avis.

---

### 1. Résumé pour le CTO

1. **Proton ne publie pas son serveur**, seulement ses logiciels clients, sa passerelle Bridge
   et ses bibliothèques de chiffrement. Il ne peut pas servir de source pour notre serveur.
2. **Proton ne parle aucun protocole standard côté serveur** : API privée ; pour Outlook ou
   Thunderbird, Bridge déchiffre sur l'ordinateur de l'utilisateur et y sert l'IMAP.
3. **Son idée centrale : le serveur ne peut pas lire le contenu.** La clé privée de chacun est
   verrouillée par son mot de passe, que le serveur ne voit jamais.
4. **Le prix** : recherche dans le texte faite sur l'appareil, filtres aveugles au corps des
   messages stockés, mot de passe perdu sans secours = anciens messages perdus.
5. **Proton ne chiffre pas tout** : heures et répétitions d'un événement, nom et adresse d'un
   contact, objet et destinataires d'un message restent lisibles par son serveur.
6. **Trois niveaux pour nous** (§5). **A** : chiffrer les fichiers stockés avec des clés de la
   plateforme (protège du vol de disque ; rien ne casse). **B** : chiffrer chaque message à
   l'arrivée avec la clé publique de l'utilisateur, comme Stalwart (le serveur ne peut plus le
   relire ; les logiciels standards le déchiffrent ; plus de recherche dans le texte).
   **C** : bout en bout comme Proton (demande nos propres logiciels clients ou une passerelle).
7. **Décision du CTO (C7)** : **A dans le programme** (extension de `lyxal_crypto` au lot 2,
   appliqué dès le lot 4) ; **B en lot optionnel**, courrier seulement, après le lot 12 ;
   **C gardé dans le programme, sans lot fixé à ce jour**. Détail au §7.
8. **Constat** : `lyxal_storage` ne chiffre rien aujourd'hui et `lyxal_crypto` ne scelle que
   1 Mio au plus. Même A demande une extension crypto à valider.
9. **À reprendre** : des idées (hiérarchie de clés, découpage chiffré / signé / clair), la
   liste des fonctions pour le futur webmail, et `rpgp`, la bibliothèque OpenPGP en Rust
   (MIT ou Apache-2.0) que Proton utilise lui-même : le bon candidat pour B.
10. **SimpleLogin** (alias, racheté par Proton) est le seul logiciel **serveur** publié de la
    famille, sous AGPL-3.0 : un modèle pour nos alias.

---

### 2. Tableau des dépôts

Légende « Reprise » : **Code** = reprise permise par la licence dans le crate indiqué ;
**Modèle** = lecture pour la conception ; **Rien** = écarté. Avec F2, les licences GPL et AGPL
ne sont pas un obstacle dans les crates `AGPL-3.0-only` du programme, mais restent interdites
dans les crates existants (`implementation_plan.md` §4.1), donc dans `lyxal_crypto`.

#### 2.1. Logiciels clients

| Dépôt | Rôle | Langage | Licence lue dans `LICENSE` | Dernier commit lu | Reprise |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ProtonMail/WebClients` | Monorepo web : `applications/` mail, calendar, account, drive, pass, wallet, lumo, meet… ; `packages/` dont `calendar`, `mail`, `encrypted-search`, `key-transparency`, `sieve`, `shared` | TypeScript (React) | **GPL-3.0** | `ad6ff86`, 18 nov. 2026 (très actif) | **Modèle** : sécurité (§3) et fonctions du webmail (§6) |
| `ProtonMail/clients` | Nouveau monorepo des clients ; contient le **SDK Rust de Proton Mail** (`project/mail/rust` : `mail`, `calendar`, `contacts`, `crypto`, `shared/{ical, ical-tz, vcard, mailto, canonical-email}`, `mail/mail-html-transformer`, `mail/mail-search`) | Rust | Racine `license/LICENSE` : **GPL-3.0** ; `project/mail/rust/LICENSE` : **AGPL-3.0** ; `Cargo.toml` de `mail-ical` : `AGPL-3.0-only` | `2ecb794`, 24 juin 2026 | **Modèle** ; **Code** possible dans les crates AGPL (analyseur iCalendar, vCard, nettoyage HTML), à instruire seulement si `calcard` ne suffit pas |
| `ProtonMail/rust-mail` | Ancien emplacement du SDK Rust (son `README` renvoie vers `ProtonMail/clients`) | Rust | **AGPL-3.0** ; `Cargo.toml` : `AGPL-3.0-only` | `3b6d35b`, 12 juin 2026 (archivé) | Rien (remplacé) |
| `ProtonMail/android-mail` | Application Proton Mail Android actuelle | Kotlin + SDK Rust | **GPL-3.0** | `c2749ed`, 18 nov. 2026 | Modèle (fonctions) |
| `ProtonMail/ios-mail` | Application Proton Mail iOS actuelle ; son `README` dit qu'elle **ne se compile pas** depuis GitHub | Swift + SDK Rust | **Aucun fichier `LICENSE` à la racine** au commit lu | `701463f`, 8 mai 2026 | Modèle |
| `ProtonMail/proton-mail-android` | Ancienne application Android | Kotlin, Java | GPL-3.0 | `7ff6a12`, 14 mai 2024 | Rien |
| `ProtonMail/android-calendar`, `ProtonMail/ios-calendar` | Applications Proton Calendar | Kotlin ; Swift | GPL-3.0 ; GPL-3.0 | 24 sept. 2025 ; 30 oct. 2025 | Modèle |
| `ProtonMail/protoncore_ios` | Briques communes iOS (compte, connexion) | Swift | GPL-3.0 | 13 oct. 2026 | Rien |
| `ProtonMail/protoncore_android` | Briques communes Android | Kotlin | **Aucun fichier `LICENSE` trouvé** dans l'arbre | 15 janv. 2026 | Rien |
| `ProtonMail/inbox-desktop` | Application de bureau (le code est dans `WebClients/applications/inbox-desktop`) | — | GPL-3.0 | 5 mars 2025 | Rien |
| `ProtonMail/proton-mail-export` | Outil d'export d'une boîte | C++ et Go | GPL-3.0 | 18 sept. 2026 | Rien |
| `ProtonMail/proton-mail`, `proton-shared`, `react-components`, `proton-calendar`, `proton-contacts` | Anciens dépôts web, remplacés par `WebClients` en 2021 | TypeScript | GPL-3.0 pour les trois premiers ; **pas de `LICENSE`** pour `proton-calendar` et `proton-contacts` | 2021 | Rien |
| `ProtonDriveApps/sdk` | SDK de Proton Drive | C#, TypeScript | **MIT** (`LICENSE.md`) | `05c9115`, 5 nov. 2026 | Modèle, plus tard (fichiers WebDAV, hors programme) |

#### 2.2. Passerelle et bibliothèques de protocole

| Dépôt | Rôle | Langage | Licence lue | Dernier commit lu | Reprise |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ProtonMail/proton-bridge` | Bridge : serveurs IMAP et SMTP **locaux**, sur la machine de l'utilisateur, devant l'API Proton | Go (+ Qt) | **GPL-3.0** (« or later » d'après `COPYING_NOTES.md`) | `36d7b6a`, 6 nov. 2026 | Modèle (option C) |
| `ProtonMail/gluon` | Bibliothèque de **serveur IMAP4rev1** ; annonce `IDLE MOVE UIDPLUS UNSELECT` ; base SQLite | Go | **MIT** | `d871584`, 2 nov. 2026 | Modèle : interface « connecteur », instantanés par session, tests. Moins complet que Stalwart ou Mox |
| `ProtonMail/go-proton-api` | Client Go de l'API Proton **et serveur de développement** (dossier `server/`) pour « une partie » de l'API | Go | **MIT** | `79fbe06`, 2 nov. 2026 | Modèle : seule vue publique de la forme de l'API serveur |
| `ProtonMail/go-mime`, `go-rfc5322`, `go-vcard` | Lecture MIME, adresses, vCard | Go | MIT (`go-vcard` : droits d'auteur d'emersion) | 2023, 2022, 2018 | Rien (nous avons `mail-parser`, `calcard`) |
| `ProtonMail/libsieve-php` | Analyseur Sieve (utilisé côté serveur, mémoire) | PHP | **GPL-3.0** | `f428cd1`, 15 oct. 2026 | Rien (nous portons `sieve` de Stalwart) |
| `ProtonMail/sieve.js` | Conversion des filtres simples en Sieve | JavaScript | **Pas de `LICENSE`** | 2023 | Rien |
| `simple-login/app` | **SimpleLogin** : service d'alias, **côté serveur** (§6.3) | Python | `LICENSE` : **AGPL-3.0** (mais `pyproject.toml` déclare `license = "MIT"` : incohérence à trancher par la lecture du `LICENSE`, qui fait foi d'après le badge du `README`) | `4d5d8c1`, 13 nov. 2026 | **Modèle**, ou **Code** dans `lyxal_mail` (AGPL) |
| `simple-login/Simple-Login-Android` | Client Android de SimpleLogin | Kotlin | Apache-2.0 | 30 mai 2026 | Rien |

#### 2.3. Cryptographie

| Dépôt | Rôle | Langage | Licence lue | Dernier commit lu | Reprise |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ProtonMail/proton-crypto-rs` | Crates Rust : `proton-crypto` (OpenPGP et SRP), `proton-crypto-account` (clés de compte, d'adresse, d'organisation, d'appareil, liste de clés signée), `proton-rpgp` (enveloppe de `rpgp`), `gopenpgp-sys`, **`proton-srp`** (SRP en Rust pur, **client et serveur** : `srp/client.rs`, `srp/server.rs`), `proton-crypto-subtle` (AES-GCM, HKDF) | Rust | **MIT** | `3f28b87`, 11 nov. 2026 | **Modèle** en premier ; **Code** possible (MIT) mais le `README` dit « *Not intended or vetted for general usage outside Proton* » et les crates visent un registre privé (`registry = "proton"`) |
| `rpgp/rpgp` (crate `pgp`) | OpenPGP en Rust pur (RFC 9580, clés v4 et v6) ; **utilisé par Proton** (`proton-rpgp` dépend de `pgp` 0.21) et par Delta Chat | Rust | **MIT OR Apache-2.0** (`LICENSE-MIT`, `LICENSE-APACHE`, `Cargo.toml`) | `52750e6`, 16 nov. 2026 ; version 0.21.1 | **Code** : candidat pour l'option B, derrière `lyxal_crypto` (§5.3) |
| `ProtonMail/gopenpgp` | Bibliothèque OpenPGP de haut niveau | Go | MIT | `dcc4859`, 30 sept. 2026 | Modèle |
| `ProtonMail/go-crypto` | Fork de `golang.org/x/crypto/openpgp` | Go | BSD (texte « The Go Authors ») | 25 sept. 2026 | Rien |
| `openpgpjs/openpgpjs` | OpenPGP en JavaScript, entretenu par Proton | JavaScript | **LGPL-3.0** | `8bc35df`, 24 sept. 2026 | Plus tard : déchiffrement dans le navigateur pour un webmail |
| `ProtonMail/pmcrypto` | Enveloppe d'OpenPGP.js pour les clients web | TypeScript | MIT | 17 juin 2026 | Modèle |
| `ProtonMail/go-srp` | SRP en Go (son fichier `server.go` existe) | Go | MIT (`LICENSE.txt`) | 21 janv. 2025 | Modèle |
| `ProtonMail/pm-srp` | Ancien SRP en JavaScript | JavaScript | MIT | 2021 | Rien |
| `ProtonMail/key-transparency` | Ancienne bibliothèque de transparence des clés (le code actuel est dans `WebClients/packages/key-transparency`) | TypeScript | MIT | 2021 | Modèle |
| `ProtonMail/pm-key-transparency-go-client` | Vérification des preuves de transparence des clés | Go | **Pas de `LICENSE`** | 15 août 2023 | Modèle |
| `ProtonMail/encrypted-search` | Ancienne bibliothèque de recherche chiffrée dans le navigateur | JavaScript | MIT | 2018 | Modèle |
| `ProtonMail/bcrypt` | bcrypt en Go | Go | BSD (texte) | 2021 | Rien |
| `protonpass/proton-pass-common` | Cœur Rust de Proton Pass et Authenticator | Rust | GPL-3.0 | 17 nov. 2026 | Hors sujet |

Dépôts cherchés et **inexistants** sous ces noms (clone refusé) : `ProtonMail/proton-srp`,
`ProtonMail/muon`, `ProtonMail/proton-calendar-android`, `ProtonMail/proton-python-client`,
`ProtonMail/gopenpgp-sys`. `proton-srp` et `gopenpgp-sys` sont des dossiers de
`proton-crypto-rs`. `muon` (client HTTP de Proton) est référencé par une adresse GitLab interne
(`gitlab.protontech.ch`) dans `rust-mail` et figure en `forks/muon` dans `ProtonMail/clients`.

#### 2.4. Ce qui n'est PAS publié

* **Aucun serveur** : ni la réception et l'envoi SMTP, ni le stockage des boîtes, ni l'API, ni
  l'anti-spam, ni le serveur des agendas et des contacts, ni le serveur de transparence des
  clés. Le dossier `server/` de `go-proton-api` est un **faux serveur de tests**, partiel.
* Seule exception dans la famille : **SimpleLogin**, serveur complet d'alias (§6.3).
* Des textes : un livre blanc sur la transparence des clés, des billets techniques, des
  rapports d'audit (Securitum, Cure53, SEC Consult cités par des sources secondaires ; liste
  non lue à la source, §10).

---

### 3. Le modèle de sécurité de Proton

#### 3.1. En langage simple

* **Le mot de passe ne quitte jamais l'appareil.** La connexion prouve au serveur que
  l'utilisateur connaît son mot de passe, sans le lui envoyer (protocole SRP).
* **Chaque utilisateur a un trousseau de clés.** Les clés publiques servent à chiffrer pour
  lui ; les clés privées sont rangées sur le serveur, mais **verrouillées par le mot de passe**.
  Le serveur garde un coffre dont il n'a pas la clé.
* **Un message entre deux utilisateurs de Proton** est chiffré sur l'appareil de l'expéditeur
  et déchiffré sur celui du destinataire.
* **Un message venu de l'extérieur** arrive en clair chez Proton (comme chez tout le monde),
  puis il est aussitôt chiffré avec la clé publique du destinataire. Proton l'a donc vu passer,
  mais ne peut plus le relire. Proton appelle cela « chiffrement à accès zéro ».
* **L'objet, l'expéditeur, les destinataires et les dates ne sont pas chiffrés de bout en
  bout** : le serveur en a besoin pour trier, lister et chercher.
* **Agenda** : le titre, le lieu, la description et les participants sont chiffrés ; **les
  heures et la répétition ne le sont pas** (elles sont signées, pour qu'on ne puisse pas les
  modifier sans que cela se voie).
* **Contacts** : le nom et l'adresse e-mail sont lisibles par le serveur et signés ; le reste
  (téléphone, adresse postale, notes) est chiffré.

#### 3.2. Précisément

**Connexion (SRP).** Lu dans `proton-crypto-rs/proton-srp/src/srp/core.rs` : SRP où le
serveur ne garde qu'un vérificateur `v = g^x` ; `x = H_pw(p, s)` avec **bcrypt** comme `H_pw`
(« parce qu'il a permis de passer à SRP sans rehacher les mots de passe déjà hachés ») ; le
code renvoie à l'analyse de sécurité `eprint.iacr.org/2023/1457`. `pmhash.rs` : condensat de
la forme `$2y$10…` (bcrypt, coût 10) étendu par SHA-512. `pgp_modulus.rs` : le module `N` est
signé en OpenPGP par une clé du serveur (`resources/server_public_key.asc`) et vérifié par le
client. Le billet de Proton parle de **SRP-6a** (résumé de recherche). Module de 2048 bits
(mémoire).

**Deux mots de passe, puis un seul.** À l'origine : un mot de passe de connexion et un « mot
de passe de boîte » qui déverrouillait la clé privée. Depuis l'arrivée de SRP (Proton Mail
3.6.0, d'après le résumé du billet de Proton), le mode à un seul mot de passe est le défaut :
le même mot de passe sert à SRP et, avec un autre sel, à déverrouiller les clés. Le mode à
deux mots de passe reste disponible et qualifié d'ancien (résumé de la page d'aide).

**Hiérarchie de clés** (lu dans `proton-crypto-account/src/keys/` et `salts.rs`) :

```text
mot de passe + sel de clé  ──(bcrypt)──►  secret de clé
   └── clé(s) du compte (« user key », OpenPGP, privée chiffrée par le secret de clé)
          └── jeton aléatoire, chiffré par la clé du compte et signé
                 └── clé(s) d'adresse (une par adresse e-mail ; privée chiffrée par le jeton)
                        ├── courrier : clés de session des messages et des pièces jointes
                        ├── agenda : phrase secrète de l'agenda ─► clé de l'agenda ─► clés de session
                        └── contacts : signature et chiffrement des fiches
clé d'organisation (OpenPGP) : un administrateur y accède par un jeton chiffré et signé
clé d'appareil : reste sur l'appareil (ex. notifications chiffrées)
```

Les anciennes clés d'adresse (« legacy ») étaient chiffrées directement par le secret de clé,
sans jeton. Changer de mot de passe ne rechiffre que les clés privées, pas les données.
Réinitialiser un mot de passe oublié sans moyen de secours (phrase ou fichier de
récupération) rend les anciens messages illisibles (mémoire). La **clé d'organisation** permet
à l'administrateur d'une organisation d'agir sur les comptes de ses membres ; l'étendue exacte
de ce qu'il peut lire n'a pas été vérifiée.

**Algorithmes.** OpenPGP ; clés Curve25519 (X25519 / Ed25519) par défaut pour les comptes
récents, RSA pour les anciens (mémoire). `proton-rpgp` active dans `rpgp` les options `pqc`
(post-quantique), `large-rsa` et le transfert de courrier chiffré
(`draft-wussler-openpgp-forwarding`, qui tire `x25519-dalek`).

**Courrier au repos (« accès zéro »).** Le corps d'un message externe est chiffré avec la clé
publique du destinataire à l'arrivée ; avant cela, le serveur l'a en clair (c'est à ce moment
que se font l'anti-spam et les filtres — mémoire). Les sources secondaires s'accordent : objet
et métadonnées ne sont pas chiffrés de bout en bout.

**Envoi.** Lu dans `WebClients/packages/shared/lib/mail/mailSettings.ts`, les six formes d'un
envoi : `SEND_PM` (vers Proton, bout en bout), `SEND_EO` (« encrypted outside » : message
protégé par mot de passe, lu sur une page web), `SEND_CLEAR`, `SEND_PGP_INLINE`,
`SEND_PGP_MIME`, `SEND_CLEAR_MIME`. Un message protégé par mot de passe expire au plus tard
après 28 jours (résumé de la page d'aide). Pour un correspondant externe qui a une clé
OpenPGP : clé téléversée dans la fiche du contact (« épinglée »), ou trouvée par WKD (mémoire).

**Pièces jointes.** Chaque pièce a sa propre clé de session, chiffrée par la clé publique
(dossier `crypto-inbox/src/attachment/` du SDK Rust ; détail du format : mémoire).

**Recherche.** Le serveur cherche dans les métadonnées. La recherche dans le texte se fait
**sur l'appareil** : le client télécharge et déchiffre les messages, construit un index local
(IndexedDB dans le navigateur) qui n'est jamais envoyé au serveur (résumé du billet
« engineering-message-content-search »). Sur mobile, le SDK Rust contient un moteur
(`mail-search` : « *Self-contained search engine for Proton Mail local search* »).

**Transparence des clés.** But : empêcher le serveur de donner une fausse clé publique.
D'après le livre blanc et les supports cités au §9 : arbre de Merkle creux de profondeur 256,
une feuille par (adresse, révision), position tirée par une fonction VRF, feuille = condensat
de la **liste de clés signée** de l'adresse (type `SignedKeyList` lu dans
`proton-crypto-account`), nouvel arbre par « époque », racine ancrée dans les journaux
*Certificate Transparency* par un certificat TLS. Date de mise en service non trouvée.

**Agenda.** Lu dans `WebClients/packages/shared/lib/calendar/constants.ts` : un événement est
découpé en parties, chacune avec un type (`CLEAR_TEXT`, `SIGNED`, `ENCRYPTED_AND_SIGNED`).

| Partie | Signé, lisible par le serveur | Chiffré et signé |
| :--- | :--- | :--- |
| Partagée (tous les participants) | `uid`, `dtstamp`, `dtstart`, `dtend`, `recurrence-id`, `rrule`, `exdate`, `organizer`, `sequence` | `created`, `description`, `summary`, `location` (+ lien de visioconférence) |
| Propre à l'agenda | `exdate`, `status`, `transp` | `comment` |
| Personnelle | rappels (`VALARM`), rangés dans la partie signée | — |
| Participants | en clair : un jeton par participant (condensat SHA-1 de l'adresse et de l'UID) et son statut de réponse | `attendee` (les adresses) |

Clés (lu dans `calendar/crypto/keys/calendarKeys.ts` et résumé du billet « calendar security
model ») : chaque agenda a une **clé OpenPGP d'agenda**, verrouillée par une **phrase secrète
aléatoire** ; chaque membre reçoit cette phrase chiffrée par sa clé d'adresse et signée.
**Partager un agenda = chiffrer la phrase secrète pour le nouveau membre** ; rien n'est
rechiffré dans les événements. Chaque événement a des clés de session, chiffrées par la clé
de l'agenda. Les invitations vers l'extérieur partent par e-mail ordinaire, en ICS, non
chiffrées (source secondaire).

**Contacts.** Lu dans `WebClients/packages/shared/lib/contacts/constants.ts` : en clair
`version`, `prodid`, `categories` (les groupes) ; **signés et lisibles** `fn` (nom affiché),
`uid`, `email`, et les réglages de chiffrement du correspondant (`key`, `x-pm-encrypt`,
`x-pm-sign`, `x-pm-scheme`…) ; tout le reste est **chiffré et signé**. La page d'aide de
Proton dit que nom et adresse e-mail « ne sont pas protégés par le chiffrement à accès zéro »
(résumé de recherche).

**Drive** (mémoire, non vérifié) : arbre de clés par dossier et par fichier, contenu chiffré
par blocs. Utile seulement le jour où nous ferons les fichiers WebDAV (hors programme).

---

### 4. Conséquences pour un serveur à protocoles standards

Un logiciel standard (Outlook, Apple Mail, Thunderbird, DAVx⁵) attend du serveur des
réponses calculées **par le serveur**, sur des données qu'il lit. Voici ce que devient chaque
fonction si le contenu est chiffré de sorte que le serveur ne puisse pas le lire.

| Fonction du programme | Lot | Si le serveur ne peut pas lire le contenu | Ce que fait Proton |
| :--- | :-: | :--- | :--- |
| Recherche IMAP (`SEARCH BODY`, `TEXT`), recherche JMAP, index plein texte | 9, 12 | Impossible sur le corps ; reste possible sur les en-têtes s'ils sont en clair | Index sur l'appareil ; le serveur ne cherche que les métadonnées |
| Filtres Sieve sur le corps, réponse d'absence | 10 | Possibles **à la réception**, avant chiffrement ; impossibles ensuite. Entre utilisateurs en bout en bout : en-têtes seulement | Filtres sur les métadonnées (mémoire) |
| Anti-spam sur le contenu, apprentissage quand l'utilisateur déplace un message vers « Indésirables » | 11 | Analyse possible à la réception ; **apprentissage après coup impossible** (le message stocké est illisible) | Analyse à l'arrivée (mémoire) |
| Antivirus (`clamd` par `lyxal_storage`) | 5 | À la réception seulement | idem (mémoire) |
| Aperçu, fils de discussion, `ENVELOPE`, `BODYSTRUCTURE` IMAP | 4, 8 | Fils et enveloppe restent possibles si les en-têtes sont en clair ; aperçu et structure du corps perdus | API privée ; aperçu calculé par le client |
| CalDAV `calendar-query` par période, `free-busy-query`, rappels | 16, 17 | Impossibles si dates et répétitions sont chiffrées | **Dates laissées lisibles** (signées) |
| Planification côté serveur (iTIP : boîtes `schedule-inbox` / `-outbox`, invitations, réponses) | 18 | Impossible : le serveur doit lire et réécrire l'événement de chaque participant | Fait par le **client**, qui chiffre pour chaque participant ; e-mail ICS en clair pour l'extérieur |
| CardDAV `addressbook-query`, complétion des adresses | 19 | Impossible sur les champs chiffrés | **Nom et e-mail laissés lisibles** |
| Lecture par un client standard | 8, 16, 19 | IMAP : possible si le format est OpenPGP ou S/MIME standard, que le client sait déchiffrer. CalDAV / CardDAV : **aucun client standard ne sait déchiffrer un événement ou une fiche** | **Bridge** sur la machine de l'utilisateur pour IMAP / SMTP ; rien pour CalDAV / CardDAV |
| Connexion sans envoyer le mot de passe (SRP) | 1 | IMAP, SMTP et HTTP Basic envoient le mot de passe au serveur : SRP ne s'y applique pas. L'équivalent standard est **SCRAM** (déjà en P6 (h)) | SRP dans ses propres clients ; Bridge fabrique un mot de passe local |
| Accès d'un administrateur d'organisation, conservation légale, compte d'un salarié parti | 4.5 | Impossible sans séquestre de clé | Clé d'organisation |

**Comment Proton contourne** : (1) une **API privée** au lieu d'IMAP, CalDAV et CardDAV ;
(2) **Bridge** (GPL-3.0), qui se connecte à l'API, déchiffre sur l'ordinateur et sert IMAP et
SMTP en local grâce à **Gluon** (MIT) ; (3) un **choix assumé de laisser en clair** ce dont le
serveur a besoin (dates des événements, nom et adresse des contacts, en-têtes des messages) ;
(4) la recherche et la planification **faites par le client**.

**Leçon pour nous.** Notre objectif F1 est l'inverse de (1) : un serveur standard complet.
Le chiffrement de bout en bout n'est compatible avec F1 que pour le **corps des messages**,
sous une forme standard (OpenPGP ou S/MIME) que les logiciels de courrier savent déjà lire.
Pour les agendas et les contacts, il n'existe pas de forme standard : c'est A, ou nos propres
clients.

---

### 5. Options pour Lyxal

#### 5.1. État de départ chez nous (lu dans le dépôt)

* `lyxal_secrets` : clé maîtresse → une clé par organisation (32 octets, scellée) → chaque
  valeur scellée (`enc:v2`, AES-256-GCM, contexte lié à l'organisation et à l'enregistrement).
  C'est une hiérarchie **dont la plateforme détient le sommet** : l'inverse de Proton, où le
  sommet est le mot de passe de l'utilisateur.
* `lyxal_crypto` : AES-256-GCM, SHA-256, BLAKE3, Argon2id, HMAC, HKDF, TOTP, signature ES256 et
  RS256, chiffrement Web Push. **Hors scope** : Ed25519, X25519, ChaCha20-Poly1305, KMS.
  `CryptoEngine::seal` refuse plus de `MAX_SECRET_BYTES` = 1 048 576 octets (`secret.rs`).
* `lyxal_storage` : n'utilise `lyxal_crypto` que pour l'empreinte BLAKE3 (`service.rs`) ; son
  `README.md` ne mentionne aucun chiffrement. **Les octets sont stockés en clair.**
* Aucune implémentation OpenPGP, S/MIME ou SRP.

#### 5.2. Tableau des options

| | **A — chiffrement au repos, clés de la plateforme** | **B — « accès zéro » au repos, clé publique de l'utilisateur** | **C — bout en bout, clés chez le client** |
| :--- | :--- | :--- | :--- |
| Principe | Les fichiers (`.eml`, pièces jointes) et, au besoin, certains champs sont chiffrés par une clé d'organisation, elle-même scellée par la clé maîtresse | L'utilisateur dépose une **clé publique** OpenPGP ou un certificat S/MIME ; chaque message est chiffré avec elle à la remise ; la clé privée reste dans son logiciel | Clés créées sur l'appareil, privées verrouillées par le mot de passe ; le serveur ne stocke que du chiffré ; connexion SRP |
| Modèle | Stalwart 1.0.3 (« *blob encryption at rest* », clés symétriques du serveur) ; `lyxal_secrets` | Stalwart `crates/crypto` et son chiffrement à la remise (depuis 2023) | Proton |
| Protège contre | Vol d'un disque, d'une sauvegarde, d'un compartiment S3 ; fuite du stockage seul | En plus : lecture **des messages déjà stockés** après une intrusion, une réquisition ou par un administrateur | En plus : un serveur compromis ou malveillant, pour le contenu |
| Ne protège pas contre | Quiconque a la base **et** la clé maîtresse (administrateur, intrusion complète) | Le serveur voit chaque message **à l'arrivée** et à l'envoi ; en-têtes lisibles (sauf protection des en-têtes, RFC 9788) ; un serveur malveillant peut cesser de chiffrer | Métadonnées ; faux logiciel client servi par le serveur (d'où les audits et la transparence des clés) |
| Ce que l'utilisateur gagne | Rien de visible | « Mon hébergeur ne peut pas relire mes messages » ; marche avec Thunderbird, Apple Mail (S/MIME), K-9, Outlook (S/MIME) | La promesse de Proton |
| Ce qui casse | Rien | Recherche dans le corps, aperçu, apprentissage anti-spam après coup, pour les comptes qui l'activent ; webmail futur : doit déchiffrer dans le navigateur ; **clé perdue = courrier perdu** | Tout le §4 : recherche serveur, Sieve sur le corps, planification serveur, clients CalDAV / CardDAV / IMAP sans passerelle, accès administrateur |
| S'applique à | Courrier, agendas, contacts | **Courrier seulement** | Courrier, agendas, contacts, mais avec nos clients |
| Primitives nécessaires | Chiffrement de fichiers **en flux** (AES-256-GCM par blocs, format à définir) ; le reste existe | OpenPGP **en chiffrement seul** : lecture de clés publiques v4 et v6, RSA, ECDH (Curve25519 / X25519, P-256/384/521), AES en modes CFB, OCB ou GCM, vérification des auto-signatures (RSA, Ed25519, ECDSA), SHA-1 pour les empreintes v4, MIME `multipart/encrypted`. S/MIME : X.509, CMS, RSA-OAEP, AES-CBC / GCM | Tout B avec les opérations privées côté client, plus SRP (bcrypt ou Argon2, grands entiers), OpenPGP dans le navigateur, transparence des clés (VRF, arbre de Merkle) |
| Face à `lyxal_crypto` | **Une extension** (flux) | **Grosse extension** : X25519 et RSA en chiffrement sortent du « hors scope » ; Ed25519 en vérification arrive déjà au lot 2 (P6 b) | Extension majeure, plus du code crypto hors Rust (navigateur, mobiles) |
| Ordre de grandeur | **S à M** (un lot ou une partie de lot) | **L** pour OpenPGP ; **+ M à L** pour S/MIME | **Plusieurs XL** : un second programme (clients web et mobiles, passerelle) |
| Lots touchés | 4 (socle courrier), `lyxal_storage`, `lyxal_crypto` ; 16 et 19 par ricochet | 4 (modèle), 5 (remise), 8 (`APPEND`, `SEARCH`), 9 (recherche), 10 (ordre Sieve → chiffrement), 11 (apprentissage), 12 (JMAP : brouillons, copies envoyées, aperçus), 13 (écran de dépôt de clé) | Tous ; demande nos propres logiciels clients ou une passerelle |

#### 5.3. Option B en détail : ce que fait Stalwart, et le choix de la bibliothèque

**Stalwart** (clone local, commit `3adead9` ; `CHANGELOG.md`) : chiffrement par compte, à
partir de la clé publique déposée ; réglage `encryptOnAppend` par compte ; les brouillons
JMAP ne sont pas chiffrés et la copie « Envoyés » d'un envoi JMAP est stockée en clair
(1.0.1) ; protection des en-têtes RFC 9788 avec masquage de l'objet (1.0.2) ; passerelle de
chiffrement **sortant** vers les clés des correspondants (WKD, serveurs de clés, DNS) et
collecte des clés Autocrypt et des certificats S/MIME reçus (1.0.2). Son crate `crypto`
(9 696 lignes, `AGPL-3.0-only OR LicenseRef-SEL`, aucun extrait propriétaire) est une
implémentation **maison** d'OpenPGP et de CMS au-dessus d'`aws-lc-rs` (bibliothèque C) ; il
expose le chiffrement et la vérification, et je n'y ai trouvé aucune fonction de
déchiffrement (le mot n'apparaît que dans `types.rs` et `x509/recipient.rs`). Un résumé de
recherche affirme au contraire que, depuis la 1.0.2, des clés privées seraient gardées par
le serveur : **non confirmé**, à relire dans la documentation de Stalwart au lot 0.

**Bibliothèque OpenPGP pour Lyxal** :

| Candidat | Licence vérifiée | Maturité | Contre |
| :--- | :--- | :--- | :--- |
| **`rpgp`** (crate `pgp` 0.21.1) | **MIT OR Apache-2.0** | Rust pur ; RFC 9580 ; utilisé par Delta Chat et **par Proton** ; deux revues de sécurité citées (IncludeSec 2019, Radically Open Security 2024, d'où CVE-2024-53856 corrigée en 0.14.1) | « Bibliothèque de bas niveau » qui n'empêche pas les mauvais usages (son `README`) ; entretenue par des bénévoles (`SECURITY.md`) ; tire la crate `rsa` (avis RUSTSEC-2023-0071 déjà signalé en P6, non revérifié) |
| `sequoia-openpgp` 2.4.2 | **LGPL-2.0-or-later** (`openpgp/Cargo.toml`) | Très complète, RFC 9580 | LGPL dans un binaire Rust lié statiquement : question de licence de plus ; moteur crypto par défaut `nettle` (bibliothèque C, LGPL) ; un moteur `crypto-rust` existe |
| Stalwart `crypto` | AGPL-3.0-only | Fait exactement B (OpenPGP **et** S/MIME, post-quantique compris) ; déjà chiffré pour nos sources | Code AGPL : **interdit dans `lyxal_crypto`** par la règle du §4.1 du plan ; crypto maison récente (réécrite en 1.0.2, 2 nov. 2026) sans revue connue ; dépend d'`aws-lc-rs` (C) |
| `proton-rpgp` / `proton-crypto` | MIT | Montre un bon usage de `rpgp` | « Non prévu pour un usage hors de Proton » ; registre privé |

Conflit de règles à trancher (question 5 du §8) : toute crypto doit vivre dans `lyxal_crypto`
(§11.3), mais aucun code AGPL ne doit y entrer (§4.1 du plan). Avec `rpgp`, les deux règles
tiennent. Avec le crate de Stalwart, il faut une exception : de la crypto dans un crate AGPL.

**Points de conception de B** (à réserver dès les lots 4 et 5) : drapeau « chiffré » et
empreinte de la clé sur chaque message ; ordre fixe à la remise : antivirus → anti-spam →
Sieve → extraction pour l'index (si l'utilisateur l'accepte) → chiffrement → stockage ;
politique d'index au choix du compte (indexer avant de chiffrer, ce qui laisse des mots dans
l'index, ou ne pas indexer) ; pas de rétroactivité ; publication de la clé publique par WKD
pour que les correspondants chiffrent eux-mêmes (ce qui donne alors un vrai bout en bout,
sans rien changer au serveur).

#### 5.4. Variante intermédiaire (pour mémoire)

« B avec clés gardées par le serveur » : le serveur garde la clé privée de l'utilisateur,
verrouillée par son mot de passe, et la déverrouille le temps d'une session pour servir IMAP
ou le webmail. C'est le modèle de Proton **sans** ses clients : le serveur voit le mot de
passe et le contenu pendant la session. Le gain sur B est le confort (aucune clé à gérer dans
le logiciel de courrier) ; la perte est la promesse (« le serveur ne peut pas lire »). Les
mots de passe d'application du lot 1 compliquent ce schéma : chacun devrait déverrouiller la
clé. Variante non prévue par la décision C7.

---

### 6. Autres idées à reprendre

#### 6.1. Fonctions des logiciels de Proton (liste pour le futur webmail)

Le webmail est hors programme (§9 du plan). Ce qui suit sert à vérifier que le **serveur**
porte ce qu'il faut. Présence des fonctions chez Proton : sources secondaires et mémoire.

| Fonction | Ce que le serveur doit offrir | Lot |
| :--- | :--- | :-: |
| Vue par conversation | Fils de discussion (déjà prévus) | 4 |
| Dossiers **et** libellés (un message dans un dossier, plusieurs libellés) | Boîtes IMAP + mots-clés IMAP / JMAP `keywords` | 4, 8, 12 |
| Envoi programmé ; annulation de l'envoi (délai de quelques secondes) | Envoi différé : `FUTURERELEASE` (RFC 4865) et `EmailSubmission` JMAP avec date ; file retenue | 6, 12 |
| Mise en attente d'un message (« snooze ») | Mot-clé et date de réveil ; tâche `lyxal_scheduler` | 12 ou après |
| Alias et adresses masquées | Alias, sous-adresses, alias jetables (§6.3) | 4 |
| Assistant d'import (« Easy Switch ») : courrier, agendas, contacts d'un autre fournisseur | Import IMAP, ICS, vCard — **hors périmètre** aujourd'hui (migration, `lyxal_connect`) | — |
| Filtres simples traduits en Sieve, éditeur Sieve | Sieve et ManageSieve (prévus) ; l'idée de `sieve.js` : un filtre simple **est** un script Sieve | 10 |
| Expiration d'un message ; message protégé par mot de passe pour l'extérieur | Suppression planifiée ; page de lecture hors courrier (proche du « partage à usage unique » de `lyxal_secrets`) | après |
| Désabonnement en un clic, vue « lettres d'information » | En-têtes `List-Unsubscribe` exposés (RFC 8058, lot 6) | 6, 12 |
| Blocage des images distantes et des traceurs, nettoyage du HTML | Côté client ; modèle : `mail-html-transformer` (Rust, AGPL) | webmail |
| Agenda : agendas partagés, lien public, disponibilités, invitations avec réponse depuis le courrier, fuseaux, abonnements ICS, anniversaires tirés des contacts | Partage, `free-busy`, iTIP / iMIP (prévus) ; abonnement à un agenda externe : hors périmètre | 17, 18 |
| Contacts : groupes, fusion des doublons, clé de chiffrement et préférences par contact | Groupes vCard (`KIND:group` ou `CATEGORIES`) ; champ `KEY` | 19 |

#### 6.2. Bridge et Gluon

* **Bridge** : un programme sur le poste de l'utilisateur, avec un mot de passe **propre à
  Bridge** pour le logiciel de courrier (mémoire) — même idée que nos mots de passe
  d'application (lot 1). Son lanceur vérifie la signature des fichiers avant de démarrer
  (`README`). Utile seulement si un jour nous faisons C.
* **Gluon** (MIT) : serveur IMAP4rev1 en bibliothèque, séparé du stockage par un
  « connecteur » (dossier `connector/`) ; chaque session travaille sur un instantané de la
  boîte ; une base SQLite par adresse (source secondaire). Son périmètre annoncé
  (`IDLE MOVE UIDPLUS UNSELECT`) est très inférieur à celui de Stalwart et de Mox
  (CONDSTORE, QRESYNC…) : **modèle** pour la frontière protocole / stockage du lot 8 et pour
  ses tests, pas source principale.

#### 6.3. SimpleLogin

Serveur d'alias publié, `LICENSE` AGPL-3.0, Python 3.12. Architecture lue dans
`email_handler.py` et le `README` : **Postfix** reçoit et envoie ; un service Python
(`aiosmtpd`) réécrit les messages ; base **PostgreSQL** ; application web Flask.
Mécanisme : à la réception sur un alias, le message est transmis à la vraie boîte avec un
`Reply-To` spécial (« alias inverse ») ; quand l'utilisateur répond, le service remplace son
adresse par l'alias, de sorte que le correspondant ne voit jamais la vraie adresse.
Chiffrement PGP facultatif des messages transmis (`pgp_utils.py`).

Pour nous : la **fonction** (alias jetables, alias inverses, désactivation d'un alias qui
reçoit du spam) se loge dans `lyxal_mail` au lot 4 (alias) et au lot 6 (réécriture à l'envoi).
Le code Python ne se porte pas tel quel ; le **modèle de données et les règles de réécriture**
sont une bonne source, sous AGPL comme le reste du crate.

#### 6.4. Idées d'architecture

* **Découper un objet en parties chiffrée / signée / claire** selon ce dont le serveur a
  besoin (tableau du §3.2). Notre modèle agenda (« texte reçu conservé tel quel + projections
  indexées », §4.4 du plan) s'y prête : les projections (dates, répétitions) sont exactement
  ce que Proton laisse lisible.
* **Partager en rechiffrant une clé, pas les données** (phrase secrète de l'agenda) : même
  principe que la clé par organisation de `lyxal_secrets`.
* **Liste de clés signée et transparence des clés** : à garder en tête si nous publions un
  jour les clés publiques de nos utilisateurs (WKD).
* **SRP pour la connexion web** (`proton-srp`, MIT, contient le côté serveur) : une idée pour
  `lyxal_auth`, sans rapport avec ce programme. L'équivalent pour IMAP et SMTP est SCRAM.
* **Cœur Rust partagé entre les clients** (SDK Rust de Proton, liaisons UniFFI) : confirme que
  nos crates « Rust pur » (`lyxal_mail_proto`, `lyxal_dav`) pourront servir à de futurs clients.

---

### 7. Décisions du CTO (C7 et C8)

> **Note du lot 0.** L'étude recommandait A dans le programme, B en lot optionnel et « pas
> d'option C dans ce programme ». Le CTO a validé A et B et a **refusé de mettre C hors
> programme**. Décisions qui font foi (`crates/lyxal_mail/implementation_plan.md` pendant le
> lot 0, puis programme à la racine, §5, §7 et §9) :
>
> * **Niveau A — dans le programme.** Contenu des messages et des pièces jointes chiffré au
>   repos avec des clés de la plateforme par organisation (modèle de `lyxal_secrets`), dès le
>   lot 4. Il demande une extension de `lyxal_crypto` (chiffrement de fichiers en flux : la
>   primitive actuelle plafonne à 1 Mio), détaillée et validée avec le lot 2.
> * **Niveau B — lot optionnel après le lot 12.** Chiffrement à la remise par la clé publique
>   OpenPGP de l'utilisateur, avec la bibliothèque `rpgp` (MIT / Apache-2.0). Les lots 4 et 5
>   réservent dès maintenant le drapeau « chiffré » et l'ordre antivirus → anti-spam → filtres
>   → index → chiffrement.
> * **Niveau C — gardé dans le programme, sans lot fixé à ce jour.** Le bout en bout complet de
>   Proton exige nos propres logiciels clients (ou une passerelle) et retire au serveur la
>   recherche, les filtres et l'anti-spam sur le contenu des boîtes qui l'activent. Son plan
>   sera instruit après le niveau B ; d'ici là aucun lot ne ferme cette possibilité : modèle
>   des clés par utilisateur, drapeau « chiffré », contenu des messages jamais supposé lisible
>   par le serveur dans les contrats.
> * **Agendas et contacts : niveau A seulement** (aucun logiciel CalDAV / CardDAV classique ne
>   déchiffre).
> * **C8** — consigné dans [`ROADMAP.md`](ROADMAP.md), sans lot dans ce programme : fonctions des
>   logiciels de Proton à reprendre dans le futur webmail (§6.1) ; alias d'adresses à la
>   SimpleLogin (§6.3), à instruire avec le lot 13.

Ce que l'étude retient par ailleurs de Proton, et qui reste valable :

1. **À prendre** : les idées du §6.4 ; la liste de fonctions du §6.1 pour le webmail ; `rpgp`
   (que Proton utilise) pour le niveau B ; `proton-crypto-rs` comme **exemple d'usage** de
   `rpgp` et de SRP ; SimpleLogin comme modèle des alias ; OpenPGP.js (LGPL-3.0) le jour où un
   webmail devra déchiffrer.
2. **À ne pas prendre** : un serveur (il n'y en a pas) ; Bridge et Gluon comme sources
   principales ; le code GPL-3.0 de `WebClients` dans nos crates (inutile : c'est du
   TypeScript d'interface) ; `proton-crypto-rs` comme dépendance directe (non prévu pour
   l'extérieur, registre privé).
3. Toute reprise suit P2 : une ligne par élément réellement repris dans le `SOURCES.md` du
   crate concerné.

---

### 8. Questions de l'étude : tranchées ou à trancher

Tranchées par C7 : la question 1 (les trois niveaux sont au programme : A, puis B, puis C), la
question 4 (extension de `lyxal_crypto` acceptée dans le principe, détail au lot 2), la
question 5 (`rpgp`), la question 8 (A suffit pour les agendas et les contacts) et la
question 10 (alias : feuille de route, avec le lot 13). Les autres restent à trancher dans le
plan du lot concerné (niveau B, niveau C, webmail).

1. **Contre qui veut-on protéger les boîtes ?** (a) le vol d'un disque ou d'une sauvegarde →
   A suffit ; (b) l'hébergeur ou une intrusion, pour les messages déjà reçus → B ; (c) le
   serveur lui-même → C.
2. **L'administrateur d'une organisation doit-il pouvoir lire ou récupérer la boîte d'un
   membre** (départ d'un salarié, obligation légale de conservation) ? Si oui, B doit rester
   un choix de l'organisation, ou prévoir un séquestre de clé.
3. **Accepte-t-on « clé perdue = courrier perdu »** pour les comptes qui activent B ?
4. **Option A** : extension de `lyxal_crypto` (chiffrement de fichiers en flux) acceptée dans
   le principe ? Ou chiffrement délégué au disque et au service S3 ?
5. **Option B** : `rpgp` (MIT / Apache-2.0) derrière `lyxal_crypto`, ce qui fait entrer RSA en
   chiffrement et X25519 dans le périmètre ; ou le crate `crypto` de Stalwart (AGPL), ce qui
   demande une exception à la règle « toute la crypto dans `lyxal_crypto` » ?
6. **OpenPGP seul, ou OpenPGP et S/MIME ?** (S/MIME est ce que savent faire Outlook et Apple
   Mail sans module.)
7. **Recherche pour les comptes chiffrés** : indexer avant de chiffrer (pratique, mais des
   mots restent lisibles dans l'index) ou ne pas indexer le corps ?
8. **Agendas et contacts** : confirmer que A suffit (aucun client standard ne déchiffre).
9. **Chiffrement sortant** vers les correspondants qui publient une clé (passerelle de
   Stalwart, WKD) : dans le lot B, plus tard, ou jamais ?
10. **Alias à la SimpleLogin** (alias jetables et alias inverses) : dans le lot 4 / 6, ou
    plus tard ?
11. **Le futur webmail doit-il viser l'expérience Proton** (déchiffrement dans le
    navigateur) ? La réponse décide si C mérite un second programme.
12. **SRP ou SCRAM** : SCRAM-SHA-256 pour IMAP et SMTP reste-t-il en P6 (h) ? SRP pour la
    connexion web de `lyxal_auth` est-il un sujet à ouvrir ?

---

### 9. Sources

**Dépôts lus par clone partiel** (licence = fichier `LICENSE` ; commit entre parenthèses) :

* https://github.com/ProtonMail/WebClients (`ad6ff86`) — `LICENSE`, `README.md`,
  `packages/shared/lib/calendar/constants.ts`, `.../calendar/veventHelper.ts`,
  `.../calendar/attendees.ts`, `.../calendar/crypto/keys/calendarKeys.ts`,
  `packages/shared/lib/contacts/constants.ts`, `packages/shared/lib/mail/mailSettings.ts`
* https://github.com/ProtonMail/clients (`2ecb794`) — `license/LICENSE`,
  `project/mail/rust/LICENSE`, `project/mail/rust/crypto/README.md`,
  `project/mail/rust/shared/ical/Cargo.toml`, `project/mail/rust/mail/mail-search/Cargo.toml`
* https://github.com/ProtonMail/rust-mail (`3b6d35b`) — `LICENSE`, `README.md`, `Cargo.toml`
* https://github.com/ProtonMail/proton-crypto-rs (`3f28b87`) — `LICENSE`, `README.md`,
  `Cargo.toml` de chaque crate, `proton-srp/src/srp/core.rs`, `proton-srp/src/pmhash.rs`,
  `proton-crypto-account/src/keys/*.rs`, `proton-crypto-account/src/salts.rs`
* https://github.com/ProtonMail/proton-bridge (`36d7b6a`) — `LICENSE`, `COPYING_NOTES.md`, `README.md`
* https://github.com/ProtonMail/gluon (`d871584`) — `LICENSE`, `README.md`, `go.mod`
* https://github.com/ProtonMail/go-proton-api (`79fbe06`) — `LICENSE`, `README.md`
* https://github.com/ProtonMail/android-mail (`c2749ed`), https://github.com/ProtonMail/ios-mail (`701463f`) — `LICENSE`, `README.md`
* https://github.com/ProtonMail/android-calendar, https://github.com/ProtonMail/ios-calendar,
  https://github.com/ProtonMail/protoncore_ios, https://github.com/ProtonMail/protoncore_android,
  https://github.com/ProtonMail/proton-mail-android, https://github.com/ProtonMail/inbox-desktop,
  https://github.com/ProtonMail/proton-mail-export
* https://github.com/ProtonMail/gopenpgp, https://github.com/ProtonMail/go-crypto,
  https://github.com/ProtonMail/pmcrypto, https://github.com/openpgpjs/openpgpjs,
  https://github.com/ProtonMail/go-srp, https://github.com/ProtonMail/pm-srp,
  https://github.com/ProtonMail/key-transparency,
  https://github.com/ProtonMail/pm-key-transparency-go-client,
  https://github.com/ProtonMail/encrypted-search, https://github.com/ProtonMail/bcrypt,
  https://github.com/ProtonMail/libsieve-php, https://github.com/ProtonMail/sieve.js,
  https://github.com/ProtonMail/go-mime, https://github.com/ProtonMail/go-rfc5322,
  https://github.com/ProtonMail/go-vcard
* https://github.com/ProtonDriveApps/sdk (`05c9115`) — `LICENSE.md`
* https://github.com/protonpass/proton-pass-common — `LICENSE`
* https://github.com/simple-login/app (`4d5d8c1`) — `LICENSE`, `README.md`, `email_handler.py`,
  `app/pgp_utils.py`, `pyproject.toml` ; https://github.com/simple-login/Simple-Login-Android
* https://github.com/rpgp/rpgp (`52750e6`) — `LICENSE-MIT`, `LICENSE-APACHE`, `Cargo.toml`,
  `README.md`, `SECURITY.md`
* https://gitlab.com/sequoia-pgp/sequoia/-/raw/main/openpgp/Cargo.toml (version, licence, moteurs)
* Clone local de Stalwart, commit `3adead9` : `crates/crypto/`, `crates/email/src/message/ingest.rs`,
  `CHANGELOG.md`

**Pages connues par les résumés de la recherche web (non lues directement)** :

* https://proton.me/blog/encrypted-email-authentication (SRP, un ou deux mots de passe)
* https://proton.me/support/switch-two-password-mode
* https://proton.me/blog/protoncalendar-security-model ;
  https://news.ycombinator.com/item?id=21914424 (citations du billet)
* https://proton.me/blog/keep-everyone-in-the-loop-with-shared-calendars
* https://proton.me/support/proton-contacts
* https://proton.me/blog/engineering-message-content-search ;
  https://proton.me/support/search-message-content
* https://proton.me/support/password-protected-emails
* https://proton.me/files/proton_keytransparency_whitepaper.pdf ;
  https://ethz.ch/content/dam/ethz/special-interest/infk/inst-infsec/appliedcrypto/education/theses/_Master_Thesis_Thore_Goebel_Proton_Key_Transparency.pdf ;
  https://transparency.dev/pdfs/summit2024/Key%20Transparency%20Proton.pdf
* https://proton.me/blog/gluon-imap-library ; https://proton.me/blog/new-proton-mail-bridge ;
  https://deepwiki.com/ProtonMail/proton-bridge/3.1-imap-service
* https://proton.me/blog/pass-open-source-security-audit ;
  https://en.wikipedia.org/wiki/Proton_Drive ; https://en.wikipedia.org/wiki/Proton_Mail ;
  https://en.wikipedia.org/wiki/Proton_AG (audits, rachat de SimpleLogin en 2022)
* https://www.techradar.com/reviews/protonmail-secure-email (courrier externe chiffré à l'arrivée)
* https://silentsuite.io/blog/encrypted-calendar-sync-2026-comparing-options ;
  https://silentsuite.io/blog/encrypted-contact-sync-2026-comparing-options
* https://query.rs/posts/2026-02-04/1qvl7mo/proton-ag-has-open-sourced-their-rust-proton-mail-sdk-powering-mobile-clients
* https://stalw.art/blog/encryption-openpgp-smime/ ; https://stalw.art/docs/faq/ ;
  https://stalw.art/blog/encryption-gateway-post-quantum/ ; https://stalw.art/docs/encryption/at-rest
* https://advisories.gitlab.com/cargo/pgp/CVE-2024-53856/ ;
  https://delta.chat/assets/blog/2019-first-security-review.pdf
* https://eprint.iacr.org/2023/1457 (cité dans le code de `proton-srp` ; non lu)

**Dépôt Lyxal** : `implementation_plan.md`, `.agents/rules/lyxal_standards_and_checklist.md`
§11.3, `crates/lyxal_secrets/README.md`, `crates/lyxal_storage/README.md`,
`crates/lyxal_storage/src/service.rs`, `crates/lyxal_crypto/src/{secret.rs,cipher.rs}`.

---

### 10. Ce qui n'a pas pu être vérifié

* **Aucune page de `proton.me` n'a été lue directement** (hôte non autorisé dans cette
  session). Les points marqués « résumé » viennent des résumés de la recherche web ; les
  points marqués « (mémoire) » ne reposent sur aucune lecture : SRP-6a et module de 2048 bits,
  algorithmes par défaut des clés, moment exact de l'anti-spam et des filtres chez Proton,
  filtres limités aux métadonnées, WKD et clés épinglées, format des pièces jointes, mot de
  passe propre à Bridge, absence de CalDAV / CardDAV chez Proton, perte des anciens messages
  après réinitialisation, modèle de Drive. À relire sur le site de Proton si un de ces points
  devient décisif.
* **API de GitHub et crates.io non joignables** : pas d'étoiles, pas d'état « archivé » lu à
  la source (celui de `rust-mail` vient de son `README` et d'un résultat de recherche), pas
  de date de publication des crates ; je n'ai pas pu vérifier si les crates de
  `proton-crypto-rs` sont publiés sur crates.io (leur `Cargo.toml` vise un registre `proton`).
* **Tailles non mesurées** : clones sans extraction des fichiers ; aucun comptage de lignes.
* **Licences absentes** : `ios-mail`, `protoncore_android`, `proton-calendar`,
  `proton-contacts`, `sieve.js`, `pm-key-transparency-go-client` n'ont pas de fichier
  `LICENSE` au commit lu ; je n'ai pas cherché d'en-têtes de licence fichier par fichier.
* **`ProtonMail/clients`** : deux textes de licence (GPL-3.0 à la racine, AGPL-3.0 dans
  `project/mail/rust`) et un modèle d'en-tête « GPL v3 or later » ; je n'ai pas vérifié les
  en-têtes des fichiers Rust. Dernier commit public du 24 juin 2026 alors que `ios-mail`
  indique la version 0.165.4 du SDK : le miroir public est peut-être en retard.
* **SimpleLogin** : `LICENSE` AGPL-3.0 contre `license = "MIT"` dans `pyproject.toml`.
* **Liste des audits de Proton** (auditeur, année, produit) : sources secondaires seulement.
* **Stalwart, clés privées** : contradiction entre mon relevé du code (pas de déchiffrement
  dans `crates/crypto`) et un résumé de recherche (clés privées gardées par le serveur depuis
  la 1.0.2). La page https://stalw.art/docs/encryption/at-rest n'a pas été lue.
* **`rpgp`** : rapports d'audit non lus ; état actuel de l'avis RUSTSEC-2023-0071 sur la crate
  `rsa` non revérifié ; `docs/IMPL_STATUS.md` non lu.
* **S/MIME en Rust** : aucune bibliothèque évaluée (les crates `cms` et `x509-cert` de
  RustCrypto sont des pistes, licence et maturité non vérifiées).
* **Fonctions du webmail de Proton** (§6.1) : sources secondaires et mémoire ; les dates
  d'arrivée de chaque fonction ne sont pas établies.
* Rien n'a été compilé ni exécuté ; les efforts du §5.2 sont des ordres de grandeur, pas des
  mesures.

---

## Mesures SurrealDB (lot 0, décision C5)

Question posée par la décision P4 : SurrealDB 3.3.4 tient-il les accès d'un magasin de courrier
modélisé en tables et en fonctions SurrealQL (voie B), à l'échelle d'une grosse boîte ? Le banc
[`scripts/bench/mailbox/`](../../scripts/bench/mailbox/README.md) charge une boîte de 100 000
puis 1 000 000 de messages et mesure les accès qu'un serveur IMAP ou JMAP fait sans cesse.
Rien n'a été réglé pour tenir les seuils : schéma, index et requêtes sont ceux écrits avant la
première mesure ; les variantes essayées ensuite sont données à part (§5).

### 1. Conditions

| | |
| :--- | :--- |
| Date | 18 novembre 2026 |
| Machine | Machine virtuelle : 4 cœurs Intel Xeon (modèle non précisé par le système), 15,7 Gio de mémoire, disque virtuel, Linux 6.18.44 |
| SurrealDB | binaire `surreal` 3.3.4 pour Linux x86_64, réglages par défaut, démarré par le banc (`surreal start`) |
| Moteurs | `memory` ; `rocksdb://` ; `surrealkv://` (les trois que ce binaire accepte ; `surrealkv+versioned://` et `file://` sont refusés) |
| Client | Python 3.13 sur la même machine, HTTP `/sql`, une connexion gardée ouverte, session authentifiée par jeton |
| Lancement | `python3 -I scripts/bench/mailbox/bench_mailbox.py --messages 1000000 --engine rocksdb --data-dir <dossier vide> --out resultats.json` (options `--variants`, `--fulltext-concurrently` pour le §5) |

**Données.** Un compte, 20 dossiers (boîte de réception 38 % des messages, archive 24 %,
envoyés 10 %, le reste en dossiers de plus en plus petits), messages datés sur six ans, 80 % de
lus dans la boîte de réception, 3 % de marqués, 40 % rattachés à un fil existant, 4 000
expéditeurs et 3 000 mots de sujet tirés selon une loi de Zipf. Après le chargement, 15 % des
messages de chaque dossier changent de drapeau, pour que l'ordre des numéros de modification ne
soit pas celui des UID. À 1 000 000 de messages : 380 052 dans la boîte de réception, dont
environ 77 000 non lus. Graine fixe : le jeu de données est le même à chaque passage.

**Schéma** (`scripts/bench/mailbox/schema.surql`). Tables `bench_account`, `bench_mailbox`
(compteurs : prochain UID, plus haut numéro de modification, total, non-lus) et `bench_message`
(compte, dossier, UID, numéro de modification, date de réception, taille, cinq drapeaux,
mots-clés, fil, identifiant de message, adresse et nom de l'expéditeur, sujet, référence du
fichier). Les octets des messages ne sont pas en base. Index de `bench_message` :
`(mailbox, uid)` unique, `(mailbox, received_at)`, `(mailbox, modseq)`, `(mailbox, seen)`,
`(account, thread)`, `(account, from_addr, received_at)`. Deux index plein texte (sujet, nom de
l'expéditeur ; analyseur `class` + `lowercase` + `ascii`, BM25) sont ajoutés **après** les
mesures de base, pour mesurer leur coût à part.

**Méthode.** Chaque mesure est répétée (30 fois pour les pages et la synchronisation, 50 pour
le changement de drapeau, 5 à 15 pour les requêtes lentes), après deux passages à blanc. Les
tableaux donnent la **médiane / le 95e centile, en millisecondes**, du temps vu par le client
(envoi, exécution, lecture de la réponse). Pour une réponse courte, le temps annoncé par le
serveur est plus bas de 0,3 à 1 ms. Pour les moteurs sur disque, le serveur est redémarré entre le chargement et les
mesures (lecture depuis les fichiers du moteur ; le cache de fichiers du système reste chaud).
Les mesures portent sur le plus gros dossier (la boîte de réception). Un contrôle de fin
vérifie que les compteurs tenus par les écritures du banc égalent le contenu réel de la table.

Première version du banc écartée : avec une authentification par mot de passe à chaque
requête, chaque appel coûtait environ 20 ms de plus (vérification du mot de passe, lente par
construction). Le banc ouvre donc une session une fois, comme le fait le SDK Rust.

### 2. Résultats

« k » = millier, « M » = million de messages. Débits en messages par seconde.

| Mesure | Mémoire 100 k | RocksDB 100 k | SurrealKV 100 k | Mémoire 1 M | RocksDB 1 M | SurrealKV 1 M |
| :--- | -: | -: | -: | -: | -: | -: |
| **Pages** | | | | | | |
| Première page (50 messages, date décroissante) | 1,0 / 1,5 | 1,0 / 1,4 | 1,3 / 1,5 | 1,6 / 1,9 | 1,1 / 1,3 | 1,4 / 1,8 |
| Page profonde par curseur de date | 1,0 / 1,1 | 1,2 / 1,8 | 1,5 / 1,6 | 1,5 / 1,6 | 1,7 / 2,1 | 1,6 / 1,7 |
| Page profonde par décalage (`START`, dix mille messages sautés) | 48,8 / 56,2 | 40,2 / 54,1 | 96,8 / 122 | 104 / 116 | 43,7 / 49,5 | 102 / 128 |
| Page au milieu du dossier par décalage `START` | 97,4 / 104 | 74,5 / 77,8 | 177 / 222 | 1 889 / 2 006 | 1 001 / 1 120 | 2 385 / 2 862 |
| **Synchronisation** | | | | | | |
| 100 changements depuis un numéro de modification | 1,2 / 1,4 | 1,3 / 2,1 | 1,7 / 2,0 | 1,8 / 2,6 | 1,8 / 2,0 | 1,8 / 2,4 |
| 5 000 changements | 42,5 / 43,8 | 34,9 / 37,6 | 67,6 / 88,5 | 79,7 / 89,9 | 40,0 / 42,3 | 66,2 / 90,3 |
| Aucun changement | 0,5 / 3,0 | 0,5 / 0,6 | 0,6 / 0,8 | 0,7 / 1,1 | 0,8 / 1,0 | 0,6 / 0,7 |
| **Écriture** | | | | | | |
| Changement du drapeau « lu » (transaction) | 0,9 / 1,9 | 1,8 / 2,0 | 1,6 / 2,0 | 1,4 / 1,8 | 2,5 / 2,8 | 1,8 / 2,0 |
| Remise un par un, 1 client (messages/s) | 1 494/s | 815/s | 1 051/s | 1 541/s | 1 039/s | 913/s |
| Remise un par un, 4 clients sur 4 dossiers (messages/s) | 2 757/s | 1 479/s | 2 123/s | 2 626/s | 2 226/s | 1 793/s |
| **Comptes** | | | | | | |
| Non-lus d'un dossier (`count()` sur l'index) | 3,7 / 4,1 | 2,1 / 2,3 | 2,1 / 2,2 | 54,6 / 62,3 | 17,7 / 21,6 | 17,2 / 25,6 |
| Total d'un dossier (`count()` sur l'index) | 14,3 / 17,8 | 8,8 / 8,9 | 8,5 / 8,6 | 176 / 203 | 84,9 / 89,3 | 91,6 / 100 |
| Non-lus de tous les dossiers, `GROUP BY` | 529 / 550 | 439 / 450 | 923 / 953 | 9 523 / 10 398 | 6 170 / 6 414 | 13 984 / 14 915 |
| Non-lus de tous les dossiers, 20 requêtes en un envoi | 8,4 / 9,1 | 6,2 / 6,3 | 6,8 / 9,1 | 94,4 / 97,0 | 34,9 / 35,4 | 36,7 / 47,1 |
| Compteurs tenus à l'écriture (lecture des 20 dossiers) | 0,7 / 0,8 | 0,8 / 1,0 | 0,7 / 0,9 | 0,6 / 0,8 | 0,9 / 1,2 | 0,7 / 1,0 |
| **Recherche sans index plein texte** | | | | | | |
| Expéditeur exact (index) | 0,9 / 1,6 | 1,1 / 1,5 | 1,0 / 1,5 | 1,5 / 1,5 | 1,8 / 2,9 | 1,7 / 1,8 |
| Sujet contient un mot fréquent, dans un dossier | 6,4 / 6,6 | 4,8 / 5,3 | 3,8 / 4,0 | 8,3 / 9,3 | 7,1 / 8,1 | 4,1 / 4,2 |
| Sujet contient un mot rare, dans un dossier | 226 / 263 | 212 / 223 | 390 / 420 | 3 955 / 4 185 | 2 408 / 2 652 | 5 335 / 6 299 |
| Sujet contient un mot absent, dans un dossier | 222 / 239 | 204 / 207 | 382 / 461 | 3 375 / 3 706 | 2 423 / 2 537 | 5 222 / 5 937 |
| Nom de l'expéditeur contient un mot, toute la boîte | 530 / 581 | 516 / 541 | 982 / 1 127 | 9 292 / 9 491 | 5 653 / 5 972 | 13 911 / 14 704 |
| **Recherche avec index plein texte** | | | | | | |
| Sujet, mot fréquent, 50 premiers | 2,1 / 6,3 | 2,5 / 3,2 | 3,3 / 4,0 | 72,8 / 84,3 | 2,8 / 3,3 (a) | 3,4 / 4,0 |
| Sujet, mot moyen | 2,0 / 2,3 | 1,9 / 2,2 | 2,5 / 3,0 | 3,3 / 4,5 | 2,3 / 2,4 (a) | 4,0 / 4,8 |
| Sujet, mot rare | 0,9 / 0,9 | 0,9 / 1,1 | 0,7 / 0,8 | 1,3 / 1,6 | 1,8 / 2,2 (a) | 2,5 / 3,1 |
| Sujet, mot absent | 0,7 / 0,8 | 0,8 / 1,5 | 0,6 / 0,6 | 0,5 / 0,6 | 0,9 / 1,2 (a) | 0,8 / 1,0 |
| Sujet, deux mots | 2,1 / 2,4 | 1,9 / 2,1 | 2,8 / 3,2 | 71,6 / 73,5 | 2,4 / 2,6 (a) | 4,2 / 5,9 |
| Nom de l'expéditeur | 1,9 / 2,4 | 1,8 / 2,0 | 2,4 / 2,8 | 1,6 / 1,9 | 2,5 / 2,6 (a) | 3,9 / 4,7 |
| Sujet, mot fréquent, dans un dossier, trié par date | 404 / 430 | 379 / 446 | 846 / 886 | 4 917 / 5 900 | 4 070 / 4 338 (a) | 11 368 / 12 013 |
| Sujet, mot moyen, dans un dossier, trié par date | 3,1 / 3,4 | 2,9 / 3,1 | 4,5 / 4,7 | 33,8 / 35,1 | 21,0 / 21,8 (a) | 62,6 / 67,4 |
| Sujet, mot rare, dans un dossier, trié par date | 0,9 / 1,0 | 0,9 / 1,1 | 0,8 / 0,9 | 1,2 / 1,4 | 1,9 / 2,1 (a) | 2,1 / 2,9 |
| **Avec les index plein texte en place** | | | | | | |
| Première page | 1,3 / 1,4 | 1,3 / 1,5 | 90,6 / 110 | 1,0 / 1,1 | 1,6 / 1,8 (a) | 143 / 163 |
| Changement du drapeau « lu » | 1,2 / 1,4 | 1,8 / 2,2 | 1,6 / 1,9 | 0,9 / 0,9 | 3,0 / 3,7 (a) | 2,1 / 2,3 |
| Remise un par un, 1 client (messages/s) | 838/s | 647/s | 777/s | 1 098/s | 390/s (a) | 648/s |

(a) Deuxième passage sur RocksDB à 1 000 000 de messages, index plein texte construits avec
`CONCURRENTLY` (§5) : au premier passage, leur construction ordinaire a échoué.

| Chargement | Mémoire 100 k | RocksDB 100 k | SurrealKV 100 k | Mémoire 1 M | RocksDB 1 M | SurrealKV 1 M |
| :--- | -: | -: | -: | -: | -: | -: |
| Durée du chargement (s) | 50,4 | 20,4 | 15,9 | 553 | 228 | 192 |
| Débit par lots de 1 000 (messages/s) | 1 983 | 4 893 | 6 279 | 1 808 | 4 378 | 5 209 |
| Lot de 1 000 : médiane / 95e centile (ms) | 483 / 629 | 180 / 244 | 141 / 177 | 537 / 691 | 207 / 272 | 175 / 225 |
| Changements de drapeau après chargement, par lots de 500 (par s) | 7 419 | 2 865 | 7 324 | 6 086 | 2 540 | 3 280 |
| Construction des 2 index plein texte (s) | 4,9 | 8,0 | 7,9 | 63,8 | échec | 94,9 |
| Taille sur disque après chargement (Mio) | — | 221 | 154 | — | 2 249 | 1 543 |
| Taille sur disque en fin de banc (Mio) | — | 194 | 239 | — | 1 264 | 1 848 |
| Compteurs tenus = contenu réel en fin de banc | oui | oui | oui | oui | oui | oui |

### 3. Face aux seuils de la décision C5 (à 1 000 000 de messages)

| Seuil | Mesure retenue | Mémoire | RocksDB | SurrealKV | Tenu ? |
| :--- | :--- | -: | -: | -: | :-: |
| Page de 50 messages en moins de 100 ms | première page, 95e centile | 1,9 ms | 1,3 ms | 1,8 ms | **oui** |
| | page profonde par curseur de date, 95e centile | 1,6 ms | 2,1 ms | 1,7 ms | **oui** |
| | page profonde par décalage `START 10000`, 95e centile | 116 ms | 49,5 ms | 128 ms | **non** sur deux moteurs |
| | page au milieu du dossier par décalage `START 190026`, 95e centile | 2 006 ms | 1 120 ms | 2 862 ms | **non** |
| Synchronisation en moins de 100 ms | 100 changements, 95e centile | 2,6 ms | 2,0 ms | 2,4 ms | **oui** |
| | 5 000 changements, 95e centile | 89,9 ms | 42,3 ms | 90,3 ms | oui, de peu sur deux moteurs |
| Changement de drapeau en moins de 20 ms | transaction complète, 95e centile | 1,8 ms | 2,8 ms | 2,0 ms | **oui** |
| Insertion d'au moins 300 messages par seconde | remise un par un, un client | 1 541 | 1 039 | 913 | **oui** |
| | remise un par un, avec les index plein texte | 1 098 | 390 (a) | 648 | oui, de peu sur RocksDB |
| | chargement par lots de 1 000 | 1 808 | 4 378 | 5 209 | **oui** |

Les seuils sont tenus avec une marge d'un facteur 7 (changement de drapeau sur RocksDB) à 50
(première page) pour la première page, la page par curseur, la synchronisation courante et le
changement de drapeau. Ils ne sont **pas** tenus pour une page atteinte par décalage : le coût
est proportionnel au nombre de messages sautés (environ 5 à 12 ms par millier). Ce n'est pas un défaut d'index (le plan est un parcours
d'index avec limite et décalage) : c'est la nature d'un décalage.

### 4. Requêtes et plans

Requêtes exactes du banc (une variante par répétition : dossier, curseur ou expéditeur
différent), et plan rendu par `EXPLAIN` sur RocksDB à 1 000 000 de messages. Les plans relevés
sont les mêmes sur les trois moteurs.

Première page :

```surql
SELECT id, uid, received_at, size, seen, flagged, answered, thread, from_addr, from_name, subject
FROM bench_message WHERE mailbox = bench_mailbox:0 ORDER BY received_at DESC LIMIT 50;
```

```text
SelectProject [projections: id, uid, received_at, …]
    IndexScan [index: bench_message_mailbox_received, access: [bench_mailbox:0], direction: Backward, limit: 50]
```

Page profonde par curseur de date (même requête avec `AND received_at < d'2021-11-18T00:00:00Z'`) :

```text
IndexScan [index: bench_message_mailbox_received, access: [bench_mailbox:0] LessThan d'2021-11-18T00:00:00Z', direction: Backward, limit: 50]
```

Page profonde par décalage (même requête avec `LIMIT 50 START 10000`) :

```text
IndexScan [index: bench_message_mailbox_received, access: [bench_mailbox:0], direction: Backward, limit: 50, offset: 10000]
```

Changements depuis un numéro de modification :

```surql
SELECT id, uid, modseq, seen, flagged, answered, deleted, keywords FROM bench_message
WHERE mailbox = bench_mailbox:0 AND modseq > 436959 ORDER BY modseq LIMIT 1000;
```

```text
IndexScan [index: bench_message_mailbox_modseq, access: [bench_mailbox:0] MoreThan 436959, direction: Forward, limit: 1000]
```

Changement du drapeau « lu » (une transaction : lecture du message par dossier et UID, avancée
du numéro de modification et du compteur du dossier, écriture du message) :

```surql
BEGIN;
LET $msg = (SELECT id, seen FROM ONLY bench_message WHERE mailbox = bench_mailbox:0 AND uid = 12345 LIMIT 1);
LET $box = (UPDATE ONLY bench_mailbox:0 SET highest_modseq += 1, unseen += (IF $msg.seen THEN 1 ELSE -1 END) RETURN AFTER);
UPDATE $msg.id SET seen = !seen, modseq = $box.highest_modseq RETURN NONE;
COMMIT;
```

Remise d'un message (une transaction : réservation de l'UID et du numéro de modification sur
le dossier, compteurs, création du message) :

```surql
BEGIN;
LET $box = (UPDATE ONLY bench_mailbox:0 SET uid_next += 1, highest_modseq += 1, total += 1, unseen += 1 RETURN AFTER);
CREATE bench_message CONTENT { account: bench_account:1, mailbox: bench_mailbox:0, uid: $box.uid_next - 1, modseq: $box.highest_modseq, … } RETURN NONE;
COMMIT;
```

Non-lus d'un dossier, puis de tous les dossiers :

```surql
SELECT count() AS unseen FROM bench_message WHERE mailbox = bench_mailbox:0 AND seen = false GROUP ALL;
SELECT mailbox, count() AS unseen FROM bench_message WHERE account = bench_account:1 AND seen = false GROUP BY mailbox;
SELECT id, name, total, unseen, uid_next, highest_modseq FROM bench_mailbox WHERE account = bench_account:1;
```

```text
IndexCountScan [source: bench_message, condition: mailbox = bench_mailbox:0 AND seen = false]

Aggregate [by: mailbox]
    Filter [predicate: seen = false]
        IndexScan [index: bench_message_account_from, access: [bench_account:1], direction: Forward]

IndexScan [index: bench_mailbox_account_name, access: [bench_account:1], direction: Forward]
```

Recherche : expéditeur exact (index), sujet par parcours, sujet par index plein texte, puis
plein texte dans un dossier avec tri par date :

```surql
SELECT … FROM bench_message WHERE account = bench_account:1 AND from_addr = "contact0@exemple.fr" ORDER BY received_at DESC LIMIT 50;
SELECT … FROM bench_message WHERE mailbox = bench_mailbox:0 AND string::contains(string::lowercase(subject), "zyxquartz") ORDER BY received_at DESC LIMIT 50;
SELECT … FROM bench_message WHERE subject @@ "facture" LIMIT 50;
SELECT … FROM bench_message WHERE mailbox = bench_mailbox:0 AND subject @@ "facture" ORDER BY received_at DESC LIMIT 50;
```

```text
IndexScan [index: bench_message_account_from, access: [bench_account:1, 'contact0@exemple.fr'], direction: Backward, limit: 50]

Limit [limit: 50]
    Filter [predicate: string::contains(...)]
        IndexScan [index: bench_message_mailbox_received, access: [bench_mailbox:0], direction: Backward]

Limit [limit: 50]
    FullTextScan [index: bench_message_subject_ft, query: facture]

Limit [limit: 50]
    SortTopKByKey [sort_keys: received_at DESC, limit: 50]
        Filter [predicate: mailbox = bench_mailbox:0]
            FullTextScan [index: bench_message_subject_ft, query: facture]
```

Toutes les requêtes et tous les plans sont dans le fichier JSON de résultats de chaque passage
(champs `query` et `explain`).

### 5. Variantes essayées

Passage complémentaire sur RocksDB à 1 000 000 de messages (`--variants --fulltext-concurrently`).
Ses mesures de base recoupent celles du premier passage à moins de 15 % près (première page
1,2 / 1,5 ms, drapeau 2,8 / 3,1 ms, remise un par un 883 messages/s).

| Point | Mesure de base | Variante | Résultat (médiane / 95e centile) |
| :--- | :--- | :--- | :--- |
| Page profonde | décalage `START 10000` : 43,7 / 49,5 ms | plage d'UID sur l'index unique `(mailbox, uid)` : `AND uid <= 370052 ORDER BY uid DESC LIMIT 50` | **1,1 / 1,2 ms** |
| | | même décalage, identifiants seuls (`SELECT VALUE id`) | 51,8 / 53,6 ms : le coût est le saut, pas la lecture des messages |
| Numéro de séquence IMAP | — | rang d'un UID : `count()` des messages d'UID inférieur (190 026 lignes d'index) | 40,4 / 41,3 ms : proportionnel au rang |
| Non-lus de tous les dossiers | `GROUP BY` : 6 170 / 6 414 ms | compteur tenu par les écritures sur la fiche du dossier | **0,9 / 1,2 ms** (mesure de base du tableau) |
| | | table calculée `DEFINE TABLE … AS SELECT count() … WHERE seen = false GROUP BY mailbox` (tenue par la base) | lecture 0,5 / 0,7 ms ; construction 4,7 s ; drapeau 1,7 / 2,4 ms et remise 880 messages/s avec la vue en place ; valeur égale au compte réel |
| | | 20 `count()` sur l'index en un envoi | 34,9 / 35,4 ms |
| Total d'un dossier | `count()` sur l'index `(mailbox, …)` : 84,9 / 89,3 ms | index `COUNT` de la table | 82,1 / 91,6 ms : sans effet avec une condition ; il ne sert que le compte de la table entière (1,1 ms ; construction 13,3 s) |
| Index plein texte sur RocksDB | `DEFINE INDEX … FULLTEXT` : **échec** (« Transaction conflict […] the MemTable only contains changes newer than SequenceNumber… ») | `DEFINE INDEX … FULLTEXT … CONCURRENTLY`, puis attente de `INFO FOR INDEX` | construits en 96 s ; recherches aussi rapides que sur les autres moteurs |

Lecture en ordre inverse sur SurrealKV (sonde à 100 000 messages, hors banc) : tant que les
écritures récentes ne sont pas déchargées dans les fichiers du moteur, un parcours d'index en
ordre **décroissant** ralentit avec leur volume — 1,3 ms après un redémarrage, 1,7 ms après
2 000 remises, 10,8 ms après 20 000 remises, 82 ms juste après le chargement de 100 000
messages (95 ms après la construction des index plein texte, 87 ms une minute plus tard) ; le
même parcours en ordre croissant reste à 1 ms, et un redémarrage ramène 1,3 ms. C'est ce qui explique la ligne « Première page » à
143 / 163 ms sur SurrealKV après la construction des index plein texte. RocksDB ne montre pas
cet effet (1,1 à 1,4 ms dans les mêmes états).

Non essayé : une table par compte au lieu d'une table commune (le banc n'a qu'un compte ; tous
les index commencent par le dossier ou le compte, donc le coût mesuré ne devrait pas dépendre
des autres comptes — non vérifié) ; des identifiants d'enregistrement composés
(`bench_message:[dossier, uid]`) à la place de l'index unique.

### 6. Ce que les mesures montrent

1. **Les accès de base d'une boîte tiennent les seuils à 1 000 000 de messages, sur les trois
   moteurs** : première page, page par curseur, synchronisation, changement de drapeau,
   remise. Entre 100 000 et 1 000 000 de messages, ces temps ne bougent presque pas (parcours
   d'index bornés par `LIMIT`).
2. **Trois façons d'écrire sont à proscrire** dans le modèle, car leur coût croît avec la taille
   du dossier ou de la boîte :
   * paginer par décalage `START` (1 à 3 s au milieu d'un dossier de 380 000 messages) — paginer
     par curseur de date ou par plage d'UID ;
   * compter à la demande : `count()` par dossier coûte 17 à 55 ms pour 77 000 non-lus et 85 à
     176 ms pour le total ; `GROUP BY` sur la boîte coûte 6 à 14 s — tenir les compteurs à
     l'écriture (moins de 1,2 ms à la lecture, cohérence vérifiée en fin de banc) ;
   * chercher une sous-chaîne sans index : 2,4 à 5,3 s dans un dossier, 5,7 à 13,9 s sur la
     boîte.
3. **Numéros de séquence IMAP.** Traduire un numéro de séquence en UID par la base coûte un
   temps proportionnel au rang (40 ms au milieu du dossier). Le serveur IMAP devra garder la
   correspondance en mémoire par session, comme le font Stalwart et Mox.
4. **Recherche plein texte.** L'index de SurrealDB 3.3.4 répond en quelques millisecondes pour
   un mot, deux mots ou un mot absent. Deux limites : (a) un mot **fréquent** combiné à un
   dossier et à un tri par date coûte 4 à 11 s, parce que le plan filtre et trie tous les
   résultats du mot ; (b) sur le moteur en mémoire, un mot fréquent seul coûte 73 ms. Le
   lot 9 devra mesurer de nouveau avec le texte des corps, et choisir entre cet index et le
   moteur de recherche de Stalwart (`store/search`).
5. **Écritures.** La remise un par un dépasse 900 messages par seconde et par client sans index
   plein texte ; avec les deux index plein texte, elle tombe à 390 (RocksDB) – 1 100 (mémoire).
   Le chargement par lots est 2,4 à 3 fois plus lent sur le moteur en mémoire que sur disque.
6. **Moteurs.** RocksDB est le plus régulier en lecture. Il a deux points à connaître : la
   construction d'un index plein texte sur une table déjà pleine doit se faire avec
   `CONCURRENTLY`, et son dossier a atteint 11,8 Gio en fin de passage complémentaire (2,2 Gio
   après le chargement), avant tout compactage. SurrealKV charge plus vite mais lit mal en ordre
   décroissant les écritures récentes (§5) : or la première page d'une boîte est justement un
   parcours décroissant des messages les plus récents.

### 7. Conclusion pour la décision P4

**Les mesures ne condamnent pas la voie B** (modèle SurrealQL) : les seuils fixés par la
décision C5 sont tenus à 1 000 000 de messages sur les trois moteurs, pour les accès tels
qu'un magasin de courrier les écrit (curseur, compteurs tenus, index composés commençant par le
dossier). Les seuils ne sont pas tenus pour la pagination par décalage, que le modèle doit
exclure ; la variante par plage d'UID tient le seuil (1,2 ms). La voie A (moteur clé-valeur de
Stalwart) n'a pas été mesurée : rien ici ne la rend nécessaire.

Conditions à inscrire dans le plan du lot 4 si le CTO confirme la voie B : pagination par
curseur ou plage d'UID ; compteurs par dossier tenus dans la transaction d'écriture ; aucune
agrégation à la demande sur une boîte ; correspondance séquence ↔ UID tenue par la session
IMAP ; recherche traitée au lot 9 avec de nouvelles mesures ; choix du moteur de stockage
(RocksDB ou SurrealKV) arrêté avec une mesure de lecture décroissante sous écritures.

### 8. Ce qui n'a pas été mesuré

* **Charge concurrente** : lectures pendant des écritures, dizaines de sessions à la fois,
  plusieurs clients écrivant dans le **même** dossier (conflits de transaction sur la fiche du
  dossier). L'essai à quatre clients écrit dans quatre dossiers différents.
* **Plusieurs comptes** dans la même table, et plus de 1 000 000 de messages.
* **Cache froid** : le cache de fichiers du système n'a pas été vidé avant les lectures.
* **Texte des corps et des pièces jointes** dans l'index plein texte (seuls le sujet et le nom
  de l'expéditeur sont indexés) ; langues, pertinence.
* **Fils de discussion** (index `(account, thread)` défini, non mesuré), suppression et purge de
  messages, déplacement entre dossiers, quotas.
* **Mémoire consommée** : non relevée avec précision (environ 4 Gio occupés pendant le passage
  en mémoire à 1 000 000 de messages, d'après `free`).
* **Durée** : aucun essai long (compactage, croissance du disque dans le temps, redémarrage
  après arrêt brutal).
* **SDK Rust et WebSocket** : le banc passe par HTTP ; le coût par appel du SDK n'est pas mesuré.
* **Réglages** de SurrealDB et des moteurs : tous par défaut.
* **Reproductibilité** : un seul passage par configuration (deux pour RocksDB à 1 000 000),
  sur une machine virtuelle partagée ; les chiffres valent comme ordres de grandeur.
