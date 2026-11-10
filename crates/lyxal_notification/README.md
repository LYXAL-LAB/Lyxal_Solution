# Lyxal Notification

Module du Noyau Technique de Lyxal OS : **notifications sortantes**. Lot V1-a : canal e-mail,
assez complet pour les messages de `lyxal_auth` (vérification d'adresse, récupération,
invitation) et pour les parcours des modules métiers. Toutes les règles vivent dans SurrealDB
(fonctions `fn::notification_*`) ; le crate Rust ouvre et scelle les secrets (`lyxal_crypto`),
rend les gabarits (MiniJinja) et envoie par SMTP (`lettre`). Modèle repris de Novu et Postal
([`MODELE_SOURCES.md`](MODELE_SOURCES.md)) ; lots suivants dans [`ROADMAP.md`](ROADMAP.md).

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `notification_settings` | réglages de l'installation, surchargés par organisation : langue par défaut, expéditeur, adresse de réponse, tentatives au plus, durées de conservation |
| `notification_workflow` | parcours : clé unique dans sa portée, événement déclencheur (`lyxal_event`), état `draft` / `active` / `inactive` (jamais supprimé), `critical`, `sensitive`, schéma des variables (`lyxal_core`), étapes ordonnées `[{ key, channel }]` |
| `notification_layout` | mise en page HTML et texte contenant `{{ content }}` |
| `notification_template`, `notification_template_locale` | gabarit d'une étape, sa langue par défaut et sa mise en page ; une version (objet, HTML, texte) par langue |
| `notification_run` | déclenchement pour un destinataire, **idempotent** par (portée, clé) ; secret scellé effacé dès la fin de ses étapes ou à son expiration |
| `notification_job` | étape à exécuter : file réservée par `locked_until` et `claim_token`, tentatives, dernière erreur |
| `notification_message` | message envoyé (destinataire, `Message-ID`) ; **aucun corps**, objet absent pour un parcours sensible |
| `notification_delivery_log` | journal en ajout seul (tentative, issue, code), jamais de secret |
| `notification_suppression` | adresses à ne plus contacter : `hard_bounce`, `complaint`, `unsubscribe`, `manual` |

Portée : champ `tenant` (organisation `lyxal_auth`, absent pour l'installation) et clé
`scope_key` (`installation` ou clé de l'organisation) pour les index uniques. Un parcours, une
mise en page ou une liste de suppression de l'installation sert de repli à toutes les
organisations. Les données d'une organisation (réglages, parcours, mises en page, gabarits,
déclenchements et leurs envois, liste de suppression) sont supprimées avec elle quand
`lyxal_auth` la purge (`REFERENCE ON DELETE CASCADE` sur `tenant`).

Règles :

* parcours d'une organisation, sinon de l'installation, choisi par clé ou par événement ;
* variables validées par le schéma du parcours ; adresse normalisée par `lyxal_core` ;
* adresse supprimée (organisation ou installation) : déclenchement abandonné
  (`suppressed:<motif>`) ; un parcours **critique** n'est arrêté que par un rejet définitif ou un
  blocage manuel ;
* activation d'un parcours seulement si chaque étape a un gabarit et sa version dans la langue
  par défaut ; cette version ne peut pas être supprimée ;
* langue du message : exacte, puis langue seule (`fr-CA` → `fr`), puis défaut du gabarit, puis
  défaut des réglages ;
* HTML des gabarits et mises en page nettoyé à l'enregistrement (scripts, iframes, gestionnaires
  d'événement) ; objet sans caractère de contrôle.

## 2. Droits

| Permission | Portée | Accès |
| :--- | :--- | :--- |
| `notification.read` | organisation | parcours, gabarits, réglages, liste de suppression, activité |
| `notification.manage` | organisation | gestion de tout ce qui précède |
| `notification.send` | organisation | déclenchement ; relecture de ses déclenchements |
| `notification.installation.manage` | installation | configuration et activité de l'installation |
| `notification.worker` | installation | compte de service du worker : file d'envoi de toutes les portées |

`organization_admin` reçoit les trois permissions d'organisation, `platform_admin` la gestion de
l'installation ; `notification.worker` n'est attribuée à aucun rôle. Contrôle unique :
`fn::notification_can({ action, tenant })`, utilisé par les fonctions et les `PERMISSIONS`. Le
secret d'un déclenchement n'est lisible que par le worker (permission de champ).

## 3. Fonctions publiques

| Domaine | Fonctions |
| :--- | :--- |
| Déclenchement | `notification_trigger` |
| Parcours | `notification_workflow_create`, `_update`, `_get`, `_list`, `_set_status` |
| Mises en page | `notification_layout_create`, `_update`, `_get`, `_list` |
| Gabarits | `notification_template_create`, `_update`, `_get`, `notification_template_locale_set`, `_delete` |
| Réglages | `notification_settings_get`, `_set` |
| Liste de suppression | `notification_suppression_add`, `_remove`, `_list` |
| Activité | `notification_run_get`, `_list` |
| File d'envoi (worker) | `notification_job_claim`, `_renew`, `_release`, `_complete`, `_fail`, `notification_purge` |

Entrées validées et nettoyées par `lyxal_core` ; erreurs `NOTIFICATION_*` (master data
`error/`) ; toute écriture vérifiée (`NOTIFICATION_WRITE_FORBIDDEN`).

File d'envoi : réservation conditionnelle (une étape n'est réservée qu'une fois ; une
réservation expirée est reprise, sauf après la dernière tentative : échec définitif),
renouvelée juste avant chaque envoi ; étape non commencée rendue à la file à l'arrêt du worker ; étape
dont le secret a expiré annulée, jamais envoyée en retard ; échec temporaire rejoué tant que
`attempts < max_attempts` ; destinataire refusé : échec définitif et adresse supprimée
(`hard_bounce`).

## 4. Événements

Consommés (contrat fixé avec `lyxal_auth`) : `auth.verification.requested`,
`auth.recovery.requested`, `auth.invitation.created`. Le code ou le lien y voyage scellé
(`enc:v2`) sous `with_tenant(tenant ?? "lyxal_installation", "lyxal_auth", <type d'événement,
points remplacés par _>, <event_id>, "secret")` : une enveloppe recopiée dans un autre
événement ne s'ouvre pas. Le module l'ouvre, le rescelle sous `with_tenant(…,
"lyxal_notification", "notification_run", <idempotency_key>, "secret")` et déclenche le parcours
de même événement (idempotent par l'identifiant d'événement).

Alertes de sécurité (sans secret) : `auth.mfa.enrolled`, `auth.mfa.removed`,
`auth.mfa.recovery_codes_generated`, `auth.mfa.recovery_code_used`, `auth.password.changed`
(sauf le premier mot de passe d'un compte), `auth.passkey.clone_detected` → parcours critique
`auth_security_alert` (gabarits fr / en, nature de l'alerte dans `payload.alert`), destinataire
pris dans la charge utile (`recipient_*`), idempotent par l'identifiant d'événement.

Publiés : `notification.message.sent`, `notification.message.failed`,
`notification.address.suppressed` (identifiants, parcours, canal, adresse pour la suppression ;
jamais de contenu ni de secret).

## 5. Rust

* `NotificationStore` : appels typés (`LyxalSurrealCall`) ; `XxxParams` / résultats dans
  `models/` (déclenchement, file, purge, réglages). Les fonctions de gestion sont appelées par la
  console.
* `SecretCodec` : ouverture et rescellement (`CryptoEngine`, contextes non vides).
* `NotificationConsumer` (`EventConsumerModule`) et `AuthMessageHandler` : secret illisible,
  charge utile invalide ou parcours absent → lettre morte ; base indisponible → rejoué.
  `SecurityAlertHandler` : alertes de sécurité vers `auth_security_alert`.
* `Renderer` : MiniJinja sans chargeur, variable affichée inconnue = erreur, échappement HTML
  automatique, budget d'exécution, mise en page autour du contenu.
  Filtres de `lyxal_i18n`, dans la langue du destinataire (sinon celle du gabarit retenu, sinon
  `fr`) ; une valeur invalide fait échouer le rendu, rien n'est envoyé :

  | Filtre | Exemple | Résultat (`fr`) |
  | :--- | :--- | :--- |
  | `format_number` | `{{ payload.count \| format_number }}` | `12 345` |
  | `format_currency(code)` | `{{ payload.total \| format_currency("EUR") }}` | `1 234,50 €` |
  | `format_date(style, zone)` | `{{ payload.due_at \| format_date("long", "Europe/Paris") }}` | `29 mars 2026` |

  Une date est un texte RFC 3339 ; `style` vaut `short`, `medium` (défaut) ou `long` pour la
  date seule, `datetime_short`, `datetime_medium` ou `datetime_long`, ou `time` ; `zone` est un
  identifiant IANA (`UTC` par défaut). Un montant est un entier ou un texte décimal (`"1234.50"`).
* `SmtpTransport` (`lettre`, TLS rustls, connexions réutilisées) et `EmailTransport` ;
  classement : connexion ou 4xx → `transient`, 550 / 551 / 553 → `recipient_rejected`, autre 5xx →
  `permanent`. Signature DKIM par le relais.
* `NotificationEmailWorker` (une étape à la fois, réservation renouvelée avant l'envoi, traitement
  borné, aucun envoi commencé après l'annulation ; attente exponentielle plafonnée avec gigue
  complète, base 30 s, plafond 6 h) et `NotificationPurgeWorker` (`LyxalWorker`) ; `NotificationModule`,
  `NotificationHealthCheck` (« dégradé » sans relais ou sans clé).

Hébergé par `lyxal-server` (`build.rs`, `src/modules/notification.rs`) : clé applicative
`LYXAL__CRYPTO__APPLICATION_KEY` et relais `LYXAL__NOTIFICATION__SMTP__*` ; sans l'un des deux,
aucun e-mail n'est envoyé et les abonnements `auth.*` restent suspendus.

## 6. Vérification

* Banc SurrealQL `tests/*.test.surql` (socle, gestion, déclenchement, file d'envoi, fonctions
  internes), exécuté par `scripts/ci/test_lyxal_modules.py`.
* Tests Rust : rendu, classement SMTP, délais ; `tests/it/` de bout en bout sur le moteur
  embarqué avec un serveur SMTP de test (invitation de `lyxal_auth` reçue, aucune trace du jeton
  en base ; enveloppe d'un autre événement refusée ; 4xx puis succès ; 550 → suppression).
* `scripts/ci/ci_local.sh`.
