# Analyse du Fichier `Federation/FederationSharingService.php`

Ce document décompose le contenu de la classe `Federation\FederationSharingService.php`. Il s'agit d'un service de haut niveau qui orchestre l'ensemble du processus de création d'un partage de calendrier fédéré sortant.

---

## 1. Rôle et Responsabilités

La classe `FederationSharingService` est l'**orchestrateur du partage sortant**. Lorsqu'un utilisateur initie un partage d'un de ses calendriers avec un utilisateur sur une instance Nextcloud distante, c'est ce service qui est responsable de la gestion de l'ensemble du workflow.

Ses responsabilités incluent :
1.  **Valider** la demande de partage.
2.  **Construire** l'invitation de partage en respectant le protocole de fédération.
3.  **Communiquer** avec le serveur distant pour lui envoyer l'invitation.
4.  **Créer un enregistrement local** du partage pour permettre l'authentification des futures requêtes de synchronisation du serveur distant.

---

## 2. Logique Principale (`shareWith` method)

La méthode `shareWith` est le point d'entrée unique et contient la logique complète du workflow, qui peut être décomposée en trois phases principales.

### Phase 1 : Validation et Préparation
Avant toute communication réseau, le service s'assure que la demande est valide.
-   Il décode le "principal URI" de l'utilisateur distant pour extraire son Cloud ID.
-   Il vérifie que le propriétaire de la ressource partagée est bien un utilisateur local.
-   Il génère un **token secret** cryptographiquement sécurisé (`$this->random->generate(32)`), qui servira de "mot de passe" pour le serveur distant.
-   Il utilise une factory (`ICloudFederationFactory`) pour créer un objet `share` qui représente l'invitation formelle.

### Phase 2 : Construction du Protocole et Envoi
Le service prépare ensuite le message à envoyer au serveur distant.
-   Il assemble un objet de protocole (`CalendarFederationProtocolV1`) contenant toutes les métadonnées du calendrier partagé : son URL d'accès, son nom d'affichage, sa couleur, les permissions accordées et les types de composants supportés (`VEVENT`, `VTODO`, etc.).
-   Il attache ce protocole à l'objet `share`.
-   Il délègue l'envoi de l'invitation au gestionnaire de fédération (`ICloudFederationProviderManager`), qui s'occupe de la communication réseau.
-   Il vérifie que la réponse du serveur distant est un `201 Created`, indiquant que l'invitation a été acceptée. Si ce n'est pas le cas, le processus s'arrête.

### Phase 3 : Création de l'Enregistrement de Partage Local
C'est une étape de sécurité et de persistance essentielle.
-   Si le serveur distant a accepté le partage, le service doit créer un enregistrement local pour s'en souvenir.
-   Il utilise le `SharingMapper` (le mapper pour les partages DAV génériques) pour créer une nouvelle entrée dans la base de données.
-   Cette entrée lie l'ID du calendrier local, le "principal" de l'utilisateur distant, les permissions accordées, et surtout, le **token secret** généré à la première étape.
-   Cet enregistrement est fondamental, car c'est lui que le backend d'authentification (`FederatedCalendarAuth`) consultera plus tard pour valider les requêtes de synchronisation du serveur distant, en vérifiant que le token fourni correspond bien à celui stocké.

---

## Conclusion

`FederationSharingService` est le chef d'orchestre du partage fédéré sortant. Il coordonne plusieurs composants de plus bas niveau (factories, mappers, gestionnaire de fédération) pour exécuter un workflow complexe qui va de la validation des données à la communication inter-serveurs, et se termine par la création d'un état persistant qui sécurise les futures interactions. C'est le composant qui transforme une simple action de l'utilisateur en un lien de partage fédéré fonctionnel et sécurisé.
