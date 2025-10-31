-- Générer le nom complet des lignes de vente liées
DEFINE EVENT sol_details_fullname ON TABLE sale_order_line_details
WHEN $after.projectSaleOrderLine != NONE THEN {
  LET $name = "Détail ligne pour " + $after.projectSaleOrderLine;
  UPDATE $this SET name = $name;
};

-- Audit du changement de statut de facturation
DEFINE EVENT audit_invoicing_status ON TABLE manuf_order
WHEN $before.invoiced != $after.invoiced OR $before.isToInvoice != $after.isToInvoice THEN {
  RETURN "Changement statut de facturation sur l'OF " + $this.code;
};

-- Mise à jour automatique de l’imputation si activé
DEFINE EVENT auto_timesheet_generation ON TABLE operation_order
WHEN $event = "UPDATE" AND $after.isToInvoice = true THEN {
  RETURN "Vérification des imputations requises";
};
