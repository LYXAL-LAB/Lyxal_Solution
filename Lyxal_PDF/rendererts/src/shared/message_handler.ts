// Simplified implementation of pdf.js MessageHandler
// Handles async communication between "threads" (or mock threads in Bun)

export class MessageHandler {
    sourceName: string;
    targetName: string;
    actionHandler: Map<string, (data: any) => any> = new Map();
    streamControllers: Map<string, ReadableStreamDefaultController<any>> = new Map();
    
    // In a real worker environment, these would wrap postMessage
    // Here we'll mock it with direct callbacks for the single-thread Bun env
    otherSide: MessageHandler | null = null; 
    port: any = null; // MessagePort or Worker

    constructor(sourceName: string, targetName: string, port: any = null) {
        this.sourceName = sourceName;
        this.targetName = targetName;
        this.port = port;

        if (this.port) {
            // Setup listener
            // Node/Bun Worker or Web Worker
            const listener = (event: any) => {
                const data = event.data;
                
                // Handle Response
                if (data && data.isResponse && data.callbackId) {
                    const capability = this.callbackCapabilities.get(data.callbackId);
                    if (capability) {
                        this.callbackCapabilities.delete(data.callbackId);
                        if (data.error) {
                            capability.reject(new Error(data.error));
                        } else {
                            capability.resolve(data.result);
                        }
                    }
                    return;
                }

                // Handle Request
                if (data && data.action) {
                    this.handleMessage(data.action, data.data)
                        .then(result => {
                            if (data.callbackId) {
                                this.sendResponse(data.callbackId, result);
                            }
                        })
                        .catch(error => {
                            if (data.callbackId) {
                                this.sendError(data.callbackId, error);
                            } else {
                                console.error(`Uncaught error in ${this.sourceName}:`, error);
                            }
                        });
                }
            };
            
            if (typeof this.port.addEventListener === 'function') {
                this.port.addEventListener('message', listener);
            } else if (typeof this.port.on === 'function') {
                this.port.on('message', listener);
            } else {
                this.port.onmessage = listener;
            }
        }
    }

    setOtherSide(other: MessageHandler) {
        this.otherSide = other;
    }

    on(actionName: string, handler: (data: any) => any) {
        this.actionHandler.set(actionName, handler);
    }

    // Request/Response map
    callbackCapabilities: Map<number, {resolve: Function, reject: Function}> = new Map();
    callbackId: number = 1;

    async send(actionName: string, data: any, transfers?: any[]): Promise<any> {
        if (this.port) {
            const callbackId = this.callbackId++;
            return new Promise((resolve, reject) => {
                this.callbackCapabilities.set(callbackId, { resolve, reject });
                this.port.postMessage({
                    action: actionName,
                    data: data,
                    callbackId: callbackId
                }, transfers);
            });
        }
        
        if (!this.otherSide) throw new Error("No communication channel linked");
        return this.otherSide.handleMessage(actionName, data);
    }

    sendResponse(callbackId: number, result: any) {
        if (this.port) {
            this.port.postMessage({
                callbackId: callbackId,
                result: result,
                isResponse: true
            });
        }
    }

    sendError(callbackId: number, error: any) {
        if (this.port) {
            this.port.postMessage({
                callbackId: callbackId,
                error: error.message || error, // error objects might not clone well
                isResponse: true
            });
        }
    }
    
    // Internal method to handle incoming message
    async handleMessage(actionName: string, data: any): Promise<any> {
        // Check if it's a response
        // In the listener above, we need to distinguish responses.
        // Let's modify listener logic in constructor slightly by assuming handleMessage
        // is only for requests, and we handle responses separately? 
        // Or we handle everything here.
        
        // Actually, handleMessage is public, called by otherSide mock.
        // For port, we do logic inside the listener.
        
        const handler = this.actionHandler.get(actionName);
        if (!handler) {
            throw new Error(`Unknown action from ${this.sourceName}: ${actionName}`);
        }
        return handler(data);
    }


    // Stream support (for returning data chunks like text content)
    sendWithStream(actionName: string, data: any, transfers?: any[]): ReadableStream<any> {
         // This is complex to implement fully without real Workers.
         // Stubbing for now or implementing basic async generator pattern if needed.
         // In pdf.js, this creates a ReadableStream on the receiving end.
         throw new Error("Stream support not implemented in this mock");
    }
}

