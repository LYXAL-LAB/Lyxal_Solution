# Analyse du Fichier `Activity/Provider/Event.php`

Ce document décompose le contenu de la classe `Activity\Provider\Event.php`. Il s'agit d'un fournisseur d'activités qui sait comment interpréter et formater les notifications relatives aux **événements (VEVENT)** pour les afficher dans le flux d'activité.

---

## 1. Rôle et Responsabilités

La classe `Event` hérite de `Activity\Provider\Base` et implémente l'interface `IProvider`. Son rôle est de prendre un objet `IEvent` brut de type `calendar_event` et de le **transformer en un objet d'activité finalisé**, prêt à être affiché.

Elle est responsable de :
1.  **Traduire** le "sujet" de l'activité (ex: `object_add_event_self`) en une phrase complète (ex: "You created event {event} in calendar {calendar}").
2.  **Enrichir** les paramètres, notamment en générant un lien direct vers l'événement dans l'application Calendrier.
3.  **Gérer la confidentialité** en masquant les détails des événements confidentiels.
4.  **Fusionner** des activités similaires.

---

## 2. Logique Principale

### Méthode `parse`
C'est le point d'entrée principal, appelé par le gestionnaire d'activités.
- **Étapes d'exécution**:
  1.  **Validation**: Vérifie que le type de l'activité est bien `calendar_event`.
  2.  **Traduction du sujet**: Utilise une grande structure `if/elseif` pour mapper chaque `subject` à sa chaîne de caractères traduite. La logique gère de nombreux cas : création, mise à jour, suppression, déplacement, restauration, et les versions `_self` pour chaque.
  3.  **Enrichissement des paramètres**: Appelle `getParameters`, qui utilise les méthodes de la classe `Base` et des méthodes spécifiques à cette classe pour formater les paramètres.
  4.  **Fusion des événements**: Utilise le service `IEventMerger` pour regrouper des notifications similaires (par exemple, plusieurs modifications sur le même événement).

### Méthodes Spécifiques
- **`generateObjectParameter(...)`**:
  - **Rôle**: Formater le paramètre `{event}`.
  - **Action**: En plus du nom, cette méthode a une logique importante pour **générer un lien profond (`deep link`)** vers l'événement dans l'application Calendrier. Elle gère la complexité des URL pour les calendriers propres et les calendriers partagés afin de construire un lien valide dans tous les cas.

- **`generateClassifiedObjectParameter(...)`**:
  - **Rôle**: Gérer la confidentialité.
  - **Action**: Appelle `generateObjectParameter` puis, si l'événement est marqué comme "classifié" (confidentiel), elle remplace le nom de l'événement par la chaîne traduite "Occupé".

---

## Conclusion

`Activity\Provider\Event` est la couche de présentation du système d'activité pour les **événements**. Symétrique à son homologue pour les calendriers, elle transforme les données d'activité brutes en une notification lisible et utile. Sa logique de génération de liens profonds et de gestion de la confidentialité est particulièrement importante, car elle enrichit la notification en la rendant directement actionnable (on peut cliquer dessus pour voir l'événement) tout en respectant les règles de visibilité des données.
