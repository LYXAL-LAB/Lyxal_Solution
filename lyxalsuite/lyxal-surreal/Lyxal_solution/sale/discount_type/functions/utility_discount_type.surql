-- =====================================================
-- FONCTIONS UTILITAIRES: discount_type
-- Description: Fonctions utilitaires pour la gestion des types de remise
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: reset_discount_type_data
-- Description: Réinitialisation complète des données
-- =====================================================

DEFINE FUNCTION fn::reset_discount_type_data() {
    -- Suppression de toutes les données existantes (sauf système)
    DELETE discount_type WHERE is_system = false;
    
    -- Réinitialisation des données de référence
    LET $reference_data = [
        {
            code: "AMOUNT",
            name: "Montant fixe",
            description: "Remise en montant fixe en devise",
            sequence: 10,
            calculation_method: "FIXED",
            symbol: "€",
            color: "#28a745",
            icon: "Euro",
            is_system: true
        },
        {
            code: "PERCENTAGE",
            name: "Pourcentage",
            description: "Remise en pourcentage du montant",
            sequence: 20,
            calculation_method: "PERCENT",
            symbol: "%",
            color: "#007bff",
            icon: "Percent",
            is_system: true
        },
        {
            code: "VOLUME",
            name: "Remise volume",
            description: "Remise pour commandes importantes",
            sequence: 30,
            calculation_method: "PERCENT",
            symbol: "%",
            min_order_amount: 1000,
            color: "#17a2b8",
            icon: "TrendingUp",
            is_cumulative: false
        },
        {
            code: "EARLY_BIRD",
            name: "Remise anticipée",
            description: "Remise pour commandes anticipées",
            sequence: 40,
            calculation_method: "PERCENT",
            symbol: "%",
            max_value: 15,
            color: "#ffc107",
            icon: "Clock",
            requires_approval: true
        },
        {
            code: "LOYALTY",
            name: "Remise fidélité",
            description: "Remise pour clients fidèles",
            sequence: 50,
            calculation_method: "PERCENT",
            symbol: "%",
            color: "#e83e8c",
            icon: "Heart",
            is_cumulative: true,
            is_automatic: true
        }
    ];
    
    -- Création des données de référence
    FOR $data IN $reference_data {
        CREATE discount_type CONTENT {
            code: $data.code,
            name: $data.name,
            description: $data.description,
            sequence: $data.sequence,
            calculation_method: $data.calculation_method,
            symbol: $data.symbol,
            min_value: $data.min_value,
            max_value: $data.max_value,
            min_order_amount: $data.min_order_amount,
            max_order_amount: $data.max_order_amount,
            is_cumulative: $data.is_cumulative OR false,
            is_automatic: $data.is_automatic OR false,
            requires_approval: $data.requires_approval OR false,
            applies_to_subtotal: $data.applies_to_subtotal OR true,
            applies_to_taxes: $data.applies_to_taxes OR false,
            color: $data.color,
            icon: $data.icon,
            is_active: true,
            is_system: $data.is_system OR false,
            created_on: time::now(),
            updated_on: time::now()
        };
    };
    
    -- Comptage des données créées
    LET $total_count = (SELECT VALUE count() FROM discount_type)[0];
    
    RETURN {
        success: true,
        message: "Données de référence des types de remise réinitialisées avec succès",
        total_count: $total_count,
        reference_data_count: array::len($reference_data)
    };
};

-- =====================================================
-- FONCTION: create_test_discount_type
-- Description: Création d'un type de test
-- =====================================================

DEFINE FUNCTION fn::create_test_discount_type() {
    -- Génération d'un code unique
    LET $test_code = "TEST_" + string::slice(string::replace(string::concat(rand::uuid::v4()), "-", ""), 0, 8);
    
    -- Création du type de test
    LET $test_type = CREATE discount_type CONTENT {
        code: $test_code,
        name: "Type de test - " + $test_code,
        description: "Type de remise créé pour les tests automatisés",
        sequence: 999,
        calculation_method: "PERCENT",
        symbol: "%",
        min_value: 1,
        max_value: 10,
        color: "#6c757d",
        icon: "TestTube",
        is_active: true,
        is_system: false,
        created_on: time::now(),
        updated_on: time::now()
    };
    
    RETURN {
        success: true,
        message: "Type de remise de test créé avec succès",
        data: $test_type[0]
    };
};

-- =====================================================
-- FONCTION: validate_discount_type_data
-- Description: Validation complète des données
-- =====================================================

DEFINE FUNCTION fn::validate_discount_type_data() {
    -- Validation des contraintes
    LET $validation_results = {
        total_count: (SELECT VALUE count() FROM discount_type)[0],
        active_count: (SELECT VALUE count() FROM discount_type WHERE is_active = true)[0],
        system_count: (SELECT VALUE count() FROM discount_type WHERE is_system = true)[0],
        
        -- Vérification des codes uniques
        duplicate_codes: (SELECT code, count() as count FROM discount_type GROUP BY code HAVING count > 1),
        
        -- Vérification des séquences uniques
        duplicate_sequences: (SELECT sequence, count() as count FROM discount_type GROUP BY sequence HAVING count > 1),
        
        -- Vérification des méthodes de calcul
        invalid_calculation_methods: (SELECT * FROM discount_type WHERE calculation_method NOT IN ["FIXED", "PERCENT", "FORMULA"]),
        
        -- Vérification des couleurs
        invalid_colors: (SELECT * FROM discount_type WHERE color IS NOT NONE AND !string::starts_with(color, "#")),
        
        -- Vérification des valeurs min/max
        invalid_value_ranges: (SELECT * FROM discount_type WHERE min_value IS NOT NONE AND max_value IS NOT NONE AND max_value < min_value),
        
        -- Vérification des montants de commande
        invalid_order_amounts: (SELECT * FROM discount_type WHERE min_order_amount IS NOT NONE AND max_order_amount IS NOT NONE AND max_order_amount < min_order_amount),
        
        -- Vérification des dates de validité
        invalid_validity_dates: (SELECT * FROM discount_type WHERE valid_from IS NOT NONE AND valid_to IS NOT NONE AND valid_to < valid_from),
        
        -- Vérification des compteurs d'utilisation
        invalid_usage_counts: (SELECT * FROM discount_type WHERE (max_usage_count IS NOT NONE AND max_usage_count <= 0) OR (max_usage_per_client IS NOT NONE AND max_usage_per_client <= 0))
    };
    
    -- Calcul du score de validation
    LET $error_count = 
        array::len($validation_results.duplicate_codes) +
        array::len($validation_results.duplicate_sequences) +
        array::len($validation_results.invalid_calculation_methods) +
        array::len($validation_results.invalid_colors) +
        array::len($validation_results.invalid_value_ranges) +
        array::len($validation_results.invalid_order_amounts) +
        array::len($validation_results.invalid_validity_dates) +
        array::len($validation_results.invalid_usage_counts);
    
    LET $is_valid = $error_count == 0;
    
    RETURN {
        success: true,
        message: "Validation des données des types de remise terminée",
        is_valid: $is_valid,
        error_count: $error_count,
        validation_results: $validation_results
    };
};

-- =====================================================
-- FONCTION: get_discount_type_statistics
-- Description: Statistiques avancées des types
-- =====================================================

DEFINE FUNCTION fn::get_discount_type_statistics() {
    -- Statistiques générales
    LET $general_stats = {
        total_count: (SELECT VALUE count() FROM discount_type)[0],
        active_count: (SELECT VALUE count() FROM discount_type WHERE is_active = true)[0],
        inactive_count: (SELECT VALUE count() FROM discount_type WHERE is_active = false)[0],
        system_count: (SELECT VALUE count() FROM discount_type WHERE is_system = true)[0],
        user_count: (SELECT VALUE count() FROM discount_type WHERE is_system = false)[0]
    };
    
    -- Statistiques par méthode de calcul
    LET $calculation_stats = {
        fixed_count: (SELECT VALUE count() FROM discount_type WHERE calculation_method = "FIXED")[0],
        percent_count: (SELECT VALUE count() FROM discount_type WHERE calculation_method = "PERCENT")[0],
        formula_count: (SELECT VALUE count() FROM discount_type WHERE calculation_method = "FORMULA")[0]
    };
    
    -- Statistiques comportementales
    LET $behavior_stats = {
        cumulative_count: (SELECT VALUE count() FROM discount_type WHERE is_cumulative = true)[0],
        automatic_count: (SELECT VALUE count() FROM discount_type WHERE is_automatic = true)[0],
        approval_required_count: (SELECT VALUE count() FROM discount_type WHERE requires_approval = true)[0],
        applies_to_subtotal_count: (SELECT VALUE count() FROM discount_type WHERE applies_to_subtotal = true)[0],
        applies_to_taxes_count: (SELECT VALUE count() FROM discount_type WHERE applies_to_taxes = true)[0]
    };
    
    -- Statistiques de validité
    LET $now = time::now();
    LET $validity_stats = {
        valid_now_count: (SELECT VALUE count() FROM discount_type 
            WHERE is_active = true
            AND (valid_from IS NONE OR valid_from <= $now)
            AND (valid_to IS NONE OR valid_to >= $now))[0],
        expired_count: (SELECT VALUE count() FROM discount_type 
            WHERE valid_to IS NOT NONE AND valid_to < $now)[0],
        future_count: (SELECT VALUE count() FROM discount_type 
            WHERE valid_from IS NOT NONE AND valid_from > $now)[0],
        unlimited_validity_count: (SELECT VALUE count() FROM discount_type 
            WHERE valid_from IS NONE AND valid_to IS NONE)[0]
    };
    
    -- Statistiques d'utilisation
    LET $usage_stats = {
        used_in_orders: (SELECT VALUE count(DISTINCT discount_type_id) FROM sale_order WHERE discount_type_id IS NOT NONE)[0],
        used_in_order_lines: (SELECT VALUE count(DISTINCT discount_type_id) FROM sale_order_line WHERE discount_type_id IS NOT NONE)[0],
        used_in_pack_lines: (SELECT VALUE count(DISTINCT discount_type_id) FROM pack_line WHERE discount_type_id IS NOT NONE)[0],
        
        total_order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id IS NOT NONE)[0],
        total_line_usage: (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id IS NOT NONE)[0],
        total_pack_usage: (SELECT VALUE count() FROM pack_line WHERE discount_type_id IS NOT NONE)[0],
        
        avg_discount_amount: (SELECT VALUE avg(discount_amount) FROM sale_order WHERE discount_type_id IS NOT NONE)[0],
        total_discount_amount: (SELECT VALUE sum(discount_amount) FROM sale_order WHERE discount_type_id IS NOT NONE)[0],
        
        unique_clients: (SELECT VALUE count(DISTINCT client_partner_id) FROM sale_order WHERE discount_type_id IS NOT NONE)[0]
    };
    
    -- Top 5 des types les plus utilisés
    LET $top_used_types = SELECT 
        discount_type_id,
        count() as usage_count,
        sum(discount_amount) as total_amount
    FROM sale_order 
    WHERE discount_type_id IS NOT NONE 
    GROUP BY discount_type_id 
    ORDER BY usage_count DESC 
    LIMIT 5;
    
    -- Distribution des séquences
    LET $sequence_stats = {
        min_sequence: (SELECT VALUE min(sequence) FROM discount_type)[0],
        max_sequence: (SELECT VALUE max(sequence) FROM discount_type)[0],
        avg_sequence: (SELECT VALUE avg(sequence) FROM discount_type)[0]
    };
    
    RETURN {
        success: true,
        message: "Statistiques des types de remise récupérées avec succès",
        generated_at: time::now(),
        general_stats: $general_stats,
        calculation_stats: $calculation_stats,
        behavior_stats: $behavior_stats,
        validity_stats: $validity_stats,
        usage_stats: $usage_stats,
        top_used_types: $top_used_types,
        sequence_stats: $sequence_stats
    };
};

-- =====================================================
-- FONCTION: reorder_discount_type_sequences
-- Description: Réorganisation des séquences
-- =====================================================

DEFINE FUNCTION fn::reorder_discount_type_sequences() {
    -- Récupération des types actifs triés par séquence
    LET $active_types = SELECT * FROM discount_type WHERE is_active = true ORDER BY sequence ASC;
    
    -- Réorganisation avec séquences multiples de 10
    LET $updated_count = 0;
    FOR $i, $type IN $active_types {
        LET $new_sequence = ($i + 1) * 10;
        IF $type.sequence != $new_sequence {
            UPDATE $type.id SET sequence = $new_sequence, updated_on = time::now();
            $updated_count = $updated_count + 1;
        };
    };
    
    RETURN {
        success: true,
        message: "Séquences des types de remise réorganisées avec succès",
        total_active_types: array::len($active_types),
        updated_count: $updated_count
    };
};

-- =====================================================
-- FONCTION: export_discount_type_data
-- Description: Export des données pour sauvegarde
-- =====================================================

DEFINE FUNCTION fn::export_discount_type_data() {
    -- Export de toutes les données
    LET $export_data = SELECT * FROM discount_type ORDER BY sequence ASC;
    
    -- Métadonnées d'export
    LET $metadata = {
        export_date: time::now(),
        total_count: array::len($export_data),
        active_count: (SELECT VALUE count() FROM discount_type WHERE is_active = true)[0],
        system_count: (SELECT VALUE count() FROM discount_type WHERE is_system = true)[0],
        version: "1.0"
    };
    
    RETURN {
        success: true,
        message: "Données des types de remise exportées avec succès",
        metadata: $metadata,
        data: $export_data
    };
};

-- =====================================================
-- FONCTION: import_discount_type_data
-- Description: Import de données depuis une sauvegarde
-- =====================================================

DEFINE FUNCTION fn::import_discount_type_data($import_data: array<object>, $replace_existing: bool) {
    -- Validation des données d'import
    IF !$import_data OR array::len($import_data) == 0 {
        RETURN {
            success: false,
            error: "Les données d'import sont obligatoires",
            message: "Erreur de validation : données manquantes"
        };
    };
    
    LET $results = {
        created: [],
        updated: [],
        skipped: [],
        errors: []
    };
    
    FOR $item IN $import_data {
        -- Vérification de l'existence
        LET $existing = SELECT * FROM discount_type WHERE code = $item.code LIMIT 1;
        
        IF $existing {
            IF $replace_existing {
                -- Mise à jour
                LET $updated = UPDATE $existing[0].id MERGE {
                    name: $item.name,
                    description: $item.description,
                    sequence: $item.sequence,
                    calculation_method: $item.calculation_method,
                    symbol: $item.symbol,
                    min_value: $item.min_value,
                    max_value: $item.max_value,
                    min_order_amount: $item.min_order_amount,
                    max_order_amount: $item.max_order_amount,
                    is_cumulative: $item.is_cumulative,
                    is_automatic: $item.is_automatic,
                    requires_approval: $item.requires_approval,
                    applies_to_subtotal: $item.applies_to_subtotal,
                    applies_to_taxes: $item.applies_to_taxes,
                    color: $item.color,
                    icon: $item.icon,
                    valid_from: $item.valid_from,
                    valid_to: $item.valid_to,
                    max_usage_count: $item.max_usage_count,
                    max_usage_per_client: $item.max_usage_per_client,
                    updated_on: time::now()
                };
                
                $results.updated = array::push($results.updated, $updated[0]);
            } ELSE {
                $results.skipped = array::push($results.skipped, $item.code);
            };
        } ELSE {
            -- Création
            LET $created = CREATE discount_type CONTENT {
                code: $item.code,
                name: $item.name,
                description: $item.description,
                sequence: $item.sequence,
                calculation_method: $item.calculation_method,
                symbol: $item.symbol,
                min_value: $item.min_value,
                max_value: $item.max_value,
                min_order_amount: $item.min_order_amount,
                max_order_amount: $item.max_order_amount,
                is_cumulative: $item.is_cumulative OR false,
                is_automatic: $item.is_automatic OR false,
                requires_approval: $item.requires_approval OR false,
                applies_to_subtotal: $item.applies_to_subtotal OR true,
                applies_to_taxes: $item.applies_to_taxes OR false,
                color: $item.color OR "#007bff",
                icon: $item.icon OR "Percent",
                valid_from: $item.valid_from,
                valid_to: $item.valid_to,
                max_usage_count: $item.max_usage_count,
                max_usage_per_client: $item.max_usage_per_client,
                is_active: $item.is_active OR true,
                is_system: $item.is_system OR false,
                created_on: time::now(),
                updated_on: time::now()
            };
            
            $results.created = array::push($results.created, $created[0]);
        };
    };
    
    RETURN {
        success: true,
        message: "Import des données des types de remise terminé",
        results: $results,
        summary: {
            total_processed: array::len($import_data),
            created_count: array::len($results.created),
            updated_count: array::len($results.updated),
            skipped_count: array::len($results.skipped),
            error_count: array::len($results.errors)
        }
    };
};

-- =====================================================
-- FONCTION: calculate_discount_amount
-- Description: Calcul du montant de remise
-- =====================================================

DEFINE FUNCTION fn::calculate_discount_amount(
    $discount_type_id: record<discount_type>,
    $base_amount: decimal,
    $discount_value: decimal
) {
    -- Validation des paramètres
    IF !$discount_type_id OR !$base_amount OR !$discount_value {
        RETURN {
            success: false,
            error: "Tous les paramètres sont obligatoires",
            message: "Erreur de validation : paramètres manquants"
        };
    };
    
    -- Récupération du type de remise
    LET $discount_type = SELECT * FROM $discount_type_id LIMIT 1;
    IF !$discount_type {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Erreur de validation : type inexistant"
        };
    };
    
    -- Calcul selon la méthode
    LET $calculated_amount = IF $discount_type[0].calculation_method = "FIXED" THEN
        $discount_value
    ELSE IF $discount_type[0].calculation_method = "PERCENT" THEN
        ($base_amount * $discount_value) / 100
    ELSE IF $discount_type[0].calculation_method = "FORMULA" THEN
        -- Évaluation de la formule (simplifié)
        $discount_value
    ELSE 0 END;
    
    -- Application des limites
    LET $final_amount = $calculated_amount;
    
    IF $discount_type[0].min_value AND $final_amount < $discount_type[0].min_value {
        $final_amount = $discount_type[0].min_value;
    };
    
    IF $discount_type[0].max_value AND $final_amount > $discount_type[0].max_value {
        $final_amount = $discount_type[0].max_value;
    };
    
    -- Vérification que la remise ne dépasse pas le montant de base
    IF $final_amount > $base_amount {
        $final_amount = $base_amount;
    };
    
    RETURN {
        success: true,
        message: "Montant de remise calculé avec succès",
        discount_type: $discount_type[0],
        base_amount: $base_amount,
        discount_value: $discount_value,
        calculated_amount: $calculated_amount,
        final_amount: $final_amount,
        calculation_method: $discount_type[0].calculation_method
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Réinitialisation des données:
   SELECT fn::reset_discount_type_data();

2. Création d'un type de test:
   SELECT fn::create_test_discount_type();

3. Validation des données:
   SELECT fn::validate_discount_type_data();

4. Statistiques avancées:
   SELECT fn::get_discount_type_statistics();

5. Réorganisation des séquences:
   SELECT fn::reorder_discount_type_sequences();

6. Export des données:
   SELECT fn::export_discount_type_data();

7. Import des données:
   SELECT fn::import_discount_type_data($data, true);

8. Calcul de remise:
   SELECT fn::calculate_discount_amount(
       discount_type:PERCENTAGE, 1000.00, 15
   );

FONCTIONS UTILITAIRES:

1. Gestion des données:
   - reset_discount_type_data: Réinitialisation complète
   - import_discount_type_data: Import depuis sauvegarde
   - export_discount_type_data: Export pour sauvegarde

2. Validation et contrôle:
   - validate_discount_type_data: Validation complète
   - get_discount_type_statistics: Statistiques avancées
   - create_test_discount_type: Création de test

3. Maintenance:
   - reorder_discount_type_sequences: Réorganisation
   - calculate_discount_amount: Calcul de remise

VALIDATION EFFECTUÉE:
- Codes uniques
- Séquences uniques
- Méthodes de calcul valides
- Formats de couleur
- Cohérence des valeurs min/max
- Cohérence des montants de commande
- Cohérence des dates de validité
- Validité des compteurs d'utilisation

STATISTIQUES DISPONIBLES:
- Générales : Total, actifs, inactifs, système
- Par méthode : FIXED, PERCENT, FORMULA
- Comportementales : Cumulable, automatique, approbation
- Validité : Valides, expirés, futurs
- Utilisation : Commandes, lignes, montants, clients
- Top types : Les plus utilisés

CALCUL DE REMISE:
- FIXED : Montant fixe
- PERCENT : Pourcentage du montant de base
- FORMULA : Évaluation de formule personnalisée
- Application des limites min/max
- Vérification que la remise ne dépasse pas le montant de base

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object/array (si applicable),
    statistics: object (si applicable),
    validation_results: object (si applicable),
    error: string (si erreur)
}
*/ 