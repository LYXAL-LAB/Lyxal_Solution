DEFINE FUNCTION OVERWRITE fn::booking_get_runtime_settings(
    $params: object
) {
    LET $base = (SELECT VALUE value FROM ONLY booking_setting:base_url).value;
    LET $allow = (SELECT VALUE value FROM ONLY booking_setting:allow_private_hosts).value;

    RETURN fn::result_ok({
        base_url: $base,
        allow_private_hosts: $allow
    });
};
