# Analyse du Fichier `Federation/RemoteUserCalendarHome.php`

Ce document décompose le contenu de la classe `Federation\RemoteUserCalendarHome.php`. Il s'agit d'une version spécialisée et restrictive du `CalendarHome` (le dossier racine des calendriers d'un utilisateur) destinée aux utilisateurs distants.

---

## 1. Rôle et Responsabilités

La classe `RemoteUserCalendarHome` hérite de la classe `Sabre\CalDAV\CalendarHome`. Son rôle est de représenter le **nœud racine de l'arborescence des calendriers pour un utilisateur distant authentifié**. C'est ce qui est exposé à un autre serveur Nextcloud lorsqu'il se connecte pour synchroniser un calendrier qui a été partagé avec lui.

Sa responsabilité est de fournir une **vue limitée et sécurisée** de l'environnement de l'utilisateur partageur.

---

## 2. Logique de Spécialisation

La classe surcharge les méthodes de découverte d'enfants (`getChild` et `getChildren`) de sa classe parente pour en simplifier et en restreindre le comportement.

- **`getChild($name)` et `getChildren()`**:
  - **Comportement surchargé**:
    1.  Contrairement à un `CalendarHome` normal, cette classe **n'essaie pas de créer ou de lister les sous-dossiers fonctionnels** comme `inbox`, `outbox`, `notifications`, etc.
    2.  Elle appelle directement la méthode `getCalendarsForUser` du backend CalDAV.
    3.  Le backend est conçu de telle manière que, lorsque le "principal URI" est celui d'un utilisateur distant (ex: `principals/remote-users/...`), cette méthode ne retourne **que la liste des calendriers qui ont été explicitement partagés** avec cet utilisateur distant.
    4.  Elle encapsule ensuite ces résultats dans des objets `Calendar` standards et les retourne.

- **Implications en termes de sécurité**:
  - Cette spécialisation est cruciale pour la sécurité et le cloisonnement. Elle garantit qu'un serveur distant, même après s'être authentifié avec succès via `FederatedCalendarAuth`, ne peut absolument pas "voir" ou interagir avec les calendriers personnels de l'utilisateur partageur, ni avec aucun autre composant de son `CalendarHome`. La vue est strictement limitée aux ressources qui lui ont été explicitement partagées.

---

## Conclusion

`RemoteUserCalendarHome` est un composant de sécurité essentiel dans l'architecture de la fédération. En fournissant une version "allégée" et strictement contrôlée du `CalendarHome`, elle crée un environnement isolé ("sandbox") pour les interactions avec les serveurs distants. Elle assure que le principe du moindre privilège est respecté, en n'exposant à une partie externe que les données strictement nécessaires à la synchronisation du partage.
