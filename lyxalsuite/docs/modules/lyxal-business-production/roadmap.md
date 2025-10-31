Feuille de route LYXALBUSINESSPRODUCTION – Gateway Production
Cette feuille de route définit l'intégralité du travail à faire pour le module Business Production dans la Gateway LYXAL, version production-ready. Elle respecte l'architecture officielle LYXAL (gateway, sdk, ui).

📦 Objectif général
Créer un backend de gestion de production liée aux projets, multi-workspace, sécurisé, et entièrement relié aux modules lyxalproject et lyxalsale. Il exposera des routes REST pour :

le suivi des ordres de fabrication (ManufOrder)

l’exécution des opérations (OperationOrder)

l’imputation des temps (TimesheetLine)

le rattachement aux projets (ProductionOrder)

la sélection des OF à facturer (InvoicingProject)

la gestion des lignes de ventes liées (SaleOrderLineDetails)

📦 Module lyxalbusinessproduction
Ce module connecte projets, ventes et production dans un flux cohérent permettant le pilotage complet des OF, leur affectation à des projets, leur facturation, et leur traçabilité.

✅ Fonctionnalités couvertes
CRUD complet pour :

ManufOrder

OperationOrder

TimesheetLine

ProductionOrder

InvoicingProject

SaleOrderLineDetails

Liaison des OF à des projets

Imputation de temps (manuel ou auto)

Suivi des employés et workcenters

Statut de facturation (isToInvoice, invoiced)

Audit des champs critiques (invoiced, isToInvoice)

Contrôle assignment via Employee.timesheetImputationSelect

Configuration globale via AppProduction

📂 Structure du module

lyxalbusinessproduction/
├── gateway/
│   ├── routes/
│   │   ├── manuf.routes.ts
│   │   ├── operation.routes.ts
│   │   ├── timesheet.routes.ts
│   │   └── production.routes.ts
│   ├── controllers/
│   │   └── manufController.ts
│   ├── services/
│   │   └── manufService.ts
│   ├── validators/
│   │   └── productionSchemas.ts
│   └── middlewares/
│       └── requireAuth.ts
├── sdk/
│   ├── backend/
│   │   └── manufClient.ts
│   ├── frontend/
│   │   └── manufClient.ts
│   └── types/
│       └── businessProduction.types.ts
├── model/
│   ├── business_production_structure.surql
│   ├── business_production_reference.surql
│   ├── business_production_triggers.surql
│   └── business_production_indexes.surql
└── docs/
    └── lyxalbusinessproduction.md

🛡️ Sécurité
🔐 Auth obligatoire via requireAuth() (Logto)

📊 Audit activé sur :

ManufOrder.isToInvoice

ManufOrder.invoiced

TimesheetLine.manufOrder

❌ Aucun accès public

🔀 Relations prises en charge
ManufOrder ➔ TimesheetLine

OperationOrder ➔ TimesheetLine

Employee ➔ TimesheetLine

InvoicingProject ➔ ManufOrder

ProductionOrder ➔ Project

SaleOrderLine ➔ SaleOrderLineDetails

WorkCenter ➔ Employee

✅ Tables SurrealDB à créer

DEFINE TABLE manuf_order SCHEMAFULL;
DEFINE TABLE operation_order SCHEMAFULL;
DEFINE TABLE timesheet_line SCHEMAFULL;
DEFINE TABLE production_order SCHEMAFULL;
DEFINE TABLE invoicing_project SCHEMAFULL;
DEFINE TABLE sale_order_line_details SCHEMAFULL;
DEFINE TABLE app_production SCHEMAFULL;

🧰 Routes disponibles (/business-production)
Méthode	URL	Description
GET	/manuf	Liste des ordres de fabrication
POST	/manuf	Créer un ordre de fabrication
PUT	/manuf/:id	Modifier un OF
GET	/operation	Liste des opérations
POST	/operation	Créer une opération
GET	/timesheet	Liste des imputations
POST	/timesheet	Ajouter une imputation
GET	/production-order	Liste des OF liés à un projet
POST	/production-order	Ajouter un OF à un projet
GET	/invoicing-project	Liste des projets à facturer
POST	/invoicing-project	Ajouter des OF à facturer
GET	/sale-order-line-details	Liste des lignes de vente liées

🧠 Triggers à prévoir
auto_fullname_line_details : concaténation pour nommer les SaleOrderLineDetails

validate_assignment : validation de timesheetImputationSelect

audit_invoicing_status : log changements isToInvoice / invoiced

🛠️ Index à créer

DEFINE INDEX manuf_invoiced_idx ON manuf_order FIELDS invoiced;
DEFINE INDEX operation_employee_idx ON operation_order FIELDS employeeSet;
DEFINE INDEX timesheet_manuf_idx ON timesheet_line FIELDS manufOrder;
DEFINE INDEX timesheet_operation_idx ON timesheet_line FIELDS operationOrder;
DEFINE INDEX production_project_idx ON production_order FIELDS project;
DEFINE INDEX invoicing_manuf_idx ON invoicing_project FIELDS manufOrderSet;
DEFINE INDEX sol_details_idx ON sale_order_line_details FIELDS projectSaleOrderLine;



