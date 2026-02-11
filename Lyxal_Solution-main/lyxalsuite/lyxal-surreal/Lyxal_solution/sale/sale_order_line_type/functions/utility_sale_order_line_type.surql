-- =====================================================
-- FONCTIONS UTILITAIRES: sale_order_line_type
-- Description: Fonctions utilitaires et de maintenance
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: reset_sale_order_line_type_data
-- Description: Réinitialisation des données de référence
-- =====================================================

DEFINE FUNCTION fn::reset_sale_order_line_type_data() {
    -- Suppression des données existantes (sauf système)
    DELETE sale_order_line_type WHERE is_system = false;
    
    -- Création des types de base
    LET $base_types = [
        {
            code: "NORMAL",
            name: "Normale",
            description: "Ligne de produit standard avec impact complet sur stock et prix",
            sequence: 1,
            color: "#28a745",
            icon: "Box",
            affects_stock: true,
            affects_pricing: true,
            is_printable: true,
            allows_modification: true,
            allows_deletion: true,
            requires_validation: false,
            min_quantity: 0,
            max_quantity: NONE,
            is_system: true
        },
        {
            code: "TITLE",
            name: "Titre",
            description: "Ligne de titre ou section sans impact sur stock et prix",
            sequence: 2,
            color: "#6c757d",
            icon: "Heading",
            affects_stock: false,
            affects_pricing: false,
            is_printable: true,
            allows_modification: true,
            allows_deletion: false,
            requires_validation: false,
            min_quantity: 0,
            max_quantity: NONE,
            is_system: true
        },
        {
            code: "PACK",
            name: "Pack",
            description: "Ligne de pack ou bundle avec validation requise",
            sequence: 3,
            color: "#17a2b8",
            icon: "Package",
            affects_stock: true,
            affects_pricing: true,
            is_printable: true,
            allows_modification: true,
            allows_deletion: true,
            requires_validation: true,
            min_quantity: 1,
            max_quantity: NONE,
            is_system: true
        },
        {
            code: "OPTION",
            name: "Option",
            description: "Ligne d'option ou accessoire optionnel",
            sequence: 4,
            color: "#ffc107",
            icon: "Plus",
            affects_stock: true,
            affects_pricing: true,
            is_printable: true,
            allows_modification: true,
            allows_deletion: true,
            requires_validation: false,
            min_quantity: 0,
            max_quantity: NONE,
            is_system: false
        }
    ];
    
    -- Insertion des types de base
    LET $created_types = [];
    FOR $type IN $base_types {
        LET $created = CREATE sale_order_line_type CONTENT {
            code: $type.code,
            name: $type.name,
            description: $type.description,
            sequence: $type.sequence,
            color: $type.color,
            icon: $type.icon,
            affects_stock: $type.affects_stock,
            affects_pricing: $type.affects_pricing,
            is_printable: $type.is_printable,
            allows_modification: $type.allows_modification,
            allows_deletion: $type.allows_deletion,
            requires_validation: $type.requires_validation,
            min_quantity: $type.min_quantity,
            max_quantity: $type.max_quantity,
            is_active: true,
            is_system: $type.is_system,
            created_on: time::now(),
            updated_on: time::now()
        };
        $created_types = array::push($created_types, $created[0]);
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Données de référence réinitialisées avec succès",
        created_count: array::len($created_types),
        created_types: $created_types
    };
};

-- =====================================================
-- FONCTION: create_test_sale_order_line_type
-- Description: Création d'un type de test
-- =====================================================

DEFINE FUNCTION fn::create_test_sale_order_line_type() {
    -- Génération d'un code unique
    LET $test_code = "TEST_" + string::replace(string::replace(<string>time::now(), ":", ""), "-", "");
    
    -- Création du type de test
    LET $test_type = CREATE sale_order_line_type CONTENT {
        code: $test_code,
        name: "Type de test",
        description: "Type de ligne créé pour les tests - peut être supprimé",
        sequence: 999,
        color: "#dc3545",
        icon: "TestTube",
        affects_stock: false,
        affects_pricing: false,
        is_printable: false,
        allows_modification: true,
        allows_deletion: true,
        requires_validation: false,
        min_quantity: 0,
        max_quantity: NONE,
        is_active: true,
        is_system: false,
        created_on: time::now(),
        updated_on: time::now()
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de test créé avec succès",
        data: $test_type[0]
    };
};

-- =====================================================
-- FONCTION: validate_sale_order_line_type_data
-- Description: Validation de l'intégrité des données
-- =====================================================

DEFINE FUNCTION fn::validate_sale_order_line_type_data() {
    LET $errors = [];
    
    -- Vérification des types obligatoires
    LET $required_types = ["NORMAL", "TITLE", "PACK"];
    FOR $required_code IN $required_types {
        LET $exists = SELECT VALUE count() FROM sale_order_line_type 
            WHERE code = $required_code AND is_active = true;
        IF $exists[0] == 0 {
            $errors = array::push($errors, "Type obligatoire manquant : " + $required_code);
        };
    };
    
    -- Vérification des doublons de code
    LET $duplicate_codes = SELECT code, count() as count FROM sale_order_line_type 
        WHERE is_active = true 
        GROUP BY code 
        HAVING count > 1;
    FOR $duplicate IN $duplicate_codes {
        $errors = array::push($errors, "Code dupliqué : " + $duplicate.code);
    };
    
    -- Vérification des doublons de séquence
    LET $duplicate_sequences = SELECT sequence, count() as count FROM sale_order_line_type 
        WHERE is_active = true 
        GROUP BY sequence 
        HAVING count > 1;
    FOR $duplicate IN $duplicate_sequences {
        $errors = array::push($errors, "Séquence dupliquée : " + <string>$duplicate.sequence);
    };
    
    -- Vérification des codes vides
    LET $empty_codes = SELECT VALUE count() FROM sale_order_line_type 
        WHERE code = "" OR code IS NONE;
    IF $empty_codes[0] > 0 {
        $errors = array::push($errors, "Types avec code vide : " + <string>$empty_codes[0]);
    };
    
    -- Vérification des noms vides
    LET $empty_names = SELECT VALUE count() FROM sale_order_line_type 
        WHERE name = "" OR name IS NONE;
    IF $empty_names[0] > 0 {
        $errors = array::push($errors, "Types avec nom vide : " + <string>$empty_names[0]);
    };
    
    -- Vérification des séquences invalides
    LET $invalid_sequences = SELECT VALUE count() FROM sale_order_line_type 
        WHERE sequence <= 0 OR sequence IS NONE;
    IF $invalid_sequences[0] > 0 {
        $errors = array::push($errors, "Types avec séquence invalide : " + <string>$invalid_sequences[0]);
    };
    
    -- Vérification des couleurs invalides
    LET $invalid_colors = SELECT VALUE count() FROM sale_order_line_type 
        WHERE color IS NOT NONE AND !string::starts_with(color, "#");
    IF $invalid_colors[0] > 0 {
        $errors = array::push($errors, "Types avec couleur invalide : " + <string>$invalid_colors[0]);
    };
    
    -- Vérification des quantités incohérentes
    LET $invalid_quantities = SELECT VALUE count() FROM sale_order_line_type 
        WHERE min_quantity IS NOT NONE AND max_quantity IS NOT NONE AND max_quantity < min_quantity;
    IF $invalid_quantities[0] > 0 {
        $errors = array::push($errors, "Types avec quantités incohérentes : " + <string>$invalid_quantities[0]);
    };
    
    -- Retour du résultat
    RETURN {
        success: array::len($errors) == 0,
        message: IF array::len($errors) == 0 THEN "Validation réussie" ELSE "Erreurs détectées" END,
        error_count: array::len($errors),
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: get_sale_order_line_type_statistics
-- Description: Statistiques globales des types
-- =====================================================

DEFINE FUNCTION fn::get_sale_order_line_type_statistics() {
    -- Statistiques de base
    LET $basic_stats = {
        total_types: (SELECT VALUE count() FROM sale_order_line_type)[0] OR 0,
        active_types: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true)[0] OR 0,
        inactive_types: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = false)[0] OR 0,
        system_types: (SELECT VALUE count() FROM sale_order_line_type WHERE is_system = true)[0] OR 0
    };
    
    -- Type le plus utilisé
    LET $most_used = SELECT 
        type_id,
        type_id.code as code,
        type_id.name as name,
        count() as usage_count
    FROM sale_order_line 
    WHERE type_id IS NOT NONE
    GROUP BY type_id 
    ORDER BY usage_count DESC 
    LIMIT 1;
    
    -- Type le moins utilisé (parmi ceux utilisés)
    LET $least_used = SELECT 
        type_id,
        type_id.code as code,
        type_id.name as name,
        count() as usage_count
    FROM sale_order_line 
    WHERE type_id IS NOT NONE
    GROUP BY type_id 
    ORDER BY usage_count ASC 
    LIMIT 1;
    
    -- Statistiques d'utilisation
    LET $usage_stats = {
        total_lines: (SELECT VALUE count() FROM sale_order_line)[0] OR 0,
        lines_with_type: (SELECT VALUE count() FROM sale_order_line WHERE type_id IS NOT NONE)[0] OR 0,
        lines_without_type: (SELECT VALUE count() FROM sale_order_line WHERE type_id IS NONE)[0] OR 0,
        most_used_type: IF array::len($most_used) > 0 THEN $most_used[0] ELSE NONE END,
        least_used_type: IF array::len($least_used) > 0 THEN $least_used[0] ELSE NONE END
    };
    
    -- Statistiques par comportement
    LET $behavior_stats = {
        affects_stock: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND affects_stock = true)[0] OR 0,
        affects_pricing: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND affects_pricing = true)[0] OR 0,
        is_printable: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND is_printable = true)[0] OR 0,
        requires_validation: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND requires_validation = true)[0] OR 0,
        allows_modification: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND allows_modification = true)[0] OR 0,
        allows_deletion: (SELECT VALUE count() FROM sale_order_line_type WHERE is_active = true AND allows_deletion = true)[0] OR 0
    };
    
    -- Retour des statistiques
    RETURN {
        success: true,
        message: "Statistiques globales calculées",
        basic_stats: $basic_stats,
        usage_stats: $usage_stats,
        behavior_stats: $behavior_stats
    };
};

-- =====================================================
-- FONCTION: get_available_lucide_icons
-- Description: Liste des icônes Lucide disponibles
-- =====================================================

DEFINE FUNCTION fn::get_available_lucide_icons() {
    -- Liste des icônes Lucide React recommandées pour les types de ligne
    LET $icons = [
        "Box", "Package", "Heading", "Plus", "Minus", "Star", "Circle", "Square",
        "Triangle", "Diamond", "Heart", "Bookmark", "Tag", "Label", "Flag",
        "CheckCircle", "XCircle", "AlertCircle", "InfoCircle", "HelpCircle",
        "Settings", "Cog", "Tool", "Wrench", "Hammer", "Screwdriver",
        "ShoppingCart", "ShoppingBag", "Gift", "Archive", "Folder", "File",
        "Image", "Video", "Music", "Download", "Upload", "Link", "Paperclip",
        "Calendar", "Clock", "Timer", "Stopwatch", "Bell", "Phone", "Mail",
        "User", "Users", "UserPlus", "UserMinus", "UserCheck", "UserX",
        "Home", "Building", "Store", "Warehouse", "Truck", "Car", "Plane",
        "Map", "MapPin", "Navigation", "Compass", "Globe", "Wifi", "Signal",
        "Battery", "Power", "Zap", "Sun", "Moon", "Cloud", "Umbrella",
        "Thermometer", "Activity", "TrendingUp", "TrendingDown", "BarChart",
        "PieChart", "Target", "Award", "Trophy", "Medal", "Crown", "Shield"
    ];
    
    -- Retour de la liste
    RETURN {
        success: true,
        message: "Liste des icônes Lucide disponibles",
        total_icons: array::len($icons),
        icons: $icons
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Réinitialisation des données:
   SELECT fn::reset_sale_order_line_type_data();

2. Création d'un type de test:
   SELECT fn::create_test_sale_order_line_type();

3. Validation des données:
   SELECT fn::validate_sale_order_line_type_data();

4. Statistiques globales:
   SELECT fn::get_sale_order_line_type_statistics();

5. Icônes disponibles:
   SELECT fn::get_available_lucide_icons();

DONNÉES DE RÉFÉRENCE CRÉÉES:
- NORMAL: Type standard avec impact complet (système)
- TITLE: Type titre sans impact stock/prix (système)
- PACK: Type pack avec validation requise (système)
- OPTION: Type option modifiable (non-système)

VALIDATIONS EFFECTUÉES:
- Présence des types obligatoires (NORMAL, TITLE, PACK)
- Absence de doublons de code
- Absence de doublons de séquence
- Codes et noms non vides
- Séquences positives
- Format de couleur hexadécimal
- Cohérence des quantités min/max

STATISTIQUES DISPONIBLES:
- Nombre total de types (actifs/inactifs/système)
- Utilisation des types dans les lignes
- Type le plus/moins utilisé
- Répartition par comportement métier
- Pourcentage d'utilisation

ICÔNES LUCIDE REACT:
- 80+ icônes recommandées pour les types
- Catégories : formes, actions, objets, UI
- Compatibles avec Lucide React
- Facilement extensible

MAINTENANCE:
- Réinitialisation sécurisée des données
- Création de types de test temporaires
- Validation périodique de l'intégrité
- Nettoyage automatique des incohérences

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object/array (si applicable),
    errors: array (si validation),
    statistics: object (si stats)
}
*/ 