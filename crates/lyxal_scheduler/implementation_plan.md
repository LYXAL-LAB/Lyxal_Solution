# Plan d'implémentation — `lyxal_scheduler`, lot 2 : calcul des dates (Rust)

Deuxième lot du programme `lyxal_scheduler` (`implementation_plan.md` à la racine). Il crée le
crate Rust du module et tout le calcul des dates que SurrealDB ne sait pas faire : expressions
cron, intervalles, date unique, fuseaux horaires et changements d'heure, exclusions, calendriers
d'exceptions, bornes, décalage aléatoire, prévision. Il fournit aussi les contrats Rust
(`XxxParams` / `XxxResult`) et les wrappers `store.call_fn` de toutes les fonctions du lot 1. La
boucle du moteur (bail, échéances, exécution) reste au lot 3. Aucune ligne de code avant la
validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **U1** | Précision | Expressions cron de 5 à 7 champs (secondes et année facultatives) ; **au moins 1 minute entre deux échéances** d'une même planification (un rythme plus rapide relève d'un worker, pas d'une planification). Une expression qui tomberait plus souvent est refusée (`SCHEDULER_SPEC_INVALID`). |
| **U2** | Jour du mois et jour de la semaine tous deux renseignés (`0 9 1 * MON`) | Règle de cron classique (Vixie, POSIX) : l'un **ou** l'autre, comme `croner` par défaut. Quartz exige `?` ; on l'accepte aussi. |
| **U3** | Point de départ d'un intervalle (`every: [6h]`) | Compté depuis `start_at` s'il est donné, sinon depuis la **création de la planification** ; un intervalle n'est pas soumis au changement d'heure (durée réelle, modèle Temporal). |
| **U4** | Calendrier qui exclut toutes les dates | Recherche limitée à 5 ans et 10 000 essais ; au-delà, la planification passe à `invalid` (`no_future_fire`) au lieu de bloquer le moteur. |
| **U5** | Décalage aléatoire (`jitter`) | Tiré à chaque échéance entre 0 et `jitter` ; borné à 1 h et à la moitié du plus petit écart entre deux échéances ; la date prévue (`scheduled_for`) reste l'identité de l'exécution, seul `available_at` est décalé. |

Rappel des décisions déjà prises : changement d'heure selon la règle d'Oban et `croner` (S5) ;
fuseau par planification, UTC par défaut ; bibliothèque `croner` (MIT) avec `jiff` (S3).

## 2. Crate

`crates/lyxal_scheduler/Cargo.toml` dans le workspace : `lyxal_surreal`, `lyxal_runtime` (types
d'erreur seulement dans ce lot), `surrealdb`, `serde`, `thiserror`, `tracing`, `jiff` (même
version et base des fuseaux intégrée que `lyxal_i18n`), **`croner`** (MIT,
`default-features = false`, fonction `jiff`), `rand_core` (`OsRng`, pour le décalage). Aucune
dépendance de chiffrement.

```text
src/
├── lib.rs
├── error.rs        SchedulerError (codes SCHEDULER_*, aucune erreur masquée)
├── store.rs        SchedulerStore (Surreal<Any>, LyxalSurrealCall) et wrappers 1-ligne
├── models/         XxxParams / XxxResult de chaque fonction du lot 1 (SurrealValue)
├── spec/
│   ├── mod.rs      Spec : lecture et contrôle d'une planification (cron, every, at, bornes…)
│   ├── cron.rs     expressions cron (croner), règle de changement d'heure
│   ├── calendar.rs règles d'un calendrier (dates, annuel, jours de semaine, jours du mois, plage horaire)
│   └── next.rs     prochaine date, dates manquées entre deux instants, prévision
└── service.rs      SchedulerService : contrôle des planifications avant écriture, prévision
```

## 3. Calcul

* **Prochaine date** après un instant `t` : plus petite date parmi les règles `cron` (dans le
  fuseau de la planification) et `every` (depuis l'ancre, U3), et `at` ; moins les dates de
  `exclude_cron` ; puis passage des calendriers (toutes les inclusions et aucune exclusion,
  modèle Croniq) ; dans `[start_at, end_at]`. Rien après `end_at` : `None`.
* **Dates manquées** entre la dernière échéance traitée et maintenant : liste bornée (1 000), que le
  lot 1 filtre ensuite selon le rattrapage (`last`, `all`, `none`) et sa fenêtre.
* **Changement d'heure** (S5) : heure inexistante → juste après le saut ; heure répétée → une
  seule exécution pour une heure fixe, les deux pour un joker ou un pas (`*/5`).
* **Prévision** : N prochaines dates (100 au plus) avec leur heure locale, pour l'affichage.
* **Contrôle** à l'écriture (`SchedulerService::schedule_create` / `_update`) : syntaxe de chaque
  expression, nom de fuseau IANA, au moins une échéance future, écart minimal (U1), `jitter`
  (U5), règles des calendriers. Erreur `SCHEDULER_SPEC_INVALID` avec la règle fautive. Une
  planification écrite directement en SurrealQL sans passer par Rust est contrôlée par le moteur
  (lot 3), qui la passe à `invalid`.

## 4. Contrats Rust

* `SchedulerStore` : `Surreal<Any>`, `LyxalSurrealCall` ; chaque fonction publique du lot 1 a son
  wrapper `store.call_fn("scheduler_…", params)` et ses types `XxxParams` / `XxxResult`
  (structures nommées, `SurrealValue`, aucun tuple).
* `SchedulerService` : `schedule_create`, `schedule_update` (contrôle puis appel), `forecast`
  (lecture de la planification puis calcul), `validate_spec` (sans écriture).
* `Spec::next_after`, `Spec::fire_times_between`, `Spec::forecast` : fonctions pures, testées sans
  base.

## 5. Erreurs

Aucun code nouveau : `SCHEDULER_SPEC_INVALID` (détails : règle, raison) et
`SCHEDULER_CALENDAR_NOT_FOUND` existent depuis le lot 1. Raison `no_future_fire` ajoutée aux
détails (U4).

## 6. Tests

* **Cron** : jeux de cas repris de `croner`, Quartz et Croniq — fin de mois, `L`, `5L`, `15W`, `LW`,
  `6#3`, alias, secondes, années, 29 février, jour du mois **ou** jour de la semaine (U2),
  expressions fausses.
* **Changement d'heure** : Europe/Paris et America/New_York, printemps et automne, heure fixe,
  joker et pas.
* **Intervalles** : ancre `start_at` ou création, indépendance du changement d'heure (U3).
* **Calendriers** : chaque sorte de règle, inclusion et exclusion, calendrier qui exclut tout (U4).
* **Bornes, date unique, exclusions, décalage** (U5), **dates manquées** (limite de 1 000),
  **prévision**.
* **Wrappers** : chaque fonction du lot 1 appelée par son wrapper en base embarquée (`mem://`),
  succès et erreur décodés.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 7. Documents

`README.md` (partie Rust, règles de calcul), `ROADMAP.md`, `RECHERCHE_SOURCES.md` inchangé
jusqu'à la clôture ; ligne 2 du plan racine passée à « Réalisé ». Ce plan est supprimé dans la
demande de fusion de l'implémentation.

## 8. Checklist (§13)

* Rust : `XxxParams` / `XxxResult`, wrappers `call_fn`, aucun `raw_query` métier, aucun `panic!`
  ni `unwrap` hors tests, aucune erreur masquée.
* Aucune logique métier dupliquée : les règles de rattrapage, de chevauchement et d'état restent
  en SurrealQL (lot 1) ; Rust ne calcule que des dates.
* Crypto : aucune ; `OsRng` pour le décalage aléatoire.
* Zéro dette : `0.1.0`, aucun alias.
