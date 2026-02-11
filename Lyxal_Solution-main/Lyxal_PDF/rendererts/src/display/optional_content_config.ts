
import { Util } from "../shared/util";

export class OptionalContentConfig {
    name: string | null = null;
    creator: string | null = null;
    private _groups: Map<string, any> = new Map();
    private _order: any[] = [];
    private _baseState: any = null; // 'ON' or 'OFF'

    constructor(data: any) {
        if (!data) return;
        
        this.name = data.name || null;
        this.creator = data.creator || null;
        this._baseState = data.baseState || "ON";
        
        if (data.order) {
            this._order = data.order;
        }
        
        if (data.groups) {
            for (const group of data.groups) {
                this._groups.set(group.id, {
                    id: group.id,
                    name: group.name,
                    intent: group.intent,
                    visible: group.currentState !== undefined ? group.currentState : (this._baseState === "ON")
                });
            }
        }
    }

    getGroups() {
        return Array.from(this._groups.values());
    }

    getGroup(id: string) {
        return this._groups.get(id);
    }

    setVisible(id: string, visible: boolean) {
        const group = this._groups.get(id);
        if (group) {
            group.visible = visible;
        }
    }

    isVisible(group: any): boolean {
        // Complex logic involving policy (AllOn, AnyOn, etc.) could go here.
        // For now, simple direct visibility.
        if (!group) return true;
        
        const g = this._groups.get(group.id || group);
        if (g) return g.visible;
        
        return true;
    }
    
    getOrder() {
        return this._order;
    }
}

