# Feuille de route — `lyxal_event`

Évolutions prévues du moteur d'événements. L'état actuel (outbox transactionnelle, livraisons
par abonnement, `ReliableDispatcher`, baux et fencing, dead letter, ramasse-miettes,
intégration `lyxal_runtime`) est décrit dans le [`README.md`](README.md). Chaque étape fait
l'objet d'un `implementation_plan.md` validé par le CTO avant tout développement
(`.agents/AGENTS.md` §3).

---

## Prochaine étape — plusieurs handlers d'un même type dans un même hôte

- [ ] Deux modules d'un **même** hôte qui écoutent le même type d'événement : le registre de
  handlers d'un processus n'accepte qu'un handler par type (`HandlerRegistry::register` refuse
  le second, `DuplicateHandler`) et le champ `handler_name` de l'abonnement ne sert pas au choix
  du handler. Plusieurs hôtes écoutant un même type fonctionnent déjà (un abonnement par hôte).
  À lever avant le premier cas dans `lyxal-groupware` (décision H9 (a) du plan « plusieurs
  hôtes sur une même base », exécuté).
- [ ] Rôle du filtre `instance_id` du worker (décision H9 (b)) : il ne sépare pas les hôtes (les
  événements émis par la base portent le contexte `default`, les hôtes le laissent vide) ;
  le garder avec un usage défini, ou le retirer.

---

## Phase V2 — Observabilité, métriques et exploitation de la dead letter

### Métriques

- [ ] Table `event_statistics` : volumes publiés, livrés, en échec et en dead letter, par minute,
  heure et jour ; latence médiane et p99 entre publication et livraison.
- [ ] Export OpenTelemetry / Prometheus : `lyxal_events_published_total`,
  `lyxal_events_delivered_total`, `lyxal_events_dlq_total`,
  `lyxal_event_delivery_duration_seconds`.

### Exploitation de la dead letter

- [ ] Commandes `lyxal-cli event` :
  - `dlq list [--event-type <motif>] [--module <nom>]` ;
  - `dlq inspect <id>` : payload, métadonnées, trace d'erreur ;
  - `dlq replay <id>` et `dlq replay-all [--event-type <motif>]` : rejeu après correction ;
  - `stats` : débit et état des files.
- [ ] Console (Surrealist, charte §15) : flux inter-modules en direct, file de dead letter et
  rejeu.

### Alertes

- [ ] Alerte si les livraisons en attente d'un hôte **dont le chef est vivant** dépassent un
  seuil pendant une durée donnée (l'hôte sans chef est déjà signalé par la sonde
  `EventEngineHealthCheck`).
- [ ] Alerte à chaque nouvel événement en dead letter.

---

## Phase V3 — Diagnostic et réglage automatiques

- [ ] Analyse des traces d'erreurs en dead letter (schéma incompatible, délai réseau, données
  corrompues) et proposition de correction.
- [ ] Réglage adaptatif de `batch_size`, de l'intervalle d'interrogation et de la durée des baux
  selon la charge mesurée.
- [ ] Suivi continu des temps d'exécution des handlers pour repérer ceux qui ralentissent.

---

## Outillage développeur

- [ ] `#[derive(Event)]` (crate de macros) : `EVENT_TYPE` déduit du nom ou d'un attribut.
- [ ] `lyxal-cli generate handler` : squelette de handler typé et de son abonnement.

Les contrats publics (`Event`, `Handler<E>`, publication, `EventStore`) évoluent selon le régime
en vigueur : rupture coordonnée en pré-production (§0), non-rupture après la première mise en
production (§8).
