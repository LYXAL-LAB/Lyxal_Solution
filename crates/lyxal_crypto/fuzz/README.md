# Campagnes de couverture

Depuis le crate : `python3 tools/run_fuzz.py --seconds 1800 --segments 3`.
Prérequis : Linux x86_64, Rust nightly, cargo-fuzz et dépendances accessibles/cache préparé.
Le conducteur compile les quatre cibles, conserve les seeds et le corpus généré,
puis lance les quatre campagnes en parallèle. Chaque cible exécute par défaut trois
sessions de dix minutes, avec conservation du corpus et enregistrement immédiat du résultat
de chaque session. Les trente minutes sont cumulées ; il ne s’agit pas d’une session
continue. `--segments 1` demande une seule session continue de trente minutes. Logs, commandes, empreintes des binaires,
horodatages et vrais codes de sortie figurent dans `fuzz/target/campaigns/`.
Les grands corpus, exécutables et artefacts restent ignorés par Git.

`envelope` et `context` acceptent jusqu'à 1 500 000 bytes ; `phc` et `rotation`
jusqu'à 8192. Le parseur PHC ne lance pas Argon2 à chaque entrée de fuzz.
Le modèle rotation vérifie les états et migrations avec des clés fictives.
Les seeds versionnés incluent une enveloppe littérale et des profils PHC valides/excessifs.

Les binaires instrumentés exigent un contexte permettant à LeakSanitizer de terminer.
Une erreur du sanitizer liée à l'environnement est un échec de campagne ; ne pas la
convertir en succès ou désactiver le contrôle pour faire passer le résultat.
Le bilan réellement exécuté est dans `../IMPLEMENTATION_REPORT.md` et `../validation/`.
