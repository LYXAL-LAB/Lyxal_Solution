# Plan d'implémentation — `lyxal_i18n`, lot 6 : clôture

Dernier lot du programme `lyxal_i18n` (`implementation_plan.md` à la racine). Il corrige les
écarts relevés par l'audit de conformité du module (skill `lyxal-audit`, lecture seule, 11 novembre
2026) et met la documentation à l'état final. Aucune ligne de code avant la validation du CTO
(`.agents/AGENTS.md` §3).

## 1. Résultat de l'audit

Contrôles sans écart :

| Contrôle | Constat |
| :--- | :--- |
| Manifeste | chaque fichier de `[resources]` existe, aucun `.surql` oublié ; dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`, sans cycle ; version `0.1.0` |
| Fonctions SurrealQL | 35 fonctions, toutes avec `COMMENT`, la plus longue fait 53 lignes ; fonctions publiques en `$params: object`, retours `fn::result_ok` / `fn::error_result` ; aucun `fn::result_error` |
| Erreurs | chaque code `I18N_*` utilisé est défini, chaque code défini est utilisé |
| Rust | un wrapper `store.call_fn` par fonction publique ; aucun `panic!`, `unwrap()`, `expect()`, `tokio::spawn` ni `raw_query()` hors tests ; aucune crate cryptographique |
| Événements | publication par `fn::event_publish`, résultat vérifié (`THROW`) |
| Zéro dette | une seule version, aucun alias, aucun `CHANGELOG.md` |

Écarts à corriger :

| N° | Gravité | Écart | Référence |
| :- | :- | :--- | :--- |
| **A1** | P1 | `fn::i18n_locale_list` met en minuscules l'étiquette et les noms par `string::lowercase` pour la recherche, au lieu de `lyxal_core` | `functions/i18n_locale.surql:29-31`, §5.7.8 |
| **A2** | P1 | La lecture d'un argument de message retire les espaces par `string::trim`, au lieu de `lyxal_core` | `functions/i18n_message.surql:15-16`, §5.7.8 |
| **A3** | P1 | Le champ `i18n_locale.language` est vérifié par une expression régulière locale, alors que la règle `language_code` de `lyxal_core` existe | `schema/01_i18n_locale.surql:27`, §5.7.8 |
| **A4** | P2 | Rapport d'import : un compteur négatif reçu de la base deviendrait `0` sans erreur (`unwrap_or_default`) | `src/exchange/mod.rs:285-287`, §11.4 |
| **A5** | P2 | Export XLIFF : une clé sans texte source est écrite avec une source vide, sans erreur | `src/exchange/xliff.rs:118`, §11.4 |
| **A6** | P2 | Documents : le plan du programme à la racine est exécuté ; `RECHERCHE_SOURCES.md` garde l'inventaire de départ et des mentions de lots ; `ROADMAP.md` et le `README.md` citent des numéros de lots et de décisions | §0.2, §0.3 |

Non vérifié par l'audit : le comportement sur un serveur SurrealDB distant en production
(`wss://`) ; les bancs tournent sur un serveur 3.3.4 local et sur le moteur embarqué.

## 2. Décision demandée au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **C1** | Où garder les décisions du programme (Q1 à Q7 et celles des lots) une fois le plan racine supprimé ? | Dans le document des sources du module, renommé **`MODELE_SOURCES.md`** comme ceux de `lyxal_auth` et de `lyxal_notification`. Il garde les sources retenues, les sources écartées et les décisions ; l'inventaire de départ et le suivi des lots en sont retirés |

## 3. Corrections

### 3.1. SurrealQL

* **A1** : `fn::i18n_locale_list` compare par `fn::sanitize_lowercase` (déjà utilisée pour le
  terme recherché). Signature et résultat inchangés.
* **A2** : `fn::i18n_message_argument` (interne) nettoie par `fn::sanitize_trim`. Résultat
  inchangé.
* **A3** : `ASSERT fn::validation_language_code($value, true, NONE).value == $value` sur
  `i18n_locale.language`, comme les autres contrôles de schéma du module.
  Le seed des 924 langues n'est pas modifié (codes de 2 ou 3 lettres minuscules).

Fonctions Core réutilisées : `fn::sanitize_lowercase`, `fn::sanitize_trim`,
`fn::validation_language_code`. Aucune fonction nouvelle, aucune fonction Core manquante, aucun
code d'erreur ajouté.

### 3.2. Rust

* **A4** : les compteurs de `ImportResult` (`created`, `updated`, `unchanged`) sont convertis
  sans valeur de remplacement ; un compteur négatif rend une nouvelle variante
  `ExchangeError::InvalidReport`. `ImportReport` inchangé.
* **A5** : `xliff::write` refuse une ligne sans texte source par une nouvelle variante
  `ExchangeError::MissingSource(clé)` ; rien n'est écrit pour ce fichier.

Types : `XxxParams` et `XxxResult` existants, inchangés.

### 3.3. Documents (A6, C1)

* `implementation_plan.md` à la racine : **supprimé** (programme exécuté).
* `crates/lyxal_i18n/RECHERCHE_SOURCES.md` → `MODELE_SOURCES.md` : sources retenues, sources
  écartées, points de vigilance, décisions Q1 à Q7 et décisions des lots encore en vigueur
  (repli, portée des surcharges, formats d'échange, modèle des e-mails) ; inventaire de départ
  et numéros de lots retirés.
* `README.md` de `lyxal_i18n` : en-tête et renvois mis à jour ; l'écart connu entre le contrôle
  de la base et le lecteur ICU (accolade fermante isolée) reste décrit.
* `ROADMAP.md` de `lyxal_i18n` : seules les évolutions à venir, sans numéros de lots.
* `docs/14-roadmap/ROADMAP_NOYAU.md` : `lyxal_i18n` décrit comme livré, renvoi vers sa feuille
  de route.
* Ce plan est supprimé dans la demande de fusion de l'implémentation.

## 4. Tests

* Banc SurrealQL `langues` : recherche insensible à la casse inchangée ; langue à code invalide
  refusée par le schéma.
* Banc `controles` : argument entouré d'espaces lu comme avant.
* Rust : export XLIFF d'une ligne sans source refusé ; compteur négatif refusé.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Checklist (§13)

* Architecture : aucun contrat public modifié ; aucun appelant à mettre à jour.
* Core : trois écarts corrigés par des fonctions existantes ; aucune extension demandée.
* Crypto : sans objet.
* Zéro dette : plan racine et plan du lot supprimés, aucun document historique conservé.
