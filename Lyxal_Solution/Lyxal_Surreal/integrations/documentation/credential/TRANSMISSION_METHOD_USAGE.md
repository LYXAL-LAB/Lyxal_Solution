# 🔌 Utilisation de `transmission_method` pour IA + UI Driven

## 🎯 Vue d'ensemble

La table `transmission_method` est conçue pour :
1. **IA autonome** : Raisonnement et recommandations basées sur métadonnées
2. **UI driven** : Génération automatique de l'interface depuis la DB
3. **Intégrité** : Validation stricte des références

---

## 🤖 Utilisation par l'IA

### Scénario 1 : Recommander une méthode de transmission

```javascript
// IA reçoit : "User wants to send an API token"

async function recommendTransmissionMethod(context) {
    const methods = await db.select('transmission_method');
    
    // Filtrer par niveau de sécurité
    const secureMethods = methods.filter(m => 
        m.security_level >= 4 && 
        m.is_active
    );
    
    // Trouver la méthode recommandée
    const recommended = secureMethods.find(m => m.is_recommended) 
                        || secureMethods[0];
    
    return {
        method: recommended,
        reasoning: {
            security_level: recommended.security_level,
            why: recommended.best_use_cases,
            concerns: recommended.security_concerns,
            requires_https: recommended.requires_https
        }
    };
}

// IA retourne :
{
    method: "transmission_method:header",
    reasoning: {
        security_level: 4,
        why: ["Bearer tokens", "API keys", "Sensitive credentials"],
        concerns: ["Can be modified by proxies", "Visible in server logs"],
        requires_https: true
    }
}
```

### Scénario 2 : Alerter sur une mauvaise pratique

```javascript
// IA détecte : User veut utiliser query parameter pour un secret

async function validateTransmissionChoice(authType, context) {
    // Récupérer les métadonnées de la méthode choisie
    const method = await db.select(authType.http.transmission_method);
    
    // Vérifier si c'est une mauvaise pratique
    if (context.isSecret && method.security_level < 3) {
        return {
            warning: true,
            message: `⚠️ ${method.name} has security concerns for secrets`,
            concerns: method.security_concerns,
            alternatives: await db.query(`
                SELECT * FROM transmission_method 
                WHERE security_level >= 4 
                ORDER BY security_level DESC
            `),
            recommendation: "Use header transmission instead"
        };
    }
    
    return { ok: true };
}

// IA alerte :
{
    warning: true,
    message: "⚠️ query has security concerns for secrets",
    concerns: [
        "Visible in URL",
        "Logged in browser history",
        "Can be shared accidentally"
    ],
    alternatives: [transmission_method:header, transmission_method:body],
    recommendation: "Use header transmission instead"
}
```

### Scénario 3 : Expliquer une décision

```javascript
// IA explique pourquoi OAuth2 utilise headers

async function explainAuthType(authTypeId) {
    const authType = await db.query(`
        SELECT 
            name,
            identity.display_name,
            quality.security_level AS auth_security,
            http.transmission_method.* AS method
        FROM $id
    `, { id: authTypeId });
    
    return {
        explanation: `
            ${authType.identity.display_name} uses ${authType.method.name} transmission 
            because:
            - Security level: ${authType.method.security_level}/5
            - Best for: ${authType.method.best_use_cases.join(', ')}
            - Concerns: ${authType.method.security_concerns.join(', ')}
            - HTTPS required: ${authType.method.requires_https ? 'Yes' : 'No'}
        `,
        metadata: authType
    };
}
```

---

## 🎨 Utilisation par l'UI (Studio)

### Exemple 1 : Selector automatique

```typescript
// components/TransmissionMethodSelector.tsx

interface Props {
    value: string;
    onChange: (methodId: string) => void;
}

function TransmissionMethodSelector({ value, onChange }: Props) {
    // 1. Récupérer toutes les méthodes depuis la DB
    const { data: methods, loading } = useLiveQuery<TransmissionMethod[]>(
        'SELECT * FROM transmission_method WHERE is_active = true ORDER BY display_order'
    );
    
    if (loading) return <Skeleton />;
    
    // 2. UI se génère automatiquement
    return (
        <RadioGroup value={value} onChange={onChange}>
            {methods?.map(method => (
                <RadioCard
                    key={method.id}
                    value={method.id}
                    // Présentation depuis la DB
                    icon={<Icon data={method.icon} />}
                    label={method.display_name_i18n.translations[currentLang]}
                    description={method.description_i18n.translations[currentLang]}
                    tooltip={method.tooltip_i18n?.translations[currentLang]}
                    
                    // Badge de sécurité dynamique
                    badge={<SecurityBadge level={method.security_level} />}
                    
                    // Variante visuelle
                    variant={method.ui_variant}
                    
                    // Badge "Recommended"
                    recommended={method.is_recommended}
                >
                    {/* Détails expandables */}
                    <MethodDetails method={method} />
                </RadioCard>
            ))}
        </RadioGroup>
    );
}

// Le composant SecurityBadge
function SecurityBadge({ level }: { level: number }) {
    const config = {
        1: { label: 'Low', color: 'error' },
        2: { label: 'Caution', color: 'warning' },
        3: { label: 'Moderate', color: 'info' },
        4: { label: 'Secure', color: 'success' },
        5: { label: 'Highly Secure', color: 'success' }
    }[level];
    
    return <Badge color={config.color}>{config.label}</Badge>;
}
```

### Exemple 2 : Détails avec métadonnées IA

```typescript
function MethodDetails({ method }: { method: TransmissionMethod }) {
    return (
        <div className="space-y-4">
            {/* Security Info */}
            <SecurityInfo 
                level={method.security_level}
                concerns={method.security_concerns}
                requiresHttps={method.requires_https}
            />
            
            {/* Use Cases */}
            <UseCases 
                best={method.best_use_cases}
                avoid={method.avoid_use_cases}
            />
            
            {/* Technical Details */}
            <TechnicalDetails 
                location={method.technical_details?.location}
                format={method.technical_details?.format}
                example={method.technical_details?.example}
                standard={method.technical_details?.standard}
            />
        </div>
    );
}
```

### Exemple 3 : Validation temps réel

```typescript
function AuthTypeForm() {
    const [transmissionMethod, setTransmissionMethod] = useState('');
    const [isSecret, setIsSecret] = useState(true);
    
    // Récupérer les métadonnées de la méthode sélectionnée
    const { data: method } = useQuery(
        transmissionMethod ? `SELECT * FROM ${transmissionMethod}` : null
    );
    
    // Validation automatique
    const warning = useMemo(() => {
        if (!method || !isSecret) return null;
        
        if (method.security_level < 3) {
            return {
                type: 'warning',
                message: `${method.display_name_i18n.translations.en} is not recommended for sensitive data`,
                concerns: method.security_concerns,
                suggestion: 'Consider using Header transmission instead'
            };
        }
        
        return null;
    }, [method, isSecret]);
    
    return (
        <form>
            <TransmissionMethodSelector 
                value={transmissionMethod}
                onChange={setTransmissionMethod}
            />
            
            {/* Affichage de l'alerte */}
            {warning && (
                <Alert variant={warning.type}>
                    <AlertTitle>{warning.message}</AlertTitle>
                    <AlertDescription>
                        <ul>
                            {warning.concerns.map(c => (
                                <li key={c}>• {c}</li>
                            ))}
                        </ul>
                        <p className="mt-2 font-medium">{warning.suggestion}</p>
                    </AlertDescription>
                </Alert>
            )}
        </form>
    );
}
```

---

## 📊 Synchronisation temps réel

```typescript
// Hook personnalisé pour live updates
function useLiveTransmissionMethods() {
    const [methods, setMethods] = useState<TransmissionMethod[]>([]);
    
    useEffect(() => {
        let queryUuid: string;
        
        const setup = async () => {
            // Données initiales
            const initial = await db.select<TransmissionMethod>('transmission_method');
            setMethods(initial);
            
            // Écouter les changements
            queryUuid = await db.live<TransmissionMethod>(
                'transmission_method',
                (action, result) => {
                    setMethods(prev => {
                        switch (action) {
                            case 'UPDATE':
                                return prev.map(m => 
                                    m.id === result.id ? result : m
                                );
                            case 'CREATE':
                                return [...prev, result];
                            case 'DELETE':
                                return prev.filter(m => m.id !== result.id);
                            default:
                                return prev;
                        }
                    });
                }
            );
        };
        
        setup();
        
        return () => {
            if (queryUuid) db.kill(queryUuid);
        };
    }, []);
    
    return methods;
}
```

---

## 🔍 Cas d'usage complet

### Workflow : Création d'un nouveau auth type

```typescript
async function createAuthTypeWorkflow() {
    // 1. IA recommande une méthode
    const recommendation = await recommendTransmissionMethod({
        isSecret: true,
        useCase: 'API token'
    });
    
    console.log('IA recommande:', recommendation.method.name);
    // → "header"
    
    // 2. UI affiche le formulaire avec métadonnées
    const methods = await db.select('transmission_method');
    renderForm({ methods, recommended: recommendation.method.id });
    
    // 3. User sélectionne "query" (mauvais choix)
    const validation = await validateTransmissionChoice(
        { http: { transmission_method: 'transmission_method:query' } },
        { isSecret: true }
    );
    
    if (validation.warning) {
        // 4. UI affiche l'alerte
        showAlert({
            type: 'warning',
            message: validation.message,
            concerns: validation.concerns,
            alternatives: validation.alternatives
        });
        
        // 5. User corrige vers "header"
        return { http: { transmission_method: 'transmission_method:header' } };
    }
}
```

---

## 🎯 Avantages de cette architecture

### Pour l'IA
✅ Peut **raisonner** sur les métadonnées  
✅ Peut **recommander** des choix optimaux  
✅ Peut **alerter** sur les mauvaises pratiques  
✅ Peut **expliquer** ses décisions

### Pour l'UI
✅ **Auto-génération** complète depuis la DB  
✅ **Multilingue** via i18n_key  
✅ **Thèmes** via ui_variant  
✅ **Synchronisation temps réel** via WebSocket  
✅ **Zero hardcoding** dans le frontend

### Pour les développeurs
✅ **Single source of truth** dans la DB  
✅ **Intégrité référentielle** garantie  
✅ **Maintenance facilitée** (un seul endroit)  
✅ **Type-safe** avec SurrealDB

---

## 📚 Résumé

```
transmission_method (table)
    ↓
    ├─ Métadonnées pour IA
    │   • security_level
    │   • security_concerns
    │   • best_use_cases
    │   • avoid_use_cases
    │
    ├─ Métadonnées pour UI
    │   • display_name_i18n
    │   • icon
    │   • ui_variant
    │   • tooltip_i18n
    │
    └─ Utilisé par auth_type
        • http.transmission_method: record<transmission_method>
        • Intégrité garantie
        • Changement centralisé
```

**L'architecture est maintenant IA-ready et UI-driven ! 🚀**

