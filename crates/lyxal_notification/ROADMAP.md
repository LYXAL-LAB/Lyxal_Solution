# Feuille de route — `lyxal_notification`

Évolutions à venir ; l'état actuel est décrit par [`README.md`](README.md). Correspondance
détaillée avec Novu : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) §1 et §2. Chaque lot démarre sur
ordre du CTO avec un `implementation_plan.md` validé.

| Lot | Contenu | Prérequis |
| :--- | :--- | :--- |
| **V1-d — Fil in-app** | États, compteurs, actions, onglets, snooze, temps réel ; valeur « lu » d'un message du fil fournie aux conditions d'étape (« sauter si déjà lu », décision C6) | point 1 |
| **V1-e — Autres canaux** | SMS, messageries d'équipe et adresse web livrés (lot 4, README) ; restent : push (lot 6, point 4) ; choix de l'intégration dans les surcharges d'un déclenchement (décision C5) ; fournisseurs e-mail Amazon SES, SendGrid et OVHcloud (signatures RSA ou SHA-1 à vérifier, K5) ; retours des SMS de toutes les parties d'un message Vonage (seule la première est rattachée) ; Vonage par l'API Messages (webhooks signés JWT) | `lyxal_crypto` (K8) pour le push |
| **V2 — Observabilité et console** | Écrans de la console (dont l'aperçu des étapes), regroupement à heure fixe (ex. chaque jour à 9 h), statistiques horaires, suivi des ouvertures et clics (désactivé par défaut, décision N7), webhooks sortants signés (point 2), révisions publiées, contrôle des domaines d'envoi, étape HTTP (point 6) | `lyxal_secrets` |
| **V3 — Événementiel avancé** | Interactions humaines (approuver / choisir par message), courrier entrant (point 5), connexions chat OAuth, outils IA | `lyxal_connect` |

## Essais réels à faire (comptes des fournisseurs)

Les tests automatiques n'appellent aucun vrai fournisseur : envois et retours sont vérifiés
contre des imitations locales, d'après la documentation de chaque API. Ces essais confirment le
format réel ; ils se font sur ordre du CTO, avec **ses propres comptes**, identifiants rangés
dans `lyxal_secrets` (jamais dans le dépôt ni dans une conversation). Chaque nouveau fournisseur
ajoute ici ses essais ; un essai réussi est retiré de la liste et noté dans le README.

Préalable commun : un hôte joignable depuis Internet en HTTPS (adresse publique
`LYXAL__NOTIFICATION__PUBLIC_URL`), une intégration créée selon le README (§6, « Première mise
en service »), une adresse de réception à soi.

| Fournisseur | Envoi | Retours (webhook) | Résultat attendu |
| :--- | :--- | :--- | :--- |
| **Relais SMTP** (ex. le relais de l'hébergeur) | essai d'intégration (`POST /api/v1/notification/integrations/{intégration}/test`) puis un vrai parcours (ex. réinitialisation du mot de passe de `lyxal_auth`) | aucun (rejets connus à l'envoi) | e-mail reçu, en-têtes `List-Unsubscribe` présents pour un parcours non critique ; adresse inexistante du domaine : rejet 550 noté, adresse supprimée |
| **Brevo** | essai d'intégration, puis un parcours | webhook transactionnel avec authentification Basic (README §6) | e-mail reçu ; `delivered` enregistré ; une adresse inexistante produit `bounced` et la suppression ; mauvais identifiants Basic : refus 401 |
| **Mailgun** (région `us` et `eu`, clé de signature au format actuel **et** au format `key-…` s'il en existe) | essai d'intégration sur un domaine vérifié | webhooks *Delivered*, *Permanent failure*, *Spam complaints* | e-mail reçu ; signature acceptée ; horodatage de plus de 5 min refusé ; adresse inexistante : `bounced` et suppression |
| **Postmark** | essai d'intégration (jeton de serveur) | webhooks *Delivery*, *Bounce*, *Spam complaint* avec Basic | e-mail reçu ; le bouton « Send test » de Postmark pour un *Bounce* produit `bounced` et la suppression |
| **Resend** | essai d'intégration ; puis envois aux adresses de test de Resend (`delivered@resend.dev`, `bounced@resend.dev`, `complained@resend.dev`) | webhook `email.*` (signature Svix) | `delivered`, `bounced` (suppression) et `complained` (suppression) enregistrés dans cet ordre ; signature altérée : refus |
| **Classement des refus** | intégration avec une clé d'API révoquée | — | refus définitif (`NOTIFICATION_PROVIDER_REJECTED`, 401), sans bascule (D3) ; la bascule sur panne temporaire reste prouvée par les tests automatiques (une vraie panne ne se provoque pas) |
| **Brevo SMS** | essai d'intégration SMS (`{ "to": "+33…" }`, secret `{ api_key }`, expéditeur `sender`), puis un parcours avec une étape `sms` | webhook SMS transactionnel avec authentification Basic (adresse demandée message par message, `webUrl`) | SMS reçu ; corps de la requête accepté tel quel (`recipient` sans « + », `type`, `unicodeEnabled`, réponse `messageId`) ; noms réels des états du webhook (`msg_status` : `delivered`, `hardBounce`, `softBounce`, `unsubscribe`…) confirmés ; numéro inexistant : `bounced` et numéro supprimé |
| **Twilio** | essai d'intégration (secret `{ account_sid, auth_token }`, `sender` : numéro Twilio) puis un parcours ; numéros magiques de test de Twilio pour les refus (`+15005550001` invalide → 21211 ; destinataire ayant envoyé STOP → 21610) | `StatusCallback` demandé par message, signature `X-Twilio-Signature` sur `{public_url}/api/v1/notification/webhooks/{intégration}` | SMS reçu ; `delivered` enregistré ; 21211 : numéro supprimé (rejet définitif) ; 21610 : numéro supprimé (plainte) ; signature valide acceptée derrière le mandataire inverse réel (même adresse publique), altérée refusée |
| **Vonage** | essai d'intégration (secret `{ api_key, api_secret }`) ; un texte avec accents hors GSM (`type=unicode`) et un texte de 3 parties | accusés de livraison signés (méthode « HMAC SHA-256 » du compte, secret `{ signature_secret }`), en POST JSON puis en formulaire | SMS reçu ; état `0` lu ; accusé `delivered` rattaché (première partie) ; signature et horodatage réels acceptés, signature altérée refusée ; codes `err-code` réels d'un numéro inexistant et d'un numéro bloqué |
| **Slack** | webhook entrant d'un salon d'essai ; essai d'intégration `chat` (`{ "to": "notification_endpoint:…" }`) puis un parcours avec une étape `chat` | — | message reçu, titre en gras ; webhook supprimé : refus définitif (404 ou 410) noté sur l'adresse |
| **Microsoft Teams** | connecteur `*.webhook.office.com` (s'il existe encore) **et** flux Power Automate « Publier dans un canal lorsqu'une requête webhook est reçue » (`*.logic.azure.com` ou `*.environment.api.powerplatform.com`) | — | carte adaptative affichée (titre, texte) ; hôte réel du flux accepté par la liste officielle ; réponse `202` traitée comme livrée |
| **Discord** | webhook d'un salon d'essai | — | message reçu, aucune mention déclenchée (`@everyone` dans le texte reste du texte) ; texte de plus de 2 000 caractères coupé |
| **Mattermost** | webhook entrant d'un serveur public ; puis le même hôte hors de `allowed_hosts` | — | message reçu ; hôte hors liste refusé (`NOTIFICATION_DESTINATION_FORBIDDEN`) sans appel |
| **Google Chat** | webhook d'un espace d'essai | — | message reçu ; identifiant `spaces/…/messages/…` noté sur le message |
| **Telegram** | robot d'essai (secret `{ bot_token }`), salon de groupe (`chat_id` négatif) et canal public (`@nom`) | — | message reçu ; robot bloqué ou salon introuvable : refus définitif (403, 400) ; `retry_after` d'un 429 : nouvel essai |
| **Adresse web** | adresse d'essai publique en HTTPS (ex. service de capture de requêtes) ; puis une adresse qui redirige et une adresse qui répond 410 | — | corps et en-têtes `Lyxal-Signature`, `Lyxal-Delivery` reçus et signature vérifiée par un script du destinataire avec la clé montrée ; redirection non suivie (nouvel essai) ; 410 : refus définitif ; nom résolu en adresse privée (enregistrement DNS d'essai) : refusé sans appel |

## Limites connues

* **Relais SMTP d'une organisation** : hôte contrôlé à l'enregistrement (ni adresse IP, ni hôte
  local, ni relais en clair) mais pas après résolution DNS ; le contrôle après résolution des
  messageries et adresses web (`OutboundClient`) pourra s'y appliquer.
* **Connexions SMTP** : une connexion par envoi ; un groupe de connexions par intégration
  viendra si le débit l'exige.
* **Appels sortants contrôlés** : un client HTTP par appel (connexion à l'adresse vérifiée) ;
  aucun mandataire sortant possible pour les messageries et adresses web (il ferait sa propre
  résolution) : à revoir si une installation impose un mandataire.
* **Parties d'un SMS** : comptage simple (sans tenir compte d'un caractère d'extension coupé
  entre deux parties) ; à l'enregistrement, le texte du gabarit tel qu'écrit est compté (le
  texte rendu est recompté avant l'envoi).
* **Modifier l'adresse** d'une messagerie ou d'une adresse web : en créer une autre (seuls le
  nom, l'état et le salon Telegram se modifient).

## Points à décider par le CTO

1. **Webhooks sortants** : dans ce module, ou dans un module commun à tous les producteurs.
2. **Environnements** : remplacés par brouillon / publication avec révisions (à confirmer).
3. **Courrier entrant** : serveur SMTP entrant, relais par un fournisseur, ou abandon.
4. **Étape HTTP** : hôtes autorisés par locataire (protection SSRF) avant toute activation.
