-- Access pour les runners distants (Workers)
DEFINE ACCESS IF NOT EXISTS runner_token ON DATABASE TYPE BEARER FOR RECORD
    AUTHENTICATE {
        LET $runner = SELECT * FROM scheduler_runner WHERE id = type::record('scheduler_runner', $auth);
        IF array::len($runner) > 0 AND $runner[0].status == 'active' {
            RETURN true;
        } ELSE {
            RETURN false;
        };
    }
    COMMENT "Accès sécurisé par Bearer token pour les runners et workers d'exécution";
