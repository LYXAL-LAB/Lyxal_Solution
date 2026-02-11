// Service minimal de résolution i18n (DB plus tard), fallback sur la clé
export class I18nService {
    static resolveKey(keyOrId, _locale) {
        if (keyOrId === null || keyOrId === undefined)
            return undefined;
        try {
            let raw;
            if (typeof keyOrId === 'string') {
                raw = keyOrId;
            }
            else if (typeof keyOrId === 'object') {
                const obj = keyOrId;
                if (typeof obj.id === 'string')
                    raw = obj.id; // ex: { id: 'base_i18n_key:menu.dashboard.name' }
                else if (typeof obj.$id === 'string')
                    raw = obj.$id;
                else
                    raw = String(obj);
            }
            else {
                raw = String(keyOrId);
            }
            if (!raw)
                return undefined;
            // Aucun traitement heuristique: renvoyer la clé telle quelle (en retirant seulement le préfixe du thing id)
            return raw.includes(':') ? raw.substring(raw.indexOf(':') + 1) : raw;
        }
        catch {
            return undefined;
        }
    }
}
