-- =====================================================
-- FONCTIONS DE LECTURE: sale_order_line_type
-- Description: Fonctions de lecture et consultation des types de ligne
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: read_sale_order_line_type
-- Description: Lecture d'un type par ID
-- =====================================================

DEFINE FUNCTION fn::read_sale_order_line_type($id: record<sale_order_line_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $type = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$type {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec cet ID"
        };
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Type de ligne trouvé",
        data: $type[0]
    };
};

-- =====================================================
-- FONCTION: read_sale_order_line_type_by_code
-- Description: Lecture d'un type par code
-- =====================================================

DEFINE FUNCTION fn::read_sale_order_line_type_by_code($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code du type de ligne est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $type = SELECT * FROM sale_order_line_type WHERE code = $code LIMIT 1;
    
    -- Vérification de l'existence
    IF !$type {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec ce code"
        };
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Type de ligne trouvé",
        data: $type[0]
    };
};

-- =====================================================
-- FONCTION: read_sale_order_line_type_with_usage
-- Description: Lecture avec statistiques d'utilisation
-- =====================================================

DEFINE FUNCTION fn::read_sale_order_line_type_with_usage($id: record<sale_order_line_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $type = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$type {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec cet ID"
        };
    };
    
    -- Calcul des statistiques d'utilisation
    LET $usage_stats = {
        total_lines: (SELECT VALUE count() FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        active_orders: (SELECT VALUE count(DISTINCT sale_order_id) FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        total_quantity: (SELECT VALUE sum(qty) FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        total_amount: (SELECT VALUE sum(in_tax_total) FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        avg_quantity: (SELECT VALUE avg(qty) FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        avg_amount: (SELECT VALUE avg(in_tax_total) FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        last_used: (SELECT VALUE max(creation_date) FROM sale_order_line WHERE type_id = $id)[0]
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Type de ligne trouvé avec statistiques",
        data: $type[0],
        usage_stats: $usage_stats
    };
};

-- =====================================================
-- FONCTION: read_multiple_sale_order_line_types
-- Description: Lecture de plusieurs types par IDs
-- =====================================================

DEFINE FUNCTION fn::read_multiple_sale_order_line_types($ids: array<record<sale_order_line_type>>) {
    -- Validation du paramètre
    IF !$ids OR array::len($ids) == 0 {
        RETURN {
            success: false,
            error: "La liste des IDs est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : IDs manquants"
        };
    };
    
    -- Lecture des enregistrements
    LET $types = SELECT * FROM sale_order_line_type WHERE id IN $ids ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de ligne trouvés",
        requested_count: array::len($ids),
        found_count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- FONCTION: read_sale_order_line_types_by_codes
-- Description: Lecture de plusieurs types par codes
-- =====================================================

DEFINE FUNCTION fn::read_sale_order_line_types_by_codes($codes: array<string>) {
    -- Validation du paramètre
    IF !$codes OR array::len($codes) == 0 {
        RETURN {
            success: false,
            error: "La liste des codes est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : codes manquants"
        };
    };
    
    -- Lecture des enregistrements
    LET $types = SELECT * FROM sale_order_line_type WHERE code IN $codes ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de ligne trouvés",
        requested_count: array::len($codes),
        found_count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- FONCTION: check_sale_order_line_type_exists
-- Description: Vérification d'existence d'un type
-- =====================================================

DEFINE FUNCTION fn::check_sale_order_line_type_exists($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code du type de ligne est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $exists = SELECT VALUE count() FROM sale_order_line_type WHERE code = $code LIMIT 1;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Vérification d'existence effectuée",
        exists: $exists[0] > 0,
        code: $code
    };
};

-- =====================================================
-- FONCTION: get_sale_order_line_type_details
-- Description: Détails complets avec métadonnées
-- =====================================================

DEFINE FUNCTION fn::get_sale_order_line_type_details($id: record<sale_order_line_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $type = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$type {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec cet ID"
        };
    };
    
    -- Calcul des métadonnées
    LET $metadata = {
        can_be_deleted: $type[0].allows_deletion AND !$type[0].is_system,
        can_be_modified: $type[0].allows_modification,
        is_in_use: (SELECT VALUE count() FROM sale_order_line WHERE type_id = $id LIMIT 1)[0] > 0,
        age_days: math::floor(time::unix(time::now()) - time::unix($type[0].created_on)) / 86400,
        last_modified_days: math::floor(time::unix(time::now()) - time::unix($type[0].updated_on)) / 86400
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Détails complets du type de ligne",
        data: $type[0],
        metadata: $metadata
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Lecture par ID:
   SELECT fn::read_sale_order_line_type(sale_order_line_type:NORMAL);

2. Lecture par code:
   SELECT fn::read_sale_order_line_type_by_code("NORMAL");

3. Lecture avec statistiques:
   SELECT fn::read_sale_order_line_type_with_usage(sale_order_line_type:NORMAL);

4. Lecture multiple par IDs:
   SELECT fn::read_multiple_sale_order_line_types([
       sale_order_line_type:NORMAL,
       sale_order_line_type:TITLE
   ]);

5. Lecture multiple par codes:
   SELECT fn::read_sale_order_line_types_by_codes(["NORMAL", "TITLE"]);

6. Vérification d'existence:
   SELECT fn::check_sale_order_line_type_exists("NORMAL");

7. Détails complets:
   SELECT fn::get_sale_order_line_type_details(sale_order_line_type:NORMAL);

STATISTIQUES DISPONIBLES:
- total_lines: Nombre total de lignes utilisant ce type
- active_orders: Nombre de commandes distinctes
- total_quantity: Quantité totale
- total_amount: Montant total
- avg_quantity: Quantité moyenne
- avg_amount: Montant moyen
- last_used: Date de dernière utilisation

MÉTADONNÉES DISPONIBLES:
- can_be_deleted: Peut être supprimé
- can_be_modified: Peut être modifié
- is_in_use: Actuellement utilisé
- age_days: Âge en jours
- last_modified_days: Dernière modification en jours

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object/array (si succès),
    error: string (si erreur)
}
*/ 