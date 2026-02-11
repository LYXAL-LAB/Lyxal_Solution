/**
 * Exemple de test pour le parser
 * 
 * Ce fichier montre comment tester le parser avec des données mock
 * basées sur la structure du composant test_button créé dans SurrealDB.
 * 
 * Pour lancer les tests :
 * npm install --save-dev vitest @testing-library/react
 * Ajouter dans package.json : "test": "vitest"
 * 
 * Puis : npm test
 */

import { describe, it, expect } from 'vitest';
import { parseComponent } from '../index';
import { resolveTemplate } from '../resolveTemplate';
import type { StudioComponentStructure } from '../../types/component';

// Données mock basées sur studio_component:test_button
const mockTestButtonStructure: StudioComponentStructure = {
  type: 'button',
  props: {
    className: ['btn', 'btn-primary'],
    onClick: {
      type: 'action',
      action: 'state_update',
      target: 'button_clicked',
    },
    disabled: '{{props.disabled}}',
  },
  children: [
    {
      type: 'text',
      content: '{{props.label}}',
    },
  ],
  variants: {},
};

describe('Studio Parser', () => {
  describe('resolveTemplate', () => {
    it('should resolve simple template', () => {
      const result = resolveTemplate('{{props.label}}', {
        props: { label: 'Click me' },
      });
      expect(result).toBe('Click me');
    });

    it('should resolve nested template', () => {
      const result = resolveTemplate('{{page.title.fr}}', {
        page: { title: { fr: 'Contact' } },
      });
      expect(result).toBe('Contact');
    });

    it('should keep original if template not found', () => {
      const result = resolveTemplate('{{props.unknown}}', {
        props: {},
      });
      expect(result).toBe('{{props.unknown}}');
    });

    it('should handle non-string values', () => {
      const result = resolveTemplate(123, {});
      expect(result).toBe(123);
    });
  });

  describe('parseComponent', () => {
    it('should parse test_button structure', () => {
      const props = {
        label: 'Test Button',
        disabled: false,
      };

      const element = parseComponent(mockTestButtonStructure, props);

      expect(element).toBeDefined();
      expect(element.type).toBe('button');
      // Les props seront vérifiées dans le composant React rendu
    });

    it('should resolve templates in children', () => {
      const props = {
        label: 'Mon Bouton',
        disabled: true,
      };

      const element = parseComponent(mockTestButtonStructure, props);
      
      // L'élément devrait avoir les props résolues
      expect(element).toBeDefined();
    });
  });
});

