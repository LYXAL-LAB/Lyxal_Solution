# 📦 Backend Modulaire LyxalSuite

## 🎯 Vue d'ensemble

LyxalSuite utilise un **backend unique modulaire** qui sert tous les SaaS instances créés par les tenants. Chaque module peut être activé/désactivé selon les besoins du SaaS.

## 🏗️ Architecture modulaire

### Structure générale
```
LyxalSuite Backend (Node.js unique)
├── 🔌 Configuration Engine
│   ├── Gestion modules par SaaS
│   ├── Templates industrie
│   └── Permissions granulaires
│
├── 📦 Modules métier
│   ├── LyxalAuth (authentification)
│   ├── LyxalCRM (relation client)  
│   ├── LyxalAnalytics (analytics)
│   ├── LyxalAI (intelligence artificielle)
│   └── LyxalEcommerce (e-commerce)
│
├── 🛡️ Middleware Guards
│   ├── SaasGuard (validation SaaS)
│   ├── ModuleGuard (autorisation module)
│   └── PermissionGuard (droits utilisateur)
│
└── 🚀 Services transverses
    ├── NotificationService
    ├── FileStorageService
    ├── EmailService
    └── BillingService
```

## 🔌 Configuration Engine

### Gestionnaire de modules
```typescript
// Configuration d'un SaaS
interface SaasConfig {
  id: string;
  tenant_id: string;
  industry: 'restaurant' | 'finance' | 'ecommerce' | 'healthcare';
  modules: {
    enabled: ModuleName[];
    config: Record<ModuleName, ModuleConfig>;
  };
  template: TemplateConfig;
  branding: BrandingConfig;
}

// Service de configuration
@Injectable()
export class ConfigurationService {
  async getSaasConfig(saasId: string): Promise<SaasConfig> {
    return await this.db.select('*').from(`saas_${saasId}.config`);
  }
  
  async isModuleEnabled(saasId: string, module: ModuleName): Promise<boolean> {
    const config = await this.getSaasConfig(saasId);
    return config.modules.enabled.includes(module);
  }
  
  async getModuleConfig(saasId: string, module: ModuleName): Promise<ModuleConfig> {
    const config = await this.getSaasConfig(saasId);
    return config.modules.config[module];
  }
}
```

### Templates par industrie
```typescript
// Templates configurés par industrie
export const INDUSTRY_TEMPLATES = {
  restaurant: {
    modules: ['auth', 'crm', 'ecommerce', 'analytics'],
    pages: ['menu', 'orders', 'reservations', 'staff'],
    roles: ['admin', 'manager', 'staff', 'waiter'],
    permissions: {
      admin: ['*'],
      manager: ['crm.*', 'analytics.read', 'ecommerce.*'],
      staff: ['crm.customers.read', 'ecommerce.orders.*'],
      waiter: ['ecommerce.orders.read', 'ecommerce.orders.update']
    }
  },
  
  finance: {
    modules: ['auth', 'crm', 'analytics', 'ai'],
    pages: ['portfolio', 'clients', 'reports', 'ai-advisor'],
    roles: ['advisor', 'analyst', 'client'],
    permissions: {
      advisor: ['*'],
      analyst: ['analytics.*', 'crm.read'],
      client: ['portfolio.read', 'reports.read']
    }
  },
  
  ecommerce: {
    modules: ['auth', 'crm', 'ecommerce', 'analytics', 'ai'],
    pages: ['products', 'orders', 'customers', 'inventory'],
    roles: ['owner', 'manager', 'support', 'customer'],
    permissions: {
      owner: ['*'],
      manager: ['crm.*', 'ecommerce.*', 'analytics.read'],
      support: ['crm.customers.*', 'ecommerce.orders.read'],
      customer: ['ecommerce.orders.read']
    }
  }
};
```

## 📦 Modules métier

### 1. **LyxalAuth** - Authentification
```typescript
@Module({
  name: 'auth',
  version: '1.0.0',
  dependencies: []
})
export class LyxalAuthModule {
  
  // Configuration Logto par SaaS
  @Get('/auth/config/:saas_id')
  @UseGuards(SaasGuard)
  async getAuthConfig(@Param('saas_id') saasId: string) {
    return {
      logto_app_id: await this.getLogtoAppId(saasId),
      callback_url: `https://${saasId}.lyxalsuite.com/callback`,
      roles: await this.getSaasRoles(saasId)
    };
  }
  
  // Endpoint de connexion
  @Post('/auth/login')
  @UseGuards(ModuleGuard('auth'))
  async login(@Body() loginDto: LoginDto, @Request() req) {
    const saasId = req.headers['x-saas-id'];
    return await this.authService.login(loginDto, saasId);
  }
  
  // Gestion des rôles par SaaS
  @Get('/auth/roles')
  @UseGuards(PermissionGuard('auth.roles.read'))
  async getRoles(@Request() req) {
    const saasId = req.user.saas_id;
    const template = await this.configService.getTemplate(saasId);
    return template.roles;
  }
}
```

### 2. **LyxalCRM** - Relation client
```typescript
@Module({
  name: 'crm',
  version: '1.0.0',
  dependencies: ['auth']
})
export class LyxalCRMModule {
  
  // Clients par workspace
  @Get('/crm/customers')
  @UseGuards(ModuleGuard('crm'), PermissionGuard('crm.customers.read'))
  async getCustomers(@Request() req) {
    const workspaceId = req.user.workspace_id;
    return await this.db.select('*').from(`ws_${workspaceId}.customers`);
  }
  
  // Création client
  @Post('/crm/customers')
  @UseGuards(ModuleGuard('crm'), PermissionGuard('crm.customers.write'))
  async createCustomer(@Body() customerDto: CreateCustomerDto, @Request() req) {
    const workspaceId = req.user.workspace_id;
    
    // Configuration module selon industrie
    const saasId = req.user.saas_id;
    const moduleConfig = await this.configService.getModuleConfig(saasId, 'crm');
    
    // Vérification limites
    if (moduleConfig.limits?.customers) {
      const currentCount = await this.getCustomersCount(workspaceId);
      if (currentCount >= moduleConfig.limits.customers) {
        throw new ForbiddenException('Customer limit reached');
      }
    }
    
    return await this.crmService.createCustomer(customerDto, workspaceId);
  }
  
  // Pipeline CRM adapté à l'industrie
  @Get('/crm/pipeline')
  @UseGuards(ModuleGuard('crm'), PermissionGuard('crm.pipeline.read'))
  async getPipeline(@Request() req) {
    const saasId = req.user.saas_id;
    const industry = await this.configService.getIndustry(saasId);
    
    // Pipeline adapté selon industrie
    switch (industry) {
      case 'restaurant':
        return ['prospect', 'reservation', 'served', 'loyal'];
      case 'finance':
        return ['lead', 'qualified', 'proposal', 'client'];
      case 'ecommerce':
        return ['visitor', 'cart', 'order', 'repeat'];
      default:
        return ['lead', 'qualified', 'proposal', 'customer'];
    }
  }
}
```

### 3. **LyxalAnalytics** - Analytics
```typescript
@Module({
  name: 'analytics',
  version: '1.0.0',
  dependencies: ['auth']
})
export class LyxalAnalyticsModule {
  
  // Dashboard adapté à l'industrie
  @Get('/analytics/dashboard')
  @UseGuards(ModuleGuard('analytics'), PermissionGuard('analytics.read'))
  async getDashboard(@Request() req) {
    const workspaceId = req.user.workspace_id;
    const saasId = req.user.saas_id;
    const industry = await this.configService.getIndustry(saasId);
    
    switch (industry) {
      case 'restaurant':
        return await this.getRestaurantAnalytics(workspaceId);
      case 'finance':
        return await this.getFinanceAnalytics(workspaceId);
      case 'ecommerce':
        return await this.getEcommerceAnalytics(workspaceId);
      default:
        return await this.getGenericAnalytics(workspaceId);
    }
  }
  
  // Analytics restaurant spécifiques
  private async getRestaurantAnalytics(workspaceId: string) {
    return {
      revenue: await this.getRevenue(workspaceId),
      orders: await this.getOrdersStats(workspaceId),
      customers: await this.getCustomersStats(workspaceId),
      popular_dishes: await this.getPopularDishes(workspaceId),
      occupancy_rate: await this.getOccupancyRate(workspaceId),
      average_ticket: await this.getAverageTicket(workspaceId)
    };
  }
  
  // Analytics finance spécifiques
  private async getFinanceAnalytics(workspaceId: string) {
    return {
      portfolio_value: await this.getPortfolioValue(workspaceId),
      clients_performance: await this.getClientsPerformance(workspaceId),
      risk_metrics: await this.getRiskMetrics(workspaceId),
      fees_generated: await this.getFeesGenerated(workspaceId)
    };
  }
}
```

### 4. **LyxalAI** - Intelligence artificielle
```typescript
@Module({
  name: 'ai',
  version: '1.0.0',
  dependencies: ['auth']
})
export class LyxalAIModule {
  
  // Agent IA configuré par industrie
  @Post('/ai/chat')
  @UseGuards(ModuleGuard('ai'), PermissionGuard('ai.chat'))
  async chat(@Body() chatDto: ChatDto, @Request() req) {
    const saasId = req.user.saas_id;
    const industry = await this.configService.getIndustry(saasId);
    const workspaceId = req.user.workspace_id;
    
    // Contexte IA selon industrie
    const context = await this.buildIndustryContext(industry, workspaceId);
    
    return await this.aiService.processChat(chatDto.message, context);
  }
  
  // Automatisations par industrie
  @Get('/ai/automations')
  @UseGuards(ModuleGuard('ai'), PermissionGuard('ai.automations.read'))
  async getAutomations(@Request() req) {
    const saasId = req.user.saas_id;
    const industry = await this.configService.getIndustry(saasId);
    
    return INDUSTRY_AUTOMATIONS[industry] || [];
  }
  
  // Suggestions intelligentes
  @Post('/ai/suggestions')
  @UseGuards(ModuleGuard('ai'), PermissionGuard('ai.suggestions'))
  async getSuggestions(@Body() dataDto: any, @Request() req) {
    const industry = await this.configService.getIndustry(req.user.saas_id);
    
    switch (industry) {
      case 'restaurant':
        return await this.getRestaurantSuggestions(dataDto);
      case 'finance':
        return await this.getFinanceSuggestions(dataDto);
      case 'ecommerce':
        return await this.getEcommerceSuggestions(dataDto);
    }
  }
}
```

### 5. **LyxalEcommerce** - E-commerce
```typescript
@Module({
  name: 'ecommerce',
  version: '1.0.0', 
  dependencies: ['auth', 'crm']
})
export class LyxalEcommerceModule {
  
  // Produits adaptés à l'industrie
  @Get('/ecommerce/products')
  @UseGuards(ModuleGuard('ecommerce'), PermissionGuard('ecommerce.products.read'))
  async getProducts(@Request() req) {
    const workspaceId = req.user.workspace_id;
    const saasId = req.user.saas_id;
    const industry = await this.configService.getIndustry(saasId);
    
    // Champs produits selon industrie
    const productSchema = INDUSTRY_PRODUCT_SCHEMAS[industry];
    
    return await this.db.select(productSchema.fields)
      .from(`ws_${workspaceId}.products`);
  }
  
  // Commandes avec workflow industrie
  @Post('/ecommerce/orders')
  @UseGuards(ModuleGuard('ecommerce'), PermissionGuard('ecommerce.orders.write'))
  async createOrder(@Body() orderDto: CreateOrderDto, @Request() req) {
    const workspaceId = req.user.workspace_id;
    const saasId = req.user.saas_id;
    const industry = await this.configService.getIndustry(saasId);
    
    // Workflow commande selon industrie
    const workflow = INDUSTRY_ORDER_WORKFLOWS[industry];
    
    const order = await this.ecommerceService.createOrder(orderDto, workspaceId);
    await this.workflowService.startWorkflow(order.id, workflow);
    
    return order;
  }
  
  // Paiements avec gateways configurés
  @Post('/ecommerce/payment')
  @UseGuards(ModuleGuard('ecommerce'), PermissionGuard('ecommerce.payment'))
  async processPayment(@Body() paymentDto: PaymentDto, @Request() req) {
    const saasId = req.user.saas_id;
    const moduleConfig = await this.configService.getModuleConfig(saasId, 'ecommerce');
    
    // Gateways de paiement configurés
    const availableGateways = moduleConfig.payment_gateways || ['stripe'];
    
    if (!availableGateways.includes(paymentDto.gateway)) {
      throw new BadRequestException('Payment gateway not available');
    }
    
    return await this.paymentService.process(paymentDto);
  }
}
```

## 🛡️ Middleware Guards

### SaasGuard - Validation SaaS
```typescript
@Injectable()
export class SaasGuard implements CanActivate {
  constructor(
    private configService: ConfigurationService,
    private tenantService: TenantService
  ) {}
  
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const saasId = request.headers['x-saas-id'] || request.params.saas_id;
    const tenantId = request.user?.tenant_id;
    
    if (!saasId) {
      throw new BadRequestException('SaaS ID required');
    }
    
    // Vérifier que le tenant possède ce SaaS
    const ownsSaas = await this.tenantService.ownsSaas(tenantId, saasId);
    if (!ownsSaas) {
      throw new ForbiddenException('Access denied to this SaaS');
    }
    
    // Ajouter config SaaS à la requête
    request.saasConfig = await this.configService.getSaasConfig(saasId);
    
    return true;
  }
}
```

### ModuleGuard - Autorisation module
```typescript
@Injectable()
export class ModuleGuard implements CanActivate {
  constructor(private configService: ConfigurationService) {}
  
  static create(moduleName: string) {
    return mixin(class extends ModuleGuard {
      async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const saasId = request.user?.saas_id;
        
        if (!saasId) {
          throw new UnauthorizedException('SaaS context required');
        }
        
        const isEnabled = await this.configService.isModuleEnabled(saasId, moduleName);
        if (!isEnabled) {
          throw new ForbiddenException(`Module ${moduleName} not enabled`);
        }
        
        return true;
      }
    });
  }
}

// Utilisation
@UseGuards(ModuleGuard.create('crm'))
```

### PermissionGuard - Droits utilisateur
```typescript
@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(private permissionService: PermissionService) {}
  
  static require(permission: string) {
    return mixin(class extends PermissionGuard {
      async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const userId = request.user?.id;
        
        if (!userId) {
          throw new UnauthorizedException('User authentication required');
        }
        
        const hasPermission = await this.permissionService.checkPermission(
          userId, 
          permission
        );
        
        if (!hasPermission) {
          throw new ForbiddenException(`Permission ${permission} required`);
        }
        
        return true;
      }
    });
  }
}

// Utilisation
@UseGuards(PermissionGuard.require('crm.customers.write'))
```

## 🚀 Services transverses

### NotificationService
```typescript
@Injectable()
export class NotificationService {
  async sendNotification(
    userId: string,
    type: 'email' | 'push' | 'sms',
    template: string,
    data: any
  ) {
    const user = await this.getUserWithPreferences(userId);
    const saasId = user.saas_id;
    const branding = await this.configService.getBranding(saasId);
    
    // Personnalisation avec branding SaaS
    const personalizedTemplate = await this.templateService.personalize(
      template,
      { ...data, branding, user }
    );
    
    switch (type) {
      case 'email':
        return await this.emailService.send(user.email, personalizedTemplate);
      case 'push':
        return await this.pushService.send(user.push_token, personalizedTemplate);
      case 'sms':
        return await this.smsService.send(user.phone, personalizedTemplate);
    }
  }
}
```

### FileStorageService
```typescript
@Injectable()
export class FileStorageService {
  async uploadFile(
    file: Express.Multer.File,
    workspaceId: string,
    userId: string
  ) {
    // Stockage isolé par workspace
    const path = `workspaces/${workspaceId}/files/${userId}/${file.originalname}`;
    
    // Limites selon plan SaaS
    const saasId = await this.getUserSaasId(userId);
    const moduleConfig = await this.configService.getModuleConfig(saasId, 'storage');
    const limits = moduleConfig.limits || { max_file_size: 10, total_storage: 1000 };
    
    if (file.size > limits.max_file_size * 1024 * 1024) {
      throw new BadRequestException('File size exceeds limit');
    }
    
    const currentUsage = await this.getStorageUsage(workspaceId);
    if (currentUsage + file.size > limits.total_storage * 1024 * 1024) {
      throw new BadRequestException('Storage limit exceeded');
    }
    
    return await this.s3Service.upload(path, file.buffer);
  }
}
```

## 🔄 Configuration dynamique

### Hot reload des modules
```typescript
@Injectable()
export class ModuleLoaderService {
  private moduleCache = new Map<string, any>();
  
  async loadModule(saasId: string, moduleName: string) {
    const cacheKey = `${saasId}:${moduleName}`;
    
    if (this.moduleCache.has(cacheKey)) {
      return this.moduleCache.get(cacheKey);
    }
    
    const moduleConfig = await this.configService.getModuleConfig(saasId, moduleName);
    const moduleInstance = await this.createModuleInstance(moduleName, moduleConfig);
    
    this.moduleCache.set(cacheKey, moduleInstance);
    
    return moduleInstance;
  }
  
  async reloadModule(saasId: string, moduleName: string) {
    const cacheKey = `${saasId}:${moduleName}`;
    this.moduleCache.delete(cacheKey);
    
    return await this.loadModule(saasId, moduleName);
  }
}
```

### API Routes dynamiques
```typescript
// Routes générées dynamiquement selon modules activés
@Controller('api')
export class DynamicController {
  
  @All('*')
  async handleDynamicRoute(@Req() req, @Res() res) {
    const saasId = req.headers['x-saas-id'];
    const path = req.path;
    
    // Extraction du module depuis le path (/api/crm/customers)
    const [, , moduleName] = path.split('/');
    
    // Vérification module activé
    const isEnabled = await this.configService.isModuleEnabled(saasId, moduleName);
    if (!isEnabled) {
      return res.status(403).json({ error: 'Module not enabled' });
    }
    
    // Délégation au module approprié
    const moduleInstance = await this.moduleLoader.loadModule(saasId, moduleName);
    return await moduleInstance.handleRequest(req, res);
  }
}
```

---

**📦 Backend modulaire : 1 instance → ∞ configurations → Maximum flexibilité** 