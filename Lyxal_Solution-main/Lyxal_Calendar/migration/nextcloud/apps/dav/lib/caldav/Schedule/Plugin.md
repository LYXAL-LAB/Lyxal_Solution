# Analyse de `OCA\DAV\CalDAV\Schedule\Plugin`

## Description

La classe `Plugin` étend le plugin de planification standard de SabreDAV (`Sabre\CalDAV\Schedule\Plugin`) pour fournir une intégration profonde et des fonctionnalités spécifiques à Nextcloud. C'est la pièce maîtresse qui gère le flux complet de la planification CalDAV (iTip), de la réception d'une modification d'événement à la livraison des invitations aux participants, en passant par l'automatisation des réponses pour les ressources.

## Rôle et Responsabilités

1.  **Gestion du Calendrier de Planification par Défaut** :
    *   La responsabilité la plus complexe de ce plugin est de fournir la propriété `caldav:schedule-default-calendar-URL` pour chaque principal (utilisateur, salle, ressource).
    *   La méthode `propFindDefaultCalendarUrl` contient une logique robuste pour :
        *   Déterminer le calendrier par défaut configuré par l'utilisateur.
        *   Si aucun n'est configuré ou s'il n'existe pas, utiliser un calendrier de repli (`personal` pour les utilisateurs, `resource-booking-calendar` pour les ressources).
        *   **Créer à la volée** le calendrier par défaut s'il n'existe pas.
        *   Si le calendrier par défaut a été supprimé, il tente de le renommer dans la corbeille pour en créer un nouveau, préservant ainsi la possibilité de restauration.
        *   Si le calendrier par défaut n'est pas valide (ex: en lecture seule), il recherche le premier calendrier personnel et inscriptible de l'utilisateur pour y déposer les invitations.
    *   Cette logique garantit qu'un utilisateur ou une ressource a toujours un emplacement valide pour recevoir des invitations.

2.  **Traitement des Changements d'Événements (`calendarObjectChange`)** :
    *   Cette méthode est déclenchée avant la création ou la modification d'un objet calendrier.
    *   Elle utilise un `TipBroker` personnalisé (`OCA\DAV\CalDAV\TipBroker`) pour analyser l'ancienne et la nouvelle version de l'événement.
    *   Le broker détermine quels participants doivent être notifiés (nouveaux, supprimés, modifiés) et génère les messages iTip correspondants.
    *   Elle gère correctement les calendriers partagés en incluant les adresses e-mail du propriétaire du calendrier et du participant actuel (le "sharee") dans l'analyse.

3.  **Livraison et Automatisation des Réponses (`scheduleLocalDelivery`)** :
    *   Cette méthode est appelée lorsque le `TipBroker` détermine qu'une invitation est destinée à un principal local (un utilisateur, une salle ou une ressource sur la même instance Nextcloud).
    *   **Réponse Automatique pour les Ressources/Salles** : C'est ici que la magie de la réservation de ressources opère.
        1.  La méthode vérifie si le destinataire est une `ROOM` ou une `RESOURCE`.
        2.  Elle vérifie si l'invitation demande une réponse (`RSVP=TRUE`).
        3.  Elle ignore les événements récurrents pour l'auto-réponse (trop complexe à gérer).
        4.  Elle appelle `isAvailableAtTime` pour vérifier si la ressource est libre pendant la plage horaire demandée en effectuant une requête `free-busy`.
        5.  Elle construit un message de réponse iTip (`METHOD:REPLY`) avec un statut de participant (`PARTSTAT`) `ACCEPTED` ou `DECLINED`.
        6.  Crucialement, elle ne distribue pas cette réponse immédiatement. Elle la stocke dans un tableau (`$this->schedulingResponses`).

4.  **Distribution Différée des Réponses (`dispatchSchedulingResponses`)** :
    *   Les réponses automatiques des ressources sont mises en attente pour résoudre un problème de concurrence : la réponse ne peut être envoyée à l'organisateur que *après* que l'événement de l'organisateur a été sauvegardé avec succès.
    *   Le plugin s'abonne aux événements `afterWriteContent` et `afterCreateFile`. Lorsque l'événement de l'organisateur est finalement écrit, `dispatchSchedulingResponses` est appelé et envoie toutes les réponses en attente.

5.  **Améliorations et Contournements Spécifiques à Nextcloud** :
    *   **`createITipBroker`**: Surcharge la méthode de SabreDAV pour instancier le `TipBroker` personnalisé de Nextcloud, qui a une logique de comparaison d'événements plus fine.
    *   **`handleSameOrganizerException`**: Introduit une tolérance pour les événements non conformes au RFC qui ont plusieurs organisateurs (souvent importés de services comme Google Calendar). Si l'utilisateur actuel n'est pas l'un des organisateurs, l'exception est ignorée, permettant de sauvegarder l'événement sans envoyer de notifications erronées.
    *   **Suppression des alarmes (`VALARM`)**: Lors de la livraison locale d'une invitation, toutes les alarmes sont retirées du message. C'est une décision de conception pour que le destinataire gère ses propres rappels et ne soit pas spammé par ceux de l'organisateur.
    *   **Décodage d'URL**: `getAddressesForPrincipal` est surchargé pour s'assurer que les adresses e-mail sont correctement décodées (`urldecode`).

## Dépendances Clés

-   `OCP\IConfig`: Pour lire la configuration de l'application `dav`, comme le calendrier par défaut d'un utilisateur.
-   `Psr\Log\LoggerInterface`: Pour la journalisation.
-   `OCA\DAV\CalDAV\DefaultCalendarValidator`: Pour valider si un calendrier est un candidat approprié pour devenir le calendrier de planification par défaut.
-   `Sabre\DAV\Server`: Le plugin s'intègre profondément dans le cycle de vie du serveur SabreDAV via des hooks événementiels.
-   `OCA\DAV\CalDAV\TipBroker`: Le moteur d'analyse iTip qui génère les messages de planification.

En résumé, le `Plugin` de planification de Nextcloud est une surcouche puissante qui transforme le moteur de planification générique de SabreDAV en un système intelligent et automatisé. Il assure de manière robuste que les invitations arrivent toujours à bon port et automatise entièrement le processus de réservation pour les ressources et les salles, une fonctionnalité essentielle pour les entreprises.
