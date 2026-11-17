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
