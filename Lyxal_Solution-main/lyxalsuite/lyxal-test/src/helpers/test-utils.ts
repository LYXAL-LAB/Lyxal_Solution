/**
 * Utilitaires de test généraux pour LyxalSuite
 */

/**
 * Crée un délai pour les tests asynchrones
 */
export const delay = (ms: number): Promise<void> => {
  return new Promise(resolve => setTimeout(resolve, ms));
};

/**
 * Génère des IDs de test uniques
 */
export const generateTestId = (prefix: string = 'test'): string => {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 8);
  return `${prefix}_${timestamp}_${random}`;
};

/**
 * Utilitaire pour tester les erreurs asynchrones
 */
export const expectAsyncError = async (
  asyncFn: () => Promise<any>,
  expectedError?: string | RegExp
): Promise<void> => {
  try {
    await asyncFn();
    throw new Error('Expected function to throw an error');
  } catch (error: any) {
    if (expectedError) {
      if (typeof expectedError === 'string') {
        expect(error.message).toContain(expectedError);
      } else {
        expect(error.message).toMatch(expectedError);
      }
    }
  }
};

/**
 * Nettoie les propriétés temporelles pour les comparaisons
 */
export const cleanTimestamps = (obj: any): any => {
  if (Array.isArray(obj)) {
    return obj.map(cleanTimestamps);
  }
  
  if (obj && typeof obj === 'object') {
    const cleaned = { ...obj };
    delete cleaned.created_at;
    delete cleaned.updated_at;
    delete cleaned.timestamp;
    delete cleaned.requestDateT;     // ✅ GDPR timestamps
    delete cleaned.dueSendingDateT;  // ✅ GDPR timestamps
    delete cleaned.sendingDateT;     // ✅ GDPR timestamps
    
    Object.keys(cleaned).forEach(key => {
      cleaned[key] = cleanTimestamps(cleaned[key]);
    });
    
    return cleaned;
  }
  
  return obj;
};

/**
 * Nettoie les propriétés SurrealDB spécifiques pour les comparaisons
 */
export const cleanSurrealProps = (obj: any): any => {
  if (Array.isArray(obj)) {
    return obj.map(cleanSurrealProps);
  }
  
  if (obj && typeof obj === 'object') {
    const cleaned = { ...obj };
    delete cleaned.id; // ID SurrealDB auto-généré
    delete cleaned.created_at;
    delete cleaned.updated_at;
    delete cleaned.timestamp;
    
    Object.keys(cleaned).forEach(key => {
      cleaned[key] = cleanSurrealProps(cleaned[key]);
    });
    
    return cleaned;
  }
  
  return obj;
};

/**
 * Crée un environnement de test isolé avec support SaaS/Workspace
 */
export const createTestEnvironment = (name: string, saasId?: string, workspaceId?: string) => {
  const testId = generateTestId(name);
  
  return {
    testId,
    saasId: saasId || `test_saas_${testId}`,
    workspaceId: workspaceId || `test_workspace_${testId}`,
    cleanup: [] as (() => void | Promise<void>)[],
    addCleanup: function(fn: () => void | Promise<void>) {
      this.cleanup.push(fn);
    },
    teardown: async function() {
      for (const cleanupFn of this.cleanup.reverse()) {
        await cleanupFn();
      }
      this.cleanup = [];
    }
  };
}; 