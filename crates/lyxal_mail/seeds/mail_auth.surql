-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- SEEDS : permissions lyxal_auth du courrier
-- MODULE : lyxal_mail
-- ============================================================================
-- Rejouable et non destructif : permissions et attributions créées seulement si elles n'existent
-- pas. mail.mailbox.access est utilisable par un mot de passe d'application (IMAP, POP3, SMTP
-- authentifié). mail.domain.manage ne donne jamais le contenu des boîtes (décision M11). Les
-- permissions mail.worker et mail.relay ne sont attribuées à aucun rôle : elles sont réservées aux
-- comptes de service.

IF !record::exists(auth_permission:⟨mail.mailbox.access⟩) THEN (
    CREATE auth_permission:⟨mail.mailbox.access⟩ CONTENT { code: "mail.mailbox.access", module: "lyxal_mail", scope: "organization", app_password: true, description: { fr: "Lire et écrire sa propre boîte de courrier : dossiers, messages, drapeaux, dépôt, quota", en: "Read and write one's own mailbox: folders, messages, flags, deposit, quota" } }
) END;

IF !record::exists(auth_permission:⟨mail.domain.manage⟩) THEN (
    CREATE auth_permission:⟨mail.domain.manage⟩ CONTENT { code: "mail.domain.manage", module: "lyxal_mail", scope: "organization", description: { fr: "Gérer les domaines, comptes, adresses, alias et réglages de courrier de son organisation, jamais le contenu des boîtes", en: "Manage one's organization mail domains, accounts, addresses, aliases and settings, never mailbox content" } }
) END;

IF !record::exists(auth_permission:⟨mail.installation.manage⟩) THEN (
    CREATE auth_permission:⟨mail.installation.manage⟩ CONTENT { code: "mail.installation.manage", module: "lyxal_mail", scope: "installation", description: { fr: "Gérer les réglages de courrier de l'installation", en: "Manage the installation mail settings" } }
) END;

IF !record::exists(auth_permission:⟨mail.worker⟩) THEN (
    CREATE auth_permission:⟨mail.worker⟩ CONTENT { code: "mail.worker", module: "lyxal_mail", scope: "installation", description: { fr: "Compte de service du courrier : résolution d'adresse, dépôt dans tout compte, maintenance", en: "Mail service account: address resolution, deposit into any account, maintenance" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_member AND out = auth_permission:⟨mail.mailbox.access⟩) = 0 THEN (
    RELATE auth_role:organization_member->auth_role_grants->auth_permission:⟨mail.mailbox.access⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨mail.mailbox.access⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨mail.mailbox.access⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨mail.domain.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨mail.domain.manage⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨mail.installation.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨mail.installation.manage⟩
) END;

-- Envoi (lot 6, §14.6) : mail.send donne d'envoyer sous ses propres adresses (dépôt authentifié,
-- utilisable par un mot de passe d'application), de lire et d'annuler ses envois ; mail.relay,
-- réservée au compte de service d'un module (aucun rôle), de déposer par le contrat public sous
-- les expéditeurs des modules d'un domaine.

IF !record::exists(auth_permission:⟨mail.send⟩) THEN (
    CREATE auth_permission:⟨mail.send⟩ CONTENT { code: "mail.send", module: "lyxal_mail", scope: "organization", app_password: true, description: { fr: "Envoyer du courrier sous ses propres adresses ; lire et annuler ses envois", en: "Send mail under one's own addresses; read and cancel one's submissions" } }
) END;

IF !record::exists(auth_permission:⟨mail.relay⟩) THEN (
    CREATE auth_permission:⟨mail.relay⟩ CONTENT { code: "mail.relay", module: "lyxal_mail", scope: "installation", description: { fr: "Compte de service d'un module : déposer du courrier sous les expéditeurs des modules d'un domaine, lire et annuler ces envois", en: "Module service account: submit mail under a domain's module senders, read and cancel these submissions" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_member AND out = auth_permission:⟨mail.send⟩) = 0 THEN (
    RELATE auth_role:organization_member->auth_role_grants->auth_permission:⟨mail.send⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨mail.send⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨mail.send⟩
) END;
