# Feuille de route — passage à SurrealDB 4.0

Lyxal OS fonctionne sur SurrealDB **3.3.4** (binaire `surreal` et SDK Rust `surrealdb` 3.3). Le
passage à la 4.0 est **reporté**. Ce document dit pourquoi, à quelles conditions le chantier est
rouvert, et ce qu'il restera à faire ce jour-là. Le chantier touche tout l'espace de travail : il
aura son propre `implementation_plan.md`, validé par le CTO (`.agents/AGENTS.md` §3).

## 1. Pourquoi le passage est reporté

La 4.0.1 a des régressions de performance ouvertes qui touchent le cœur de notre architecture
(défauts [#7667](https://github.com/surrealdb/surrealdb/issues/7667),
[#7663](https://github.com/surrealdb/surrealdb/issues/7663) et
[#7686](https://github.com/surrealdb/surrealdb/issues/7686) du dépôt `surrealdb/surrealdb`). Les
résultats restent justes, mais le temps de réponse grandit avec la taille des tables :

| Régression de la 4.0.1 | Ce qu'elle vise chez nous |
| :--- | :--- |
| Chaque instruction d'écriture coûte beaucoup plus cher qu'en 3.3, y compris en mémoire | Les tests (base en mémoire) et chaque appel `call_fn` |
| Dans une fonction, une recherche sur un champ indexé parcourt toute la table quand la valeur vient d'un champ de paramètre | Notre standard `fn::<module>_<action>($params: object)` |
| Sur une table avec permissions, l'index n'est plus utilisé pour une valeur connue à l'exécution (`$auth`, variable, argument) | Les clauses `PERMISSIONS` de presque toutes nos tables |
| Dans un événement, une recherche sur `$before` / `$after` parcourt la table | Nos `DEFINE EVENT` |

Aucune nouveauté de la 4.0 ne nous est nécessaire aujourd'hui, et il n'y a aucune donnée à
convertir (régime pré-production, `.agents/AGENTS.md` §0) : attendre ne coûte rien.

## 2. Ce que la 4.0 corrige pour la sécurité

| Alerte | Corrigée par la 4.0 ? | Détail |
| :--- | :--- | :--- |
| `reblessive` (RUSTSEC-2026-0454) | **Oui** | La dépendance est retirée en 4.0 ; aucune version 3.x n'est corrigée. |
| `quick-xml` (RUSTSEC-2026-0194 et RUSTSEC-2026-0195) | **Oui, avec un geste de notre côté** | La 4.0 passe à `quick-xml` 0.41, mais `lyxal_storage` et `lyxal_pipeline_ingestion` dépendent d'`object_store` 0.13, qui garde l'ancienne version : il faut aussi passer à `object_store` 0.14. |
| `crypto-bigint` (RUSTSEC-2026-0387) | **Non** | La 4.0.1 embarque toujours `crypto-bigint` 0.5.5 ; la correction dépend d'une future version des bibliothèques RustCrypto. |
| `rsa` (RUSTSEC-2023-0071, « Marvin ») | **Non** | Suivi dans [`crates/lyxal_auth/ROADMAP.md`](../../crates/lyxal_auth/ROADMAP.md). |

## 3. Conditions pour rouvrir le chantier

1. La **4.0.2 ou la 4.1** est sortie.
2. Les défauts **#7667, #7663 et #7686** sont fermés.
3. Sur une branche d'essai, la suite de tests n'est pas plus lente qu'en 3.3.4 (point « Mesure »
   ci-dessous).

## 4. Ce qui est déjà prêt

Ces points fonctionnent en 3.3.4 et ne seront plus à faire le jour du passage :

| Écart de la 4.0 | État du dépôt |
| :--- | :--- |
| Une fonction ou un bloc qui déclare `LET $event`, `$before`, `$after`, `$value`, `$input`, `$parent`, `$self` ou `$this` est refusé à l'installation | Plus aucune déclaration de ce type dans `crates/` et `apps/` ; `scripts/ci/validate_surql.sh` refuse tout retour ; règle inscrite dans le skill `lyxal-surrealdb` (§2.5). |
| Sans `ORDER BY`, un `LIMIT` ne renvoie plus les lignes dans un ordre garanti | Toutes les listes paginées ont un tri ; les paquets de purge sont triés là où le champ est indexé ou l'ensemble petit (`fn::notification_purge`, parcours et entités supprimées de `fn::auth_purge`) ; les paquets non triés qui restent suppriment des lignes toutes échues, dont l'ordre est indifférent. |
| Un nombre à virgule flottante n'est plus égal à un décimal | Les champs décimaux (`lyxal_base`, `lyxal_catalogue`) sont comparés à des décimaux (`1dec`, `<decimal>`), valeurs par défaut et tests compris. |
| Un identifiant lu depuis une chaîne doit être valide en entier (`type::record` à un argument) | `lyxal_event` construit ses identifiants par la forme à deux arguments (table, identifiant) ; `fn::scheduler_run_ref` et `fn::validation_surql_record_string` contrôlent la chaîne (`string::is_record`, forme canonique) avant de la relire. |

## 5. Ce qu'il restera à faire

| Travail | Détail |
| :--- | :--- |
| SDK Rust | Passer `surrealdb` et `surrealdb-types` en 4.0 dans les 12 crates qui en dépendent, en une fois (un SDK 3.x refuse un serveur 4.0 ; le SDK 4.0 sait parler à un serveur 3.x : le SDK d'abord, le serveur ensuite). Corriger la compilation. |
| `object_store` | Passer à la 0.14 dans `lyxal_storage` et `lyxal_pipeline_ingestion` (alerte `quick-xml`). |
| Scripts de CI | `scripts/ci/install_surreal.sh` (installation par le nouvel outil « Surreal CLI », contrôle de version par texte), `.github/workflows/ci.yml` (version fixée), `scripts/ci/test_all.sh`. |
| Skill `lyxal-surrealdb` | Revérifier chaque règle de compatibilité sur un binaire 4.0 et réécrire le document pour la 4.0. |
| Champs imbriqués | En 4.0 le parent d'un champ imbriqué doit être déclaré : contrôler sur un binaire 4.0 les 8 définitions concernées des tables `secrets_request`, `scheduler_calendar` et `i18n_key`. |
| Paramètres nommés `$value` ou `$input` | Vérifier sur un binaire 4.0 si les **paramètres** de fonctions et de closures portant ces noms (très nombreux dans `lyxal_core`) sont acceptés ; seules les déclarations `LET` ont été renommées. |
| Lecture d'identifiants | Vérifier sur un binaire 4.0 que `string::is_record` refuse bien une chaîne que `type::record` refuse (`fn::validation_surql_record_string`), et qu'un nombre flottant reçu en paramètre est toujours rangé dans un champ `decimal` (`fn::catalogue_item_create`). |
| Mesure | Comparer le temps de la CI (bancs SurrealQL et `cargo test`) avant et après, sur une branche d'essai. |
