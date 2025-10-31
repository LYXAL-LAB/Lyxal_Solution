-- =====================================================================
-- DONNÉES DE RÉFÉRENCE - Sale Order Status
-- Utilisation des fonctions fn:: et icônes Lucide React
-- =====================================================================

-- Statut DRAFT (Brouillon)
SELECT fn::create_sale_order_status(
    "DRAFT",
    "Brouillon",
    1,
    "#6c757d",
    "FileEdit",
    false,
    true,
    "Commande en cours de création ou de modification"
);

-- Statut CONFIRMED (Confirmée)
SELECT fn::create_sale_order_status(
    "CONFIRMED",
    "Confirmée",
    2,
    "#28a745",
    "CheckCircle",
    false,
    false,
    "Commande confirmée et validée par le client"
);

-- Statut IN_PROGRESS (En cours)
SELECT fn::create_sale_order_status(
    "IN_PROGRESS",
    "En cours",
    3,
    "#17a2b8",
    "Clock",
    false,
    false,
    "Commande en cours de traitement ou de préparation"
);

-- Statut SHIPPED (Expédiée)
SELECT fn::create_sale_order_status(
    "SHIPPED",
    "Expédiée",
    4,
    "#fd7e14",
    "Truck",
    false,
    false,
    "Commande expédiée vers le client"
);

-- Statut DELIVERED (Livrée)
SELECT fn::create_sale_order_status(
    "DELIVERED",
    "Livrée",
    5,
    "#20c997",
    "PackageCheck",
    false,
    false,
    "Commande livrée au client"
);

-- Statut COMPLETED (Terminée)
SELECT fn::create_sale_order_status(
    "COMPLETED",
    "Terminée",
    6,
    "#007bff",
    "CheckCircle2",
    true,
    false,
    "Commande entièrement terminée et facturée"
);

-- Statut CANCELLED (Annulée)
SELECT fn::create_sale_order_status(
    "CANCELLED",
    "Annulée",
    99,
    "#dc3545",
    "XCircle",
    true,
    false,
    "Commande annulée par le client ou l'entreprise"
);

-- Statut ON_HOLD (En attente)
SELECT fn::create_sale_order_status(
    "ON_HOLD",
    "En attente",
    10,
    "#ffc107",
    "Pause",
    false,
    true,
    "Commande mise en attente temporairement"
);

-- Statut PENDING_APPROVAL (En attente d'approbation)
SELECT fn::create_sale_order_status(
    "PENDING_APPROVAL",
    "En attente d'approbation",
    15,
    "#6f42c1",
    "UserCheck",
    false,
    false,
    "Commande nécessitant une approbation hiérarchique"
);

-- Statut PARTIALLY_SHIPPED (Partiellement expédiée)
SELECT fn::create_sale_order_status(
    "PARTIALLY_SHIPPED",
    "Partiellement expédiée",
    35,
    "#e83e8c",
    "PackageMinus",
    false,
    false,
    "Commande avec livraison partielle"
);

-- Statut INVOICED (Facturée)
SELECT fn::create_sale_order_status(
    "INVOICED",
    "Facturée",
    50,
    "#198754",
    "Receipt",
    false,
    false,
    "Commande facturée mais pas encore payée"
);

-- Statut PAID (Payée)
SELECT fn::create_sale_order_status(
    "PAID",
    "Payée",
    55,
    "#0d6efd",
    "CreditCard",
    false,
    false,
    "Commande entièrement payée"
);

-- =====================================================================
-- VÉRIFICATION ET AFFICHAGE DES DONNÉES CRÉÉES
-- =====================================================================

-- Afficher tous les statuts créés
SELECT fn::list_sale_order_status();

-- Afficher avec statistiques
SELECT fn::list_sale_order_status_with_stats();

-- Valider les données créées
SELECT fn::validate_sale_order_status_data();