# 🔐 Configuration Logto Multi-Tenant

## 🎯 Vue d'ensemble

LyxalSuite utilise **Logto** pour gérer l'authentification multi-tenant avec une **organisation unique** et des **applications séparées** par SaaS instance.

## 🏗️ Architecture Logto

### Structure multi-tenant
```
🔐 Logto Organization: LyxalSuite
├── 📱 App: restaurant-bistro-paris.com
│   ├── Users: admin, manager, staff, waiter
│   └── Rôles: restaurant_admin, restaurant_manager, etc.
│
├── 📱 App: finance-conseil.com  
│   ├── Users: advisor, analyst, client
│   └── Rôles: finance_advisor, finance_analyst, etc.
│
└── 📱 App: ecommerce-mode.com
    ├── Users: owner, manager, support
    └── Rôles: ecommerce_owner, ecommerce_manager, etc.
```

## 🚀 Configuration initiale

### 1. Organisation Logto
```bash
# Installation Logto
npm install @logto/node @logto/js

# Variables d'environnement
LOGTO_ENDPOINT=https://your-logto-instance.com
LOGTO_APP_ID=your-app-id
LOGTO_APP_SECRET=your-app-secret
LOGTO_MANAGEMENT_API_RESOURCE=https://your-logto-instance.com/api
LOGTO_MANAGEMENT_API_TOKEN=your-management-token
```

### 2. Configuration Management API
```typescript
// Service Logto Management
@Injectable()
export class LogtoManagementService {
  private managementApi: LogtoManagementApi;
  
  constructor() {
    this.managementApi = new LogtoManagementApi({
      endpoint: process.env.LOGTO_ENDPOINT,
      credentials: {
        resource: process.env.LOGTO_MANAGEMENT_API_RESOURCE,
        accessToken: process.env.LOGTO_MANAGEMENT_API_TOKEN
      }
    });
  }
  
  // Création automatique d'une app SaaS
  async createSaaSApp(saasConfig: SaaSConfig): Promise<LogtoApplication> {
    const app = await this.managementApi.post('applications', {
      name: saasConfig.name,
      type: 'SPA',
      description: `SaaS Application for ${saasConfig.industry}`,
      oidc_client_metadata: {
        redirect_uris: [
          `https://${saasConfig.domain}/callback`,
          `https://${saasConfig.domain}/silent-callback`
        ],
        post_logout_redirect_uris: [
          `https://${saasConfig.domain}`,
          `https://${saasConfig.domain}/login`
        ],
        cors_allowed_origins: [
          `https://${saasConfig.domain}`
        ]
      },
      custom_client_metadata: {
        saas_id: saasConfig.saas_id,
        tenant_id: saasConfig.tenant_id,
        industry: saasConfig.industry
      }
    });
    
    return app;
  }
}
```

## 🎭 Rôles par industrie

### Configuration rôles restaurant
```typescript
// Rôles restaurant avec permissions granulaires
const RESTAURANT_ROLES = [
  {
    name: 'restaurant_admin',
    description: 'Propriétaire/gérant restaurant',
    scopes: [
      'crm:customers:*',
      'ecommerce:menu:*',
      'ecommerce:orders:*',
      'analytics:*',
      'staff:*'
    ]
  },
  {
    name: 'restaurant_manager',
    description: 'Manager opérationnel',
    scopes: [
      'crm:customers:read',
      'crm:customers:write',
      'ecommerce:menu:read',
      'ecommerce:orders:*',
      'analytics:read',
      'staff:read'
    ]
  },
  {
    name: 'restaurant_staff',
    description: 'Personnel service',
    scopes: [
      'crm:customers:read',
      'ecommerce:orders:read',
      'ecommerce:orders:update'
    ]
  },
  {
    name: 'restaurant_waiter',
    description: 'Serveur',
    scopes: [
      'ecommerce:orders:read',
      'ecommerce:orders:update:status'
    ]
  }
];

// Service création rôles automatique
@Injectable()
export class RoleManagementService {
  async createIndustryRoles(
    appId: string, 
    industry: string
  ): Promise<LogtoRole[]> {
    const roleTemplates = INDUSTRY_ROLE_TEMPLATES[industry];
    const createdRoles = [];
    
    for (const roleTemplate of roleTemplates) {
      // 1. Créer le rôle
      const role = await this.managementApi.post('roles', {
        name: roleTemplate.name,
        description: roleTemplate.description
      });
      
      // 2. Créer les scopes/permissions
      for (const scope of roleTemplate.scopes) {
        await this.managementApi.post('scopes', {
          name: scope,
          description: `Permission ${scope} for ${industry}`,
          resource_id: appId
        });
      }
      
      // 3. Assigner scopes au rôle
      await this.managementApi.post(`roles/${role.id}/scopes`, {
        scope_ids: roleTemplate.scopes.map(scope => 
          this.getScopeId(scope, appId)
        )
      });
      
      createdRoles.push(role);
    }
    
    return createdRoles;
  }
}
```

### Configuration rôles finance
```typescript
const FINANCE_ROLES = [
  {
    name: 'finance_advisor',
    description: 'Conseiller financier principal',
    scopes: [
      'crm:clients:*',
      'portfolio:*',
      'analytics:*',
      'ai:advisor:*',
      'reports:*'
    ]
  },
  {
    name: 'finance_analyst',
    description: 'Analyste financier',
    scopes: [
      'crm:clients:read',
      'portfolio:read',
      'analytics:*',
      'reports:read',
      'reports:write'
    ]
  },
  {
    name: 'finance_client',
    description: 'Client final',
    scopes: [
      'portfolio:read:own',
      'reports:read:own',
      'profile:*'
    ]
  }
];
```

## 🔄 Workflow authentification

### 1. Connexion utilisateur SaaS
```typescript
// Middleware détection SaaS
@Injectable()
export class SaaSDetectionMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Détection SaaS depuis domaine
    const host = req.get('host');
    const saasId = this.extractSaasFromDomain(host);
    
    if (saasId) {
      req['saas_id'] = saasId;
      req['logto_app_id'] = this.getLogtoAppId(saasId);
    }
    
    next();
  }
  
  private extractSaasFromDomain(host: string): string | null {
    // restaurant-bistro-paris.com → saas_67890
    return this.domainToSaasMapping[host] || null;
  }
}

// Configuration Logto par SaaS
@Controller('auth')
export class AuthController {
  
  @Get('config')
  async getAuthConfig(@Req() req): Promise<LogtoConfig> {
    const saasId = req.saas_id;
    const appId = req.logto_app_id;
    
    if (!saasId || !appId) {
      throw new BadRequestException('SaaS context required');
    }
    
    const saasConfig = await this.configService.getSaasConfig(saasId);
    
    return {
      endpoint: process.env.LOGTO_ENDPOINT,
      appId: appId,
      scopes: ['openid', 'profile', 'email', 'offline_access'],
      resources: [`https://api.${saasConfig.domain}`],
      prompt: 'consent'
    };
  }
  
  @Post('callback')
  async handleCallback(
    @Body() callbackData: LogtoCallbackData,
    @Req() req
  ) {
    const saasId = req.saas_id;
    
    // 1. Validation token Logto
    const userInfo = await this.logtoService.validateToken(
      callbackData.code,
      req.logto_app_id
    );
    
    // 2. Récupération/création utilisateur SaaS
    let user = await this.userService.findBySaasAndLogtoId(
      saasId,
      userInfo.sub
    );
    
    if (!user) {
      user = await this.userService.createFromLogto(saasId, userInfo);
    }
    
    // 3. Génération JWT interne avec contexte SaaS
    const jwt = await this.jwtService.sign({
      user_id: user.id,
      saas_id: saasId,
      account_id: user.account_id,
      workspace_ids: user.workspace_ids,
      roles: user.roles,
      permissions: user.permissions
    });
    
    return { access_token: jwt, user: user };
  }
}
```

### 2. Middleware validation permissions
```typescript
// Guard validation permissions granulaires
@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private permissionService: PermissionService
  ) {}
  
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermission = this.reflector.get<string>(
      'permission',
      context.getHandler()
    );
    
    if (!requiredPermission) {
      return true;
    }
    
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    
    if (!user) {
      throw new UnauthorizedException('User not authenticated');
    }
    
    // Vérification permission dans contexte SaaS
    const hasPermission = await this.permissionService.checkPermission(
      user.id,
      user.saas_id,
      requiredPermission
    );
    
    if (!hasPermission) {
      throw new ForbiddenException(
        `Permission ${requiredPermission} required`
      );
    }
    
    return true;
  }
}

// Utilisation
@Controller('crm')
export class CRMController {
  
  @Get('customers')
  @UseGuards(PermissionGuard)
  @Permission('crm:customers:read')
  async getCustomers(@Req() req) {
    const workspaceId = req.user.workspace_id;
    return await this.crmService.getCustomers(workspaceId);
  }
  
  @Post('customers')
  @UseGuards(PermissionGuard)
  @Permission('crm:customers:write')
  async createCustomer(@Body() customerDto: CreateCustomerDto, @Req() req) {
    const workspaceId = req.user.workspace_id;
    return await this.crmService.createCustomer(customerDto, workspaceId);
  }
}
```

## 🔧 Configuration avancée

### Hooks Logto personnalisés
```typescript
// Hook post-inscription
export const POST_REGISTER_HOOK = `
async function postRegister(user, context) {
  const { saas_id, industry } = context.application.customClientMetadata;
  
  // 1. Création account si premier utilisateur
  const accountExists = await checkAccountExists(saas_id, user.primaryEmail);
  
  if (!accountExists) {
    await createAccount({
      saas_id: saas_id,
      owner_email: user.primaryEmail,
      name: extractCompanyName(user.primaryEmail)
    });
  }
  
  // 2. Attribution rôle par défaut selon industrie
  const defaultRole = getDefaultRole(industry);
  await assignUserRole(user.id, defaultRole);
  
  // 3. Création workspace par défaut
  await createDefaultWorkspace(user.id, saas_id);
  
  // 4. Notification tenant
  await notifyTenantNewUser(saas_id, user);
}
`;

// Hook pré-connexion
export const PRE_SIGN_IN_HOOK = `
async function preSignIn(user, context) {
  const { saas_id } = context.application.customClientMetadata;
  
  // Vérification utilisateur autorisé pour ce SaaS
  const hasAccess = await checkUserSaaSAccess(user.id, saas_id);
  
  if (!hasAccess) {
    throw new Error('Access denied to this application');
  }
  
  // Mise à jour dernière connexion
  await updateLastLogin(user.id, saas_id);
}
`;
```

### SSO Enterprise (optionnel)
```typescript
// Configuration SSO pour clients enterprise
@Injectable()
export class SSOConfigService {
  async configureSAML(
    saasId: string,
    samlConfig: SAMLConfig
  ): Promise<void> {
    const appId = await this.getLogtoAppId(saasId);
    
    await this.managementApi.post(`applications/${appId}/connectors`, {
      connector_id: 'saml',
      config: {
        entity_id: samlConfig.entityId,
        sso_url: samlConfig.ssoUrl,
        certificate: samlConfig.certificate,
        name_id_format: 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
      }
    });
  }
  
  async configureOIDC(
    saasId: string,
    oidcConfig: OIDCConfig
  ): Promise<void> {
    const appId = await this.getLogtoAppId(saasId);
    
    await this.managementApi.post(`applications/${appId}/connectors`, {
      connector_id: 'oidc',
      config: {
        client_id: oidcConfig.clientId,
        client_secret: oidcConfig.clientSecret,
        issuer: oidcConfig.issuer,
        scope: 'openid profile email'
      }
    });
  }
}
```

## 📊 Monitoring et analytics

### Métriques authentification
```typescript
@Injectable()
export class AuthAnalyticsService {
  async trackLogin(userId: string, saasId: string, success: boolean) {
    await this.analytics.track('user_login', {
      user_id: userId,
      saas_id: saasId,
      success: success,
      timestamp: new Date().toISOString()
    });
  }
  
  async getAuthStats(saasId: string, period: string) {
    return {
      total_users: await this.getUserCount(saasId),
      active_users_24h: await this.getActiveUsers(saasId, '24h'),
      login_success_rate: await this.getLoginSuccessRate(saasId, period),
      top_user_agents: await this.getTopUserAgents(saasId, period)
    };
  }
}
```

---

**🔐 Logto Multi-Tenant : 1 organisation → ∞ SaaS apps → Sécurité maximale** 