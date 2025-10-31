/**
 * Tests SaaS - Architecture Bicéphale
 * Regroupés depuis lyxal-surreal avec améliorations
 */

import { MockSurrealClient, createMockSurrealClient } from '@lyxal-test/mocks';
import { createTestEnvironment, generateTestId, cleanSurrealProps } from '@lyxal-test/helpers';
import { TEST_USERS, createTestUser } from '@lyxal-test/fixtures';
import type { SurrealConfig, SaaSRecord } from '@lyxal-surreal/index';

describe('🏢 SaaS Instance Management - Architecture Bicéphale', () => {
  let client: MockSurrealClient;
  let testEnv: ReturnType<typeof createTestEnvironment>;
  let randomSaaSName: string;

  beforeAll(async () => {
    testEnv = createTestEnvironment('saas-tests');
    randomSaaSName = `saas_${testEnv.testId}`;
    
    const config: SurrealConfig = {
      url: 'mock://test-saas',
      namespace: 'test',
      database: 'saas_management',
      auth: { username: 'test', password: 'test' }
    };
    
    client = createMockSurrealClient(config);
    await client.initialize();
  });

  afterAll(async () => {
    await client.close();
    await testEnv.teardown();
  });

  test('✨ devrait créer une nouvelle instance SaaS', async () => {
    const saasConfig: Partial<SaaSRecord> = {
      displayName: `Test SaaS ${randomSaaSName}`,
      domain: 'test.example.com',
      plan: 'pro',
      limits: {
        maxWorkspaces: 10,
        maxUsers: 100,
        maxStorage: 50000
      },
      settings: {
        theme: 'dark',
        features: ['advanced_analytics', 'custom_branding']
      }
    };

    // Créer l'instance SaaS
    await client.createSaaS(randomSaaSName, saasConfig);
    
    // Vérifier que l'instance SaaS existe
    const saasExists = await client.saasExists(randomSaaSName);
    expect(saasExists).toBe(true);
    
    // Vérifier les données stockées
    await client.useSaaS(randomSaaSName);
    const saasData = client.getTableData('saas');
    
    expect(saasData).toHaveLength(1);
    const saasRecord = saasData[0];
    
    expect(saasRecord.name).toBe(randomSaaSName);
    expect(saasRecord.displayName).toBe(`Test SaaS ${randomSaaSName}`);
    expect(saasRecord.plan).toBe('pro');
    expect(saasRecord.status).toBe('active');
    
    console.log(`✅ SaaS créé: ${randomSaaSName}`);
  });

  test('🔍 devrait pouvoir naviguer vers une instance SaaS', async () => {
    // Naviguer vers l'instance SaaS
    await client.useSaaS(randomSaaSName);
    
    // Vérifier le namespace courant
    expect(client.getCurrentNamespace()).toBe(randomSaaSName);
    
    // Vérifier que les tables de base existent
    const saasData = client.getTableData('saas');
    expect(saasData.length).toBeGreaterThan(0);
    
    console.log(`🔍 Navigation SaaS réussie: ${randomSaaSName}`);
  });

  test('📊 devrait vérifier l\'existence d\'instances SaaS', async () => {
    // L'instance créée devrait exister
    const exists = await client.saasExists(randomSaaSName);
    expect(exists).toBe(true);
    
    // Une instance inexistante ne devrait pas exister
    const notExists = await client.saasExists(`nonexistent_${generateTestId('saas')}`);
    expect(notExists).toBe(false);
    
    console.log('📊 Vérification existence SaaS - OK');
  });

  test('⚙️ devrait gérer le catalogue des modules SaaS', async () => {
    await client.useSaaS(randomSaaSName);
    
    // Ajouter un module au catalogue
    const moduleData = {
      name: 'test_module',
      displayName: 'Test Module',
      version: '1.0.0',
      description: 'Module de test pour l\'architecture bicéphale',
      category: 'testing',
      requiredTables: [
        'DEFINE TABLE test_data SCHEMAFULL;',
        'DEFINE FIELD name ON test_data TYPE string;'
      ],
      dependencies: [],
      permissions: ['read', 'write']
    };
    
    await client.query('CREATE modules_catalog CONTENT $content', {
      content: moduleData
    });
    
    // Vérifier le catalogue
    const catalogData = client.getTableData('modules_catalog');
    expect(catalogData.length).toBeGreaterThan(0);
    
    const module = catalogData.find(m => m.name === 'test_module');
    expect(module).toBeDefined();
    expect(module?.displayName).toBe('Test Module');
    expect(module?.category).toBe('testing');
    
    console.log('⚙️ Catalogue modules - OK');
  });

  test('🚀 devrait supporter différents plans SaaS', async () => {
    const starterSaaS = `starter_${generateTestId('saas')}`;
    const enterpriseSaaS = `enterprise_${generateTestId('saas')}`;
    
    // Créer SaaS Starter
    await client.createSaaS(starterSaaS, {
      displayName: 'Starter SaaS',
      plan: 'starter',
      limits: { maxWorkspaces: 3, maxUsers: 10, maxStorage: 1000 }
    });
    
    // Créer SaaS Enterprise
    await client.createSaaS(enterpriseSaaS, {
      displayName: 'Enterprise SaaS',
      plan: 'enterprise',
      limits: { maxWorkspaces: 100, maxUsers: 10000, maxStorage: 1000000 }
    });
    
    // Vérifier Starter
    await client.useSaaS(starterSaaS);
    const starterData = client.getTableData('saas');
    expect(starterData[0].plan).toBe('starter');
    expect(starterData[0].limits.maxWorkspaces).toBe(3);
    
    // Vérifier Enterprise
    await client.useSaaS(enterpriseSaaS);
    const enterpriseData = client.getTableData('saas');
    expect(enterpriseData[0].plan).toBe('enterprise');
    expect(enterpriseData[0].limits.maxWorkspaces).toBe(100);
    
    console.log('🚀 Plans SaaS multiples - OK');
    
    // Nettoyage
    testEnv.addCleanup(() => {
      client.clearTable('saas');
    });
  });

  test('👥 devrait gérer les utilisateurs SaaS avec fixtures', async () => {
    await client.useSaaS(randomSaaSName);
    
    // Utiliser les fixtures de test
    const testUser = createTestUser({ role: 'admin' });
    const regularUser = TEST_USERS.find(u => u.role === 'user');
    
    expect(testUser.role).toBe('admin');
    expect(testUser.email).toContain('@test.lyxalsuite.com');
    expect(regularUser).toBeDefined();
    
    // Simuler l'ajout d'utilisateurs
    await client.query('CREATE users CONTENT $user1', { user1: testUser });
    await client.query('CREATE users CONTENT $user2', { user2: regularUser });
    
    const userData = client.getTableData('users');
    expect(userData).toHaveLength(2);
    
    // Nettoyer les propriétés SurrealDB pour comparaison
    const cleanUsers = userData.map(u => cleanSurrealProps(u));
    expect(cleanUsers.some(u => u.role === 'admin')).toBe(true);
    expect(cleanUsers.some(u => u.role === 'user')).toBe(true);
    
    console.log('👥 Gestion utilisateurs SaaS - OK');
  });

  test('🔒 devrait isoler les données entre instances SaaS', async () => {
    const saas1 = `isolation_test_1_${generateTestId('saas')}`;
    const saas2 = `isolation_test_2_${generateTestId('saas')}`;
    
    // Créer deux instances SaaS
    await client.createSaaS(saas1, { displayName: 'SaaS 1' });
    await client.createSaaS(saas2, { displayName: 'SaaS 2' });
    
    // Ajouter des données dans SaaS 1
    await client.useSaaS(saas1);
    await client.query('CREATE test_data CONTENT { name: "data1", value: "saas1" }');
    
    // Ajouter des données dans SaaS 2
    await client.useSaaS(saas2);
    await client.query('CREATE test_data CONTENT { name: "data2", value: "saas2" }');
    
    // Vérifier l'isolation
    await client.useSaaS(saas1);
    const data1 = client.getTableData('test_data');
    expect(data1).toHaveLength(1);
    expect(data1[0]?.value).toBe('saas1');
    
    await client.useSaaS(saas2);
    const data2 = client.getTableData('test_data');
    expect(data2).toHaveLength(1);
    expect(data2[0]?.value).toBe('saas2');
    
    console.log('🔒 Isolation SaaS - OK');
    
    // Nettoyage
    testEnv.addCleanup(() => {
      client.clearAll();
    });
  });
}); 