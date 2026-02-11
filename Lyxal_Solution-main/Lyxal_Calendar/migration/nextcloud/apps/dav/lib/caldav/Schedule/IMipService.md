# Analyse de `OCA\DAV\CalDAV\Schedule\IMipService`

## Description

La classe `IMipService` est une classe de service (helper) dédiée, utilisée intensivement par `IMipPlugin`. Elle encapsule toute la logique métier complexe liée à la **création du contenu** des e-mails iMIP. Son rôle est de transformer les données brutes d'un événement iCalendar (`VEvent`) et d'un message iTip en chaînes de caractères localisées, en données structurées pour les templates, et en tokens sécurisés.

C'est un exemple clair de séparation des responsabilités : tandis que `IMipPlugin` orchestre l'envoi, `IMipService` se charge de la "sale besogne" de la préparation du contenu.

## Rôle et Responsabilités

1.  **Préparation des Données pour les Templates (`build...BodyData`)** :
    *   **`buildBodyData(VEvent $vEvent, ?VEvent $oldVEvent)`**: Pour les invitations nouvelles ou modifiées. Elle extrait le titre, la description, le lieu, etc. Surtout, si une ancienne version de l'événement (`$oldVEvent`) est fournie, elle génère un "diff" visuel en HTML (par exemple, `<span style='text-decoration: line-through'>Ancien lieu</span><br />Nouveau lieu`) pour mettre en évidence les changements.
    *   **`buildReplyBodyData(VEvent $vEvent)`**: Pour les e-mails de réponse à une invitation. Elle extrait les informations de l'événement sans générer de diff.
    *   **`buildCancelledBodyData(VEvent $vEvent)`**: Pour les notifications d'annulation. Elle formate toutes les informations de l'événement avec un style barré pour indiquer clairement que l'événement est annulé.

2.  **Génération de Chaînes de Date/Heure Complexes (`generateWhenString`, `generateOccurringString`)** :
    *   C'est l'une des fonctionnalités les plus sophistiquées. Ces méthodes utilisent un `EventReader` (un autre helper qui simplifie la lecture des `VEvent`) pour analyser les règles de récurrence.
    *   Elles construisent des phrases complètes et localisées décrivant quand un événement a lieu, en gérant de très nombreux cas :
        *   Événements non récurrents ("Le 24 décembre 2024 de 14h00 à 15h00").
        *   Événements récurrents quotidiens, hebdomadaires, mensuels, annuels.
        *   Intervalles ("Toutes les 2 semaines").
        *   Jours spécifiques ("Tous les lundis et mercredis").
        *   Règles complexes ("Le premier et le dernier dimanche de chaque mois").
        *   Dates de fin de récurrence ("... jusqu'au 31 janvier 2025").
    *   `generateOccurringString` calcule et affiche les prochaines occurrences d'un événement récurrent.
    *   Toutes ces chaînes sont générées en utilisant le service de localisation (`IL10N`) pour être dans la langue du destinataire.

3.  **Gestion de la Localisation (`setL10nFromAttendee`)** :
    *   Cette méthode détermine la langue à utiliser pour un e-mail donné.
    *   Elle suit une logique de priorité :
        1.  Vérifier si l'adresse e-mail du participant correspond à un utilisateur Nextcloud et utiliser la langue configurée pour cet utilisateur.
        2.  Sinon, utiliser le paramètre `LANGUAGE` de l'invitation iCalendar elle-même.
        3.  En dernier recours, utiliser la langue par défaut de l'instance Nextcloud.

4.  **Création et Gestion des Tokens d'Invitation (`createInvitationToken`)** :
    *   Génère un token cryptographiquement sécurisé et unique à l'aide de `ISecureRandom`.
    *   Stocke ce token dans la table de la base de données `oc_calendar_invitations` avec les détails de l'invitation (participant, organisateur, UID de l'événement, etc.) et une date d'expiration.
    *   Ce token est ensuite utilisé dans les URL des boutons "Accepter" / "Refuser" dans l'e-mail, permettant une réponse en un clic sans nécessiter de connexion.

5.  **Fonctions Utilitaires et Logique de Décision** :
    *   **`getLastOccurrence(VCalendar $vObject)`**: Calcule la date et l'heure de la dernière occurrence d'un événement, même s'il est infiniment récurrent (dans ce cas, il est plafonné à 2038). C'est utilisé pour s'assurer qu'on n'envoie pas de notifications pour des événements déjà terminés.
    *   **`isRoomOrResource(Property $attendee)` / `isCircle(Property $attendee)`**: Vérifie le paramètre `CUTYPE` d'un participant pour déterminer s'il s'agit d'une salle, d'une ressource ou d'un cercle, et ainsi éviter de leur envoyer des e-mails.
    *   **`getAttendeeRsvpOrReqForParticipant(...)`**: Détermine si un participant doit pouvoir répondre à une invitation (si son paramètre `RSVP` est à `TRUE` ou s'il est un participant requis/optionnel).
    *   **`addSubjectAndHeading(...)` / `addBulletList(...)` / `addResponseButtons(...)`**: Méthodes qui interagissent directement avec l'objet `IEMailTemplate` pour construire l'e-mail final (définir le sujet, ajouter des listes à puces, ajouter les boutons d'action).

## Dépendances Clés

-   `OCP\L10N\IFactory` et `OCP\IL10N`: Au cœur de la génération de contenu localisé.
-   `OCP\AppFramework\Utility\ITimeFactory`: Pour obtenir l'heure actuelle de manière fiable.
-   `OCA\DAV\CalDAV\EventReader`: Un helper essentiel pour simplifier l'interprétation des données d'un `VEvent`.
-   `OCP\IDBConnection`: Pour stocker les tokens d'invitation.
-   `OCP\Security\ISecureRandom`: Pour la génération de tokens sécurisés.
-   `OC\URLGenerator`: Pour construire les URLs absolues des images et des liens de réponse.

En résumé, `IMipService` est une classe de service très dense qui agit comme le "cerveau" derrière le contenu des invitations par e-mail. Elle transforme la structure de données formelle d'iCalendar en une communication humaine, localisée, et interactive.
