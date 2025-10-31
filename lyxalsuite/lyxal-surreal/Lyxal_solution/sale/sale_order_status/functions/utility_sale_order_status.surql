-- =====================================================================
-- FONCTIONS UTILITAIRES - Sale Order Status
-- =====================================================================

-- Fonction pour réinitialiser les données de référence
DEFINE FUNCTION fn::reset_sale_order_status_data() {
    -- Désactiver tous les statuts existants
    UPDATE sale_order_status SET is_active = false WHERE is_active = true;
    
    -- Recréer les statuts de base
    SELECT fn::create_sale_order_status("DRAFT", "Brouillon", 1, "#6c757d", "FileEdit", false, true, "Commande en cours de création");
    SELECT fn::create_sale_order_status("CONFIRMED", "Confirmée", 2, "#28a745", "CheckCircle", false, false, "Commande confirmée");
    SELECT fn::create_sale_order_status("COMPLETED", "Terminée", 6, "#007bff", "CheckCircle2", true, false, "Commande terminée");
    SELECT fn::create_sale_order_status("CANCELLED", "Annulée", 99, "#dc3545", "XCircle", true, false, "Commande annulée");
    
    RETURN { success: true, message: "Données de référence réinitialisées" };
};

-- Fonction pour créer un jeu de données de test
DEFINE FUNCTION fn::create_test_sale_order_status() {
    SELECT fn::create_sale_order_status("TEST_STATUS", "Statut Test", 100, "#ff6b6b", "TestTube", false, true, "Statut pour les tests");
    RETURN { success: true, message: "Statut de test créé" };
};

-- Fonction pour obtenir les icônes Lucide disponibles
DEFINE FUNCTION fn::get_available_lucide_icons() {
    RETURN [
        "FileEdit", "CheckCircle", "CheckCircle2", "Clock", "Truck", 
        "PackageCheck", "XCircle", "Pause", "UserCheck", "PackageMinus",
        "Receipt", "CreditCard", "AlertCircle", "Info", "Settings",
        "Archive", "Calendar", "Mail", "Phone", "User", "Users",
        "Home", "Building", "MapPin", "Globe", "Search", "Filter",
        "Download", "Upload", "Save", "Edit", "Trash2", "Plus",
        "Minus", "MoreHorizontal", "MoreVertical", "ChevronUp",
        "ChevronDown", "ChevronLeft", "ChevronRight", "ArrowUp",
        "ArrowDown", "ArrowLeft", "ArrowRight", "ExternalLink",
        "Eye", "EyeOff", "Lock", "Unlock", "Shield", "ShieldCheck",
        "Star", "Heart", "Bookmark", "Flag", "Tag", "Tags"
    ];
};

-- Fonction pour valider les données de référence
DEFINE FUNCTION fn::validate_sale_order_status_data() {
    LET $errors = [];
    
    -- Vérifier les statuts obligatoires
    LET $required_statuses = ["DRAFT", "CONFIRMED", "COMPLETED", "CANCELLED"];
    FOR $required IN $required_statuses {
        LET $exists = SELECT id FROM sale_order_status WHERE code = $required AND is_active = true LIMIT 1;
        IF !$exists {
            array::push($errors, "Statut obligatoire manquant: " + $required);
        };
    };
    
    -- Vérifier les doublons de séquence
    LET $duplicate_sequences = SELECT sequence, COUNT(*) as count 
                              FROM sale_order_status 
                              WHERE is_active = true 
                              GROUP BY sequence 
                              HAVING count > 1;
    
    FOR $dup IN $duplicate_sequences {
        array::push($errors, "Séquence dupliquée: " + string($dup.sequence));
    };
    
    -- Vérifier les doublons de code
    LET $duplicate_codes = SELECT code, COUNT(*) as count 
                          FROM sale_order_status 
                          WHERE is_active = true 
                          GROUP BY code 
                          HAVING count > 1;
    
    FOR $dup IN $duplicate_codes {
        array::push($errors, "Code dupliqué: " + $dup.code);
    };
    
    RETURN {
        success: count($errors) == 0,
        errors: $errors,
        message: IF count($errors) == 0 THEN "Validation réussie" ELSE "Erreurs détectées"
    };
};

-- Fonction pour obtenir les statistiques globales
DEFINE FUNCTION fn::get_sale_order_status_statistics() {
    LET $total_statuses = SELECT count() FROM sale_order_status;
    LET $active_statuses = SELECT count() FROM sale_order_status WHERE is_active = true;
    LET $inactive_statuses = SELECT count() FROM sale_order_status WHERE is_active = false;
    LET $final_statuses = SELECT count() FROM sale_order_status WHERE is_final = true AND is_active = true;
    
    -- Statut le plus utilisé
    LET $most_used = SELECT 
        status.code,
        status.name,
        COUNT(*) as usage_count
    FROM sale_order so
    JOIN sale_order_status status ON so.status_id = status.id
    WHERE status.is_active = true
    GROUP BY status.id, status.code, status.name
    ORDER BY usage_count DESC
    LIMIT 1;
    
    -- Statut le moins utilisé
    LET $least_used = SELECT 
        status.code,
        status.name,
        COUNT(*) as usage_count
    FROM sale_order so
    JOIN sale_order_status status ON so.status_id = status.id
    WHERE status.is_active = true
    GROUP BY status.id, status.code, status.name
    ORDER BY usage_count ASC
    LIMIT 1;
    
    RETURN {
        total_statuses: $total_statuses,
        active_statuses: $active_statuses,
        inactive_statuses: $inactive_statuses,
        final_statuses: $final_statuses,
        most_used_status: $most_used,
        least_used_status: $least_used
    };
}; 