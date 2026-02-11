// Service minimal pour charger le menu (DB plus tard), avec fallback statique

export type DbMenuItem = {
  id: string;
  key: string;
  name_i18n?: string; // id de base_i18n_key (record id sous forme string)
  tooltip_i18n?: string;
  icon_key?: string;
  module_key?: string;
  enabled: boolean;
  order: number;
  name_text?: string;
  tooltip_text?: string;
};

import { SurrealClient } from './SurrealClient';

type ConfigLike = {
  infrastructure: {
    surrealDbUrl: { value: string };
    surrealNamespace: { value: string };
    surrealDatabase: { value: string };
    surrealUsername: { value: string };
    surrealPassword: { value: string };
  };
  ui?: { modules?: Record<string, boolean> };
};

export class MenuService {
  static async listActive(config?: ConfigLike): Promise<DbMenuItem[]> {
    if (!config) return [];
    try {
      const locale = 'FR';
      const rows = await SurrealClient.query<DbMenuItem[]>(config,
         `SELECT 
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
         ORDER BY \`order\`;`
      );
      return Array.isArray(rows) ? rows : [];
    } catch {
      return [];
    }
  }
}


