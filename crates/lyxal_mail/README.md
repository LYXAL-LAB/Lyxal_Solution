# `lyxal_mail` — serveur de courrier

**État : socle courrier (lot 4 du programme courrier, réalisé) et contrat réseau des sessions
(lot 3).** Le module déclare ses tables, fonctions, gardes, erreurs `MAIL_*`, événements et
permissions (`manifest.toml`, `[resources]`) ; son service Rust dépose un message brut (lecture
MIME, écriture **chiffrée au repos** par `lyxal_storage`, inscription), le relit en entier ou par
plage, et fait la maintenance (contenus abandonnés et libérés, effacements échus, comptes
supprimés). Aucun protocole n'est encore écrit (lots 5 à 12) : rien n'est joignable par le
réseau. Le module est installé et démarré par l'hôte `apps/lyxal-groupware`, qui le porte par
son `MailModule`, héberge ses dépendances (`lyxal_auth`, `lyxal_secrets`, `lyxal_storage`) et
`lyxal_scheduler` (maintenance), et lui rattache ses écoutes (workers
`lyxal_mail:mail.listener.<id>`). Inscrit au Noyau Technique dans `.agents/AGENTS.md` §6 et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md). Évolutions à
venir : [`ROADMAP.md`](ROADMAP.md).

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
| `mail_message` | Message d'un dossier (un seul, M5), d'identifiant ordonné `mail_message:⟨<clé du dossier>_<10^10 + UID>⟩` (décision P1) : UID, identifiant JMAP (`email_id`, gardé par un déplacement), numéros de modification, fil immuable (M7), dates, drapeaux système en booléens, mots-clés en minuscules triés, `Message-ID`, sujet de base, enveloppe typée et structure MIME facultatives (M8) |
| `mail_tombstone` | Effacements (message effacé ou déplacé hors d'un dossier, dossier supprimé) avec leur numéro de modification, pour `QRESYNC` et `Email/changes` |
| `mail_message_date` | Vue des messages d'un dossier par date interne, d'identifiant ordonné `⟨<clé du dossier>_<10^16 + µs>_<10^10 + UID>⟩`, tenue par les événements des messages, fermée à l'écriture directe (pages par date) |

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

**Règle de lecture par fiche (décision P1).** `mail_message`, `mail_message_date` et
`mail_tombstone` portent l'organisation et le titulaire du compte (`tenant`, `owner`, recopiés et
gardés ; le titulaire d'un compte ne change jamais : l'identité ne se remplace pas, et une
identité supprimée met le compte en suppression). Leur permission `select`, même texte sur les
trois tables, compare ces champs à la session lue par chemins : session active et non expirée,
sujet actif, session postérieure à son `not_before`, version des droits du jeton à jour (un
membre retiré de l'organisation, un rôle ou une permission retirés : refus dès l'écriture qui
l'incrémente), puis titulaire dans son organisation active avec `mail.mailbox.access`, ou compte
de service (`mail.worker`). Même portée que `fn::mail_can` pour une boîte, sans appel de fonction
(13 µs par fiche au lieu de 360 µs) ; l'administrateur ne lit jamais une fiche d'une boîte (M11).
Les fonctions publiques contrôlent en plus `fn::mail_can` une fois par appel (dossier, compte ou
message visé).

**Règles de session reprises de `lyxal_auth` (décision P6).** Pour son coût, cette règle recopie
les règles de validité d'une session de `lyxal_auth` au lieu d'appeler `fn::auth_session_valid` :
état de la session et expirations (absolue et d'inactivité), sujet actif (identité ou
application), session postérieure au `not_before` du sujet, version des droits du jeton (`pv`) à
jour, permission portée par le jeton. Écart accepté, consigné aussi dans le README de
`lyxal_auth` : toute évolution de ces règles dans `lyxal_auth` met à jour cette règle dans le
même changement. Une session issue d'une clé d'API ou d'un mot de passe d'application est
révoquée avec lui et n'expire jamais après lui (décision P5) : la règle n'a pas à relire le moyen
(banc `plages` : le même jeton ne lit plus rien après la révocation). Les écritures gardent le contrôle complet. `mail_message.protection` est recopiée
du contenu : une page ne lit pas le contenu.

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
(`fn::auth_organization_domain_get`), l'adhésion du titulaire d'un nouveau compte aussi
(`fn::auth_organization_member_check`, décision P4), jamais dans leurs tables.

### Fonctions publiques (`functions/`)

| Domaine | Fonctions |
| :--- | :--- |
| Réglages, domaines | `mail_settings_get`, `mail_settings_set`, `mail_domain_create`, `_get`, `_list`, `_update`, `_delete` |
| Comptes, adresses | `mail_account_create` (compte, adresse principale, six dossiers), `_get`, `_list`, `_update`, `_delete` ; `mail_quota_get` ; `mail_address_create`, `_update`, `_delete`, `_list`, `_resolve` |
| Dossiers | `mail_mailbox_create`, `_get`, `_list`, `_update` (renommage, déplacement, sous-dossiers réécrits), `_delete` |
| Messages | `mail_message_create`, `_get`, `_list` (curseur de date ou plage d'UID), `_changes` (depuis un numéro de modification, effacements compris), `_flags_set` (`CONDSTORE`), `_move` (nouvelle fiche dans le dossier cible, ancienne retirée, même `email_id` ; un message déjà dans le dossier cible reste inchangé), `_copy`, `_expunge` ; `mail_thread_get` |
| Contenus, maintenance | `mail_content_begin`, `_attach`, `_open`, `_expire` ; `mail_tombstone_purge` ; `mail_account_purge_step` |

Toutes : `$params: object`, entrées par le moteur de `lyxal_core`, `fn::result_ok` /
`fn::error_result`, écriture principale vérifiée (`MAIL_WRITE_FORBIDDEN`), listes par curseur.
**Lectures bornées (décision P1).** Dans une fonction, SurrealDB 3.3.4 n'applique pas `LIMIT` au
parcours d'un index et évalue la permission de la table sur chaque ligne parcourue : les pages
(`mail_message_list`) se lisent donc par plages d'identifiants bornées des deux côtés, qui ne
parcourent que les fiches qu'elles contiennent, permissions des tables comprises (aucune
lecture hors des permissions). Pages par UID : fenêtres d'UID ; pages par date : fenêtres de
dates de la vue `mail_message_date`, dimensionnées sur la densité du dossier (bornes
`received_min`, `received_max`), puis lecture des messages par identifiants. Un UID effacé ne
coûte rien. Les changements depuis un numéro de modification ne parcourent que les fiches
changées (index `(compte, modseq)`). Clés texte de largeur fixe, car le moteur de validation de
`lyxal_core` ne lit pas un identifiant tableau (`mail_message:[dossier, uid]`).
Fonctions internes (`COMMENT` « Interne ») : `fn::mail_can`, `fn::mail_settings_effective`,
`fn::mail_session_account`, `fn::mail_address_normalize`, `fn::mail_modseq_next`,
`fn::mail_thread_assign`, `fn::mail_content_release`, `fn::mail_content_bucket` (bucket
`lyxal-mail` de l'organisation, cherché sur toutes les pages), `fn::mail_content_remove`,
`fn::mail_write_refusal`, `fn::mail_counters_apply`, `fn::mail_keywords_rule`,
`fn::mail_messages_rule`, `fn::mail_flags_apply`, `fn::mail_messages_load`,
`fn::mail_message_key`, `fn::mail_message_key_text`, `fn::mail_message_date_key_text`,
`fn::mail_message_uid_page`, `fn::mail_message_date_page`.

### Erreurs et événements

39 codes `MAIL_*` en master data (`error/<thème>/`, traduits en français et en anglais ;
`MAIL_CONTENT_UNAVAILABLE` à réessayer). Événements publiés par `fn::event_publish`, sans donnée
personnelle (identifiants et compteurs seulement) : `mail.domain.created`, `mail.domain.deleted`,
`mail.account.created`, `mail.account.deleted` (fin de la purge), `mail.address.created`,
`mail.address.deleted`, `mail.quota.exceeded` (premier refus depuis le dernier passage sous le
quota ou le dernier changement de quota). Aucun événement par message au lot 4 (M16).

### Banc SurrealQL

`tests/*.test.surql` (`scripts/ci/test_lyxal_modules.py`) : `reglages`, `domaines`, `comptes`,
`adresses`, `dossiers`, `messages`, `synchronisation`, `contenus`, `droits`, `plages`, `organisations` —
chaque fonction appelée ; sessions système, compte de service, administrateur, titulaire, autre
membre, autre organisation ; écritures filtrées (`MAIL_WRITE_FORBIDDEN`) ; écritures directes
refusées par les gardes ; compteurs égaux au contenu réel ; suppression d'une organisation ;
`plages` : identifiants ordonnés, pages par UID à travers des UID effacés, pages par date à
travers des dates éloignées et des égalités, aucune fiche d'un autre compte lue par une plage
d'identifiants (autre membre, autre organisation, administrateur), vue par date fermée à
l'écriture directe, identifiant et UID gardés.

## Mesures (`scripts/bench/mailbox/bench_mail_module.py`)

Mesures du 21 novembre 2026, SurrealDB 3.3.4 en mémoire, machine de développement à 4 cœurs,
boîtes de 2 000 et 100 000 messages (`--delivery 100 --repeat 15 --fast-load` : boîte chargée par
écriture directe de la session système, gardes et compteurs compris), temps vus par le client
sur une connexion gardée ouverte, moteur de `lyxal_core` accéléré (décision P2), lectures par
plages d'identifiants bornées et règle de lecture par fiche allégée (décision P1). Les temps sous
la session système comprennent environ 20 ms d'authentification Basic par requête (`RETURN 1`),
ceux d'un membre moins de 1 ms (jeton). Seuils de la décision C5 (lot 0).

| Mesure (p50 / p95) | Membre, 2 000 | Membre, 100 000 | Système, 2 000 / 100 000 (p50) | Seuil C5 |
| :--- | :-: | :-: | :-: | :-: |
| Première page de 50 messages, par date | 51 / 52 ms | 54 / 67 ms | 49 / 51 ms | 100 ms : **tenu** |
| Page de 50 messages, par UID | 38 / 44 ms | 39 / 46 ms | 43 / 45 ms | 100 ms : **tenu** |
| Changements du compte (1 000 drapeaux, 200 effacements) | 69 / 70 ms | 73 / 80 ms | 62 / 62 ms | 100 ms : **tenu** |
| Changements d'un dossier | 73 / 74 ms | 76 / 78 ms | 63 / 64 ms | 100 ms : **tenu** |
| Plage de 1 000 UID | 489 / 565 ms | 504 / 547 ms | 193 / 223 ms | — |
| Changement de drapeau (`_flags_set`, un message) | 15 / 16 ms | 13 / 18 ms | — | 20 ms : **tenu** |
| Remise (`fn::mail_message_create`) | 28 / 31 ms, 35,6 par seconde | 28 / 35 ms, 34,4 par seconde | 45 / 44 ms (validation seule : 38 à 40 ms) | 300 par seconde : **non tenu** |

**Coût par fiche lue.** La règle de lecture des tables `mail_message`, `mail_message_date` et
`mail_tombstone` lit la session et son sujet par chemins et compare des champs recopiés sur la
fiche (`tenant`, `owner`) : environ 13 µs par fiche dans une clause `PERMISSIONS` (mesure isolée
sur 1 000 fiches), contre environ 360 µs pour `fn::mail_can` et 90 µs pour une fonction faite de
requêtes ; en situation, 1 200 changements coûtent environ 10 ms de plus à un membre qu'à la
session système. Les coûts ne dépendent pas de la taille de la boîte : une plage d'identifiants
bornée ne parcourt que les fiches qu'elle contient. Les fonctions publiques contrôlent en plus
`fn::mail_can` une fois par appel (dossier, compte ou message visé). Avant P1, une page de 50 sur
2 000 messages prenait 1 847 ms à un membre, et 1 200 changements 959 ms.

**Plage de 1 000 UID** : environ 0,3 ms de plus par fiche pour un membre que pour la session
système, non expliqué par la règle de lecture (13 µs) ; non analysé (aucun seuil C5).

**Contention du compteur de modifications du compte (décisions M6, P3)** : quatre clients qui
remettent en même temps dans un même compte (25 messages chacun), conflits de transaction
rejoués trois fois au plus : 101 à 115 conflits et 30 à 35 remises refusées pour 100, 34 à 36
remises par seconde au total, dans un dossier comme dans quatre, sur 2 000 comme sur 100 000
messages. Environ un tiers des remises restent refusées après trois rejeux : le compteur unique
du compte sérialise ses écritures. Repli du §19 du plan à décider sur cette mesure.

Cohérence vérifiée en fin de banc : compteurs du compte égaux aux messages, UID uniques dans le
dossier, une fiche de la vue par date par message. Non mesuré : coût d'un scellement de clé de
fichier par message et d'une ouverture de clé par lecture (`ROADMAP.md`).

## État actuel : service Rust

| Élément | Rôle |
| :--- | :--- |
| `MailStore`, `models` | Un appel typé d'une ligne par fonction publique `fn::mail_*` (38 fonctions, `LyxalSurrealCall::call_fn`), paramètres `XxxParams` et résultats nommés (`SurrealValue`) ; la session du client détermine l'appelant |
| `MailIngest`, `Delivery`, `DeliveryFlags` | Dépôt d'un message brut (seul chemin d'écriture d'un message, repris par la remise SMTP du lot 5 et `APPEND` au lot 8) : mémoire réservée sur le budget des connexions (`MemoryBudget`, facultatif), lecture MIME par `lyxal_mail_proto`, `fn::mail_content_begin` sous la session de l'appelant, écriture chiffrée par `lyxal_storage` sous la session système de l'hôte dans le bucket chiffré `lyxal-mail` de l'organisation (créé à la première écriture, sur le support réglé par l'hôte), `fn::mail_content_attach` (session système), `fn::mail_message_create` (appelant) ; écritures rejouées trois fois au plus sur conflit de transaction |
| `MailContent`, `OpenedContent` | Lecture d'un message, entière ou par plage d'octets du message brut (une partie MIME par ses positions) : `fn::mail_content_open` contrôle les droits de l'appelant, `lyxal_storage` ne déchiffre que les segments de la plage ; un segment altéré met fin au flux par une erreur, jamais par une fin normale |
| `MailMaintenance`, `MaintenanceReport` | Un passage, interrompu entre deux appels à l'arrêt du serveur : `fn::mail_content_expire`, `fn::mail_tombstone_purge`, `fn::mail_account_purge_step` par paquets ; exécutée par `lyxal_scheduler` (tâche `mail.maintenance` de l'hôte, toutes les 10 minutes) |
| `MailModule`, `MailHealthCheck` | `LyxalModule` du module (descripteur égal au manifeste) ; sonde : réglages lisibles (sinon « malade »), support de stockage et service de clés des fichiers présents (sinon « dégradé ») ; l'hôte la compose avec celle des écoutes (une sonde par module) |
| `MailError` | Code `MAIL_*` (dont `MAIL_MESSAGE_MALFORMED`, `MAIL_CONTENT_UNAVAILABLE` à réessayer) ou `STORAGE_*` propagé ; `is_retryable()`, `is_business()` ; aucune adresse, aucun sujet, aucun contenu |

**Chiffrement obligatoire (décision M1).** Sans support de stockage ou sans clé maîtresse du
coffre-fort, rien n'est réservé ni écrit (`MAIL_CONTENT_UNAVAILABLE`, à réessayer) et aucun
message n'est lu ; jamais de repli en clair. Un bucket `lyxal-mail` trouvé en clair dans
l'organisation (créé par ailleurs avant la première remise : `lyxal_storage` n'en réserve pas le
nom) fait refuser chaque dépôt avant toute écriture (`MAIL_CONTENT_UNAVAILABLE`) jusqu'à ce que
l'administrateur le supprime ; le bucket est cherché sur toutes les pages de la liste des buckets
de l'organisation. Hiérarchie des clés : clé maîtresse du coffre-fort →
clé « fichiers » de l'organisation (`lyxal_secrets`, sans cache, M19) → clé propre à chaque
message (scellée dans la fiche de `lyxal_storage`) → segments de 64 Kio du `.eml`. Un message
remis à plusieurs comptes a un contenu par compte (M14).

**Atomicité d'un dépôt en échec.** Aucun octet en clair n'est jamais rangé. Écriture du fichier
en échec : `lyxal_storage` retire ses octets et sa fiche. Lien refusé : le fichier, que rien ne
référence, est supprimé aussitôt. Inscription refusée : le contenu lié au fichier reste sans
lecteur et la maintenance le retire avec son fichier, dans la même transaction, à la fin de son
délai d'une heure (le fichier ne peut pas être supprimé avant : il est référencé par le contenu,
`STORAGE_OBJECT_IN_USE`). Une panne dont on ne sait pas si l'écriture a eu lieu ne fait rien
supprimer : la maintenance tranche. Les octets chiffrés d'un fichier supprimé et sa clé scellée
sont retirés par le nettoyage de `lyxal_storage` (tâche `storage.cleanup`, exécutée par
`lyxal-server` sur la base partagée).

**Projection d'un message lu** (`mime`). Enveloppe typée (date de l'en-tête `Date`, sujet,
adresses à plat avec leur groupe, `Message-ID`, `In-Reply-To`, `References`), structure MIME
rangée telle quelle (types, paramètres, disposition, nom, positions `header` / `body` / `end`,
tailles, lignes, parties ou message joint avec son enveloppe, la date brute), clés de fil et sujet
de base. Un message reçu se garde même hors norme : textes et listes plus longs que le schéma de
`mail_message` sont raccourcis (texte coupé à une limite de caractère, `References` réduit aux
1 000 plus récents) au lieu de faire refuser le message ; les entrées restent contrôlées par
`fn::mail_message_create`.

Dépendances Rust : `lyxal_mail_proto`, `lyxal_runtime`, `lyxal_storage`, `lyxal_surreal`,
`surrealdb`, `tokio`, `tokio-util`, `async-trait`, `thiserror`, `tracing`, `bytes`, `futures` ;
aucune crate cryptographique (le chiffrement passe par `lyxal_storage` et `lyxal_secrets`).

Vérification : `cargo test -p lyxal_mail` (base embarquée, support disque, clé maîtresse
éphémère, jetons de session de test) : dépôt de bout en bout puis liste, lecture entière et
d'une partie déchiffrée, octets rangés chiffrés (`LXS1`), drapeaux, déplacement (même
`email_id`), effacement, maintenance qui retire le contenu et son fichier ; refus à réessayer
sans service de clés ou sans clé maîtresse (rien n'est réservé) ; message illisible refusé avant
toute réservation ; inscription refusée puis maintenance ; isolement entre membres et entre
organisations au travers des services (lecture, liste, dépôt) ; maintenance réservée à la
session système ; purge d'un compte supprimé avec ses contenus et fichiers. L'hôte
(`cargo test -p lyxal-groupware`, essai `mail_service`) : démarrage avec clé maîtresse et support
disque, sonde, dépôt et lecture par les services de l'hôte, maintenance exécutée par le
planificateur, planification non recréée au redémarrage ; sans clé : sonde « dégradé », dépôt
refusé à réessayer.

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

Dépendances du module `net` : `tokio`, `tokio-util`, `async-trait`, `thiserror` ; aucun crate
Lyxal, aucune crate cryptographique.

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
| 4 — Socle courrier (réalisé) | Modèle de données SurrealQL : domaines, adresses, alias, boîtes, messages, quotas, droits, erreurs, événements ; service Rust de dépôt et de lecture, chiffrement au repos (niveau A) par `lyxal_storage`, maintenance par `lyxal_scheduler` |
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
