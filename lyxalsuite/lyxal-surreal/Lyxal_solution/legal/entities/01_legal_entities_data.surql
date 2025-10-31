 -- =============================================================================
-- MODULE LEGAL - ENTITÉS JURIDIQUES
-- DONNÉES DE RÉFÉRENCES 
-- =============================================================================

-- Catégories principales (niveau 1)
INSERT INTO legal_category (
    id, name, code, description, parent_category, level, sort_order,
    active, created_on, created_by
) VALUES 
(
    legal_category:societe,
    'Société',
    'SOCIETE',
    'Structures juridiques avec personnalité morale distincte',
    null,
    1,
    1,
    true,
    time::now(),
    'system'
),
(
    legal_category:entreprise_sans_personnalite_morale,
    'Entreprise sans personnalité morale',
    'ENTREPRISE_SANS_PERSONNALITE_MORALE',
    'Structures d\'exploitation sans personnalité morale distincte',
    null,
    1,
    2,
    true,
    time::now(),
    'system'
),
(
    legal_category:association,
    'Association',
    'ASSOCIATION',
    'Organisations à but non lucratif',
    null,
    1,
    3,
    true,
    time::now(),
    'system'
);

-- Sous-catégories sociétés (niveau 2)
INSERT INTO legal_category (
    id, name, code, description, parent_category, level, sort_order,
    active, created_on, created_by
) VALUES 
(
    legal_category:societe_commerciale,
    'Société Commerciale',
    'SOCIETE_COMMERCIALE',
    'Sociétés destinées aux activités commerciales',
    legal_category:societe,
    2,
    1,
    true,
    time::now(),
    'system'
),
(
    legal_category:societe_civile,
    'Société Civile',
    'SOCIETE_CIVILE',
    'Sociétés pour activités civiles (non commerciales)',
    legal_category:societe,
    2,
    2,
    true,
    time::now(),
    'system'
);

-- Sous-catégories entreprise sans personnalité morale (niveau 2)
INSERT INTO legal_category (
    id, name, code, description, parent_category, level, sort_order,
    active, created_on, created_by
) VALUES 
(
    legal_category:entreprise_individuelle_classique,
    'Entreprise Individuelle Classique',
    'ENTREPRISE_INDIVIDUELLE_CLASSIQUE',
    'Entreprises individuelles avec régime fiscal normal',
    legal_category:entreprise_sans_personnalite_morale,
    2,
    1,
    true,
    time::now(),
    'system'
),
(
    legal_category:entreprise_individuelle_simplifiee,
    'Entreprise Individuelle Simplifiée',
    'ENTREPRISE_INDIVIDUELLE_SIMPLIFIEE',
    'Entreprises individuelles avec régime fiscal simplifié',
    legal_category:entreprise_sans_personnalite_morale,
    2,
    2,
    true,
    time::now(),
    'system'
);

-- =============================================================================
-- DONNÉES POUR LES FORMES JURIDIQUES
-- =============================================================================

-- Formes juridiques françaises
INSERT INTO legal_form (
    id, name, code, description, country, category,
    isCommercial, isLimitedLiability, requiresMinimumCapital, minimumCapital,
    minimumShareholders, maximumShareholders, defaultTaxRegime, typicalUse,
    advantages, disadvantages, requirements, active, created_on, created_by
) VALUES 
-- France - Sociétés commerciales
(
    legal_form:fr_sarl,
    'Société à Responsabilité Limitée',
    'SARL',
    'Société commerciale à responsabilité limitée, adaptée aux PME',
    country:france,
    legal_category:societe_commerciale,
    true,
    true,
    false,
    null,
    1,
    100,
    tax_regime:fr_normal,
    'PME familiales, artisans, commerçants',
    ['Responsabilité limitée', 'Simplicité de gestion', 'Flexibilité'],
    ['Formalités administratives', 'Limitations transmission parts'],
    {
        auditRequired: false,
        boardRequired: false,
        publicationRequired: true,
        specificReporting: false,
        registrationAuthority: 'RCS',
        additionalCompliance: ['Dépôt comptes annuels']
    },
    true,
    time::now(),
    'system'
),
(
    legal_form:fr_sas,
    'Société par Actions Simplifiée',
    'SAS',
    'Société commerciale très flexible, adaptée aux entreprises innovantes',
    country:france,
    legal_category:societe_commerciale,
    true,
    true,
    false,
    null,
    1,
    null,
    tax_regime:fr_normal,
    'Startups, entreprises innovantes, croissance rapide',
    ['Grande flexibilité', 'Facilité transmission', 'Protection sociale président'],
    ['Complexité juridique', 'Coûts comptables élevés'],
    {
        auditRequired: false,
        boardRequired: false,
        publicationRequired: true,
        specificReporting: false,
        registrationAuthority: 'RCS',
        additionalCompliance: ['Dépôt comptes annuels', 'Commissaire aux comptes si seuils dépassés']
    },
    true,
    time::now(),
    'system'
),
(
    legal_form:fr_micro,
    'Micro-Entreprise',
    'MICRO',
    'Régime simplifié d\'entreprise individuelle',
    country:france,
    legal_category:entreprise_individuelle_simplifiee,
    true,
    false,
    false,
    null,
    1,
    1,
    tax_regime:fr_micro,
    'Petites activités, freelances, consultants',
    ['Simplicité maximale', 'Charges sociales réduites', 'Comptabilité simple'],
    ['Plafonds CA', 'Pas de déduction charges', 'Évolution limitée'],
    {
        auditRequired: false,
        boardRequired: false,
        publicationRequired: false,
        specificReporting: false,
        registrationAuthority: 'Auto-entrepreneur',
        additionalCompliance: ['Déclaration CA périodique']
    },
    true,
    time::now(),
    'system'
),
(
    legal_form:fr_ei,
    'Entreprise Individuelle',
    'EI',
    'Entreprise individuelle classique avec régime fiscal normal',
    country:france,
    legal_category:entreprise_individuelle_classique,
    true,
    false,
    false,
    null,
    1,
    1,
    tax_regime:fr_normal,
    'Artisans, commerçants, professionnels libéraux',
    ['Simplicité de création', 'Liberté de gestion', 'Déduction des charges'],
    ['Responsabilité illimitée', 'Difficultés de transmission', 'Charges sociales élevées'],
    {
        auditRequired: false,
        boardRequired: false,
        publicationRequired: false,
        specificReporting: false,
        registrationAuthority: 'RCS ou RM',
        additionalCompliance: ['Déclaration fiscale personnelle']
    },
    true,
    time::now(),
    'system'
),
(
    legal_form:fr_eirl,
    'Entreprise Individuelle à Responsabilité Limitée',
    'EIRL',
    'Entreprise individuelle avec limitation de responsabilité',
    country:france,
    legal_category:entreprise_individuelle_classique,
    true,
    true,
    false,
    null,
    1,
    1,
    tax_regime:fr_normal,
    'Entrepreneurs voulant protéger leur patrimoine personnel',
    ['Responsabilité limitée', 'Protection patrimoine', 'Simplicité relative'],
    ['Formalités supplémentaires', 'Déclaration d\'affectation obligatoire'],
    {
        auditRequired: false,
        boardRequired: false,
        publicationRequired: false,
        specificReporting: false,
        registrationAuthority: 'RCS ou RM',
        additionalCompliance: ['Déclaration d\'affectation du patrimoine']
    },
    true,
    time::now(),
    'system'
);