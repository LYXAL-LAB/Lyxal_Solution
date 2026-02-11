export interface OperatorPermissions {
    uiSafe?: boolean;          // allowed in UI engine
    backend?: boolean;         // allowed in backend engine
    roles?: string[];          // e.g. ['admin','editor']
    plans?: Array<'free' | 'pro' | 'enterprise'>;
    moduleAccess?: string[];   // e.g. ['studio','automation']
    premium?: boolean;         // gated feature
    tenantScope?: 'local' | 'global';
    allowedIn?: Array<'renderer' | 'workflow' | 'schema' | 'migration'>;
  }
  