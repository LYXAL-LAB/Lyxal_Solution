--  Types de requêtes RGPD
CREATE type::select("gdpr.request.type.select", {
  "0": "Access",
  "1": "Erasure"
});

--  Statuts de requête RGPD
CREATE type::select("gdpr.request.status.select", {
  "0": "Received",
  "1": "Confirmed",
  "2": "Sent",
  "3": "Canceled"
});

--  Statuts des registres de traitement
CREATE type::select("gdpr.processing.register.status.select", {
  "0": "Draft",
  "1": "Active",
  "2": "Canceled"
});

--  Exemple d’origine de requête
CREATE gdpr_request_origin:1 SET code = "PORTAL", name = "Portal";
CREATE gdpr_request_origin:2 SET code = "EMAIL", name = "Email";
CREATE gdpr_request_origin:3 SET code = "API", name = "API";

--  Exemple d’un app GDPR pour test
CREATE app:1 SET appGdpr = app_gdpr:1;
CREATE app_gdpr:1 SET maxRespondingDays = 30;

--  Exemple de template email de réponse
CREATE template:1 SET name = "Access Request Response", subject = "RGPD - Access Data", content = "Here is your personal data...";
CREATE template:2 SET name = "Erasure Request Response", subject = "RGPD - Erasure Confirmation", content = "Your data has been erased.";

UPDATE app_gdpr:1 SET accessResponseTemplate = template:1, erasureResponseTemplate = template:2;
