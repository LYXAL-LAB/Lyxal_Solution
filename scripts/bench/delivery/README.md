# Banc SurrealQL de la remise d'un message

Banc du plan de performance de la remise du courrier
(`docs/14-roadmap/implementation_plan_performance.md`, sous-lot 0). Il mesure le temps de calcul
de la base pour une remise, sans écriture de fichier ni chiffrement ; la remise entière
(`MailIngest::receive`) est mesurée par le banc Rust `crates/lyxal_mail/tests/it/measures.rs`.

Hors CI : les chiffres dépendent de la machine et de sa charge. À rejouer avant et après tout
changement du chemin de remise, et à chaque changement de version de SurrealDB.

## Lancement

```bash
# Les trois mesures sur la copie de travail (environ 3 minutes)
python3 -I scripts/bench/delivery/bench_delivery.py --out /tmp/apres.json

# Les mêmes sur une autre révision (mesure « avant »)
python3 -I scripts/bench/delivery/bench_delivery.py --ref <révision> --out /tmp/avant.json

# Une partie seulement
python3 -I scripts/bench/delivery/bench_delivery.py --only remise,appels --deliveries 300
```

Binaire : `${LYXAL_SURREAL_BIN:-surreal}` (version de référence du workspace : 3.3.4,
`scripts/ci/install_surreal.sh`). Le banc démarre un serveur jetable en mémoire, y installe
`lyxal_mail` et ses dépendances depuis leurs manifestes (comme
`scripts/ci/test_lyxal_modules.py`), mesure, puis arrête le serveur. Options : `--deliveries`,
`--repeat`, `--warmup`, `--clients` (paliers), `--seconds` (durée d'un palier), `--quota` (quota
de volume posé sur chaque organisation de la mesure `clients`, en octets : le quota est alors lu à
chaque écriture de fichier), `--timeout`.

## Ce qui est mesuré

Les durées sont relevées **dans le serveur** (`time::now()` avant et après chaque appel). Chaque
instruction d'une requête HTTP `/sql` est sa propre transaction, comme un appel de `call_fn`.

| Mesure (`--only`) | Contenu |
| :--- | :--- |
| `remise` | Une remise de 10 Kio, poste par poste, chaque appel dans sa transaction : `fn::mail_delivery_begin`, `fn::storage_object_begin`, `fn::secrets_tenant_key_ring` (lu par `FileKeys::seal`), `fn::storage_object_commit`, `fn::mail_delivery_commit` (un message). Moyenne et médiane, et total des moyennes (« total base ») |
| `appels` | Premier et deuxième appel d'une même expression dans une transaction : le premier paie la lecture et l'analyse des définitions de fonctions (refaites à chaque transaction en SurrealDB 3.3), le deuxième non. Validateur seul, moteur par nom de règle, exécuteur à fermetures, lectures publiques, publication d'un événement. Médianes |
| `clients` | Débit pendant 12 s avec 1, 2, 4, 8 et 16 clients, une connexion HTTP chacun (jeton de la session système) : un client par organisation, puis tous dans la même organisation (un compte chacun). Remises refusées comptées par cause : le banc ne rejoue pas un conflit de transaction, alors que `lyxal_storage` (lignes de compteurs `storage_usage` tirées au sort parmi 64) et le service de remise les rejouent |

En fin de mesure `clients`, le banc contrôle la cohérence : compteurs des comptes égaux aux
messages inscrits, UID uniques dans chaque dossier, compteurs de volume de chaque organisation
égaux aux fiches (`fn::storage_usage_verify`).

## Limites

* Base en mémoire, client et serveur sur la même machine : le débit de `clients` plafonne au
  nombre de cœurs, partagés avec le banc.
* Messages d'essai : enveloppe de 4 adresses, structure MIME vide, clé de fichier factice.
* Une machine occupée par autre chose (compilation, autres essais) fausse surtout `clients`.
