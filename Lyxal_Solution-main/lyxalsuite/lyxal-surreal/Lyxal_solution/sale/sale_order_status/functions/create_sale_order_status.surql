-- =====================================================================
-- FONCTION CREATE - Sale Order Status
-- =====================================================================

DEFINE FUNCTION fn::create_sale_order_status(
    $code: string,
    $name: string,
    $sequence: int,
    $color: string,
    $icon: string,
    $is_final: bool,
    $allows_modification: bool,
    $description: string
) {
    -- Validation des paramètres obligatoires
    IF !$code OR !$name {
        THROW "Code et nom sont obligatoires";
    };
    
    -- Vérifier que le code n'existe pas déjà
    LET $existing = SELECT id FROM sale_order_status WHERE code = $code LIMIT 1;
    IF $existing {
        THROW "Un statut avec le code '" + $code + "' existe déjà";
    };
    
    -- Vérifier que la séquence n'existe pas déjà
    LET $existing_seq = SELECT id FROM sale_order_status WHERE sequence = $sequence LIMIT 1;
    IF $existing_seq {
        THROW "Un statut avec la séquence " + string($sequence) + " existe déjà";
    };
    
    -- Créer le nouveau statut
    LET $new_status = CREATE sale_order_status SET
        code = $code,
        name = $name,
        sequence = $sequence,
        color = $color OR "#6c757d",
        icon = $icon OR "fa-circle",
        is_final = $is_final OR false,
        allows_modification = $allows_modification OR true,
        description = $description,
        is_active = true,
        created_on = time::now(),
        updated_on = time::now();
    
    RETURN {
        success: true,
        message: "Statut créé avec succès",
        data: $new_status
    };
}; 