import { MessageHandler } from '../shared/message_handler';

export class WorkerTransport {
    worker: Worker | null = null;
    messageHandler: MessageHandler;

    constructor(workerSrc: string) {
        if (typeof Worker !== 'undefined' && workerSrc) {
            this.worker = new Worker(workerSrc, { type: "module" }); // Assume module for now
            this.messageHandler = new MessageHandler('main', 'worker', this.worker);
        } else {
            throw new Error("Worker API not supported or workerSrc not provided");
        }
    }

    destroy() {
        this.worker?.terminate();
        this.worker = null;
    }
}

