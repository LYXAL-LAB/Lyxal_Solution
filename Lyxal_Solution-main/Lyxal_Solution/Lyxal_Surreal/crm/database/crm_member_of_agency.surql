DEFINE TABLE IF NOT EXISTS crm_member_of_agency TYPE RELATION
    COMMENT 'Relation many-to-many : base_user <-> crm_agency (membre d\'une agence)'
    PERMISSIONS FULL;

  -- ==================================
  -- DÉFINITION DES CHAMPS (in / out)
  -- ==================================
  DEFINE FIELD in ON TABLE crm_member_of_agency TYPE record<base_user>
    COMMENT 'Référence vers l\'utilisateur membre';

  DEFINE FIELD out ON TABLE crm_member_of_agency TYPE record<crm_agency>
    COMMENT 'Référence vers l\'agence';

  -- ==================================
  -- CHAMPS OPTIONNELS (métadonnées de relation)
  -- ==================================
  DEFINE FIELD role ON TABLE crm_member_of_agency TYPE option<string>
    COMMENT 'Rôle du membre dans l\'agence (ex: "manager", "member")';

  DEFINE FIELD joined_at ON TABLE crm_member_of_agency TYPE datetime
    VALUE time::now();

  -- ==================================
  -- INDEX
  -- ==================================
  DEFINE INDEX idx_crm_member_of_agency_user ON crm_member_of_agency FIELDS in;
  DEFINE INDEX idx_crm_member_of_agency_agency ON crm_member_of_agency FIELDS out;
  DEFINE INDEX idx_crm_member_of_agency_user_agency 
    ON crm_member_of_agency FIELDS in, out 
    UNIQUE;