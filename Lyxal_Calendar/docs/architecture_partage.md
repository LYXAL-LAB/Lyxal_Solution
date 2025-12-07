# Réflexion d'Architecture : Partage Contextuel de Calendriers

Ce document a pour but d'explorer les différentes manières de modéliser le partage de calendriers dans un contexte multi-workspace, où un utilisateur peut accéder à des calendriers partagés différemment selon qu'il se trouve dans son espace personnel ou dans un espace d'entreprise.

## Contexte

L'objectif est de permettre des scénarios de partage avancés :
1.  **Partage à une entreprise :** Tous les employés de "SAS Acme" voient le calendrier.
2.  **Partage à un utilisateur dans un contexte d'entreprise :** "M. Dupont" ne voit le calendrier que lorsqu'il utilise le workspace de "SAS Acme".
3.  **Partage à un utilisateur dans son contexte personnel :** "M. Martin" ne voit le calendrier que dans son workspace personnel.

## Hypothèse d'Architecture Clé

Chaque **workspace** est une **base de données ou un namespace physiquement séparé** dans SurrealDB. Cela garantit une isolation maximale des données.

## Proposition 1 : Partage par Copie/Synchronisation (Modèle le plus robuste)

Cette approche considère le "partage" comme un processus actif géré par le backend.

### Schéma `davshares`

La table `davshares`, dans la base de données du *propriétaire* du calendrier, agit comme une table de configuration.

```surql
DEFINE TABLE davshares;

-- Le calendrier source qui est partagé
DEFINE FIELD resource ON davshares TYPE record<calendars>;

-- La cible du partage
DEFINE FIELD target ON davshares TYPE object;
DEFINE FIELD target.principal_id ON davshares TYPE string; -- ID global de la cible (user:uuid ou company:uuid)
DEFINE FIELD target.destination_db ON davshares TYPE string; -- Nom de la DB/namespace cible (ex: "workspace_acme")
```

### Mécanisme de Fonctionnement

1.  L'utilisateur A (dans sa DB `db_A`) partage un calendrier avec l'utilisateur B dans le contexte du workspace `ws_acme`.
2.  Une entrée est créée dans `db_A:davshares` avec `resource: calendars:cal_A`, `target.principal_id: user_B_uuid`, `target.destination_db: ws_acme`.
3.  Un service backend détecte ce changement.
4.  Il se connecte à la base de données `ws_acme`.
5.  Il y crée un "calendrier-lien" (ou "calendrier-fantôme"). Cet enregistrement pourrait contenir des informations sur la source :
    ```json
    {
      "id": "calendars:cal_lien_123",
      "is_shared_link": true,
      "source_record": "db_A:calendars:cal_A",
      "source_owner": "user_A_uuid"
    }
    ```
6.  Quand l'utilisateur B (connecté à `ws_acme`) accède à ce calendrier-lien, le backend intercepte la requête, lit les informations `source_record`, et va chercher les vrais événements dans `db_A:calendars:cal_A` en appliquant les permissions définies.

### Avantages
-   **Sécurité et Isolation :** Respecte parfaitement l'architecture de DBs séparées.
-   **Clarté :** La table `davshares` est une configuration explicite des flux de partage.
-   **Flexibilité :** Permet de gérer des logiques complexes de permissions au niveau du backend.

### Inconvénients
-   **Complexité du Backend :** Nécessite une logique applicative significative pour gérer la synchronisation, la mise à jour des permissions et la propagation des modifications.
-   **Latence Potentielle :** La lecture des événements partagés nécessite une double lecture (lire le lien, puis lire la source), ce qui peut introduire une latence si ce n'est pas bien optimisé.

## Proposition 2 : Partage par Contexte dans un Champ (Modèle plus simple)

Cette approche ne fonctionne que si les workspaces ne sont pas des DBs physiquement séparées, mais plutôt des concepts logiques. **Elle est consignée ici pour mémoire mais est probablement incompatible avec l'hypothèse d'architecture.**

### Schéma `davshares`

```surql
DEFINE TABLE davshares;

-- Le calendrier source
DEFINE FIELD resource ON davshares TYPE record<calendars>;

-- La cible du partage
DEFINE FIELD principal_id ON davshares TYPE string; -- ID global (user:uuid ou company:uuid)

-- Le contexte de visibilité
DEFINE FIELD workspace_context ON davshares TYPE option<string>; -- ID du workspace où le partage est visible
```

### Mécanisme de Fonctionnement
-   Quand l'utilisateur B se connecte, l'application récupère son `principal_id` et son `workspace_context` actuel.
-   Elle recherche ensuite dans *toutes* les tables `davshares` de la plateforme les entrées qui correspondent à son `principal_id` ET à son `workspace_context`.

### Avantages
-   **Simple à Modéliser :** La structure de la table est très simple.

### Inconvénients
-   **Ne Respecte pas l'Isolation :** Nécessite que l'application puisse lire dans les tables `davshares` de potentiellement tous les autres utilisateurs, ce qui casse le modèle de DBs séparées.
-   **Problèmes de Performance :** Les requêtes pour trouver "les calendriers partagés avec moi" peuvent devenir très lourdes à grande échelle.

## Conclusion Provisoire

La **Proposition 1** est techniquement plus complexe à implémenter mais est la seule qui soit véritablement compatible avec une architecture multi-tenant sécurisée et isolée sur SurrealDB. C'est la voie la plus robuste pour l'avenir.
