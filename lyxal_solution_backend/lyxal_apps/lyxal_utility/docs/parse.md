# Module : Parse
Lieu : `core/src/function/parse.rs`

Ce module gère la transformation de chaînes de caractères brutes (provenant d'APIs ou d'entrées utilisateurs) en données structurées pour Lyxal.

| Fonction Lyxal | Arguments | Retour | Description |
| :--- | :--- | :--- | :--- |
| **`parse::datetime::from_str`** | `(string, format)` | `datetime | none` | Parse une date selon un format spécifié (ex: "%Y-%m-%d"). |
| **`parse::datetime::iso`** | `(string)` | `datetime | none` | Parse une date au format standard ISO8601 / RFC3339. |
| **`parse::email::host`** | `(string)` | `string | none` | Extrait le domaine d'une adresse email. |
| **`parse::email::user`** | `(string)` | `string | none` | Extrait la partie utilisateur d'une adresse email. |
| **`parse::url::domain`** | `(string)` | `string | none` | Extrait le domaine d'une URL. |
| **`parse::url::path`** | `(string)` | `string | none` | Extrait le chemin (path) d'une URL. |
| **`parse::url::port`** | `(string)` | `number | none` | Extrait le port d'une URL. |
