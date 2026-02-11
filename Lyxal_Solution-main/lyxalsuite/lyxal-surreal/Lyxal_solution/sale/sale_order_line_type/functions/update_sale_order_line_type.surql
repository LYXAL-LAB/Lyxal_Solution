-- =====================================================
-- FONCTION: update_sale_order_line_type
-- Description: Mise à jour d'un type de ligne de commande de vente
-- Version: 1.0
-- =====================================================

-- Fonction principale de mise à jour
DEFINE FUNCTION fn::update_sale_order_line_type(
    $id: record<sale_order_line_type>,
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
    -- Validation du paramètre ID
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $existing = SELECT * FROM $id;
    IF !$existing {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec cet ID"
        };
    };
    
    -- Vérification des permissions de modification
    IF !$existing[0].allows_modification {
        RETURN {
            success: false,
            error: "Ce type de ligne ne peut pas être modifié",
            message: "Erreur de permission : modification interdite"
        };
    };
    
    -- Protection des types système
    IF $existing[0].is_system AND ($code OR $name) {
        RETURN {
            success: false,
            error: "Les types système ne peuvent pas avoir leur code ou nom modifié",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Validation du code (si fourni)
    IF $code {
        IF $code == "" {
            RETURN {
                success: false,
                error: "Le code ne peut pas être vide",
                message: "Erreur de validation : code vide"
            };
        };
        
        -- Vérification de l'unicité du code (si différent)
        IF $code != $existing[0].code {
            LET $existing_code = SELECT VALUE id FROM sale_order_line_type WHERE code = $code LIMIT 1;
            IF $existing_code {
                RETURN {
                    success: false,
                    error: "Un type de ligne avec ce code existe déjà",
                    message: "Erreur de validation : code déjà utilisé",
                    existing_id: $existing_code[0]
                };
            };
        };
    };
    
    -- Validation du nom (si fourni)
    IF $name AND $name == "" {
        RETURN {
            success: false,
            error: "Le nom ne peut pas être vide",
            message: "Erreur de validation : nom vide"
        };
    };
    
    -- Validation de la séquence (si fournie)
    IF $sequence {
        IF $sequence <= 0 {
            RETURN {
                success: false,
                error: "La séquence doit être positive",
                message: "Erreur de validation : séquence invalide"
            };
        };
        
        -- Vérification de l'unicité de la séquence (si différente)
        IF $sequence != $existing[0].sequence {
            LET $existing_sequence = SELECT VALUE id FROM sale_order_line_type WHERE sequence = $sequence LIMIT 1;
            IF $existing_sequence {
                RETURN {
                    success: false,
                    error: "Un type de ligne avec cette séquence existe déjà",
                    message: "Erreur de validation : séquence déjà utilisée",
                    existing_id: $existing_sequence[0]
                };
            };
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
    LET $final_min_quantity = $min_quantity OR $existing[0].min_quantity;
    LET $final_max_quantity = $max_quantity OR $existing[0].max_quantity;
    
    IF $final_min_quantity AND $final_max_quantity AND $final_max_quantity < $final_min_quantity {
        RETURN {
            success: false,
            error: "La quantité maximale doit être supérieure ou égale à la quantité minimale",
            message: "Erreur de validation : quantités incohérentes"
        };
    };
    
    -- Préparation de l'objet de mise à jour
    LET $update_data = {};
    
    -- Ajout conditionnel des champs à mettre à jour
    IF $code { $update_data.code = $code; };
    IF $name { $update_data.name = $name; };
    IF $sequence { $update_data.sequence = $sequence; };
    IF $description != NONE { $update_data.description = $description; };
    IF $affects_stock != NONE { $update_data.affects_stock = $affects_stock; };
    IF $affects_pricing != NONE { $update_data.affects_pricing = $affects_pricing; };
    IF $is_printable != NONE { $update_data.is_printable = $is_printable; };
    IF $allows_modification != NONE { $update_data.allows_modification = $allows_modification; };
    IF $allows_deletion != NONE { $update_data.allows_deletion = $allows_deletion; };
    IF $color { $update_data.color = $color; };
    IF $icon { $update_data.icon = $icon; };
    IF $requires_validation != NONE { $update_data.requires_validation = $requires_validation; };
    IF $min_quantity != NONE { $update_data.min_quantity = $min_quantity; };
    IF $max_quantity != NONE { $update_data.max_quantity = $max_quantity; };
    
    -- Mise à jour du timestamp
    $update_data.updated_on = time::now();
    
    -- Vérification qu'il y a quelque chose à mettre à jour
    IF object::len($update_data) == 1 { -- Seulement updated_on
        RETURN {
            success: true,
            message: "Aucune modification à effectuer",
            data: $existing[0]
        };
    };
    
    -- Mise à jour de l'enregistrement
    LET $updated_type = UPDATE $id MERGE $update_data;
    
    -- Vérification de la mise à jour
    IF !$updated_type {
        RETURN {
            success: false,
            error: "Erreur lors de la mise à jour du type de ligne",
            message: "Erreur système : mise à jour échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de ligne mis à jour avec succès",
        data: $updated_type[0],
        updated_fields: object::keys($update_data)
    };
};

-- =====================================================
-- FONCTION: update_sale_order_line_type_partial
-- Description: Mise à jour partielle avec objet
-- =====================================================

DEFINE FUNCTION fn::update_sale_order_line_type_partial(
    $id: record<sale_order_line_type>,
    $updates: object
) {
    RETURN fn::update_sale_order_line_type(
        $id,
        $updates.code,
        $updates.name,
        $updates.sequence,
        $updates.description,
        $updates.affects_stock,
        $updates.affects_pricing,
        $updates.is_printable,
        $updates.allows_modification,
        $updates.allows_deletion,
        $updates.color,
        $updates.icon,
        $updates.requires_validation,
        $updates.min_quantity,
        $updates.max_quantity
    );
};

-- =====================================================
-- FONCTION: update_sale_order_line_type_sequence
-- Description: Mise à jour de la séquence uniquement
-- =====================================================

DEFINE FUNCTION fn::update_sale_order_line_type_sequence(
    $id: record<sale_order_line_type>,
    $new_sequence: int
) {
    RETURN fn::update_sale_order_line_type(
        $id,
        NONE, NONE, $new_sequence, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_sale_order_line_type_display
-- Description: Mise à jour des éléments d'affichage
-- =====================================================

DEFINE FUNCTION fn::update_sale_order_line_type_display(
    $id: record<sale_order_line_type>,
    $color: string,
    $icon: string
) {
    RETURN fn::update_sale_order_line_type(
        $id,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, $color, $icon, NONE, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_sale_order_line_type_behavior
-- Description: Mise à jour du comportement métier
-- =====================================================

DEFINE FUNCTION fn::update_sale_order_line_type_behavior(
    $id: record<sale_order_line_type>,
    $affects_stock: bool,
    $affects_pricing: bool,
    $is_printable: bool,
    $requires_validation: bool
) {
    RETURN fn::update_sale_order_line_type(
        $id,
        NONE, NONE, NONE, NONE, $affects_stock, $affects_pricing, $is_printable, NONE, NONE, NONE, NONE, $requires_validation, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_sale_order_line_type_permissions
-- Description: Mise à jour des permissions
-- =====================================================

DEFINE FUNCTION fn::update_sale_order_line_type_permissions(
    $id: record<sale_order_line_type>,
    $allows_modification: bool,
    $allows_deletion: bool
) {
    RETURN fn::update_sale_order_line_type(
        $id,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, $allows_modification, $allows_deletion, NONE, NONE, NONE, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_sale_order_line_type_quantities
-- Description: Mise à jour des quantités min/max
-- =====================================================

DEFINE FUNCTION fn::update_sale_order_line_type_quantities(
    $id: record<sale_order_line_type>,
    $min_quantity: decimal,
    $max_quantity: decimal
) {
    RETURN fn::update_sale_order_line_type(
        $id,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, $min_quantity, $max_quantity
    );
};

-- =====================================================
-- FONCTION: batch_update_sale_order_line_types
-- Description: Mise à jour en lot
-- =====================================================

DEFINE FUNCTION fn::batch_update_sale_order_line_types($updates: array<object>) {
    LET $results = [];
    LET $errors = [];
    LET $success_count = 0;
    
    FOR $update IN $updates {
        IF !$update.id {
            $errors = array::push($errors, {
                error: "ID manquant",
                update: $update
            });
            CONTINUE;
        };
        
        LET $result = fn::update_sale_order_line_type_partial($update.id, $update);
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.data);
        } ELSE {
            $errors = array::push($errors, {
                id: $update.id,
                error: $result.error,
                message: $result.message
            });
        };
    };
    
    RETURN {
        success: $success_count > 0,
        message: "Mise à jour en lot terminée",
        total_requested: array::len($updates),
        success_count: $success_count,
        error_count: array::len($errors),
        updated_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Mise à jour complète:
   SELECT fn::update_sale_order_line_type(
       sale_order_line_type:NORMAL,
       "NEW_CODE", "Nouveau nom", 10, "Nouvelle description",
       true, true, true, true, true, "#28a745", "Star",
       false, 1, 100
   );

2. Mise à jour partielle:
   SELECT fn::update_sale_order_line_type_partial(
       sale_order_line_type:NORMAL,
       {
           name: "Nouveau nom",
           color: "#007bff",
           description: "Nouvelle description"
       }
   );

3. Mise à jour séquence:
   SELECT fn::update_sale_order_line_type_sequence(
       sale_order_line_type:NORMAL, 15
   );

4. Mise à jour affichage:
   SELECT fn::update_sale_order_line_type_display(
       sale_order_line_type:NORMAL, "#28a745", "CheckCircle"
   );

5. Mise à jour comportement:
   SELECT fn::update_sale_order_line_type_behavior(
       sale_order_line_type:NORMAL, true, true, true, false
   );

6. Mise à jour permissions:
   SELECT fn::update_sale_order_line_type_permissions(
       sale_order_line_type:NORMAL, true, false
   );

7. Mise à jour quantités:
   SELECT fn::update_sale_order_line_type_quantities(
       sale_order_line_type:NORMAL, 1, 1000
   );

8. Mise à jour en lot:
   SELECT fn::batch_update_sale_order_line_types([
       {id: sale_order_line_type:NORMAL, name: "Nouveau nom 1"},
       {id: sale_order_line_type:TITLE, color: "#007bff"}
   ]);

VALIDATIONS EFFECTUÉES:
- Existence de l'enregistrement
- Permissions de modification
- Protection des types système
- Unicité du code et de la séquence
- Format de couleur hexadécimal
- Cohérence des quantités min/max
- Vérification des champs obligatoires

PROTECTIONS:
- Types système : code et nom non modifiables
- Permissions : respect du champ allows_modification
- Unicité : vérification des doublons
- Cohérence : validation des données

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    updated_fields: array (champs modifiés),
    error: string (si erreur)
}
*/ 