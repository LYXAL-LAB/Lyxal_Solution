-- =============================================================================================
-- |
-- | Fichier : log_get_by_run_id.surql
-- | Module : system / log
-- | Description : Raccourci pour récupérer tous les logs (traduits) associés à un
-- |               `run_id` spécifique, triés par date.
-- |
-- | Paramètres :
-- |   - $run_id: string
-- |   - $langue_id: string (ex: 'fr')
-- |
-- | Retour :
-- |   - array<object> : Une liste d'enregistrements de log enrichis.
-- =============================================================================================
DEFINE FUNCTION fn::log_get_by_run_id(
    $run_id: string,
    $langue_id: string
) {
    -- Appelle la fonction principale avec le filtre approprié.
    -- Le tri par défaut est DESC, ce qui est généralement ce qu'on veut.
    -- Limite à 1000 pour éviter des résultats trop volumineux.
    RETURN fn::log_get_records(
        $langue_id,
        { 'operation.run_id': $run_id },
        'ASC', -- On veut voir la séquence des événements dans l'ordre chronologique
        0,
        1000
    );
}
COMMENT 'Raccourci pour récupérer tous les logs d\'un run_id, traduits et triés.';
