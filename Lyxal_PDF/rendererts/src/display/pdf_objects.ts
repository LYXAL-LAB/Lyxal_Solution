// Manages the mapping of object IDs to actual data (Fonts, Images) on the client side.
// In worker mode, this fetches data from the worker if not present.

export class PDFObjects {
    objs: Map<string, any> = new Map();
    
    constructor() {}

    async ensureObj(objId: string): Promise<any> {
        // If local, it might be already set.
        // If remote (worker), we might need to fetch it.
        // For now, assume it's pushed or available.
        if (this.objs.has(objId)) {
            return this.objs.get(objId);
        }
        return null;
    }

    get(objId: string): any {
        return this.objs.get(objId);
    }

    has(objId: string): boolean {
        return this.objs.has(objId);
    }

    resolve(objId: string, data: any) {
        this.objs.set(objId, data);
    }
}

