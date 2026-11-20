# Campagnes de couverture

Depuis le crate : `python3 tools/run_fuzz.py --seconds 1800 --segments 3 --toolchain nightly-2026-10-20`.
En CI : workflow « Fuzzing lyxal_crypto » (`scripts/ci/crypto_fuzz.sh`), 60 s par cible sur toute PR
qui modifie le crate, 600 s par cible chaque lundi et à la demande.
Prérequis : Linux x86_64, Rust `nightly-2026-10-20`, `cargo-fuzz` 0.13.2 (épinglés dans `scripts/ci/crypto_fuzz.sh`).
Le conducteur compile les six cibles, conserve les seeds et le corpus généré,
puis lance les six campagnes en parallèle. Chaque cible exécute par défaut trois
sessions de dix minutes, avec conservation du corpus et enregistrement immédiat du résultat
de chaque session. Les trente minutes sont cumulées ; il ne s’agit pas d’une session
continue. `--segments 1` demande une seule session continue de trente minutes. Logs, commandes, empreintes des binaires,
horodatages et vrais codes de sortie figurent dans `fuzz/target/campaigns/`.
Les grands corpus, exécutables et artefacts restent ignorés par Git.

`envelope` et `context` acceptent jusqu'à 1 500 000 bytes ; `stream_open` jusqu'à 300 000
(plusieurs segments de 64 Kio) ; `phc`, `rotation` et `tls_pem` jusqu'à 8192. Le parseur PHC ne
lance pas Argon2 à chaque entrée de fuzz.
`stream_open` lit l'entrée comme un fichier chiffré hostile (format de flux v1), puis la chiffre,
l'altère (bit, troncature, ajout) selon ses premiers octets et exige l'échec de la lecture.
`tls_pem` découpe l'entrée en chaîne et clé (séparateur 0x00) et essaie aussi la suite comme nom
de serveur contre un certificat de test valide.
Le modèle rotation vérifie les états et migrations avec des clés fictives.
Les seeds versionnés incluent une enveloppe littérale, des profils PHC valides/excessifs, le
vecteur S1 du format de flux et une chaîne et une clé de test TLS.

Les binaires instrumentés exigent un contexte permettant à LeakSanitizer de terminer.
Une erreur du sanitizer liée à l'environnement est un échec de campagne ; ne pas la
convertir en succès ou désactiver le contrôle pour faire passer le résultat.
Chaque campagne écrit ses journaux, commandes et codes de sortie dans `fuzz/target/campaigns/` (non versionné).
