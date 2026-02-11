DEFINE FUNCTION IF NOT EXISTS fn::get_error_severities(
    $is_active: option<bool>, -- Filtrer par statut actif (optionnel, défaut: tous)
    $language_id: string, -- langue de l'utilisateur
    $user_id: string -- id de l'utilisateur
) {
    -- 1. Convertir la langue en record
    LET $target_language = type::thing('language', $language_id);
    
    -- 2. Convertir l'ID utilisateur en record
    LET $user_record = IF $user_id IS NONE { NONE} ELSE {type::thing('user', $user_id)};
    
    -- 3. Récupérer le filtre de statut actif
    LET $filter_active = IF $is_active IS NONE {TRUE} ELSE {$is_active};
    
    -- 4. Récupérer la liste des sévérités d'erreur
    -- Récupérer toutes les error_severity avec leurs traductions dans une langue spécifique

LET $severities = (SELECT 
    *,
    {
        label: (SELECT content.text FROM translation 
                WHERE in = $parent.presentation.label_i18n 
                AND out = $target_language 
                LIMIT 1)[0].content.text,
        
        description: (SELECT content.text FROM translation 
                      WHERE in = $parent.presentation.description_i18n 
                      AND out = $target_language 
                      LIMIT 1)[0].content.text,
        
        message: (SELECT content.text FROM translation 
                  WHERE in = $parent.presentation.message_i18n 
                  AND out = $target_language 
                  LIMIT 1)[0].content.text
    } AS display

FROM error_severity
WHERE status.is_active = $filter_active
ORDER BY display.label ASC); -- Tri alphabétique sur le label traduit
    
    -- 5. Retourne un objet structuré avec success, result_code et data
    RETURN { 
        success: true, 
        result_code: 'error_severity_list_success', 
        data: $severities
    };
}
COMMENT 'Récupère la liste des sévérités d\'erreur'
PERMISSIONS FULL;
