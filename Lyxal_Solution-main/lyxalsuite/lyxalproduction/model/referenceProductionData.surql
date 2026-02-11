-- Données de référence pour lyxalproduction

-- AppProduction (configuration par défaut)
CREATE app_production:default SET enableAutoImputation = true, enableProdStatusUpdate = true;

-- WorkCenter
CREATE work_center:1 SET name = 'Atelier principal', location = 'Site A', capacity = 5;
CREATE work_center:2 SET name = 'Chantier mobile', location = 'Site B', capacity = 3;

-- Employee
CREATE employee:1 SET name = 'Alice Durand', isOperator = true;
CREATE employee:2 SET name = 'Jean Dupont', isOperator = true;

-- InvoicingProject
CREATE invoicing_project:1 SET name = 'Projet A - Facturation', project = project:1, amountToInvoice = 12000;

-- ProjectTask
CREATE project_task:1 SET name = 'Maçonnerie', project = project:1;
CREATE project_task:2 SET name = 'Finitions', project = project:1;

-- SaleOrderLine
CREATE sale_order_line:1 SET product = product:1, quantity = 10, price = 500, project = project:1;

-- SaleOrderLineDetails
CREATE sale_order_line_details:1 SET saleOrderLine = sale_order_line:1, details = 'Livraison en deux temps';

-- ProductionOrder
CREATE production_order:1 SET name = 'Chantier A - Phase 1', project = project:1, saleOrderLine = sale_order_line:1, status = 'in_progress';

-- ManufOrder
CREATE manuf_order:1 SET name = 'OF001', productionOrder = production_order:1, saleOrderLineDetail = sale_order_line_details:1, invoicingProject = invoicing_project:1, toInvoice = false;

-- OperationOrder
CREATE operation_order:1 SET name = 'Coulage dalle', manufOrder = manuf_order:1, workCenter = work_center:1, employee = employee:1, duration = time::duration("2h"), status = 'in_progress';

-- TimesheetLine
CREATE timesheet_line:1 SET employee = employee:1, operationOrder = operation_order:1, duration = time::duration("2h"), date = time::now();
