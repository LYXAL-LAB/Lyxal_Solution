# `lyxal_notification` — modèle cible composé à partir de Novu (gratuit et payant)

Synthèse préalable au plan d'implémentation de `lyxal_notification`. Elle complète
[`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) (choix des sources) en listant **toutes** les
fonctionnalités de Novu, y compris celles des offres payantes, et leur place dans Lyxal.

Le crate n'existe pas encore : aucun code avant un `implementation_plan.md` validé par le CTO
(`.agents/AGENTS.md` §3).

## En-tête

| Élément | Valeur |
| :--- | :--- |
| Date | 8 novembre 2026 |
| Source | Novu, dépôt `novuhq/novu`, commit `8713b02` (8 nov. 2026), clone `--depth 1` |
| Parties lues | `docs/` (≈ 1 100 pages : platform, framework, guides, api-reference, agents), `agent-inbox-docs/`, les 46 entités `libs/dal/src/repositories/*/*.entity.ts`, la structure de `apps/` (api, worker, ws, webhook, inbound-mail), le schéma d'activité `apps/api/migrations/clickhouse-migrations/1_initial_schema.sql`, les énumérations de `packages/shared/src/` |
| Méthode | Lecture seule. Chaque ligne cite le fichier lu (chemins relatifs à la racine du dépôt Novu) |

### Règle de licence (à respecter dans tout le module)

* **Tout Novu est sous licence MIT**, sauf le dossier `enterprise/packages/` (licence propriétaire,
  fichiers `LICENSE-ENTERPRISE` et `EE-PACKAGES-LICENSE` : interdiction de modifier, adapter ou
  traduire).
* Dans le clone, `enterprise/packages/*/src` est **vide** (0 fichier) : c'est un sous-module privé
  (`.gitmodules` → `novuhq/packages-enterprise`). Aucun code payant n'a donc été lu.
* `enterprise/workers/` est **hors** de `enterprise/packages/` : il est sous MIT. Seuls ses
  `README.md` ont été lus (`socket`, `step-resolver`, `thalamus-observer`).
* Les fonctionnalités payantes sont relevées **uniquement** dans la documentation publique (MIT)
  et les noms d'entités MIT de `libs/dal`. Une fonctionnalité est une idée : elle n'est pas
  protégée. Lyxal la **reconçoit** avec ses propres règles. Mention utilisée plus bas :
  **« reconçue, aucun code repris »**.
* Le code MIT de Novu peut servir de référence de conception. Il n'est pas traduit ligne à ligne
  (TypeScript/MongoDB très éloigné de SurrealQL/Rust). S'il est un jour repris, mention d'origine
  dans le `README.md`.

### Légende

* **Novu** : `Gratuit` = inclus dans la version open source ; `Cloud` = Novu Cloud seulement (pas
  dans l'open source) ; `Pro`, `Team`, `Ent.` = plan payant minimum ; `EE` = Enterprise Edition
  auto-hébergée (payante).
* **Lyxal** : `V1` = fonctionnel (découpé en lots, §4) ; `V2` = observabilité et console ;
  `V3` = événementiel avancé et IA (méthode `.agents/AGENTS.md` §9) ; `Non` = non pertinente.
* Les plafonds des plans Novu (durées, nombres) sont dans `docs/platform/developer/limits.mdx`.
  Dans Lyxal, ce ne sont pas des offres commerciales mais des **réglages par locataire**
  (`notification_settings`, §2).

---

## 1. Catalogue des fonctionnalités

108 fonctionnalités relevées : 19 réservées au Cloud ou à une offre payante (n° 46, 47, 49, 54,
58, 59, 78, 90, 91, 93, 94, 99, 100, 101, 103, 105, 106, 107, 108) et 6 autres gratuites mais
plafonnées selon le plan (n° 12, 25, 44, 83, 86, 104).

### 1.1. Destinataires et ciblage

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Abonnés | Destinataire identifié par un identifiant stable fourni par l'application | Gratuit | `docs/platform/concepts/subscribers.mdx` | V1 | Base de tout envoi |
| 2 | Profil et données libres | Prénom, e-mail, téléphone, avatar, `locale`, `timezone`, objet `data` libre | Gratuit | idem, `subscriber.entity.ts` | V1 | Personnalisation, langue, fuseau |
| 3 | Création à la volée | L'abonné est créé ou mis à jour au déclenchement | Gratuit | `docs/platform/concepts/trigger.mdx` | V1 | Indispensable pour les e-mails `auth.*` |
| 4 | Import en masse | Création de nombreux abonnés en un appel, rapport créés / modifiés / échoués | Gratuit | `docs/api-reference/subscribers/bulk-create-subscribers.mdx` | V1 | Reprise de données client |
| 5 | Adresses de canal (endpoints) | Jetons d'appareil push, adresse webhook chat, identifiant Slack, liés à une intégration | Gratuit | `channel-endpoint.entity.ts`, `docs/api-reference/channel-endpoints/` | V1 | Un abonné peut avoir plusieurs appareils |
| 6 | Statut en ligne | `isOnline`, `lastOnlineAt` mis à jour par le temps réel | Gratuit | `subscriber.entity.ts`, `apps/ws/src/shared/subscriber-online/` | V2 | Utile seulement avec le fil in-app temps réel |
| 7 | Sujets (topics) | Liste nommée d'abonnés ; un envoi au sujet = un envoi par membre | Gratuit | `docs/platform/concepts/topics.mdx` | V1 | Diffusion à une équipe, un chantier, un projet |
| 8 | Abonnement conditionnel à un sujet | Plusieurs abonnements par membre (max 10), chacun avec une condition sur le contenu de l'événement | Gratuit | `docs/platform/subscription.mdx` | V1 | Alertes fines (ex. « seulement si montant > 1 000 € ») |
| 9 | Exclure l'auteur | Ne pas notifier la personne qui a provoqué l'événement (acteur) | Gratuit | `docs/platform/workflow/trigger-workflow.mdx` | V1 | Évite de se notifier soi-même |
| 10 | Acteur | L'abonné à l'origine de l'action, affiché dans le message (avatar, nom) | Gratuit | `message.entity.ts` (`actor`) | V1 | Fil in-app lisible |
| 11 | Diffusion à tous | Envoi à tous les abonnés du locataire | Gratuit | `docs/api-reference/events/broadcast-event-to-all.mdx` | V1 | Annonces de maintenance |
| 12 | Contextes | Métadonnées persistantes (`tenant`, `app`, `region`…) qui cloisonnent fil, préférences et abonnements | Gratuit (5 par envoi, plus en Ent.) | `docs/platform/concepts/contexts.mdx`, `context.entity.ts` | V2 | Le locataire Lyxal est déjà natif ; reste utile pour des sous-espaces (chantier, magasin) |
| 13 | Locataires (ancienne version) | Ancienne entité `tenant`, remplacée par les contextes | Gratuit | `tenant.entity.ts`, `docs/platform/concepts/tenants.mdx` | Non | Locataire = organisation `lyxal_auth`, contrôlé par `PERMISSIONS` |

### 1.2. Parcours (workflows) et déclenchement

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 14 | Parcours en étapes | Suite ordonnée d'étapes canal et d'étapes d'action | Gratuit | `docs/platform/concepts/workflows.mdx` | V1 | Cœur du module |
| 15 | Identifiant immuable, statut actif / inactif | L'identifiant ne change plus après création ; un parcours inactif ne part pas | Gratuit | idem | V1 | Stabilité des appels |
| 16 | Déclenchement par événement | Un événement nommé démarre le parcours | Gratuit | `docs/platform/concepts/trigger.mdx` | V1 | Dans Lyxal : type d'événement `lyxal_event` |
| 17 | Envoi groupé | Jusqu'à 100 déclenchements en un appel | Gratuit | `docs/api-reference/events/bulk-trigger-event.mdx` | V1 | Imports, traitements par lot |
| 18 | Annulation | Annuler un déclenchement en attente (délai, digest) par `transactionId` | Gratuit | `docs/api-reference/events/cancel-triggered-event.mdx` | V1 | Ex. relance annulée si le client a payé |
| 19 | Idempotence | Clé `Idempotency-Key` (cache) et `transactionId` | Gratuit (clé activée sur demande) | `docs/api-reference/idempotency.mdx` | V1 | Dans Lyxal : index `UNIQUE`, pas de cache |
| 20 | Schéma du contenu | Schéma JSON du `payload`, validation imposée ou non | Gratuit | `docs/platform/workflow/configure-workflow.mdx` | V1 | Validé par `lyxal_core` (§5.7.8) |
| 21 | Étiquettes (tags) | Classent les parcours ; servent aux onglets et préférences | Gratuit | idem, `docs/framework/tags.mdx` | V1 | Filtrage du fil et des préférences |
| 22 | Catégories (ancien « groupe ») | Regroupement des parcours, remplacé par les étiquettes | Gratuit | `notification-group.entity.ts`, `docs/guides/migration-to-new-dashboard/feature-comparison.mdx` | V1 | Gardé comme catégorie de désabonnement (lien « se désabonner ») |
| 23 | Parcours critique | Ignore les préférences de l'abonné (mot de passe, vérification) | Gratuit | `docs/platform/concepts/preferences.mdx` | V1 | Indispensable pour `lyxal_auth` |
| 24 | Gravité | `high`, `medium`, `low`, `none` ; sert aux onglets et à l'affichage | Gratuit | `packages/shared/src/consts/severity.ts`, `configure-workflow.mdx` | V1 | Simple et utile |
| 25 | Étape délai | Attente fixe, jusqu'à une date, planifiée ou lue dans l'événement | Gratuit (1 j / 7 j / 30 j selon plan) | `docs/platform/workflow/add-and-configure-steps/configure-action-steps/delay.mdx` | V1 | Attente courte par le worker ; longue après `lyxal_scheduler` |
| 26 | Étape digest | Regroupe plusieurs événements en un message (fenêtre fixe, recul « backoff », horaire planifié, clé de regroupement) | Gratuit | `.../digest.mdx`, `DigestTypeEnum` | V1 | « Vous avez 5 nouveaux commentaires » |
| 27 | Étape limitation (throttle) | Plafond d'envois par fenêtre fixe ou dynamique, par groupe | Gratuit | `.../throttle.mdx` | V1 | Anti-spam |
| 28 | Respect des horaires de l'abonné | Un délai ou digest attend la prochaine plage autorisée | Gratuit | `delay.mdx` (§ Extend to subscriber's schedule) | V1 | Lié aux heures calmes (#55) |
| 29 | Étape requête HTTP | Appel d'une API externe, réponse réutilisable par les étapes suivantes, signature | Gratuit | `.../http-step.mdx` | V2 | Risque SSRF : liste d'hôtes autorisés à décider |
| 30 | Conditions d'étape | Règles (subscriber, payload, contexte, résultat d'étape précédente, variables) | Gratuit | `.../step-conditions.mdx` | V1 | Moteur de conditions à fournir (décision §5) |
| 31 | Arrêt sur échec | Une étape canal en échec n'arrête pas le parcours ; une étape d'action, si | Gratuit | `docs/platform/developer/delivery-retries.mdx` | V1 | Comportement repris et rendu configurable |
| 32 | « Sauter » si déjà lu | Ex. e-mail 6 h plus tard seulement si l'in-app n'est pas lu | Gratuit | `docs/framework/skip.mdx` | V1 | Exprimé par une condition sur l'étape précédente |
| 33 | Étapes en code (step resolver) | Code TypeScript de l'utilisateur publié en fonction serverless qui produit le contenu | Gratuit (Cloud pour l'exécution hébergée) | `docs/platform/workflow/add-and-configure-steps/code-steps.mdx`, `enterprise/workers/step-resolver/README.md` | Non | Lyxal n'exécute pas de code utilisateur ; remplacé par des gabarits et des handlers Rust enregistrés |
| 34 | Framework « bridge » | Le parcours est écrit dans l'application et Novu appelle un point d'entrée HTTP | Gratuit | `docs/framework/endpoint.mdx` | Non | Dans Lyxal, les parcours vivent dans SurrealDB |
| 35 | Étape personnalisée | Logique libre dont le résultat sert ensuite | Gratuit | `docs/framework/custom.mdx` | V3 | Handler Rust déclaré par un module, si un besoin réel apparaît |
| 36 | Contrôles (controls) | Valeurs modifiables d'une étape, validées par schéma, à plusieurs niveaux | Gratuit | `control-values.entity.ts`, `docs/framework/controls.mdx` | V1 | Objet imbriqué validé par `lyxal_core` |
| 37 | Surcharges au déclenchement | Changer canal, fournisseur ou contenu pour un envoi précis | Gratuit | `docs/platform/integrations/trigger-overrides.mdx` | V1 | Ex. forcer l'intégration SMTP d'un client |
| 38 | Aperçu et envoi de test | Rendu d'une étape, test vers un abonné | Gratuit | `docs/api-reference/workflows/generate-a-step-preview.mdx` | V1 | Nécessaire pour la console |
| 39 | Duplication, modèles prêts | Copier un parcours ; bibliothèque de modèles (`isBlueprint`) | Gratuit | `notification-template.entity.ts`, `create-a-workflow.mdx` | V2 | Confort de la console |
| 40 | Brouillon et publication | `draft`, `lastPublishedAt`, problèmes de configuration (`issues`) | Gratuit | `notification-template.entity.ts` | V2 | Publication avec révision figée (§2) |

### 1.3. Contenu et mise en forme

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 41 | Gabarits par canal | Sujet, corps, préentête, nom d'expéditeur, boutons d'action | Gratuit | `message-template.entity.ts`, `docs/platform/workflow/add-notification-content/channels-template-editors.mdx` | V1 | Rendu MiniJinja (Novu : LiquidJS) |
| 42 | Variables | `payload`, `subscriber`, `context`, `env`, digest, filtres et boucles | Gratuit | `.../personalize-content.mdx` | V1 | Variable inconnue = erreur |
| 43 | Nettoyage du HTML | Contenu in-app nettoyé, désactivable | Gratuit | `channels-template-editors.mdx` | V1 | Échappement automatique MiniJinja |
| 44 | Mises en page e-mail (layouts) | En-tête et pied communs | Gratuit : 1 ; Pro+ : 100 | `layout.entity.ts`, `channels-template-editors.mdx` | V1 | Sans plafond, réglage locataire |
| 45 | Éditeur par blocs | Éditeur visuel d'e-mail | Gratuit | `libs/maily-*`, `channels-template-editors.mdx` | V2 | Écran console ; option MJML (`mrml`) |
| 46 | Traductions | Clés de traduction par parcours et mise en page, fichiers JSON par langue, état « à jour / obsolète », import-export, CLI | **Cloud** | `docs/platform/workflow/advanced-features/translations.mdx`, `localization*.entity.ts`, `translation*.entity.ts` | V1 (simple) puis V2 | Reconçue, aucun code repris. V1 : une version du gabarit par langue ; V2 : clés avec `lyxal_i18n` |
| 47 | Variables d'environnement | Valeurs nommées réutilisées dans les gabarits (`{{ env.X }}`), secrètes ou non | **Pro+** | `docs/platform/developer/environment-variables.mdx`, `environment-variable.entity.ts` | V2 | Reconçue, aucun code repris. Valeurs non secrètes ici, secrets dans `lyxal_secrets` |
| 48 | Image de marque | Logo, couleurs, police, sens d'écriture (rtl) | Gratuit | `organization.entity.ts` (`branding`) | V1 | Variables de la mise en page |
| 49 | Retrait de la marque Novu | Masquer « Powered by Novu » | **Payant** | `docs/platform/inbox/prepare-for-production.mdx` | Non | Lyxal n'affiche pas de marque tierce |

### 1.4. Canaux, fournisseurs, livraison

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 50 | Intégrations | Instance configurée d'un fournisseur, plusieurs par canal, une principale (e-mail, SMS) | Gratuit | `docs/platform/concepts/integrations.mdx`, `integration.entity.ts` | V1 | Identifiants via `lyxal_secrets` |
| 51 | Choix conditionnel d'intégration | Ex. chaque client avec son propre compte SendGrid | Gratuit | `docs/platform/integrations/integration-conditions.mdx` | V1 | Multi-locataire |
| 52 | Catalogue de fournisseurs | 18 e-mail, 37 SMS, 6 push, 10 chat, 3 outils (PagerDuty, Opsgenie, Grafana) | Gratuit | `docs/platform/integrations/*/` | V1 par étapes | SMTP d'abord, puis API HTTP (§4) |
| 53 | SMTP personnalisé | TLS direct ou STARTTLS, TLS exigé | Gratuit | `docs/platform/integrations/email/custom-smtp.mdx` | V1 | `lettre` + rustls |
| 54 | Fournisseur de démonstration | Envoi limité sans compte fournisseur | Cloud | `docs/platform/integrations/demo-integration.mdx` | Non | Remplacé par un transport « capture » de test |
| 55 | Canal « outil » et webhook | Livrer à PagerDuty, Opsgenie, Grafana ou une URL | Gratuit | `docs/framework/tool-channel.mdx`, `docs/platform/integrations/tool/` | V1 (lot canaux) | Alertes d'exploitation |
| 56 | Connexions chat OAuth | Espace Slack / Teams connecté avec jetons d'accès | Gratuit | `channel-connection.entity.ts`, `docs/api-reference/integrations/generate-chat-oauth-url.mdx` | V3 | Le flux OAuth relève de `lyxal_connect` |
| 57 | Nouvelles tentatives | **Novu ne retente pas** un envoi refusé par un fournisseur (une seule tentative, pas de bascule) | Gratuit | `docs/platform/developer/delivery-retries.mdx` | V1 | Lyxal fait mieux : tentatives avec attente croissante, 4xx définitif / temporaire |
| 58 | Suivi d'activité e-mail | Délivré, ouvert, cliqué, rejeté, plainte, reçus des fournisseurs et normalisés | **Cloud / EE** | `docs/platform/integrations/email/activity-tracking.mdx` | V2 | Reconçue, aucun code repris. Alimente aussi la liste de suppression (V1) |
| 59 | Suivi d'activité push | Retours des fournisseurs push | Cloud | `docs/platform/integrations/push/push-activity-tracking.mdx` | V2 | Après les canaux push |
| 60 | Liste de suppression | Adresses en rejet définitif ou plainte | (absent chez Novu) | Postal, voir `RECHERCHE_SOURCES.md` | V1 | Protège la réputation d'envoi |

### 1.5. Préférences

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 61 | Préférences par défaut du parcours | Canaux actifs par défaut | Gratuit | `docs/platform/concepts/preferences.mdx` | V1 | |
| 62 | Préférences globales de l'abonné | Ex. « plus aucun SMS » | Gratuit | idem | V1 | |
| 63 | Préférences par parcours | Choix par canal pour un parcours | Gratuit | idem | V1 | |
| 64 | Ordre de priorité | Le niveau le plus précis gagne ; le parcours critique ignore l'abonné | Gratuit | idem | V1 | Une fonction SurrealQL unique de résolution |
| 65 | Préférences par contexte / locataire | Mêmes préférences, cloisonnées par contexte | Gratuit | `preferences.entity.ts` (`contextKeys`) | V1 (locataire) / V2 (contexte) | |
| 66 | Surcharge par client | Un client désactive un canal d'un parcours pour tous ses abonnés | Gratuit | `workflow-override.entity.ts` | V1 | Niveau « organisation cliente » de `lyxal_auth` |
| 67 | Préférences d'abonnement à un sujet | Niveau `SUBSCRIPTION_SUBSCRIBER_WORKFLOW` | Gratuit | `PreferencesTypeEnum` | V1 | |
| 68 | Heures calmes (schedule) | Plages horaires hebdomadaires par jour, dans le fuseau de l'abonné | Gratuit | `docs/platform/inbox/features/schedule.mdx` | V1 | Objet imbriqué de la préférence globale |
| 69 | Mise à jour groupée | Plusieurs préférences en un appel | Gratuit | `docs/api-reference/subscribers/bulk-update-subscriber-preferences.mdx` | V1 | |
| 70 | Lien de désabonnement | Désabonnement d'une catégorie depuis l'e-mail | (absent, à reconcevoir) | — | V1 | En-tête `List-Unsubscribe` ; jeton signé HMAC `lyxal_crypto` |

### 1.6. Fil in-app (Inbox)

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 71 | Fil de notifications | Liste paginée par abonné | Gratuit | `docs/platform/inbox.mdx`, `message.entity.ts` | V1 | |
| 72 | États | vu, lu, non lu, archivé, supprimé, avec dates | Gratuit | `docs/api-reference/subscribers/` | V1 | |
| 73 | Actions groupées | Tout marquer lu, archiver tous les lus, tout supprimer | Gratuit | idem | V1 | |
| 74 | Compteurs | Non vus, non lus, total, par filtre | Gratuit | `retrieve-subscriber-notifications-count.mdx` | V1 | |
| 75 | Boutons d'action | Action principale / secondaire, « terminée » ou « annulée » | Gratuit | `complete-a-notification-action.mdx`, `revert-a-notification-action.mdx` | V1 | Ex. « Valider le devis » |
| 76 | Lien de redirection, avatar, objet `data` | Clic vers une page, données libres pour l'interface | Gratuit | `channels-template-editors.mdx` | V1 | |
| 77 | Onglets filtrés | Par étiquettes, `data` ou gravité | Gratuit | `docs/platform/inbox/configuration/tabs.mdx` | V1 | Filtres côté fonction SurrealQL |
| 78 | Mise en sommeil (snooze) | Masquer jusqu'à une date (3 min à 90 j) | **Cloud** | `docs/platform/inbox/features/snooze.mdx` | V1 | Reconçue, aucun code repris. Réveil par worker |
| 79 | Temps réel | Nouveau message et compteurs poussés (WebSocket : `notification_received`, `unread_count_changed`, `unseen_count_changed`) | Gratuit | `apps/ws/src/socket/ws.gateway.ts`, `packages/shared/src` (`WebSocketEventEnum`) | V1 | Décision : `LIVE SELECT` SurrealDB ou flux SSE de `lyxal-server` (§5) |
| 80 | Sécurisation HMAC du fil | Empreinte `HMAC-SHA256(clé, subscriberId)` pour empêcher la lecture du fil d'un autre | Gratuit | `docs/platform/inbox/prepare-for-production.mdx` | V1 | Dans Lyxal : session `lyxal_auth` + `PERMISSIONS` |
| 81 | Composants d'interface | Cloche, Inbox, préférences, mode sans interface (headless), traduction de l'interface | Gratuit | `docs/platform/inbox/`, `docs/platform/sdks/` | V2 | Console Surrealist (charte §15) |
| 82 | Composant d'abonnement aux sujets | L'utilisateur choisit ses abonnements conditionnels | Gratuit | `docs/platform/subscription/` | V2 | Console |
| 83 | Durée de conservation du fil | 30 j (gratuit), 90 j (payant), sur mesure (Ent.) | Plans | `docs/platform/additional-resources/security.mdx` | V1 | Réglage locataire + purge par worker |

### 1.7. Observabilité, webhooks sortants, analyses

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 84 | Journal d'activité | Exécutions, étapes, traces, réponse du fournisseur | Gratuit | `docs/platform/workflow/monitor-and-debug-workflow.mdx`, `execution-details.entity.ts`, `clickhouse-migrations/1_initial_schema.sql` | V1 (journal) / V2 (écrans) | |
| 85 | Statuts d'étape et de livraison | `pending`, `queued`, `running`, `completed`, `failed`, `delayed`, `canceled`, `merged`, `skipped` ; cycle `sent`, `delivered`, `interacted` | Gratuit | `docs/platform/concepts/trigger.mdx`, `DeliveryLifecycleStatusEnum` | V1 | |
| 86 | Conservation du journal | 1 j (gratuit), 7 j (Pro), 90 j (Team), sur mesure (Ent.) | **Plans** | `docs/platform/developer/limits.mdx` | V1 | Reconçue, aucun code repris. Champ `expires_at` + purge |
| 87 | Page d'usage | Envois, abonnés, engagement | Gratuit | `docs/platform/workflow/usage.mdx` | V2 | Statistiques horaires |
| 88 | Tendances de livraison | Comptages agrégés | Gratuit | `clickhouse-migrations/3_analytics_tables.sql` | V2 | |
| 89 | Journal des requêtes API | Chaque appel API conservé | Gratuit | `1_initial_schema.sql` (`requests`) | Non | Relève de `lyxal-server` |
| 90 | Webhooks sortants | Événements `message.*`, `workflow.*`, `preference.updated`, `email.received` vers les URL du client, signés, 8 essais sur ≈ 27 h | **Team / Ent.** (via le service Svix) | `docs/platform/developer/webhooks.mdx`, `.../webhooks/event-types.mdx` | V2 | Reconçue, aucun code repris. Signature HMAC `lyxal_crypto` |
| 91 | Connecteurs de webhooks | Vers S3, BigQuery, Snowflake, SQS, Pub/Sub, ClickHouse… | **Team / Ent.** | `docs/platform/developer/webhooks/connectors.mdx` | Non | Hors périmètre ; un client branche son outil sur les webhooks |
| 92 | Exports analytiques | Segment, Hightouch, Databricks | Gratuit (guides) | `docs/guides/analytics/` | Non | Hors périmètre |

### 1.8. Courrier entrant et domaines

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 93 | Domaines entrants | Domaine vérifié par enregistrement MX, configuration automatique (Domain Connect) | **Team+ / EE** | `docs/platform/inbound-email/overview.mdx`, `domain.entity.ts` | V3 | Reconçue, aucun code repris. Demande un serveur SMTP entrant |
| 94 | Routes d'adresse | `support@…` ou `*@…` vers un webhook ou un agent, avec métadonnées | **Team+ / EE** | idem, `domain-route.entity.ts` | V3 | Idem |
| 95 | Vérification SPF / DKIM du courrier reçu | Contrôle de l'expéditeur | (service `inbound-mail`) | `apps/inbound-mail/src/python/verifyspf.py`, `verifydkim.py` | V3 | Vérification de signatures RSA : **soumise au CTO** (§11.3) |
| 96 | Réponse à un e-mail | Rappel sur réponse (`replyCallback`) | Gratuit | `notification-template.entity.ts` | V3 | Dépend du courrier entrant |
| 97 | Domaine d'envoi vérifié | Contrôle SPF / DKIM / DMARC du domaine expéditeur | **Absent de Novu** (laissé au fournisseur) | — (idée Postal, MIT) | V2 | Simple lecture DNS, sans crypto ; la signature DKIM reste au relais |

### 1.9. Organisation, sécurité, conformité

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 98 | Organisations, membres, invitations, domaines vérifiés | | Gratuit (1 membre en auto-hébergé) | `docs/platform/account/organizations.mdx` | Non | Porté par `lyxal_auth` |
| 99 | Rôles et permissions (RBAC) | Owner, Admin, Author, Viewer, matrice par action | **Team / Ent.** | `docs/platform/account/roles-and-permissions.mdx` | Non (ici) | Reconçue dans `lyxal_auth` : permissions `notification:*` déclarées par ce module |
| 100 | SSO SAML / OIDC, synchronisation d'annuaire SCIM, MFA imposée | | **Ent.** | `docs/platform/account/sso.mdx`, `directory-sync.mdx`, `authentication.mdx` | Non (ici) | `lyxal_auth` (V2 / V3 de ce module) |
| 101 | Contrôles d'audit | Historique des actions d'administration | **EE / Ent.** | `docs/platform/account/billing.mdx` (§ Enterprise Edition) | V1 | Reconçue, aucun code repris : événements `notification.*` publiés par `fn::event_publish` |
| 102 | Clés d'API par environnement, chiffrées | | Gratuit | `environment.entity.ts` (`apiKeys`) | Non | `auth_api_key` de `lyxal_auth` |
| 103 | Régions et résidence des données, HIPAA, SOC 2 | | **Ent. / Cloud** | `docs/platform/additional-resources/security.mdx` | Non | Choix d'hébergement, pas de fonction |
| 104 | Limites de débit API par plan | 20 à 60 requêtes/s en gratuit | Plans | `docs/api-reference/rate-limiting.mdx` | Non | Relève de `lyxal-server` |

### 1.10. Environnements et cycle de vie

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 105 | Environnements et publication | Développement → production ; parcours, mises en page, traductions publiés ; comparaison des différences ; environnements sur mesure | Dev + Prod gratuits ; sur mesure **Team / Ent.** | `docs/platform/developer/environments.mdx`, `change.entity.ts`, `docs/api-reference/environments/` | Non (remplacé) | Lyxal sépare ses bases ; remplacé par brouillon / publication avec révisions (#40) |

### 1.11. IA et agents

| # | Fonctionnalité | Ce qu'elle fait | Novu | Source lue | Lyxal | Pourquoi |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 106 | Outils pour assistants IA | Serveur MCP, « skills », boîte à outils pour agents | Cloud (MCP hébergé) | `docs/platform/build-with-ai/mcp.mdx`, `skills.mdx`, `agent-toolkit.mdx` | V3 | Reconçue, aucun code repris ; sujet transverse, pas propre à ce module |
| 107 | Assistant IA du tableau de bord | Génère ou modifie un parcours par conversation, avec instantanés | Cloud | `ai-chat.entity.ts`, `snapshot.entity.ts` | Non | Hors périmètre |
| 108 | Agents conversationnels (Novu Connect, Agent Inbox) | Conversations bidirectionnelles Slack / Teams / WhatsApp / Telegram / e-mail / chat web ; participants ; approbation d'outils ; questions `ask` / `approve` / `choose` avec expiration ; agents gérés (Claude) ; connexions MCP OAuth ; parcours « envoyer et répondre via l'agent » | Cloud / EE | `docs/agents/`, `agent-inbox-docs/`, `conversation*.entity.ts`, `agent*.entity.ts`, `human-*.entity.ts`, `mcp-connection.entity.ts` | V3 partiel | Reconçue, aucun code repris. Seule l'**interaction humaine** (demande d'approbation ou de choix par message, avec expiration) est retenue pour ce module ; le reste serait un module séparé (§5) |

Fonctionnalités d'exploitation non reprises (sans objet pour un module) : facturation, télémétrie,
drapeaux de fonctionnalités, migrations de données, déploiement Docker, CLI et Studio local,
intégration Vercel (`docs/community/`, `docs/platform/account/billing.mdx`,
`organization.entity.ts` → `partnerConfigurations`).

---

## 2. Correspondance table par table : Novu → SurrealDB

Préfixe `notification_`. Entités : `TYPE NORMAL SCHEMAFULL`. Associations : `TYPE RELATION ...
ENFORCED`. Tous les documents portent `tenant` (organisation `lyxal_auth`), contrôlé par les
`PERMISSIONS`. Novu sépare organisation **et** environnement : Lyxal n'a que le locataire.

### 2.1. Tables reprises (complète `RECHERCHE_SOURCES.md` §3)

| Novu (entité ou table) | Table Lyxal | Type | Contenu et différences | Lot |
| :--- | :--- | :--- | :--- | :--- |
| `subscriber` | `notification_subscriber` | document | profil, `locale` (BCP 47), `timezone`, `data` ; préférence globale et heures calmes en objet imbriqué ; `external_id` unique par locataire | V1-b |
| `channel-endpoint` | `notification_endpoint` (abonné → intégration) | relation | type (`device_token`, `webhook_url`, `slack_user`…), valeur, contextes | V1-b |
| `topic` | `notification_topic` | document | clé unique par locataire, nom, `data` | V1-b |
| `topic-subscribers` | `notification_topic_member` (abonné → sujet) | relation | `identifier` unique par (sujet, abonné, identifiant), condition, contextes ; jusqu'à 10 par abonné | V1-b |
| `notification-group` | `notification_category` | document | catégorie de désabonnement | V1-b |
| `notification-template` | `notification_workflow` | document | étapes en **tableau d'objets imbriqués ordonnés** (type, conditions, contrôles, surcharges fournisseur) ; type d'événement déclencheur ; `critical`, `severity`, `tags`, schéma du `payload`, état `draft` / `active` / `inactive` | V1-a |
| `message-template` | `notification_template` | document | contenu d'une étape par canal ; lien vers mise en page | V1-a |
| `localization`, `localization-group`, `translation-group`, `translations` | `notification_template_locale` (V1), puis clés `lyxal_i18n` (V2) | document | V1 : une version du gabarit par langue, langue par défaut en repli ; V2 : clés de traduction et état « obsolète » | V1-a / V2 |
| `layout` | `notification_layout` | document | HTML commun, variables d'image de marque, `is_default` par locataire et canal | V1-a |
| `control-values` | objet imbriqué `controls` dans l'étape ou la mise en page | objet | les niveaux `step_provider` et `step_integration` deviennent `provider_overrides` | V1-c |
| `integration` | `notification_integration` | document | fournisseur, canal, `priority`, `primary`, `conditions` ; `credentials_ref` = **référence** `lyxal_secrets`, jamais une valeur | V1-a |
| `preferences` | `notification_preference` (abonné → parcours, catégorie ou sujet) | relation | niveaux `global`, `workflow`, `topic_subscription`, `tenant_workflow` ; canaux en objet | V1-b |
| `workflow-override` | `notification_preference` niveau `tenant_workflow` | relation | surcharge décidée par une organisation cliente | V1-b |
| `context` | `notification_context` | document | `type`, `key`, `data` ; unique (locataire, type, clé) ; référencé par `context_keys` | V2 |
| `notification` + ClickHouse `workflow_runs` | `notification_run` | document | un déclenchement pour un abonné ; `idempotency_key` **UNIQUE** ; `event_id` `lyxal_event` ; `expires_at` | V1-a |
| `job` + ClickHouse `step_runs` | `notification_job` | document | une étape : statut, tentatives, `next_retry_at`, `locked_until`, clé de digest | V1-a |
| `message` | `notification_message` | document | envoi par canal ; fil in-app : `seen_at`, `read_at`, `archived_at`, `snoozed_until`, actions ; `expires_at` | V1-a / V1-d |
| `execution-details` + ClickHouse `traces` | `notification_delivery_log` | document | journal en ajout seul ; jamais de code ni de lien sensible en clair | V1-a |
| retours fournisseurs (activity tracking) | `notification_provider_event` | document | délivré, ouvert, cliqué, rejeté, plainte ; dédoublonné par identifiant fournisseur | V1-a (rejets) / V2 |
| Postal `suppressions` | `notification_suppression` | document | rejet définitif, plainte, désabonnement ; unique (locataire, canal, adresse) | V1-a |
| étape `throttle` | `notification_rate_limit` | document | compteur par (parcours, clé, fenêtre) | V1-c |
| digest (`_mergedDigestId`) | `notification_digest` | document | fenêtre ouverte : clé, échéance, événements regroupés | V1-c |
| `human-interaction` | `notification_interaction` | document | question `ask` / `approve` / `choose`, destinataires, expiration, réponse | V3 |
| `domain`, `domain-route` | `notification_inbound_domain`, `notification_inbound_route` (route → domaine) | document / relation | statut MX, métadonnées de route | V3 |
| (absent de Novu) | `notification_sender_domain` | document | domaine d'envoi, résultats SPF / DKIM / DMARC, date de contrôle | V2 |
| (Svix, `environment.webhookAppId`) | `notification_webhook_endpoint`, `notification_webhook_delivery` | document | URL, types d'événements, secret de signature dans `lyxal_secrets` ; tentatives | V2 |
| `environment-variable` | `notification_variable` | document | clé, valeur **non secrète** ; les secrets restent dans `lyxal_secrets` | V2 |
| ClickHouse `delivery_trend_counts`, `workflow_run_count` | `notification_stat_hourly` | document | comptages par heure, canal, parcours, statut | V2 |
| limites par plan (`limits.mdx`) | `notification_settings` | document | un par locataire : conservation du journal et du fil, durée max de délai, digest, throttle, snooze | V1-a |
| `channel-connection` | `notification_channel_connection` | document | espace Slack / Teams connecté ; jetons dans `lyxal_secrets`, flux OAuth par `lyxal_connect` | V3 |

### 2.2. Entités sans table propre

| Novu | Où cela va dans Lyxal | Raison |
| :--- | :--- | :--- |
| `organization`, `member`, `user` | `lyxal_auth` (`auth_organization`, `auth_member_of`, `auth_identity`) | Identités et organisations ont un seul propriétaire |
| rôles (`MemberRoleEnum`), SSO, SCIM, MFA | `lyxal_auth` (`auth_role`, `auth_permission`, `auth_identity_provider`) | Ce module déclare seulement ses permissions `notification:*` |
| audit | `lyxal_event` (événements `notification.*`) | Pas de table d'audit locale (même règle que `lyxal_auth`) |
| `environment` (dont `apiKeys`, `widget`, `dns`) | locataire `lyxal_auth`, `auth_api_key` ; `dns` → `notification_inbound_domain` | Pas d'environnements dans Lyxal |
| `change` | Git + révisions `notification_workflow_revision` (V2) | Pas de promotion entre environnements |
| `tenant` (ancien) | locataire natif | Remplacé chez Novu par les contextes |
| `feed` | étiquettes du parcours | Notion abandonnée par Novu |
| secrets d'intégration, `isSecret` des variables | `lyxal_secrets` (à créer) | Secrets scellés `enc:v2` |
| langues, traductions | `lyxal_i18n` (à créer) | |
| délais longs, digests planifiés, purges | `lyxal_scheduler` (à créer) ; en attendant un `LyxalWorker` | |
| déclencheurs, file de travail | `lyxal_event` + `notification_job` | Pas de BullMQ / Redis |
| pièces jointes, pièces de courrier entrant, avatars | `lyxal_storage` (référence de fichier) | |
| `snapshot`, `ai-chat` | aucune | Assistant IA du tableau de bord hors périmètre |
| `agent`, `agent-integration`, `agent-mcp-server`, `agent-tool-trust`, `conversation`, `conversation-activation`, `conversation-activity`, `human-contact`, `mcp-connection` | aucune ici ; module séparé éventuel (§5) | Messagerie conversationnelle IA, pas notification |
| ClickHouse `requests`, `events` | journaux de `lyxal-server` | |

---

## 3. Différences voulues avec Novu

| Sujet | Novu | Lyxal |
| :--- | :--- | :--- |
| Stockage | MongoDB + ClickHouse (journal) + Redis (cache, files BullMQ) + S3 | SurrealDB seul ; fichiers par `lyxal_storage` |
| File de travail | BullMQ (`packages/shared/src/config/job-queue.ts`) | `notification_job` verrouillé par `locked_until`, `LyxalWorker` sous bail (`lyxal_runtime`) |
| Déclenchement | API HTTP `POST /v1/events/trigger` | événements `lyxal_event` consommés par `EventConsumerModule` ; fonction publique `fn::notification_trigger` |
| Idempotence | clé en cache Redis, activée sur demande ; `transactionId` | index `UNIQUE` (locataire, `idempotency_key`) et `event_id` ; un rejeu ne crée rien |
| Nouvelles tentatives | aucune pour un fournisseur (`delivery-retries.mdx`) | attente croissante avec gigue ; erreur temporaire / définitive ; plafond par réglage |
| Secrets des fournisseurs | chiffrement maison dans la base | référence `lyxal_secrets`, scellée par `lyxal_crypto` (`enc:v2`, contexte non vide) |
| Multi-locataire | `_organizationId` + `_environmentId` filtrés par le code | champ `tenant` contrôlé par `PERMISSIONS` ; écriture refusée → `NOTIFICATION_WRITE_FORBIDDEN` |
| Accès au fil in-app | clé publique + empreinte HMAC du `subscriberId` | session `lyxal_auth` ; l'abonné ne lit que ses messages |
| Gabarits | LiquidJS | MiniJinja (bac à sable, variable inconnue = erreur) |
| Code utilisateur | étapes en code exécutées en serverless | aucun code utilisateur ; handlers Rust déclarés par les modules |
| Validation | DTO TypeScript | `lyxal_core` (`fn::validation_object_execute`), erreurs `NOTIFICATION_*` |
| Données sensibles | corps conservé | code ou lien d'un e-mail `auth.*` jamais stocké ni journalisé en clair |
| Conservation | durée selon le plan payant (TTL ClickHouse `expires_at`) | `expires_at` posé à l'écriture selon `notification_settings`, purge par worker |
| Webhooks sortants | service tiers payant (Svix) | fait par Lyxal : signature HMAC `lyxal_crypto`, tentatives suivies |
| Environnements | dev / prod / sur mesure avec publication | bases séparées ; brouillon / publication par révision |
| Fonctions payantes | réservées à des plans | toutes disponibles, réglées par locataire |

---

## 4. Découpage proposé en lots

| Lot | Contenu | Prérequis |
| :--- | :--- | :--- |
| **V1-a — E-mail pour `lyxal_auth`** | Consommation des événements `auth.*` (invitation, vérification, récupération, code). Tables : `notification_settings`, `notification_integration` (SMTP), `notification_workflow` (étape e-mail, `critical`), `notification_template` + `_locale`, `notification_layout`, `notification_run`, `notification_job`, `notification_message`, `notification_delivery_log`, `notification_suppression`, `notification_provider_event` (rejets DSN). Worker d'envoi sous bail (`lettre`, rustls), tentatives, sonde de santé SMTP, purge | Décisions 1, 2, 3 de `RECHERCHE_SOURCES.md` §5 |
| **V1-b — Destinataires et préférences** | Abonnés (création à la volée, import), adresses de canal, sujets et abonnements conditionnels, catégories, préférences à tous les niveaux, heures calmes, désabonnement, diffusion, exclusion de l'acteur, annulation | V1-a ; moteur de conditions (§5) |
| **V1-c — Parcours complets** | Délais, digest, throttle, conditions d'étape, surcharges, contrôles, choix conditionnel d'intégration, envoi groupé, aperçu et test | V1-b ; délais longs après `lyxal_scheduler` |
| **V1-d — Fil in-app** | États, compteurs, actions, onglets, snooze, temps réel | V1-b ; décision temps réel (§5) |
| **V1-e — Autres canaux** | SMS (API HTTP), chat par webhook (Slack, Teams), canal outil (PagerDuty…), puis push (décision crypto) ; fournisseurs e-mail par API (SES, Postmark…) | V1-c |
| **V2 — Observabilité et console** | Écrans console, statistiques horaires, suivi d'activité (ouvertures, clics), webhooks sortants signés, traductions avec `lyxal_i18n`, contextes, variables, révisions publiées, contrôle des domaines d'envoi, étape HTTP | `lyxal_i18n`, `lyxal_secrets` |
| **V3 — Événementiel avancé** | Interactions humaines (approuver / choisir par message), courrier entrant et routes, connexions chat OAuth (`lyxal_connect`), étape personnalisée, outils IA | `lyxal_connect`, décisions §5 |

---

## 5. Points à décider par le CTO

1. **Nouvelles tentatives** : Novu n'en fait aucune pour un fournisseur. Proposition : tentatives
   avec attente croissante dès V1-a (4xx SMTP temporaire, 5xx définitif).
2. **Moteur de conditions** (conditions d'étape, abonnements conditionnels, choix d'intégration) :
   règle générique absente de `lyxal_core`. Candidat d'extension du Core (§5.7.7) ou fonction
   propre au module.
3. **Temps réel du fil in-app** : `LIVE SELECT` SurrealDB exposé par `lyxal-server`, ou flux SSE /
   WebSocket de l'hôte.
4. **Webhooks sortants** (payants chez Novu) : dans ce module, ou dans un module commun à tous les
   producteurs d'événements.
5. **Suivi des ouvertures et clics** (pixel, liens réécrits) : RGPD, consentement, activé par
   locataire ou non.
6. **Cryptographie hors `lyxal_crypto`** (§11.3) : push web (VAPID, ECDSA P-256), APNs (jetons
   ES256), vérification DKIM du courrier entrant (RSA), signature DKIM sortante.
7. **Courrier entrant** : serveur SMTP entrant dans Lyxal (lourd), relais par un fournisseur
   (webhook entrant), ou abandon.
8. **Agents conversationnels** : hors module (recommandé) ; création éventuelle d'un module séparé
   plus tard. Seule l'interaction humaine (`approve` / `choose`) est proposée en V3 ici.
9. **Format des langues** : BCP 47 (`fr-FR`, validé par `lyxal_core`) plutôt que `fr_FR` de Novu.
10. **Étape HTTP** : hôtes autorisés par locataire (protection SSRF) avant toute activation.
11. **Durées de conservation par défaut** (journal, fil, messages) dans `notification_settings`.
12. **Environnements** : confirmer qu'ils sont remplacés par brouillon / publication avec révisions.
