# Module : Duration
Lieu : `core/src/function/duration.rs`

Ce module gère la création et l'extraction des durées (`duration`).

| Fonction Lyxal | Arguments | Retour | Description |
| :--- | :--- | :--- | :--- |
| **`duration::days`** | `(duration)` | `number` | Extrait le nombre de jours d'une durée. |
| **`duration::secs`** | `(duration)` | `number` | Extrait le nombre de secondes d'une durée. |
| **`duration::from::days`** | `(number)` | `duration` | Crée une durée à partir d'un nombre de jours. |
| **`duration::from::secs`** | `(number)` | `duration` | Crée une durée à partir d'un nombre de secondes. |
| **`duration::from::string`** | `(string)` | `duration` | Parse une chaîne de durée (ex: "1d 2h 30m"). |
