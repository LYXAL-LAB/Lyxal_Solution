-- ============================================================================
-- FONCTION MODÃˆLE DE RÃ‰FÃ‰RENCE ABSOLUE : fn::booking_create_team
-- Domaine : Teams (Ã‰quipes)
-- Pattern : ParamÃ¨tres optionnels avec messages d'erreur personnalisÃ©s explicites
-- Description : RÃ©alise en UNE SEULE TRANSACTION ATOMIQUE dans SurrealDB :
--   1. ContrÃ´le des paramÃ¨tres requis avec messages d'erreur personnalisÃ©s
--   2. ContrÃ´les complets de validation (longueurs, regex, mots rÃ©servÃ©s)
--   3. Validation de l'unicitÃ© du slug
--   4. CrÃ©ation de l'Ã©quipe
--   5. Association du crÃ©ateur comme Admin
--   6. Ajout des membres directs ($member_ids)
--   7. Liaison des groupes OIDC ($group_ids) + ajout de leurs membres
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_create_team(
    $name: option<string>,
    $slug: option<string>,
    $description: option<string>,
    $created_by: option<string>,
    $visibility: option<string>,
    $member_ids: option<array<string>>,
    $group_ids: option<array<string>>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES (Erreurs explicites)
    -- ------------------------------------------------------------------------
    
    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        THROW "Parameter 'name' is required and cannot be empty";
    };

    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        THROW "Parameter 'slug' is required and cannot be empty";
    };

    IF $created_by == NONE OR string::len(string::trim($created_by)) == 0 {
        THROW "Parameter 'created_by' is required and cannot be empty";
    };

    -- ------------------------------------------------------------------------
    -- 2. NETTOYAGE & VALEURS NORMALISÃ‰ES
    -- ------------------------------------------------------------------------

    LET $clean_name = string::trim($name);
    LET $clean_slug = string::lowercase(string::trim($slug));
    LET $clean_creator = string::trim($created_by);

    -- ------------------------------------------------------------------------
    -- 3. CONTRÃ”LES & VALIDATIONS STRUCTURÃ‰ES
    -- ------------------------------------------------------------------------

    -- A. Longueur maximale du Nom (max 255)
    IF string::len($clean_name) > 255 {
        THROW "Team name must be at most 255 characters";
    };

    -- B. Format du Slug (lettres minuscules, chiffres et tirets uniquement)
    IF !($clean_slug ~ "^[a-z0-9-]+$") {
        THROW "Slug must contain only lowercase letters, numbers, and dashes";
    };

    -- C. Slugs rÃ©servÃ©s au systÃ¨me
    LET $reserved = ['new', 'settings', 'admin', 'api', 'dashboard', 'auth'];
    IF $clean_slug IN $reserved {
        THROW "This slug is reserved. Please choose a different one";
    };

    -- D. Description max 5000 caractÃ¨res
    IF $description != NONE AND string::len(string::trim($description)) > 5000 {
        THROW "Description must be at most 5000 characters";
    };

    -- E. UnicitÃ© du slug en base de donnÃ©es
    LET $existing = SELECT VALUE id FROM booking_team WHERE slug = $clean_slug LIMIT 1;
    IF array::len($existing) > 0 {
        THROW "A team with this slug already exists";
    };

    -- ------------------------------------------------------------------------
    -- 4. INITIALISATION DES VALEURS OPTIONNELLES ET LISTES (Syntaxe SurrealQL IF {} ELSE {})
    -- ------------------------------------------------------------------------
    LET $vis = IF $visibility != NONE { $visibility } ELSE { 'public' };
    LET $desc = IF $description != NONE { string::trim($description) } ELSE { NONE };
    LET $m_list = IF $member_ids != NONE { $member_ids } ELSE { [] };
    LET $g_list = IF $group_ids != NONE { $group_ids } ELSE { [] };

    -- ------------------------------------------------------------------------
    -- 5. PERSISTANCE : CRÃ‰ATION DE L'Ã‰QUIPE ET SES MEMBRES
    -- ------------------------------------------------------------------------
    LET $team = CREATE ONLY booking_team CONTENT {
        name: $clean_name,
        slug: $clean_slug,
        description: $desc,
        visibility: $vis,
        created_by: $clean_creator,
        created_at: time::now()
    };

    -- 6. RELATION GRAPH : AJOUT DU CRÃ‰ATEUR EN TANT QU'ADMIN
    CREATE booking_team_member CONTENT {
        in: $clean_creator,
        out: $team.id,
        role: 'admin',
        source: 'direct',
        created_at: time::now()
    };

    -- 7. RELATION GRAPH : AJOUT DES MEMBRES DIRECTS SÃ‰LECTIONNÃ‰S
    FOR $mid IN $m_list {
        IF $mid != $clean_creator {
            LET $check = SELECT VALUE id FROM booking_team_member WHERE out = $team.id AND in = $mid;
            IF array::len($check) == 0 {
                CREATE booking_team_member CONTENT {
                    in: $mid,
                    out: $team.id,
                    role: 'member',
                    source: 'direct',
                    created_at: time::now()
                };
            };
        };
    };

    -- 8. LIAISON DES GROUPES OIDC ET DE LEURS MEMBRES
    FOR $gid IN $g_list {
        CREATE team_group CONTENT {
            team_id: $team.id,
            group_id: $gid,
            created_at: time::now()
        };

        LET $gmembers = SELECT VALUE user_id FROM user_group WHERE group_id = $gid;
        FOR $guser IN $gmembers {
            LET $check_g = SELECT VALUE id FROM booking_team_member WHERE out = $team.id AND in = $guser;
            IF array::len($check_g) == 0 {
                CREATE booking_team_member CONTENT {
                    in: $guser,
                    out: $team.id,
                    role: 'member',
                    source: 'group',
                    created_at: time::now()
                };
            };
        };
    };

    -- ------------------------------------------------------------------------
    -- 9. RETOUR : L'OBJET Ã‰QUIPE COMPLET CRÃ‰Ã‰
    -- ------------------------------------------------------------------------
    RETURN $team;
};
