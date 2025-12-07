import { WorkerMessageHandler } from './core/worker';
import { MessageHandler } from './shared/message_handler';

// Worker Entry Point
// This code runs inside the Web Worker (or Node Worker)

const globalScope = typeof self !== 'undefined' ? self : this;

// Setup MessageHandler for the worker
const handler = new MessageHandler("worker", "main", globalScope);
WorkerMessageHandler.setup(handler, globalScope);

// Notify main thread we are ready (optional, but good practice)
// handler.send("Ready", null);

