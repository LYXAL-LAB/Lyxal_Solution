-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::utils::predict_next_executions`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_utils_predict_next_executions_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_utils_predict_next_executions_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::utils::predict_next_executions`.');

    DEFINE FUNCTION fn::scheduler::utils::predict_next_executions(
        $schedule: object, // { timezone: string, months: [], mdays: [], wdays: [], hours: [], minutes: [] }
        $start_date: datetime,
        $count: int
    ) {
        // Cette fonction porte la logique de `ExecutionPredictor.php` en JavaScript
        // pour calculer les prochaines dates d'exécution d'un job.
        RETURN function($schedule, $startDate, $count) {
            
            // --- Helper pour vérifier si un tableau de schedule est "tous" (*) ---
            const isAll = (arr) => Array.isArray(arr) && arr.length === 1 && arr[0] === -1;

            // --- Logique principale ---
            const predictions = [];
            let currentDate = new Date($startDate);

            // Commence la recherche à la minute suivante.
            currentDate.setSeconds(0, 0);
            currentDate.setMinutes(currentDate.getMinutes() + 1);
            
            for (let i = 0; i < $count; i++) {
                const maxIterations = 2048; // Sécurité
                let iterations = 0;
                
                while (iterations++ < maxIterations) {
                    
                    // NOTE: La gestion des timezones en JS natif est complexe.
                    // Pour cette première version, nous allons travailler en UTC et supposer
                    // que les dates et les schedules sont alignés sur UTC.
                    // Une version plus avancée nécessiterait une logique de conversion plus fine.
                    const year = currentDate.getUTCFullYear();
                    const month = currentDate.getUTCMonth() + 1; // getUTCMonth est 0-11
                    const dayOfMonth = currentDate.getUTCDate();
                    const dayOfWeek = currentDate.getUTCDay(); // 0 = Dimanche, ..., 6 = Samedi
                    const hour = currentDate.getUTCHours();
                    const minute = currentDate.getUTCMinutes();
                    
                    if (!isAll($schedule.months) && !$schedule.months.includes(month)) {
                        currentDate.setUTCMonth(currentDate.getUTCMonth() + 1, 1);
                        currentDate.setUTCHours(0, 0, 0, 0);
                        continue;
                    }
                    
                    if (!isAll($schedule.mdays) && !$schedule.mdays.includes(dayOfMonth)) {
                        currentDate.setUTCDate(currentDate.getUTCDate() + 1);
                        currentDate.setUTCHours(0, 0, 0, 0);
                        continue;
                    }

                    if (!isAll($schedule.wdays) && !$schedule.wdays.includes(dayOfWeek)) {
                        currentDate.setUTCDate(currentDate.getUTCDate() + 1);
                        currentDate.setUTCHours(0, 0, 0, 0);
                        continue;
                    }
                    
                    if (!isAll($schedule.hours) && !$schedule.hours.includes(hour)) {
                        currentDate.setUTCHours(currentDate.getUTCHours() + 1, 0, 0, 0);
                        continue;
                    }

                    if (!isAll($schedule.minutes) && !$schedule.minutes.includes(minute)) {
                        currentDate.setUTCMinutes(currentDate.getUTCMinutes() + 1, 0, 0);
                        continue;
                    }
                    
                    // Si on arrive ici, la date est valide.
                    break;
                }

                if (iterations >= maxIterations) {
                    break; // N'a pas trouvé de date, on arrête de chercher.
                }

                predictions.push(currentDate.toISOString());
                
                // Prépare la prochaine itération en avançant d'une minute.
                currentDate.setUTCMinutes(currentDate.getUTCMinutes() + 1);
            }

            return predictions;

        }($schedule, $start_date, $count);
    };
    
    fn::system_log_create_record_system(['scheduler_utils_predict_next_executions_initialise', 'success'], 'Fonction `fn::scheduler::utils::predict_next_executions` initialisée avec succès.');

    RETURN true;
};
