-- ============================================================================
-- SEEDS : textes des e-mails du système (clés lyxal_i18n)
-- MODULE : lyxal_notification
-- TABLES : i18n_namespace, i18n_key, i18n_translation
-- ============================================================================
-- Rejouable et non destructif (CREATE protégé par record::exists) : un texte existant n'est pas
-- modifié. Espace de noms notification, langue source fr, traduction anglaise fournie. Les
-- gabarits (notification_initial.surql) appellent ces clés par t("clé"). Tous les champs sont
-- écrits, y compris ceux que la base calcule, pour une installation par import (OPTION IMPORT).

IF !record::exists(i18n_namespace:notification) THEN (
    CREATE i18n_namespace:notification CONTENT { key: "notification", module: "lyxal_notification", description: "Textes des e-mails du système", source_locale: i18n_locale:⟨fr⟩, created_at: time::now(), updated_at: time::now() }
) END;

-- common
IF !record::exists(i18n_key:⟨notification.common.greeting⟩) THEN (
    CREATE i18n_key:⟨notification.common.greeting⟩ CONTENT { namespace: i18n_namespace:notification, name: "common.greeting", full_key: "notification.common.greeting", description: "Salutation sans nom", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.common.greeting", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.common.greeting", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.common.greeting⟩, locale: i18n_locale:⟨fr⟩, text: "Bonjour,", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Bonjour,"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.common.greeting", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.common.greeting", "en", "installation"] CONTENT { key: i18n_key:⟨notification.common.greeting⟩, locale: i18n_locale:⟨en⟩, text: "Hello,", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Bonjour,"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.common.greeting_named⟩) THEN (
    CREATE i18n_key:⟨notification.common.greeting_named⟩ CONTENT { namespace: i18n_namespace:notification, name: "common.greeting_named", full_key: "notification.common.greeting_named", description: "Salutation avec le nom du destinataire", params: [{ name: "name", type: "string" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.common.greeting_named", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.common.greeting_named", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.common.greeting_named⟩, locale: i18n_locale:⟨fr⟩, text: "Bonjour {name},", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Bonjour {name},"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.common.greeting_named", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.common.greeting_named", "en", "installation"] CONTENT { key: i18n_key:⟨notification.common.greeting_named⟩, locale: i18n_locale:⟨en⟩, text: "Hello {name},", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Bonjour {name},"), created_at: time::now(), updated_at: time::now() }
) END;

-- auth_verification
IF !record::exists(i18n_key:⟨notification.auth_verification.subject⟩) THEN (
    CREATE i18n_key:⟨notification.auth_verification.subject⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_verification.subject", full_key: "notification.auth_verification.subject", description: "Objet", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.subject", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.subject", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.subject⟩, locale: i18n_locale:⟨fr⟩, text: "Confirmez votre adresse e-mail", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Confirmez votre adresse e-mail"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.subject", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.subject", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.subject⟩, locale: i18n_locale:⟨en⟩, text: "Confirm your email address", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Confirmez votre adresse e-mail"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_verification.intro⟩) THEN (
    CREATE i18n_key:⟨notification.auth_verification.intro⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_verification.intro", full_key: "notification.auth_verification.intro", description: "Avant le code et le lien", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.intro", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.intro", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.intro⟩, locale: i18n_locale:⟨fr⟩, text: "Pour confirmer votre adresse e-mail, utilisez le code ci-dessous ou ouvrez le lien.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pour confirmer votre adresse e-mail, utilisez le code ci-dessous ou ouvrez le lien."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.intro", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.intro", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.intro⟩, locale: i18n_locale:⟨en⟩, text: "To confirm your email address, use the code below or open the link.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pour confirmer votre adresse e-mail, utilisez le code ci-dessous ou ouvrez le lien."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_verification.action⟩) THEN (
    CREATE i18n_key:⟨notification.auth_verification.action⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_verification.action", full_key: "notification.auth_verification.action", description: "Texte du lien", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.action", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.action", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.action⟩, locale: i18n_locale:⟨fr⟩, text: "Confirmer mon adresse", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Confirmer mon adresse"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.action", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.action", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.action⟩, locale: i18n_locale:⟨en⟩, text: "Confirm my address", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Confirmer mon adresse"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_verification.ignore⟩) THEN (
    CREATE i18n_key:⟨notification.auth_verification.ignore⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_verification.ignore", full_key: "notification.auth_verification.ignore", description: "Fin du message", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.ignore", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.ignore", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.ignore⟩, locale: i18n_locale:⟨fr⟩, text: "Si vous n'êtes pas à l'origine de cette demande, ignorez ce message.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous n'êtes pas à l'origine de cette demande, ignorez ce message."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_verification.ignore", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_verification.ignore", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_verification.ignore⟩, locale: i18n_locale:⟨en⟩, text: "If you did not request this, ignore this message.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous n'êtes pas à l'origine de cette demande, ignorez ce message."), created_at: time::now(), updated_at: time::now() }
) END;

-- auth_recovery
IF !record::exists(i18n_key:⟨notification.auth_recovery.subject⟩) THEN (
    CREATE i18n_key:⟨notification.auth_recovery.subject⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_recovery.subject", full_key: "notification.auth_recovery.subject", description: "Objet", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.subject", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.subject", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.subject⟩, locale: i18n_locale:⟨fr⟩, text: "Récupération de votre compte", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Récupération de votre compte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.subject", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.subject", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.subject⟩, locale: i18n_locale:⟨en⟩, text: "Recover your account", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Récupération de votre compte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_recovery.intro⟩) THEN (
    CREATE i18n_key:⟨notification.auth_recovery.intro⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_recovery.intro", full_key: "notification.auth_recovery.intro", description: "Avant le code et le lien", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.intro", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.intro", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.intro⟩, locale: i18n_locale:⟨fr⟩, text: "Pour récupérer l'accès à votre compte, utilisez le code ci-dessous ou ouvrez le lien.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pour récupérer l'accès à votre compte, utilisez le code ci-dessous ou ouvrez le lien."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.intro", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.intro", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.intro⟩, locale: i18n_locale:⟨en⟩, text: "To recover access to your account, use the code below or open the link.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pour récupérer l'accès à votre compte, utilisez le code ci-dessous ou ouvrez le lien."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_recovery.action⟩) THEN (
    CREATE i18n_key:⟨notification.auth_recovery.action⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_recovery.action", full_key: "notification.auth_recovery.action", description: "Texte du lien", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.action", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.action", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.action⟩, locale: i18n_locale:⟨fr⟩, text: "Récupérer mon compte", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Récupérer mon compte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.action", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.action", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.action⟩, locale: i18n_locale:⟨en⟩, text: "Recover my account", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Récupérer mon compte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_recovery.ignore⟩) THEN (
    CREATE i18n_key:⟨notification.auth_recovery.ignore⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_recovery.ignore", full_key: "notification.auth_recovery.ignore", description: "Fin du message", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.ignore", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.ignore", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.ignore⟩, locale: i18n_locale:⟨fr⟩, text: "Si vous n'êtes pas à l'origine de cette demande, ignorez ce message : votre mot de passe reste inchangé.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous n'êtes pas à l'origine de cette demande, ignorez ce message : votre mot de passe reste inchangé."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_recovery.ignore", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_recovery.ignore", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_recovery.ignore⟩, locale: i18n_locale:⟨en⟩, text: "If you did not request this, ignore this message: your password is unchanged.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous n'êtes pas à l'origine de cette demande, ignorez ce message : votre mot de passe reste inchangé."), created_at: time::now(), updated_at: time::now() }
) END;

-- auth_invitation
IF !record::exists(i18n_key:⟨notification.auth_invitation.subject⟩) THEN (
    CREATE i18n_key:⟨notification.auth_invitation.subject⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_invitation.subject", full_key: "notification.auth_invitation.subject", description: "Objet", params: [{ name: "organization", type: "string" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.subject", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.subject", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.subject⟩, locale: i18n_locale:⟨fr⟩, text: "Invitation à rejoindre {organization}", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Invitation à rejoindre {organization}"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.subject", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.subject", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.subject⟩, locale: i18n_locale:⟨en⟩, text: "Invitation to join {organization}", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Invitation à rejoindre {organization}"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_invitation.intro⟩) THEN (
    CREATE i18n_key:⟨notification.auth_invitation.intro⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_invitation.intro", full_key: "notification.auth_invitation.intro", description: "Invitation sans nom de l'invitant", params: [{ name: "organization", type: "string" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.intro", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.intro", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.intro⟩, locale: i18n_locale:⟨fr⟩, text: "Vous êtes invité à rejoindre l'organisation {organization}.", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Vous êtes invité à rejoindre l'organisation {organization}."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.intro", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.intro", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.intro⟩, locale: i18n_locale:⟨en⟩, text: "You are invited to join the organization {organization}.", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Vous êtes invité à rejoindre l'organisation {organization}."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_invitation.intro_by⟩) THEN (
    CREATE i18n_key:⟨notification.auth_invitation.intro_by⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_invitation.intro_by", full_key: "notification.auth_invitation.intro_by", description: "Invitation avec le nom de l'invitant", params: [{ name: "inviter", type: "string" }, { name: "organization", type: "string" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.intro_by", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.intro_by", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.intro_by⟩, locale: i18n_locale:⟨fr⟩, text: "{inviter} vous invite à rejoindre l'organisation {organization}.", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("{inviter} vous invite à rejoindre l'organisation {organization}."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.intro_by", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.intro_by", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.intro_by⟩, locale: i18n_locale:⟨en⟩, text: "{inviter} invites you to join the organization {organization}.", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("{inviter} vous invite à rejoindre l'organisation {organization}."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_invitation.action⟩) THEN (
    CREATE i18n_key:⟨notification.auth_invitation.action⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_invitation.action", full_key: "notification.auth_invitation.action", description: "Texte du lien", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.action", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.action", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.action⟩, locale: i18n_locale:⟨fr⟩, text: "Accepter l'invitation", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Accepter l'invitation"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.action", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.action", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.action⟩, locale: i18n_locale:⟨en⟩, text: "Accept the invitation", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Accepter l'invitation"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_invitation.ignore⟩) THEN (
    CREATE i18n_key:⟨notification.auth_invitation.ignore⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_invitation.ignore", full_key: "notification.auth_invitation.ignore", description: "Fin du message", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.ignore", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.ignore", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.ignore⟩, locale: i18n_locale:⟨fr⟩, text: "Si vous ne vous attendiez pas à cette invitation, ignorez ce message.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous ne vous attendiez pas à cette invitation, ignorez ce message."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_invitation.ignore", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_invitation.ignore", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_invitation.ignore⟩, locale: i18n_locale:⟨en⟩, text: "If you were not expecting this invitation, ignore this message.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous ne vous attendiez pas à cette invitation, ignorez ce message."), created_at: time::now(), updated_at: time::now() }
) END;

-- auth_security_alert
IF !record::exists(i18n_key:⟨notification.auth_security_alert.subject⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.subject⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.subject", full_key: "notification.auth_security_alert.subject", description: "Objet", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.subject", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.subject", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.subject⟩, locale: i18n_locale:⟨fr⟩, text: "Alerte de sécurité sur votre compte", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Alerte de sécurité sur votre compte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.subject", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.subject", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.subject⟩, locale: i18n_locale:⟨en⟩, text: "Security alert on your account", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Alerte de sécurité sur votre compte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.mfa_enrolled_totp⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.mfa_enrolled_totp⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.mfa_enrolled_totp", full_key: "notification.auth_security_alert.mfa_enrolled_totp", description: "Second facteur ajouté (application)", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_enrolled_totp", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_enrolled_totp", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_enrolled_totp⟩, locale: i18n_locale:⟨fr⟩, text: "Un second facteur a été ajouté à votre compte : application d'authentification.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été ajouté à votre compte : application d'authentification."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_enrolled_totp", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_enrolled_totp", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_enrolled_totp⟩, locale: i18n_locale:⟨en⟩, text: "A second factor was added to your account: authenticator app.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été ajouté à votre compte : application d'authentification."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.mfa_enrolled_passkey", full_key: "notification.auth_security_alert.mfa_enrolled_passkey", description: "Second facteur ajouté (passkey sans nom)", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey⟩, locale: i18n_locale:⟨fr⟩, text: "Un second facteur a été ajouté à votre compte : passkey.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été ajouté à votre compte : passkey."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey⟩, locale: i18n_locale:⟨en⟩, text: "A second factor was added to your account: passkey.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été ajouté à votre compte : passkey."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey_named⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey_named⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.mfa_enrolled_passkey_named", full_key: "notification.auth_security_alert.mfa_enrolled_passkey_named", description: "Second facteur ajouté (passkey nommée)", params: [{ name: "label", type: "string" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey_named", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey_named", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey_named⟩, locale: i18n_locale:⟨fr⟩, text: "Un second facteur a été ajouté à votre compte : passkey « {label} ».", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été ajouté à votre compte : passkey « {label} »."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey_named", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_enrolled_passkey_named", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_enrolled_passkey_named⟩, locale: i18n_locale:⟨en⟩, text: "A second factor was added to your account: passkey “{label}”.", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été ajouté à votre compte : passkey « {label} »."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.mfa_removed_admin⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.mfa_removed_admin⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.mfa_removed_admin", full_key: "notification.auth_security_alert.mfa_removed_admin", description: "Seconds facteurs retirés par un administrateur", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_admin", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_admin", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_admin⟩, locale: i18n_locale:⟨fr⟩, text: "Un administrateur a retiré tous les seconds facteurs de votre compte ; vos sessions ont été fermées.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un administrateur a retiré tous les seconds facteurs de votre compte ; vos sessions ont été fermées."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_admin", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_admin", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_admin⟩, locale: i18n_locale:⟨en⟩, text: "An administrator removed all second factors from your account; your sessions were closed.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un administrateur a retiré tous les seconds facteurs de votre compte ; vos sessions ont été fermées."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.mfa_removed_totp⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.mfa_removed_totp⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.mfa_removed_totp", full_key: "notification.auth_security_alert.mfa_removed_totp", description: "Second facteur retiré (application)", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_totp", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_totp", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_totp⟩, locale: i18n_locale:⟨fr⟩, text: "Un second facteur a été retiré de votre compte : application d'authentification.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été retiré de votre compte : application d'authentification."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_totp", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_totp", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_totp⟩, locale: i18n_locale:⟨en⟩, text: "A second factor was removed from your account: authenticator app.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été retiré de votre compte : application d'authentification."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.mfa_removed_passkey", full_key: "notification.auth_security_alert.mfa_removed_passkey", description: "Second facteur retiré (passkey sans nom)", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_passkey", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_passkey", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey⟩, locale: i18n_locale:⟨fr⟩, text: "Un second facteur a été retiré de votre compte : passkey.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été retiré de votre compte : passkey."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_passkey", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_passkey", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey⟩, locale: i18n_locale:⟨en⟩, text: "A second factor was removed from your account: passkey.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été retiré de votre compte : passkey."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey_named⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey_named⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.mfa_removed_passkey_named", full_key: "notification.auth_security_alert.mfa_removed_passkey_named", description: "Second facteur retiré (passkey nommée)", params: [{ name: "label", type: "string" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_passkey_named", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_passkey_named", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey_named⟩, locale: i18n_locale:⟨fr⟩, text: "Un second facteur a été retiré de votre compte : passkey « {label} ».", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été retiré de votre compte : passkey « {label} »."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.mfa_removed_passkey_named", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.mfa_removed_passkey_named", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.mfa_removed_passkey_named⟩, locale: i18n_locale:⟨en⟩, text: "A second factor was removed from your account: passkey “{label}”.", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un second facteur a été retiré de votre compte : passkey « {label} »."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.recovery_codes_generated⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.recovery_codes_generated⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.recovery_codes_generated", full_key: "notification.auth_security_alert.recovery_codes_generated", description: "Codes de secours régénérés", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.recovery_codes_generated", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.recovery_codes_generated", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.recovery_codes_generated⟩, locale: i18n_locale:⟨fr⟩, text: "De nouveaux codes de secours ont été générés ; les précédents ne fonctionnent plus.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("De nouveaux codes de secours ont été générés ; les précédents ne fonctionnent plus."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.recovery_codes_generated", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.recovery_codes_generated", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.recovery_codes_generated⟩, locale: i18n_locale:⟨en⟩, text: "New recovery codes were generated; the previous ones no longer work.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("De nouveaux codes de secours ont été générés ; les précédents ne fonctionnent plus."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.recovery_code_used⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.recovery_code_used⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.recovery_code_used", full_key: "notification.auth_security_alert.recovery_code_used", description: "Code de secours utilisé, nombre restant", params: [{ name: "remaining", type: "number" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.recovery_code_used", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.recovery_code_used", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.recovery_code_used⟩, locale: i18n_locale:⟨fr⟩, text: "Un code de secours a été utilisé pour vous connecter. {remaining, plural, =0 {Il ne vous en reste aucun.} one {Il vous en reste #.} other {Il vous en reste #.}}", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un code de secours a été utilisé pour vous connecter. {remaining, plural, =0 {Il ne vous en reste aucun.} one {Il vous en reste #.} other {Il vous en reste #.}}"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.recovery_code_used", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.recovery_code_used", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.recovery_code_used⟩, locale: i18n_locale:⟨en⟩, text: "A recovery code was used to sign in. {remaining, plural, =0 {You have none left.} one {You have # left.} other {You have # left.}}", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Un code de secours a été utilisé pour vous connecter. {remaining, plural, =0 {Il ne vous en reste aucun.} one {Il vous en reste #.} other {Il vous en reste #.}}"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.password_changed⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.password_changed⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.password_changed", full_key: "notification.auth_security_alert.password_changed", description: "Mot de passe changé", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.password_changed", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.password_changed", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.password_changed⟩, locale: i18n_locale:⟨fr⟩, text: "Le mot de passe de votre compte a été changé.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Le mot de passe de votre compte a été changé."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.password_changed", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.password_changed", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.password_changed⟩, locale: i18n_locale:⟨en⟩, text: "Your account password was changed.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Le mot de passe de votre compte a été changé."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.passkey_clone_detected⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.passkey_clone_detected⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.passkey_clone_detected", full_key: "notification.auth_security_alert.passkey_clone_detected", description: "Passkey copiée (sans nom)", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.passkey_clone_detected", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.passkey_clone_detected", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.passkey_clone_detected⟩, locale: i18n_locale:⟨fr⟩, text: "Une passkey de votre compte a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Une passkey de votre compte a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.passkey_clone_detected", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.passkey_clone_detected", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.passkey_clone_detected⟩, locale: i18n_locale:⟨en⟩, text: "A passkey on your account was refused: it appears to have been copied. Remove it and register a new one.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Une passkey de votre compte a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.passkey_clone_detected_named⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.passkey_clone_detected_named⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.passkey_clone_detected_named", full_key: "notification.auth_security_alert.passkey_clone_detected_named", description: "Passkey copiée (nommée)", params: [{ name: "label", type: "string" }], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.passkey_clone_detected_named", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.passkey_clone_detected_named", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.passkey_clone_detected_named⟩, locale: i18n_locale:⟨fr⟩, text: "Une passkey de votre compte (« {label} ») a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle.", syntax: "icu_mf1", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Une passkey de votre compte (« {label} ») a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.passkey_clone_detected_named", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.passkey_clone_detected_named", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.passkey_clone_detected_named⟩, locale: i18n_locale:⟨en⟩, text: "A passkey on your account (“{label}”) was refused: it appears to have been copied. Remove it and register a new one.", syntax: "icu_mf1", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Une passkey de votre compte (« {label} ») a été refusée : elle semble avoir été copiée. Retirez-la et enregistrez-en une nouvelle."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_key:⟨notification.auth_security_alert.advice⟩) THEN (
    CREATE i18n_key:⟨notification.auth_security_alert.advice⟩ CONTENT { namespace: i18n_namespace:notification, name: "auth_security_alert.advice", full_key: "notification.auth_security_alert.advice", description: "Fin du message", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.advice", "fr", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.advice", "fr", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.advice⟩, locale: i18n_locale:⟨fr⟩, text: "Si vous n'êtes pas à l'origine de cette action, changez votre mot de passe et prévenez votre administrateur.", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous n'êtes pas à l'origine de cette action, changez votre mot de passe et prévenez votre administrateur."), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["notification.auth_security_alert.advice", "en", "installation"]) THEN (
    CREATE i18n_translation:["notification.auth_security_alert.advice", "en", "installation"] CONTENT { key: i18n_key:⟨notification.auth_security_alert.advice⟩, locale: i18n_locale:⟨en⟩, text: "If you did not do this, change your password and tell your administrator.", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Si vous n'êtes pas à l'origine de cette action, changez votre mot de passe et prévenez votre administrateur."), created_at: time::now(), updated_at: time::now() }
) END;
