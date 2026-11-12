# Plan d'implémentation — `lyxal_storage`, lot 8 : clôture

Dernier lot du programme `lyxal_storage` (`implementation_plan.md` à la racine). Il rend compte de
l'audit de conformité du module (skill `lyxal-audit`, lecture seule), propose les corrections
qui en découlent et la mise à jour finale des documents. Aucune modification avant la validation
du CTO (`.agents/AGENTS.md` §3).

## 1. Audit de conformité (12 novembre 2026)

Périmètre : `crates/lyxal_storage` et ses routes dans `apps/lyxal-server`.

| Contrôle | Résultat | Preuve |
| :--- | :--- | :--- |
| 1. Structure et manifeste | conforme | les 19 fichiers `.surql` du module (hors tests) sont exactement ceux de `manifest.toml` ; dépendances du manifeste et du descripteur Rust identiques (`lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`) ; aucune dépendance circulaire |
| 2. Place dans le graphe | conforme | service du noyau : dépend de `lyxal_surreal`, `lyxal_runtime`, `lyxal_crypto` ; seul consommateur : `lyxal_pipeline_ingestion` (module métier) et l'hôte |
| 3. SurrealQL | conforme, une remarque (A1) | 37 fonctions, toutes `($params: object)` pour les publiques, `fn::result_ok` / `fn::error_result`, `COMMENT` présent, aucune au-delà de 300 lignes ; aucune occurrence de `result_error` ; 5 tables `SCHEMAFULL` avec `PERMISSIONS` et `COMMENT` (52 champs commentés) ; événements par `fn::event_publish` avec `THROW` ; seeds en `IF !record::exists` ; entrées validées par `fn::validation_object_execute` ; les 29 codes `STORAGE_*` émis ont leur définition et aucune définition n'est orpheline |
| 4. DTO Rust et SurrealQL | conforme | 26 appels du store comparés champ par champ à leur fonction : aucun écart |
| 5. SurrealDB 3.3.4 | conforme | aucune construction héritée de la 2.x ; `surreal validate` et le banc passent contre un serveur 3.3.4 réel (CI du lot 7) |
| 6. Rust | conforme | store sur `Surreal<Any>` et `call_fn` ; aucun `panic!`, `unwrap`, `expect` hors tests ; aucun `raw_query` ; aucun `tokio::spawn` ; worker `LyxalWorker` coopératif ; sonde `ModuleHealthCheck` ; 138 éléments publics, documentation sans avertissement |
| 7. Cryptographie | conforme | empreinte par `lyxal_crypto` (`Blake3Hasher`) ; aucune crate crypto importée ; identifiants S3 en `SecretString` |
| 7 bis. Zéro dette | conforme après ce lot (A3) | version `0.1.0` ; pas de code mort ; reste un document de recherche à réduire et le plan de programme à retirer |
| 8. Tests | conforme, limites connues (A2) | banc SurrealQL 128 assertions ; tests Rust sur mémoire, disque et S3 de test ; routes de bout en bout ; `scripts/ci/ci_local.sh` vert ; **essai réel sur Bunny Storage réussi le 12 novembre 2026** (`real_s3_service_stores_serves_and_cleans`, variables `LYXAL_TEST_S3_*`) |

Aucun écart P0 ni P1 dans le module.

### Écarts relevés (P2)

| N° | Constat | Proposition |
| :- | :--- | :--- |
| **A1** | `fn::storage_object_open` transmet la langue reçue à `fn::error_result` sans passer par la validation (les autres fonctions la valident) | **Corriger** : la langue est lue comme dans les autres fonctions |
| **A2** | Quatre cas ne sont couverts par aucun test automatique : refus au-delà de 10 000 parties d'un envoi reprenable ; panne de la base pendant l'inscription d'une partie ; antivirus ClamAV réel (seul un faux service est testé) ; mémoire utilisée sur un gros fichier | **Documenter** dans le `README.md` (déjà fait pour trois d'entre eux) ; essai ClamAV réel à lancer à la main avant la mise en production |
| **A3** | `RECHERCHE_SOURCES.md` est un document de recherche de 156 lignes ; le plan de programme à la racine est exécuté | **Réduire** le premier en `MODELE_SOURCES.md` (ce qui a été repris, de quelle source, sous quelle licence) ; **supprimer** le second (§0.3) |
| **A4** | Montée en charge : quand un quota est réglé, le volume d'une portée est recalculé en relisant toutes ses fiches à chaque écriture ; les listes sont paginées après lecture complète ; la liste des envois à assembler recalcule la position de chaque envoi | Voir la décision N1 |

### Constat hors module, relevé pendant ce programme

| N° | Constat | Proposition |
| :- | :--- | :--- |
| **A5** | Le contrôle « SurrealQL » de la CI échoue par moments avant tout test : le serveur SurrealDB de test « n'a pas démarré en 30 s » (`scripts/ci/test_lyxal_core.py`). Vu deux fois le 12 novembre 2026 sur GitHub (dont une fois sur une demande ne contenant qu'un document) et plusieurs fois sur la machine de développement. La cause n'est pas connue : le script jette la sortie d'erreur du serveur, et il choisit un port libre puis le relâche avant que le serveur ne le prenne | **Rendre la cause visible et le démarrage robuste** : en cas d'échec, afficher le code de sortie et la sortie d'erreur du serveur ; si le serveur s'est arrêté (port pris entre-temps), redémarrer sur un autre port, trois essais au plus. Aucun test n'est sauté ni relancé |

## 2. Décisions demandées au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **N1** | Traite-t-on maintenant la montée en charge (A4) ? | **Non, à la feuille de route**, avec le seuil écrit noir sur blanc : le module convient jusqu'à quelques dizaines de milliers de fichiers par organisation ; au-delà, il faudra tenir des compteurs à jour au lieu de recompter. Le faire maintenant ajouterait une table et des événements sans besoin constaté. Sans quota réglé, les écritures ne recomptent rien |
| **N2** | Déclare-t-on la V1 de `lyxal_storage` terminée ? | **Oui.** Les sept lots sont fusionnés, l'audit ne relève aucun écart bloquant, l'essai réel Bunny est passé. La version reste `0.1.0` (régime pré-production, §0.3) |

## 3. Changements

| Fichier | Changement |
| :--- | :--- |
| `functions/storage_object.surql` | A1 : langue validée dans `fn::storage_object_open` ; test du banc |
| `README.md` | état final ; limites de vérification (A2) ; seuil de montée en charge (A4) ; essai réel Bunny réussi |
| `ROADMAP.md` | plus de lots ; évolutions à venir seules, dont les compteurs de volume (N1) |
| `RECHERCHE_SOURCES.md` → `MODELE_SOURCES.md` | réduit aux sources reprises et à leurs licences (A3) |
| `implementation_plan.md` (racine) | supprimé : programme exécuté (A3) |
| `scripts/ci/test_lyxal_core.py` (classe `SurrealServer`, partagée par les bancs) | A5 : sortie d'erreur du serveur gardée et affichée en cas d'échec ; redémarrage sur un autre port si le serveur s'est arrêté, trois essais au plus |
| `.agents/AGENTS.md` §6, `docs/14-roadmap/ROADMAP_NOYAU.md` | `lyxal_storage` livré ; prochain service du noyau selon l'ordre de la feuille de route |

Aucune fonction Core nouvelle, aucun besoin cryptographique, aucun changement de contrat public.
Ce plan est supprimé dans la demande de fusion de l'implémentation.
