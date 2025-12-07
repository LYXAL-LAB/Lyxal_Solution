# Analyse du Fichier `Federation/FederatedCalendarAuth.php`

Ce document décompose le contenu de la classe `Federation\FederatedCalendarAuth.php`. Il s'agit d'un backend d'authentification SabreDAV spécialisé pour les requêtes de synchronisation de calendriers fédérés **entrantes**.

---

## 1. Rôle et Responsabilités

La classe `FederatedCalendarAuth` implémente l'interface `BackendInterface` de SabreDAV. Son unique responsabilité est d'**authentifier les requêtes provenant d'autres serveurs Nextcloud** qui cherchent à synchroniser un calendrier qui a été partagé avec eux.

Elle agit comme un "gardien" pour les points d'accès (`endpoints`) des calendriers fédérés (les URL commençant par `remote-calendars/`). Elle valide que le serveur distant qui fait la requête a bien la permission d'accéder à la ressource demandée.

---

## 2. Logique d'Authentification (`check` method)

La méthode `check` est le point d'entrée principal pour le processus d'authentification.

- **Étapes d'exécution**:
  1.  **Filtrage de l'URL**: La première chose que fait la méthode est de vérifier si l'URL de la requête commence par `remote-calendars/`. Si ce n'est pas le cas, elle ignore la requête, car elle n'est pas de sa responsabilité.
  2.  **Extraction des Identifiants**: Elle utilise la classe `Sabre\HTTP\Auth\Basic` pour parser l'en-tête `Authorization: Basic` et en extraire le nom d'utilisateur et le mot de passe.
  3.  **Délégation à `validateUserPass`**: La validation réelle est effectuée dans la méthode privée `validateUserPass`.

### Méthode `validateUserPass`
C'est le cœur de la logique de sécurité.

- **Interprétation des "Identifiants"**:
  -   Le **nom d'utilisateur** fourni par le serveur distant est en réalité l'**identifiant Cloud** de l'utilisateur à qui le calendrier a été partagé (ex: `user@distant-server.com`).
  -   Le **mot de passe** est le **`sharedSecret`**, un token unique qui a été généré lors du partage initial et envoyé au serveur distant par le `CalendarFederationNotifier`.

- **Processus de Validation**:
  1.  Elle utilise le `SharingMapper` pour interroger la base de données et récupérer la liste de tous les calendriers qui ont été partagés avec l'utilisateur distant (`remoteUserPrincipalUri`) en utilisant le token secret (`password`).
  2.  Elle parcourt cette liste et vérifie si l'URL exacte demandée dans la requête correspond à l'un des partages autorisés pour ce couple utilisateur/token.
  3.  **Si une correspondance est trouvée**, la méthode retourne le "principal URI" de l'utilisateur distant, ce qui signifie que l'authentification a réussi.
  4.  **Si aucune correspondance n'est trouvée**, elle retourne `null`, et l'authentification échoue.

---

## Conclusion

`FederatedCalendarAuth` est un composant de sécurité crucial pour la fédération. Il implémente un mécanisme d'authentification basé sur des tokens (`sharedSecret`) qui est à la fois sécurisé et spécifique à chaque partage. En validant non seulement que le token est correct pour l'utilisateur distant, mais aussi que cet utilisateur tente bien d'accéder à la ressource qui lui a été spécifiquement partagée, il garantit que les serveurs distants ne peuvent accéder qu'aux données pour lesquelles ils ont explicitement reçu une autorisation.
