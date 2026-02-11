-- =====================================================================
-- FONCTION UPDATE - Sale Order Status
-- =====================================================================

DEFINE FUNCTION fn::update_sale_order_status(
    $id: record<sale_order_status>,
    $code: string,
    $name: string,
    $sequence: int,
    $color: string,
    $icon: string,
    $is_final: bool,
    $allows_modification: bool,
    $description: string
) {
    -- Vérifier que le statut existe
    LET $existing = SELECT * FROM sale_order_status WHERE id = $id LIMIT 1;
    IF !$existing {
        THROW "Statut non trouvé avec l'ID: " + string($id);
    };
    
    -- Vérifier que le statut est actif
    IF !$existing.is_active {
        THROW "Impossible de modifier un statut désactivé";
    };
    
    -- Si le code change, vérifier qu'il n'existe pas déjà
    IF $code AND $code != $existing.code {
        LET $code_exists = SELECT id FROM sale_order_status 
                          WHERE code = $code AND id != $id LIMIT 1;
        IF $code_exists {
            THROW "Un statut avec le code '" + $code + "' existe déjà";
        };
    };
    
    -- Si la séquence change, vérifier qu'elle n'existe pas déjà
    IF $sequence AND $sequence != $existing.sequence {
        LET $seq_exists = SELECT id FROM sale_order_status 
                         WHERE sequence = $sequence AND id != $id LIMIT 1;
        IF $seq_exists {
            THROW "Un statut avec la séquence " + string($sequence) + " existe déjà";
        };
    };
    
    -- Mettre à jour le statut
    LET $updated_status = UPDATE sale_order_status SET
        code = $code OR code,
        name = $name OR name,
        sequence = $sequence OR sequence,
        color = $color OR color,
        icon = $icon OR icon,
        is_final = $is_final OR is_final,
        allows_modification = $allows_modification OR allows_modification,
        description = $description OR description,
        updated_on = time::now()
    WHERE id = $id;
    
    RETURN {
        success: true,
        message: "Statut mis à jour avec succès",
        data: $updated_status
    };
}; 