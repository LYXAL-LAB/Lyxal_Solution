import { Surreal } from 'surrealdb';

// =================================================================================================
// Configuration (à charger depuis des variables d'environnement)
// =================================================================================================

const CONFIG = {
    SURREAL_URL: process.env.SURREAL_URL || 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud',
    SURREAL_USER: process.env.SURREAL_USER || 'system_notification', // Utilisateur dédié
    SURREAL_PASS: process.env.SURREAL_PASS || 'notification_secret_password',
    SURREAL_NS: process.env.SURREAL_NS || 'lyxal',
    SURREAL_DB: process.env.SURREAL_DB || 'mcp',
    LOG_LEVEL: process.env.LOG_LEVEL || 'info',
    // Configurations SMTP
    SMTP_HOST: process.env.SMTP_HOST,
    SMTP_PORT: parseInt(process.env.SMTP_PORT || '587'),
    SMTP_USER: process.env.SMTP_USER,
    SMTP_PASS: process.env.SMTP_PASS,
};

// =================================================================================================
// Interfaces (à compléter)
// =================================================================================================

interface Notification {
    id: string;
    // ... autres champs de la table scheduler_notification
}

// Logger (peut être externalisé dans un fichier utilitaire partagé)
class Logger {
    private level: string;

    constructor(level: string = 'info') {
        this.level = level;
    }

    private shouldLog(level: string): boolean {
        const levels = ['debug', 'info', 'warn', 'error'];
        return levels.indexOf(level) >= levels.indexOf(this.level);
    }

    private log(level: string, message: string, metadata?: any) {
        if (this.shouldLog(level)) {
            console.log(JSON.stringify({ 
                timestamp: new Date().toISOString(), 
                level, 
                message, 
                service: 'NotificationWorker', 
                ...metadata 
            }));
        }
    }

    debug(message: string, metadata?: any) { this.log('debug', message, metadata); }
    info(message: string, metadata?: any) { this.log('info', message, metadata); }
    warn(message: string, metadata?: any) { this.log('warn', message, metadata); }
    error(message: string, metadata?: any) { this.log('error', message, metadata); }
}


// =================================================================================================
// Classe NotificationWorker
// =================================================================================================

class NotificationWorker {
    private db: Surreal;
    private running = false;
    private logger: Logger;
    private liveQueryUuid: string | null = null;

    constructor() {
        this.db = new Surreal();
        this.logger = new Logger(CONFIG.LOG_LEVEL);
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
            this.logger.info('NotificationWorker connecté à SurrealDB');
            return true;
        } catch (e: any) {
            this.logger.error('Erreur de connexion du NotificationWorker', { error: e.message });
            return false;
        }
    }

    public async start() {
        if (this.running) {
            this.logger.warn('Le NotificationWorker est déjà en cours d\'exécution');
            return;
        }
        this.running = true;
        this.logger.info('NotificationWorker démarré. En attente des notifications...');

        // Écoute des nouvelles notifications via LIVE QUERY
        try {
            const stream = await this.db.live('scheduler_notification', (data) => {
                this.logger.info('Notification reçue via LIVE QUERY', { action: data.action, data: data.result });
                if (data.action === 'CREATE') {
                    this.processNotification(data.result as Notification);
                }
            });
            
            if (typeof stream === 'string') {
                this.liveQueryUuid = stream;
            }

        } catch (e: any) {
            this.logger.error('Impossible de souscrire à la LIVE QUERY sur scheduler_notification', { error: e.message });
            this.stop();
        }
    }

    private async processNotification(notification: Notification) {
        this.logger.info(`Traitement de la notification`, { notificationId: notification.id });
        
        // TODO:
        // 1. Récupérer les détails complets (job, utilisateur, traductions/phrases) en appelant des fonctions fn::
        // 2. Construire l'e-mail avec un moteur de template (en utilisant les phrases)
        // 3. Envoyer l'e-mail via un client SMTP
        // 4. Mettre à jour la notification comme "traitée" ou la supprimer pour éviter un double envoi

        try {
            // Simule l'envoi d'un email
            this.logger.debug('Simulation de l\'envoi de l\'email...', { notificationId: notification.id });
            await new Promise(resolve => setTimeout(resolve, 500)); 
            this.logger.info(`Notification traitée avec succès.`, { notificationId: notification.id });

            // Une fois traitée, il est crucial de supprimer l'enregistrement pour ne pas la renvoyer
            await this.db.delete(notification.id);

        } catch (e: any) {
            this.logger.error(`Erreur lors du traitement de la notification`, { notificationId: notification.id, error: e.message });
            // TODO: Mettre en place une stratégie de retry ou de dead-letter queue ici
        }
    }

    public async stop() {
        this.running = false;
        if (this.liveQueryUuid) {
            try {
                await this.db.kill(this.liveQueryUuid);
                this.logger.info('LIVE QUERY arrêtée');
            } catch (e: any) {
                this.logger.warn('Erreur lors de l\'arrêt de la LIVE QUERY (peut-être déjà fermée)', { error: e.message });
            }
        }
        await this.db.close();
        this.logger.info('NotificationWorker arrêté.');
    }
}

// =================================================================================================
// Point d'entrée
// =================================================================================================

async function main() {
    const worker = new NotificationWorker();
    const logger = new Logger(CONFIG.LOG_LEVEL);

    const shutdown = async (signal: string) => {
        logger.info(`Réception du signal ${signal}. Arrêt du worker...`);
        await worker.stop();
        process.exit(0);
    };

    process.on('SIGINT', () => shutdown('SIGINT'));
    process.on('SIGTERM', () => shutdown('SIGTERM'));

    const connected = await worker.connect();
    if (connected) {
        worker.start();
    } else {
        logger.error("Impossible de démarrer le NotificationWorker sans connexion à la base de données.");
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

export { NotificationWorker, CONFIG };
