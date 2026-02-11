/**
 * Fixtures d'utilisateurs pour les tests
 */

export interface TestUser {
  id?: string;
  email: string;
  name: string;
  role: 'admin' | 'user' | 'viewer';
  company_id?: string;
  created_at?: string;
  updated_at?: string;
}

export const TEST_USERS: TestUser[] = [
  {
    id: 'user:admin_test',
    email: 'admin@test.lyxalsuite.com',
    name: 'Admin Test',
    role: 'admin',
    company_id: 'company:test_company',
    created_at: '2024-01-01T00:00:00Z'
  },
  {
    id: 'user:user_test',
    email: 'user@test.lyxalsuite.com',
    name: 'User Test',
    role: 'user',
    company_id: 'company:test_company',
    created_at: '2024-01-01T00:00:00Z'
  },
  {
    id: 'user:viewer_test',
    email: 'viewer@test.lyxalsuite.com',
    name: 'Viewer Test',
    role: 'viewer',
    company_id: 'company:test_company',
    created_at: '2024-01-01T00:00:00Z'
  }
];

export const createTestUser = (overrides: Partial<TestUser> = {}): TestUser => {
  const timestamp = new Date().toISOString();
  const randomId = Math.random().toString(36).substring(2, 8);
  
  return {
    id: `user:test_${randomId}`,
    email: `test_${randomId}@test.lyxalsuite.com`,
    name: `Test User ${randomId}`,
    role: 'user',
    company_id: 'company:test_company',
    created_at: timestamp,
    ...overrides
  };
};

export const getTestUserByRole = (role: TestUser['role']): TestUser | undefined => {
  return TEST_USERS.find(user => user.role === role);
};

export const createMultipleTestUsers = (count: number, baseData: Partial<TestUser> = {}): TestUser[] => {
  return Array.from({ length: count }, (_, index) => 
    createTestUser({ 
      ...baseData, 
      name: `${baseData.name || 'Test User'} ${index + 1}` 
    })
  );
};