import { Surreal } from 'surrealdb';

// =================================================================================================
// Configuration (doit être chargée depuis des variables d'environnement en production)
// =================================================================================================

const CONFIG = {
    SURREAL_URL: process.env.SURREAL_URL || 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud',
    SURREAL_USER: process.env.SURREAL_USER || 'system_worker',
    SURREAL_PASS: process.env.SURREAL_PASS || 'worker_secret_password',
    SURREAL_NS: process.env.SURREAL_NS || 'lyxal',
    SURREAL_DB: process.env.SURREAL_DB || 'mcp',
    PARALLEL_EXECUTIONS: parseInt(process.env.PARALLEL_EXECUTIONS || '10'),
    JOB_TIMEOUT_MS: parseInt(process.env.JOB_TIMEOUT_MS || '30000'),
    MAX_QUEUE_SIZE: parseInt(process.env.MAX_QUEUE_SIZE || '1000'),
    METRICS_ENABLED: process.env.METRICS_ENABLED === 'true',
    LOG_LEVEL: process.env.LOG_LEVEL || 'info'
};

// =================================================================================================
// Interfaces
// =================================================================================================

interface Job {
    id: string;
    function_name: string;
    function_params: object;
    notification_on_success: boolean;
    notification_on_failure: boolean;
    defer: boolean;
    defer_max_ms: number;
}

interface JobResult {
    job_id: string;
    execution_status: 'success' | 'failure';
    return_value: any;
    start_time: string;
    end_time: string;
    duration_ms: number;
}

// =================================================================================================
// Logger structuré pour la production
// =================================================================================================

class Logger {
    private level: string;

    constructor(level: string = 'info') {
        this.level = level;
    }

    private shouldLog(level: string): boolean {
        const levels = ['debug', 'info', 'warn', 'error'];
        return levels.indexOf(level) >= levels.indexOf(this.level);
    }

    debug(message: string, metadata?: any) {
        if (this.shouldLog('debug')) {
            console.debug(JSON.stringify({ timestamp: new Date().toISOString(), level: 'debug', message, ...metadata }));
        }
    }

    info(message: string, metadata?: any) {
        if (this.shouldLog('info')) {
            console.info(JSON.stringify({ timestamp: new Date().toISOString(), level: 'info', message, ...metadata }));
        }
    }

    warn(message: string, metadata?: any) {
        if (this.shouldLog('warn')) {
            console.warn(JSON.stringify({ timestamp: new Date().toISOString(), level: 'warn', message, ...metadata }));
        }
    }

    error(message: string, metadata?: any) {
        if (this.shouldLog('error')) {
            console.error(JSON.stringify({ timestamp: new Date().toISOString(), level: 'error', message, ...metadata }));
        }
    }
}

// =================================================================================================
// Classe Worker optimisée pour la production
// =================================================================================================

class SchedulerWorker {
    private db: Surreal;
    private running = false;
    private currentlyExecuting = 0;
    private jobQueue: Job[] = [];
    private reconnectAttempts = 0;
    private maxReconnectAttempts = 10;
    private reconnectDelay = 5000;
    private logger: Logger;
    private metrics: {
        jobsExecuted: number;
        jobsFailed: number;
        averageExecutionTime: number;
        maxQueueSizeReached: number;
        lastTick: string;
        uptime: number;
    };

    constructor() {
        this.db = new Surreal();
        this.logger = new Logger(CONFIG.LOG_LEVEL);
        this.metrics = {
            jobsExecuted: 0,
            jobsFailed: 0,
            averageExecutionTime: 0,
            maxQueueSizeReached: 0,
            lastTick: new Date().toISOString(),
            uptime: 0
        };
        this.setupEventListeners();
    }

    private setupEventListeners() {
        this.db.on('close', () => {
            this.logger.warn('Connexion à la base de données fermée');
            this.attemptReconnection();
        });

        this.db.on('error', (error) => {
            this.logger.error('Erreur de connexion à la base de données', { error: error.message });
        });
    }

    public async connect(): Promise<boolean> {
        try {
            await this.db.connect(CONFIG.SURREAL_URL, {
                namespace: CONFIG.SURREAL_NS,
                database: CONFIG.SURREAL_DB,
                auth: {
                    user: CONFIG.SURREAL_USER,
                    pass: CONFIG.SURREAL_PASS,
                },
            });
            
            this.logger.info('Worker connecté à SurrealDB');
            this.reconnectAttempts = 0;
            return true;
        } catch (e) {
            this.logger.error('Erreur de connexion à SurrealDB', { error: e.message });
            this.attemptReconnection();
            return false;
        }
    }

    private async attemptReconnection() {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            this.logger.error('Nombre maximum de tentatives de reconnexion atteint. Arrêt du worker.');
            this.stop();
            return;
        }

        this.reconnectAttempts++;
        const delay = Math.min(this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1), 30000); // Backoff exponentiel avec limite à 30s
        
        this.logger.warn(`Tentative de reconnexion ${this.reconnectAttempts}/${this.maxReconnectAttempts} dans ${delay}ms`);

        setTimeout(async () => {
            const connected = await this.connect();
            if (connected && this.running) {
                this.logger.info('Reconnecté avec succès. Redémarrage du traitement');
                this.scheduleNextTick();
            }
        }, delay);
    }

    public start() {
        if (this.running) {
            this.logger.warn('Le worker est déjà en cours d\'exécution');
            return;
        }
        this.running = true;
        this.metrics.uptime = Date.now();
        this.logger.info('Worker démarré. En attente du prochain tick de minute');
        this.scheduleNextTick();

        // Mettre à jour l'uptime périodiquement
        setInterval(() => {
            this.metrics.uptime = Date.now() - this.metrics.uptime;
        }, 60000); // Toutes les minutes
    }

    public async stop() {
        this.running = false;
        this.logger.info('Arrêt du worker demandé');

        // Attendre que les jobs en cours se terminent
        if (this.currentlyExecuting > 0) {
            this.logger.info(`En attente de la fin de ${this.currentlyExecuting} job(s) en cours`);
            await new Promise(resolve => {
                const checkInterval = setInterval(() => {
                    if (this.currentlyExecuting === 0) {
                        clearInterval(checkInterval);
                        resolve(true);
                    }
                }, 100);
            });
        }

        try {
            await this.db.close();
            this.logger.info('Connexion à la base de données fermée');
        } catch (e) {
            this.logger.error('Erreur lors de la fermeture de la connexion', { error: e.message });
        }
    }

    private scheduleNextTick() {
        if (!this.running) return;

        const now = new Date();
        const nextMinute = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes() + 1, 0, 0);
        const delay = nextMinute.getTime() - now.getTime();

        setTimeout(() => this.tick(), delay);
    }

    private async tick() {
        this.metrics.lastTick = new Date().toISOString();
        this.logger.debug('Début du tick - récupération des jobs');

        try {
            const jobsToRun: Job[] = await this.db.query('PERFORM fn::scheduler::chronos::get_jobs_for_minute');
            if (jobsToRun && jobsToRun.length > 0) {
                this.logger.info(`${jobsToRun.length} job(s) à exécuter`);
                for (const job of jobsToRun) {
                    this.addToQueue(job);
                }
                this.processQueue();
            } else {
                this.logger.debug('Aucun job à exécuter pour cette minute');
            }
        } catch (e) {
            this.logger.error('Erreur lors de la récupération des jobs', { error: e.message });
        }

        this.scheduleNextTick();
    }

    private addToQueue(job: Job) {
        if (this.jobQueue.length >= CONFIG.MAX_QUEUE_SIZE) {
            this.logger.error(`File d'attente pleine. Rejet du job`, { jobId: job.id, queueSize: this.jobQueue.length });
            return;
        }
        this.jobQueue.push(job);
        this.metrics.maxQueueSizeReached = Math.max(this.metrics.maxQueueSizeReached, this.jobQueue.length);
    }

    private async processQueue() {
        while (this.currentlyExecuting < CONFIG.PARALLEL_EXECUTIONS && this.jobQueue.length > 0) {
            const job = this.jobQueue.shift();
            if (job) {

                // L'exécution n'est plus synchrone dans la boucle, donc on encapsule dans une IIFE asynchrone
                // pour ne pas bloquer la boucle `while` et permettre le lancement de plusieurs jobs en parallèle.
                (async () => {
                    try {
                        this.currentlyExecuting++;

                        // Si le lissage de charge est activé pour ce job, on attend un délai aléatoire.
                        if (job.defer && job.defer_max_ms > 0) {
                            const delay = Math.round(Math.random() * job.defer_max_ms);
                            this.logger.debug(`Lissage de charge activé, attente de ${delay}ms`, { jobId: job.id });
                            await this.sleep(delay);
                        }

                        await this.executeJobWithTimeout(job);

                    } catch (e) {
                        this.logger.error(`Erreur non capturée lors de l'exécution du job`, { jobId: job.id, error: e.message });
                    } finally {
                        this.currentlyExecuting--;
                        // Potentiellement relancer processQueue pour traiter le prochain item si la boucle est inactive
                        if (this.jobQueue.length > 0) {
                            this.processQueue();
                        }
                    }
                })();
            }
        }
    }

    private async executeJobWithTimeout(job: Job): Promise<void> {
        const timeoutPromise = new Promise((_, reject) => 
            setTimeout(() => reject(new Error(`Timeout après ${CONFIG.JOB_TIMEOUT_MS}ms`)), CONFIG.JOB_TIMEOUT_MS)
        );

        try {
            await Promise.race([this.executeJob(job), timeoutPromise]);
        } catch (e) {
            this.logger.error(`Job échoué ou expiré`, { jobId: job.id, error: e.message });
            await this.handleFailedJob(job, e);
        }
    }

    private async executeJob(job: Job) {
        this.logger.debug(`Exécution du job`, { jobId: job.id, function: job.function_name });
        const startTime = new Date();
        let result: Partial<JobResult> = {
            job_id: job.id,
            start_time: startTime.toISOString(),
        };

        try {
            // Validation basique uniquement
            if (!this.validateJobParameters(job)) {
                throw new Error("Validation basique du job a échoué");
            }

            const [fnResult] = await this.db.query(`PERFORM ${job.function_name} WITH $params`, {
                params: job.function_params || {},
            });

            result.execution_status = 'success';
            result.return_value = fnResult;

        } catch (e) {
            this.logger.error(`Erreur lors de l'exécution du job`, { jobId: job.id, error: e.message });
            result.execution_status = 'failure';
            result.return_value = e instanceof Error ? e.message : String(e);
            throw e;
        } finally {
            const endTime = new Date();
            result.end_time = endTime.toISOString();
            result.duration_ms = endTime.getTime() - startTime.getTime();
            
            if (result.execution_status) {
                await this.postProcessResult(job, result as JobResult);
            }
        }
    }

    private async handleFailedJob(job: Job, error: any) {
        const result: JobResult = {
            job_id: job.id,
            execution_status: 'failure',
            return_value: error instanceof Error ? error.message : String(error),
            start_time: new Date().toISOString(),
            end_time: new Date().toISOString(),
            duration_ms: 0
        };

        await this.postProcessResult(job, result);
    }

    private async postProcessResult(job: Job, result: JobResult) {
        this.collectMetrics(result);

        try {
            const [historyId]: [string | null] = await this.db.query(
                'PERFORM fn::scheduler::chronos::process_job_result WITH $result',
                { result }
            );

            if (!historyId) {
                this.logger.error(`Impossible d'enregistrer le résultat du job`, { jobId: job.id });
                return;
            }

            if (result.execution_status === 'success' && job.notification_on_success) {
                await this.db.query(
                    `PERFORM fn::scheduler::chronos::create_notification WITH {
                        job_id: $job_id,
                        history_id: $history_id,
                        type: "onSuccess"
                    }`,
                    { job_id: job.id, history_id: historyId }
                );
            } else if (result.execution_status === 'failure' && job.notification_on_failure) {
                await this.db.query(
                    `PERFORM fn::scheduler::chronos::create_notification WITH {
                        job_id: $job_id,
                        history_id: $history_id,
                        type: "onFailure"
                    }`,
                    { job_id: job.id, history_id: historyId }
                );
            }
        } catch (e) {
            this.logger.error(`Erreur lors du post-traitement du job`, { jobId: job.id, error: e.message });
        }
    }

    private validateJobParameters(job: Job): boolean {
        if (!job.id || !job.function_name) {
            this.logger.error(`Job invalide - id ou function_name manquant`, { job });
            return false;
        }
        
        if (job.function_params && JSON.stringify(job.function_params).length > 10000) {
            this.logger.error(`Paramètres trop volumineux`, { jobId: job.id });
            return false;
        }
        
        return true;
    }

    private collectMetrics(result: JobResult) {
        if (!CONFIG.METRICS_ENABLED) return;
        
        this.metrics.jobsExecuted++;
        if (result.execution_status === 'failure') {
            this.metrics.jobsFailed++;
        }
        
        this.metrics.averageExecutionTime = 
            (this.metrics.averageExecutionTime * (this.metrics.jobsExecuted - 1) + result.duration_ms) 
            / this.metrics.jobsExecuted;
    }

    public getMetrics() {
        return {
            ...this.metrics,
            averageExecutionTime: Math.round(this.metrics.averageExecutionTime),
            currentQueueSize: this.jobQueue.length,
            currentlyExecuting: this.currentlyExecuting,
            isConnected: this.db.status === 'CONNECTED',
            reconnectAttempts: this.reconnectAttempts
        };
    }

    public getStatus() {
        return {
            running: this.running,
            connected: this.db.status === 'CONNECTED',
            queueSize: this.jobQueue.length,
            executing: this.currentlyExecuting
        };
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// =================================================================================================
// Point d'entrée avec gestion d'erreur améliorée
// =================================================================================================

async function main() {
    const worker = new SchedulerWorker();
    const logger = new Logger(CONFIG.LOG_LEVEL);
    
    // Gestion des signaux d'arrêt
    const shutdown = async (signal: string) => {
        logger.info(`Réception du signal ${signal}. Arrêt du worker...`);
        await worker.stop();
        process.exit(0);
    };

    process.on('SIGINT', () => shutdown('SIGINT'));
    process.on('SIGTERM', () => shutdown('SIGTERM'));

    process.on('unhandledRejection', (reason, promise) => {
        logger.error('Rejet non géré', { promise, reason });
    });

    process.on('uncaughtException', (error) => {
        logger.error('Exception non attrapée', { error: error.message });
        process.exit(1);
    });

    try {
        const connected = await worker.connect();
        if (connected) {
            worker.start();

            // Afficher les métriques périodiquement si activé
            if (CONFIG.METRICS_ENABLED) {
                setInterval(() => {
                    logger.info("Métriques du worker", worker.getMetrics());
                }, 30000);
            }

        } else {
            logger.error("Impossible de se connecter à la base de données. Arrêt.");
            process.exit(1);
        }
    } catch (e) {
        logger.error("Erreur lors du démarrage du worker", { error: e.message });
        process.exit(1);
    }
}

// Exécution principale
if (require.main === module) {
    main();
}

export { SchedulerWorker, CONFIG };
