-- lyxalbank: EVENTS / TRIGGERS

--  Met à jour la date de validation quand une BankOrder passe en "confirmed"
DEFINE EVENT update_validation_date ON TABLE bank_order
WHEN $after.status = "confirmed" AND $before.status != "confirmed" THEN {
  UPDATE $this SET validated_at = time::now();
};

--  Génère automatiquement le fullName dans BankStatement à partir du nom et date
DEFINE EVENT compute_statement_full_name ON TABLE bank_statement
WHEN $after.name != NONE AND $after.from_date != NONE THEN {
  LET $label = $after.name + " [" + string::from($after.from_date) + "]";
  UPDATE $this SET label = $label;
};

--  Si le solde est mis à jour, enregistre automatiquement la date de mise à jour
DEFINE EVENT update_balance_date ON TABLE bank_details
WHEN $before.balance != $after.balance THEN {
  UPDATE $this SET balance_updated_date = time::now();
};

--  Vérifie automatiquement si un relevé est totalement rapproché
DEFINE EVENT check_fully_reconciled ON TABLE bank_statement
WHEN $after.is_fully_reconciled != true AND $after.status_select = 2 THEN {
  LET $recoCount = count((SELECT * FROM bank_reconciliation_line WHERE bank_statement_line.bank_statement = $this.id));
  IF $recoCount > 0 THEN {
    UPDATE $this SET is_fully_reconciled = true;
  };
};

--  Si un BankReconciliationLine est posté, on loggue le timestamp
DEFINE EVENT log_posted_reco_line ON TABLE bank_reconciliation_line
WHEN $after.is_posted = true AND $before.is_posted != true THEN {
  UPDATE $this SET posted_nbr = "POSTED-" + string::from(time::now());
};
