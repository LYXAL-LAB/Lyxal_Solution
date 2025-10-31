CREATE error_code:identity_field_email_format_invalid SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_field_email_format_invalid') };

CREATE error_code:identity_field_first_name_required SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_field_first_name_required') };

CREATE error_code:identity_field_last_name_required SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_field_last_name_required') };

CREATE error_code:identity_email_already_exists SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_email_already_exists') };

CREATE error_code:identity_password_too_weak SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_password_too_weak') };

CREATE error_code:identity_email_already_exists SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_email_already_exists') };

CREATE error_code:identity_created_successfully SET
    severity = type::record('error_severity', 'success'),
    success_result = true,
    i18n = { message: type::record('i18n_key', 'identity_created_successfully') };

CREATE error_code:identity_user_not_found SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_user_not_found') };

CREATE error_code:identity_invalid_token SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_invalid_token') };

CREATE error_code:identity_token_expired SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_token_expired') };

CREATE error_code:identity_email_verified_successfully SET
    severity = type::record('error_severity', 'success'),
    success_result = true,
    i18n = { message: type::record('i18n_key', 'identity_email_verified_successfully') };

CREATE error_code:identity_account_not_verified SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_account_not_verified') };

CREATE error_code:identity_authenticated_successfully SET
    severity = type::record('error_severity', 'success'),
    success_result = true,
    i18n = { message: type::record('i18n_key', 'identity_authenticated_successfully') };

CREATE error_code:identity_invalid_credentials SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_invalid_credentials') };

CREATE error_code:identity_access_denied SET
    severity = type::record('error_severity', 'error'),
    success_result = false,
    i18n = { message: type::record('i18n_key', 'identity_access_denied') };