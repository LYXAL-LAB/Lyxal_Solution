-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_event_type_details_by_id                              â”‚
-- â”‚  RÃ©cupÃ¨re les dÃ©tails complets d'un type d'Ã©vÃ©nement par son ID        â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_event_type_details_by_id(
    $et_id: option<record<booking_event_type>>
) {
    IF $et_id == NONE {
        THROW "Parameter 'et_id' is required";
    };

    LET $res = SELECT *, account.name AS owner_name, account.avatar_url AS owner_avatar FROM $et_id;
    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re les dÃ©tails complets d'un type de rendez-vous avec profil propriÃ©taire";
