# `lyxal_calendar` — recherche de sources (CalDAV, CardDAV, WebDAV)

Étude de sources du programme courrier, agendas et contacts, pour les agendas, les contacts et
le socle WebDAV (`lyxal_dav`, `lyxal_calendar`, `lyxal_contacts`). Le programme (architecture,
lots, décisions F1 à F5 et P1 à P15 du CTO) est décrit par `implementation_plan.md` à la racine
du dépôt ; l'objet du crate par son [`README.md`](README.md), la provenance du code porté par
[`SOURCES.md`](SOURCES.md), les évolutions par sa [`ROADMAP.md`](ROADMAP.md). L'étude du
courrier et de Proton, et les mesures de SurrealDB, sont dans
[`crates/lyxal_mail/RECHERCHE_SOURCES.md`](../lyxal_mail/RECHERCHE_SOURCES.md).

Étude en lecture seule. Registres (crates.io), fichiers de licence et manifestes des dépôts
publics lus le **18 novembre 2026**, avant les décisions du CTO ; aucun dépôt n'avait alors été
cloné (lecture des fichiers bruts et des étiquettes Git seulement). Je ne suis pas juriste : la
partie licences est une lecture technique des textes.

L'étude a été écrite **avant** les décisions du CTO. Son contenu est conservé (normes, sources,
licences, adresses, points non vérifiés). Les passages qui recommandaient un périmètre réduit ou
de ne pas reprendre de code AGPL ont été retirés et remplacés par une « Note du lot 0 » qui
renvoie à la décision prise : le CTO a décidé une suite complète, portée de projets open source
quelle que soit leur licence, la licence AGPL étant déclarée crate par crate.

Légende des niveaux de preuve : **[V]** vérifié le jour de l'étude sur la source citée ; **[C]**
connaissance générale des normes ou des logiciels, non revérifiée (les sites
`datatracker.ietf.org`, `sabre.io`, `stalw.art`, `davx5.com` n'étaient pas joignables depuis la
session d'étude) ; **[E]** estimation de l'auteur.

---

## 1. Résumé pour le CTO

1. **CalDAV n'est pas une norme, c'est une pile d'une quinzaine de normes.** Un « CalDAV complet »
   va du simple agenda synchronisé jusqu'aux invitations par e-mail entre serveurs.
2. **Licences des serveurs existants.** Les deux serveurs Rust sérieux (Stalwart, RustiCal) sont
   sous licence AGPL ; Radicale, Baïkal, Xandikos, DAViCal, SOGo, Nextcloud sont sous GPL ou
   AGPL. Les crates existants de Lyxal sont sous MIT ou Apache-2.0.
3. **Sources sous licence permissive** : la bibliothèque PHP `sabre/dav` (BSD, la référence
   historique : son modèle de données et ses tests sont transposables), le serveur d'Apple
   (Apache-2.0, archivé) et sa suite de tests CalDAVTester (Apache-2.0), et des briques Rust
   pour lire les fichiers d'agenda (`icalendar`, `rrule`, `calcard` 0.3.14).
4. **Alerte sur `calcard`** : la meilleure brique Rust (celle de Stalwart) a été archivée fin
   octobre 2026 ; la suite du développement est passée sous AGPL. La version 0.3.14 reste
   utilisable (MIT ou Apache-2.0) mais ne sera plus corrigée par ses auteurs.
5. **`lyxal_booking`** (dossier à la racine du dépôt) contient un *client* CalDAV (il lit des
   agendas externes), pas un serveur. Il est hors programme et n'est pas touché (décision F3).
6. **Mot de passe d'application** : les clients d'agenda envoient identifiant et mot de passe à
   chaque requête et ne savent pas faire de double facteur. Décision P8 : évolution de
   `lyxal_auth` (lot 1).

> **Note du lot 0.** L'étude recommandait un crate `lyxal_calendar` hébergé par `lyxal-server`,
> limité aux agendas, aux tâches, au partage et aux disponibilités, en reportant les invitations
> par e-mail et CardDAV, et sans reprendre de code AGPL. Cette recommandation est caduque. Les
> décisions qui font foi sont dans `implementation_plan.md` à la racine du dépôt : **F1** (CalDAV
> complet avec tâches, partage, planification iTIP / iMIP, disponibilités ; contacts CardDAV ;
> socle WebDAV) ; **F2, F4, F5, P2** (portage de Stalwart, RustiCal, sabre/dav ; licence
> `AGPL-3.0-only` déclarée par crate ; `SOURCES.md` ; code sous licence Entreprise de Stalwart
> jamais utilisé) ; **P1** (crates `lyxal_dav`, `lyxal_calendar`, `lyxal_contacts`) ; **P3** (hôte
> dédié `apps/lyxal-groupware`) ; **P5** (sources principales) ; lots 14 à 20.

---

## 2. Normes à couvrir

En clair : **WebDAV** transforme HTTP en système de dossiers et de fichiers avec propriétés ;
**CalDAV** dit qu'un dossier est un agenda et que chaque fichier est un événement au format
**iCalendar** ; **CardDAV** fait la même chose pour les contacts au format **vCard** ; **iTIP**
décrit les messages d'invitation, transportés soit par le serveur (RFC 6638), soit par e-mail
(**iMIP**).

| Norme | Rôle en une phrase | Dépend de | Palier |
| :--- | :--- | :--- | :--- |
| RFC 4918 — WebDAV | Dossiers, fichiers, propriétés sur HTTP (`PROPFIND`, `PROPPATCH`, `MKCOL`, `PUT`, `DELETE`, `COPY`, `MOVE`, verrous) | HTTP | b |
| RFC 3253 (extrait) | Définit la méthode `REPORT` que CalDAV utilise pour ses recherches | 4918 | b |
| RFC 3744 — ACL | Qui a le droit de quoi, notion de « principal » (compte) | 4918 | b (lecture des droits), c (partage) |
| RFC 5397 | Propriété « qui suis-je » (`current-user-principal`), point de départ de la découverte | 3744 | b |
| RFC 6764 | Découverte automatique : enregistrements DNS `_caldavs._tcp` et adresse `/.well-known/caldav` | DNS, 4918 | b |
| RFC 4791 — CalDAV | Agendas, `MKCALENDAR`, recherches par période (`calendar-query`), lecture groupée (`calendar-multiget`), `free-busy-query` | 4918, 3744, 5545 | b (c pour free-busy) |
| RFC 5689 | Création d'un dossier typé en une requête (`MKCOL` étendu) | 4918 | b |
| RFC 6578 — sync-collection | Synchronisation par jeton : « donne-moi ce qui a changé depuis » | 4918 | b |
| Extension `getctag` (Apple, hors RFC) | Ancienne version du jeton de changement, encore demandée par des clients | — | b |
| Propriétés Apple `calendar-color`, `calendar-order` (hors RFC) | Couleur et ordre d'affichage des agendas | — | b |
| RFC 5545 — iCalendar | Format des événements (`VEVENT`), tâches (`VTODO`), journaux, alarmes (`VALARM`), fuseaux (`VTIMEZONE`), récurrences (`RRULE`, `EXDATE`, `RECURRENCE-ID`) | — | b |
| RFC 7986 | Nouvelles propriétés iCalendar (couleur, nom, conférence, image) | 5545 | b |
| RFC 6868 | Écriture des caractères spéciaux dans les paramètres | 5545, 6350 | b |
| RFC 7529 — RSCALE | Récurrences dans des calendriers non grégoriens | 5545 | optionnel |
| RFC 9074 | Compléments aux alarmes (accusé, rappel reporté) | 5545 | c |
| RFC 7953 — VAVAILABILITY | Plages de disponibilité publiées | 5545, 4791 | c (optionnel) |
| Base IANA des fuseaux, RFC 7809, RFC 7808 | Fuseaux par référence (le serveur connaît la base IANA, le client n'envoie plus `VTIMEZONE`) ; 7808 est un service de distribution des fuseaux | 5545 | b (7809 partiel), 7808 hors périmètre |
| RFC 5546 — iTIP | Messages d'invitation : `REQUEST`, `REPLY`, `CANCEL`, `COUNTER`… | 5545 | d |
| RFC 6638 — planification CalDAV | Boîtes `schedule-inbox` / `schedule-outbox` : le serveur distribue lui-même les invitations entre ses utilisateurs | 4791, 5546 | d |
| RFC 6047 — iMIP | Invitations transportées par e-mail (pièce `text/calendar`) | 5546, e-mail | d |
| Délégation `calendar-proxy` (Apple, hors RFC) | Un assistant gère l'agenda d'un autre | 3744 | c |
| Partage d'agenda (extensions Apple `caldav-sharing`, brouillon `webdav-resource-sharing`) | Inviter quelqu'un sur un agenda | 3744 | c |
| RFC 8607 — pièces jointes gérées | Pièces jointes stockées par le serveur (statut « informatif ») | 4791 | optionnel, via `lyxal_storage` |
| WebDAV-Push (brouillon bitfire) | Notification immédiate des clients ; expérimental | 4918 | plus tard |
| RFC 7265 — jCal | iCalendar écrit en JSON | 5545 | optionnel |
| RFC 8984 — JSCalendar ; JMAP pour les agendas | Successeurs JSON ; JSCalendar 1.0 est une RFC, sa révision 2.0 et « JMAP for Calendars » sont **encore des brouillons** d'après les recherches du jour | 8620 | hors périmètre (à surveiller) |
| RFC 6352 — CardDAV | Carnets d'adresses sur WebDAV | 4918, 3744, vCard | e |
| RFC 6350 (vCard 4), RFC 2426 (vCard 3) | Format des contacts ; les clients envoient encore souvent la version 3 | — | e |
| RFC 9553 / 9554 / 9555, RFC 9610 | JSContact, extensions vCard associées, conversion, JMAP pour les contacts | — | hors périmètre |

**CardDAV et la couche de protocole.** Techniquement, CardDAV réutilise environ les deux
tiers de la couche WebDAV (découverte, propriétés, synchronisation, droits) **[E]**, et les
clients (iOS, DAVx⁵) configurent agenda et contacts ensemble. Les contacts sont un autre domaine
de données. Décision P1 : la couche de protocole est un crate à part (`lyxal_dav`) qui sert aux
deux ; CardDAV est livré par `lyxal_contacts` (lot 19).

---

## 3. Tableau des sources

« Reprendre » : **code** = licence permissive, copie ou dépendance possible avec les mentions
requises ; **modèle** = on lit le fonctionnement et on le réécrit ; **tests** = on peut faire
tourner l'outil contre notre serveur ou transposer les cas ; **rien**. Cette colonne date
d'avant les décisions du CTO : pour Stalwart et RustiCal, elle a été mise à jour d'après les
décisions F2 et P5 ; la carte des sources qui fait foi est celle du programme (§3.2 du plan).

### 3.1. Serveurs de référence

| Projet | Rôle | Langage / stockage | Licence vérifiée | Version / date | Reprendre |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **sabre/dav** | Bibliothèque de référence WebDAV + CalDAV + CardDAV, planification, partage ; base de Baïkal, Nextcloud, ownCloud | PHP ; SQL (tables `calendars`, `calendarinstances`, `calendarobjects` avec `firstoccurence` / `lastoccurence`, `calendarchanges` avec `synctoken`) | **BSD-3-Clause** [V] (`LICENSE`, `composer.json`) | 4.7.1 [V] (étiquette Git) | **code, modèle, tests** (avec la mention de copyright BSD) |
| **Baïkal** | Serveur léger au-dessus de sabre/dav | PHP ; SQLite / MySQL | **GPL-3.0-only** [V] (`composer.json`) — et non BSD | 0.13.0 ; 2.0.0-alpha2 [V] | modèle |
| **Apple Calendar and Contacts Server** | Serveur le plus complet historiquement (planification, délégation, partage, pièces jointes) | Python (Twisted) ; PostgreSQL [C] | **Apache-2.0** [V] (`LICENSE.txt`) ; **archivé** [V] (`README.rst`) | CalendarServer-9.2 [V] | **code, modèle** (code Python 2 ancien : sert surtout de référence de comportement) |
| **Stalwart** | Serveur mail et collaboration ; CalDAV, CardDAV, WebDAV depuis la 0.12.0 (26 mai 2025), planification RFC 6638 et e-mails d'invitation depuis la 0.13.0 (15 juil. 2025), JMAP agendas depuis la 0.14.0 (22 oct. 2025) | Rust ; stockage clé-valeur propre (RocksDB, FoundationDB, SQL…) [C] | **AGPL-3.0-only OU licence Entreprise Stalwart (SELv2)** [V] (`README`, en-têtes SPDX, `Cargo.toml`) | 1.1.1 du 16 nov. 2026 [V] (`CHANGELOG.md`) | **source principale du programme** (F2, P5), sans ses parties sous SELv2 (F5) |
| — ses crates internes `dav-proto`, `dav`, `groupware` | Analyse des requêtes DAV, traitement, données | Rust | AGPL / SEL [V] ; **jamais publiés** sur crates.io [V] | 1.1.1 | **sources du programme** (P5) |
| **RustiCal** | Serveur CalDAV / CardDAV, partage par groupes, WebDAV-Push, jetons d'application, profils Apple | Rust (axum 0.8) ; SQLite | **AGPL-3.0-or-later** [V] (`Cargo.toml`, `LICENSE`) | 0.19.1 [V] ; « en développement actif » selon son README | **source complémentaire du programme** (P5 : découpage du stockage, jetons d'application, WebDAV-Push) |
| **Radicale** | Serveur simple, très répandu en auto-hébergement | Python ; fichiers sur disque [C] | **GPL-3** [V] (`COPYING.md`, `pyproject.toml`) | 3.9.2 [V] | modèle ; peut tourner à côté |
| **Xandikos** | Serveur léger, données dans un dépôt Git | Python | **GPL-3.0-or-later** [V] | 0.4.11 [V] ; classé « Beta » | modèle |
| **DAViCal** | Serveur ancien, bon support de la délégation | PHP ; PostgreSQL [C] | **GPL-2** (« en général », avec des parties sous d'autres licences) [V] (`COPYING`) | r1.1.13 [V] (étiquette) | modèle |
| **Cyrus IMAP** | Serveur mail avec CalDAV / CardDAV / JMAP, auteur principal des RFC récentes | C | **Licence BSD de Carnegie Mellon** (4 clauses, avec clause de nom) [V] (`COPYING`) | version non relevée | modèle (code C peu transposable) |
| **SOGo** | Groupware avec connecteur Outlook | Objective-C | **GPL-2** [V] (`COPYING.GPL`) | 5.12.13 [V] | modèle |
| **Nextcloud** (app `dav`) | Groupware ; s'appuie sur sabre/dav | PHP | **AGPL-3.0** [V] (`COPYING`) | 35.0.3 [V] | modèle |

### 3.2. Bibliothèques Rust

| Crate | Rôle | Licence vérifiée (crates.io) | Version / date | Remarques | Reprendre |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`calcard`** (Stalwart Labs) | Lecture et écriture iCalendar, vCard, JSCalendar, JSContact ; conversions ; expansion des récurrences ; détection des fuseaux non standard | **Apache-2.0 OR MIT** [V] | **0.3.14**, 15 sept. 2026 — **dernière version publiée** : dépôt archivé, suite du développement dans le dépôt Stalwart sous AGPL / SEL, `publish = false` [V] | Dépend de `chrono`, `chrono-tz`, `mail-parser`, `mail-builder` ; plus de correctifs amont | **code** (version figée) |
| `calcard-next` | Copie reprise par un tiers après l'archivage | Apache-2.0 OR MIT [V] | 3.0.1, 10 nov. 2026 ; créé le 9 nov. 2026 ; 76 téléchargements [V] | Un seul mainteneur ; passé à `jiff` et `encodify`, comme la version AGPL interne à Stalwart : **origine du code à contrôler** avant tout usage (je n'ai pas pu vérifier qu'il ne contient aucun apport postérieur au changement de licence) | à ne pas retenir sans audit |
| **`icalendar`** | Constructeur et lecteur iCalendar typés (`VEVENT`, `VTODO`, alarmes) | **MIT / Apache-2.0** [V] | 0.17.17, 26 oct. 2026 ; 1,1 M de téléchargements [V] | `chrono` ; option `rrule` ; activement maintenu | **code** |
| **`rrule`** | Expansion des récurrences RFC 5545 (`RRULE`, `RDATE`, `EXDATE`, ensembles) avec garde-fous contre les boucles | **MIT OR Apache-2.0** [V] | 0.14.0, 20 avr. 2025 ; 1,8 M de téléchargements [V] | Fuseaux par `chrono-tz` ; pas de version depuis 19 mois | **code** |
| `ical` | Lecteur iCalendar / vCard bas niveau | Apache-2.0 (fichier `LICENSE`) [V] | 0.11.0, 13 mars 2024 [V] | Peu actif | code (peu utile) |
| `caldata` (auteur de RustiCal) | Dérivé de `ical`, utilisé par RustiCal | Apache-2.0 (fichier) [V], **mais dépend de `vtimezones-rs`, GPL-3.0-or-later** [V] | 0.18.0, 31 oct. 2026 | Dépendance GPL : à relever au lot qui porterait du code de RustiCal qui en dépend | à instruire par lot |
| `ical-rs` | Lecteur, validateur, éditeur iCalendar | MIT OR Apache-2.0 [V] | 0.7.1, 16 nov. 2026 ; créé en août 2026 | Jeune | à surveiller |
| `mailrs-ical`, `mailrs-dav` | Lecteur iCalendar + sémantique iTIP ; gestionnaires CalDAV / CardDAV côté serveur, indépendants du framework, données fournies par un trait | Apache-2.0 OR MIT [V] | 2.2.0 et 2.0.0, 22 oct. 2026 ; créés en mai 2026 ; 3 200 et 1 700 téléchargements [V] | `mailrs-dav` : pas de filtre par période (annoncé « à venir »), pas de `sync-collection` listée | **modèle et code** d'appoint, pas une base |
| **`dav-server`** | Serveur WebDAV générique (réussit la suite litmus de base) ; options `caldav` et `carddav` | **Apache-2.0** [V] | 0.12.0, 9 nov. 2026 ; 742 000 téléchargements [V] | Modèle « système de fichiers » ; sa propre notice dit : pas de planification, **pas de partage ni d'ACL**, méthode `ACL` absente | code possible pour la partie WebDAV fichiers ; peu adapté à un stockage SurrealDB avec droits par organisation |
| `dav-xml` | Types XML WebDAV | MIT OR Apache-2.0 [V] | 0.2.0, sept. 2026 | Très jeune | à surveiller |
| `libdav` | **Client** CalDAV / CardDAV | **ISC** [V] | 0.11.2, 30 oct. 2026 | Utile pour lire des agendas externes | code (côté client) |
| `kitchen-fridge` | Client CalDAV | MIT [V] | 0.4.0, janv. 2022 — inactif | — | rien |
| `minicaldav` | Client CalDAV | **GPL-3.0-or-later** [V] | 0.8.0, juil. 2023 | — | rien |
| `fast-dav-rs` | Client CalDAV / CardDAV | LGPL-3.0 [V] | 0.19.0 | — | rien |
| `vcard4` | Lecteur vCard 4 | MIT OR Apache-2.0 [V] | 0.7.3, févr. 2026 | Pour le palier e | code |
| `quick-xml` (déjà dans `lyxal_parsing`), `jiff` (déjà dans le dépôt) | XML ; dates et fuseaux avec base IANA embarquée | MIT ; Unlicense OR MIT [V] | 0.42.0 ; 1.0.1 (le dépôt utilise 0.2) | — | déjà là |

### 3.3. Outils de conformité

| Outil | Rôle | Licence vérifiée | Version | Usage permis |
| :--- | :--- | :--- | :--- | :--- |
| **CalDAVTester** (Apple ; copie chez CalConnect) | Suite de tests scriptés CalDAV / CardDAV (fichiers XML de scénarios) | **Apache-2.0** [V] ; dépôt Apple **archivé** [V] | 7.0 [V] | faire tourner et transposer les scénarios ; code Python ancien (Python 2 [C]) |
| **caldav-server-tester** | Sonde un serveur et dresse la liste des fonctions gérées, bancales ou fausses (matrice de `python-caldav`) | **AGPL-3.0-or-later** [V] | 1.8.0 [V] | faire tourner comme outil externe en intégration continue ; ne rien en copier |
| **python-caldav** | Bibliothèque cliente + table `compatibility_hints.py` des particularités de chaque serveur | **GPL-3.0-or-later OU Apache-2.0** [V] | 3.7.0 [V] | la table est exploitable sous Apache-2.0 |
| **litmus** | Conformité WebDAV de base (copie, déplacement, propriétés, verrous) | **GPL-2** [V] | 0.18 [V] | outil externe seulement |
| Tests de **sabre/dav** | Tests unitaires du comportement de référence | BSD-3-Clause [V] | 4.7.1 | transposables avec mention |
| Tests de Stalwart et de RustiCal | — | AGPL (ceux de Stalwart sont privés depuis la 1.0.0) | — | ceux de RustiCal : transposables dans les crates AGPL du programme (P10) |

---

## 4. Clients réels : ce que chacun exige

Sources : documentation de sabre/dav sur la construction d'un client (fichier du dépôt
`sabre-io/sabre.io`, lu aujourd'hui pour les étiquettes `ctag`, `etag`, `sync-token`), README de
RustiCal (clients testés), notes de projets serveurs trouvées par recherche ; le reste est de la
connaissance générale **[C]**. Le comportement des clients Apple n'est documenté nulle part
officiellement : il se confirme par essais.

| Client | Ce qu'il exige ou utilise |
| :--- | :--- |
| **Apple Calendrier (iOS, macOS)** | HTTPS ; découverte complète (`/.well-known/caldav`, `current-user-principal`, `calendar-home-set`) ; authentification HTTP Basic ; `getctag` et `sync-collection` ; `calendar-color` et `calendar-order` ; `supported-calendar-component-set` (un agenda `VEVENT` pour Calendrier) ; conserve des propriétés `X-APPLE-*` qu'il faut rendre telles quelles ; planification RFC 6638 si le serveur l'annonce ; partage au format Apple ; iOS ne gère pas la délégation `calendar-proxy` (sabre.io) |
| **Rappels Apple (VTODO)** | Liste séparée ne contenant que `VTODO` ; depuis iOS 13 / macOS 10.15 les rappels « améliorés » ne passent plus par CalDAV ; un compte CalDAV tiers reste possible avec des fonctions réduites (pas de sous-tâches) — retours d'utilisateurs contradictoires selon les serveurs, **à essayer** |
| **Thunderbird** | Découverte automatique dans les versions récentes [C] (la page sabre.io qui dit le contraire décrit l'ancien module Lightning) ; `sync-collection` ou `PROPFIND` puis `calendar-multiget` ; n'utilise pas `calendar-query` (note d'un projet serveur) ; invitations surtout par e-mail (iMIP) |
| **DAVx⁵ (Android)** | Découverte RFC 6764 ; `sync-collection`, `calendar-query` par période, `calendar-multiget` ; agendas, tâches (via Tasks.org / jtx Board) et contacts dans le même compte ; WebDAV-Push expérimental (depuis la 4.4.10) |
| **GNOME (Evolution, Agenda)** | Découverte par compte en ligne ; `getctag` + `etag` ; événements, tâches et notes (`VJOURNAL`) |
| **Outlook** | Pas de CalDAV natif dans Outlook classique ; module « CalDav Synchronizer » (AGPL-3, à installer par l'utilisateur), **incompatible avec le « nouvel Outlook »** |
| **Home Assistant, scripts** | `calendar-query` par période : la recherche par période doit être juste, y compris sur les récurrences |

Conséquences pour nous : la découverte, les ETags stricts (`If-Match`, `If-None-Match: *`), le
jeton de synchronisation avec mémoire des suppressions, la recherche par période avec récurrences
et la restitution **à l'octet près** du fichier reçu sont non négociables dès le palier b.

---

## 5. Analyse de licence (lecture technique, pas un avis juridique)

Lecture pour un crate sous `MIT OR Apache-2.0`, licence des crates existants du workspace
(`Cargo.toml` du workspace).

| Licence de la source | Dépendance Cargo | Copie de code | Lire pour s'inspirer | Faire tourner à côté |
| :--- | :--- | :--- | :--- | :--- |
| MIT, Apache-2.0, BSD-3-Clause, ISC, Unlicense | oui | oui, en gardant les mentions de copyright (et le fichier `NOTICE` pour Apache-2.0, §4 de la licence) | oui | oui |
| Apache-2.0 seule (`dav-server`, `ical`) | oui : la dépendance garde sa licence ; le produit distribué doit respecter Apache-2.0 pour cette partie | oui, le fichier copié reste sous Apache-2.0 | oui | oui |
| LGPL-3.0 | liaison statique en Rust : obligations de re-liaison difficiles à tenir | non | oui | oui |
| **GPL-2 / GPL-3** | l'ensemble lié doit être distribué sous GPL (GPL-3 §5) | le crate qui reçoit la copie passe sous GPL | oui — les idées et le fonctionnement ne sont pas protégés, seul le code l'est | oui (« simple agrégat », GPL-3 §5 dernier alinéa) |
| **AGPL-3.0** (Stalwart, RustiCal, Nextcloud) | l'ensemble lié doit être distribué sous AGPL | le crate qui reçoit la copie passe sous AGPL | oui | oui ; si on **modifie** le serveur et qu'on l'offre en réseau, il faut publier les modifications (AGPL-3 §13) |
| Licence Entreprise Stalwart | propriétaire, payante | non | — | selon contrat |

> **Note du lot 0.** L'étude concluait qu'aucune source GPL ou AGPL ne pouvait être copiée ni
> liée. Le CTO en a décidé autrement (décisions F2, F4, F5 et P2 du programme) : les sources
> AGPL et GPL sont portées dans les crates du programme, qui déclarent `AGPL-3.0-only` et
> tiennent un `SOURCES.md` ; aucun crate existant ne reçoit de code AGPL ou GPL, et
> `lyxal-server` ne lie aucun crate du programme (P3) ; les parties de Stalwart sous licence
> Entreprise ne sont jamais utilisées. Le CTO traite lui-même les conséquences de licence.

Points d'attention :

* **Une dépendance transitive compte.** `caldata` est sous Apache-2.0 mais tire
  `vtimezones-rs` (GPL-3.0-or-later). Chaque ajout passe par un contrôle de l'arbre complet
  (`cargo deny check licenses`, `deny.toml` à la racine du dépôt).
* **Serveur à côté** (Radicale GPL-3, Stalwart AGPL-3), voie étudiée et non retenue : aucune
  contrainte sur notre code tant qu'on communique par le réseau (HTTP) sans lier ni copier.
  Contraintes pratiques : deuxième base de données, comptes et droits à synchroniser,
  sauvegardes séparées, pas d'isolation par organisation native dans Radicale ; la
  multi-location de Stalwart est une fonction de son édition Entreprise (d'après son README).

Textes : <https://www.gnu.org/licenses/gpl-3.0.html>, <https://www.gnu.org/licenses/agpl-3.0.html>,
<https://www.apache.org/licenses/LICENSE-2.0>, <https://opensource.org/license/bsd-3-clause>,
<https://opensource.org/license/mit>.

---

## 6. Ce qui existe déjà chez nous

| Élément | Constat (fichiers lus) | Conséquence |
| :--- | :--- | :--- |
| **`lyxal_booking/`** (racine, hors `crates/`) | Hors workspace : non compilé par la CI, non hébergé par `lyxal-server` ; vise SurrealDB 2.x. | Hors programme, non touché (décision F3). |
| — sa partie agenda | **Client** CalDAV (`engine/src/caldav/mod.rs`, 1 676 lignes : découverte, liste des agendas, `PUT`/`DELETE`, `sync-collection`, protection SSRF), connecteurs Google (OAuth) et Exchange (`ews/`), générateur d'invitations `.ics` (`email/ics.rs`), récurrences maison limitées (`rrule.rs` : quotidien, hebdomadaire, mensuel ; refuse `BYMONTHDAY`, `BYSETPOS`, `YEARLY`). Tables `booking_caldav_source`, `booking_calendar` (avec `ctag`), `booking_event`. | Aucun serveur CalDAV. Le besoin « lire les agendas externes pour connaître les indisponibilités » est distinct du serveur ; il relève plutôt de la proposition `lyxal_connect`, avec `libdav` (ISC) comme brique. |
| **`Lyxal_timezone/`** | Un cahier des charges (`.docx`) : fuseaux centralisés ; cite explicitement « Calendriers, événements, récurrences (**Lyxal_Calendar**) » comme hors de son périmètre. | Le nom `lyxal_calendar` est déjà attendu. Les fuseaux d'un agenda s'appuieront sur `jiff` (base IANA embarquée), déjà utilisé par `lyxal_scheduler`, `lyxal_i18n`, `lyxal_notification`. |
| **`crates/lyxal_scheduler`** | Ses « calendriers » sont des calendriers d'**exceptions** de planification (jours fériés…), pas des agendas d'utilisateurs ; `RRULE` est sur sa feuille de route ; calcul des dates en Rust (`jiff`, `croner`). | Ne pas fusionner. Réutiliser le planificateur pour les tâches de fond (purge des suppressions, rappels). L'expansion `RRULE` écrite pour l'agenda pourra être offerte au planificateur plus tard, pas l'inverse. |
| **`crates/lyxal_auth`** | Clés d'API personnelles (`auth_api_key`, session de nature `api_key`, permissions bornées par celles du propriétaire) ; l'hôte les échange contre un jeton `Bearer` (`/api-keys/exchange`). Double facteur en place. | Les clients d'agenda envoient un identifiant et un mot de passe en **HTTP Basic à chaque requête** : il faut une entrée « mot de passe d'application » — évolution de `lyxal_auth` (décision P8, lot 1). |
| **`crates/lyxal_storage`** | Fichiers en flux, plages d'octets, quotas, envoi reprenable. | Pièces jointes gérées (RFC 8607) possibles plus tard sans nouveau stockage. |
| **`crates/lyxal_notification`** | E-mail sortant (SMTP et fournisseurs), parcours, gabarits traduits. Je n'ai trouvé dans son README **ni pièce jointe ni réception d'e-mail**. | Les invitations par e-mail demandent une pièce `text/calendar` et une **réception d'e-mails** : dans le programme, elles passent par `lyxal_mail` (lots 5, 6 et 18). |
| **`crates/lyxal_parsing`** | Lecture en flux CSV, XML (`quick-xml` 0.42), JSON. | La lecture XML des requêtes DAV peut s'appuyer sur la même dépendance. |
| **`apps/lyxal-server`** | Hôte axum 0.7 ; un fichier de routes par service (`http/storage.rs`, `http/scheduler.rs`…). | Décision P3 : les routes DAV sont servies par l'hôte dédié `apps/lyxal-groupware`, bâti de la même façon ; axum doit accepter les méthodes non standard (`PROPFIND`, `REPORT`, `MKCALENDAR`). |

---

## 7. Options de périmètre

Effort en « lots » de la taille de ceux des crates déjà livrés (`lyxal_scheduler` : 5 lots ;
`lyxal_notification` : 7 lots). Ce sont des **estimations** de l'étude, à ±50 %. Le programme
couvre tous les paliers (b) à (e) (décision F1), dans les lots 14 à 20, avec ses propres tailles
(§5 du plan). Les colonnes « Briques réutilisables » et « À écrire » sont celles de l'étude,
avant la décision de porter Stalwart (P5).

| Palier | Contenu | Normes | Briques réutilisables | À écrire | Effort [E] | Risque |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **(a)** Flux ICS en lecture seule | Une adresse secrète par agenda, que les clients « abonnent » | 5545, 7986 | `icalendar` (écriture) | Tables, fonctions, une route `GET` | 1 lot | Faible. Pas de modification depuis le téléphone ; rafraîchissement lent décidé par le client |
| **(b)** Serveur CalDAV, événements | Agendas, `VEVENT`, découverte, synchronisation, recherche par période, clients principaux | 4918 (sans verrous complets), 3253 `REPORT`, 3744 (lecture), 5397, 6764, 4791, 5689, 6578, 5545, 7986, 6868, 7809 partiel, `getctag`, propriétés Apple | `icalendar` ou `calcard` 0.3.14 (lecture), `rrule` (récurrences), `quick-xml`, `jiff` ; modèle de données de sabre/dav | Toute la couche DAV (XML, multistatus, préconditions, rapports), le modèle SurrealQL, l'authentification Basic, les essais sur clients réels | 5 à 6 lots | **Moyen à élevé** : la norme est large et chaque client a ses particularités ; la sécurité (expansion de récurrences bornée, XML hostile) demande un lot à elle seule |
| **(c)** + tâches, partage, disponibilités | `VTODO` (et `VJOURNAL`), partage en lecture / écriture, délégation, `free-busy-query`, alarmes | + 3744 complet côté droits, `calendar-proxy`, partage Apple, 9074, 7953 optionnel | idem | Droits fins, vues partagées par utilisateur (couleur, nom propres), calcul des plages occupées | + 2 à 3 lots | Moyen : les extensions de partage ne sont pas des RFC, à valider client par client |
| **(d)** + invitations | Boîtes de planification entre utilisateurs internes (6638), invitations par e-mail vers l'extérieur (iMIP), traitement des réponses | 5546, 6638, 6047 | `calcard` 0.3.14 (dépend déjà de `mail-parser` / `mail-builder`, MIT/Apache), `mailrs-ical` (sémantique iTIP, jeune) | Machine d'états iTIP (numéros de séquence, exceptions de récurrence, contre-propositions), envoi avec pièce `text/calendar` via `lyxal_notification`, **réception et lecture d'e-mails** (nouvelle capacité de la plateforme), anti-usurpation | + 4 à 5 lots, dont la réception d'e-mails | **Élevé** : c'est la partie où les serveurs existants ont le plus de défauts ; dépend d'une brique absente |
| **(e)** + contacts CardDAV | Carnets d'adresses, vCard 3 et 4, recherche, synchronisation | 6352, 6350, 2426, 6868 | couche DAV du palier b ; `calcard` 0.3.14 ou `vcard4` | Modèle contacts, rapports `addressbook-query` / `multiget`, lien avec le futur `lyxal_crm` | + 2 lots | Faible à moyen si la couche DAV a été conçue pour deux usages |

### 7.1. Modèle de données proposé par l'étude (paliers b et c)

Proposition de l'étude, à reprendre ou à revoir dans les plans des lots 15 à 17 : transposition
du modèle de sabre/dav (BSD) et des principes de Stalwart, en tables préfixées par le module
(`AGENTS.md` §7) :

| Table | Contenu |
| :--- | :--- |
| `calendar_collection` | Agenda : organisation, propriétaire (identité `lyxal_auth`), nom d'adresse, composants acceptés (`VEVENT`, `VTODO`…), fuseau par défaut, compteur de synchronisation, état (actif, corbeille) |
| `calendar_instance` | Vue d'un agenda pour un utilisateur : nom affiché, couleur, ordre, niveau d'accès (propriétaire, lecture, écriture), état de l'invitation de partage — c'est la table `calendarinstances` de sabre/dav |
| `calendar_object` | Une ressource : agenda, nom de fichier, `UID`, type, **texte iCalendar reçu, conservé tel quel**, ETag (empreinte par `lyxal_crypto`), taille, et projections indexées : début de la première occurrence, fin de la dernière (vide si récurrence sans fin), présence d'une récurrence, organisateur, participants, résumé |
| `calendar_change` | Journal : agenda, numéro de synchronisation, nom de fichier, opération (ajout, modification, suppression) — sert le jeton RFC 6578 et garde la trace des suppressions ; purgé par une tâche `lyxal_scheduler`, un jeton trop ancien renvoyant l'erreur normalisée « jeton invalide » |
| `calendar_feed` (palier a) | Adresse secrète d'abonnement en lecture seule, révocable |
| plus tard | `calendar_scheduling_object` (boîte de réception, palier d), `calendar_attachment` → `lyxal_storage` |

Index unique sur (agenda, nom de fichier) et sur (agenda, `UID`), comme l'exige RFC 4791 §5.3.2.1.

**Récurrences.** Stratégie de sabre/dav : ne stocker que les bornes (première et dernière
occurrence) pour un filtre grossier en base, puis développer précisément les candidats : le
filtre SurrealQL élimine l'essentiel, Rust développe le reste avec un plafond (nombre
d'occurrences et étendue de dates). Ce plafond est une exigence de sécurité : Stalwart a publié
une alerte (CVE-2025-59045) pour une expansion non bornée dans les rapports CalDAV.
Alternative : matérialiser toutes les occurrences dans une table (coûteux à maintenir,
impossible pour les récurrences sans fin).

**Répartition SurrealQL / Rust** (philosophie §10 des standards) :

| En Rust | En SurrealQL |
| :--- | :--- |
| Lecture du XML des requêtes, écriture des réponses `207 Multi-Status` | `fn::calendar_collection_create / update / delete / list` |
| Lecture et contrôle du fichier iCalendar ; extraction des projections ; expansion des récurrences ; fuseaux (`jiff`) | `fn::calendar_object_put` : droits, composant accepté, unicité de l'`UID`, précondition d'ETag, quota de taille, incrément du compteur, ligne de journal, événement `calendar.object.changed` — le tout dans une seule fonction, donc atomique |
| Authentification HTTP Basic → session | `fn::calendar_object_delete`, `fn::calendar_object_query` (filtre par période sur les bornes), `fn::calendar_sync_changes` (depuis un jeton), `fn::calendar_share_*`, `fn::calendar_freebusy` (lecture des candidats) |
| Calcul final des plages occupées à partir des occurrences développées | Validation des entrées par `lyxal_core` (`fn::validation_object_execute`), erreurs `CALENDAR_*` en master data, `CALENDAR_WRITE_FORBIDDEN` |

Les wrappers Rust restent des appels `store.call_fn("calendar_…", params)` (§5.4).

**Authentification des clients DAV.** Les clients d'agenda envoient identifiant + mot de passe en
HTTP Basic à chaque requête et ne savent pas répondre à un second facteur. Pratique commune
(RustiCal, Nextcloud, Stalwart, iCloud) : un **mot de passe d'application** par appareil,
révocable, à droits réduits. Décision P8 (lot 1) : mot de passe d'application dans `lyxal_auth`,
limité aux permissions choisies, vérifié à chaque connexion sans Argon2 complet, avec
limitation des essais.

**Isolation par organisation.** Adresses de la forme `/dav/<organisation>/principals/<identité>/`
et `/dav/<organisation>/calendars/<identité>/<agenda>/` ; la clé d'API est liée à une
organisation ; permissions de table par organisation comme dans les autres crates ; un
`calendar-home-set` ne liste jamais un agenda d'une autre organisation.

**Relation avec l'existant.** `lyxal_scheduler` reste indépendant (ses calendriers d'exceptions
ne sont pas des agendas). La reprise de `lyxal_booking` au-dessus de `lyxal_calendar` est hors
programme (§9 du plan).

---

## 8. Suite donnée par le CTO

> **Note du lot 0.** L'étude recommandait ici un crate `lyxal_calendar` livré jusqu'au partage et
> aux disponibilités, écrit à partir de sabre/dav et de bibliothèques permissives (`icalendar`,
> `rrule`, `calcard` 0.3.14), sans code de Stalwart ni de RustiCal, et hébergé par
> `lyxal-server`. Cette recommandation est caduque. Décisions qui font foi (programme à la
> racine du dépôt) :
>
> * **F1** — CalDAV complet : tâches, partage, planification iTIP / iMIP, disponibilités ;
>   contacts CardDAV ; socle WebDAV ;
> * **P1** — trois crates : `lyxal_dav` (Rust pur : XML WebDAV / CalDAV / CardDAV, iCalendar et
>   vCard), `lyxal_calendar`, `lyxal_contacts` ; Noyau Technique, après `lyxal_notification` ;
> * **P5** — sources : Stalwart (`dav-proto`, `dav`, `groupware`, `calcard` dans sa version du
>   dépôt Stalwart, sur `jiff`), sabre/dav pour le modèle de données et les tests, RustiCal
>   pour le découpage du stockage, les jetons d'application et WebDAV-Push ;
> * **P3** — hôte dédié `apps/lyxal-groupware` ; **P8** — mots de passe d'application ;
> * **P10** — suites de conformité : CalDAVTester, `caldav-server-tester`, litmus en outils
>   externes ; tests de sabre/dav et de RustiCal transposés ;
> * lots 14 (formats), 15 (socle WebDAV), 16 (CalDAV), 17 (tâches, partage, disponibilités),
>   18 (planification), 19 (CardDAV), 20 (JMAP agendas et contacts).
>
> Les dépendances et la place dans la hiérarchie sont décrites au §4 du programme.

---

## 9. Questions posées par l'étude et décisions

| Question de l'étude | Décision |
| :--- | :--- |
| Palier cible ; invitations par e-mail | F1 : tous les paliers, invitations comprises (lot 18) |
| Contacts (CardDAV) | F1, P1 : dans le programme, crate `lyxal_contacts` (lot 19) |
| Un crate ou deux ; nom | P1 : `lyxal_dav` + `lyxal_calendar` (+ `lyxal_contacts`) |
| Brique iCalendar | P5 : `calcard` dans sa version du dépôt Stalwart (sur `jiff`, déjà dans le dépôt Lyxal) |
| Place dans la hiérarchie | P1 : Noyau Technique |
| Mot de passe d'application | P8 : évolution de `lyxal_auth` (lot 1) |
| `lyxal_booking` | F3 : non touché, hors programme |
| Solution d'attente (serveur existant à côté) | Non retenue |
| Clients à garantir | Essais réels sur appareils fournis par le CTO (P11, P12, lot 22) |
| Réception d'e-mails | Dans le programme : `lyxal_mail` (lot 5) |
| Revue juridique | F2 : le CTO traite lui-même les conséquences de licence |

---

## 10. Sources

Registres et dépôts lus le 18 novembre 2026.

**Crates (crates.io, API `https://crates.io/api/v1/crates/<nom>`)** :
<https://crates.io/crates/calcard>, <https://crates.io/crates/calcard-next>,
<https://crates.io/crates/icalendar>, <https://crates.io/crates/rrule>,
<https://crates.io/crates/ical>, <https://crates.io/crates/caldata>,
<https://crates.io/crates/vtimezones-rs>, <https://crates.io/crates/ical-rs>,
<https://crates.io/crates/mailrs-dav>, <https://crates.io/crates/mailrs-ical>,
<https://crates.io/crates/dav-server>, <https://crates.io/crates/dav-xml>,
<https://crates.io/crates/libdav>, <https://crates.io/crates/kitchen-fridge>,
<https://crates.io/crates/minicaldav>, <https://crates.io/crates/fast-dav-rs>,
<https://crates.io/crates/vcard4>, <https://crates.io/crates/quick-xml>,
<https://crates.io/crates/jiff>, <https://crates.io/crates/mail-parser>.
`dav-proto`, `rustical`, `jmap-proto` : absents de crates.io (requête sans résultat).

**Stalwart** : <https://github.com/stalwartlabs/stalwart> — `README.md` (licence double, liste
des protocoles), `Cargo.toml` (membres `crates/dav-proto`, `crates/dav`, `crates/groupware`,
`crates/calcard`), `crates/calcard/Cargo.toml` (`AGPL-3.0-only OR LicenseRef-SEL`,
`publish = false`), `crates/dav-proto/Cargo.toml`, `CHANGELOG.md` (0.12.0 du 2025-05-26, 0.13.0
du 2025-07-15, 0.14.0 du 2025-10-22, 1.0.0 du 2026-10-26, 1.1.1 du 2026-11-16, CVE-2025-59045).
`calcard` archivé : <https://github.com/stalwartlabs/calcard> (`README.md`, `Cargo.toml`) ;
<https://support.stalw.art/t/calcard-will-it-be-published-to-crates-io-under-a-permissive-license-again/2054> ;
copie tierce <https://github.com/EvanCarroll/calcard-next>.

**Autres serveurs** : <https://github.com/lennart-k/rustical> (`Cargo.toml`, `LICENSE`, `README.md`) ;
<https://github.com/lennart-k/caldata-rs> ; <https://github.com/lennart-k/vtimezones-rs> ;
<https://github.com/sabre-io/dav> (`LICENSE`, `composer.json`, `examples/sql/pgsql.calendars.sql`) ;
<https://github.com/sabre-io/Baikal> (`LICENSE`, `composer.json`) ;
<https://github.com/Kozea/Radicale> (`COPYING.md`, `pyproject.toml`) ;
<https://github.com/jelmer/xandikos> (`COPYING`, `pyproject.toml`) ;
<https://github.com/apple/ccs-calendarserver> (`LICENSE.txt`, `README.rst`) ;
<https://gitlab.com/davical-project/davical> (`COPYING`) ;
<https://github.com/cyrusimap/cyrus-imapd> (`COPYING`) ;
<https://github.com/Alinto/sogo> (`COPYING.GPL`) ; <https://github.com/nextcloud/server> (`COPYING`) ;
<https://github.com/messense/dav-server-rs> (`Cargo.toml`, `README.md`, `README.CalDAV.md`) ;
<https://github.com/fmeringdal/rust-rrule> (`README.md`) ; <https://github.com/hoodie/icalendar-rs>.

**Tests** : <https://github.com/apple/ccs-caldavtester> (`LICENSE.txt`, `README.md`) ;
<https://github.com/CalConnect/caldavtester> ; <https://github.com/python-caldav/caldav>
(`README.md`, `pyproject.toml`) ; <https://github.com/python-caldav/caldav-server-tester>
(`pyproject.toml`, `README.md`) ; <https://github.com/notroj/litmus> (`COPYING`, `README.md`).

**Clients** : <https://github.com/sabre-io/sabre.io> (`source/dav/building-a-caldav-client.md`,
`source/dav/clients/ical.md`, `ios.md`, `thunderbird.md`, `evolution.md`) ;
<https://manual.davx5.com/webdav_push.html> ; <https://github.com/bitfireAT/webdav-push> ;
<https://support.busymac.com/blog/112990> ; <https://discussions.apple.com/thread/250655031> ;
<https://github.com/aluxnimm/outlookcaldavsynchronizer> ;
<https://www.webdavsystem.com/server/creating_caldav_carddav/discovery/>.

**Normes** : <https://www.rfc-editor.org/rfc/rfc4918>, `rfc3744`, `rfc4791`, `rfc6638`, `rfc5545`,
`rfc7986`, `rfc6868`, `rfc7529`, `rfc5546`, `rfc6047`, `rfc6578`, `rfc6764`, `rfc5397`, `rfc5689`,
`rfc7809`, `rfc7808`, `rfc8607`, `rfc7953`, `rfc9074`, `rfc7265`, `rfc8984`, `rfc6352`, `rfc6350`,
`rfc9553`, `rfc9610` (même adresse de base) ; <https://jmap.io/spec/calendars-draft/> ;
<https://jmap.io/spec/jscalendar-draft/> ;
<https://datatracker.ietf.org/doc/draft-ietf-jmap-calendars/>.

**Dépôt Lyxal** : `Cargo.toml`, `.agents/AGENTS.md`, `lyxal_booking/README.md`,
`lyxal_booking/engine/Cargo.toml`, `lyxal_booking/engine/README.md`,
`lyxal_booking/engine/src/caldav/mod.rs`, `lyxal_booking/engine/src/rrule.rs`,
`lyxal_booking/schema/booking_calendar.surql`, `lyxal_booking/implementation_plan.md`,
`docs/AUDIT_CALRS_UPSTREAM.md`, `Lyxal_timezone/Cahier_des_charges_officiel_Lyxal_Timezone.docx`,
`crates/lyxal_scheduler/README.md` et `ROADMAP.md`, `crates/lyxal_auth/README.md`,
`crates/lyxal_notification/README.md`, `crates/lyxal_storage/README.md`,
`apps/lyxal-server/src/http/auth.rs`, `docs/14-roadmap/ROADMAP_NOYAU.md`.

---

## 11. Ce qui n'a pas pu être vérifié

* **Sites non joignables depuis cette session** : `datatracker.ietf.org`, `sabre.io`, `stalw.art`,
  `davx5.com` (et l'API GitHub). Le contenu des RFC et leur statut viennent de ma connaissance ;
  seuls les fichiers bruts de GitHub / GitLab, crates.io et les résultats de recherche ont été lus.
* **Statut exact de « JMAP for Calendars » et de JSCalendar 2.0** : les recherches du jour les
  montrent encore à l'état de brouillon (le README de Stalwart cite la révision 32), sans numéro
  de RFC trouvé ; non confirmé à la source.
* **Comportement des clients** (Apple Calendrier, Rappels, Thunderbird, DAVx⁵, Evolution,
  Outlook) : repris de documentations tierces, parfois anciennes, et de ma connaissance ; aucun
  essai réel. Le cas des Rappels Apple sur un serveur tiers est contradictoire selon les sources.
* **Origine du code de `calcard-next`** (présence ou non d'apports postérieurs au passage sous
  AGPL) : non auditée.
* **Qualité réelle des bibliothèques** (`icalendar`, `rrule`, `calcard`, `mailrs-*`) sur des
  fichiers d'agenda réels, et couverture exacte de `dav-server` (présence de `sync-collection`) :
  lues dans leurs README seulement ; rien n'a été compilé ni exécuté.
* **Stockage et maturité** de DAViCal, Cyrus, SOGo, du serveur d'Apple ; version courante de
  Cyrus ; date des dernières versions de DAViCal et de Xandikos ; langage exact (Python 2) de
  CalDAVTester : connaissance générale.
* **Multi-location de Stalwart réservée à l'édition Entreprise** : d'après son README seulement.
* **`lyxal_notification`** : absence de pièces jointes et de réception d'e-mails constatée par
  recherche de mots dans son README, pas par lecture du code.
* **Efforts en lots** : estimations personnelles, non étayées par un chiffrage.
