--  Génération auto du champ `label` sur insert/update
DEFINE EVENT gdpr_request_label_trigger ON gdpr_request WHEN $event = "CREATE" OR $event = "UPDATE" THEN (
  LET $type := (
    IF typeSelect = 0 THEN "Access"
    ELSE IF typeSelect = 1 THEN "Erasure"
    ELSE "Unknown"
  );
  LET $label := $type + " " + string::format(requestDateT, "%Y-%m-%d");
  UPDATE gdpr_request SET label = $label WHERE id = $id;
);

--  Calcul automatique de la dueSendingDateT (en se basant sur app_gdpr.maxRespondingDays)
DEFINE EVENT gdpr_request_due_date_trigger ON gdpr_request WHEN $event = "CREATE" THEN (
  LET $appGdpr := (
    SELECT ->gdprRequestOrigin->appGdpr->maxRespondingDays FROM gdpr_request WHERE id = $id
  );
  LET $days := IF $appGdpr.maxRespondingDays THEN $appGdpr.maxRespondingDays ELSE 30;
  LET $due := time::add(requestDateT, $days + "d");
  UPDATE gdpr_request SET dueSendingDateT = $due WHERE id = $id;
);
