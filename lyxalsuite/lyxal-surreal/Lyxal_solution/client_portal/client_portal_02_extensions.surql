-- ================================================================================
-- LYXAL SURREAL - AXELOR CLIENT PORTAL - MODULE 2 : EXTENSIONS D'ENTITÉS
-- ================================================================================
-- Extensions : Partner, SaleOrder
-- ================================================================================

-- Extension Partner pour portail client (Partner.xml - 477 bytes)
DEFINE TABLE partner_client_portal SCHEMAFULL;
DEFINE FIELD partner ON partner_client_portal TYPE record<partner>;
DEFINE FIELD password ON partner_client_portal TYPE string; -- Mot de passe crypté
DEFINE FIELD is_portal_user ON partner_client_portal TYPE bool DEFAULT false;
DEFINE FIELD portal_access_enabled ON partner_client_portal TYPE bool DEFAULT false;
DEFINE FIELD last_login_date ON partner_client_portal TYPE datetime;
DEFINE FIELD login_attempts ON partner_client_portal TYPE int DEFAULT 0;
DEFINE FIELD account_locked ON partner_client_portal TYPE bool DEFAULT false;
DEFINE FIELD account_locked_until ON partner_client_portal TYPE datetime;
DEFINE FIELD password_reset_token ON partner_client_portal TYPE string;
DEFINE FIELD password_reset_expires ON partner_client_portal TYPE datetime;
DEFINE FIELD email_verified ON partner_client_portal TYPE bool DEFAULT false;
DEFINE FIELD email_verification_token ON partner_client_portal TYPE string;
DEFINE FIELD email_verification_expires ON partner_client_portal TYPE datetime;
DEFINE FIELD preferred_language ON partner_client_portal TYPE string DEFAULT "en";
DEFINE FIELD portal_theme ON partner_client_portal TYPE string DEFAULT "default";
DEFINE FIELD notifications_enabled ON partner_client_portal TYPE bool DEFAULT true;
DEFINE FIELD two_factor_enabled ON partner_client_portal TYPE bool DEFAULT false;
DEFINE FIELD two_factor_secret ON partner_client_portal TYPE string;
DEFINE FIELD portal_roles ON partner_client_portal TYPE array<record<role>>;
DEFINE FIELD portal_permissions ON partner_client_portal TYPE array<string>;
DEFINE FIELD session_token ON partner_client_portal TYPE string;
DEFINE FIELD session_expires ON partner_client_portal TYPE datetime;
DEFINE FIELD terms_accepted ON partner_client_portal TYPE bool DEFAULT false;
DEFINE FIELD terms_accepted_date ON partner_client_portal TYPE datetime;
DEFINE FIELD privacy_accepted ON partner_client_portal TYPE bool DEFAULT false;
DEFINE FIELD privacy_accepted_date ON partner_client_portal TYPE datetime;
DEFINE FIELD registration_date ON partner_client_portal TYPE datetime;
DEFINE FIELD approval_status ON partner_client_portal TYPE int DEFAULT 1; -- 1:Pending, 2:Approved, 3:Rejected
DEFINE FIELD approved_by ON partner_client_portal TYPE record<user>;
DEFINE FIELD approval_date ON partner_client_portal TYPE datetime;
DEFINE FIELD created_at ON partner_client_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON partner_client_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON partner_client_portal TYPE int DEFAULT 0;

-- Extension SaleOrder pour portail client (SaleOrder.xml - 531 bytes)
DEFINE TABLE sale_order_client_portal SCHEMAFULL;
DEFINE FIELD sale_order ON sale_order_client_portal TYPE record<sale_order>;
DEFINE FIELD electronic_signature ON sale_order_client_portal TYPE record<meta_file>;
DEFINE FIELD is_portal_accessible ON sale_order_client_portal TYPE bool DEFAULT false;
DEFINE FIELD portal_visibility ON sale_order_client_portal TYPE int DEFAULT 1; -- 1:Private, 2:Shared, 3:Public
DEFINE FIELD portal_access_token ON sale_order_client_portal TYPE string;
DEFINE FIELD portal_access_expires ON sale_order_client_portal TYPE datetime;
DEFINE FIELD signature_required ON sale_order_client_portal TYPE bool DEFAULT false;
DEFINE FIELD signature_status ON sale_order_client_portal TYPE int DEFAULT 1; -- 1:Pending, 2:Signed, 3:Rejected
DEFINE FIELD signed_date ON sale_order_client_portal TYPE datetime;
DEFINE FIELD signed_by ON sale_order_client_portal TYPE record<partner>;
DEFINE FIELD signature_ip_address ON sale_order_client_portal TYPE string;
DEFINE FIELD signature_location ON sale_order_client_portal TYPE string;
DEFINE FIELD signature_device_info ON sale_order_client_portal TYPE string;
DEFINE FIELD portal_comments ON sale_order_client_portal TYPE array<object>;
DEFINE FIELD portal_attachments ON sale_order_client_portal TYPE array<record<meta_file>>;
DEFINE FIELD client_approval_required ON sale_order_client_portal TYPE bool DEFAULT false;
DEFINE FIELD client_approval_status ON sale_order_client_portal TYPE int DEFAULT 1; -- 1:Pending, 2:Approved, 3:Rejected
DEFINE FIELD client_approved_date ON sale_order_client_portal TYPE datetime;
DEFINE FIELD client_rejection_reason ON sale_order_client_portal TYPE string;
DEFINE FIELD portal_notifications_enabled ON sale_order_client_portal TYPE bool DEFAULT true;
DEFINE FIELD last_portal_view_date ON sale_order_client_portal TYPE datetime;
DEFINE FIELD portal_view_count ON sale_order_client_portal TYPE int DEFAULT 0;
DEFINE FIELD online_payment_enabled ON sale_order_client_portal TYPE bool DEFAULT false;
DEFINE FIELD online_payment_methods ON sale_order_client_portal TYPE array<record<online_payment_method>>;
DEFINE FIELD payment_deadline ON sale_order_client_portal TYPE date;
DEFINE FIELD payment_instructions ON sale_order_client_portal TYPE string;
DEFINE FIELD created_at ON sale_order_client_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sale_order_client_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_client_portal TYPE int DEFAULT 0;

-- Historique des connexions au portail
DEFINE TABLE portal_login_history SCHEMAFULL;
DEFINE FIELD partner ON portal_login_history TYPE record<partner>;
DEFINE FIELD login_date ON portal_login_history TYPE datetime DEFAULT time::now();
DEFINE FIELD logout_date ON portal_login_history TYPE datetime;
DEFINE FIELD ip_address ON portal_login_history TYPE string;
DEFINE FIELD user_agent ON portal_login_history TYPE string;
DEFINE FIELD session_duration ON portal_login_history TYPE duration;
DEFINE FIELD login_success ON portal_login_history TYPE bool DEFAULT true;
DEFINE FIELD failure_reason ON portal_login_history TYPE string;
DEFINE FIELD location ON portal_login_history TYPE string;
DEFINE FIELD device_type ON portal_login_history TYPE string;
DEFINE FIELD browser ON portal_login_history TYPE string;
DEFINE FIELD operating_system ON portal_login_history TYPE string;
DEFINE FIELD created_at ON portal_login_history TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON portal_login_history TYPE int DEFAULT 0;

-- Notifications du portail client
DEFINE TABLE portal_notification SCHEMAFULL;
DEFINE FIELD partner ON portal_notification TYPE record<partner>;
DEFINE FIELD title ON portal_notification TYPE string ASSERT $value != NONE;
DEFINE FIELD message ON portal_notification TYPE string ASSERT $value != NONE;
DEFINE FIELD notification_type ON portal_notification TYPE int DEFAULT 1; -- 1:Info, 2:Warning, 3:Error, 4:Success
DEFINE FIELD is_read ON portal_notification TYPE bool DEFAULT false;
DEFINE FIELD read_date ON portal_notification TYPE datetime;
DEFINE FIELD priority ON portal_notification TYPE int DEFAULT 1; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD related_entity_type ON portal_notification TYPE string;
DEFINE FIELD related_entity_id ON portal_notification TYPE string;
DEFINE FIELD action_url ON portal_notification TYPE string;
DEFINE FIELD action_label ON portal_notification TYPE string;
DEFINE FIELD expires_at ON portal_notification TYPE datetime;
DEFINE FIELD send_email ON portal_notification TYPE bool DEFAULT false;
DEFINE FIELD email_sent ON portal_notification TYPE bool DEFAULT false;
DEFINE FIELD email_sent_date ON portal_notification TYPE datetime;
DEFINE FIELD created_at ON portal_notification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON portal_notification TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON portal_notification TYPE int DEFAULT 0;

-- Activité sur le portail client
DEFINE TABLE portal_activity_log SCHEMAFULL;
DEFINE FIELD partner ON portal_activity_log TYPE record<partner>;
DEFINE FIELD activity_type ON portal_activity_log TYPE string ASSERT $value != NONE;
DEFINE FIELD activity_description ON portal_activity_log TYPE string;
DEFINE FIELD entity_type ON portal_activity_log TYPE string;
DEFINE FIELD entity_id ON portal_activity_log TYPE string;
DEFINE FIELD old_values ON portal_activity_log TYPE object;
DEFINE FIELD new_values ON portal_activity_log TYPE object;
DEFINE FIELD ip_address ON portal_activity_log TYPE string;
DEFINE FIELD user_agent ON portal_activity_log TYPE string;
DEFINE FIELD session_id ON portal_activity_log TYPE string;
DEFINE FIELD activity_date ON portal_activity_log TYPE datetime DEFAULT time::now();
DEFINE FIELD created_at ON portal_activity_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON portal_activity_log TYPE int DEFAULT 0;

-- Index pour optimisation des extensions
DEFINE INDEX idx_partner_client_portal_partner ON partner_client_portal FIELDS partner;
DEFINE INDEX idx_partner_client_portal_is_portal_user ON partner_client_portal FIELDS is_portal_user;
DEFINE INDEX idx_partner_client_portal_access_enabled ON partner_client_portal FIELDS portal_access_enabled;
DEFINE INDEX idx_partner_client_portal_last_login ON partner_client_portal FIELDS last_login_date;
DEFINE INDEX idx_partner_client_portal_account_locked ON partner_client_portal FIELDS account_locked;
DEFINE INDEX idx_partner_client_portal_approval_status ON partner_client_portal FIELDS approval_status;

DEFINE INDEX idx_sale_order_client_portal_sale_order ON sale_order_client_portal FIELDS sale_order;
DEFINE INDEX idx_sale_order_client_portal_is_accessible ON sale_order_client_portal FIELDS is_portal_accessible;
DEFINE INDEX idx_sale_order_client_portal_signature_status ON sale_order_client_portal FIELDS signature_status;
DEFINE INDEX idx_sale_order_client_portal_approval_status ON sale_order_client_portal FIELDS client_approval_status;
DEFINE INDEX idx_sale_order_client_portal_payment_enabled ON sale_order_client_portal FIELDS online_payment_enabled;

DEFINE INDEX idx_portal_login_history_partner ON portal_login_history FIELDS partner;
DEFINE INDEX idx_portal_login_history_login_date ON portal_login_history FIELDS login_date;
DEFINE INDEX idx_portal_login_history_success ON portal_login_history FIELDS login_success;
DEFINE INDEX idx_portal_login_history_ip ON portal_login_history FIELDS ip_address;

DEFINE INDEX idx_portal_notification_partner ON portal_notification FIELDS partner;
DEFINE INDEX idx_portal_notification_is_read ON portal_notification FIELDS is_read;
DEFINE INDEX idx_portal_notification_priority ON portal_notification FIELDS priority;
DEFINE INDEX idx_portal_notification_type ON portal_notification FIELDS notification_type;
DEFINE INDEX idx_portal_notification_expires ON portal_notification FIELDS expires_at;

DEFINE INDEX idx_portal_activity_log_partner ON portal_activity_log FIELDS partner;
DEFINE INDEX idx_portal_activity_log_activity_type ON portal_activity_log FIELDS activity_type;
DEFINE INDEX idx_portal_activity_log_entity_type ON portal_activity_log FIELDS entity_type;
DEFINE INDEX idx_portal_activity_log_activity_date ON portal_activity_log FIELDS activity_date;