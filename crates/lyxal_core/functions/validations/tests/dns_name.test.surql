-- lyxal-test: assertions
-- Tests de fn::validation_dns_name (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: nom ordinaire, espaces retirés, minuscules
RETURN fn::validation_dns_name(" Mail.Exemple.FR ", true, false, NONE)
    == { valid: true, value: "mail.exemple.fr", code: NONE, details: {} };

-- test: point final retiré
RETURN fn::validation_dns_name("exemple.fr.", true, false, NONE)
    == { valid: true, value: "exemple.fr", code: NONE, details: {} };

-- test: DMARC à tiret bas
RETURN fn::validation_dns_name("_dmarc.exemple.fr", true, false, NONE)
    == { valid: true, value: "_dmarc.exemple.fr", code: NONE, details: {} };

-- test: sélecteur DKIM
RETURN fn::validation_dns_name("lyx202611r._domainkey.exemple.fr", true, false, NONE)
    == { valid: true, value: "lyx202611r._domainkey.exemple.fr", code: NONE, details: {} };

-- test: MTA-STS (tiret bas puis tiret)
RETURN fn::validation_dns_name("_mta-sts.exemple.fr", true, false, NONE).value == "_mta-sts.exemple.fr";

-- test: TLS-RPT (deux labels de service)
RETURN fn::validation_dns_name("_smtp._tls.exemple.fr", true, false, NONE).value == "_smtp._tls.exemple.fr";

-- test: défi ACME
RETURN fn::validation_dns_name("_acme-challenge.www.exemple.fr", true, false, NONE).valid;

-- test: A-label (punycode) accepté
RETURN fn::validation_dns_name("xn--bcher-kva.example", true, false, NONE).value == "xn--bcher-kva.example";

-- test: label numérique hors dernier label accepté
RETURN fn::validation_dns_name("4.3.2.1.in-addr.arpa", true, false, NONE).valid;

-- test: joker autorisé en premier label
RETURN fn::validation_dns_name("*.Exemple.fr", true, true, NONE)
    == { valid: true, value: "*.exemple.fr", code: NONE, details: {} };

-- test: joker refusé sans l'option
RETURN fn::validation_dns_name("*.exemple.fr", true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "wildcard" } };

-- test: joker hors du premier label
RETURN fn::validation_dns_name("www.*.exemple.fr", true, true, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "dns_name" } };

-- test: joker collé à un label
RETURN fn::validation_dns_name("*www.exemple.fr", true, true, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: joker seul
RETURN fn::validation_dns_name("*", true, true, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: tiret bas refusé sans l'option
RETURN fn::validation_dns_name("_dmarc.exemple.fr", false, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "underscore" } };

-- test: nom sans tiret bas accepté sans l'option
RETURN fn::validation_dns_name("mail.exemple.fr", false, false, NONE).valid;

-- test: label de 63 octets accepté
RETURN fn::validation_dns_name(string::repeat("a", 63) + ".exemple.fr", true, false, NONE).valid;

-- test: label de 64 octets refusé
RETURN fn::validation_dns_name(string::repeat("a", 64) + ".exemple.fr", true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "dns_name" } };

-- test: nom de 253 octets accepté
RETURN fn::validation_dns_name(string::repeat(string::repeat("a", 63) + ".", 3) + string::repeat("b", 58) + ".fr", true, false, NONE).value
    == string::repeat(string::repeat("a", 63) + ".", 3) + string::repeat("b", 58) + ".fr";

-- test: nom de 253 octets suivi du point final accepté
RETURN fn::validation_dns_name(string::repeat(string::repeat("a", 63) + ".", 3) + string::repeat("b", 58) + ".fr.", true, false, NONE).valid;

-- test: nom de 254 octets refusé
RETURN fn::validation_dns_name(string::repeat(string::repeat("a", 63) + ".", 3) + string::repeat("b", 59) + ".fr", true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 253, length: 254 } };

-- test: un seul label refusé
RETURN fn::validation_dns_name("localhost", true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "dns_name" } };

-- test: tiret en début de label
RETURN fn::validation_dns_name("-mail.exemple.fr", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: tiret en fin de label
RETURN fn::validation_dns_name("mail-.exemple.fr", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: label vide
RETURN fn::validation_dns_name("mail..exemple.fr", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: point initial
RETURN fn::validation_dns_name(".exemple.fr", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: deux points finals
RETURN fn::validation_dns_name("exemple.fr..", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: point seul
RETURN fn::validation_dns_name(".", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: Unicode refusé (U-label)
RETURN fn::validation_dns_name("bücher.example", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: espace interne refusé
RETURN fn::validation_dns_name("mail exemple.fr", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: caractère interdit
RETURN fn::validation_dns_name("mail@exemple.fr", true, false, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: adresse IPv4 refusée (dernier label numérique)
RETURN fn::validation_dns_name("192.0.2.1", true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "dns_name" } };

-- test: zone : apex accepté
RETURN fn::validation_dns_name("Exemple.fr", true, false, "exemple.fr").value == "exemple.fr";

-- test: zone : sous-nom accepté, casse et point final de la zone ignorés
RETURN fn::validation_dns_name("_dmarc.exemple.fr", true, false, "Exemple.FR.")
    == { valid: true, value: "_dmarc.exemple.fr", code: NONE, details: {} };

-- test: zone : joker sous la zone accepté
RETURN fn::validation_dns_name("*.exemple.fr", true, true, "exemple.fr").valid;

-- test: zone : nom d'une autre zone refusé
RETURN fn::validation_dns_name("mail.autre.fr", true, false, "exemple.fr")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "zone" } };

-- test: zone : suffixe sans point de séparation refusé
RETURN fn::validation_dns_name("monexemple.fr", true, false, "exemple.fr").details == { reason: "zone" };

-- test: zone : nom parent refusé
RETURN fn::validation_dns_name("fr.", true, false, "exemple.fr").valid == false;

-- test: chaîne blanche
RETURN fn::validation_dns_name("   ", true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_dns_name(NONE, true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_dns_name(NULL, true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_dns_name(42, true, false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: type tableau refusé
RETURN fn::validation_dns_name(["exemple.fr"], true, false, NONE).details == { expected: "string", actual: "array" };

-- test: zone mal formée
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_dns_name("mail.exemple.fr", true, false, "pas une zone");

-- test: zone d'un seul label
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_dns_name("mail.exemple.fr", true, false, "fr");

-- test: zone avec joker
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_dns_name("mail.exemple.fr", true, false, "*.exemple.fr");

-- test: zone vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_dns_name("mail.exemple.fr", true, false, "");

-- test: zone contrôlée même si la valeur est absente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_dns_name(NONE, true, false, "-exemple.fr");

-- test: règle du moteur
RETURN fn::validation_pipeline_execute("_DMARC.Exemple.fr.", [{ rule: "dns_name", options: { allow_underscore: true, allow_wildcard: false } }], 5).value == "_dmarc.exemple.fr";

-- test: règle du moteur avec zone
RETURN fn::validation_pipeline_execute("mail.autre.fr", [{ rule: "dns_name", options: { allow_underscore: true, allow_wildcard: false, zone: "exemple.fr" } }], 5).valid == false;
