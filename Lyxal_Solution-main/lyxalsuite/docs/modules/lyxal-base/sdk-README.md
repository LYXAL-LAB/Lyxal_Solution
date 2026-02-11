# LyxalBase SDK

## 🎯 Objectif

Le SDK de **LyxalBase** fournit tous les outils nécessaires aux modules métier pour :
- Se connecter aux APIs
- Gérer l'authentification
- Utiliser les entités de base
- Accéder aux services communs

## 📦 Structure du SDK

```
sdk/
├── httpClient/           # Client HTTP avec authentification
│   ├── HttpClient.ts     # Client principal
│   ├── types.ts          # Types TypeScript
│   └── index.ts          # Exports publics
│
├── auth/                 # Utilitaires d'authentification
│   ├── AuthContext.ts    # Contexte d'auth
│   ├── TokenManager.ts   # Gestion des tokens
│   └── index.ts
│
├── base/                 # Classes et services de base
│   ├── BaseService.ts    # Service de base
│   ├── BaseEntity.ts     # Entité de base
│   ├── CrudService.ts    # CRUD générique
│   └── index.ts
│
├── entities/             # Entités typées
│   ├── Partner.ts        # Interface Partner
│   ├── Company.ts        # Interface Company
│   ├── Product.ts        # Interface Product
│   └── index.ts
│
└── index.ts              # Export principal
```

## 🌐 HttpClient

### Usage de Base

```typescript
import { HttpClient } from '@lyxalsuite/lyxal-base/sdk';

// Initialisation avec URL de base
const httpClient = new HttpClient('https://api.monapp.com');

// Requêtes typées
const partners = await httpClient.get<Partner[]>('/partners');
const partner = await httpClient.post<Partner>('/partners', partnerData);
```

### Configuration Avancée

```typescript
import { HttpClient, HttpClientConfig } from '@lyxalsuite/lyxal-base/sdk';

const config: HttpClientConfig = {
  baseURL: 'https://api.monapp.com',
  timeout: 30000,
  headers: {
    'X-App-Version': '1.0.0'
  },
  workspace: 'restaurant_paris',
  retryCount: 3,
  retryDelay: 1000
};

const httpClient = new HttpClient(config);
```

### Authentification Automatique

```typescript
// Le HttpClient gère automatiquement l'authentification
const httpClient = new HttpClient({
  baseURL: 'https://api.monapp.com',
  auth: {
    tokenProvider: () => getTokenFromStorage(),
    refreshProvider: () => refreshToken(),
    onAuthError: () => redirectToLogin()
  }
});

// Les requêtes incluent automatiquement les headers d'auth
const data = await httpClient.get('/protected-data');
```

## 🏗️ BaseService

### Service Générique CRUD

```typescript
import { BaseService } from '@lyxalsuite/lyxal-base/sdk';
import { Partner } from '@lyxalsuite/lyxal-base/sdk/entities';

class PartnerService extends BaseService<Partner> {
  constructor(httpClient: HttpClient) {
    super(httpClient, '/partners');
  }

  // CRUD automatique disponible :
  // - findAll()
  // - findById(id)
  // - create(data)
  // - update(id, data)
  // - delete(id)

  // Méthodes spécialisées
  async findCustomers(): Promise<Partner[]> {
    return this.httpClient.get<Partner[]>(`${this.basePath}?isCustomer=true`);
  }

  async findSuppliers(): Promise<Partner[]> {
    return this.httpClient.get<Partner[]>(`${this.basePath}?isSupplier=true`);
  }

  async findByEmail(email: string): Promise<Partner | null> {
    const results = await this.httpClient.get<Partner[]>(`${this.basePath}?email=${email}`);
    return results[0] || null;
  }
}
```

### Service Métier Spécialisé

```typescript
import { BaseService, HttpClient } from '@lyxalsuite/lyxal-base/sdk';

export class CrmContactService extends BaseService<Contact> {
  constructor(httpClient: HttpClient) {
    super(httpClient, '/crm/contacts');
  }

  async createLead(contactData: CreateContactDTO): Promise<Contact> {
    return this.create({
      ...contactData,
      status: 'lead',
      isContact: true
    });
  }

  async convertToCustomer(contactId: string): Promise<Contact> {
    return this.httpClient.patch<Contact>(`${this.basePath}/${contactId}/convert`, {
      status: 'customer',
      isCustomer: true
    });
  }

  async findByPipeline(pipeline: string): Promise<Contact[]> {
    return this.httpClient.get<Contact[]>(`${this.basePath}?pipeline=${pipeline}`);
  }
}
```

## 🎭 Entités Typées

### Partner

```typescript
import { Partner } from '@lyxalsuite/lyxal-base/sdk/entities';

interface Partner {
  id: string;
  partnerSeq: string;
  name: string;
  firstName?: string;
  fullName: string;
  
  // Types
  partnerTypeSelect: 1 | 2; // 1=Company, 2=Individual
  titleSelect?: 1 | 2 | 3; // 1=M., 2=Mme, 3=Mx
  
  // Statuts
  isCustomer: boolean;
  isSupplier: boolean;
  isContact: boolean;
  isEmployee: boolean;
  isProspect: boolean;
  
  // Contact
  emailAddress?: string;
  fixedPhone?: string;
  mobilePhone?: string;
  webSite?: string;
  
  // Relations
  parentPartner?: Partner;
  mainAddress?: Address;
  currency?: Currency;
  
  // Business
  paymentDelay?: number;
  registrationCode?: string;
  taxNbr?: string;
  
  // Audit
  workspaceId: string;
  createdAt: Date;
  updatedAt: Date;
  createdBy?: string;
}
```

### Company

```typescript
import { Company } from '@lyxalsuite/lyxal-base/sdk/entities';

interface Company {
  id: string;
  name: string;
  code: string;
  
  // Légal
  registrationCode?: string;
  taxNbr?: string;
  legalForm?: string;
  
  // Contact
  emailAddress?: string;
  phone?: string;
  webSite?: string;
  
  // Configuration
  currency: Currency;
  timezone: string;
  language: string;
  logoUrl?: string;
  
  // Relations
  parentCompany?: Company;
  mainAddress?: Address;
  isMain: boolean;
  
  // Workspace
  workspaceId: string;
  createdAt: Date;
  updatedAt: Date;
}
```

### Product

```typescript
import { Product } from '@lyxalsuite/lyxal-base/sdk/entities';

interface Product {
  id: string;
  name: string;
  code: string;
  fullName: string;
  
  // Type
  productTypeSelect: 'service' | 'storable';
  productCategory?: ProductCategory;
  
  // Descriptions
  description?: string;
  pictureUrl?: string;
  
  // Prix
  salePrice?: number;
  saleCurrency?: Currency;
  purchasePrice?: number;
  costPrice?: number;
  
  // Unités
  unit: Unit;
  
  // Statuts
  sellable: boolean;
  purchasable: boolean;
  isActive: boolean;
  
  // Dates
  startDate?: Date;
  endDate?: Date;
  
  // Workspace
  workspaceId: string;
  createdAt: Date;
  updatedAt: Date;
}
```

## 🔧 Utilitaires

### Configuration Workspace

```typescript
import { WorkspaceConfig } from '@lyxalsuite/lyxal-base/sdk';

class WorkspaceManager {
  constructor(private httpClient: HttpClient) {}

  async getCurrentWorkspace(): Promise<Workspace> {
    return this.httpClient.get<Workspace>('/workspace/current');
  }

  async switchWorkspace(workspaceId: string): Promise<void> {
    await this.httpClient.post('/workspace/switch', { workspaceId });
    this.httpClient.setWorkspace(workspaceId);
  }

  async getWorkspaceConfig(): Promise<WorkspaceConfig> {
    return this.httpClient.get<WorkspaceConfig>('/workspace/config');
  }
}
```

### Gestion des Erreurs

```typescript
import { ApiError, ErrorHandler } from '@lyxalsuite/lyxal-base/sdk';

try {
  const partner = await partnerService.create(invalidData);
} catch (error) {
  if (error instanceof ApiError) {
    switch (error.status) {
      case 400:
        console.error('Données invalides:', error.details);
        break;
      case 401:
        console.error('Non autorisé:', error.message);
        // Redirection vers login
        break;
      case 403:
        console.error('Accès refusé:', error.message);
        break;
      case 404:
        console.error('Ressource non trouvée');
        break;
      default:
        console.error('Erreur API:', error.message);
    }
  } else {
    console.error('Erreur inconnue:', error);
  }
}
```

## 🎮 Exemples d'Usage

### Module CRM

```typescript
// lyxal-crm/src/services/ContactService.ts
import { HttpClient, BaseService } from '@lyxalsuite/lyxal-base/sdk';
import { Partner } from '@lyxalsuite/lyxal-base/sdk/entities';

export class ContactService extends BaseService<Partner> {
  constructor(httpClient: HttpClient) {
    super(httpClient, '/partners');
  }

  async createContact(data: CreateContactDTO): Promise<Partner> {
    return this.create({
      ...data,
      isContact: true,
      partnerTypeSelect: data.isCompany ? 1 : 2
    });
  }

  async findContacts(): Promise<Partner[]> {
    return this.findAll({ isContact: true });
  }
}
```

### Module Marketing

```typescript
// lyxal-marketing/src/services/CampaignService.ts
import { HttpClient, BaseService } from '@lyxalsuite/lyxal-base/sdk';
import { Partner } from '@lyxalsuite/lyxal-base/sdk/entities';

export class CampaignService extends BaseService<Campaign> {
  constructor(
    httpClient: HttpClient,
    private partnerService: PartnerService
  ) {
    super(httpClient, '/campaigns');
  }

  async createEmailCampaign(campaignData: CreateCampaignDTO): Promise<Campaign> {
    // Utilise les partners comme cibles
    const targets = await this.partnerService.findCustomers();
    
    return this.create({
      ...campaignData,
      type: 'email',
      targets: targets.map(t => t.id)
    });
  }
}
```

### Module Sales

```typescript
// lyxal-sales/src/services/OrderService.ts
import { HttpClient, BaseService } from '@lyxalsuite/lyxal-base/sdk';
import { Partner, Product } from '@lyxalsuite/lyxal-base/sdk/entities';

export class OrderService extends BaseService<SaleOrder> {
  constructor(
    httpClient: HttpClient,
    private partnerService: PartnerService,
    private productService: ProductService
  ) {
    super(httpClient, '/orders');
  }

  async createOrder(customerId: string, productIds: string[]): Promise<SaleOrder> {
    const customer = await this.partnerService.findById(customerId);
    const products = await Promise.all(
      productIds.map(id => this.productService.findById(id))
    );

    return this.create({
      customer,
      orderLines: products.map(product => ({
        product,
        quantity: 1,
        unitPrice: product.salePrice
      }))
    });
  }
}
```

## 📚 Installation et Configuration

### Installation

```bash
npm install @lyxalsuite/lyxal-base
```

### Configuration dans un Module

```typescript
// config/sdk.ts
import { HttpClient } from '@lyxalsuite/lyxal-base/sdk';

export const httpClient = new HttpClient({
  baseURL: process.env.VITE_API_URL || 'https://api.lyxalsuite.com',
  workspace: process.env.VITE_WORKSPACE_ID,
  auth: {
    tokenProvider: () => localStorage.getItem('auth_token'),
    refreshProvider: async () => {
      // Logique de refresh token
    }
  }
});
```

### Export des Services

```typescript
// services/index.ts
import { httpClient } from '../config/sdk';
import { PartnerService, CompanyService, ProductService } from '@lyxalsuite/lyxal-base/sdk';

export const partnerService = new PartnerService(httpClient);
export const companyService = new CompanyService(httpClient);
export const productService = new ProductService(httpClient);
```

---

*Le SDK LyxalBase simplifie l'intégration et garantit la cohérence entre tous les modules de la suite.* 