# Feuille de route — `lyxal_calendar`

Évolutions à venir du crate (à créer). Son objet est décrit par le [`README.md`](README.md),
l'étude des sources par [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md), la provenance par
[`SOURCES.md`](SOURCES.md). Le programme est décrit par `implementation_plan.md` à la racine du
dépôt ; chaque lot a son propre plan, validé par le CTO avant toute ligne de code
(`.agents/AGENTS.md` §3).

## Lots du programme, dans l'ordre

| Lot | Contenu pour ce crate | Sources principales | Prérequis |
| :- | :--- | :--- | :--- |
| 16 — CalDAV | Création du module (`Cargo.toml` sous `AGPL-3.0-only`, exception nommée dans `deny.toml`) : agendas, événements, recherche par période, lecture groupée, propriétés Apple, restitution à l'octet près ; chiffrement au repos (niveau A) | Stalwart `dav/calendar`, `groupware/calendar` ; sabre/dav (modèle SQL, tests) | lot 15 |
| 17 — Tâches, partage, disponibilités | `VTODO`, `VJOURNAL`, partage lecture / écriture, délégation, `free-busy-query`, alarmes et rappels | idem ; RustiCal (partage par groupes) | lot 16 |
| 18 — Planification | Boîtes `schedule-inbox` / `-outbox`, invitations internes, invitations par e-mail (envoi et réception), réponses, contre-propositions | Stalwart `groupware/scheduling` ; sabre/dav `Schedule` | lots 5, 6, 17 |
| 20 — JMAP agendas et contacts | JSCalendar, méthodes JMAP | Stalwart `jmap` (agendas) | lots 12, 18, 19 |
| 21 — Durcissement et conformité | Suites de conformité (CalDAVTester, `caldav-server-tester`, litmus), essais de charge, corrections | Tests de sabre/dav et de RustiCal transposés | lots 12, 20 |
| 22 — Essais réels et clôture | Essais ci-dessous, audit `lyxal-audit`, procédures d'exploitation, documents définitifs | — | lot 21, moyens P11 |

## Chiffrement (décision C7)

Agendas : **niveau A seulement** (chiffrement au repos avec les clés de la plateforme par
organisation, modèle de `lyxal_secrets`). Aucun logiciel CalDAV classique ne sait déchiffrer un
événement : les niveaux B et C ne s'appliquent pas aux agendas dans ce programme. Si le
niveau C du courrier est un jour instruit avec nos propres logiciels clients, l'étude Proton
(découpage d'un événement en parties chiffrée, signée et lisible) est dans
[`crates/lyxal_mail/RECHERCHE_SOURCES.md`](../lyxal_mail/RECHERCHE_SOURCES.md).

## Après le programme

Reprise de la prise de rendez-vous au-dessus de ce module (autre plan) ; lecture d'agendas
externes (Google, Microsoft, CalDAV distant) : proposition `lyxal_connect` ; abonnement à un
agenda externe ; pièces jointes gérées (RFC 8607) sur `lyxal_storage` ; WebDAV-Push.

## Essais réels à faire

Les tests automatiques n'appellent aucun service réel. Les essais réels se font sur ordre du
CTO, avec les moyens qu'il fournit (décision P11) ; secrets rangés dans `lyxal_secrets`, jamais
dans le dépôt ni dans une conversation. Chaque lot ajoute ici ses essais ; un essai réussi est
retiré de la liste et noté dans le `README.md`.

Moyens à fournir par le CTO (décision P11) : un nom de domaine et la main sur son DNS
(enregistrements SRV de découverte), un hôte joignable en HTTPS, des appareils et logiciels
réels (iPhone, Mac, Android avec DAVx⁵, Thunderbird, Outlook), et, pour le lot 18, les moyens du
courrier (IP avec port 25, boîtes d'essai chez Gmail, Outlook.com et Yahoo).

| Lot | Préalable | Action | Résultat attendu |
| :- | :--- | :--- | :--- |
| 16 | Domaine, HTTPS, mot de passe d'application ; iPhone et Mac (Calendrier), Thunderbird, DAVx⁵, Evolution | Ajouter le compte ; créer, modifier, supprimer des événements simples et récurrents sur chaque logiciel | Synchronisation juste dans les deux sens ; exceptions de récurrence et fuseaux exacts ; couleurs et ordre des agendas gardés |
| 16 | Idem | Modifier le même événement sur deux appareils | Conflit détecté par ETag ; aucune modification perdue en silence |
| 17 | Idem, plus Rappels d'Apple et une application de tâches Android | Tâches, partage en lecture et en écriture entre deux comptes, délégation, disponibilités | Tâches synchronisées ; droits respectés ; plages occupées exactes |
| 18 | Moyens du courrier ; comptes Gmail, Outlook.com et Yahoo | Inviter un compte interne et des comptes externes ; accepter, refuser, proposer un autre horaire ; modifier une occurrence | Invitations reçues et lisibles partout ; réponses rattachées au bon événement ; organisateur non usurpable |
| 20 | Client JMAP | Lire et modifier un agenda par JMAP | Même état que par CalDAV |
| 22 | Outlook (classique et nouveau) | Relever ce qui fonctionne | Limites notées dans le `README.md` |
