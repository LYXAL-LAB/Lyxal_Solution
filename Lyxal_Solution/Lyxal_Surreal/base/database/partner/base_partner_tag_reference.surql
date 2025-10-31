DEFINE FUNCTION IF NOT EXISTS fn::base_partner_tag_reference_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: seeds de tags Partner', { run_id: $run_id, parent_run_id: $parent_run_id });

-- partner_source_*
LET $ts1 = fn::system_tag_create_record('partner_source_import', 'Partner Source: Import', 'Partenaire issu d\'un import', '#6b7280', false);
LET $ts2 = fn::system_tag_create_record('partner_source_web', 'Partner Source: Web', 'Partenaire créé via site web', '#60a5fa', false);
LET $ts3 = fn::system_tag_create_record('partner_source_crm', 'Partner Source: CRM', 'Partenaire créé via CRM', '#34d399', false);

-- partner_category_*
LET $tc1 = fn::system_tag_create_record('partner_category_customer', 'Partner Category: Customer', 'Partenaire de type client', '#f59e0b', true);
LET $tc2 = fn::system_tag_create_record('partner_category_supplier', 'Partner Category: Supplier', 'Partenaire de type fournisseur', '#84cc16', true);
LET $tc3 = fn::system_tag_create_record('partner_category_prospect', 'Partner Category: Prospect', 'Partenaire de type prospect', '#22c55e', false);
LET $tc4 = fn::system_tag_create_record('partner_category_internal', 'Partner Category: Internal', 'Partenaire interne', '#a78bfa', true);

-- partner_active / partner_is_company
LET $ta1 = fn::system_tag_create_record('partner_active', 'Partner Active', 'Partenaire actif', '#10b981', true);
LET $ta2 = fn::system_tag_create_record('partner_inactive', 'Partner Inactive', 'Partenaire inactif', '#ef4444', true);
LET $ti1 = fn::system_tag_create_record('partner_is_company', 'Partner Is Company', 'Partenaire de type entreprise', '#3b82f6', true);
LET $ti2 = fn::system_tag_create_record('partner_is_individual', 'Partner Is Individual', 'Partenaire de type personne', '#8b5cf6', true);

-- partner_role_*
LET $tr1 = fn::system_tag_create_record('partner_role_decider', 'Partner Role: Décideur', 'Décideur principal côté partenaire', '#ef4444', true);
LET $tr2 = fn::system_tag_create_record('partner_role_billing_contact', 'Partner Role: Contact Facturation', 'Contact dédié à la facturation', '#f59e0b', true);
LET $tr3 = fn::system_tag_create_record('partner_role_legal_representative', 'Partner Role: Représentant légal', 'Représentant légal de la société', '#10b981', true);
LET $tr4 = fn::system_tag_create_record('partner_role_buyer', 'Partner Role: Acheteur', 'Acheteur / approvisionneur', '#3b82f6', false);
LET $tr5 = fn::system_tag_create_record('partner_role_sales_contact', 'Partner Role: Contact Commercial', 'Référent commercial', '#8b5cf6', false);
LET $tr6 = fn::system_tag_create_record('partner_role_account_manager', 'Partner Role: Gestionnaire de compte', 'Gestionnaire/AM côté fournisseur', '#22c55e', false);
LET $tr7 = fn::system_tag_create_record('partner_role_employee', 'Partner Role: Employé', 'Employé/salarié', '#0ea5e9', false);
LET $tr8 = fn::system_tag_create_record('partner_role_contact', 'Partner Role: Contact', 'Contact (personne)', '#64748b', false);

-- partner_department_*
LET $td1 = fn::system_tag_create_record('partner_department_purchasing', 'Partner Department: Achats', 'Département Achats', '#06b6d4', false);
LET $td2 = fn::system_tag_create_record('partner_department_finance', 'Partner Department: Finance', 'Département Finance', '#0ea5e9', false);
LET $td3 = fn::system_tag_create_record('partner_department_it', 'Partner Department: IT', 'Département Informatique', '#6366f1', false);
LET $td4 = fn::system_tag_create_record('partner_department_sales', 'Partner Department: Sales', 'Département Commercial', '#f59e0b', false);
LET $td5 = fn::system_tag_create_record('partner_department_hr', 'Partner Department: RH', 'Département Ressources Humaines', '#10b981', false);

-- address_*
LET $addr1 = fn::system_tag_create_record('address_head_office', 'Address: Head Office', 'Adresse de siège social', '#ef4444', true);
LET $addr2 = fn::system_tag_create_record('address_delivery', 'Address: Delivery', 'Adresse de livraison', '#2563eb', false);
LET $addr3 = fn::system_tag_create_record('address_invoicing', 'Address: Invoicing', 'Adresse de facturation', '#059669', false);
LET $addr4 = fn::system_tag_create_record('address_main', 'Address: Main', 'Adresse principale (générale)', '#f59e0b', true);

-- bank_*
LET $bk1 = fn::system_tag_create_record('bank_main', 'Bank: Main', 'Coordonnée bancaire principale', '#0ea5e9', true);

-- price_list_type_*
LET $plt1 = fn::system_tag_create_record('price_list_type_sale', 'Price List Type: Sale', 'Type de liste de prix: vente', '#22c55e', true);
LET $plt2 = fn::system_tag_create_record('price_list_type_purchase', 'Price List Type: Purchase', 'Type de liste de prix: achat', '#f59e0b', true);

-- industry/activity
LET $ia1 = fn::system_tag_create_record('industry_manufacturing', 'Industry: Manufacturing', 'Secteur: Industrie manufacturière', '#1d4ed8', false);
LET $ia2 = fn::system_tag_create_record('industry_services', 'Industry: Services', 'Secteur: Services', '#059669', false);
LET $ia3 = fn::system_tag_create_record('industry_retail', 'Industry: Retail', 'Secteur: Commerce de détail', '#b45309', false);
LET $ac1 = fn::system_tag_create_record('activity_it', 'Activity: IT', 'Activité: Technologies de l\'information', '#4f46e5', false);
LET $ac2 = fn::system_tag_create_record('activity_finance', 'Activity: Finance', 'Activité: Finance', '#0f766e', false);
LET $ac3 = fn::system_tag_create_record('activity_logistics', 'Activity: Logistics', 'Activité: Logistique', '#a21caf', false);

-- partner_function_*
LET $pf1 = fn::system_tag_create_record('partner_function_ceo', 'Partner Function: CEO', 'Directeur général', '#f97316', false);
LET $pf2 = fn::system_tag_create_record('partner_function_cfo', 'Partner Function: CFO', 'Directeur financier', '#22c55e', false);
LET $pf3 = fn::system_tag_create_record('partner_function_cto', 'Partner Function: CTO', 'Directeur technique', '#0ea5e9', false);
LET $pf4 = fn::system_tag_create_record('partner_function_buyer', 'Partner Function: Acheteur', 'Acheteur / approvisionneur', '#84cc16', false);
LET $pf5 = fn::system_tag_create_record('partner_function_sales', 'Partner Function: Commercial', 'Commercial / Sales', '#f59e0b', false);
LET $pf6 = fn::system_tag_create_record('partner_function_support', 'Partner Function: Support', 'Support / Service client', '#8b5cf6', false);

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_partner' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_failure'], 'Erreur: sous-module base_partner introuvable pour builder_function (tags)', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $f_rec = fn::builder_function_create_record('base_partner_tag_reference_initialise', $sm.id, 'Initialise les tags de référence Partner', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour base_partner_tag_reference_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: seeds de tags Partner', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise les tags de référence du sous-module Partner'
PERMISSIONS FULL;