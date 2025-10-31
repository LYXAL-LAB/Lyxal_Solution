-- =====================================================================
-- FONCTION ACTIVATE - Sale Order Status
-- =====================================================================

DEFINE FUNCTION fn::activate_sale_order_status($id: record<sale_order_status>) {
    -- Vérifier que le statut existe
    LET $status = SELECT * FROM sale_order_status WHERE id = $id LIMIT 1;
    IF !$status {
        THROW "Statut non trouvé avec l'ID: " + string($id);
    };
    
    -- Vérifier que le statut est inactif
    IF $status.is_active {
        RETURN {
            success: true,
            message: "Le statut est déjà actif"
        };
    };
    
    -- Vérifier les conflits de séquence avec les statuts actifs
    LET $sequence_conflict = SELECT id FROM sale_order_status 
                            WHERE sequence = $status.sequence 
                            AND is_active = true 
                            AND id != $id LIMIT 1;
    IF $sequence_conflict {
        THROW "Conflit de séquence: un statut actif utilise déjà la séquence " + string($status.sequence);
    };
    
    -- Vérifier les conflits de code avec les statuts actifs
    LET $code_conflict = SELECT id FROM sale_order_status 
                        WHERE code = $status.code 
                        AND is_active = true 
                        AND id != $id LIMIT 1;
    IF $code_conflict {
        THROW "Conflit de code: un statut actif utilise déjà le code " + $status.code;
    };
    
    -- Activer le statut
    LET $activated_status = UPDATE sale_order_status SET
        is_active = true,
        updated_on = time::now()
    WHERE id = $id;
    
    RETURN {
        success: true,
        message: "Statut activé avec succès",
        data: $activated_status
    };
};

-- Fonction pour activer par code
DEFINE FUNCTION fn::activate_sale_order_status_by_code($code: string) {
    LET $status = SELECT id FROM sale_order_status WHERE code = $code LIMIT 1;
    IF !$status {
        THROW "Statut non trouvé avec le code: " + $code;
    };
    
    RETURN fn::activate_sale_order_status($status.id);
}; 