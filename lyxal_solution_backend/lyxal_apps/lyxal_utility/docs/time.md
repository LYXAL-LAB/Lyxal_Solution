# Module : Time
Lieu : `core/src/function/time.rs`

Ce module gère la manipulation, le calcul et l'affichage des objets temporels (`datetime`).

| Fonction Lyxal | Arguments | Retour | Description |
| :--- | :--- | :--- | :--- |
| **`time::now`** | `()` | `datetime` | Retourne l'instant présent en UTC. |
| **`time::add`** | `(datetime, duration)` | `datetime` | Ajoute une durée à une date. |
| **`time::sub`** | `(datetime, duration)` | `datetime` | Soustrait une durée à une date. |
| **`time::diff`** | `(datetime, datetime)` | `duration` | Calcule la durée exacte entre deux dates. |
| **`time::add_business_days`** | `(datetime, number)` | `datetime` | Ajoute des jours ouvrés (Lundi-Vendredi). |
| **`time::with_timezone`** | `(datetime, string)` | `datetime` | Change le fuseau horaire d'affichage (IANA). |
| **`time::humanize`** | `(datetime)` | `string` | Retourne une durée relative lisible (ex: "il y a 2h"). |
| **`time::format`** | `(datetime, string)` | `string` | Formate une date selon un pattern (chrono). |
| **`time::unix`** | `(datetime?)` | `number` | Retourne le timestamp Unix en secondes. |
