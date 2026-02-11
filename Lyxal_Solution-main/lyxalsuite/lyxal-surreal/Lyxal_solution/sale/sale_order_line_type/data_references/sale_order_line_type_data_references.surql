-- =====================================================
-- DONNÉES DE RÉFÉRENCE: sale_order_line_type
-- Description: Types de ligne de commande de vente standards
-- Version: 1.0
-- =====================================================

-- =====================================================
-- SUPPRESSION ET RÉINITIALISATION
-- =====================================================

-- Réinitialisation des données de référence
SELECT fn::reset_sale_order_line_type_data();

-- =====================================================
-- CRÉATION DES TYPES DE BASE
-- =====================================================

-- Type NORMAL - Ligne de produit standard
CREATE sale_order_line_type:NORMAL CONTENT {
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
    is_active: true,
    is_system: true,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type TITLE - Ligne de titre/section
CREATE sale_order_line_type:TITLE CONTENT {
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
    is_active: true,
    is_system: true,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type PACK - Ligne de pack/bundle
CREATE sale_order_line_type:PACK CONTENT {
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
    is_active: true,
    is_system: true,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type OPTION - Ligne d'option/accessoire
CREATE sale_order_line_type:OPTION CONTENT {
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
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- TYPES AVANCÉS OPTIONNELS
-- =====================================================

-- Type SERVICE - Ligne de service
CREATE sale_order_line_type:SERVICE CONTENT {
    code: "SERVICE",
    name: "Service",
    description: "Ligne de service ou prestation sans impact stock",
    sequence: 5,
    color: "#6f42c1",
    icon: "Settings",
    affects_stock: false,
    affects_pricing: true,
    is_printable: true,
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

-- Type DISCOUNT - Ligne de remise
CREATE sale_order_line_type:DISCOUNT CONTENT {
    code: "DISCOUNT",
    name: "Remise",
    description: "Ligne de remise ou réduction tarifaire",
    sequence: 6,
    color: "#dc3545",
    icon: "Minus",
    affects_stock: false,
    affects_pricing: true,
    is_printable: true,
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

-- Type COMMENT - Ligne de commentaire
CREATE sale_order_line_type:COMMENT CONTENT {
    code: "COMMENT",
    name: "Commentaire",
    description: "Ligne de commentaire ou note sans impact",
    sequence: 7,
    color: "#fd7e14",
    icon: "MessageCircle",
    affects_stock: false,
    affects_pricing: false,
    is_printable: true,
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

-- Type SUBTOTAL - Ligne de sous-total
CREATE sale_order_line_type:SUBTOTAL CONTENT {
    code: "SUBTOTAL",
    name: "Sous-total",
    description: "Ligne de sous-total ou récapitulatif",
    sequence: 8,
    color: "#20c997",
    icon: "Calculator",
    affects_stock: false,
    affects_pricing: false,
    is_printable: true,
    allows_modification: false,
    allows_deletion: true,
    requires_validation: false,
    min_quantity: 0,
    max_quantity: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- FONCTIONS UTILITAIRES
-- =====================================================

-- Fonction de test des données
SELECT fn::create_test_sale_order_line_type();

-- Validation des données créées
SELECT fn::validate_sale_order_line_type_data();

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
TYPES DE LIGNE CRÉÉS:

1. NORMAL (Système) - Ligne standard
   - Impact: Stock ✓, Prix ✓, Impression ✓
   - Couleur: Vert (#28a745)
   - Icône: Box
   - Utilisation: Produits standards

2. TITLE (Système) - Ligne de titre
   - Impact: Stock ✗, Prix ✗, Impression ✓
   - Couleur: Gris (#6c757d)
   - Icône: Heading
   - Utilisation: Sections et titres

3. PACK (Système) - Ligne de pack
   - Impact: Stock ✓, Prix ✓, Impression ✓
   - Couleur: Bleu clair (#17a2b8)
   - Icône: Package
   - Utilisation: Packs et bundles
   - Validation: Requise

4. OPTION (Personnalisable) - Ligne d'option
   - Impact: Stock ✓, Prix ✓, Impression ✓
   - Couleur: Jaune (#ffc107)
   - Icône: Plus
   - Utilisation: Options et accessoires

5. SERVICE (Personnalisable) - Ligne de service
   - Impact: Stock ✗, Prix ✓, Impression ✓
   - Couleur: Violet (#6f42c1)
   - Icône: Settings
   - Utilisation: Services et prestations

6. DISCOUNT (Personnalisable) - Ligne de remise
   - Impact: Stock ✗, Prix ✓, Impression ✓
   - Couleur: Rouge (#dc3545)
   - Icône: Minus
   - Utilisation: Remises et réductions

7. COMMENT (Personnalisable) - Ligne de commentaire
   - Impact: Stock ✗, Prix ✗, Impression ✓
   - Couleur: Orange (#fd7e14)
   - Icône: MessageCircle
   - Utilisation: Commentaires et notes

8. SUBTOTAL (Personnalisable) - Ligne de sous-total
   - Impact: Stock ✗, Prix ✗, Impression ✓
   - Couleur: Vert clair (#20c997)
   - Icône: Calculator
   - Utilisation: Sous-totaux et récapitulatifs
   - Modification: Interdite

RÈGLES MÉTIER:
- Types système (NORMAL, TITLE, PACK) : protégés contre suppression
- Type TITLE : suppression interdite (structure documentaire)
- Type PACK : validation requise (complexité)
- Type SUBTOTAL : modification interdite (calcul automatique)
- Séquences : définissent l'ordre d'affichage et de priorité

UTILISATION:
- Ligne produit standard → NORMAL
- Section de document → TITLE
- Pack de produits → PACK
- Accessoire optionnel → OPTION
- Prestation de service → SERVICE
- Remise commerciale → DISCOUNT
- Note ou commentaire → COMMENT
- Récapitulatif partiel → SUBTOTAL

COULEURS ET ICÔNES:
- Couleurs harmonisées avec Bootstrap
- Icônes Lucide React pour cohérence UI
- Facilement personnalisables
- Accessibilité respectée

ÉVOLUTIVITÉ:
- Types personnalisables ajoutables
- Comportements configurables
- Validation conditionnelle
- Règles métier flexibles
*/ 