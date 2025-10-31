DEFINE EVENT update_project_announcement_fullname ON TABLE project_announcement
WHEN $before.title != $after.title OR $before.date != $after.date THEN {
  LET $fullname = $after.title + " [" + string::from($after.date) + "]";
  UPDATE $this SET fullName = $fullname;
};

DEFINE EVENT track_provider_company_update ON TABLE app_business_support
WHEN $before.providerCompany != $after.providerCompany THEN {
  // Log de modification si besoin
  RETURN true;
};