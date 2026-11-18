# Plan d'implémentation — préparation au passage à SurrealDB 4.0

Le passage à SurrealDB 4.0 est **reporté** (décision du CTO du 18 novembre 2026, après étude : la
4.0.1 a des régressions de performance ouvertes qui touchent nos fonctions, nos tables à
permissions et nos écritures). Ce plan fait seulement trois préparations qui **fonctionnent en
3.3.4** et retirent du travail le jour du passage. La version de SurrealDB, le SDK Rust et les
scripts d'installation ne changent pas. Aucune ligne de code avant la validation du CTO
(`.agents/AGENTS.md` §3).

## 1. Décisions du CTO

Décisions U1 à U5 **validées par le CTO** le 18 novembre 2026, telles que proposées ci-dessous.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **U1** | Noms de variables réservés en 4.0 | En 4.0, une fonction ou un bloc qui déclare `LET $event`, `$before`, `$after`, `$value`, `$input`, `$parent`, `$self` ou `$this` est refusé à l'installation. Nous en avons **62** (38 dans les modules : `lyxal_core` 17, `lyxal_auth` 8, `lyxal_notification` 5, `lyxal_event` 2, `lyxal_scheduler` 2, `lyxal_secrets` 2, `lyxal_base` 1, `lyxal_pipeline_ingestion` 1 ; 24 dans les tests). Chacune est renommée par un nom qui dit ce qu'elle contient (`$previous`, `$current`, `$cleaned`…), sans changer le comportement. Les variables fournies par la base elle-même (`$before` / `$after` / `$event` d'un `DEFINE EVENT`, `$value` d'un `ASSERT`, `$parent` d'une sous-requête) restent : elles sont lues, pas déclarées. |
| **U2** | Garde contre le retour du problème | Le contrôle SurrealQL de la CI (`scripts/ci/validate_surql.sh`) refuse toute nouvelle déclaration `LET` d'un nom réservé ; la règle est ajoutée au skill `lyxal-surrealdb` (liste des constructions interdites). |
| **U3** | Ordre des résultats | En 4.0, une requête avec `LIMIT` sans `ORDER BY` ne renvoie plus les lignes dans un ordre garanti. Chaque `SELECT … LIMIT` de plus d'une ligne sans tri (environ 30 hors tests, dans `lyxal_auth`, `lyxal_notification`, `lyxal_error`, `lyxal_event`, `lyxal_pipeline_ingestion`, `lyxal_runtime`, `lyxal_scheduler`) est relu : un tri explicite est ajouté quand l'ordre ou le choix des lignes compte (listes paginées, paquets de purge « les plus anciens d'abord », files) ; les recherches d'une seule ligne par clé unique (`LIMIT 1`) ne changent pas. Un tri n'est ajouté que sur un champ indexé ou sur un petit ensemble, pour ne rien ralentir. Les tests qui supposent un ordre sans le demander sont corrigés de la même façon. |
| **U4** | Deux autres écarts silencieux | **Décimaux** : en 4.0 un nombre à virgule flottante n'est plus égal à un décimal ; les comparaisons sur nos champs décimaux (facteurs d'unités, quantités du catalogue) comparent des décimaux à des décimaux. **Identifiants lus depuis une chaîne** : les deux appels `type::record` à un seul argument des modules (`lyxal_core`, `lyxal_scheduler`) passent à la forme à deux arguments (table, identifiant) ou contrôlent leur entrée. |
| **U5** | Feuille de route | La ligne « Passage à SurrealDB 4.0 » de `crates/lyxal_auth/ROADMAP.md` est corrigée et déplacée dans la feuille de route commune (`docs/14-roadmap/`) : la 4.0 corrige les alertes `reblessive` et `quick-xml` (cette dernière seulement avec `object_store` 0.14 de notre côté), **pas** `crypto-bigint` ; conditions pour rouvrir le chantier (4.0.2 ou 4.1 sortie, régressions #7667, #7663 et #7686 fermées) ; ce qui restera à faire ce jour-là (SDK des 12 crates, scripts de CI, règles du skill revérifiées sur un binaire 4.0, champs imbriqués, mesure des temps de la CI avant / après). |

**Hors de ce plan** (non confirmé par les sources lues, à vérifier sur un binaire 4.0 le jour du
passage) : les **paramètres** de fonctions et de closures nommés `$value` ou `$input` (très
nombreux dans `lyxal_core`) ne sont pas renommés maintenant.

## 2. Travaux

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **1** | U1 (renommage), U2 (garde CI et skill) | 8 modules, leurs tests, `scripts/ci/`, `.agents/skills/lyxal-surrealdb/SKILL.md` |
| **2** | U3 (tris), U4 (décimaux, `type::record`) | modules listés en U3, `lyxal_base`, `lyxal_catalogue`, `lyxal_core`, `lyxal_scheduler` |
| **3** | U5 (feuille de route) | `crates/lyxal_auth/ROADMAP.md`, `docs/14-roadmap/` |

Une seule demande de fusion : les trois lots sont petits et sans changement de contrat public
(aucune signature, aucun champ, aucun code d'erreur ne change ; aucun `XxxParams` Rust touché).
Fonctions `lyxal_core` : aucune ajoutée ; celles dont une variable locale est renommée gardent
leur signature et leur résultat.

## 3. Tests

* Bancs SurrealQL existants (`scripts/ci/test_lyxal_core.py`, `scripts/ci/test_lyxal_modules.py`)
  inchangés dans leurs attentes : ils prouvent que le renommage ne change aucun résultat.
* U2 : la garde de la CI échoue sur un fichier d'essai qui déclare `LET $value`, et passe sur le
  dépôt.
* U3 : pour chaque tri ajouté dont l'ordre est un contrat (listes, paquets), un test vérifie
  l'ordre renvoyé.
* U4 : test de comparaison décimal / décimal sur les champs concernés.
* `scripts/ci/ci_local.sh` complet avant la demande de fusion.

## 4. Checklist (§13)

* Aucune primitive du Core ajoutée ni dupliquée ; aucun contrat public modifié.
* SurrealQL : `surreal validate` 3.3.4 sur tous les fichiers touchés ; `COMMENT` conservés.
* Zéro dette : aucun alias (les anciens noms de variables disparaissent) ; feuille de route à
  jour ; ce plan supprimé une fois exécuté.
* Aucun besoin cryptographique.
