# Banc « boîte aux lettres » sur SurrealDB

Banc du lot 0 du programme courrier, agendas et contacts (décision C5). Il mesure si
SurrealDB 3.3.4 tient les accès d'un magasin de courrier modélisé en tables (voie B de la
décision P4) pour une boîte de 100 000 puis 1 000 000 de messages. Résultats, machine, requêtes
et conclusion : [`crates/lyxal_mail/RECHERCHE_SOURCES.md`](../../../crates/lyxal_mail/RECHERCHE_SOURCES.md),
section « Mesures SurrealDB ».

Hors workspace et **hors CI** : le banc dure de une minute (100 000 messages) à plusieurs
dizaines de minutes (1 000 000), et ses chiffres dépendent de la machine.

## Fichiers

| Fichier | Rôle |
| :--- | :--- |
| `schema.surql` | Schéma d'essai : compte, dossiers (compteurs), messages (métadonnées, drapeaux, UID, numéro de modification), index d'un magasin de courrier |
| `schema_fulltext.surql` | Analyseur et index plein texte (sujet, nom de l'expéditeur), installés après les mesures de base |
| `bench_mailbox.py` | Démarre un serveur jetable, charge la boîte, mesure, garde les plans `EXPLAIN`, arrête le serveur |

Les tables `bench_*` n'appartiennent à aucun module et ne sont installées par aucun manifeste.

## Lancement

```bash
# En mémoire, 100 000 messages
python3 -I scripts/bench/mailbox/bench_mailbox.py --messages 100000 --engine memory --out /tmp/memory_100000.json

# Sur disque (rocksdb ou surrealkv), 1 000 000 de messages ; le dossier de données doit être vide ou absent
python3 -I scripts/bench/mailbox/bench_mailbox.py --messages 1000000 --engine rocksdb \
    --data-dir /chemin/vers/un/dossier/vide --out /tmp/rocksdb_1000000.json
```

Binaire : `${LYXAL_SURREAL_BIN:-surreal}` (version de référence du workspace : 3.3.4,
`scripts/ci/install_surreal.sh`). Options : `--repeat` (répétitions par mesure, 30 par défaut),
`--delivery` (messages de l'essai de remise un par un), `--no-fulltext`, `--keep` (garde le
dossier de données). Prévoir environ 3 Go de disque libre pour 1 000 000 de messages sur disque,
et 8 Go de mémoire pour le moteur en mémoire.

## Ce qui est mesuré

Chaque mesure est répétée ; le banc donne la médiane et le 95e centile du temps vu par le client
(envoi, exécution, lecture de la réponse, sur une connexion gardée ouverte et une session déjà
authentifiée) et le temps d'exécution annoncé par le serveur.

* page de 50 messages d'un dossier triée par date décroissante : première page, page profonde
  par décalage `START`, page profonde par curseur de date ;
* changements depuis un numéro de modification (synchronisation) ;
* changement du drapeau « lu » dans une transaction (numéro de modification du dossier, compteur
  de non-lus, message) ;
* compte des non-lus : un dossier, tous les dossiers (`GROUP BY`, une requête par dossier,
  compteur tenu à l'écriture) ;
* recherche sur l'expéditeur (index) et sur le sujet (parcours, puis index plein texte) ;
* débit d'insertion : chargement par lots de 1 000, puis remise message par message dans une
  transaction (un client, puis quatre clients sur quatre dossiers).

Seuils de la décision C5, à 1 000 000 de messages : page et synchronisation en moins de 100 ms,
changement de drapeau en moins de 20 ms, insertion d'au moins 300 messages par seconde. Le banc
compare le 95e centile côté client à ces seuils ; il ne change aucun réglage pour les tenir.

Pour un moteur sur disque, le serveur est redémarré entre le chargement et les mesures : les
lectures viennent des fichiers du moteur, pas de ses tampons d'écriture (le cache de fichiers du
système reste chaud).
