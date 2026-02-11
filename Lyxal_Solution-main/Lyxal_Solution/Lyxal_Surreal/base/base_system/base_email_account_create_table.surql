DEFINE FUNCTION IF NOT EXISTS fn::base_email_account_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_email_account', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_email_account TYPE NORMAL SCHEMAFULL
  COMMENT 'Comptes email (système)'
  PERMISSIONS FULL;

  -- Identification & liaison
  DEFINE FIELD name ON base_email_account TYPE string;
  DEFINE FIELD email ON base_email_account TYPE string ASSERT string::is::email($value);
  DEFINE FIELD user ON base_email_account TYPE option<record<base_user>>;
  DEFINE FIELD company ON base_email_account TYPE option<record<base_company>>;

  -- Connexion serveur
  DEFINE FIELD login ON base_email_account TYPE string;
  DEFINE FIELD password ON base_email_account TYPE string;
  DEFINE FIELD host ON base_email_account TYPE string;
  DEFINE FIELD port ON base_email_account TYPE int DEFAULT 587;
  DEFINE FIELD security_select ON base_email_account TYPE int DEFAULT 1; -- 1=None, 2=SSL, 3=TLS
  DEFINE FIELD server_type_select ON base_email_account TYPE int; -- 1=IMAP, 2=SMTP, etc.

  -- Présentation / statut
  DEFINE FIELD from_name ON base_email_account TYPE option<string>;
  DEFINE FIELD from_address ON base_email_account TYPE option<string>;
  DEFINE FIELD signature ON base_email_account TYPE option<string>;
  DEFINE FIELD is_default ON base_email_account TYPE bool DEFAULT false;
  DEFINE FIELD is_valid ON base_email_account TYPE bool DEFAULT true;

  -- Meta
  DEFINE FIELD created_at ON base_email_account TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_email_account TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_email_account TYPE int DEFAULT 0;

  -- Indexes
  DEFINE INDEX idx_base_email_account_email ON base_email_account FIELDS email;
  DEFINE INDEX idx_base_email_account_user ON base_email_account FIELDS user;
  DEFINE INDEX idx_base_email_account_company ON base_email_account FIELDS company;
  DEFINE INDEX idx_base_email_account_default ON base_email_account FIELDS is_default;

  -- Catalogage
  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_email_account', $sm.id, 'Comptes email (système)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_email_account_create_table_initialise', $sm.id, 'Crée la table base_email_account', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_email_account', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_email_account (système)'
PERMISSIONS FULL;

