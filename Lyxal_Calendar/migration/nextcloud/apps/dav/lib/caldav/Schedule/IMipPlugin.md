# Analyse de `OCA\DAV\CalDAV\Schedule\IMipPlugin`

## Description

La classe `IMipPlugin` est une spécialisation pour Nextcloud du plugin iMIP de SabreDAV (`Sabre\CalDAV\Schedule\IMipPlugin`). Son rôle principal est de gérer l'envoi d'invitations et de mises à jour d'événements de calendrier par e-mail, en utilisant le protocole iMIP (iCalendar Message-based Interoperability Protocol).

Elle s'intègre profondément avec le système de messagerie, de templating et de gestion des utilisateurs de Nextcloud pour envoyer des e-mails riches et contextualisés.

## Rôle et Responsabilités

1.  **Interception des Événements de Planification** :
    *   Le plugin s'abonne à l'événement `schedule` du serveur SabreDAV. Cet événement est déclenché par le `Broker` iTip lorsqu'une modification sur un événement (création, mise à jour, annulation, réponse) affecte un participant.
    *   La méthode `schedule(Message $iTipMessage)` est le point d'entrée principal.

2.  **Filtrage et Validation avant Envoi** :
    *   **Changement significatif** : Elle n'envoie un e-mail que si le `Broker` iTip considère la modification comme significative (`$iTipMessage->significantChange`).
    *   **Validité du destinataire** : Elle vérifie que le destinataire est bien une adresse e-mail (`mailto:`), qu'elle est valide, et qu'il ne s'agit pas d'une ressource, d'une salle ou d'un cercle (pour éviter de notifier des entités non humaines).
    *   **Temporalité** : Elle n'envoie pas de notifications pour des événements dont la dernière occurrence est déjà passée.

3.  **Construction de l'E-mail d'Invitation** :
    *   **Détermination du contexte** : La classe détermine la nature de la modification (nouvelle invitation `REQUEST`, réponse `REPLY`, ou annulation `CANCEL`).
    *   **Utilisation de Templates** : Elle utilise le `IMailer` de Nextcloud pour créer un e-mail à partir de templates HTML et texte spécifiques à chaque contexte (par exemple, `dav.calendarInvite.request`).
    *   **Personnalisation du Contenu** : Elle délègue à `IMipService` la tâche complexe de générer les données pour le template (titre de l'événement, date, lieu, changements, etc.) et de formater le sujet et les en-têtes de manière localisée.
    *   **Ajout de Boutons de Réponse** : Pour les nouvelles invitations, elle peut ajouter des boutons "Accepter", "Refuser", "Peut-être". L'affichage de ces boutons est configurable (`dav.invitation_link_recipients`) pour ne les montrer qu'aux utilisateurs internes si nécessaire. Ces boutons pointent vers une URL contenant un token sécurisé (`IMipService->createInvitationToken`).

4.  **Envoi de l'E-mail** :
    *   **Intégration avec `IMailManager`**: La classe tente d'abord d'utiliser le nouveau gestionnaire de comptes de messagerie (`IMailManager`). Si l'organisateur de l'événement a configuré un compte e-mail dans Nextcloud et que l'adresse correspond, l'invitation est envoyée via ce compte, ce qui est idéal pour la cohérence (l'e-mail provient de l'adresse de l'organisateur).
    *   **Fallback sur `IMailer`**: Si aucun compte personnalisé n'est trouvé ou si la fonctionnalité est désactivée, elle utilise le service de messagerie global de Nextcloud (`IMailer`) comme solution de repli. L'e-mail est alors envoyé depuis une adresse générique "noreply".
    *   **Gestion de l'Expéditeur** : Le nom de l'expéditeur (`From`) est soigneusement construit en utilisant le nom d'affichage de l'organisateur.

5.  **Attachement du Fichier iCalendar** :
    *   L'invitation iCalendar brute (le message iTip sérialisé) est attachée à l'e-mail.
    *   Le type de contenu MIME est correctement défini (`text/calendar; method=...`) pour que les clients de messagerie (comme Outlook, Thunderbird, Google Calendar) puissent l'interpréter correctement et l'afficher comme une invitation interactive.

6.  **Gestion de l'État d'Origine** :
    *   Pour pouvoir comparer l'ancienne et la nouvelle version d'un événement et déterminer les changements, le plugin s'abonne également à l'événement `beforeWriteContent`. Avant qu'une modification ne soit écrite, il lit et met en cache l'état actuel de l'objet calendrier.

## Dépendances Clés

-   `OCA\DAV\CalDAV\Schedule\IMipService`: Une classe de service cruciale à laquelle une grande partie de la logique métier (formatage des données, création de tokens, gestion de la localisation) est déléguée.
-   `OCP\Mail\IMailer` et `OCP\Mail\Provider\IManager`: Pour la création et l'envoi des e-mails.
-   `OCP\IAppConfig`: Pour lire la configuration de l'application `dav` (par exemple, `invitation_link_recipients`).
-   `OCP\IUserSession`: Pour obtenir des informations sur l'utilisateur qui initie l'action.
-   `OCA\DAV\CalDAV\EventComparisonService`: Pour identifier précisément quels `VEvent` ont été modifiés entre deux versions d'un `VCalendar`.
-   `OCP\Mail\IEmailValidator`: Pour valider les adresses e-mail des destinataires.

En résumé, `IMipPlugin` est un orchestrateur sophistiqué qui agit comme un pont entre le monde interne de la planification CalDAV de Nextcloud et le monde externe de la messagerie. Il transforme des événements de protocole abstraits en e-mails de notification clairs, localisés, sécurisés et interactifs pour l'utilisateur final.
