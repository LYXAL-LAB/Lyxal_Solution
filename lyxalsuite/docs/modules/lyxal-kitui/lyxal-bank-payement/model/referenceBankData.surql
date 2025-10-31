-- lyxalbank: DONNÉES DE RÉFÉRENCE (SELECT + CREATE)

--  Status de BankOrder
DEFINE SELECT bank_order_status_select AS {
  "draft": "Draft",
  "confirmed": "Confirmed",
  "validated": "Validated",
  "rejected": "Rejected"
};

CREATE bank_order_status:1 SET code = "draft", label = "Draft";
CREATE bank_order_status:2 SET code = "confirmed", label = "Confirmed";
CREATE bank_order_status:3 SET code = "validated", label = "Validated";
CREATE bank_order_status:4 SET code = "rejected", label = "Rejected";

--  Type de ligne de relevé bancaire
DEFINE SELECT bank_statement_line_line_type_select AS {
  "1": "Initial balance",
  "2": "Movement",
  "3": "Final balance"
};

--  Status de rapprochement bancaire
DEFINE SELECT bank_reconciliation_status_select AS {
  "1": "Draft",
  "2": "Validated",
  "3": "Under Correction"
};

--  Type de ligne de rapprochement
DEFINE SELECT bank_reconciliation_type_select AS {
  "1": "General",
  "2": "Customer",
  "3": "Supplier"
};

--  Index de confiance
DEFINE SELECT bank_reconciliation_confidence_index AS {
  "1": "Green",
  "2": "Orange",
  "3": "Red"
};

--  Index de disponibilité / exonération
DEFINE SELECT bank_statement_line_afb_120_unavailability_index_select AS {
  "0": "Available",
  "1": "Unavailable"
};
DEFINE SELECT bank_statement_line_afb_120_commission_exemption_index_select AS {
  "0": "Not exempt",
  "1": "Exempt"
};
