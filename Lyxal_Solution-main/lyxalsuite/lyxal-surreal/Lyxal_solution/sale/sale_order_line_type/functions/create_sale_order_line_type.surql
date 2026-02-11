-- =====================================================
-- FONCTION: create_sale_order_line_type
-- Description: Création d'un nouveau type de ligne de commande de vente
-- Version: 1.0
-- =====================================================

-- Fonction principale de création
DEFINE FUNCTION fn::create_sale_order_line_type(
    $code: string,
    $name: string,
    $sequence: int,
    $description: string,
    $affects_stock: bool,
    $affects_pricing: bool,
    $is_printable: bool,
    $allows_modification: bool,
    $allows_deletion: bool,
    $color: string,
    $icon: string,
    $requires_validation: bool,
    $min_quantity: decimal,
    $max_quantity: decimal
) {
    -- Validation des paramètres obligatoires
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : code manquant"
        };
    };
    
    IF !$name OR $name == "" {
        RETURN {
            success: false,
            error: "Le nom est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : nom manquant"
        };
    };
    
    IF !$sequence OR $sequence <= 0 {
        RETURN {
            success: false,
            error: "La séquence est obligatoire et doit être positive",
            message: "Erreur de validation : séquence invalide"
        };
    };
    
    -- Validation de la couleur (si fournie)
    IF $color AND !string::starts_with($color, "#") {
        RETURN {
            success: false,
            error: "La couleur doit être un code hexadécimal valide (ex: #FF0000)",
            message: "Erreur de validation : format de couleur invalide"
        };
    };
    
    -- Validation des quantités
    IF $min_quantity AND $max_quantity AND $max_quantity < $min_quantity {
        RETURN {
            success: false,
            error: "La quantité maximale doit être supérieure ou égale à la quantité minimale",
            message: "Erreur de validation : quantités incohérentes"
        };
    };
    
    -- Vérification de l'unicité du code
    LET $existing_code = SELECT VALUE id FROM sale_order_line_type WHERE code = $code LIMIT 1;
    IF $existing_code {
        RETURN {
            success: false,
            error: "Un type de ligne avec ce code existe déjà",
            message: "Erreur de validation : code déjà utilisé",
            existing_id: $existing_code[0]
        };
    };
    
    -- Vérification de l'unicité de la séquence
    LET $existing_sequence = SELECT VALUE id FROM sale_order_line_type WHERE sequence = $sequence LIMIT 1;
    IF $existing_sequence {
        RETURN {
            success: false,
            error: "Un type de ligne avec cette séquence existe déjà",
            message: "Erreur de validation : séquence déjà utilisée",
            existing_id: $existing_sequence[0]
        };
    };
    
    -- Préparation des valeurs avec défauts
    LET $final_description = $description OR "";
    LET $final_affects_stock = IF $affects_stock != NONE THEN $affects_stock ELSE true END;
    LET $final_affects_pricing = IF $affects_pricing != NONE THEN $affects_pricing ELSE true END;
    LET $final_is_printable = IF $is_printable != NONE THEN $is_printable ELSE true END;
    LET $final_allows_modification = IF $allows_modification != NONE THEN $allows_modification ELSE true END;
    LET $final_allows_deletion = IF $allows_deletion != NONE THEN $allows_deletion ELSE true END;
    LET $final_color = $color OR "#6c757d";
    LET $final_icon = $icon OR "Box";
    LET $final_requires_validation = IF $requires_validation != NONE THEN $requires_validation ELSE false END;
    LET $final_min_quantity = $min_quantity OR 0;
    LET $final_max_quantity = $max_quantity OR NONE;
    
    -- Création de l'enregistrement
    LET $new_type = CREATE sale_order_line_type CONTENT {
        code: $code,
        name: $name,
        description: $final_description,
        sequence: $sequence,
        affects_stock: $final_affects_stock,
        affects_pricing: $final_affects_pricing,
        is_printable: $final_is_printable,
        allows_modification: $final_allows_modification,
        allows_deletion: $final_allows_deletion,
        color: $final_color,
        icon: $final_icon,
        requires_validation: $final_requires_validation,
        min_quantity: $final_min_quantity,
        max_quantity: $final_max_quantity,
        is_active: true,
        is_system: false,
        created_on: time::now(),
        updated_on: time::now()
    };
    
    -- Vérification de la création
    IF !$new_type {
        RETURN {
            success: false,
            error: "Erreur lors de la création du type de ligne",
            message: "Erreur système : création échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de ligne de commande créé avec succès",
        data: $new_type[0]
    };
};

-- =====================================================
-- FONCTION: create_sale_order_line_type_simple
-- Description: Création simplifiée avec paramètres minimaux
-- =====================================================

DEFINE FUNCTION fn::create_sale_order_line_type_simple(
    $code: string,
    $name: string,
    $sequence: int
) {
    RETURN fn::create_sale_order_line_type(
        $code,
        $name,
        $sequence,
        NONE,  -- description
        NONE,  -- affects_stock (défaut: true)
        NONE,  -- affects_pricing (défaut: true)
        NONE,  -- is_printable (défaut: true)
        NONE,  -- allows_modification (défaut: true)
        NONE,  -- allows_deletion (défaut: true)
        NONE,  -- color (défaut: #6c757d)
        NONE,  -- icon (défaut: Box)
        NONE,  -- requires_validation (défaut: false)
        NONE,  -- min_quantity (défaut: 0)
        NONE   -- max_quantity (défaut: NONE)
    );
};

-- =====================================================
-- FONCTION: create_sale_order_line_type_with_config
-- Description: Création avec configuration comportementale
-- =====================================================

DEFINE FUNCTION fn::create_sale_order_line_type_with_config(
    $code: string,
    $name: string,
    $sequence: int,
    $config: object
) {
    RETURN fn::create_sale_order_line_type(
        $code,
        $name,
        $sequence,
        $config.description,
        $config.affects_stock,
        $config.affects_pricing,
        $config.is_printable,
        $config.allows_modification,
        $config.allows_deletion,
        $config.color,
        $config.icon,
        $config.requires_validation,
        $config.min_quantity,
        $config.max_quantity
    );
};

-- =====================================================
-- FONCTION: batch_create_sale_order_line_types
-- Description: Création en lot de plusieurs types
-- =====================================================

DEFINE FUNCTION fn::batch_create_sale_order_line_types($types: array<object>) {
    LET $results = [];
    LET $errors = [];
    LET $success_count = 0;
    
    FOR $type IN $types {
        LET $result = fn::create_sale_order_line_type_with_config(
            $type.code,
            $type.name,
            $type.sequence,
            $type
        );
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.data);
        } ELSE {
            $errors = array::push($errors, {
                code: $type.code,
                error: $result.error,
                message: $result.message
            });
        };
    };
    
    RETURN {
        success: $success_count > 0,
        message: "Création en lot terminée",
        total_requested: array::len($types),
        success_count: $success_count,
        error_count: array::len($errors),
        created_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Création complète:
   SELECT fn::create_sale_order_line_type(
       "CUSTOM_TYPE", "Type personnalisé", 10, "Description",
       true, true, true, true, true, "#28a745", "Settings",
       false, 1, 100
   );

2. Création simple:
   SELECT fn::create_sale_order_line_type_simple("BASIC", "Basique", 5);

3. Création avec configuration:
   SELECT fn::create_sale_order_line_type_with_config("ADVANCED", "Avancé", 15, {
       description: "Type avancé avec options",
       color: "#007bff",
       icon: "Star",
       requires_validation: true
   });

4. Création en lot:
   SELECT fn::batch_create_sale_order_line_types([
       {code: "TYPE1", name: "Type 1", sequence: 1},
       {code: "TYPE2", name: "Type 2", sequence: 2}
   ]);

VALIDATIONS EFFECTUÉES:
- Code obligatoire et unique
- Nom obligatoire
- Séquence positive et unique
- Format de couleur hexadécimal
- Cohérence des quantités min/max
- Vérification d'existence avant création

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    error: string (si erreur)
}
*/ 