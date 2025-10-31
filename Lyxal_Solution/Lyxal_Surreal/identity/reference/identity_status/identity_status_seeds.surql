CREATE identity_status:active SET
    code = 'active',
    name_i18n_key = i18n_key:identity_status_active_name,
    description_i18n_key = i18n_key:identity_status_active_description,
    is_active = true,
    sort_order = 1;

CREATE identity_status:suspended SET
    code = 'suspended',
    name_i18n_key = i18n_key:identity_status_suspended_name,
    description_i18n_key = i18n_key:identity_status_suspended_description,
    is_active = true,
    sort_order = 2;

CREATE identity_status:deleted SET
    code = 'deleted',
    name_i18n_key = i18n_key:identity_status_deleted_name,
    description_i18n_key = i18n_key:identity_status_deleted_description,
    is_active = true,
    sort_order = 3;

CREATE identity_status:archived SET
    code = 'archived',
    name_i18n_key = i18n_key:identity_status_archived_name,
    description_i18n_key = i18n_key:identity_status_archived_description,
    is_active = true,
    sort_order = 4;

CREATE identity_status:pending SET
    code = 'pending',
    name_i18n_key = i18n_key:identity_status_pending_name,
    description_i18n_key = i18n_key:identity_status_pending_description,
    is_active = true,
    sort_order = 5;

CREATE identity_status:verified SET
    code = 'verified',
    name_i18n_key = i18n_key:identity_status_verified_name,
    description_i18n_key = i18n_key:identity_status_verified_description,
    is_active = true,   
    sort_order = 6;

CREATE identity_status:expired SET
    code = 'expired',
    name_i18n_key = i18n_key:identity_status_expired_name,
    description_i18n_key = i18n_key:identity_status_expired_description,
    is_active = true,
    sort_order = 7;

CREATE identity_status:created SET
    code = 'created',
    name_i18n_key = i18n_key:identity_status_created_name,
    description_i18n_key = i18n_key:identity_status_created_description,
    is_active = true,
    sort_order = 8;