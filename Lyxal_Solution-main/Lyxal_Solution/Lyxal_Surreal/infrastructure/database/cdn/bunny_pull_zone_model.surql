-- Table: bunny_pull_zone_model
-- Source: PullZoneModel
-- Description: Table pour PullZoneModel

DEFINE TABLE IF NOT EXISTS bunny_pull_zone_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour PullZoneModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The unique ID of the pull zone.';

DEFINE FIELD IF NOT EXISTS name ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The name of the pull zone.';

DEFINE FIELD IF NOT EXISTS origin_url ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The origin URL of the pull zone where the files are fetched from.';

DEFINE FIELD IF NOT EXISTS enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'True unless reached resource limits or account owning it ran out of funds.';

DEFINE FIELD IF NOT EXISTS suspended ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS hostnames ON bunny_pull_zone_model
  TYPE option<array<option<record<hostname_model>>>>
  COMMENT 'The list of hostnames linked to this Pull Zone';

DEFINE FIELD IF NOT EXISTS storage_zone_id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the storage zone that the pull zone is linked to';

DEFINE FIELD IF NOT EXISTS edge_script_id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the edge script that the pull zone is linked to';

DEFINE FIELD IF NOT EXISTS edge_script_execution_phase ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The phase of the request where the script will be executed';

DEFINE FIELD IF NOT EXISTS middleware_script_id ON bunny_pull_zone_model
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS magic_containers_app_id ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The ID of the Magic Container application the pull zone is linked to';

DEFINE FIELD IF NOT EXISTS magic_containers_endpoint_id ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The ID of the Magic Container Endpoint the pull zone is linked to';

DEFINE FIELD IF NOT EXISTS allowed_referrers ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of referrer hostnames that are allowed to access the pull zone.Requests containing the header Referer: hostname that is not on the list will be rejected.If empty, all the referrers are allowed';

DEFINE FIELD IF NOT EXISTS blocked_referrers ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of referrer hostnames that are allowed to access the pull zone. Requests containing the header Referer: hostname that is not on the list will be rejected. If empty, all the referrers are allowed';

DEFINE FIELD IF NOT EXISTS blocked_ips ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of IPs that are blocked from accessing the pull zone. Requests coming from the following IPs will be rejected. If empty, all the IPs will be allowed';

DEFINE FIELD IF NOT EXISTS enable_geo_zone_u_s ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the delivery from the North American region is enabled for this pull zone';

DEFINE FIELD IF NOT EXISTS enable_geo_zone_e_u ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the delivery from the European region is enabled for this pull zone';

DEFINE FIELD IF NOT EXISTS enable_geo_zone_a_s_i_a ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the delivery from the Asian / Oceanian region is enabled for this pull zone';

DEFINE FIELD IF NOT EXISTS enable_geo_zone_s_a ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the delivery from the South American region is enabled for this pull zone';

DEFINE FIELD IF NOT EXISTS enable_geo_zone_a_f ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the delivery from the Africa region is enabled for this pull zone';

DEFINE FIELD IF NOT EXISTS zone_security_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'True if the URL secure token authentication security is enabled';

DEFINE FIELD IF NOT EXISTS zone_security_key ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The security key used for secure URL token authentication';

DEFINE FIELD IF NOT EXISTS zone_security_include_hash_remote_i_p ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'True if the zone security hash should include the remote IP';

DEFINE FIELD IF NOT EXISTS ignore_query_strings ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'True if the Pull Zone is ignoring query strings when serving cached objects';

DEFINE FIELD IF NOT EXISTS monthly_bandwidth_limit ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The monthly limit of bandwidth in bytes that the pullzone is allowed to use';

DEFINE FIELD IF NOT EXISTS monthly_bandwidth_used ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The amount of bandwidth in bytes that the pull zone used this month';

DEFINE FIELD IF NOT EXISTS monthly_charges ON bunny_pull_zone_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The total monthly charges for this so zone so far';

DEFINE FIELD IF NOT EXISTS add_host_header ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Pull Zone should forward the current hostname to the origin';

DEFINE FIELD IF NOT EXISTS origin_host_header ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Determines the host header that will be sent to the origin';

DEFINE FIELD IF NOT EXISTS type ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The type of the pull zone. Premium = 0, Volume = 1';

DEFINE FIELD IF NOT EXISTS access_control_origin_header_extensions ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of extensions that will return the CORS headers';

DEFINE FIELD IF NOT EXISTS enable_access_control_origin_header ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the CORS headers should be enabled';

DEFINE FIELD IF NOT EXISTS disable_cookies ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the cookies are disabled for the pull zone';

DEFINE FIELD IF NOT EXISTS budget_redirected_countries ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of budget redirected countries with the two-letter Alpha2 ISO codes';

DEFINE FIELD IF NOT EXISTS blocked_countries ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of blocked countries with the two-letter Alpha2 ISO codes';

DEFINE FIELD IF NOT EXISTS enable_origin_shield ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'If true the server will use the origin shield feature';

DEFINE FIELD IF NOT EXISTS cache_control_max_age_override ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The override cache time for the pull zone';

DEFINE FIELD IF NOT EXISTS cache_control_public_max_age_override ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The override cache time for the pull zone for the end client';

DEFINE FIELD IF NOT EXISTS burst_size ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Excessive requests are delayed until their number exceeds the maximum burst size.';

DEFINE FIELD IF NOT EXISTS request_limit ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Max number of requests per IP per second';

DEFINE FIELD IF NOT EXISTS block_root_path_access ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'If true, access to root path will return a 403 error';

DEFINE FIELD IF NOT EXISTS block_post_requests ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'If true, POST requests to the zone will be blocked';

DEFINE FIELD IF NOT EXISTS limit_rate_per_second ON bunny_pull_zone_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The maximum rate at which the zone will transfer data in kb/s. 0 for unlimited';

DEFINE FIELD IF NOT EXISTS limit_rate_after ON bunny_pull_zone_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The amount of data after the rate limit will be activated';

DEFINE FIELD IF NOT EXISTS connection_limit_per_i_p_count ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The number of connections limited per IP for this zone';

DEFINE FIELD IF NOT EXISTS price_override ON bunny_pull_zone_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The custom price override for this zone. Unit is $/Byte.';

DEFINE FIELD IF NOT EXISTS optimizer_pricing ON bunny_pull_zone_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'Monthly pricing for Bunny Optimizer for this pull zone';

DEFINE FIELD IF NOT EXISTS add_canonical_header ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Add Canonical Header is enabled for this Pull Zone';

DEFINE FIELD IF NOT EXISTS enable_logging ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the logging is enabled for this Pull Zone';

DEFINE FIELD IF NOT EXISTS enable_cache_slice ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the cache slice (Optimize for video) feature is enabled for the Pull Zone';

DEFINE FIELD IF NOT EXISTS enable_smart_cache ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if smart caching is enabled for this zone';

DEFINE FIELD IF NOT EXISTS edge_rules ON bunny_pull_zone_model
  TYPE option<array<option<record<edge_rule_v2_model>>>>
  COMMENT 'The list of edge rules on this Pull Zone';

DEFINE FIELD IF NOT EXISTS enable_web_p_vary ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the WebP Vary feature is enabled.';

DEFINE FIELD IF NOT EXISTS enable_avif_vary ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the AVIF Vary feature is enabled.';

DEFINE FIELD IF NOT EXISTS enable_country_code_vary ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Country Code Vary feature is enabled.';

DEFINE FIELD IF NOT EXISTS enable_country_state_code_vary ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Country State Code Vary feature should be enabled.';

DEFINE FIELD IF NOT EXISTS enable_mobile_vary ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Mobile Vary feature is enabled.';

DEFINE FIELD IF NOT EXISTS enable_cookie_vary ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Cookie Vary feature is enabled.';

DEFINE FIELD IF NOT EXISTS cookie_vary_parameters ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'Contains the list of vary parameters that will be used for vary cache by cookie string. If empty, cookie vary will not be used.';

DEFINE FIELD IF NOT EXISTS enable_hostname_vary ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Hostname Vary feature is enabled.';

DEFINE FIELD IF NOT EXISTS cname_domain ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The CNAME domain of the pull zone for setting up custom hostnames';

DEFINE FIELD IF NOT EXISTS a_w_s_signing_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the AWS Signing is enabled';

DEFINE FIELD IF NOT EXISTS a_w_s_signing_key ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The AWS Signing region key';

DEFINE FIELD IF NOT EXISTS a_w_s_signing_secret ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The AWS Signing region secret';

DEFINE FIELD IF NOT EXISTS a_w_s_signing_region_name ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The AWS Signing region name';

DEFINE FIELD IF NOT EXISTS logging_i_p_anonymization_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the TLS 1 is enabled on the Pull Zone';

DEFINE FIELD IF NOT EXISTS enable_t_l_s1 ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the TLS 1 is enabled on the Pull Zone';

DEFINE FIELD IF NOT EXISTS enable_t_l_s1_1 ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the TLS 1.1 is enabled on the Pull Zone';

DEFINE FIELD IF NOT EXISTS verify_origin_s_s_l ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the Pull Zone should verify the origin SSL certificate';

DEFINE FIELD IF NOT EXISTS error_page_enable_custom_code ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if custom error page code should be enabled.';

DEFINE FIELD IF NOT EXISTS error_page_custom_code ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Contains the custom error page code that will be returned';

DEFINE FIELD IF NOT EXISTS error_page_enable_statuspage_widget ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the statuspage widget should be displayed on the error pages';

DEFINE FIELD IF NOT EXISTS error_page_statuspage_code ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The statuspage code that will be used to build the status widget';

DEFINE FIELD IF NOT EXISTS error_page_whitelabel ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the error pages should be whitelabel or not';

DEFINE FIELD IF NOT EXISTS origin_shield_zone_code ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The zone code of the origin shield';

DEFINE FIELD IF NOT EXISTS log_forwarding_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the log forawrding is enabled';

DEFINE FIELD IF NOT EXISTS log_forwarding_hostname ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The log forwarding hostname';

DEFINE FIELD IF NOT EXISTS log_forwarding_port ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The log forwarding port';

DEFINE FIELD IF NOT EXISTS log_forwarding_token ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The log forwarding token value';

DEFINE FIELD IF NOT EXISTS log_forwarding_protocol ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Determines the log forwarding protocol type';

DEFINE FIELD IF NOT EXISTS logging_save_to_storage ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the permanent logging feature is enabled';

DEFINE FIELD IF NOT EXISTS logging_storage_zone_id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the logging storage zone that is configured for this Pull Zone';

DEFINE FIELD IF NOT EXISTS follow_redirects ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the zone will follow origin redirects';

DEFINE FIELD IF NOT EXISTS video_library_id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the video library that the zone is linked to';

DEFINE FIELD IF NOT EXISTS dns_record_id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the DNS record tied to this pull zone';

DEFINE FIELD IF NOT EXISTS dns_zone_id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the DNS zone tied to this pull zone';

DEFINE FIELD IF NOT EXISTS dns_record_value ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The cached version of the DNS record value';

DEFINE FIELD IF NOT EXISTS optimizer_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the optimizer should be enabled for this zone';

DEFINE FIELD IF NOT EXISTS optimizer_tunnel_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the optimizer origin tunnel system is enabled for this zone';

DEFINE FIELD IF NOT EXISTS optimizer_desktop_max_width ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the maximum automatic image size for desktop clients';

DEFINE FIELD IF NOT EXISTS optimizer_mobile_max_width ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the maximum automatic image size for mobile clients';

DEFINE FIELD IF NOT EXISTS optimizer_image_quality ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the image quality for desktop clients';

DEFINE FIELD IF NOT EXISTS optimizer_mobile_image_quality ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the image quality for mobile clients';

DEFINE FIELD IF NOT EXISTS optimizer_enable_web_p ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the WebP optimization should be enabled';

DEFINE FIELD IF NOT EXISTS optimizer_prerender_html ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the SEO HTML prerender is enabled';

DEFINE FIELD IF NOT EXISTS optimizer_enable_manipulation_engine ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines the image manipulation should be enabled';

DEFINE FIELD IF NOT EXISTS optimizer_minify_c_s_s ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the CSS minifcation should be enabled';

DEFINE FIELD IF NOT EXISTS optimizer_minify_java_script ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the JavaScript minifcation should be enabled';

DEFINE FIELD IF NOT EXISTS optimizer_watermark_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if image watermarking should be enabled';

DEFINE FIELD IF NOT EXISTS optimizer_watermark_url ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Sets the URL of the watermark image';

DEFINE FIELD IF NOT EXISTS optimizer_watermark_position ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Sets the position of the watermark image';

DEFINE FIELD IF NOT EXISTS optimizer_watermark_offset ON bunny_pull_zone_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'Sets the offset of the watermark image';

DEFINE FIELD IF NOT EXISTS optimizer_watermark_min_image_size ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Sets the minimum image size to which the watermark will be added';

DEFINE FIELD IF NOT EXISTS optimizer_automatic_optimization_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the automatic image optimization should be enabled';

DEFINE FIELD IF NOT EXISTS perma_cache_storage_zone_id ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The IP of the storage zone used for Perma-Cache';

DEFINE FIELD IF NOT EXISTS perma_cache_type ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Determines Perma-Cache behavior';

DEFINE FIELD IF NOT EXISTS origin_retries ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The number of retries to the origin server';

DEFINE FIELD IF NOT EXISTS origin_connect_timeout ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The amount of seconds to wait when connecting to the origin. Otherwise the request will fail or retry.';

DEFINE FIELD IF NOT EXISTS origin_response_timeout ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The amount of seconds to wait when waiting for the origin reply. Otherwise the request will fail or retry.';

DEFINE FIELD IF NOT EXISTS use_stale_while_updating ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if we should use stale cache while cache is updating';

DEFINE FIELD IF NOT EXISTS use_stale_while_offline ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if we should use stale cache while the origin is offline';

DEFINE FIELD IF NOT EXISTS origin_retry5_x_x_responses ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if we should retry the request in case of a 5XX response.';

DEFINE FIELD IF NOT EXISTS origin_retry_connection_timeout ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if we should retry the request in case of a connection timeout.';

DEFINE FIELD IF NOT EXISTS origin_retry_response_timeout ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if we should retry the request in case of a response timeout.';

DEFINE FIELD IF NOT EXISTS origin_retry_delay ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the amount of time that the CDN should wait before retrying an origin request.';

DEFINE FIELD IF NOT EXISTS query_string_vary_parameters ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'Contains the list of vary parameters that will be used for vary cache by query string. If empty, all parameters will be used to construct the key';

DEFINE FIELD IF NOT EXISTS origin_shield_enable_concurrency_limit ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the origin shield concurrency limit is enabled.';

DEFINE FIELD IF NOT EXISTS origin_shield_max_concurrent_requests ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the number of maximum concurrent requests allowed to the origin.';

DEFINE FIELD IF NOT EXISTS enable_safe_hop ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS cache_error_responses ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if bunny.net should be caching error responses';

DEFINE FIELD IF NOT EXISTS origin_shield_queue_max_wait_time ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the max queue wait time';

DEFINE FIELD IF NOT EXISTS origin_shield_max_queued_requests ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the max number of origin requests that will remain in the queu';

DEFINE FIELD IF NOT EXISTS optimizer_classes ON bunny_pull_zone_model
  TYPE option<array<option<record<optimizer_class_model>>>>
  COMMENT 'Contains the list of optimizer classes';

DEFINE FIELD IF NOT EXISTS optimizer_force_classes ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the optimizer class list should be enforced';

DEFINE FIELD IF NOT EXISTS optimizer_static_html_word_press_path ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Wordpress html path which should be bypassed by permacache in edge rule';

DEFINE FIELD IF NOT EXISTS optimizer_static_html_word_press_bypass_cookie ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Wordpress cookie which should be bypassed by permacache in edge rule';

DEFINE FIELD IF NOT EXISTS use_background_update ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if cache update is performed in the background.';

DEFINE FIELD IF NOT EXISTS enable_auto_s_s_l ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'If set to true, any hostnames added to this Pull Zone will automatically enable SSL.';

DEFINE FIELD IF NOT EXISTS enable_query_string_ordering ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'If set to true the query string ordering property is enabled.';

DEFINE FIELD IF NOT EXISTS log_anonymization_type ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Gets the log anonymization type for this pull zone';

DEFINE FIELD IF NOT EXISTS log_format ON bunny_pull_zone_model
  TYPE option<record<pull_zone_log_format>>
;

DEFINE FIELD IF NOT EXISTS log_forwarding_format ON bunny_pull_zone_model
  TYPE option<record<pull_zone_log_format>>
;

DEFINE FIELD IF NOT EXISTS shield_d_dos_protection_type ON bunny_pull_zone_model
  TYPE option<record<shield_d_dos_protection_type>>
;

DEFINE FIELD IF NOT EXISTS shield_d_dos_protection_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS origin_type ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The type of the origin for this Pull Zone';

DEFINE FIELD IF NOT EXISTS enable_request_coalescing ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if request coalescing is currently enabled.';

DEFINE FIELD IF NOT EXISTS request_coalescing_timeout ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Determines the lock time for coalesced requests.';

DEFINE FIELD IF NOT EXISTS origin_link_value ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Returns the link short preview value for the pull zone origin connection.';

DEFINE FIELD IF NOT EXISTS disable_lets_encrypt ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'If true, the built-in let\'s encrypt is disabled and requests are passed to the origin.';

DEFINE FIELD IF NOT EXISTS enable_bunny_image_ai ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS bunny_ai_image_blueprints ON bunny_pull_zone_model
  TYPE option<array<option<record<bunny_ai_image_blueprint_model>>>>
;

DEFINE FIELD IF NOT EXISTS preloading_screen_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the preloading screen is currently enabled';

DEFINE FIELD IF NOT EXISTS preloading_screen_show_on_first_visit ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the preloading screen is shown on the first load from a user.';

DEFINE FIELD IF NOT EXISTS preloading_screen_code ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The custom preloading screen code';

DEFINE FIELD IF NOT EXISTS preloading_screen_logo_url ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The preloading screen logo URL';

DEFINE FIELD IF NOT EXISTS preloading_screen_code_enabled ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the custom preloader screen is enabled';

DEFINE FIELD IF NOT EXISTS preloading_screen_theme ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'The currently configured preloading screem theme. (0 - Light, 1 - Dark)';

DEFINE FIELD IF NOT EXISTS preloading_screen_delay ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The delay in miliseconds after which the preloading screen will be desplayed';

DEFINE FIELD IF NOT EXISTS e_u_u_s_discount ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The Pull Zone specific pricing discount for EU and US region.';

DEFINE FIELD IF NOT EXISTS south_america_discount ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The Pull Zone specific pricing discount for South America region.';

DEFINE FIELD IF NOT EXISTS africa_discount ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The Pull Zone specific pricing discount for Africa region.';

DEFINE FIELD IF NOT EXISTS asia_oceania_discount ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The Pull Zone specific pricing discount for Asia & Oceania region.';

DEFINE FIELD IF NOT EXISTS routing_filters ON bunny_pull_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of routing filters enabled for this zone';

DEFINE FIELD IF NOT EXISTS block_none_referrer ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if direct access to files will be blocked if not coming from allowed referrers';

DEFINE FIELD IF NOT EXISTS sticky_session_type ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Whether to use a Sticky Session mechanism for this pull zone';

DEFINE FIELD IF NOT EXISTS sticky_session_cookie_name ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'Sticky Session Cookie Name';

DEFINE FIELD IF NOT EXISTS sticky_session_client_headers ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'A set of comma-separated header names used to identify clients';

DEFINE FIELD IF NOT EXISTS user_id ON bunny_pull_zone_model
  TYPE option<string>
  COMMENT 'User Id of the pull zone owner';

DEFINE FIELD IF NOT EXISTS cache_version ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS optimizer_enable_upscaling ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Whether to automatically upscale assets when using Optimizer.';

DEFINE FIELD IF NOT EXISTS enable_web_sockets ON bunny_pull_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if WebSocket connections are allowed for this Pull Zone.';

DEFINE FIELD IF NOT EXISTS max_web_socket_connections ON bunny_pull_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The maximum global simultaneous WebSocket connections allowed for this Pull Zone.';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_pull_zone_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_pull_zone_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
