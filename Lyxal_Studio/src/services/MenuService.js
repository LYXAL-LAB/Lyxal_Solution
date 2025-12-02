// Service minimal pour charger le menu (DB plus tard), avec fallback statique
import { SurrealClient } from './SurrealClient';
export class MenuService {
    static async listActive(config) {
        if (!config)
            return [];
        try {
            const locale = 'FR';
            const rows = await SurrealClient.query(config, `SELECT 
            id,
            key,
            name_i18n,
            tooltip_i18n,
            icon_key,
            module_key,
            enabled,
            \`order\`,
           array::first((SELECT VALUE text FROM name_i18n->base_i18n_translation WHERE out = type::thing('base_language', '${locale}') LIMIT 1)) AS name_text,
           array::first((SELECT VALUE text FROM tooltip_i18n->base_i18n_translation WHERE out = type::thing('base_language', '${locale}') LIMIT 1)) AS tooltip_text
          FROM ui_menu_item 
         WHERE enabled = true 
         ORDER BY \`order\`;`);
            return Array.isArray(rows) ? rows : [];
        }
        catch {
            return [];
        }
    }
}
