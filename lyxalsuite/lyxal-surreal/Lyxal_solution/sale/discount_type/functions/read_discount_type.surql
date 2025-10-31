-- =====================================================
-- FONCTIONS DE LECTURE: discount_type
-- Description: Fonctions de lecture et consultation des types de remise
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: read_discount_type
-- Description: Lecture d'un type par ID
-- =====================================================

DEFINE FUNCTION fn::read_discount_type($id: record<discount_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de remise est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $discount_type = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$discount_type {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Aucun type de remise trouvé avec cet ID"
        };
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Type de remise trouvé",
        data: $discount_type[0]
    };
};

-- =====================================================
-- FONCTION: read_discount_type_by_code
-- Description: Lecture d'un type par code
-- =====================================================

DEFINE FUNCTION fn::read_discount_type_by_code($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code du type de remise est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $discount_type = SELECT * FROM discount_type WHERE code = $code LIMIT 1;
    
    -- Vérification de l'existence
    IF !$discount_type {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Aucun type de remise trouvé avec ce code"
        };
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Type de remise trouvé",
        data: $discount_type[0]
    };
};

-- =====================================================
-- FONCTION: read_discount_type_with_usage
-- Description: Lecture avec statistiques d'utilisation
-- =====================================================

DEFINE FUNCTION fn::read_discount_type_with_usage($id: record<discount_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de remise est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $discount_type = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$discount_type {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Aucun type de remise trouvé avec cet ID"
        };
    };
    
    -- Calcul des statistiques d'utilisation
    LET $usage_stats = {
        -- Utilisation dans les commandes
        order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id)[0] OR 0,
        order_line_usage: (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id = $id)[0] OR 0,
        pack_line_usage: (SELECT VALUE count() FROM pack_line WHERE discount_type_id = $id)[0] OR 0,
        
        -- Montants
        total_discount_amount: (SELECT VALUE sum(discount_amount) FROM sale_order WHERE discount_type_id = $id)[0] OR 0,
        avg_discount_amount: (SELECT VALUE avg(discount_amount) FROM sale_order WHERE discount_type_id = $id)[0] OR 0,
        
        -- Statistiques temporelles
        first_used: (SELECT VALUE min(creation_date) FROM sale_order WHERE discount_type_id = $id)[0],
        last_used: (SELECT VALUE max(creation_date) FROM sale_order WHERE discount_type_id = $id)[0],
        
        -- Clients uniques
        unique_clients: (SELECT VALUE count(DISTINCT client_partner_id) FROM sale_order WHERE discount_type_id = $id)[0] OR 0
    };
    
    -- Calcul du total d'utilisation
    LET $total_usage = $usage_stats.order_usage + $usage_stats.order_line_usage + $usage_stats.pack_line_usage;
    
    -- Vérification des limites d'utilisation
    LET $usage_limits = {
        max_usage_count: $discount_type[0].max_usage_count,
        current_usage: $total_usage,
        usage_remaining: IF $discount_type[0].max_usage_count THEN $discount_type[0].max_usage_count - $total_usage ELSE NONE END,
        is_usage_exceeded: IF $discount_type[0].max_usage_count THEN $total_usage >= $discount_type[0].max_usage_count ELSE false END
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Type de remise trouvé avec statistiques",
        data: $discount_type[0],
        usage_stats: $usage_stats,
        usage_limits: $usage_limits
    };
};

-- =====================================================
-- FONCTION: read_multiple_discount_types
-- Description: Lecture de plusieurs types par IDs
-- =====================================================

DEFINE FUNCTION fn::read_multiple_discount_types($ids: array<record<discount_type>>) {
    -- Validation du paramètre
    IF !$ids OR array::len($ids) == 0 {
        RETURN {
            success: false,
            error: "La liste des IDs est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : IDs manquants"
        };
    };
    
    -- Lecture des enregistrements
    LET $discount_types = SELECT * FROM discount_type WHERE id IN $ids ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise trouvés",
        requested_count: array::len($ids),
        found_count: array::len($discount_types),
        data: $discount_types
    };
};

-- =====================================================
-- FONCTION: read_discount_types_by_codes
-- Description: Lecture de plusieurs types par codes
-- =====================================================

DEFINE FUNCTION fn::read_discount_types_by_codes($codes: array<string>) {
    -- Validation du paramètre
    IF !$codes OR array::len($codes) == 0 {
        RETURN {
            success: false,
            error: "La liste des codes est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : codes manquants"
        };
    };
    
    -- Lecture des enregistrements
    LET $discount_types = SELECT * FROM discount_type WHERE code IN $codes ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise trouvés",
        requested_count: array::len($codes),
        found_count: array::len($discount_types),
        data: $discount_types
    };
};

-- =====================================================
-- FONCTION: check_discount_type_exists
-- Description: Vérification d'existence d'un type
-- =====================================================

DEFINE FUNCTION fn::check_discount_type_exists($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code du type de remise est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $exists = SELECT VALUE count() FROM discount_type WHERE code = $code LIMIT 1;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Vérification d'existence effectuée",
        exists: $exists[0] > 0,
        code: $code
    };
};

-- =====================================================
-- FONCTION: get_discount_type_details
-- Description: Détails complets avec métadonnées
-- =====================================================

DEFINE FUNCTION fn::get_discount_type_details($id: record<discount_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de remise est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $discount_type = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$discount_type {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Aucun type de remise trouvé avec cet ID"
        };
    };
    
    -- Calcul des métadonnées
    LET $metadata = {
        can_be_deleted: $discount_type[0].allows_deletion AND !$discount_type[0].is_system,
        can_be_modified: !$discount_type[0].is_system,
        is_in_use: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id LIMIT 1)[0] > 0,
        is_valid_now: IF $discount_type[0].valid_from AND $discount_type[0].valid_to THEN
            (time::now() >= $discount_type[0].valid_from AND time::now() <= $discount_type[0].valid_to)
        ELSE IF $discount_type[0].valid_from THEN
            time::now() >= $discount_type[0].valid_from
        ELSE IF $discount_type[0].valid_to THEN
            time::now() <= $discount_type[0].valid_to
        ELSE true END,
        age_days: math::floor(time::unix(time::now()) - time::unix($discount_type[0].created_on)) / 86400,
        last_modified_days: math::floor(time::unix(time::now()) - time::unix($discount_type[0].updated_on)) / 86400
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Détails complets du type de remise",
        data: $discount_type[0],
        metadata: $metadata
    };
};

-- =====================================================
-- FONCTION: get_valid_discount_types
-- Description: Types valides à la date donnée
-- =====================================================

DEFINE FUNCTION fn::get_valid_discount_types($date: datetime) {
    -- Utilisation de la date actuelle si non fournie
    LET $check_date = $date OR time::now();
    
    -- Recherche des types valides
    LET $valid_types = SELECT * FROM discount_type 
        WHERE is_active = true
        AND (valid_from IS NONE OR valid_from <= $check_date)
        AND (valid_to IS NONE OR valid_to >= $check_date)
        ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise valides trouvés",
        check_date: $check_date,
        count: array::len($valid_types),
        data: $valid_types
    };
};

-- =====================================================
-- FONCTION: get_discount_types_by_calculation_method
-- Description: Types par méthode de calcul
-- =====================================================

DEFINE FUNCTION fn::get_discount_types_by_calculation_method($method: string) {
    -- Validation du paramètre
    IF !$method OR !($method IN ["FIXED", "PERCENT", "FORMULA"]) {
        RETURN {
            success: false,
            error: "La méthode de calcul doit être FIXED, PERCENT ou FORMULA",
            message: "Erreur de validation : méthode invalide"
        };
    };
    
    -- Recherche des types par méthode
    LET $types = SELECT * FROM discount_type 
        WHERE is_active = true 
        AND calculation_method = $method
        ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Types de remise trouvés par méthode de calcul",
        calculation_method: $method,
        count: array::len($types),
        data: $types
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Lecture par ID:
   SELECT fn::read_discount_type(discount_type:AMOUNT);

2. Lecture par code:
   SELECT fn::read_discount_type_by_code("AMOUNT");

3. Lecture avec statistiques:
   SELECT fn::read_discount_type_with_usage(discount_type:PERCENTAGE);

4. Lecture multiple par IDs:
   SELECT fn::read_multiple_discount_types([
       discount_type:AMOUNT,
       discount_type:PERCENTAGE
   ]);

5. Lecture multiple par codes:
   SELECT fn::read_discount_types_by_codes(["AMOUNT", "PERCENTAGE"]);

6. Vérification d'existence:
   SELECT fn::check_discount_type_exists("VOLUME");

7. Détails complets:
   SELECT fn::get_discount_type_details(discount_type:AMOUNT);

8. Types valides maintenant:
   SELECT fn::get_valid_discount_types(time::now());

9. Types par méthode de calcul:
   SELECT fn::get_discount_types_by_calculation_method("PERCENT");

STATISTIQUES DISPONIBLES:
- order_usage: Utilisation dans les commandes
- order_line_usage: Utilisation dans les lignes de commande
- pack_line_usage: Utilisation dans les lignes de pack
- total_discount_amount: Montant total des remises
- avg_discount_amount: Montant moyen des remises
- first_used/last_used: Dates d'utilisation
- unique_clients: Nombre de clients uniques

MÉTADONNÉES DISPONIBLES:
- can_be_deleted: Peut être supprimé
- can_be_modified: Peut être modifié
- is_in_use: Actuellement utilisé
- is_valid_now: Valide à la date actuelle
- age_days: Âge en jours
- last_modified_days: Dernière modification en jours

LIMITES D'UTILISATION:
- max_usage_count: Limite globale d'utilisation
- current_usage: Utilisation actuelle
- usage_remaining: Utilisations restantes
- is_usage_exceeded: Limite dépassée

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object/array (si succès),
    error: string (si erreur)
}
*/ 