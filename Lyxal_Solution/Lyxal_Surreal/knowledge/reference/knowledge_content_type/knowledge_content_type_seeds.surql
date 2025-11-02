-- ============================================================================
-- Seeds : knowledge_content_type_seeds.surql
-- ============================================================================
-- Insère les types de contenus standards pour Knowledge Content
-- ============================================================================

-- SYNTAX
CREATE knowledge_content_type:SYNTAX SET
    identity.code = "SYNTAX",
    identity.label_key = i18n_key:knowledge_content_type_SYNTAX_label,
    identity.description_key = i18n_key:knowledge_content_type_SYNTAX_description,
    metadata.display_order = 1,
    metadata.ai = {
        priority: 5,
        weight: 0.9,
        level: { level: 1, label: "BEGINNER" },
        is_structured: true,
        context_length: 350,
        min_quality_score: 0.4,
        use_cases: [
            { code: "TEACH_SYNTAX", weight: 0.9, recommended: true },
            { code: "GENERATE_SYNTAX", weight: 0.7 }
        ]
    };

-- RULE
CREATE knowledge_content_type:RULE SET
    identity.code = "RULE",
    identity.label_key = i18n_key:knowledge_content_type_RULE_label,
    identity.description_key = i18n_key:knowledge_content_type_RULE_description,
    metadata.display_order = 2,
    metadata.ai = {
        priority: 5,
        weight: 1.0,
        level: { level: 2, label: "INTERMEDIATE" },
        is_structured: false,
        context_length: 600,
        min_quality_score: 0.6,
        use_cases: [
            { code: "VALIDATE_CODE", weight: 1.0, recommended: true },
            { code: "TEACH_RULES", weight: 0.8 }
        ]
    };

-- EXAMPLE_CORRECT
CREATE knowledge_content_type:EXAMPLE_CORRECT SET
    identity.code = "EXAMPLE_CORRECT",
    identity.label_key = i18n_key:knowledge_content_type_EXAMPLE_CORRECT_label,
    identity.description_key = i18n_key:knowledge_content_type_EXAMPLE_CORRECT_description,
    metadata.display_order = 3,
    metadata.ai = {
        priority: 5,
        weight: 0.95,
        level: { level: 1, label: "BEGINNER" },
        is_structured: true,
        context_length: 400,
        min_quality_score: 0.5,
        use_cases: [
            { code: "GENERATE_EXAMPLE", weight: 0.9, recommended: true },
            { code: "COMPARE_OUTPUT", weight: 0.6 }
        ]
    };

-- EXAMPLE_INCORRECT
CREATE knowledge_content_type:EXAMPLE_INCORRECT SET
    identity.code = "EXAMPLE_INCORRECT",
    identity.label_key = i18n_key:knowledge_content_type_EXAMPLE_INCORRECT_label,
    identity.description_key = i18n_key:knowledge_content_type_EXAMPLE_INCORRECT_description,
    metadata.display_order = 4,
    metadata.ai = {
        priority: 4,
        weight: 0.7,
        level: { level: 2, label: "INTERMEDIATE" },
        is_structured: true,
        context_length: 400,
        min_quality_score: 0.7,
        use_cases: [
            { code: "PREVENT_MISTAKE", weight: 1.0, recommended: true },
            { code: "TEACH_MISTAKE", weight: 0.7 }
        ]
    };

-- TIP
CREATE knowledge_content_type:TIP SET
    identity.code = "TIP",
    identity.label_key = i18n_key:knowledge_content_type_TIP_label,
    identity.description_key = i18n_key:knowledge_content_type_TIP_description,
    metadata.display_order = 5,
    metadata.ai = {
        priority: 3,
        weight: 0.6,
        level: { level: 1, label: "BEGINNER" },
        is_structured: false,
        context_length: 200,
        min_quality_score: 0.2,
        use_cases: [
            { code: "QUICK_HELP", weight: 1.0, recommended: true }
        ]
    };

-- PATTERN
CREATE knowledge_content_type:PATTERN SET
    identity.code = "PATTERN",
    identity.label_key = i18n_key:knowledge_content_type_PATTERN_label,
    identity.description_key = i18n_key:knowledge_content_type_PATTERN_description,
    metadata.display_order = 6,
    metadata.ai = {
        priority: 5,
        weight: 0.95,
        level: { level: 3, label: "ADVANCED" },
        is_structured: true,
        context_length: 950,
        min_quality_score: 0.75,
        use_cases: [
            { code: "GENERATE_PATTERN", weight: 1.0, recommended: true },
            { code: "APPLY_PATTERN", weight: 0.8 }
        ]
    };

-- EXPLANATION
CREATE knowledge_content_type:EXPLANATION SET
    identity.code = "EXPLANATION",
    identity.label_key = i18n_key:knowledge_content_type_EXPLANATION_label,
    identity.description_key = i18n_key:knowledge_content_type_EXPLANATION_description,
    metadata.display_order = 7,
    metadata.ai = {
        priority: 4,
        weight: 0.8,
        level: { level: 2, label: "INTERMEDIATE" },
        is_structured: false,
        context_length: 900,
        min_quality_score: 0.5,
        use_cases: [
            { code: "TEACH_EXPLANATION", weight: 1.0, recommended: true }
        ]
    };

-- REFERENCE
CREATE knowledge_content_type:REFERENCE SET
    identity.code = "REFERENCE",
    identity.label_key = i18n_key:knowledge_content_type_REFERENCE_label,
    identity.description_key = i18n_key:knowledge_content_type_REFERENCE_description,
    metadata.display_order = 8,
    metadata.ai = {
        priority: 3,
        weight: 0.5,
        level: { level: 1, label: "BEGINNER" },
        is_structured: false,
        context_length: 150,
        min_quality_score: 0.3,
        use_cases: [
            { code: "ADD_SOURCE", weight: 1.0, recommended: true }
        ]
    };
