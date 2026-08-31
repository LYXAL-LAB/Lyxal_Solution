-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_set_runtime_setting                                        │
-- │  Mise à jour d'un paramètre de configuration publique (base_url, etc.)  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_set_runtime_setting($params: object) {
    LET $key = $params.key;
    LET $value = $params.value;

    IF $key == NONE OR string::len(string::trim(type::string($key))) == 0 {
        THROW "Parameter 'key' is required";
    };

    LET $clean_key = string::trim(type::string($key));
    LET $record_id = type::record(type::string("booking_setting:") + $clean_key);

    UPSERT ONLY $record_id CONTENT {
        value: $value,
        updated_at: time::now()
    };

    RETURN {
        key: $clean_key,
        updated: true
    };
} COMMENT "Mise à jour d'une configuration publique dans booking_setting";
