# Architecture de lyxal-server

## Position

```mermaid
flowchart TD
    Client --> HTTP[lyxal-server / Axum]
    HTTP --> Runtime[Runtime de modules]
    Runtime --> Core[Contrats communs]
    Runtime --> TZ[Timezone]
    Runtime --> Scheduler
    Runtime --> Calendar
    Runtime --> Booking
    Runtime --> DB[(SurrealDB)]
```

## Principe

Le serveur orchestre. Les modules possèdent leur logique, leurs routes, leurs
migrations et leurs workers.

## Démarrage

```mermaid
sequenceDiagram
    participant Main
    participant Config
    participant DB as SurrealDB
    participant Runtime
    participant HTTP

    Main->>Config: charger et valider
    Main->>DB: connecter, authentifier, sélectionner NS/DB
    Main->>Runtime: construire le graphe
    Runtime->>Runtime: valider les dépendances
    Runtime->>DB: appliquer les migrations
    Runtime->>Runtime: démarrer les modules
    Main->>HTTP: assembler les routes
    HTTP-->>Main: prêt
```

## Arrêt

Les modules sont arrêtés dans l'ordre inverse de leur démarrage. Chaque arrêt
possède un délai maximal. Un échec est journalisé et reflété dans le registre
de santé.
