# Feuille de route — `lyxal_notification`

Évolutions à venir ; l'état actuel est décrit par [`README.md`](README.md). Correspondance
détaillée avec Novu : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) §1 et §2. Chaque lot démarre sur
ordre du CTO avec un `implementation_plan.md` validé.

| Lot | Contenu | Prérequis |
| :--- | :--- | :--- |
| **V1-d — Fil in-app** | États, compteurs, actions, onglets, snooze, temps réel ; valeur « lu » d'un message du fil fournie aux conditions d'étape (« sauter si déjà lu », décision C6) | point 1 |
| **V1-e — Autres canaux** | Sur les intégrations existantes (`notification_integration`, identifiants dans `lyxal_secrets`) : SMS (Brevo, Twilio, Vonage), messageries d'équipe et appel signé d'une adresse web (lot 4 du programme), puis push (lot 6, point 4) ; choix de l'intégration dans les surcharges d'un déclenchement (décision C5) ; fournisseurs e-mail Amazon SES, SendGrid et OVHcloud (signatures RSA ou SHA-1 à vérifier, K5) | `lyxal_crypto` (K8) pour Twilio et le push |
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

## Limites connues du lot 3 (intégrations)

* **Relais SMTP d'une organisation** : hôte contrôlé à l'enregistrement (ni adresse IP, ni hôte
  local, ni relais en clair) mais pas après résolution DNS ; le contrôle après résolution de K7
  (lot 4) pourra s'y appliquer.
* **Connexions SMTP** : une connexion par envoi ; un groupe de connexions par intégration
  viendra si le débit l'exige.

## Points à décider par le CTO

1. **Webhooks sortants** : dans ce module, ou dans un module commun à tous les producteurs.
2. **Environnements** : remplacés par brouillon / publication avec révisions (à confirmer).
3. **Courrier entrant** : serveur SMTP entrant, relais par un fournisseur, ou abandon.
4. **Étape HTTP** : hôtes autorisés par locataire (protection SSRF) avant toute activation.
