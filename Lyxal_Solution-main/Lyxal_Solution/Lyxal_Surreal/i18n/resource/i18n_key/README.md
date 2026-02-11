### builder_translate — Inventaire

#### Fonctions du module
- fn::builder_i18n_key_create
- fn::builder_i18n_key_get_by_code
- fn::builder_i18n_key_verify_unicity
- fn::builder_i18n_key_delete_record
- fn::builder_i18n_language_verify_id_active
- fn::builder_i18n_translation_create
- fn::builder_i18n_translation_get
- fn::builder_i18n_translation_list
- fn::builder_i18n_translation_update_text
- fn::builder_i18n_translation_delete_edges

#### Fonctions utilisées par ce module (uniques)
- fn::builder_user_verify_id
- fn::builder_log_create_record
- fn::builder_error_get_by_code
- fn::builder_i18n_translation_get
- fn::builder_i18n_key_get_by_code
- fn::builder_i18n_language_verify_id_active
- fn::builder_i18n_translation_delete_edges

#### Codes d'erreur à implémenter/valider
- I18N_KEY_CREATED
- I18N_KEY_FAILED
- I18N_KEY_DELETED
- KEY.I18N.FOUND
- KEY.I18N.NOT.FOUND
- CODE.I18N.KEY.VALID
- CODE.I18N.KEY.ALREADY.EXISTS
- LANGUE_NOT_FOUND
- LANGUE_NOT_ACTIVE
- LANGUE_FOUND
- I18N_TRANSLATION_CREATED
- I18N_TRANSLATION_FAILED
- I18N_TRANSLATION_ALREADY_EXISTS
- I18N_TRANSLATION_FOUND
- I18N_TRANSLATION_NOT_FOUND
- I18N_TRANSLATION_DELETED
- I18N_TRANSLATION_LIST_SUCCESS
- I18N_TRANSLATION_LIST_FAILED
- I18N_TRANSLATION_UPDATED
- I18N_TRANSLATION_UPDATE_FAILED
- ETAG.MISMATCH
- TEXT.EMPTY
- DELETE.PARTIAL
- EDGES.EMPTY


