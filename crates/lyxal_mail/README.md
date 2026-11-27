# `lyxal_mail` — serveur de courrier

**État : socle courrier (lot 4 du programme courrier, réalisé), contrat réseau des sessions
(lot 3) et réception SMTP (lot 5, réalisé : DNS, SPF, DKIM, DMARC, nom inverse, résolution des
destinataires, remise groupée et idempotente, liste de blocage, session SMTP entrante, chaîne de
remise).** Le module déclare ses tables, fonctions, gardes, erreurs `MAIL_*`, événements et
permissions (`manifest.toml`, `[resources]`) ; son service Rust reçoit le courrier d'Internet
sur le port 25 (session SMTP, refus dès `RCPT TO`, contrôles d'authenticité, politique DMARC,
antivirus), dépose un message brut (lecture MIME, écriture **chiffrée au repos** par
`lyxal_storage`, inscription), le relit en entier ou par plage, remet un message reçu à un compte
(ordre par compte dans le nœud, écriture groupée, événement `mail.message.received`) et fait la
maintenance (contenus abandonnés et libérés, effacements échus, fiches d'idempotence échues,
comptes supprimés). Envoi (lot 6, en cours) : la partie SurrealQL est faite (sous-lot 6c : file
d'envoi, dépôt et contrat public des modules, droits d'expéditeur, clés DKIM, adresses de retour,
§ « État actuel : envoi ») et le dépôt authentifié des ports 587 et 465 aussi (sous-lot 6e,
§ « `lyxal_mail::submission` ») : un message déposé reste dans la file tant que le worker
d'envoi (6d) n'est pas livré ; le port 25 ne relaie rien, aucun avis de non-remise n'est
produit. Le module est installé et démarré par
l'hôte `apps/lyxal-groupware`, qui le porte par son `MailModule`, héberge ses dépendances
(`lyxal_auth`, `lyxal_secrets`, `lyxal_storage`) et `lyxal_scheduler` (maintenance), et lui
rattache ses écoutes (workers `lyxal_mail:mail.listener.<id>`), servies pour `smtp` par
`SmtpInboundHandler`, et la relecture de la liste de blocage (`lyxal_mail:mail.block_refresh`). Inscrit au Noyau Technique dans `.agents/AGENTS.md` §6 et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md). Évolutions à
venir : [`ROADMAP.md`](ROADMAP.md).

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0).

## État actuel : modèle de données (SurrealQL)

Dépendances du manifeste : `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`,
`lyxal_storage`. Licence des fichiers SurrealQL : `AGPL-3.0-only` (en-tête SPDX).

### Tables (`schema/`)

Toutes `TYPE NORMAL SCHEMAFULL`, rattachées à une organisation (`tenant`, `REFERENCE ON DELETE
CASCADE`) : une organisation supprimée emporte tout son courrier. Seule la liste de blocage
(`mail_network_block`) est à l'échelle de l'installation.

| Table | Contenu |
| :--- | :--- |
| `mail_settings` | Réglages de l'installation et des organisations : taille d'un message (50 Mio par défaut), quota par défaut (aucun), conservation des effacements (30 jours, 7 à 365), dossiers par compte (1 000), adresses par compte (100), mots-clés par message (50) ; installation seulement : `postmaster`, adresse inscrite qui reçoit le destinataire `postmaster` écrit sans domaine (RFC 5321 §4.5.1, S17) |
| `mail_domain` | Domaine de courrier repris d'un domaine **vérifié** de `lyxal_auth` (M9), forme ASCII seulement (M10), état, séparateur de sous-adresse (`+` ou aucun), nombre d'adresses ; `catch_all` (compte attrape-tout, **aucun par défaut**, S17) et `postmaster` (compte qui reçoit `postmaster@<domaine>` sans adresse inscrite), comptes actifs de la même organisation, effacés quand le compte part en suppression ; le retrait du domaine dans `lyxal_auth` est refusé tant qu'il sert au courrier (`MAIL_DOMAIN_EXISTS`), sauf avec l'organisation |
| `mail_account` | Compte d'un membre (une identité par organisation), état (`active`, `disabled`, `deleting`), adresse principale, quota, compteurs du compte : messages, volume, **numéro de modification du compte** (M6), prochaine UIDVALIDITY, plancher des changements, dossiers, adresses |
| `mail_address` | Adresse d'un compte ou alias vers 1 à 50 comptes de l'organisation ; partie locale ASCII en minuscules, préfixe `rp=` réservé (`MAIL_ADDRESS_RESERVED`) ; alias : `senders` (comptes qui peuvent écrire sous l'alias, aucun par défaut), `forward_to` (0 à 10 adresses extérieures, transfert du lot 6f) |
| `mail_mailbox` | Dossier : chemin (`/`), parent, rôle SPECIAL-USE, abonnement, ordre, UIDVALIDITY, prochain UID, compteurs (total, non lus, volume, `HIGHESTMODSEQ`) |
| `mail_content` | Contenu d'un message (fichier `.eml` de `lyxal_storage`) : clé `<compte>/<UUID v7>.eml`, fiche de stockage, état `pending` → `stored` → `released`, taille, `protection` (`platform` ; `openpgp`, `client` réservés, M15), lecteurs (`refs`) |
| `mail_message` | Message d'un dossier (un seul, M5), d'identifiant ordonné `mail_message:⟨<clé du dossier>_<10^10 + UID>⟩` (décision P1) : UID, identifiant JMAP (`email_id`, gardé par un déplacement), numéros de modification, fil immuable (M7), dates, drapeaux système en booléens, mots-clés en minuscules triés, `Message-ID`, sujet de base, enveloppe typée et structure MIME facultatives (M8) ; `origin` (immuable : `delivery`, `append`, `copy`, `move`, `import`) et, pour un message reçu seulement, `reception` : résultats `spf`, `dkim`, `dmarc`, `iprev` (mots de la RFC 8601), `antivirus`, `spam`, `tls`, sans domaine ni adresse |
| `mail_delivery` | Idempotence d'une remise SMTP (S8) : `mail_delivery:⟨<clé du compte>_<empreinte>⟩`, message inscrit, fin de conservation (7 jours) ; lue et écrite par la session système et le compte de service seulement ; purgée par la maintenance |
| `mail_network_block` | Liste de blocage de l'installation (S18) : réseau (plage CIDR, unique), motif (`manual`, `errors`, `harvest`, `smuggling`), récidives (`strikes`), fin (`expires_at` ; absente : entrée manuelle sans fin), auteur d'une entrée manuelle |
| `mail_tombstone` | Effacements (message effacé ou déplacé hors d'un dossier, dossier supprimé) avec leur numéro de modification, pour `QRESYNC` et `Email/changes` |
| `mail_message_date` | Vue des messages d'un dossier par date interne, d'identifiant ordonné `⟨<clé du dossier>_<10^16 + µs>_<10^10 + UID>⟩`, tenue par les événements des messages, fermée à l'écriture directe (pages par date) |
| `mail_submission`, `mail_queue_recipient`, `mail_queue_due`, `mail_queue_destination`, `mail_dkim_key`, `mail_send_counter` | Envoi (lot 6) : voir « État actuel : envoi » |

### Droits (`fn::mail_can`, seed `seeds/mail_auth.surql`)

| Permission | Portée | Mot de passe d'application | Rôles | Donne |
| :--- | :--- | :-: | :--- | :--- |
| `mail.mailbox.access` | organisation | oui | membre, administrateur | sa propre boîte (identité du compte = identité de la session) |
| `mail.domain.manage` | organisation | non | administrateur | domaines, comptes, adresses, alias, réglages ; **jamais** le contenu des boîtes (M11) |
| `mail.installation.manage` | installation | non | administrateur de la plateforme | réglages de l'installation (dont `postmaster`), entrées manuelles de la liste de blocage, sa lecture et ses retraits |
| `mail.worker` | installation | non | aucun (compte de service) | résolution des destinataires, remise et dépôt dans tout compte, bannissements automatiques et lecture des réseaux bloqués, maintenance ; file d'envoi, clés DKIM, avis reçus |
| `mail.send` | organisation | oui | membre, administrateur | envoyer sous ses propres adresses (§8.3 du plan du lot 6), lire et annuler ses envois |
| `mail.relay` | installation | non | aucun (compte de service d'un module) | déposer par le contrat public sous les expéditeurs des modules d'un domaine, lire et annuler ces envois |

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
compte de service). Réception : un message d'origine `delivery` n'est inscrit que par le service
de remise (session système, compte de service) et porte ses sept résultats de réception ; aucune
autre origine ne les porte ; l'attrape-tout et le postmaster d'un domaine ne se posent que sur un
compte actif de son organisation. Le domaine de `lyxal_auth` est lu par son contrat public
(`fn::auth_organization_domain_get`), l'adhésion du titulaire d'un nouveau compte aussi
(`fn::auth_organization_member_check`, décision P4), jamais dans leurs tables.

### Fonctions publiques (`functions/`)

| Domaine | Fonctions |
| :--- | :--- |
| Réglages, domaines | `mail_settings_get`, `mail_settings_set` (dont `postmaster`, installation seulement), `mail_domain_create`, `_get`, `_list`, `_update` (dont `catch_all`, `postmaster`, `clear`), `_delete` |
| Comptes, adresses | `mail_account_create` (compte, adresse principale, six dossiers), `_get`, `_list`, `_update`, `_delete` ; `mail_quota_get` ; `mail_address_create`, `_update`, `_delete`, `_list` |
| Réception (session système, `mail.worker`) | `mail_recipient_resolve` (remplace `mail_address_resolve` : domaine actif sinon `MAIL_RELAY_DENIED` ; adresse exacte, sans sous-adresse, `postmaster`, attrape-tout ; comptes actifs et `quota_full` par compte ; taille maximale de l'organisation) ; `mail_delivery_begin` (compte, taille, quota, idempotence : contenu réservé, ou `duplicate`) ; `mail_delivery_commit` (1 à 32 messages d'un compte en une transaction ; une erreur d'élément n'annule pas les autres ; 33 : `MAIL_DELIVERY_BATCH_TOO_LARGE`) ; `mail_delivery_purge` |
| Liste de blocage | `mail_block_create` (entrée manuelle : `mail.installation.manage` ; bannissement automatique : `mail.worker`, 1 h doublée à chaque récidive, 24 h au plus), `_list` (curseur : réseau), `_delete`, `_active` (réseaux en vigueur, lus par chaque nœud) |
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
`fn::mail_message_uid_page`, `fn::mail_message_date_page`, `fn::mail_recipient_accounts`,
`fn::mail_delivery_item` (un élément d'un lot : tous les contrôles avant les écritures),
`fn::mail_delivery_key`, `fn::mail_delivery_item_check` (contrôle d'un élément d'un lot).

**Contrôle allégé des paramètres de remise (décisions S12, P4).** `fn::mail_delivery_commit`,
appelée par le seul service de remise, fait valider par `lyxal_core` les champs scalaires de
chaque élément, la forme des listes d'identifiants, les résultats de réception et la taille
sérialisée de l'enveloppe (256 Kio) et de la structure (1 Mio) : primitives du Core appelées
directement pour chaque élément (`fn::mail_delivery_item_check`) et rapport par
`fn::validation_checks_report`, sans fermeture par contrôle, pour que le coût d'un élément ne
monte ni avec la taille du lot ni avec celle de l'enveloppe ; la forme détaillée de l'enveloppe
est garantie par le schéma de `mail_message`. Une valeur hors schéma fait refuser l'écriture par
la base (erreur de la base, pas un code `MAIL_*` : SurrealQL ne rattrape pas une erreur) et annule
le lot ; le service de remise reprend alors le lot élément par élément, et l'élément en cause
échoue seul. `fn::mail_message_create` (dépôt par un titulaire) garde la validation complète.

### Erreurs et événements

58 codes `MAIL_*` en master data (`error/<thème>/`, traduits en français et en anglais ;
`MAIL_CONTENT_UNAVAILABLE`, `MAIL_SCANNER_UNAVAILABLE`, `MAIL_QUEUE_CLAIM_LOST` et
`MAIL_SEND_LIMIT_EXCEEDED` à réessayer), dont 11 pour l'envoi (« État actuel : envoi ») et 8 pour la réception :
`MAIL_RELAY_DENIED`, `MAIL_RECIPIENT_DISABLED` (thème `adresses`), `MAIL_DELIVERY_REJECTED`,
`MAIL_MESSAGE_INFECTED`, `MAIL_SCANNER_UNAVAILABLE`, `MAIL_DELIVERY_BATCH_TOO_LARGE` (`reception`),
`MAIL_BLOCK_EXISTS`, `MAIL_BLOCK_NOT_FOUND` (`blocage`) ; ils ne sont jamais rendus à un serveur
expéditeur (la session SMTP les traduit). Événements publiés par `fn::event_publish`, sans donnée
personnelle (identifiants et compteurs seulement) : `mail.domain.created`, `mail.domain.deleted`,
`mail.account.created`, `mail.account.deleted` (fin de la purge), `mail.address.created`,
`mail.address.deleted`, `mail.quota.exceeded` (premier refus depuis le dernier passage sous le
quota ou le dernier changement de quota), et `mail.message.received` (décision S15) : un par
compte destinataire, dans la transaction de l'inscription d'un message d'origine `delivery`
(jamais pour une copie, un déplacement ou un dépôt du titulaire) ; charge utile : `tenant`,
`account`, `mailbox`, `message`, `email_id`, `size`, `received_at`, `has_attachment`,
`protection`, `reception` ; ni adresse, ni domaine, ni sujet, ni `Message-ID`.

### Banc SurrealQL

`tests/*.test.surql` (`scripts/ci/test_lyxal_modules.py`) : `reglages`, `domaines`, `comptes`,
`adresses`, `dossiers`, `messages`, `synchronisation`, `contenus`, `droits`, `plages`,
`organisations`, `reception` (résolution : relais refusé, inconnu, désactivé, sous-adresse,
alias, attrape-tout, `postmaster` avec et sans domaine, quota plein, taille de l'organisation ;
remise : ouverture, doublon, lot de 32, élément en erreur sans annuler les autres, lot de 33
refusé, origine, résultats de réception, compteurs égaux au contenu, dossier « Junk » ; événement
publié une fois par compte, sans adresse ni sujet), `blocages` (CIDR valide et invalide, doublon,
expiration, récidive, droits des entrées manuelles et des bannissements) —
chaque fonction appelée ; sessions système, compte de service, administrateur, titulaire, autre
membre, autre organisation ; écritures filtrées (`MAIL_WRITE_FORBIDDEN`) ; écritures directes
refusées par les gardes ; compteurs égaux au contenu réel ; suppression d'une organisation ;
`plages` : identifiants ordonnés, pages par UID à travers des UID effacés, pages par date à
travers des dates éloignées et des égalités, aucune fiche d'un autre compte lue par une plage
d'identifiants (autre membre, autre organisation, administrateur), vue par date fermée à
l'écriture directe, identifiant et UID gardés.

## État actuel : envoi (SurrealQL, sous-lot 6c du lot 6)

Plan : `implementation_plan.md` du crate, §5, §8 à §12, §14, §15. Le worker d'envoi, le client
SMTP, la signature DKIM et le dépôt authentifié (6d, 6e), puis les avis reçus et le transfert à la
réception (6f) s'appuient sur ces fonctions.

| Table | Contenu |
| :--- | :--- |
| `mail_submission` | Envoi `mail_submission:s<UUID v7 en hexadécimal>` : origine (`submission` : dépôt authentifié ; `module` : contrat public ; `forward` : transfert ; `dsn` : avis vers l'extérieur), compte et titulaire, expéditeur, adresses des champs d'en-tête contrôlées, adresse d'enveloppe et jeton de retour (unique, lisible du compte de service seulement), référence du module appelant, contenu (fichier chiffré `queue/<clé>.eml` du bucket `lyxal-mail`), préfixe (`DKIM-Signature`, compte de service seulement), demande d'avis (`RET`, `ENVID`), réception d'origine d'un transfert (`spf`, `envelope_dkim`), états `pending` → `queued` → `done`, destinataires ouverts, abandon, fin de vie (`expire_hours`) |
| `mail_queue_recipient` | Destinataire en file `⟨<clé de l'envoi>_<10^3 + rang>⟩` : adresse, domaine, route locale, `NOTIFY`, `ORCPT`, état (`scheduled`, `running`, `delivered`, `relayed`, `failed`, `expired`, `canceled`, `bounced`), essais, échéance, bail et jeton de réservation (compte de service seulement), dernier résultat (étape, codes, texte assaini, serveur, TLS), retard, avis produits |
| `mail_queue_due` | Échéancier ordonné `⟨<10^16 + µs>_<clé du destinataire>⟩` (E5) : un destinataire `scheduled` sous son échéance, `running` sous la fin de son bail ; tenu par les événements des destinataires, fermé à l'écriture directe |
| `mail_queue_destination` | Suspension d'une destination injoignable (5 min doublé, 2 h au plus) et échecs consécutifs |
| `mail_dkim_key` | Fiche publique d'une clé DKIM (`rsa-sha256` 2 048 bits, `ed25519-sha256`) : sélecteur, `p=`, chemin du secret `mail/dkim/<domaine>/<sélecteur>` (compte de service seulement), `pending` → `active` |
| `mail_send_counter` | Limites d'envoi : messages et destinataires d'un compte par jour UTC, messages des modules d'une organisation par heure, transferts par jour ; pris par l'événement de création d'un envoi, rendus à l'abandon, purgés |

`mail_domain` porte `module_senders` (parties locales des modules, jamais une adresse inscrite :
`MAIL_MODULE_SENDER_CONFLICT`) et `backscatter_protection` ; `mail_settings` les limites d'envoi
(organisation plafonnée par l'installation : 100 destinataires par message, 1 000 messages et
2 000 destinataires par compte et par jour, 10 000 messages de modules par heure, 10 000
transferts par jour) et, pour l'installation seulement, `retry_intervals` (5, 10, 20, 40, 80,
120 min, le dernier répété), `retry_jitter_percent` (10), `delay_notice_hours` (4),
`expire_hours` (120).

**Contrat public de dépôt (stable, décision E19, solution B)** pour les autres modules, sans
dépendance Cargo ni de manifeste : `fn::mail_submission_begin({ origin: "module", from,
header_from, recipients: [{ address, notify, orcpt }], size, smtputf8, eight_bit, dsn,
client_reference })` → `{ submission, tenant, bucket_name, key, max_size, return_address,
expires_at }` ; écriture du fichier par `StorageService::put` (bucket chiffré `lyxal-mail` de
l'organisation, clé rendue ; l'hôte crée le bucket s'il manque) ; `fn::mail_submission_commit({
submission, object })` → `{ submission, recipients, queued_at }` ; `fn::mail_submission_abort`,
`fn::mail_submission_get` (sans texte distant pour un module), `fn::mail_submission_cancel` ;
issue par les événements `mail.submission.delivered`, `.delayed`, `.failed`, `.bounced` (un par
destinataire ; charge : `tenant`, `submission`, `recipient`, `rank`, `origin`,
`client_reference`, `status`, `attempts`, `local`, `at`, et `outcome` ; ni adresse, ni domaine,
ni texte distant ; aucun pour un avis). Appelant : session système d'un hôte, ou compte de
service `mail.relay` (qui a aussi `storage.worker` pour clore) ; expéditeur parmi les
`module_senders` d'un domaine actif ; 100 destinataires, `module_messages_per_hour`.

| Fonction | Rôle | Droit |
| :--- | :--- | :--- |
| `fn::mail_sender_check` | Droit d'envoyer sous des adresses (adresses du compte, sous-adresses, alias qui le nomment dans `senders`, domaines actifs de l'organisation), rangs refusés | `mail.send` |
| `fn::mail_submission_begin` | Dépôt pending : droit, expéditeur (une seule règle, `fn::mail_sender_allowed`, revérifiée par la garde), destinataires, taille, limites | `mail.send`, `mail.relay` ou session système, `mail.worker` (transfert, avis) |
| `fn::mail_submission_commit` | Fichier contrôlé, destinataires mis en file (route locale posée), une transaction | compte de service, session système ; `mail.relay` pour un module |
| `fn::mail_submission_abort`, `_get`, `_cancel` | Abandon (compteurs rendus), lecture, annulation des destinataires en attente | titulaire, `mail.relay` (modules), compte de service ; jamais un administrateur |
| `fn::mail_queue_claim` | Réservation par une plage bornée de l'échéancier : échus et baux expirés (reprise après un arrêt brutal, sans essai compté), destinations suspendues et domaines saturés écartés, jeton et bail | compte de service, session système |
| `fn::mail_queue_renew`, `_prepare`, `_complete`, `_fail`, `_release` | Bail renouvelé ; préparation à la première réservation (jeton de retour, préfixe, message illisible) ; remises, échecs (échéance suivante, retard une fois, expiration 4.4.7, suspension) ; rendu sans essai ; toujours sous la garde du jeton (`lost`, `MAIL_QUEUE_CLAIM_LOST`) | idem |
| `fn::mail_queue_dsn_done`, `_stats`, `_purge` | Avis produits notés une fois ; mesures ; maintenance (fichiers des envois finis, envois de plus de 14 jours, dépôts abandonnés, jetons et compteurs échus) | idem |
| `fn::mail_return_record` | Avis reçu sur une adresse de retour : destinataire remis ou relayé → `bounced` | idem |
| `fn::mail_dkim_key_create`, `_activate`, `_signers`, `_pending` | Fiches publiques, activation, clés actives d'un message, travail de `mail.dkim.provision` | idem |
| `fn::mail_dkim_key_list` | Enregistrements DKIM à publier (`<sélecteur>._domainkey.<domaine>`, `v=DKIM1; k=…; p=…`) | `mail.domain.manage`, compte de service |

`fn::mail_recipient_resolve` rend aussi `kind` (`mailbox` ou `return`), `forward_to` et
`backscatter_protection` : une adresse `rp=<jeton>@<domaine>` valide se résout vers son envoi
(`kind: return`) ; la session SMTP la refuse comme inconnue jusqu'au sous-lot 6f. Les éléments des
lots du worker (`_complete`, `_fail`, `_renew`, `_release`, `_dsn_done`, `fn::mail_return_record`)
sont contrôlés par appels directs des primitives de `lyxal_core` et
`fn::validation_checks_report` (décision E32) ; les autres fonctions par
`fn::validation_fields_execute`. Rust : un wrapper d'une ligne par fonction dans `MailStore`,
modèles `models/{submission,queue,dkim}.rs`.

Banc : `tests/envoi.test.surql`, `file.test.surql`, `dkim.test.surql`, `retours.test.surql`
(droits d'expéditeur et usurpations, limites et compteurs, clôture, isolement des
organisations et de l'administrateur, contrat des modules, réservation et garde du jeton,
reprise d'un bail expiré, tentatives, retard, expiration, suspension, avis dus une fois,
événements sans donnée personnelle, échéancier égal à la table, adresses de retour) ;
`tests/it/queue.rs` (wrappers, reprise d'un bail, contrat des modules appelé par le nom des
fonctions sans type de `lyxal_mail`).

**Mesure de la réservation** (binaire `surreal` 3.3.4, serveur en mémoire, une connexion,
`scripts/ci` + script d'essai du sous-lot, 27 novembre 2026) : la plage de l'échéancier se lit en
2 ms pour 1 000 fiches, quelle que soit la taille de la file ; une réservation coûte environ
1,8 ms **par destinataire réservé** (garde et échéancier de chaque écriture, dont 1,35 ms pour le
`DELETE` de l'ancienne fiche de l'échéancier, coût de la base en 3.3.4 pour tout `DELETE`).
Réservation de 500 destinataires échus dans une file de 100 000 en attente : médiane 908 ms,
p95 1 073 ms (20 réservations rendues aussitôt) ; 916 ms dans une file de 10 000 : le coût ne
dépend pas de la taille de la file. Objectif du plan (20 ms) non tenu : voir `ROADMAP.md`.

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
dossier, une fiche de la vue par date par message.

### Mesures de la remise (`tests/it/measures.rs`, `scripts/bench/delivery/`)

Mesures du 26 novembre 2026. Machine de développement à 4 cœurs, base et banc sur la même
machine ; deux séries par mesure (séparées par « ; »). Objectifs (décision P10) : une remise seule
en 42 ms au plus ; 80 remises par seconde sur 4 cœurs partagés, aucune refusée. La colonne
« Départ » est la révision `2ed5fbb33`, avant les corrections de performance.

Corrections en place :

* contrôle des paramètres des neuf fonctions du chemin de remise par
  `fn::validation_fields_execute` (les validateurs nommés seulement) ;
* éléments d'un lot de `fn::mail_delivery_commit` contrôlés par appels directs des primitives
  (`fn::mail_delivery_item_check`, `fn::validation_checks_report`), fichier et résumé de son
  bucket lus en un appel (`fn::storage_object_get` avec `with_bucket`) ;
* pool de connexions de la session système (`[database] connections`,
  `lyxal_surreal::SurrealPool`) ;
* compteurs de volume de `lyxal_storage` répartis sur 64 lignes, sans ordre des écritures de
  fichiers dans le nœud.

**Banc Rust** : binaire d'essai optimisé (`cargo test -p lyxal_mail --release --test it --
--ignored --nocapture --test-threads 1 measures`), messages de 10 Kio remis par
`MailIngest::receive` (la remise seule, **sans** le dialogue SMTP ni les contrôles
d'authenticité : voir « Mesures de la réception SMTP » ci-dessous), support disque. Serveur SurrealDB 3.3.4 en mémoire joint par
`ws://` (`LYXAL_SURREAL_WS_URL`, `LYXAL_SURREAL_USER`, `LYXAL_SURREAL_PASS`), pool de
`LYXAL_SURREAL_CONNECTIONS` connexions (8 ici ; une par défaut) ; sans ces variables, base
embarquée dans le processus (`mem://`).

| Mesure | Départ (une connexion) | Aujourd'hui (pool de 8) |
| :--- | :-: | :-: |
| Une remise, sans concurrence (moyenne de 300) | 96 ms : ouverture 9,0 ; fichier chiffré 38,4 ; inscription 48,2 | **36,7 ; 38,2 ms** |
| `FileKeys::seal` | 13,1 ms | 2,3 ms (p95 2,5) |
| 100 comptes d'une organisation, 50 clients, 3 000 remises | 11,8 par seconde | **108,7 ; 104,2 par seconde**, aucune refusée |
| 100 comptes de deux organisations, 50 clients, 3 000 remises | 11,5 par seconde | **103,0 ; 107,1 par seconde**, aucune refusée |
| Un compte, 20 clients, 1 000 remises | 10,9 par seconde | 61,1 ; 61,9 par seconde (lots de 14 au plus) |
| Deux nœuds simulés (deux services de remise sur la même base), un compte, 20 clients, 1 000 remises | — | 62,1 ; 56,4 par seconde ; 1 refusée sur 1 000, puis aucune |

Les objectifs sur 4 cœurs partagés sont tenus. Sur deux nœuds, les remises refusées
(`SURREAL_DATABASE_ERROR` : un conflit d'écriture qui survit aux rejeux) restent sous le seuil de
1 % de la décision S11 (la ligne en conflit n'a pas été cherchée) ; les conflits rejoués sont
ceux de la fiche du compte, écrite par les deux nœuds (décision M6). En fin de chaque mesure, les
compteurs de volume de chaque organisation sont égaux aux fiches (`fn::storage_usage_verify`).
La base embarquée du binaire d'essai est près de deux fois plus lente que le serveur (une remise :
70,6 ms contre 37 ms, mesure antérieure aux deux dernières corrections) : ses chiffres ne valent
pas pour une installation, qui joint un serveur.

**Banc SurrealQL** (`scripts/bench/delivery/bench_delivery.py`, temps de calcul de la base seule,
relevé dans le serveur, chaque appel public dans sa transaction ; départ : `--ref 2ed5fbb33`) :

| Appel d'une remise (moyenne de 100) | Départ | Aujourd'hui |
| :--- | :-: | :-: |
| `fn::mail_delivery_begin` | 6,4 ms | 3,9 ms |
| `fn::storage_object_begin` | 8,6 ms | 5,4 ms |
| `fn::secrets_tenant_key_ring` (lue par `FileKeys::seal`) | 11,4 ms | 2,1 ms |
| `fn::storage_object_commit` | 8,5 ms | 5,4 ms |
| `fn::mail_delivery_commit` (un message) | 39,7 ms | 15,4 ; 15,0 ms |
| **Total base** | **74,6 ms** | **31,9 ; 31,0 ms** |
| Par message, lot de 8 / 16 / 32, enveloppe de 3 destinataires | — | 10,7 / 9,9 / 10,1 ms ; 10,5 / 10,5 / 10,2 ms |
| Par message, lot de 8, enveloppe de 150 destinataires | — | 15,8 ; 17,0 ms |

| Remises par seconde, une connexion par client | 1 client | 2 | 4 | 8 | 16 |
| :--- | :-: | :-: | :-: | :-: | :-: |
| Une organisation par client, départ | 12,9 | 24,9 | 51,3 | 52,1 | 49,6 |
| Une organisation par client, aujourd'hui | 30,0 | 57,4 | 115,3 | 113,3 | 111,5 |
| Une seule organisation, départ | 13,2 | 19,3 | 24,0 | 21,0 | 17,2 |
| Une seule organisation, aujourd'hui | 30,1 | 58,9 | 111,5 | 107,0 | 105,2 |
| Une seule organisation, quota défini (`--quota`) | 26,7 | 49,6 | 106,1 | 101,9 | 99,7 |

Le banc ne rejoue pas une transaction refusée : 5, 34, 44 et 115 refusées à 2, 4, 8 et 16
clients dans une seule organisation (2,5 % à 4 clients ; 960 à 4 clients avant la répartition des
compteurs), autant avec un quota défini. Ce sont ces conflits que `lyxal_storage` rejoue (aucune
remise refusée au banc Rust).

Ce que montrent les mesures :

* **Le contrôle des paramètres pesait plus de la moitié d'une remise.** En SurrealDB 3.3, une
  définition de fonction est relue et réanalysée à chaque transaction, et une fonction qui ne
  fait que lire charge tout son graphe d'appels : `fn::validation_object_execute` fait charger
  les 177 validateurs du Core à chaque appel public (7 à 9 ms). Les autres fonctions publiques du
  courrier paient encore ce coût.
* **Une seule connexion ne se partage pas les cœurs du serveur** : ses requêtes s'entrelacent,
  mais le débit d'un nœud y reste proche d'une remise à la fois (29 par seconde). Avec le pool,
  les appels se répartissent sur les cœurs.
* **Compteurs de volume de `lyxal_storage`** : deux lignes par organisation faisaient passer une
  à une les écritures de fichiers d'une organisation (62 remises par seconde). Répartis sur 64
  lignes (`crates/lyxal_storage/README.md`, « Compteurs de volume »), une organisation va aussi
  vite que deux. Le quota de volume est contrôlé sur l'instantané de la transaction : deux
  écritures simultanées peuvent le dépasser ensemble de leur taille.
* **L'inscription reste le premier poste** (`fn::mail_delivery_commit`, 15 ms). Au banc Rust,
  l'allègement de l'inscription (3 ms) reste dans la dispersion d'une série à l'autre : les lots y
  sont petits. `MAX_BATCH` reste à 32 (décision P11).

**Clés « fichiers » (décision S13).** `FileKeys::seal` : 2,5 ms en moyenne sur le serveur (p95
2,9 ms ; 3,7 ms sur la base embarquée), `FileKeys::open` : 2,5 ms, presque entièrement la lecture
du trousseau en base (`fn::secrets_tenant_key_ring`) ; le scellement
pèse 7 % d'une remise. Avec le cache de `lyxal_secrets` (`FileKeys::with_cache`), une ouverture
coûte 0,01 ms (299 succès pour 300 appels) ; un scellement coûte toujours 2,4 ms, parce que la
règle du cache (ne jamais sceller par une clé qui n'est plus active) impose de relire le
trousseau. **Le cache ne réduit donc pas le coût d'une remise** ; il sert les lectures (lot 8).
Il est activé par l'hôte `lyxal-groupware`.

### Mesures de la réception SMTP (`tests/it/smtp_load.rs`)

Mesures du 26 novembre 2026, même machine (4 cœurs partagés par les clients SMTP, la session,
le service de remise et le serveur SurrealDB 3.3.4 en mémoire joint par `ws://`, pool de 8
connexions), binaire d'essai optimisé (`cargo test -p lyxal_mail --release --test it --
--ignored --nocapture --test-threads 1 smtp_load`). Chemin complet : dialogue SMTP sur une socket
locale (`EHLO` une fois par connexion, puis `MAIL FROM`, `RCPT TO` et `DATA` par message, sans
délai de Nagle comme dans l'hôte), contrôles SPF, DKIM, DMARC et nom inverse (résolveur
`StaticResolver` : aucun délai de réseau DNS), chaîne de remise sans antivirus, écriture chiffrée
sur disque, inscription ; messages de 10 Kio. Latence : de la fin des données (`CRLF.CRLF`) à la
réponse `250`. Objectifs (§10.5 du plan du lot 5) entre parenthèses.

| Mesure | Débit | Latence fin des données → `250` (p50 / p95) | Refus |
| :--- | :-: | :-: | :-: |
| Un client, un compte, 200 messages | 17,9 par seconde | 45,0 / 59,8 ms (p95 ≤ 100 ms : **tenu**) | 0 |
| Un compte, 20 clients, 1 000 messages | 58,6 par seconde (≥ 100 : **non tenu**) | 314,7 / 368,4 ms | 0 (objectif 0 : **tenu**) ; 103 lots, 12 au plus |
| 100 comptes, 50 clients, 3 000 messages | 88,6 par seconde (≥ 300 : **non tenu** ; ≥ 200 sur serveur : **non tenu**) | 458,0 / 842,0 ms | 0 ; aucun conflit rejoué |

Ce que montrent les mesures : la session ajoute environ 10 ms par message à la remise seule
(résolution du destinataire, lecture MIME, contrôles, en-têtes), et le débit reste celui de la
remise mesurée plus haut (105 remises par seconde sur ces 4 cœurs) : la base et l'écriture
chiffrée en sont le facteur limitant, partagé ici avec les clients. L'objectif de 300 remises par
seconde (seuil C5) n'est **pas** atteint sur cette machine ; il reste à mesurer sur la machine de
référence (base et hôte séparés, plus de cœurs), et les pistes déjà relevées (moins
d'allers-retours P8, scellement depuis le cache P7) attendent une décision (`ROADMAP.md`). Non
mesurés : deux nœuds par la session SMTP (mesurés par la remise seule, plus haut), 1 000
sessions ouvertes et lentes (mémoire), résolveur DNS réel, antivirus réel.

## État actuel : service Rust

| Élément | Rôle |
| :--- | :--- |
| `MailStore`, `models` | Un appel typé d'une ligne par fonction publique `fn::mail_*` (45 fonctions, `LyxalSurrealCall::call_fn`), paramètres `XxxParams` et résultats nommés (`SurrealValue`) ; la session du client détermine l'appelant ; réception : `models::{RecipientResolveParams, ResolvedRecipient, RecipientAccount, DeliveryBeginParams, DeliveryReservation, DeliveryCommitParams, DeliveryItem, DeliveryCommitResult, DeliveryItemResult, Reception}` ; liste de blocage : `BlockCreateParams`, `NetworkBlock`, `BlockReason`, `BlockListParams`, `BlockPage`, `BlockDeleteParams`, `BlockActiveParams`, `ActiveBlocks` |
| `MailIngest`, `Delivery`, `DeliveryFlags` | Dépôt d'un message brut par son titulaire (`APPEND` au lot 8) : mémoire réservée sur le budget des connexions (`MemoryBudget`, facultatif), lecture MIME par `lyxal_mail_proto`, `fn::mail_content_begin` sous la session de l'appelant, écriture chiffrée par `lyxal_storage` sous la session système de l'hôte dans le bucket chiffré `lyxal-mail` de l'organisation (créé à la première écriture, sur le support réglé par l'hôte, puis gardé en mémoire du nœud), `fn::mail_content_attach` (session système), `fn::mail_message_create` (appelant) ; écritures rejouées trois fois au plus sur conflit de transaction |
| `MailIngest::receive`, `ReceivedDelivery`, `DeliveryOutcome`, `delivery_key` | Remise d'un message reçu par SMTP à un compte, sous la session système, en quatre allers-retours au lieu de six : `fn::mail_delivery_begin` (un message déjà remis s'arrête là : `DeliveryOutcome::Duplicate`), écriture chiffrée du fichier, `fn::mail_delivery_commit` à son tour dans l'ordre du compte ; `delivery_key` : empreinte d'idempotence BLAKE3 (`lyxal_crypto`) de l'adresse inscrite, de l'expéditeur de l'enveloppe et des octets reçus (S8) ; l'élément refusé d'un lot (`MailError::Refused`) laisse son fichier supprimé |
| `AccountQueue`, `QueueStats`, `MAX_BATCH` | Ordre des inscriptions par compte dans le nœud (S11) : 1 024 compartiments, un tour d'écriture chacun ; les inscriptions d'un compte qui attendent déjà sont inscrites ensemble, 32 au plus par appel, sans délai ajouté ; lot refusé en entier (hors conflit rejoué) : repris élément par élément ; relevé des lots, conflits rejoués et lots repris |
| `MailContent`, `OpenedContent` | Lecture d'un message, entière ou par plage d'octets du message brut (une partie MIME par ses positions) : `fn::mail_content_open` contrôle les droits de l'appelant, `lyxal_storage` ne déchiffre que les segments de la plage ; un segment altéré met fin au flux par une erreur, jamais par une fin normale |
| `MailMaintenance`, `MaintenanceReport` | Un passage, interrompu entre deux appels à l'arrêt du serveur : `fn::mail_content_expire`, `fn::mail_tombstone_purge`, `fn::mail_delivery_purge`, `fn::mail_account_purge_step` par paquets ; exécutée par `lyxal_scheduler` (tâche `mail.maintenance` de l'hôte, toutes les 10 minutes) |
| `DeliveryPipeline`, `ReceivedMessage`, `RecipientTarget`, `DeliveryVerdict`, `PipelineResult`, `AccountOutcome` | Chaîne de remise d'un message reçu (S9, S10), ordre fixé par le type (champs nommés `antivirus`, `spam`, `filters`, `index`, `encryption`) : une analyse antivirus par message sur le clair avant tout dépôt (`ContentScanner` de `lyxal_storage` ; infecté : refus définitif, aucune quarantaine ; injoignable : refus temporaire ; sans antivirus : `not_scanned`), anti-spam vide (`none`), filtres (dossier « Junk » si la quarantaine DMARC est appliquée), index vide, puis dépôt chiffré par compte (`MailIngest::receive`), en parallèle ; un compte désigné par plusieurs destinataires (adresse et alias) n'est servi qu'une fois, sous la plus petite de ces adresses (empreinte d'idempotence indépendante de l'ordre des `RCPT TO`) ; réponse unique : tout inscrit (ou déjà inscrit) → accepté, un échec → refus temporaire (S8) |
| `smtp::SmtpInboundHandler`, `SmtpConfig`, `SmtpServices` | Réception SMTP (`SessionHandler` de l'écoute `smtp`), décrite ci-dessous (« `lyxal_mail::smtp` ») |
| `smtp::BlockList`, `BlockRefreshWorker`, `Network`, `Offence` | Liste de blocage du nœud (S18) : réseaux de `mail_network_block` relus toutes les 30 s par le worker `lyxal_mail:mail.block_refresh` (criticité `Optional` ; un échec garde la dernière liste, compté), appliqués par l'hôte à l'acceptation ; bannissement d'une adresse (`/32`, `/64`) après 3 sessions fautives en 10 minutes (trop d'erreurs, recherche d'adresses, contrebande), écrit en base par `fn::mail_block_create` (durée calculée par la base) et appliqué aussitôt sur le nœud |
| `MailModule`, `MailHealthCheck`, `RequiredHost` | `LyxalModule` du module (descripteur égal au manifeste) ; sonde : réglages lisibles (sinon « malade »), support de stockage et service de clés des fichiers présents (sinon « dégradé »), antivirus de la chaîne joignable (`with_scanner`), DNS qui répond sur le nom témoin `smtp.hostname` (`with_dns_probe`, une requête par minute au plus ; une absence est une réponse, seule une panne dégrade), et, avec `with_required_host`, un nœud vivant de l'hôte requis (`RequiredHost` : `lyxal_server`, lu dans `runtime_node` par `PresenceStore`) vu depuis moins de `REQUIRED_HOST_ABSENCE_LIMIT` (10 minutes ; sinon « dégradé », « aucun nœud lyxal_server vivant… ») ; l'hôte la compose avec celle des écoutes (une sonde par module) |
| `MailError` | Code `MAIL_*` (dont `MAIL_MESSAGE_MALFORMED`, `MAIL_CONTENT_UNAVAILABLE` à réessayer, et `Refused` : code de l'élément refusé d'un lot de remise) ou `STORAGE_*` propagé ; `is_retryable()`, `is_business()` ; aucune adresse, aucun sujet, aucun contenu |

**Chiffrement obligatoire (décision M1).** Sans support de stockage ou sans clé maîtresse du
coffre-fort, rien n'est réservé ni écrit (`MAIL_CONTENT_UNAVAILABLE`, à réessayer) et aucun
message n'est lu ; jamais de repli en clair. Un bucket `lyxal-mail` trouvé en clair dans
l'organisation (créé par ailleurs avant la première remise : `lyxal_storage` n'en réserve pas le
nom) fait refuser chaque dépôt avant toute écriture (`MAIL_CONTENT_UNAVAILABLE`) jusqu'à ce que
l'administrateur le supprime ; le bucket est cherché sur toutes les pages de la liste des buckets
de l'organisation. Hiérarchie des clés : clé maîtresse du coffre-fort →
clé « fichiers » de l'organisation (`lyxal_secrets` ; cache des ouvertures de 60 s activé par
l'hôte, S13) → clé propre à chaque
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

**Deux hôtes sur la même base (exigence d'exploitation).** `lyxal-server` doit tourner à côté de
`lyxal-groupware` : ses tâches `storage.cleanup` (octets des messages effacés) et
`secrets.maintenance` (rotation des clés « fichiers », rescellement des clés des messages) ne
sont exécutées que par lui. Sans nœud `lyxal_server` vivant depuis plus de 10 minutes, la sonde
du courrier passe à « dégradé ». Le bucket `lyxal-mail` de chaque organisation est créé chiffré
et sans événements `storage.object.*` (`emit_events` faux, décision S14) ; sans clé maîtresse,
`lyxal-groupware` refuse de démarrer dès qu'un bucket chiffré existe
(`GROUPWARE_MASTER_KEY_MISSING`).

**Ordre des écritures dans le nœud (décision S11).** Le compteur de modifications reste par
compte (M6) : `AccountQueue` fait passer une à une les inscriptions d'un même compte et groupe
celles qui attendent, ce qui supprime les conflits entre remises d'un nœud. Les fichiers, eux,
s'écrivent sans ordre imposé par le nœud : les compteurs de volume de `lyxal_storage`
(`storage_usage`) sont répartis sur 64 lignes par organisation et par bucket, deux écritures
simultanées ne se heurtent que si elles tirent la même ligne, et `lyxal_storage` rejoue alors
l'ouverture ou la fin d'écriture (six essais au plus). Entre deux nœuds, les conflits sur la
fiche d'un compte restent rejoués par le service de remise.

**Projection d'un message lu** (`mime`). Enveloppe typée (date de l'en-tête `Date`, sujet,
adresses à plat avec leur groupe, `Message-ID`, `In-Reply-To`, `References`), structure MIME
rangée telle quelle (types, paramètres, disposition, nom, positions `header` / `body` / `end`,
tailles, lignes, parties ou message joint avec son enveloppe, la date brute), clés de fil et sujet
de base. Un message reçu se garde même hors norme : textes et listes plus longs que le schéma de
`mail_message` sont raccourcis (texte coupé à une limite de caractère, `References` réduit aux
1 000 plus récents) au lieu de faire refuser le message ; les entrées restent contrôlées par
`fn::mail_message_create` et `fn::mail_delivery_commit`.

Dépendances Rust : `lyxal_crypto` (DKIM, BLAKE3 de l'empreinte d'idempotence), `lyxal_mail_proto`,
`lyxal_runtime`, `lyxal_storage`, `lyxal_surreal`, `surrealdb`, `tokio`, `tokio-util`,
`async-trait`, `thiserror`, `tracing`, `bytes`, `futures`, `hickory-resolver`, `idna`, `psl`
(liste des suffixes publics, version figée) ; aucune crate cryptographique directe (le chiffrement
passe par `lyxal_storage` et `lyxal_secrets`).

Vérification : `cargo test -p lyxal_mail` (base embarquée, support disque, clé maîtresse
éphémère, jetons de session de test) : dépôt de bout en bout puis liste, lecture entière et
d'une partie déchiffrée, octets rangés chiffrés (`LXS1`), drapeaux, déplacement (même
`email_id`), effacement, maintenance qui retire le contenu et son fichier ; refus à réessayer
sans service de clés ou sans clé maîtresse (rien n'est réservé) ; message illisible refusé avant
toute réservation ; inscription refusée puis maintenance ; isolement entre membres et entre
organisations au travers des services (lecture, liste, dépôt) ; maintenance réservée à la
session système ; purge d'un compte supprimé avec ses contenus et fichiers ; sonde « dégradé »
sans nœud vivant de l'hôte requis au-delà de l'absence tolérée, saine dès qu'un nœud de cet hôte
(et non d'un autre) bat, de nouveau « dégradé » après son arrêt ; réception (`tests/it/reception.rs`) :
destinataire résolu, message remis chiffré puis lu par son titulaire, nouvel essai sans doublon
ni fichier, un événement sans adresse ni sujet, alias (un contenu et un événement par compte),
dossier « Junk », élément refusé pour quota à l'inscription (fichier supprimé, voisin inscrit),
100 remises de 20 clients simultanés dans un compte (UID de 1 à 100, compteurs exacts, aucun
conflit, moins d'appels que de messages), lot dont un élément sort du schéma (repris élément par
élément), purge des fiches d'idempotence, liste de blocage, attrape-tout et `postmaster` par les
appels typés. L'hôte
(`cargo test -p lyxal-groupware`, essai `mail_service`) : démarrage avec clé maîtresse et support
disque, sonde, dépôt et lecture par les services de l'hôte, maintenance exécutée par le
planificateur, planification non recréée au redémarrage, aucun événement `storage.object.*` ;
sans clé : sonde « dégradé », dépôt refusé à réessayer ; sans clé avec un bucket chiffré en
base : démarrage refusé (`GROUPWARE_MASTER_KEY_MISSING`).

## État actuel : `lyxal_mail::smtp` (réception SMTP)

`SmtpInboundHandler` sert l'écoute `protocol = "smtp"` de `lyxal-groupware` (port 25). L'hôte lui
remet `SmtpServices` : session système (`MailStore`), résolveur DNS du nœud (`HickoryResolver`,
un par nœud), chaîne de remise (`DeliveryPipeline`, antivirus de `[storage.antivirus]`), budget
mémoire des connexions, liste de blocage. Syntaxe : `lyxal_mail_proto::smtp`. Écrit pour Lyxal sur
le modèle de Stalwart (`smtp/inbound`) et de Mox (`smtpserver`), sans code repris (`SOURCES.md`).

| Étape | Comportement |
| :--- | :--- |
| Accueil | `220 <hostname> ESMTP` (aucun nom ni version de logiciel) ; nom inverse demandé aussitôt (contrôle avancé pendant que la session attend le client, aucune tâche hors de la session) |
| `EHLO` / `HELO` | Nom de domaine (converti en forme ASCII) ou adresse entre crochets, sinon `501 5.5.4` ; un nom qui ne correspond pas à l'adresse n'est jamais refusé ; SPF de l'identité HELO lancé ; extensions (S5) : `PIPELINING`, `SIZE`, `8BITMIME`, `SMTPUTF8`, `ENHANCEDSTATUSCODES`, `STARTTLS` (écoute `starttls`, une fois), `CHUNKING` ; jamais `DSN`, `AUTH`, `BINARYMIME`, `REQUIRETLS` |
| États (§7.1) | Avant `EHLO` : `EHLO`, `HELO`, `QUIT`, `NOOP`, `RSET`, `HELP` seulement (`503 5.5.1`) ; `VRFY` → `252 2.5.0` ; `EXPN`, `AUTH`, `LHLO`, `ETRN`, `ATRN`, `BURL` → `502 5.5.1` ; `MAIL` imbriqué, `RCPT` sans `MAIL` → `503 5.5.1` ; `DATA` sans destinataire → `554 5.5.1` |
| `STARTTLS` | `220 2.0.0` puis mise à niveau par l'hôte ; octets reçus derrière la commande : fermeture (injection) ; état remis à « Accueil » (RFC 3207 §4.2) |
| `MAIL FROM` | Paramètres DSN et `BODY=BINARYMIME` → `555 5.5.4` ; `SIZE` au-delà de `max_message_bytes` → `552 5.3.4` ; `max_messages_per_session` atteint → `421 4.7.0` ; cadence par réseau (`messages_per_network_per_minute`, `/32`, `/26`, `/21`) → `450 4.7.1` ; SPF de `MAIL FROM` lancé |
| `RCPT TO` | `fn::mail_recipient_resolve` (domaine en forme ASCII, `idna`, S16) : domaine étranger, adresse littérale, route source → `550 5.7.1` (aucun relais) ; inconnu, partie locale UTF-8 → `550 5.1.1` ; désactivé → `550 5.2.1` ; quota plein → `452 4.2.2` ; `SIZE` au-delà de la taille de l'organisation → `552 5.3.4` ; `max_recipients` → `452 4.5.3` ; base indisponible → `451 4.3.0` ; à partir du 5ᵉ refus, chaque réponse retardée d'une seconde ; au 20ᵉ, `421 4.7.0`, fermeture et récidive comptée |
| `DATA` / `BDAT` | Données avant `354` → `554 5.5.0` et fermeture ; fin reconnue sur `CRLF.CRLF` seulement ; mémoire réservée par pas de 64 Kio (classe « réception SMTP » ; épuisée → `452 4.3.1`), gardée jusqu'à la réponse et agrandie, avant de la faire, pour la copie à ranger avec nos en-têtes ; au-delà de la taille, lecture jusqu'au bout sans garder les octets → `552 5.3.4` ; CR ou LF isolé (contrebande, S7) → `500 5.5.2`, session poursuivie, erreur et récidive comptées ; octet nul → `554 5.6.0` ; délai entre blocs `data_timeout_seconds`, débit minimal après 30 s |
| Contrôles du message | Lecture MIME (`554 5.6.0`) ; exactement un `From` (`550 5.6.0`) ; plus de 10 domaines d'auteur → `550 5.7.1` ; plus de 50 `Received` → `554 5.4.6` ; DKIM, DMARC (avec le SPF de `MAIL FROM`), nom inverse ; politique (S6) : DMARC `reject` → `550 5.7.1`, `quarantine` → « Junk », `temperror` avec `reject` → `451 4.7.5`, `dmarc_enforce = false` → résultat seulement ; jamais de refus sur SPF ou DKIM seuls |
| En-têtes ajoutés | `Return-Path`, `Received` (nom annoncé, nom inverse confirmé et valide seulement, adresse, notre nom, `ESMTP` / `ESMTPS` / `UTF8SMTP` / `UTF8SMTPS`, identifiant, version et suite TLS, date ; aucun destinataire), `Authentication-Results` (après retrait de ceux qui portent notre `authserv-id`) |
| Remise et réponse | `DeliveryPipeline` puis réponse unique : `250 2.0.0 Ok <identifiant>`, infecté `554 5.7.1`, message que nos en-têtes font passer au-delà de la taille de l'organisation `552 5.3.4`, échec partiel ou antivirus injoignable `451 4.3.0` (nouvel essai sans doublon, S8) |
| Fin de session | `QUIT` → `221 2.0.0` ; `max_errors` erreurs → `421 4.7.0` et récidive comptée ; attente d'une commande au-delà de `command_timeout_seconds` ou de `session_max_seconds` → `421 4.4.2` ; arrêt du nœud → `421 4.3.2` à la commande suivante |

Réglages (`SmtpConfig`, section `[smtp]` de l'hôte, décision S19) : `hostname` (obligatoire),
`max_message_bytes` (50 Mio), `max_recipients` (100), `max_messages_per_session` (50),
`max_errors` (10), `max_line_bytes` (4 096), `command_timeout_seconds` (300),
`data_timeout_seconds` (180), `session_max_seconds` (1 800), `data_min_bytes_per_second`
(1 024), `messages_per_network_per_minute` (60, 180, 540), `dmarc_enforce` (vrai).

Journal : une ligne par transaction (identifiant de session, réseau masqué `/24` ou `/48`,
résultats SPF, DKIM, DMARC, nom inverse, nombre de destinataires, taille, décision, code) ; ni
adresse, ni sujet, ni contenu. Mesures (`SmtpInboundHandler::snapshot`, `/metrics` de l'hôte) :
sessions, messages acceptés, refusés par motif (relais, inconnu, désactivé, quota, taille, DMARC,
antivirus, contrebande, limites, illisible, politique, temporaire), destinataires acceptés et
refusés par motif, résultats SPF / DKIM / DMARC, remises dupliquées évitées, nombre et durée des
remises, lots, conflits rejoués et lots repris de l'ordre des inscriptions, requêtes et pannes
DNS, bannissements écrits, réseaux bloqués, relectures de la liste en échec. Les succès du cache
DNS ne sont pas mesurés (`hickory-resolver` ne les expose pas).

Vérification : `cargo test -p lyxal_mail` (`tests/it/smtp.rs`, dialogues scriptés sur une vraie
socket, base embarquée, `StaticResolver`) : réception de bout en bout (extensions annoncées,
en-têtes ajoutés, `Authentication-Results` forgé retiré, bourrage retiré, résultats de réception,
événement, mesures) ; conformité par commande et par état ; `PIPELINING` (réponses dans l'ordre,
groupe qui finit par `DATA`) et `BDAT` ; refus sans relais (domaine étranger, `%`, route source,
adresse littérale, UTF-8 avec et sans `SMTPUTF8`, `max_recipients`) ; variantes de contrebande et
données avant `354` ; usurpation (notre domaine en `p=reject` sans DKIM, DKIM valide d'un autre
domaine, plusieurs domaines dans un `From`, `From` multiple ou absent), quarantaine, boucle,
`dmarc_enforce = false` ; antivirus (EICAR refusé, injoignable → `451`) ; échec partiel → `451`
puis nouvel essai sans doublon, alias et adresse directe vers le même compte ; limites (taille,
messages par session, cadence) ; bannissement après trois sessions fautives, relu par un second
nœud ; recherche d'adresses ralentie puis fermée ; STARTTLS (injection refusée, état remis à
zéro, `ESMTPS` et `tls` dans le message rangé). Mesures de charge : « Mesures de la réception
SMTP » plus haut.

## État actuel : `lyxal_mail::submission` (dépôt authentifié, sous-lot 6e)

Plan : `implementation_plan.md` du crate, §8 (décisions E14 à E17). Écoutes `protocol =
"submission"` de l'hôte : port 587 (STARTTLS exigé) et port 465 (TLS implicite, RFC 8314),
servies par `SubmissionHandler`. La session est celle de la réception (même machine d'états,
mêmes lectures de `DATA` et de `BDAT`, fins de ligne, budget mémoire, délais et limites de
session de `SmtpConfig`), dans son rôle « dépôt » :

| Étape | Règle | Réponses |
| :--- | :--- | :--- |
| `EHLO` | `AUTH PLAIN LOGIN` annoncé **seulement sous TLS** ; `DSN` annoncé ; jamais `REQUIRETLS` | |
| Avant TLS | `AUTH` et `MAIL` refusés | `530 5.7.0 Must issue a STARTTLS command first` |
| `AUTH PLAIN` / `LOGIN` | échange de `lyxal_mail_proto` ; mot de passe d'application vérifié par l'hôte (`SubmissionAuthenticator`, service de `lyxal_auth`, droits recalculés par la base) ; permission `mail.send` exigée | `235 2.7.0` ; faux, révoqué ou sans `mail.send` : `535 5.7.8` ; adresse bloquée par `lyxal_auth` : `421 4.7.0` ; base indisponible : `454 4.7.0` ; troisième échec : `421 4.7.0` et fermeture ; déjà authentifié : `503 5.5.1` |
| `MAIL FROM` | `AUTH` exigé ; `RET`, `ENVID`, `AUTH=` acceptés ; adresse contrôlée par `fn::mail_sender_check` **au nom de l'utilisateur** | `530 5.7.0 Authentication required` ; usurpation : `550 5.7.1 Sender address not allowed` |
| `RCPT TO` | domaine extérieur : aucune vérification ; domaine de l'installation : `fn::mail_recipient_resolve` (session système) ; `NOTIFY`, `ORCPT` gardés ; adresse littérale, route source, `postmaster` seul refusés | inconnu `550 5.1.1`, désactivé `550 5.2.1`, invalide `553 5.1.3`, au-delà de `smtp.max_recipients` `452 4.5.3` |
| Fin des données | lecture MIME ; exactement un `From`, un `Sender` au plus ; chaque adresse de `From`, `Sender`, `Resent-From`, `Resent-Sender` (10 au plus) contrôlée par `fn::mail_sender_check` ; antivirus ; `Received: from <EHLO> by <hostname> with ESMTPSA id <session>.<n>` **sans adresse IP ni compte** ; `Bcc` et `Resent-Bcc` retirés ; `Date` et `Message-ID: <UUID v7@hostname>` ajoutés s'ils manquent ; puis `MailIngest::queue_submission` | `250 2.0.0 Ok queued as <clé de l'envoi>` **après** l'inscription ; illisible `554 5.6.0` ; `From` absent, multiple ou sans adresse `550 5.6.0` ; usurpation `550 5.7.1` ; infecté `554 5.7.1` ; limite d'envoi `451 4.7.1` ; destinataires au-delà de la limite de l'organisation `550 5.5.3` ; taille `552 5.3.4` ; toute panne `451 4.3.0` |

`MailIngest::queue_submission` : `fn::mail_submission_begin` au nom de l'utilisateur, fichier
chiffré écrit par `lyxal_storage` (bucket `lyxal-mail` de l'organisation, créé s'il manque) et
`fn::mail_submission_commit` sous la session système ; écriture en échec ou clôture refusée :
envoi abandonné (`fn::mail_submission_abort`, compteurs rendus) et fichier supprimé ; panne dont
on ne sait pas si la clôture a eu lieu : rien n'est supprimé, la maintenance retire l'envoi
`pending` au bout d'une heure. La signature DKIM, l'adresse de retour et le préfixe sont posés
par le worker d'envoi à la première réservation (`fn::mail_queue_prepare`).

**Aucun bannissement réseau** sur le dépôt (ni pour les échecs d'authentification, ni pour les
autres fautes : un bureau entier partage souvent une adresse) ; la liste de blocage de
l'installation reste appliquée à l'acceptation, et `lyxal_auth` bloque l'adresse après trop
d'échecs de mots de passe d'application. Journal : une ligne par authentification (issue,
réseau masqué) et par dépôt (session, destinataires, taille, décision, code), sans identifiant,
mot de passe, adresse, sujet ni contenu. Mesures (`SubmissionHandler::snapshot`) : sessions,
messages mis en file et refusés par motif, destinataires, authentifications par issue
(`auth_refused.invalid`, `.forbidden`, `.locked`, `.unavailable`, `.malformed`), commandes
refusées avant TLS ou avant `AUTH`, usurpations refusées (`submission_spoofing`).

Essais : unitaires (adresses d'expéditeur, groupes, mots encodés, domaines Unicode, `Bcc`
retiré, `Date` et `Message-ID` ajoutés) ; dans l'hôte, sur de vraies sockets
(`apps/lyxal-groupware/tests/it/submission.rs`).

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

## État actuel : `lyxal_mail::dns` et `lyxal_mail::auth`

Contrôles employés par la session SMTP entrante (`lyxal_mail::smtp`).

| Élément | Rôle |
| :--- | :--- |
| `dns::MailResolver`, `DnsError`, `Answer` | Seule porte vers le DNS (TXT, MX, A, AAAA, PTR) ; « n'existe pas » et « aucun enregistrement » (définitifs) distingués de la panne (`temperror`) |
| `dns::HickoryResolver`, `DnsConfig` | `hickory-resolver` 0.26 sans DNSSEC ni DNS chiffré (décision S3), une instance par nœud ; serveurs du système ou liste explicite, délai (5 s) et essais (2) par requête, cache de 16 384 réponses, TTL bornés à 1 h (positifs) et 5 min (négatifs), fichier `hosts` non lu ; noms toujours interrogés comme noms complets |
| `dns::StaticResolver` | Résolveur des essais : réponses, pannes et délais simulés, compte des requêtes ; aucun essai n'interroge le vrai DNS |
| `auth::SpfVerifier` | SPF (RFC 7208) sur `MAIL FROM` (ou `postmaster@<HELO>`) et sur HELO ; macros ; 10 termes DNS, 2 réponses vides, 10 noms par `mx` / `ptr`, 20 s au plus ; domaines Unicode convertis en A-label (`idna`) |
| `auth::DkimVerifier` | DKIM (RFC 6376, 8301, 8463) : balises, clé `<s>._domainkey.<d>`, en-têtes de `h=` du bas vers le haut ; octets signés et vérification par `lyxal_crypto::dkim` ; 5 signatures au plus ; `rsa-sha1`, `h=` sans `From`, `i=` hors de `d=`, échéance passée, clé révoquée : `permerror` ; `t=` à plus de 5 min dans le futur : `neutral` ; `l=` plus court que le corps : `policy` ; clé `t=y` signalée (ignorée par DMARC) |
| `auth::DmarcVerifier`, `author_domains`, `DmarcDisposition` | DMARC (RFC 7489) pour chaque domaine de `From` (10 au plus) : `_dmarc.<domaine>` puis domaine d'organisation, alignement souple ou strict, `p`, `sp`, `pct` ; décision S6 : `reject` → refus, `quarantine` → « Junk », `temperror` avec `reject` → `451`, jamais de refus sur SPF ou DKIM seuls, `dmarc_enforce` faux → aucun effet ; le plus sévère de plusieurs domaines l'emporte |
| `auth::OrganizationalDomain`, `EmbeddedSuffixList`, `PublicSuffixList` | Domaine d'organisation : `EmbeddedSuffixList`, la « Public Suffix List » embarquée par la crate `psl` à version figée (décision S4 ; `=2.1.263`, liste du jour de sa publication ; noms en forme ASCII convertis pour la recherche) ; `PublicSuffixList`, liste au même format fournie par l'appelant (essais) |
| `auth::Iprev` | Nom inverse confirmé (RFC 8601 §3), informatif |
| `auth::AuthenticationResults`, `strip_forged_results` | En-tête `Authentication-Results` (RFC 8601) : `spf` (`smtp.mailfrom` : domaine seulement, `smtp.helo`), `dkim` (`header.d`, `header.s`, `header.b` sur 8 caractères), `dmarc` (`header.from`, `policy.dmarc`), `iprev` (`policy.iprev`) ; valeurs échappées, sans caractère de contrôle ; retrait des en-têtes reçus portant notre `authserv-id` |
| `auth::MessageHeaders` | Découpage brut de l'en-tête (champs, valeurs repliées, corps), syntaxe obsolète d'un espace avant `:` admise |

Vérification : `cargo test -p lyxal_mail` — cas de Mox transposés (SPF : macros, annexe A de la
RFC 7208, limites ; DMARC : recherche, alignement, `sp`, `pct`), corpus DKIM de `mail-auth` et
message signé de `lyxal_crypto`, messages signés par les clés de `lyxal_crypto` dans les quatre
canonicalisations, cas de la RFC 6376 §6.1, en-têtes `Authentication-Results`.

Oracle différentiel S2 (`tools/dkim_oracle/`, hors du workspace, lancé à la main le 25 novembre
2026 contre `mail-auth` 0.16.0, commit `c862df2`, sur son corpus `resources/dkim/` (6 messages),
le message signé de `lyxal_crypto` et 64 messages signés par les clés de `lyxal_crypto` puis
altérés ; 71 messages) : **(a) canonicalisation identique 71/71** (en-têtes et empreinte du corps,
`simple` et `relaxed`) ; **(b) même verdict 70/71**, mêmes mots 57/71. Écarts de mot (politique
propre à Lyxal, même verdict) : empreinte du corps fausse `fail` ici, `neutral` chez `mail-auth`
(13 messages) ; signature échue `permerror` ici, `neutral` chez `mail-auth` (corpus `005`). Seul
écart de verdict : le message signé de `lyxal_crypto` (`pass` ici, `fail` chez `mail-auth`) porte
un champ `SUBJECT :` (espace avant `:`, syntaxe obsolète de la RFC 5322 §4.5.8) ; `mail-auth`
compare le nom brut `SUBJECT ` à `Subject` de `h=` et ne signe pas le champ, alors que les
signatures de ce message ont été produites par OpenSSL avec une canonicalisation écrite depuis la
RFC (`lyxal_crypto/tools/check_dkim_fixtures.py`) : comportement de Lyxal conservé. Code de
sortie de l'outil : 1 (à cause de cet écart).

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
| 5 — Réception SMTP (réalisé) | Serveur SMTP entrant, SPF / DKIM / DMARC, antivirus, remise en boîte |
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
| Externes (accord de principe P7) | `mail-parser`, `mail-builder`, `mail-send`, `rustls` côté serveur, `hickory-resolver` (sans DNSSEC au lot 5, DNSSEC examiné au lot 7), `idna` ; `mail-auth` jamais (décision S1 : seul l'oracle hors du workspace en dépend) |

`lyxal_mail` ne dépend ni de `lyxal_notification`, ni de `lyxal_calendar`, ni de
`lyxal_contacts`. `lyxal_notification` consomme ses événements `mail.*` sans lien Cargo ;
`lyxal_calendar` dépose ses invitations par son contrat public de dépôt.

## Documents

* [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) — études des sources (courrier, Proton) et mesures de SurrealDB.
* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, rapport du tri du code propriétaire, éléments portés.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, chiffrement des boîtes, webmail et alias, essais réels à faire.
