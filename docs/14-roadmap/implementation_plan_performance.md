# Plan d'implémentation — débit de la remise du courrier (performance)

Plan d'étude et de correction du débit de la remise d'un message reçu (`MailIngest::receive`,
lot 5c du programme courrier). Objectif du lot 5 (§10.5) : 300 remises par seconde, 200 au moins
sur un serveur SurrealDB joint par `ws://`. Mesuré au lot 5c : 11 à 25.

**Conclusion, en clair.**

* Le temps d'une remise est du temps de calcul de la base : 83 à 92 ms sur 91 ms.
* Les deux tiers de ce temps viennent du moteur de validation de `lyxal_core` appelé par son nom
  de règle (`fn::validation_object_execute`). La cause est dans SurrealDB 3.3 : une définition de
  fonction est relue et réanalysée à chaque transaction, et l'appel d'une fonction qui ne fait que
  lire charge tout son graphe d'appels (les 177 validateurs du Core).
* Trois corrections prototypées et mesurées portent le débit de **10,7 à 85–94 remises par
  seconde** sur la même machine à 4 cœurs (client et serveur ensemble), et une remise seule de
  **90,7 à 37–39 ms**.
* **300 par seconde n'est pas atteignable sur 4 cœurs**, et 200 non plus : même sans aucune
  validation, une remise coûte 25,5 ms de calcul à la base, soit 157 par seconde au plus sur
  4 cœurs réservés à la base. Objectif réaliste proposé : **90 par seconde sur 4 cœurs partagés,
  120 sur 4 cœurs réservés à la base** (décision P10).

Touche, si le plan est validé : `crates/lyxal_core` (deux fonctions nouvelles), `crates/lyxal_mail`,
`crates/lyxal_storage`, `crates/lyxal_secrets`, `crates/lyxal_event`, `crates/lyxal_surreal`,
`crates/lyxal_host`, `apps/lyxal-server`, `apps/lyxal-groupware`, `.agents/AGENTS.md` (§5.7.8),
documents. `lyxal_booking/` n'est pas touché. Aucune primitive cryptographique nouvelle. Aucune
ligne de code avant la validation de ce plan par le CTO (`.agents/AGENTS.md` §3).

Méthode : mesures du 25 novembre 2026, machine de développement à 4 cœurs, serveur
`surreal` 3.3.4 en mémoire (`surreal start memory`), binaire d'essai optimisé
(`cargo test -p lyxal_mail --release --test it`), messages de 10 Kio. Deux bancs :

* **banc Rust** existant (`crates/lyxal_mail/tests/it/measures.rs`), par `ws://` ;
* **banc SurrealQL** jetable écrit pour cette étude (hors dépôt) : modules installés comme le fait
  `scripts/ci/test_lyxal_modules.py`, puis chaque appel public dans sa propre transaction comme
  le fait `call_fn`, temps relevés dans le serveur (`time::now()` avant et après). Il sépare le
  **premier appel** d'une fonction dans une transaction du **deuxième**.

Les prototypes ont été posés par `DEFINE FUNCTION OVERWRITE` dans des bases jetables, et par une
modification locale de trois stores Rust pour le pool ; tout a été annulé (`git checkout .`). Les
prototypes sont des mesures, pas du code à reprendre tel quel (§9). Chaque chiffre de ce plan est
marqué **mesuré** ou **estimé**. Ce qui n'est pas vérifié est listé au §10.

## Bilan de réutilisation (`AGENTS.md` §3, §5.7)

**Fonctions `lyxal_core` réutilisées** : les primitives `fn::validation_record`,
`fn::validation_integer`, `fn::validation_hexadecimal`, `fn::validation_language_code`,
`fn::validation_enum`, `fn::validation_boolean`, `fn::validation_datetime`,
`fn::validation_optional_string`, `fn::validation_required_string`,
`fn::validation_array_of_strings`, `fn::validation_array_length`, `fn::validation_object`,
`fn::validation_max_serialized_length`, `fn::validation_lyxal_storage_path`,
`fn::validation_filename`, `fn::validation_mime_type`, `fn::validation_checksum`,
`fn::validation_starts_with`, `fn::validation_uuid`, `fn::validation_regex`,
`fn::validation_record_id` (toutes présentes, signatures vérifiées). Aucune n'est modifiée.

**Fonctions `lyxal_core` nouvelles — décision CTO obligatoire (§5.7.7)** :

| Fonction proposée (nom à valider) | Rôle | Décision |
| :--- | :--- | :-: |
| `fn::validation_fields_execute($value, $fields, $unknown_keys)` | Exécuteur d'objet dont les contrôles sont des fermetures remises par le module, qui appellent les primitives du Core ; même rapport `{ valid, value, errors, warnings, by_field }` que `fn::validation_object_execute` | P1 |
| `fn::validation_checks_report($value, $checks)` | Rapport `{ valid, value, by_field }` à partir de résultats de primitives déjà calculés, clés inconnues refusées ; pour les chemins chauds réservés au worker | P4 |

**Fonctions `lyxal_core` modifiées** : aucune. `fn::validation_object_execute`, les catalogues et
`fn::utils_engine_*` restent tels quels (contrat inchangé).

**Fonctions métier** : aucune fonction publique nouvelle dans les sous-lots 1 à 4 ; deux dans le
sous-lot 5 s'il est retenu (§5.5). Contrats changés : §6.

## 1. Constat chiffré (mesuré)

### 1.1. Les mesures du lot 5c, refaites

| Mesure (serveur `ws://`, une connexion) | Lot 5c (README) | Refait |
| :--- | :-: | :-: |
| Une remise seule, moyenne de 300 | 96 ms | **90,7 ms** |
| dont `fn::mail_delivery_begin` | 9,0 ms | 8,3 ms |
| dont écriture chiffrée du fichier | 38,4 ms | 35,7 ms |
| dont `fn::mail_delivery_commit` | 48,2 ms | 46,7 ms |
| dont lecture MIME | 0,05 ms | 0,06 ms |
| `FileKeys::seal` | 13,1 ms | 13,6 ms (lecture du trousseau : 13,5 ms) |
| Contrôle allégé d'un élément, requête isolée, 5 et 67 adresses | 22 à 25 ms | 21,2 et 23,7 ms |
| 100 comptes d'une organisation, 50 clients, 3 000 remises | 11,8 par seconde | **10,7 par seconde** |
| Même mesure, une connexion par service | 16,9 par seconde | 15,8 par seconde |

Les chiffres du lot 5c sont confirmés.

### 1.2. Une remise, poste par poste

Banc SurrealQL, chaque appel dans sa transaction, moyenne de 100 :

| Appel | Temps | Avec le moteur de validation remplacé par un passage minimal (borne basse) |
| :--- | :-: | :-: |
| `fn::mail_delivery_begin` | 8,0 ms | 3,5 ms |
| `fn::storage_object_begin` | 9,8 ms | 4,4 ms |
| `fn::secrets_tenant_key_ring` (lu par `FileKeys::seal`) | 12,7 ms | 1,3 ms |
| `fn::storage_object_commit` | 9,6 ms | 4,1 ms |
| `fn::mail_delivery_commit` (un message) | 43,5 ms | 12,1 ms |
| **Total base** | **83,5 ms** | **25,5 ms** |

Écart avec le banc Rust (90,7 ms) : disque, chiffrement et cinq allers-retours, 3 à 7 ms. Le
moteur de validation pèse donc **58 ms sur 83,5 (69 %)**. La borne basse de 25,5 ms est ce qu'il
reste si la validation ne coûtait rien : c'est le plancher de toute correction qui ne touche qu'à
la validation.

### 1.3. Le serveur suit le nombre de connexions, jusqu'au nombre de cœurs

Banc SurrealQL, N clients, une connexion HTTP chacun, une organisation par client :

| Clients | 1 | 2 | 4 | 8 | 16 |
| :--- | :-: | :-: | :-: | :-: | :-: |
| Remises par seconde, fonctions actuelles | 11,3 | 21,7 | 45,3 | 43,5 | 41,3 |

Le serveur occupe ses 4 cœurs à partir de 4 connexions ; au-delà, rien de plus. Avec une seule
connexion (`ws://`), 50 clients obtiennent 10,7 remises par seconde : une connexion exécute ses
requêtes une à une. **Aujourd'hui, 4 cœurs donnent 45 remises par seconde au plus**
(4 / 0,088 s), quel que soit le reste.

Dans une même organisation, les compteurs `storage_usage` font échouer les transactions : 22,2
remises par seconde et 324 conflits en 12 s à 4 clients, 15,2 et 402 conflits à 16 clients.

## 2. Causes prouvées

### 2.1. Une fonction qui ne fait que lire charge tout son graphe d'appels (C1)

Lu dans le moteur (`surrealdb-core` 3.3.5, `exec/planner.rs`, `fnc/mutability.rs`,
`exec/physical_expr/function/user_defined.rs`, `surrealdb-datastore` `tx.rs`) :

* à la planification d'un appel `fn::x(...)` au premier niveau d'une requête, le moteur parcourt
  tout le graphe des fonctions que `x` peut appeler, pour savoir si l'appel écrit
  (`resolve_mutability`). Le parcours s'arrête à la première écriture trouvée ; pour une fonction
  qui ne fait que lire, il va jusqu'au bout, **à chaque appel** ;
* chaque définition visitée est lue dans la base et **réanalysée depuis son texte**
  (`FunctionDefinition::from_stored`, analyseur `surrealdb_syn`) ; elle n'est gardée que pour la
  durée de la transaction ;
* le corps d'une fonction est replanifié à chaque appel.

Prouvé par la mesure sur le serveur 3.3.4 (médianes, premier appel puis deuxième appel dans la
même transaction) :

| Appel | Premier | Deuxième |
| :--- | :-: | :-: |
| `fn::validation_record` (primitive) | 0,10 ms | 0,04 ms |
| `fn::validation_step_apply`, règle `record`, au premier niveau | 7,40 ms | 0,63 ms |
| `fn::validation_step_apply` dans une fonction qui ne fait que lire | 7,39 ms | 0,62 ms |
| `fn::validation_step_apply` dans une fonction dont le corps écrit | **0,82 ms** | 0,23 ms |
| `fn::validation_object_execute`, un champ, au premier niveau | 8,94 ms | 1,45 ms |
| La même, dans une fonction dont le corps écrit | 2,80 ms | 1,24 ms |
| La même, **jamais exécutée**, dans une fonction qui ne fait que lire | **8,21 ms** | 0,56 ms |
| La même, jamais exécutée, dans une fonction dont le corps écrit | 0,03 ms | 0,01 ms |

`fn::validation_step_apply` est un aiguillage de 227 lignes qui nomme les 177 validateurs du Core :
un appel au premier niveau, ou dans une fonction qui ne fait que lire, les fait tous charger
(7,4 ms), même si un seul sert. Contre-épreuve sur des fonctions d'essai : un aiguillage de
160 branches vers 160 fonctions différentes coûte 1,49 ms au premier appel, contre 0,59 ms vers
une seule fonction ; le deuxième appel coûte 0,20 ms quelle que soit la branche prise (corps
replanifié en entier).

Conséquences mesurées :

* `fn::secrets_tenant_key_ring` (trois champs, une lecture) coûte 12,7 ms : c'est une fonction
  publique qui ne fait que lire ;
* `fn::storage_object_get` : 11,0 ms au premier niveau ; `fn::storage_bucket_get` : 10,4 ms ;
* toute fonction publique de lecture de Lyxal OS paie ce coût. Les modules comptent 524 appels
  de `fn::validation_object_execute` hors tests.

Profil du moteur embarqué (40 relevés de pile pendant la mesure de validation) : 9 relevés sur 40
dans l'analyseur de texte appelé par `from_stored`.

### 2.2. Le moteur par nom de règle coûte 1,5 ms par objet même réchauffé (C2)

Deuxième appel dans la transaction : un champ 1,58 ms, les 4 champs de l'ouverture 2,94 ms, contre
0,15 ms pour les 4 primitives appelées directement. Détail d'un champ : `fn::utils_engine_schema`
0,68 ms (catalogue de 177 règles construit, converti et filtré à chaque appel),
`fn::validation_step_apply` 0,65 ms (aiguillage replanifié), le reste dans l'état et le rapport.
L'optimiseur, les traces et les mesures du moteur ne sont pas appelés sur ce chemin : ils ne
coûtent rien.

Profil : 28 relevés sur 40 dans l'interprète des corps de fonctions, 23 sur 40 dans une copie de
mémoire. Le coût suit le nombre d'opérations SurrealQL exécutées.

### 2.3. Les valeurs en portée sont recopiées à chaque appel (C3)

`fn::mail_delivery_commit`, coût par message selon la taille de l'enveloppe et du lot (avec le
prototype du §3.1) :

| Destinataires dans l'enveloppe | Lot de 1 | Lot de 8 |
| :--- | :-: | :-: |
| 3 | 17,2 ms | 12,4 ms |
| 30 | 18,2 ms | 17,1 ms |
| 150 | 23,9 ms | **38,9 ms** |

Le coût par message monte avec la taille des valeurs portées et avec la taille du lot : chaque
appel de fermeture recopie ses variables, dont le lot entier. Avec des primitives appelées
directement (§3.4) : 11,2, 12,3 et 16,5 ms par message dans un lot de 8.

### 2.4. `fn::event_publish` (C4)

6,1 ms réchauffé, 8,3 ms au premier appel ; 5,2 ms sans la ventilation. Avec le prototype du
§3.1 : 1,98 ms, et 1,38 ms sans la ventilation. Le moteur de validation (12 champs) en fait donc
4,1 ms. Le reste est l'écriture de `event_outbox` (16 champs, 2 index) et la ventilation, qui
réécrit la même fiche.

### 2.5. Compteurs `storage_usage` (C5)

Chaque fichier écrit deux fois les deux mêmes lignes de son organisation (ouverture, puis fin
d'écriture). Mesuré au banc Rust avec un pool de 8 connexions et le prototype du §3.1 :

* avec `WriteTurns` : 48,5 remises par seconde, aucune refusée ;
* sans `WriteTurns` : **1 848 remises refusées sur 3 000** pour conflit de transaction.

`fn::storage_bucket_get`, appelée par chaque élément remis, lit en plus ces compteurs alors que
le courrier n'a besoin que du nom, de l'organisation et du chiffrement du bucket.

### 2.6. Une connexion par hôte (C6)

§1.3 : 10,7 remises par seconde avec une connexion, 45 avec quatre. Un pool seul, sans autre
correction, donne 20,5 remises par seconde au banc Rust (pool de 8, `WriteTurns` gardé).

### 2.7. Lecture du trousseau « fichiers » (C7)

`FileKeys::seal` : 13,6 ms, dont 13,5 ms pour `fn::secrets_tenant_key_ring`. Cette fonction ne
contient qu'une lecture : son coût est celui de C1. Avec le prototype du §3.1 elle tombe à 2,1 ms
dans la base et `FileKeys::seal` à 2,3–2,7 ms. Sceller depuis le cache n'en retirerait plus que
ces 2,5 ms (décision P7).

### 2.8. Pistes écartées par la mesure

* **`--planner-strategy compute-only`** du serveur : aucun gain (89,9 ms hors trousseau), et
  `fn::secrets_tenant_key_ring` est refusée (« Cannot ORDER BY `created_at` because it is not in
  the statement selection »).
* **Aiguillage à deux niveaux dans `fn::validation_step_apply`** : non prototypé, écarté par
  lecture du moteur. Le parcours du graphe est transitif : il chargerait les mêmes définitions.
* **Table des validateurs rangée dans un `DEFINE PARAM`** : refusé par la base (« Closures cannot
  be stored on disk »).

Il n'existe donc pas de correction du moteur par nom de règle qui garde son contrat et retire C1.

## 3. Corrections prototypées (gains mesurés)

### 3.1. Contrôles par fermetures sur les chemins chauds

Prototype : `fn::validation_fields_execute` (30 lignes), et huit fonctions du chemin de remise
réécrites pour l'utiliser : `fn::mail_delivery_begin`, `fn::mail_delivery_commit`,
`fn::storage_object_begin`, `fn::storage_object_commit`, `fn::storage_object_get`,
`fn::storage_bucket_get`, `fn::secrets_tenant_key_ring`, `fn::event_publish`. Forme d'un appel :

```surql
LET $report = fn::validation_fields_execute($params, {
    account: { checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true },
    size: { checks: [|$v: any| fn::validation_integer($v, 1, 5368709120)], required: true },
    delivery_key: { checks: [|$v: any| fn::validation_hexadecimal($v, 64, 64, false)], required: true },
    language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
}, "reject");
```

Le module ne nomme que les primitives qu'il utilise : son graphe d'appels reste petit. Les
valeurs par défaut, les champs exigés, les clés inconnues et le rapport restent dans le Core.

| Mesure | Avant | Après |
| :--- | :-: | :-: |
| 4 champs de l'ouverture, premier appel / deuxième | 10,64 / 2,94 ms | **0,98 / 0,56 ms** |
| Un champ, premier appel / deuxième | 9,44 / 1,66 ms | 0,45 / 0,21 ms |
| `fn::mail_delivery_begin` | 9,4 ms | 5,2 ms |
| `fn::storage_object_begin` | 10,6 ms | 6,2 ms |
| `fn::secrets_tenant_key_ring` | 14,5 ms | 2,1 ms |
| `fn::storage_object_commit` | 10,6 ms | 5,5 ms |
| `fn::mail_delivery_commit` | 47,4 ms | 17,6 ms |
| Total base (même série) | 92,5 ms | **36,6 ms** |
| `fn::event_publish`, deuxième appel | 6,11 ms | 1,98 ms |
| Banc Rust, une remise seule | 90,7 ms | **38,7 ms** |
| Banc Rust, `FileKeys::seal` | 13,6 ms | 2,5 ms |
| Banc Rust, 100 comptes, 50 clients, une connexion | 10,7 par seconde | 24,6 par seconde |
| Banc SurrealQL, 4 clients, une organisation chacun | 45,3 par seconde | 124,4 par seconde |

### 3.2. Pool de connexions

Prototype : les stores `MailStore`, `StorageStore` et `SecretsStore` répartissent leurs appels à
tour de rôle sur N connexions ouvertes sous la session système.

| Banc Rust, 100 comptes d'une organisation, 50 clients | Remises par seconde |
| :--- | :-: |
| Fonctions actuelles, une connexion | 10,7 |
| Fonctions actuelles, pool de 8, `WriteTurns` gardé | 20,5 |
| §3.1, une connexion | 24,6 |
| §3.1, pool de 8, `WriteTurns` gardé | 48,5 |

Au-delà du nombre de cœurs, rien de plus : pool de 4, 8 et 16 donnent 84,8, 89,4 et 85,9 (avec
§3.3).

### 3.3. Compteurs de volume sans ligne partagée

Deux prototypes, dans `fn::storage_usage_apply` et `fn::storage_scope_usage` :

* **(a) compteurs répartis** : 64 lignes par portée et 64 par bucket ; chaque écriture en tire
  une au sort ; la lecture additionne 64 lignes au plus ;
* **(b) journal de variations** : chaque écriture ajoute une ligne ; la lecture additionne la
  ligne consolidée et les variations en attente ; une tâche de maintenance consolide (non
  prototypée).

Banc SurrealQL, N clients dans une même organisation, avec §3.1 :

| Clients | 1 | 2 | 4 | 8 | 16 |
| :--- | :-: | :-: | :-: | :-: | :-: |
| Compteurs actuels | 30,2 | 45,5 | 54,8 (1 039 conflits) | 51,1 | 47,7 |
| (a) compteurs répartis | 30,2 | 59,3 | 122,6 (46 conflits) | 118,0 (72) | 112,0 (169) |
| (a) avec un quota défini | 28,1 | 54,7 | 114,6 (56) | 112,4 (73) | 98,1 (161) |
| (b) journal | 29,8 | 59,6 | 126,7 (0) | 120,3 (0) | 116,5 (0) |
| (b) avec un quota défini, sans consolidation | 24,0 | 36,2 | 54,2 (0) | 42,4 | 35,5 |

(a) laisse 3 % de conflits à 4 clients, rejoués par `lyxal_storage` (six essais). (b) n'en laisse
aucun, mais avec un quota chaque écriture relit les variations en attente : le débit baisse tant
que rien n'est consolidé.

Banc Rust, 100 comptes d'une organisation, 50 clients, pool de 8, `WriteTurns` retiré, avec §3.1 :

| Compteurs | Remises par seconde | Refusées |
| :--- | :-: | :-: |
| Actuels | 24,2 | 1 848 sur 3 000 |
| (a) répartis | **89,4** (p50 398 ms, p95 1 326 ms) | 0 |
| (b) journal | **91,1** | 0 |

Avec un pool de 4 et (a) : 84,8 par seconde, une remise refusée sur 3 000
(`SURREAL_DATABASE_ERROR`, cause non recherchée).

### 3.4. Inscription allégée (chemins réservés au worker)

Prototype, en plus du §3.1 et du §3.3 (a) : éléments d'un lot contrôlés par appels directs des
primitives et `fn::validation_checks_report` ; `fn::event_publish` de même ; fichier et bucket
relus par deux lectures de trois champs au lieu de `fn::storage_object_get` et
`fn::storage_bucket_get`.

| Mesure | §3.1 | §3.4 |
| :--- | :-: | :-: |
| Contrôle d'un élément, deuxième appel | 2,59 ms | 1,23 ms |
| `fn::mail_delivery_commit` par message, lot de 8 / 16 / 32 | 12,0 / 12,7 / 16,4 ms | 11,8 / 11,1 / 10,8 ms |
| Par message, lot de 8, enveloppe de 150 destinataires | 38,9 ms | 16,5 ms |
| Banc Rust, une remise seule | 38,7 ms | 37,0 ms |
| Banc Rust, 100 comptes, 50 clients, pool de 8 | 89,4 par seconde | **93,9 par seconde** |
| Banc Rust, un compte, 20 clients, pool de 8 | non mesuré | 60,3 par seconde (lots de 17 au plus) ; lot 5c : 10,9 |

Le gain est faible pour un petit message, net pour un lot ou une grande enveloppe (C3). Le
contrôle de `fn::event_publish` n'y gagne rien (1,94 ms contre 1,98 ms) : son coût restant est
l'écriture.

### 3.5. Moins de transactions

Prototype : une fonction qui enchaîne `fn::mail_delivery_begin` et `fn::storage_object_begin`,
une autre qui enchaîne `fn::storage_object_commit` et `fn::mail_delivery_commit`. Avec §3.1 et
§3.3 (a), hors lecture du trousseau : **31,1 ms contre 34,5 ms** (9,8 ms pour l'ouverture, 21,3 ms
pour la clôture). Gain : 3,4 ms, 10 %. Avec des compteurs répartis, les conflits montent (134 en
12 s à 4 clients contre 46) : les transactions sont plus longues.

### 3.6. Ce qui reste dans une remise après correction

`fn::mail_delivery_commit`, par message dans un lot de 8, avec §3.1, en retirant un poste après
l'autre :

| État | Par message |
| :--- | :-: |
| §3.1 | 12,6 ms |
| sans l'événement `mail.message.received` | 10,1 ms |
| sans `fn::storage_object_get` ni `fn::storage_bucket_get` | 9,1 ms |
| sans aucun contrôle des paramètres | 4,6 ms |

Les 4,6 ms restants sont l'inscription : `mail_message`, sa vue par date, la fiche d'idempotence,
le contenu (deux écritures), le dossier (deux écritures), le compte, et les gardes de chacune
(`UPDATE mail_mailbox` : 0,34 ms réchauffé ; `mail_account` : 0,20 ms ; `mail_content` : 0,13 ms).

## 4. Débit atteignable

| État | Une remise seule (banc Rust) | 100 comptes, 50 clients, 4 cœurs partagés (banc Rust) | Base seule sur 4 cœurs (banc SurrealQL) |
| :--- | :-: | :-: | :-: |
| Aujourd'hui | 90,7 ms | 10,7 par seconde | 45 par seconde |
| Sous-lot 1 | 38,7 ms | 24,6 | 124 |
| Sous-lots 1 et 2 | 38,7 ms | 48,5 | 124 (55 dans une organisation) |
| Sous-lots 1, 2 et 3 | 38,7 ms | **85 à 91** | 115 à 127 |
| Sous-lots 1 à 4 | 37,0 ms | **93,9** | non mesuré |
| Sous-lots 1 à 5 | **estimé** 33 ms | **estimé** 100 à 110 | **estimé** 130 à 140 |
| Sans aucune validation (plancher) | — | — | 157 au plus (25,5 ms) |

Toutes les lignes sont mesurées, sauf celle marquée « estimé ».

* **200 par seconde sur 4 cœurs : non.** Il faudrait 20 ms de calcul par remise ; le plancher sans
  validation est à 25,5 ms. Il faudrait retirer du travail à l'inscription elle-même (gardes,
  compteurs, événement), ce que ce plan ne propose pas.
* **300 par seconde sur 4 cœurs : non** (13 ms par remise).
* **Avec plus de cœurs** : le serveur suit le nombre de connexions jusqu'à 4 cœurs (mesuré).
  Au-delà, c'est une extrapolation : 8 cœurs réservés à la base donneraient 230 à 250 remises par
  seconde après les sous-lots 1 à 3 (**estimé, non vérifié**).
* **Latence** : à saturation (50 clients pour 90 remises par seconde), p50 400 ms, p95 1,1 à
  1,3 s. L'objectif « p95 ≤ 100 ms » ne tient qu'en dessous de la saturation (une remise seule :
  37 à 39 ms).

Toutes ces mesures sont faites sur une base en mémoire : §10.

## 5. Sous-lots

Indépendants, ordonnés par gain sur effort. Chacun est une demande de fusion.

### 5.0. Sous-lot 0 — banc de mesure versé au dépôt

* `scripts/bench/delivery/` : le banc SurrealQL de cette étude (chaque appel dans sa transaction,
  premier et deuxième appel, montée en clients), sur le modèle de
  `scripts/bench/core/bench_core_engine.py`.
* `crates/lyxal_mail/tests/it/measures.rs` et `support.rs` : taille du pool par
  `LYXAL_SURREAL_CONNECTIONS=<nombre>` (remplace la valeur `services`), une fois le sous-lot 2
  fusionné.
* Recette : le banc redonne, à 10 % près, les chiffres du §1.2 et du §1.3 sur `main`.

### 5.1. Sous-lot 1 — contrôles par fermetures sur les chemins chauds (P1, P2)

Gain mesuré : 90,7 → 38,7 ms par remise ; 45 → 124 remises par seconde côté base.

* `lyxal_core` : `fn::validation_fields_execute` (`functions/validations/functions/`), son test
  (`tests/fields_execute.test.surql`), `Readme.md`. Contrat : `$fields` =
  `{ <champ>: { checks: [fermetures], required, nullable, default } }` ; `$unknown_keys` =
  `reject`, `strip` ou `keep` ; rapport identique à celui de `fn::validation_object_execute`
  (`errors` avec `path`, `rule`, `code`, `details`). Erreurs de programmation par `THROW`
  (`CORE_INVALID_ARGUMENT`, `CORE_UNSUPPORTED_OPTION`), comme le moteur.
* Neuf fonctions migrées (contrat public inchangé, mêmes codes d'erreur) : les huit du prototype
  (`fn::mail_delivery_begin`, `fn::mail_delivery_commit`, `fn::storage_object_begin`,
  `fn::storage_object_commit`, `fn::storage_object_get`, `fn::storage_bucket_get`,
  `fn::secrets_tenant_key_ring`, `fn::event_publish`) et `fn::mail_recipient_resolve`, appelée à
  chaque `RCPT TO` (non prototypée ; son nettoyage par `fn::sanitize_object_execute`, 3,2 ms au
  premier appel et 1,1 ms ensuite, est gardé). `fn::storage_object_open` en profite sans
  changer. `fn::mail_reception_rule` devient une règle à fermetures.
* `.agents/AGENTS.md` §5.7.8 et checklist §13 : `fn::validation_fields_execute` ajoutée aux formes
  permises du moteur unique.
* Tests : `scripts/ci/test_lyxal_core.py` (cas valides, chaque code d'erreur, valeur par défaut,
  `NULL`, clés inconnues dans les trois modes, valeur qui n'est pas un objet) ; les tests
  SurrealQL existants de `lyxal_mail`, `lyxal_storage`, `lyxal_secrets` et `lyxal_event` passent
  sans changement d'attendu ; `cargo test` du workspace.
* Recette : banc du sous-lot 0, total base ≤ 40 ms ; banc Rust, une remise seule ≤ 42 ms ;
  `FileKeys::seal` ≤ 4 ms.

### 5.2. Sous-lot 2 — pool de connexions (P5)

Gain mesuré : débit multiplié par 2 (10,7 → 20,5 ; 24,6 → 48,5 avec le sous-lot 1).

* `lyxal_surreal` : `SurrealPool` (N clients `Surreal<Any>` ouverts et authentifiés par
  `create_surreal_client`, distribution à tour de rôle) ; aucune logique métier. Pour `mem://` :
  un seul client (le moteur embarqué n'a pas de connexion).
* `lyxal_host` : `[database] connections` (défaut : le nombre de cœurs, 16 au plus) ;
  `connect_database` rend le pool ; santé `/ready` vraie si une connexion au moins répond.
* Stores : le pool n'est remis qu'aux stores de la **session système** de l'hôte. Les stores d'une
  session d'utilisateur (`authenticate`) gardent leur client.
* Tests : pool de 1 égal au comportement actuel ; pool de N : appels répartis, une connexion
  coupée ne fait échouer que ses appels en cours ; essai des deux nœuds
  (`measures_two_nodes_one_account`) rejoué sur serveur avec pool.
* Recette : banc Rust, fonctions de `main`, pool de 8 : ≥ 18 remises par seconde.

### 5.3. Sous-lot 3 — compteurs de volume sans conflit, retrait de `WriteTurns` (P3)

Gain mesuré (avec 1 et 2) : 48,5 → 85–91 remises par seconde dans une organisation.

* `lyxal_storage` : `storage_usage` selon la décision P3 (compteurs répartis, ou journal et
  consolidation) ; `fn::storage_usage_apply`, `fn::storage_scope_usage`,
  `fn::storage_usage_verify`, `fn::storage_object_usage`, `fn::storage_bucket_get` adaptées ;
  `migrations/0001_initial.surql` réécrite en place (§0).
* `lyxal_mail` : `WriteTurns` supprimé (`delivery.rs`, `ingest.rs`), README mis à jour.
* Tests : compteurs égaux aux fiches après 1 000 écritures simultanées
  (`fn::storage_usage_verify`) ; quota refusé au dépassement ; suppression d'un bucket et d'une
  organisation ; essai des remises concurrentes sans `WriteTurns`, aucune refusée.
* Recette : banc Rust, 100 comptes d'une organisation, 50 clients, pool de 8 : ≥ 80 remises par
  seconde, 0 refusée.

### 5.4. Sous-lot 4 — inscription allégée (P4, P6)

Gain mesuré : 89,4 → 93,9 remises par seconde ; 38,9 → 16,5 ms par message pour un lot de 8 à
grande enveloppe.

* `lyxal_core` : `fn::validation_checks_report` et son test.
* `lyxal_mail` : éléments de `fn::mail_delivery_commit` contrôlés par appels directs des
  primitives (`fn::mail_delivery_item_check`, interne).
* `lyxal_storage` : `fn::storage_object_get` rend `bucket_summary`
  (`{ name, tenant, encrypted }`) sur demande (`with_bucket: true`) ; `fn::mail_delivery_item` ne
  fait plus qu'un appel.
* `lyxal_event` : `fn::event_fanout` n'écrit plus deux fois la fiche de l'outbox quand elle est
  appelée par `fn::event_publish` (gain **estimé** : 0,3 à 0,6 ms par événement).
* Recette : `fn::mail_delivery_commit` ≤ 12 ms par message dans un lot de 32 ; ≤ 18 ms par message
  dans un lot de 8 à 150 destinataires.

### 5.5. Sous-lot 5 — moins d'allers-retours (P7, P8)

Gain mesuré dans la base : 34,5 → 31,1 ms (10 %). Gain de débit **estimé** : 5 à 10 %.

* `fn::mail_delivery_open` (ouverture du courrier et du fichier, une transaction) et clôture
  groupée dans `fn::mail_delivery_commit` ; `StorageService` offre l'écriture d'un fichier déjà
  ouvert et sans clôture.
* Trousseau : rendu par l'ouverture, ou scellement depuis le cache (P7).
* À faire en dernier, et seulement si la mesure sur une base persistante (§10) le justifie.

### 5.6. Hors de ce plan

* Les 515 autres appels de `fn::validation_object_execute` (décision P2).
* Les gardes `fn::mail_write_refusal` (139 lignes) et `fn::mail_counters_apply` (106 lignes),
  une fonction pour toutes les tables : gain d'un découpage par table non mesuré.
* Signalement à SurrealDB des causes C1 (décision P9).

## 6. Contrats publics touchés

| Contrat | Changement | Sous-lot |
| :--- | :--- | :-: |
| `fn::validation_fields_execute`, `fn::validation_checks_report` (`lyxal_core`) | Nouvelles | 1, 4 |
| `fn::validation_object_execute`, catalogues, `fn::utils_engine_*` | Aucun | — |
| Neuf fonctions publiques migrées (§5.1) | Aucun : mêmes paramètres, mêmes résultats, mêmes codes | 1 |
| `lyxal_surreal::SurrealPool` ; `lyxal_host::Database`, `[database] connections` | Nouveaux | 2 |
| Table `storage_usage` | Forme des lignes changée (P3) ; aucune écriture directe aujourd'hui | 3 |
| `fn::storage_bucket_get` | `usage` inchangé dans le résultat ; lu autrement | 3 |
| Quota de `lyxal_storage` | Contrôlé sur l'instantané de la transaction : deux écritures simultanées peuvent le dépasser ensemble (P3) | 3 |
| `fn::storage_object_get` | Paramètre `with_bucket`, champ `bucket_summary` | 4 |
| `fn::mail_delivery_open` ; `StorageService` | Nouveaux (sous-lot 5 seulement) | 5 |
| `FileKeys::seal`, `fn::secrets_tenant_key_destroy` | Selon P7 | 5 |

Toute rupture est répercutée sur les appelants du dépôt dans le même changement (§0.3).

## 7. Décisions à faire valider par le CTO

| N° | Décision | Proposition |
| :-: | :--- | :--- |
| **P1** | Ajouter à `lyxal_core` un exécuteur d'objet à fermetures (`fn::validation_fields_execute`, nom à valider) et l'inscrire au §5.7.8 comme forme du moteur unique | Oui. Seule correction mesurée qui retire C1 en gardant défauts, champs exigés, clés inconnues et rapport dans le Core. Autre choix : primitives appelées directement dans chaque fonction chaude, comme `fn::event_fanout` |
| **P2** | Périmètre de la migration | Les neuf fonctions du chemin de remise dans ce plan. Les 515 autres appels dans un plan à part, lectures publiques d'abord (8 à 12 ms chacune aujourd'hui) |
| **P3** | Forme des compteurs `storage_usage` et quota | (a) compteurs répartis sur 64 lignes : lecture bornée, pas de tâche, 3 % de conflits rejoués. Autre choix : (b) journal et consolidation, aucun conflit, une tâche de plus, quota plus cher. Dans les deux cas, accepter qu'un quota soit dépassé de la taille des écritures simultanées |
| **P4** | Ajouter `fn::validation_checks_report` et permettre, dans les fonctions réservées au worker, l'appel direct des primitives sans exécuteur | Oui, pour `fn::mail_delivery_commit` seulement dans ce plan |
| **P5** | Pool de connexions dans `lyxal_surreal`, réglé par `[database] connections`, pour la session système seulement | Oui ; défaut : nombre de cœurs, 16 au plus |
| **P6** | `fn::storage_object_get` rend un résumé du bucket sur demande | Oui |
| **P7** | Sceller une clé de fichier depuis le cache des clés « fichiers ». Exige d'interdire la destruction d'une clé retirée depuis moins que la durée de garde du cache (60 s) plus une marge | Reporter. Après le sous-lot 1 le gain n'est plus que de 2,5 ms par remise (13,6 ms avant) |
| **P8** | Ouverture et clôture groupées (sous-lot 5) | Reporter après la mesure sur base persistante |
| **P9** | Signaler à SurrealDB : définitions de fonctions réanalysées à chaque transaction, graphe d'appels parcouru à chaque appel d'une fonction de lecture | Oui ; suivi dans `docs/14-roadmap/SURREALDB_4.md` |
| **P10** | Objectif de débit du lot 5 (§10.5) | Remplacer « 300 (embarquée), 200 (serveur) » par : ≥ 80 remises par seconde sur 4 cœurs partagés, ≥ 110 sur 4 cœurs réservés à la base, 0 refusée ; une remise seule ≤ 42 ms |
| **P11** | `MAX_BATCH` (32) | Garder 32 après le sous-lot 4 (10,8 ms par message). Sans le sous-lot 4, descendre à 16 (16,4 ms par message à 32) |

## 8. Tests et mesures de recette

Par sous-lot : §5. Pour tous :

* `scripts/ci/test_lyxal_core.py`, `scripts/ci/test_lyxal_modules.py`, `cargo test` du workspace,
  `scripts/ci/clippy.sh`, `scripts/ci/check_crypto_dependencies.py`,
  `scripts/ci/check_agpl_isolation.py` ;
* bancs du sous-lot 0 avant et après, chiffres reportés dans le README de `lyxal_mail`
  (« Mesures ») à la place de ceux du lot 5c ;
* cohérence en fin de banc : compteurs du compte égaux aux messages, UID uniques, une fiche de la
  vue par date par message, `fn::storage_usage_verify` sans écart.

## 9. Risques

* **Dépendance au comportement de SurrealDB 3.3.** C1 à C3 tiennent à cette version. Une version
  qui garderait les définitions entre transactions réduirait le gain du sous-lot 1 sans le rendre
  nuisible. Bancs à rejouer à chaque changement de version.
* **Fermetures et lots.** L'exécuteur à fermetures recopie ses variables à chaque contrôle : coût
  qui monte avec la taille du lot et de l'enveloppe (§2.3). À ne pas employer pour les éléments
  d'un lot (sous-lot 4).
* **Prototypes simplifiés.** Chemins d'erreur imbriqués (`items[0].content`), `details`,
  `nullable` et avertissements du rapport ne sont pas au niveau du moteur actuel dans le
  prototype. Les suites de tests n'ont pas été rejouées dessus : seuls les bancs l'ont été.
* **Pool.** Rien ne doit dépendre de l'ordre d'exécution d'une connexion unique. Avec un pool, les
  conflits entre transactions d'un même nœud deviennent possibles ; mesuré : 0 conflit rejoué sur
  les inscriptions, 0 à 1 remise refusée sur 3 000.
* **Quota approché** (P3) : dépassement borné par les écritures en cours.
* **Deux exécuteurs dans le Core.** Deux façons de valider un objet tant que la migration n'est
  pas finie (P2).

## 10. Ce qui n'a pas pu être vérifié

* **Base persistante.** Toutes les mesures sont faites sur `surreal start memory`. Le coût d'une
  validation de transaction sur disque (cinq par remise) n'est pas mesuré ; il pèserait en faveur
  du sous-lot 5.
* **Base et hôte sur deux machines.** Les deux tournaient sur les mêmes 4 cœurs. « 4 cœurs
  réservés à la base » vient du banc SurrealQL, sans écriture de fichier ni chiffrement.
* **Plus de 4 cœurs** : extrapolation.
* **Profil du serveur 3.3.4** : binaire sans symboles. Le profil par relevés de pile a été fait
  sur le moteur embarqué 3.3.5 du binaire d'essai, et le code lu est celui de 3.3.5 ; les effets
  sont confirmés sur le serveur 3.3.4 par les mesures du §2.1.
* **Base embarquée (`mem://`)** : débits non refaits (profil seulement).
* **Deux nœuds** avec pool, **support S3**, **session SMTP** et contrôles d'authenticité (5d) :
  non mesurés.
* **Messages réels** : messages d'essai de 10 Kio, structure MIME vide dans le banc SurrealQL ;
  seule la taille de l'enveloppe a été variée.
* **Journal de variations** (P3 b) : consolidation non prototypée.
* **Refus isolé** `SURREAL_DATABASE_ERROR` (une remise sur 3 000, pool de 4) : cause non cherchée.
* **Sous-lot 5 et retouche de `fn::event_fanout`** : gains de débit estimés, non mesurés au banc
  Rust.

## Checklist (`.agents/rules/lyxal_standards_and_checklist.md` §13)

* [x] Responsabilités : validation générique dans `lyxal_core`, compteurs dans `lyxal_storage`,
  transport dans `lyxal_surreal`, configuration dans `lyxal_host`.
* [x] `lyxal_core` vérifié (`validations`, `sanitize`, `security`, `utils`) ; aucune primitive
  dupliquée ; deux extensions du Core signalées (P1, P4).
* [x] Aucune dépendance circulaire nouvelle ; aucun module métier ne référence un consommateur.
* [x] Contrats publics touchés listés (§6) ; ruptures répercutées dans le même changement.
* [x] Aucune primitive cryptographique nouvelle ; P7 ne change que la règle d'usage d'un cache.
* [x] Zéro dette : `WriteTurns` supprimé avec sa cause ; `0001_initial.surql` réécrite en place.
* [ ] Validation explicite du CTO (P1 à P11) : **attendue**.
