-- Statuts de projet
CREATE type::project_status:1 SET code = "DRAFT", label = "Draft";
CREATE type::project_status:2 SET code = "IN_PROGRESS", label = "In Progress";
CREATE type::project_status:3 SET code = "COMPLETED", label = "Completed";
CREATE type::project_status:4 SET code = "CANCELED", label = "Canceled";

-- Statuts de tâche
CREATE type::task_status:1 SET code = "PLANNED", label = "Planned";
CREATE type::task_status:2 SET code = "STARTED", label = "Started";
CREATE type::task_status:3 SET code = "DONE", label = "Done";
CREATE type::task_status:4 SET code = "BLOCKED", label = "Blocked";

-- Statuts de facturation projet
CREATE type::invoicing_project_status:1 SET code = "DRAFT", label = "Draft";
CREATE type::invoicing_project_status:2 SET code = "GENERATED", label = "Generated";
CREATE type::invoicing_project_status:3 SET code = "VALIDATED", label = "Validated";
CREATE type::invoicing_project_status:4 SET code = "VENTILATED", label = "Ventilated";
CREATE type::invoicing_project_status:5 SET code = "CANCELED", label = "Canceled";

-- Types d'éléments manuels (coût ou chiffre d'affaire)
CREATE type::manual_element_type:1 SET code = "REVENUE", label = "Revenue";
CREATE type::manual_element_type:2 SET code = "EXPENSE", label = "Expense";

-- Configuration de base pour business_project_config
CREATE business_project_config:default SET 
  automaticProject = true,
  generateProjectOrder = false,
  projectInvoiceLines = true,
  projectSaleOrderLines = true,
  projectPurchaseOrderLines = true;
