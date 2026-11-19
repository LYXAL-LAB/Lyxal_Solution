# Plan d'implémentation — programme courrier, agendas et contacts (`lyxal_mail`, `lyxal_calendar`, `lyxal_contacts`)

Création, dans le Noyau Technique, d'un **serveur de courrier complet** et d'un **serveur
CalDAV / CardDAV complet**, portés de projets open source existants et adaptés à Lyxal OS et à
SurrealDB. Études de sources (18 novembre 2026), versées au lot 0 :
`crates/lyxal_mail/RECHERCHE_SOURCES.md` (courrier, Proton, mesures de SurrealDB) et
`crates/lyxal_calendar/RECHERCHE_SOURCES.md` (agendas et contacts). Les mesures de ce plan
ont été faites sur les clones locaux, en lecture seule, sans rien compiler ni exécuter (§3.1).

**Deux niveaux de validation** (`AGENTS.md` §3) : ce plan fixe le programme (architecture,
sources, lots, décisions). Chaque lot a ensuite son propre plan détaillé, soumis au CTO avant
toute ligne de code : contrats Rust `XxxParams` / `XxxResult`, signatures SurrealQL, codes
d'erreurs, fonctions `lyxal_core` réutilisées, fichiers sources portés, tests.

## 1. Contexte et décisions déjà prises

Décisions du CTO, appliquées telles quelles dans ce plan (elles ne sont pas rouvertes) :

| N° | Décision prise |
| :- | :--- |
| **F1** | **Cible** : un crate de courrier et un crate CalDAV aussi complets que l'existant (niveau Stalwart). Courrier : SMTP entrant et sortant, IMAP, JMAP, POP3 si peu coûteux, Sieve et ManageSieve, anti-spam, DKIM / SPF / DMARC / ARC, MTA-STS / DANE / TLS-RPT, boîtes aux lettres. Agendas : CalDAV avec tâches, partage, planification iTIP / iMIP, disponibilités ; contacts CardDAV ; socle WebDAV. |
| **F2** | **Méthode** : ne pas inventer ; partir de projets open source existants, **quelle que soit leur licence** (AGPL et GPL comprises : Stalwart, RustiCal, Mox, sabre/dav, Postal, Radicale…), en les adaptant à Lyxal OS et à SurrealDB. Le CTO traite lui-même les conséquences de licence, plus tard. Les recommandations contraires des deux études (« s'inspirer seulement ») sont donc caduques. |
| **F3** | Le dossier `lyxal_booking/` (racine du dépôt) **n'est pas touché**. |
| **F4** | **Garde-fou 1 — provenance et licence.** Chaque crate et chaque partie portée enregistre son projet source, sa version ou son commit et sa licence. Un crate dérivé de code AGPL ou GPL déclare cette licence dans son propre `Cargo.toml` (pas la licence `MIT OR Apache-2.0` du workspace) et dans un `SOURCES.md`, pour que le CTO sache exactement ce qui est concerné. |
| **F5** | **Garde-fou 2 — code non libre de Stalwart.** Les fichiers et extraits de Stalwart marqués `LicenseRef-SEL` seul (licence Entreprise propriétaire) ne sont jamais utilisés. Les fonctions correspondantes (multi-organisations, etc.) viennent d'autres projets ou sont écrites pour Lyxal. |

## 2. Point de départ

| Élément | État constaté |
| :--- | :--- |
| Courrier dans Lyxal OS | `lyxal_notification` **envoie** par un relais SMTP ou une API de fournisseur (`lettre`). Aucune réception, aucune boîte aux lettres. « Courrier entrant » est le point 3 des « Points à décider » de sa feuille de route. |
| Agendas dans Lyxal OS | Aucun serveur. `lyxal_scheduler` a des calendriers d'**exceptions** (jours fériés), pas des agendas. `lyxal_booking/` contient un client CalDAV ; il reste hors programme (F3). |
| Briques du noyau à réutiliser | `lyxal_auth` (identités, organisations, permissions, clés d'API, sessions), `lyxal_storage` (octets en flux, quotas, antivirus `clamd`), `lyxal_secrets` (coffre-fort, rotation), `lyxal_scheduler` (tâches périodiques et différées), `lyxal_event`, `lyxal_runtime` (modules, workers supervisés, baux, santé), `lyxal_crypto`, `lyxal_parsing` (`quick-xml` 0.42), `lyxal_i18n`. |
| Manques connus | Pas de mot de passe d'application (`lyxal_auth` échange une clé d'API contre un jeton, alors que les logiciels de courrier et d'agenda envoient identifiant et mot de passe à chaque connexion). `lyxal_crypto` signe (ES256, RS256) mais **ne vérifie aucune signature asymétrique** ; Ed25519 est « hors scope » (§11.3). L'hôte `lyxal-server` n'écoute qu'en HTTP (axum 0.7), derrière un proxy pour TLS. |
| Taille du dépôt aujourd'hui | Crates : environ 103 000 lignes de Rust et 107 000 de SurrealQL ; hôte : 20 800 lignes de Rust (tests compris). |

## 3. Sources

### 3.1. Mesures faites sur les clones

Méthode : `find <dossier> -name '*.rs' | xargs cat | wc -l` (lignes brutes : commentaires, lignes
vides et tests compris) ; licence d'un fichier = première ligne `SPDX-License-Identifier` ;
extraits propriétaires = lignes `SPDX-License-Identifier: LicenseRef-SEL` placées plus bas dans
un fichier à double licence (blocs `SPDX-SnippetBegin` … `SPDX-SnippetEnd`).

**Stalwart**, commit `3adead9` (16 nov. 2026), 36 crates, 639 860 lignes de Rust.
`Cargo.toml` des crates : `AGPL-3.0-only OR LicenseRef-SEL`.

| Crate Stalwart | Rôle | Fichiers | Lignes | Fichiers SEL seul | Fichiers avec extraits SEL |
| :--- | :--- | -: | -: | -: | -: |
| `smtp-proto` | syntaxe SMTP / LMTP | 9 | 4 393 | 0 | 0 |
| `smtp` | sessions entrantes (7 378), sortantes (5 584), file (5 701), rapports (4 041) | 66 | 24 575 | 1 (`queue/tenant.rs`) | 6 |
| `smtp-report` | formats des rapports DMARC et TLS | 14 | 3 891 | 0 | 0 |
| `imap-proto` / `imap` | syntaxe / serveur IMAP | 51 / 43 | 8 771 / 14 373 | 0 / 0 | 0 / 3 |
| `pop3`, `managesieve` | serveurs POP3 et ManageSieve | 13, 17 | 2 091, 2 008 | 0 | 0, 1 |
| `sieve` | interprète Sieve | 100 | 24 113 | 0 | 0 |
| `email` | boîtes, messages (10 177), fils, dépôt | 51 | 15 391 | 0 | 8 |
| `jmap-proto` / `jmap` | types / serveur JMAP (courrier, agendas, contacts, fichiers) | 60 / 154 | 18 035 / 54 455 | 0 / 2 | 1 / 20 |
| `spam-filter`, `nlp` | règles anti-spam, classement bayésien | 36, 24 | 11 143, 8 278 | 5 (dossier `analysis/ai`) / 0 | 2 / 0 |
| `text-extract` | texte des pièces jointes (recherche) | 117 | 22 762 | 0 | 0 |
| `dav-proto` / `dav` | XML WebDAV / serveur (agendas 7 074, contacts 3 314, commun 7 034, fichiers 2 772) | 28 / 49 | 8 894 / 22 111 | 0 / 0 | 0 / 8 |
| `groupware` | données agendas (15 409), planification iTIP (6 314), contacts (1 203) | 49 | 25 975 | 0 | 2 |
| `calcard` | iCalendar, vCard, JSCalendar, JSContact (sur `jiff`) | 74 | 43 166 | 0 | 0 |
| `directory` | annuaires (LDAP, OIDC, SQL) | 20 | 4 009 | 0 | 2 |
| `crypto` | OpenPGP, S/MIME, X.509 | 47 | 9 696 | 0 | 0 |
| `common` | colle : configuration, écoute réseau (9 317, dont ACME 2 325), authentification, caches | 233 | 68 124 | 20 (dossier `enterprise`, télémétrie) | 38 |
| `store` | stockage clé-valeur et ses moteurs | 132 | 39 725 | 4 (`backend/composite`) | 22 |
| `services`, `http` | tâches de fond, API HTTP | 42, 17 | 14 667, 6 864 | 0, 1 | 15, 5 |
| `registry` | schéma de configuration (surtout généré) | 37 | 128 385 | 0 | 11 |
| `scim`, `scim-proto` | SCIM | 17, 16 | 4 565, 4 024 | **17, 16 (tout)** | — |

Total : 66 fichiers `.rs` entièrement propriétaires et 2 070 extraits propriétaires répartis dans
151 fichiers à double licence. Ce que couvrent ces parties (mots relevés à côté des marqueurs) :
**organisations multiples (`tenant`) et leurs quotas**, licence et marque, IA (anti-spam et
modèles), télémétrie et alertes, réplicas et répartition du stockage, restauration des éléments
supprimés, SCIM. Correction de l'étude courrier : elle parlait de « 1 447 fichiers » propriétaires
dans `registry` ; ce sont des extraits dans 11 fichiers, pas des fichiers.

Autres constats : aucun dossier de tests à la racine du clone (l'étude indique que les tests
sont privés depuis la 1.0.0) ; `sieve`, `smtp-proto`, `smtp-report`, `nlp`, `text-extract`,
`crypto` ne dépendent d'aucun autre crate interne ; `imap-proto`, `dav-proto`, `calcard`,
`jmap-proto` dépendent seulement de petits crates utilitaires (`trc`, `types`, `utils`,
`jmap-tools`, `registry` pour `jmap-proto`) ; tous les crates « serveur » dépendent de `common`,
`store` et `registry`.

**Le stockage de Stalwart** n'est pas une interface à implémenter table par table : c'est un
magasin **clé-valeur ordonné** (`enum Store`), découpé en 26 sous-espaces d'un octet, avec ces
opérations : lire une valeur, tester une clé, parcourir un intervalle de clés dans l'ordre,
lire un compteur, écrire un lot atomique (avec conditions et compteurs), supprimer un
intervalle, purger ; plus lire / écrire / supprimer un blob. Un moteur existant fait de 1 120
(SQLite) à 4 855 lignes (PostgreSQL). Les crates serveur appellent ce magasin directement
(fichiers concernés : `jmap` 52, `email` 27, `dav` 24, `groupware` 16, `smtp` 14, `imap` 10).
Conséquence : décision P4.

**Mox**, commit `b32f0de` (27 oct. 2026), Go, licence MIT (`LICENSE.MIT` ; la liste des suffixes
publics est sous MPL-2.0) : 97 886 lignes hors `vendor/` et hors tests, 29 643 lignes de tests.
Principaux paquets : `imapserver` 10 818, `store` 8 107, `smtpserver` 5 813, `webmail` 5 758,
`queue` 4 807, `message` 2 903, `dkim` 2 051, `smtpclient` 2 012, `spf` 1 560, `junk` 1 302,
`dmarcdb` 1 273, `tlsrpt` 875, `dmarc` 798, `scram` 796, `dsn` 771, `mtasts` 703, `dane` 516,
`autotls` 489. Il contient un `Dockerfile.imaptest` (banc IMAP).

**RustiCal**, commit `0698bb6` (18 nov. 2026), version 0.19.1, `AGPL-3.0-or-later` : 24 611
lignes de Rust (`caldav` 3 903, `carddav` 2 588, `dav` 2 760, `xml` 3 030, `store` 1 121,
`store_sqlite` 4 378, `dav_push` 753, `oidc` 439, `frontend` 1 212). Stockage derrière des
traits (`CalendarStore`, `AddressbookStore`, `AuthenticationProvider`). Aucun fichier ne
mentionne `schedule-inbox` ni iTIP : **pas de planification**. Dépend de `caldata` et
`vtimezones-rs` (GPL-3.0-or-later d'après l'étude).

**sabre/dav**, commit `be1d58d` (1er nov. 2026), PHP, BSD-3-Clause : `lib/DAV` 14 428 lignes,
`lib/CalDAV` 11 365, `lib/DAVACL` 4 589, `lib/CardDAV` 3 371 ; tests 35 714 lignes ; schémas SQL
dans `examples/sql/`.

Bibliothèques (clones) : `mail-parser` 33 090 lignes, `mail-auth` 37 627, `mail-builder` 5 774,
`mail-send` 2 294, `smtp-proto` 0.2.5 6 174 (toutes `Apache-2.0 OR MIT`) ; `sieve-rs` 17 942
(`AGPL-3.0-only`) ; `calcard` 0.3.14 34 421 (`Apache-2.0 OR MIT`, archivé).

### 3.2. Carte des sources par bloc

« Porté » = code repris et adapté ; « modèle » = fonctionnement repris, code réécrit pour
SurrealDB. Les tailles sont celles de la source (§3.1), pas du résultat.

| Bloc | Source principale (licence) | Taille source | Compléments | Exclu car SEL seul |
| :--- | :--- | -: | :--- | :--- |
| Lecture / écriture des messages, SPF, DKIM, DMARC, ARC | `mail-parser`, `mail-builder`, `mail-auth` (Apache-2.0 OR MIT), en dépendances | 76 500 | Mox `dkim`, `spf`, `dmarc` (MIT) | — |
| Syntaxe SMTP, IMAP ; interprète Sieve ; formats de rapports | Stalwart `smtp-proto`, `imap-proto`, `sieve`, `smtp-report` (AGPL) — portés | 41 200 | — | rien |
| Écoute réseau, TLS, limites, DNS | Stalwart `common/network` (AGPL) — porté en partie | 9 300 | Mox `autotls`, `ratelimit` | extraits `tenant` |
| Réception SMTP | Stalwart `smtp/inbound` (AGPL) — porté | 7 400 | Mox `smtpserver` (MIT) ; Postal (routes) | extraits `tenant` |
| File, envoi, avis de non-remise | Stalwart `smtp/queue`, `smtp/outbound` (AGPL) — porté, stockage réécrit | 11 300 | Mox `queue`, `smtpclient`, `dsn` ; KumoMTA (limitation par destination, Apache-2.0) | `queue/tenant.rs` (quotas par organisation) |
| MTA-STS, DANE, TLS-RPT, rapports DMARC | Stalwart `smtp/outbound/{mta_sts,dane}`, `smtp/reporting` (AGPL) | 4 000 + | Mox `mtasts`, `dane`, `tlsrpt`, `dmarcdb` | rien |
| Boîtes, messages, fils de discussion | Stalwart `email` (AGPL) — **modèle**, réécrit en SurrealQL | 15 400 | Mox `store` (modèle relationnel, MIT) | extraits `tenant`, quotas |
| IMAP, POP3, ManageSieve | Stalwart `imap`, `pop3`, `managesieve` (AGPL) — portés, accès aux données réécrit | 18 500 | Mox `imapserver` et son banc | extraits `tenant` |
| Anti-spam | Stalwart `spam-filter`, `nlp` (AGPL) — portés | 18 400 | Mox `junk` (réputation) | `analysis/ai` (1 000 lignes) |
| Recherche plein texte | Stalwart `text-extract` (AGPL) — porté ; index : SurrealDB (à mesurer) ou Stalwart `store/search` (4 364) | 22 800 | — | rien |
| JMAP (cœur, courrier) | Stalwart `jmap-proto`, `jmap` hors agendas / contacts / fichiers / `registry` (AGPL) | ≈ 42 000 | — | `registry/mapping/{archived_item,telemetry}.rs`, extraits |
| iCalendar, vCard | Stalwart `calcard` dans le serveur (AGPL, sur `jiff`) — porté tel quel | 43 200 | `calcard` 0.3.14 (Apache-2.0 OR MIT) si P5 le préfère | rien |
| WebDAV (XML, propriétés, droits, synchronisation) | Stalwart `dav-proto`, `dav/common`, `dav/principal` (AGPL) — porté | 16 700 | RustiCal `dav`, `xml` (AGPL) ; sabre/dav `DAV`, `DAVACL` (BSD) | extraits `tenant` |
| CalDAV, tâches, partage, disponibilités | Stalwart `dav/calendar`, `groupware/calendar` (AGPL) — données réécrites en SurrealQL | 22 500 | sabre/dav (modèle SQL et tests) ; RustiCal (découpage par traits, jetons d'application, WebDAV-Push) | extraits `tenant` |
| Planification iTIP / iMIP | Stalwart `groupware/scheduling`, `dav/calendar/scheduling.rs` (AGPL) | 6 300 + | sabre/dav `CalDAV/Schedule` | rien |
| CardDAV | Stalwart `dav/card`, `groupware/contact` (AGPL) | 4 500 | RustiCal `carddav` ; sabre/dav `CardDAV` | rien |
| Organisations multiples, quotas par organisation | **Écrit pour Lyxal** sur `lyxal_auth` et `lyxal_storage` | — | Mox (comptes et domaines), sabre/dav (principals) | tout le code `tenant` de Stalwart |
| Annuaire, SCIM, télémétrie, grappe, IA | `lyxal_auth` et l'existant Lyxal ; SCIM, IA, réplicas : hors programme | — | — | `scim`, `scim-proto`, `common/enterprise`, `store/backend/composite` |

**Application de F5** : `scripts/sources/strip_sel.py` (lot 0) produit une copie de travail de
Stalwart **sans** les 66 fichiers propriétaires ni les extraits propriétaires (2 067 dans les
fichiers gardés, 3 dans un fichier lui-même supprimé) ; seule cette copie sert de source. Le
script de l'éditeur `resources/scripts/ossify.py`, lu au lot 0, fait le même tri : ses règles
donnent le même résultat fichier par fichier (rapport dans `crates/lyxal_mail/SOURCES.md`). La
version sans la fonctionnalité Cargo `enterprise` est la version libre prévue par l'éditeur.

## 4. Architecture

### 4.1. Crates

| Crate | Nature | Contenu | Licence déclarée (F4) |
| :--- | :--- | :--- | :--- |
| `lyxal_mail_proto` | Rust pur, sans base (comme `lyxal_parsing`) | Syntaxes SMTP, IMAP, POP3, ManageSieve ; interprète Sieve ; formats des rapports ; types JMAP | `AGPL-3.0-only` (porté de Stalwart) |
| `lyxal_mail` | Module (SurrealQL + Rust) | Domaines, adresses, boîtes, messages, files, droits ; serveurs SMTP, IMAP, POP3, ManageSieve ; anti-spam ; JMAP courrier | `AGPL-3.0-only` |
| `lyxal_dav` | Rust pur, sans base | XML WebDAV / CalDAV / CardDAV, réponses `207`, préconditions, jetons de synchronisation ; iCalendar et vCard (`calcard`) | `AGPL-3.0-only` |
| `lyxal_calendar` | Module | Agendas, événements, tâches, partage, disponibilités, planification ; CalDAV | `AGPL-3.0-only` |
| `lyxal_contacts` | Module | Carnets d'adresses, contacts ; CardDAV | `AGPL-3.0-only` |
| `apps/lyxal-groupware` | Hôte (binaire) | Ports du courrier, HTTP du DAV et de JMAP (P3) | `AGPL-3.0-only` |

Pourquoi plusieurs crates : (1) les crates « Rust pur » se portent presque tels quels et se
testent sans base ; (2) `lyxal_contacts` réutilise `lyxal_dav` sans dépendre des agendas ;
(3) une responsabilité, un propriétaire (§5.1) : un carnet d'adresses n'est pas un agenda ;
(4) la provenance se suit crate par crate. L'anti-spam et JMAP restent dans `lyxal_mail` ; un
plan de lot pourra demander de les séparer si la taille l'impose.

**Règle de provenance proposée** : aucun crate existant (`lyxal_crypto`, `lyxal_auth`,
`lyxal_core`, `lyxal_runtime`…) ne reçoit de code porté d'une source AGPL ou GPL. Leurs
évolutions (P6, P8) viennent de sources permissives (`mail-auth`, `ring`, Mox) ou sont écrites
pour Lyxal. Ainsi, seuls les six éléments ci-dessus sont concernés par F4.

### 4.2. Place dans la hiérarchie (§6) et dépendances

Noyau Technique, après `lyxal_notification` : ce sont des services transversaux (courrier et
agendas des identités et des organisations) que des modules métiers consommeront.

```text
lyxal_core · lyxal_error · lyxal_surreal · lyxal_crypto · lyxal_parsing · lyxal_event · lyxal_runtime
lyxal_auth · lyxal_i18n · lyxal_storage · lyxal_secrets · lyxal_scheduler
        ▲
lyxal_mail_proto ──► lyxal_mail          lyxal_dav ──► lyxal_contacts
                          ▲                   │
                          └──── lyxal_calendar ◄┘      (lyxal_calendar dépend de lyxal_dav et de lyxal_mail)
        ▲
apps/lyxal-groupware        lyxal_notification (consommateur par événements, sans lien Cargo)
```

| Relation | Règle |
| :--- | :--- |
| `lyxal_auth` | Identités, organisations, permissions `mail.*`, `calendar.*`, `contacts.*` ; mots de passe d'application (P8). Les modules ne refont aucune authentification. |
| `lyxal_storage` | Octets des messages (`.eml`) et des pièces jointes, quotas, antivirus. Les tables gardent une référence et des métadonnées, jamais les octets. |
| `lyxal_secrets` | Clés DKIM privées, clé du compte ACME, clés privées TLS, secrets des adresses signées. Rotation DKIM par son mécanisme de rotation. |
| `lyxal_scheduler` | Tâches périodiques déclarées par les modules : purges, rapports DMARC et TLS, renouvellement des certificats, apprentissage anti-spam, rappels d'agenda. La **file d'envoi** du courrier a sa propre table et ses workers (débit et ordre par destination), comme la file de `lyxal_notification` ; à confirmer au plan du lot 6. |
| `lyxal_event` | `mail.message.received`, `mail.message.delivered`, `mail.message.bounced`, `mail.complaint.received`, `mail.quota.exceeded`, `calendar.object.changed`, `calendar.invitation.received`, `calendar.alarm.due`, `contacts.card.changed`… (liste arrêtée par lot). |
| `lyxal_notification` | **Consommateur** : s'abonne aux événements `mail.*` (rejets, plaintes → liste de suppression ; réponse à un e-mail) et `calendar.alarm.due`. **Client** facultatif : une intégration « serveur de courrier Lyxal » qui dépose ses messages par la fonction publique SurrealQL de dépôt de `lyxal_mail`, sans dépendance Cargo. `lyxal_mail` ne connaît jamais `lyxal_notification`. |
| `lyxal_calendar` → `lyxal_mail` | Invitations par e-mail : envoi par le contrat public de dépôt de `lyxal_mail` ; réception en s'abonnant à `mail.message.received` (pièce `text/calendar`). `lyxal_mail` ne connaît pas les agendas. |

Aucun cycle : aucun crate existant ne dépend des nouveaux ; `lyxal_mail` et `lyxal_dav` ne
dépendent d'aucun des trois autres nouveaux modules.

### 4.3. Écoute des protocoles (P3)

Proposition : un **hôte dédié** `apps/lyxal-groupware`, bâti comme `lyxal-server` (même
`LyxalRuntime`, même base, mêmes contrats §5.8), qui embarque et installe les cinq crates et
écoute : SMTP 25, dépôt 587 / 465, IMAP 143 / 993, POP3 110 / 995, ManageSieve 4190, et un
port HTTP pour CalDAV, CardDAV, JMAP, la découverte (`/.well-known/…`), la politique MTA-STS et
les défis ACME. Chaque écoute est un `LyxalWorker` supervisé (§5.8.3). `lyxal-server` reste
inchangé ; le proxy inverse envoie `/dav`, `/jmap` et `/.well-known/{caldav,carddav,jmap}` vers
le nouvel hôte.

Raisons : (1) **sécurité** — des ports attaqués en permanence sont isolés de l'API de la
plateforme (une saturation mémoire ou un plantage n'arrête pas `lyxal-server`), avec leurs
propres limites et droits système ; (2) **exploitation** — on peut ne pas déployer le courrier,
ou le placer sur une machine qui a le port 25 ouvert ; (3) **licence** — le binaire qui lie du
code dérivé d'AGPL est distinct, `lyxal-server` ne lie aucun des nouveaux crates (P2).
Essai du lot 0 (tests `two_hosts_shared_database_tests` de `lyxal_runtime`) : deux hôtes à
jeux de modules différents s'installent sous bail, démarrent, se réconcilient, redémarrent et
s'arrêtent sur une même base sans effet l'un sur l'autre. **Le moteur d'événements ne le permet
pas encore** : un seul `EventWorker` est élu pour toute la base et ne sert que les handlers de
son hôte ; les événements destinés aux handlers de l'autre hôte finissent en dead letter (ou
restent en attente si les hôtes ont des `instance_id` différents). Le correctif du runtime et de
`lyxal_event` a son propre plan, à valider avant le lot 3. Non essayé : les exécuteurs de
`lyxal_scheduler` sur deux hôtes (d'après le code, un exécuteur qui réserve une tâche dont le
handler est inscrit sur l'autre hôte la fait échouer avec `SCHEDULER_HANDLER_NOT_FOUND`).

### 4.4. Données et répartition SurrealQL / Rust

| SurrealQL (données et règles) | Rust (protocoles, analyse, système) |
| :--- | :--- |
| Domaines, adresses, alias, listes, boîtes, messages (métadonnées, drapeaux, UID, MODSEQ, fils), quotas, file d'envoi et états, règles d'acceptation d'un destinataire, scripts Sieve (stockage, activation), verdicts, journal des changements | Sessions SMTP / IMAP / POP3 / ManageSieve, TLS, DNS, lecture MIME, exécution Sieve, calcul des scores anti-spam, signature et vérification (par `lyxal_crypto`), envoi vers les MX |
| Agendas, vues par utilisateur, objets (texte reçu conservé tel quel + projections indexées), journal de synchronisation, partages, boîtes de planification, carnets et contacts | XML DAV, iCalendar / vCard, développement des récurrences (borné), fuseaux (`jiff`), machine d'états iTIP, calcul final des plages occupées |
| Droits par organisation (`fn::auth_has_permission`, permissions de table), entrées par `lyxal_core` (§5.7.8), erreurs `MAIL_*`, `CALENDAR_*`, `CONTACTS_*`, écritures vérifiées (`*_WRITE_FORBIDDEN`) | Wrappers `store.call_fn(...)` 1 ligne (§5.4) ; aucune requête libre |

Préfixes de tables : `mail_`, `calendar_`, `contacts_`. Une migration `0001_initial.surql` par
module, réécrite en place (§0). Versions `0.1.0`.

**Voie de portage du stockage (P4).** Deux voies existent ; la proposition est la seconde.

| Voie | Principe | Pour | Contre |
| :--- | :--- | :--- | :--- |
| A — moteur clé-valeur | Écrire un moteur SurrealDB pour le magasin de Stalwart (clés et valeurs opaques) | Le plus court ; code serveur de Stalwart presque inchangé | Données illisibles en SurrealQL ; ni règles en SurrealQL ni permissions de table : contraire à la philosophie §10 et à §5.3 ; SurrealDB comme magasin d'intervalles ordonnés non mesuré |
| **B — modèle SurrealQL** | Tables et fonctions `fn::mail_*`, `fn::calendar_*`, `fn::contacts_*` ; les couches de protocole sont portées, les accès aux données sont réécrits sur le modèle de Stalwart, Mox et sabre/dav | Conforme aux règles ; données interrogeables, droits par organisation natifs | Nettement plus long (≈ 140 fichiers de Stalwart touchent le magasin) ; le suivi des versions de Stalwart devient manuel |

### 4.5. Isolation par organisation

Le code d'organisations multiples de Stalwart est propriétaire (§3.1) : il n'est pas utilisé.
Dans Lyxal : chaque domaine de courrier appartient à une organisation ; chaque table porte
l'organisation et des permissions par organisation, comme les autres modules ; un compte de
courrier ou d'agenda est une identité `lyxal_auth` dans une organisation ; adresses DAV de la
forme `/dav/<organisation>/…` ; quotas par organisation tenus par `lyxal_storage` ; une clé DKIM
par domaine ; données d'une organisation supprimées avec elle. Le courrier entre deux
organisations de la même installation passe par la file, comme un envoi extérieur.

## 5. Lots

Tailles : relatives aux lots passés du dépôt (moyennes mesurées en lignes Rust + SurrealQL par
lot, tests compris : `lyxal_storage` 1 100, `lyxal_secrets` 2 900, `lyxal_scheduler` 3 200,
`lyxal_auth` 3 200, `lyxal_notification` 4 800). **S** : moins de 3 000 lignes ; **M** : 3 000 à
6 000 (lot habituel) ; **L** : 6 000 à 12 000 ; **XL** : plus de 12 000. Ce sont des
estimations. Les numéros de RFC viennent des deux études ou de mémoire : à revérifier dans
chaque plan de lot. **Chaque lot est utilisable et fusionnable seul, et a son plan détaillé
validé par le CTO avant tout code.**

| Lot | Contenu | Normes | Source | Touche | Prérequis | Taille | Risque principal |
| :- | :--- | :--- | :--- | :--- | :--- | :-: | :--- |
| **0. Cadre** | `SOURCES.md` et licences par crate, commits figés, copie de Stalwart sans SEL, contrôle des licences de l'arbre des dépendances, inscription « à créer » (`AGENTS.md` §6, `ROADMAP_NOYAU.md`) ; **mesures** : boîte de 100 000 à 1 000 000 de messages dans SurrealDB (liste, synchronisation, recherche), deux hôtes sur une base | — | — | docs, scripts ; essais hors dépôt | P1 à P4 | S | Les mesures peuvent imposer de revoir P4 |
| **1. Mots de passe d'application** | Mot de passe par appareil, révocable, limité à des permissions ; vérification à chaque connexion sans Argon2 complet ; limitation des essais | — | Écrit pour Lyxal (modèle : jetons d'application de RustiCal, Mox) | `lyxal_auth`, `lyxal-server` | P8 | S | Contournement du double facteur à borner |
| **2. Crypto, vague 1** | TLS côté serveur, vérification RSA et Ed25519, vérification et signature DKIM, génération de clés ; **chiffrement de fichiers en flux** (niveau A du chiffrement des boîtes, P15) | 6376, 8301, 8463 | `mail-auth`, `ring` ; Mox `dkim` ; chiffrement en flux écrit pour Lyxal | `lyxal_crypto` | P6 | M | Nouvelles crates crypto ; API figée à étendre ; format de chiffrement en flux à définir |
| **3. Hôte et socle réseau** | `apps/lyxal-groupware`, écoutes supervisées, TLS (certificat fourni), limites par IP, délais, budget mémoire, DNS, configuration, santé | 3207, 8314 | Stalwart `common/network` ; Mox | hôte, `lyxal_mail` (squelette) | 0, 2 ; correctif du moteur d'événements pour deux hôtes (§4.3) | M | Deux hôtes sur une base |
| **4. Socle courrier** | `lyxal_mail_proto` (lecture MIME par `mail-parser`) ; `lyxal_mail` : domaines, adresses, alias, boîtes, messages, quotas, droits, erreurs, événements, banc ; **contenu des messages et des pièces jointes chiffré au repos** (niveau A, clés de la plateforme par organisation) ; drapeau « chiffré » réservé sur les messages (niveaux B et C) | 5322, 2045-2049 | Stalwart `email` (modèle), Mox `store` | `lyxal_mail_proto`, `lyxal_mail`, `lyxal_storage` | 0, 2 | L | Modèle des boîtes (UID, MODSEQ, fils) à figer tôt |
| **5. Réception SMTP** | Serveur SMTP entrant, refus dès `RCPT TO`, SPF / DKIM / DMARC, en-tête `Authentication-Results`, antivirus, remise en boîte dans l'ordre fixe antivirus → anti-spam → filtres → index → chiffrement (étapes posées même si vides), événement `mail.message.received` | 5321, 1870, 2920, 6152, 6531, 3463, 7208, 7489, 8601 | Stalwart `smtp-proto`, `smtp/inbound` ; Mox `smtpserver` | `lyxal_mail*`, hôte | 2, 3, 4 | L | Port 25 exposé ; attaques sur les fins de ligne |
| **6. Envoi** | File par destination, tentatives, envoi vers les MX, dépôt authentifié (587 / 465), signature DKIM, avis de non-remise, adresses de retour signées, contrat public de dépôt | 5321 (client), 6409, 4954, 3461, 3464, 8058 | Stalwart `smtp/queue`, `smtp/outbound` ; Mox `queue`, `smtpclient`, `dsn` ; KumoMTA | `lyxal_mail*`, hôte | 1, 5 | XL | Délivrabilité ; relais ouvert ; pertes de messages |
| **7. Transport sûr et rapports** | MTA-STS, DANE, TLS-RPT, rapports DMARC reçus et émis, ARC | 8461, 7672, 6698, 8460, 7489, 8617 | Stalwart `smtp/reporting`, `smtp-report`, `outbound/{dane,mta_sts}` ; Mox | `lyxal_mail*`, `lyxal_crypto` | 6, P6 | L | DNSSEC ; vérificateur de certificat sur mesure |
| **8. IMAP** | IMAP4rev2 et rev1, extensions (IDLE, CONDSTORE, QRESYNC, MOVE, UIDPLUS, SPECIAL-USE, QUOTA, ACL…) | 9051, 3501, 2177, 7162, 6851… | Stalwart `imap-proto`, `imap` ; Mox `imapserver` | `lyxal_mail*`, hôte | 1, 4 | XL | Compatibilité Outlook, Apple Mail, Thunderbird ; performances |
| **9. Recherche et POP3** | Texte des pièces jointes, index plein texte, recherche IMAP ; POP3 | 1939, 2449 | Stalwart `text-extract`, `pop3`, `store/search` | `lyxal_mail*` | 8 | L | Recherche plein texte de SurrealDB non mesurée |
| **10. Sieve** | Filtres Sieve, ManageSieve, réponse d'absence, filtres à la réception | 5228 et extensions, 5804, 5230 | Stalwart `sieve`, `managesieve`, `email/sieve` | `lyxal_mail*`, hôte | 5, 8 | L | Bac à sable des scripts (boucles, envois) |
| **11. Anti-spam** | Règles, listes DNS, classement bayésien et apprentissage, réputation, quarantaine | — | Stalwart `spam-filter` (hors `ai`), `nlp` ; Mox `junk` | `lyxal_mail` | 5 | XL | Faux positifs ; réglages à l'usage |
| **12. JMAP courrier** | Cœur JMAP, courrier, dépôt, identités, fils, push, WebSocket, blobs, quotas, Sieve | 8620, 8621, 8887 | Stalwart `jmap-proto`, `jmap` | `lyxal_mail*`, hôte | 6, 8 | XL | Volume ; états et synchronisation |
| **12 bis. Chiffrement à la remise** (optionnel) | Niveau B du chiffrement des boîtes : chaque message est chiffré à la remise par la clé publique OpenPGP de l'utilisateur (le serveur ne peut plus le relire ; les logiciels classiques déchiffrent) ; dépôt et contrôle de la clé publique ; activable par compte ; courrier seulement | 9580, 3156 | `rpgp` (MIT / Apache-2.0), derrière `lyxal_crypto` | `lyxal_crypto`, `lyxal_mail` | 12, P6 | L | Recherche, aperçu et apprentissage anti-spam perdus pour les comptes chiffrés ; clé perdue, courrier perdu |
| **13. Administration du courrier** | Routes HTTP (domaines, clés DKIM et rotation, contrôle des enregistrements DNS, file, quarantaine), certificats automatiques, configuration automatique des logiciels | 8555, 6186 | Stalwart `common/network/{acme,autoconfig}` ; Mox `autotls`, `webadmin` (modèle) | `lyxal_mail`, hôte, `lyxal_crypto` | 6, P6 | M | ACME : extension crypto |
| **14. Formats agenda et contact** | `lyxal_dav` : iCalendar, vCard, récurrences bornées, fuseaux | 5545, 7986, 6868, 6350, 2426 | Stalwart `calcard` | `lyxal_dav` | 0 | M | Tolérance aux fichiers hors norme |
| **15. Socle WebDAV** | XML, propriétés, `PROPFIND` / `REPORT`, principals, droits, synchronisation par jeton, découverte, méthodes DAV dans l'hôte | 4918, 3253, 3744, 5397, 6578, 5689, 6764 | Stalwart `dav-proto`, `dav/common` ; RustiCal `dav`, `xml` ; sabre/dav | `lyxal_dav`, hôte | 1, 3, 14 | L | XML hostile ; particularités des clients |
| **16. CalDAV** | `lyxal_calendar` : agendas, événements, recherche par période, lecture groupée, propriétés Apple, restitution à l'octet près ; chiffrement au repos (niveau A) | 4791, 7809 | Stalwart `dav/calendar`, `groupware/calendar` ; sabre/dav (modèle SQL, tests) | `lyxal_calendar`, hôte | 15 | XL | Récurrences ; clients Apple non documentés |
| **17. Tâches, partage, disponibilités** | `VTODO`, `VJOURNAL`, partage lecture / écriture, délégation, `free-busy-query`, alarmes et rappels | 3744, 9074, 7953 | idem ; RustiCal (partage par groupes) | `lyxal_calendar` | 16 | L | Extensions de partage hors RFC |
| **18. Planification** | Boîtes `schedule-inbox` / `-outbox`, invitations internes, invitations par e-mail (envoi et réception), réponses, contre-propositions | 5546, 6638, 6047 | Stalwart `groupware/scheduling` ; sabre/dav `Schedule` | `lyxal_calendar` | 5, 6, 17 | XL | Usurpation d'organisateur ; exceptions de récurrence |
| **19. CardDAV** | `lyxal_contacts` : carnets, contacts, recherche, synchronisation, partage ; chiffrement au repos (niveau A) | 6352 | Stalwart `dav/card`, `groupware/contact` ; RustiCal `carddav` | `lyxal_contacts`, hôte | 15 | L | vCard 3 et 4 mêlées |
| **20. JMAP agendas et contacts** | JSCalendar, JSContact, méthodes JMAP correspondantes | 8984, 9553, 9610 ; brouillon « JMAP for Calendars » | Stalwart `jmap` (agendas, contacts) | `lyxal_calendar`, `lyxal_contacts` | 12, 18, 19 | L | Norme agendas encore en brouillon (non revérifié) |
| **21. Durcissement et conformité** | Fuzzing des analyseurs, essais de charge, suites de conformité (P10), corrections | — | Bancs de Mox, sabre/dav, RustiCal (transposés) | tous | 12, 20 | L | Nombre d'écarts inconnu d'avance |
| **22. Essais réels et clôture** | Essais sur domaine, IP et appareils réels (§8), audit `lyxal-audit` par crate, procédures d'exploitation, `README.md`, `ROADMAP.md`, `SOURCES.md` définitifs | — | — | tous, docs | 21, P11 | M | Dépend des moyens fournis par le CTO |

Ordre : la valeur arrive tôt (lot 5 : courrier entrant, attendu par `lyxal_notification` ;
lot 6 : envoi sans fournisseur ; lot 8 : vraies boîtes). Les lots 14 à 17 et 19 ne dépendent
pas du courrier : ils peuvent être avancés après le lot 3 si le CTO veut les agendas plus tôt.
Les lots 18 et 20 exigent le courrier.

**Chiffrement des boîtes** (décision du CTO sur l'étude Proton, P15) — trois niveaux :

| Niveau | Principe | Place dans le programme |
| :- | :--- | :--- |
| **A** | Chiffrement au repos avec des clés de la plateforme par organisation (modèle de `lyxal_secrets`) | **Dans le programme** : chiffrement de fichiers en flux, extension de `lyxal_crypto` détaillée et validée avec le lot 2 (la primitive actuelle plafonne à 1 Mio) ; appliqué dès le lot 4 au courrier, puis aux agendas (lot 16) et aux contacts (lot 19) |
| **B** | Chiffrement à la remise par la clé publique OpenPGP de l'utilisateur, avec `rpgp` | **Lot optionnel 12 bis**, après le lot 12. Les lots 4 et 5 réservent dès maintenant le drapeau « chiffré » et l'ordre antivirus → anti-spam → filtres → index → chiffrement |
| **C** | Bout en bout complet, à la Proton : clés chez le client ; exige nos propres logiciels clients (ou une passerelle) et retire au serveur la recherche, les filtres et l'anti-spam sur le contenu des boîtes qui l'activent | **Gardé dans le programme, sans lot fixé à ce jour** ; son plan est instruit après le niveau B. D'ici là, aucun lot ne ferme cette possibilité : modèle des clés par utilisateur, drapeau « chiffré », contrats qui ne supposent jamais le contenu des messages lisible par le serveur |

Agendas et contacts : niveau A seulement (aucun logiciel CalDAV / CardDAV classique ne
déchiffre). Ce que Proton apporte d'autre (fonctions du futur webmail, alias d'adresses à la
SimpleLogin à instruire avec le lot 13) est consigné dans `crates/lyxal_mail/ROADMAP.md`.

## 6. Dépendances nouvelles

| Bibliothèque | Licence | Usage | Déjà dans le dépôt |
| :--- | :--- | :--- | :--- |
| `mail-parser` 1.0, `mail-builder` 2.0, `mail-send` | Apache-2.0 OR MIT | Lecture, écriture, envoi des messages | non |
| `mail-auth` 0.15 | Apache-2.0 OR MIT | SPF, DKIM, DMARC, ARC — **derrière `lyxal_crypto`** (P6) ; fait sa crypto avec `aws-lc-rs` ou `rsa` / `ed25519-dalek`, pas `ring` (étude) | non |
| `rustls`, `tokio-rustls` (serveur), `hickory-resolver` (avec DNSSEC) | permissives | TLS, DNS | oui (client ; `lyxal_auth`) |
| `rcgen`, `x509-parser` | à vérifier au lot 13 | Demandes de certificat ACME (utilisées par Stalwart) | non |
| `quick-xml` 0.42, `jiff` 0.2, `reqwest`, `axum` | permissives | XML DAV, dates, HTTP | oui |
| Dépendances propres aux crates portés (`roaring`, `rkyv`, listes de suffixes…) | à relever par lot | — | non |

Chaque plan de lot liste ses dépendances exactes ; l'arbre complet est contrôlé (licences)
avant chaque fusion.

## 7. Décisions du CTO

Décisions P1 à P14 **validées par le CTO** le 18 novembre 2026, telles que proposées ci-dessous ; P15 ajoutée à sa demande le même jour.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **P1** | Crates et noms | Cinq crates du Noyau Technique : `lyxal_mail_proto`, `lyxal_mail`, `lyxal_dav`, `lyxal_calendar`, `lyxal_contacts` (§4.1), inscrits après `lyxal_notification` dans `AGENTS.md` §6 avec la mention « à créer ». |
| **P2** | Licence déclarée par crate | Les cinq crates et l'hôte `apps/lyxal-groupware` déclarent `license = "AGPL-3.0-only"` (option AGPL de la double licence de Stalwart ; le code RustiCal, `AGPL-3.0-or-later`, s'y combine ; les parties MIT et BSD gardent leurs mentions) et tiennent un `SOURCES.md` : fichier ou dossier porté, projet, commit, licence. **Faits, sans avis juridique** : (1) l'AGPL demande que l'œuvre qui contient ce code soit diffusée sous AGPL, et que les utilisateurs d'une version modifiée servie par le réseau puissent en obtenir le source (articles 5 et 13) ; le binaire `lyxal-groupware`, qui lie ces crates et les crates MIT / Apache du noyau, est donc concerné en entier ; (2) les crates existants restent sous `MIT OR Apache-2.0` et, avec P3, `lyxal-server` ne lie aucun crate concerné ; (3) règle proposée : aucun code de source AGPL / GPL dans un crate existant (§4.1) ; (4) les fichiers `.surql` des nouveaux modules sont installés dans la même base que les autres : la portée de la licence sur ce point est une question pour le CTO. |
| **P3** | Hébergement des ports | Hôte dédié `apps/lyxal-groupware` (§4.3) pour tous les ports du courrier **et** le HTTP de CalDAV, CardDAV et JMAP ; `lyxal-server` inchangé. Si refusé : tout dans `lyxal-server`, qui lie alors les crates AGPL et expose les ports du courrier dans le processus de l'API. |
| **P4** | Portage du stockage | Voie **B** (§4.4) : modèle SurrealQL conforme aux règles ; couches de protocole portées, accès aux données réécrits. Confirmée ou revue après les mesures du lot 0. La voie A reste le repli si les mesures condamnent B pour les index des boîtes. |
| **P5** | Sources principales | Courrier : **Stalwart** (protocoles) et **Mox** (modèle de données, comportements, bancs) ; bibliothèques `mail-*` en dépendances. DAV, agendas, contacts : **Stalwart** (`dav-proto`, `dav`, `groupware`, `calcard` — même bibliothèque iCalendar que JMAP et la planification), **sabre/dav** pour le modèle de données et les tests, **RustiCal** pour le découpage du stockage, les jetons d'application et WebDAV-Push. `calcard` : version du dépôt Stalwart (AGPL, sur `jiff`, déjà dans le dépôt Lyxal) plutôt que la 0.3.14 archivée. |
| **P6** | Extensions de `lyxal_crypto` (§11.3) — accord de principe, détail validé lot par lot | (a) TLS côté serveur avec `rustls` (lot 2) ; (b) vérification de signatures **RSA-SHA256** et **Ed25519** — Ed25519 sort du « hors scope » (lot 2) ; (c) **DKIM** : canonicalisation, vérification, signature RSA et Ed25519 (lot 2) ; (d) génération de clés RSA et Ed25519 pour DKIM (`ring` ne génère pas de clés RSA ; l'étude signale l'avis RUSTSEC-2023-0071 sur la crate `rsa`, non revérifié) (lot 2) ; (e) **ARC** : vérification et scellement (lot 7) ; (f) **DANE** : contrôle du certificat contre l'enregistrement TLSA (lot 7) ; (g) **ACME** : demande de certificat et clés (lot 13) ; (h) **SCRAM-SHA-256** pour l'authentification IMAP / SMTP (PBKDF2-HMAC), si retenu au lot 8. (i) **chiffrement de fichiers en flux** pour le niveau A du chiffrement des boîtes (lot 2) ; (j) **OpenPGP en chiffrement** par `rpgp` pour le niveau B (lot 12 bis, optionnel) ; les extensions du niveau C sont instruites avec son plan (P15, §5). Sources : `mail-auth`, `ring`, Mox, `rpgp` (toutes permissives). Si (b) à (d) sont refusés : pas de DKIM, donc pas de lots 5 à 7 complets. |
| **P7** | Dépendances notables | Accord de principe sur `mail-parser`, `mail-builder`, `mail-send`, `mail-auth`, `rustls` côté serveur, `hickory-resolver` avec DNSSEC ; le reste lot par lot (§6). |
| **P8** | Mots de passe d'application dans `lyxal_auth` | Évolution de `lyxal_auth` (lot 1) : mot de passe par appareil, sans double facteur, révocable, limité aux permissions `mail.*`, `calendar.*`, `contacts.*` choisies, utilisable en HTTP Basic et en SASL PLAIN / LOGIN sur TLS seulement ; essais limités ; journal des connexions. |
| **P9** | Ordre des lots | Ordre du §5 (courrier d'abord). Variante possible sans surcoût : lots 14 à 17 et 19 juste après le lot 3. |
| **P10** | Suites de conformité | CalDAVTester (Apache-2.0), `caldav-server-tester` (AGPL) et litmus (GPL-2) lancés comme outils externes ; banc IMAP `imaptest` (présent dans Mox ; licence à vérifier) ; Mailpit et `swaks` pour SMTP (licences à vérifier) ; tests de Mox (MIT), de sabre/dav (BSD) et de RustiCal transposés. Les tests de Stalwart sont privés. Outils installés hors dépôt ; aucun appel à Internet en CI. |
| **P11** | Moyens que seul le CTO peut fournir | Avant le lot 22 (et dès le lot 6 pour l'envoi) : un **nom de domaine** d'essai et la main sur son **DNS** (MX, SPF, DKIM, DMARC, MTA-STS, TLS-RPT, SRV de découverte, DNSSEC et TLSA pour DANE) ; une **adresse IP publique** avec le **port 25 ouvert en entrée et en sortie** et la main sur son **DNS inverse** ; des **appareils et logiciels réels** (iPhone, Mac, Android avec DAVx⁵, Thunderbird, Outlook) ; des boîtes d'essai chez Gmail, Outlook.com et Yahoo. Secrets rangés dans `lyxal_secrets`, jamais dans le dépôt ni dans une conversation. |
| **P12** | Liste « Essais réels à faire » | Même convention que `crates/lyxal_notification/ROADMAP.md` : chaque `ROADMAP.md` tient un tableau des essais réels (préalable, action, résultat attendu) ; chaque lot y ajoute les siens ; un essai réussi est retiré et noté dans le `README.md`. Les tests automatiques n'appellent aucun service réel. |
| **P13** | Anti-spam | Intégré (lot 11), porté de Stalwart sans la partie IA (propriétaire). Rspamd n'est pas utilisé. |
| **P14** | Suivi des sources | Les commits sources sont figés au lot 0. Reprendre une version plus récente d'une source est un changement comme un autre : plan, `SOURCES.md` mis à jour, validation. |
| **P15** | Proton comme source d'inspiration | Demande du CTO : s'inspirer aussi de **Proton** (Proton Mail, Proton Calendar, Proton Contacts). Le serveur de Proton n'est pas publié : seuls ses logiciels clients et ses bibliothèques le sont. Au lot 0, étude à verser dans `RECHERCHE_SOURCES.md` : dépôts publics de Proton, licence de chacun (à vérifier, non vérifiée à ce jour), et ce qui peut inspirer Lyxal — en premier le **chiffrement des boîtes, des agendas et des contacts** (clés par utilisateur, chiffrement de bout en bout, serveur qui ne lit pas le contenu), la gestion des clés et l'expérience des logiciels clients. Toute reprise suit P2 (provenance et licence dans `SOURCES.md`) et P6 (chaque primitive cryptographique est une extension de `lyxal_crypto` validée par le CTO). **Décision du CTO sur cette étude (18 novembre 2026)** : le chiffrement des boîtes entre dans le programme. Niveau A (au repos, clés de la plateforme par organisation) : extension de `lyxal_crypto` au lot 2, appliqué dès le lot 4. Niveau B (à la remise, clé publique OpenPGP de l'utilisateur, `rpgp`) : lot optionnel 12 bis ; les lots 4 et 5 lui réservent le drapeau « chiffré » et l'ordre de remise. Niveau C (bout en bout complet) : **gardé dans le programme, sans lot fixé à ce jour**, instruit après le niveau B ; aucun lot ne doit fermer cette possibilité. Agendas et contacts : niveau A seulement. Détail au §5 ; étude dans `crates/lyxal_mail/RECHERCHE_SOURCES.md` (partie 2). |

## 8. Vérification

Chaque lot : banc SurrealQL (`scripts/ci/test_lyxal_modules.py` : cas nominaux, erreurs,
identités, permissions, isolation entre organisations ; chaque fonction publique appelée),
tests Rust de bout en bout sur le moteur embarqué avec de **faux correspondants locaux**
(serveur et client SMTP, résolveur DNS simulé, clients IMAP et DAV scriptés),
`scripts/ci/ci_local.sh` vert avant chaque demande de fusion. Les suites de P10 tournent à
partir du lot où leur protocole existe. Les essais réels (P11, P12) se font sur ordre du CTO.

## 9. Hors périmètre de ce programme

* `lyxal_booking/` (F3) ; sa reprise au-dessus de `lyxal_calendar` est un autre plan.
* Fonctions propriétaires de Stalwart et leurs équivalents non demandés : SCIM, anti-spam par
  IA, réplicas et répartition du stockage, télémétrie en direct, restauration des éléments
  supprimés. (Les organisations multiples, elles, sont dans le programme, écrites pour Lyxal.)
* Webmail et écrans de la console (Surrealist) : après la clôture, sur les fonctions publiques.
  Les logiciels clients propres à Lyxal qu'exige le niveau C du chiffrement relèvent du plan de
  ce niveau (§5), pas de cette exclusion.
* Stockage de fichiers WebDAV (Stalwart `dav/file`, JMAP fichiers) : plus tard, sur `lyxal_storage`.
* Annuaires externes LDAP et SQL pour les comptes : les comptes sont ceux de `lyxal_auth`.
* Lecture de boîtes et d'agendas **externes** (Google, Microsoft, IMAP distant) : `lyxal_connect`.
* Signatures post-quantiques et DKIM v2 (brouillon) ; service de fuseaux RFC 7808 ; WebDAV-Push
  (brouillon) ; connecteur Outlook ; migration depuis un autre serveur de courrier.
* Bascule de `lyxal_notification` vers le serveur de courrier Lyxal comme fournisseur par
  défaut : son propre plan, après le lot 6.

## 10. Risques

| Risque | Ce qu'il faut savoir |
| :--- | :--- |
| **Taille** | 23 lots, dont 6 XL et 10 L : en lots de taille habituelle (S = ½, M = 1, L = 2, XL = 4), environ **50 lots**, contre 5 à 8 pour chacun des crates déjà livrés. Les sources à porter ou à transposer font environ 315 000 lignes de Rust côté Stalwart (hors colle `common`, `store`, `registry` et hors parties écartées au §9), soit plus de deux fois et demie tout le Rust actuel du dépôt. C'est le plus gros programme du dépôt, de loin. S'y ajoutent le lot optionnel 12 bis (niveau B du chiffrement, L) et le niveau C, sans lot ni taille à ce jour. |
| **Délivrabilité** | Envoyer sans fournisseur demande une IP réputée, un DNS inverse, SPF, DKIM et DMARC alignés, une montée en charge progressive et une surveillance des listes noires. C'est un travail d'exploitation continu que le code ne remplace pas. Beaucoup d'hébergeurs bloquent le port 25 sortant (sources secondaires de l'étude). |
| **Exposition** | Les ports 25, 587, 465, 143, 993 sont attaqués en permanence : spam, relais ouvert, recherche d'adresses, essais de mots de passe, saturation mémoire. Stalwart lui-même a publié des avis de déni de service (étude). Limites, délais et fuzzing sont dans les lots 3, 5 et 21 ; l'hôte dédié (P3) borne les dégâts. |
| **Entretien d'un gros portage** | Stalwart publie une version par semaine et a cassé son schéma entre 0.16 et 1.0 (étude) ; ses tests sont privés. Avec la voie B, chaque correctif amont (sécurité comprise) est à reporter à la main. Il faut une veille des avis de sécurité des sources. |
| **SurrealDB à l'échelle d'une boîte** | Mesuré au lot 0 sur une boîte de 1 000 000 de messages (`crates/lyxal_mail/RECHERCHE_SOURCES.md`, « Mesures SurrealDB ») : première page, page par curseur, synchronisation, changement de drapeau et remise tiennent les seuils sur les trois moteurs, à condition de paginer par curseur ou par plage d'UID (jamais par décalage) et de tenir les compteurs à l'écriture. Restent inconnus : la charge concurrente (lectures sous écritures, plusieurs écrivains dans un même dossier), plusieurs comptes dans une table, la recherche plein texte sur le corps des messages (un mot fréquent combiné à un dossier et à un tri coûte déjà 4 à 11 s sur les sujets), le comportement dans la durée. |
| **Compatibilité des logiciels clients** | Outlook, Apple Mail, Calendrier et Rappels d'Apple ne sont pas documentés : seuls des essais réels (P11) tranchent. |
| **Perte ou fuite de courrier** | Inacceptable en production : sauvegarde et restauration des boîtes, cohérence entre SurrealDB (métadonnées) et `lyxal_storage` (octets), isolation entre organisations testée à chaque lot. |
| **Chiffrement des boîtes** | Niveau A : nouvelle primitive (chiffrement de fichiers en flux) dans `lyxal_crypto`, à faire relire. Niveau B : recherche dans le texte, aperçu et apprentissage anti-spam après coup perdus pour les comptes qui l'activent ; une clé perdue rend le courrier illisible. Niveau C : exige des logiciels clients propres à Lyxal ou une passerelle, et retire au serveur recherche, filtres et anti-spam sur le contenu ; sans lot fixé, il impose dès le lot 4 des contrats qui ne supposent jamais le contenu lisible par le serveur. |
| **Licence** | Traitée par le CTO (F2). Ce plan garantit seulement la traçabilité (F4, P2) et l'exclusion du code propriétaire (F5). |
| **Faits non vérifiés** | Exécuteurs de `lyxal_scheduler` sur deux hôtes ; licences de `rcgen`, `x509-parser`, `imaptest`, `swaks` ; état des brouillons JMAP agendas ; numéros de RFC ; dépendance GPL de RustiCal (reprise de l'étude). Rien n'a été compilé. |

## 11. Checklist (§13 des standards)

* [ ] **Architecture** : responsabilités dans les bons crates ; aucun cycle (§4.2) ; frontière SurrealQL / Rust (§4.4).
* [ ] **Core** : entrées validées, nettoyées et contrôlées par `lyxal_core` (§5.7.8) ; besoins génériques manquants signalés lot par lot, jamais ajoutés sans accord.
* [ ] **SurrealQL** : `fn::<module>_<action>($params: object)`, `fn::result_ok` / `fn::error_result`, `COMMENT`, 300 lignes au plus, écriture principale vérifiée (`*_WRITE_FORBIDDEN`), bancs `tests/*.test.surql`.
* [ ] **Rust** : `XxxParams` / `XxxResult`, wrappers `store.call_fn`, aucun `panic!`, aucun `raw_query()` métier, aucun secret exposé, workers `LyxalWorker` seulement.
* [ ] **Erreurs** : codes `MAIL_*`, `CALENDAR_*`, `CONTACTS_*` en master data ; aucune erreur silencieuse.
* [ ] **Événements** : `fn::event_publish` vérifié ; producteurs sans connaissance des consommateurs ; handlers idempotents.
* [ ] **Cryptographie** : tout par `lyxal_crypto` ; extensions P6 validées avant tout code ; aucune crate crypto dans les modules ; secrets dans `lyxal_secrets`.
* [ ] **Chiffrement des boîtes** (P15, §5) : niveau A appliqué ; drapeau « chiffré » et ordre de remise réservés (niveau B) ; aucun contrat ne suppose le contenu d'un message lisible par le serveur (niveau C).
* [ ] **Zéro dette** (§0) : une migration par module, versions `0.y.z`, aucun alias ni code mort, pas de document historique ; `ROADMAP.md` tenue.
* [ ] **Provenance** (F4, F5) : `SOURCES.md` à jour, licence déclarée par crate, aucune partie `LicenseRef-SEL`, aucun code AGPL / GPL dans un crate existant.
* [ ] **Validation CTO** : ce plan, puis un plan détaillé par lot.
