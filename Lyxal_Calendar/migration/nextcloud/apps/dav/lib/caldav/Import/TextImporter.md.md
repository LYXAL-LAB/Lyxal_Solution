# Analyse du Fichier `Import/TextImporter.php`

Ce document décompose le contenu de la classe `Import\TextImporter.php`. Il s'agit d'un parser iCalendar (`.ics`) de bas niveau, spécifiquement conçu pour être performant et efficace en mémoire lors du traitement de fichiers volumineux.

---

## 1. Rôle et Responsabilités

La classe `TextImporter` est un **parser spécialisé**. Contrairement à un parser iCalendar standard qui lirait l'ensemble d'un fichier pour construire un arbre d'objets en mémoire, cette classe a une approche optimisée en deux phases :
1.  **Analyser**: Parcourir le fichier une première fois pour en créer une "carte" ou un "index", sans charger le contenu des événements.
2.  **Extraire**: Fournir une méthode pour lire des segments spécifiques du fichier en utilisant l'index précédemment créé.

Cette approche permet au `ImportService` de traiter un fichier iCalendar de manière séquentielle (`stream`), en ne chargeant en mémoire que les données d'un seul événement à la fois.

---

## 2. Logique Principale

### `analyze()` - La Phase d'Indexation
-   Cette méthode privée est le cœur de l'optimisation. Elle parcourt le fichier source (`resource`) ligne par ligne.
-   Son objectif n'est **pas** de comprendre ou de stocker le contenu, mais de **repérer les marqueurs de structure** :
    -   `BEGIN:VEVENT`, `BEGIN:VTODO`, `BEGIN:VTIMEZONE`, etc.
    -   `END:VEVENT`, `END:VTODO`, etc.
    -   Les identifiants `UID` (pour les événements/tâches) et `TZID` (pour les fuseaux horaires).
-   Pour chaque composant qu'elle identifie, elle **enregistre uniquement sa position de début et de fin en octets** dans le fichier (`ftell()`).
-   Le résultat est stocké dans la propriété `$this->structure`, un tableau qui sert de carte. Par exemple, pour un `UID` donné, il peut y avoir plusieurs entrées, chacune correspondant à une occurrence de cet événement dans le fichier (par exemple, la définition de base et les exceptions de récurrence).

### `structure()` - L'Accès à l'Index
-   Cette méthode publique est le point d'accès à la carte générée par `analyze()`.
-   Elle s'assure que l'analyse n'est effectuée qu'une seule fois (mémoïsation).

### `extract(int $start, int $end)` - La Phase d'Extraction
-   Cette méthode publique permet d'accéder directement à un segment de données du fichier.
-   Elle utilise `fseek()` pour se positionner au `$start` octet, puis `fread()` pour lire le nombre d'octets requis jusqu'à `$end`.
-   Le `ImportService` utilise cette méthode, après avoir consulté la `structure`, pour extraire les données brutes de chaque composant afin de les passer au parser de Sabre\VObject.

---

## Conclusion

`TextImporter` est une implémentation intelligente et performante pour le pré-traitement de fichiers iCalendar. En séparant l'indexation de la structure du fichier de l'extraction de son contenu, elle évite la consommation de mémoire élevée typique des parsers DOM-like. C'est un composant d'infrastructure crucial qui permet au `ImportService` de gérer l'importation de calendriers de plusieurs mégaoctets ou gigaoctets de manière fiable et sans épuiser les ressources du serveur.
