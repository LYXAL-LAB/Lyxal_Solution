-- Test complet du flux de production (lyxalproduction)

-- Étape 1 : Création d’un ordre de production
LET $prod = CREATE production_order SET name = 'Test - Production 001', project = project:1, saleOrderLine = sale_order_line:1, status = 'planned';

-- Étape 2 : Génération d’un ordre de fabrication
LET $of = CREATE manuf_order SET name = 'OF-Test-001', productionOrder = $prod.id, saleOrderLineDetail = sale_order_line_details:1, invoicingProject = invoicing_project:1, toInvoice = false;

-- Étape 3 : Ajout d’une opération
LET $op = CREATE operation_order SET name = 'Opération Test', manufOrder = $of.id, workCenter = work_center:1, employee = employee:1, duration = time::duration('1h'), status = 'planned';

-- Étape 4 : Enregistrement d’un temps
CREATE timesheet_line SET employee = employee:1, operationOrder = $op.id, duration = time::duration('1h'), date = time::now();

-- Étape 5 : Vérification des triggers (statut de production mis à jour automatiquement)
SELECT * FROM production_order WHERE id = $prod.id;
SELECT * FROM operation_order WHERE id = $op.id;
SELECT * FROM manuf_order WHERE id = $of.id;

-- Étape 6 : Audit
SELECT * FROM production_audit_log ORDER BY timestamp DESC;
