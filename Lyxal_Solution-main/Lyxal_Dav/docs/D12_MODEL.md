# D12 — Modèle de Données DAV Natif (SurrealQL)

## Objectif

D12 marque la transition d'un runtime DAV in-memory vers une extension native de SurrealDB, entièrement pilotée par le modèle de données (Tables, Events, Permissions).

## Schéma des Données

Le schéma est défini dans `crates/core/src/fnc/dav/schema.surql` et peut être appliqué via `dav::bootstrap()`.

### Collections (`dav_collection`)
Stocke les métadonnées des dossiers.

```sql
DEFINE TABLE dav_collection SCHEMAFULL;
DEFINE FIELD path ON dav_collection TYPE string ASSERT $value != '';
DEFINE FIELD parent_path ON dav_collection TYPE string;
DEFINE FIELD owner ON dav_collection TYPE string;
DEFINE FIELD created_at ON dav_collection TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dav_collection TYPE datetime DEFAULT time::now();
DEFINE FIELD sync_token ON dav_collection TYPE int DEFAULT 0;
DEFINE INDEX dav_collection_path ON dav_collection FIELDS path UNIQUE;
```

### Objets (`dav_object`)
Stocke les fichiers et leur contenu binaire.

```sql
DEFINE TABLE dav_object SCHEMAFULL;
DEFINE FIELD path ON dav_object TYPE string ASSERT $value != '';
DEFINE FIELD collection_path ON dav_object TYPE string;
DEFINE FIELD content ON dav_object TYPE bytes;
DEFINE FIELD mime_type ON dav_object TYPE string DEFAULT 'application/octet-stream';
DEFINE FIELD etag ON dav_object TYPE string;
DEFINE FIELD created_at ON dav_object TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dav_object TYPE datetime DEFAULT time::now();
DEFINE INDEX dav_object_path ON dav_object FIELDS path UNIQUE;
```

### Propriétés (`dav_prop`)
Stocke les propriétés WebDAV arbitraires (Dead Properties).

```sql
DEFINE TABLE dav_prop SCHEMAFULL;
DEFINE FIELD resource_path ON dav_prop TYPE string;
DEFINE FIELD name ON dav_prop TYPE string;
DEFINE FIELD namespace ON dav_prop TYPE string;
DEFINE FIELD value ON dav_prop TYPE string;
DEFINE INDEX dav_prop_key ON dav_prop FIELDS resource_path, namespace, name UNIQUE;
```

### Verrous (`dav_lock`)
Gère le verrouillage exclusif ou partagé.

```sql
DEFINE TABLE dav_lock SCHEMAFULL;
DEFINE FIELD path ON dav_lock TYPE string;
DEFINE FIELD token ON dav_lock TYPE string;
DEFINE FIELD owner ON dav_lock TYPE string;
DEFINE FIELD type ON dav_lock TYPE string;
DEFINE FIELD scope ON dav_lock TYPE string;
DEFINE FIELD depth ON dav_lock TYPE string;
DEFINE FIELD timeout ON dav_lock TYPE int;
DEFINE FIELD created_at ON dav_lock TYPE datetime DEFAULT time::now();
DEFINE INDEX dav_lock_token ON dav_lock FIELDS token UNIQUE;
```

## Événements Natifs

La logique de synchronisation est gérée par des événements moteurs, garantissant l'intégrité même en cas de modification directe via SQL.

```sql
DEFINE EVENT bump_sync_create ON dav_object WHEN $event = "CREATE" THEN (
    UPDATE dav_collection SET sync_token += 1 WHERE path = $after.collection_path
);
DEFINE EVENT bump_sync_update ON dav_object WHEN $event = "UPDATE" THEN (
    UPDATE dav_collection SET sync_token += 1 WHERE path = $after.collection_path
);
DEFINE EVENT bump_sync_delete ON dav_object WHEN $event = "DELETE" THEN (
    UPDATE dav_collection SET sync_token += 1 WHERE path = $before.collection_path
);
```

## Fonctions Natives

Les fonctions natives (`dav::put`, `dav::get`, etc.) n'implémentent aucune logique métier complexe en Rust. Elles agissent comme des proxys vers le moteur SQL, transformant les appels de fonction en transactions SQL.

- `dav::put($path, $content)` -> `UPSERT dav_object ...`
- `dav::get($path)` -> `SELECT * FROM dav_object ...`
- `dav::delete($path)` -> `DELETE FROM dav_object ...`

## Permissions

(À implémenter dans une phase ultérieure via `DEFINE ACCESS`)
Les permissions seront gérées nativement par SurrealDB au niveau des tables `dav_*`.

