# lyxal-server

`lyxal-server` est le binaire principal de Lyxal OS. Il assemble l'infrastructure,
le runtime de modules, les routes HTTP, les migrations, les contrôles de santé
et l'arrêt coordonné.

## Responsabilités

- charger et valider la configuration ;
- initialiser `tracing` ;
- établir la connexion SurrealDB ;
- construire le contexte partagé ;
- enregistrer les modules compilés ;
- valider leur graphe de dépendances ;
- installer, migrer, démarrer et arrêter les modules ;
- exposer les routes système et les routes des modules ;
- servir HTTP avec limitation, timeout, CORS et identifiant de requête ;
- exposer liveness, readiness, état détaillé et métriques ;
- gérer `SIGINT` et `SIGTERM`.

La logique métier ne doit jamais être implémentée directement dans ce crate.

## Démarrage

```bash
cargo run -p lyxal-server
```

Configuration :

```bash
LYXAL__SERVER__PORT=8080 \
LYXAL__DATABASE__ENDPOINT=ws://127.0.0.1:8000 \
cargo run -p lyxal-server
```

Les variables d'environnement utilisent le séparateur `__`.

## Routes système

- `GET /`
- `GET /live`
- `GET /ready`
- `GET /health`
- `GET /metrics`
- `GET /api/v1/system/info`
- `GET /api/v1/system/modules`

## Intégration des modules Lyxal

Implémenter `LyxalModule`, puis l'enregistrer dans `modules::compiled_modules`.
Lorsqu'un contrat commun définitif existe dans `lyxal-runtime`, déplacer le trait
dans ce crate commun et remplacer l'import local sans modifier l'orchestration.
