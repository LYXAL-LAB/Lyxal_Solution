
/**
 * Key-value storage for annotation data.
 * Used to store modified form values, ink signatures, etc.
 */
export class AnnotationStorage {
    private _storage: Map<string, any>;
    private _modified: boolean;
    
    // Callback for when storage changes (useful for UI updates)
    onSetModified: ((id: string, value: any) => void) | null = null;
    onResetModified: (() => void) | null = null;

    constructor() {
        this._storage = new Map();
        this._modified = false;
    }

    /**
     * Get the value for a given annotation ID.
     */
    getValue(id: string, defaultValue: any = null): any {
        return this._storage.has(id) ? this._storage.get(id) : defaultValue;
    }

    /**
     * Set the value for a given annotation ID.
     */
    setValue(id: string, value: any): void {
        this._storage.set(id, value);
        this._modified = true;
        if (this.onSetModified) {
            this.onSetModified(id, value);
        }
    }

    /**
     * Check if a value exists for the given ID.
     */
    has(id: string): boolean {
        return this._storage.has(id);
    }

    /**
     * Remove a value.
     */
    remove(id: string): void {
        this._storage.delete(id);
        if (this._storage.size === 0) {
            this.resetModified();
        }
    }

    /**
     * Get all stored values as a dictionary.
     */
    getAll(): Record<string, any> {
        const obj: Record<string, any> = {};
        for (const [key, value] of this._storage) {
            obj[key] = value;
        }
        return obj;
    }

    get size(): number {
        return this._storage.size;
    }

    resetModified(): void {
        this._modified = false;
        if (this.onResetModified) {
            this.onResetModified();
        }
    }

    /**
     * Clear all storage.
     */
    clear(): void {
        this._storage.clear();
        this.resetModified();
    }
}

