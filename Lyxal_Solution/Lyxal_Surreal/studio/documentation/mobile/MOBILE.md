# 📱 Lyxal Studio Mobile - React Native

Guide complet pour intégrer Lyxal Studio dans une application React Native.

---

## 🎯 Vision

**Lyxal Studio Mobile** permet d'utiliser la **même configuration SurrealDB** que le web pour générer des applications mobiles natives iOS et Android.

**1 Config DB → Web + iOS + Android** 🚀

---

## ✨ Avantages

### Par rapport à une App Native Classique

| Aspect | App Native | Lyxal Studio Mobile |
|--------|-----------|---------------------|
| **Changement UI** | Rebuild app | UPDATE DB |
| **White-Label** | App séparée | 1 config DB |
| **Deploy** | App Store review | Instantané (config) |
| **Maintenance** | Code dupliqué | Config centralisée |
| **Thèmes** | Hard-coded | Dynamiques (DB) |
| **Menus** | Hard-coded | Dynamiques (DB) |

---

## 🛠️ Stack Technique

### Dépendances Requises

```json
{
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.73.0",
    "surrealdb.js": "^0.11.0",
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/drawer": "^6.6.6",
    "@react-navigation/bottom-tabs": "^6.5.11",
    "react-native-paper": "^5.11.3",
    "react-native-vector-icons": "^10.0.3",
    "react-native-svg": "^14.1.0",
    "react-native-chart-kit": "^6.12.0"
  }
}
```

### Installation

```bash
# Créer un nouveau projet React Native
npx react-native init LyxalMobile
cd LyxalMobile

# Installer les dépendances
npm install surrealdb.js
npm install @react-navigation/native @react-navigation/drawer @react-navigation/bottom-tabs
npm install react-native-paper react-native-vector-icons
npm install react-native-gesture-handler react-native-reanimated react-native-screens react-native-safe-area-context

# iOS uniquement
cd ios && pod install && cd ..
```

---

## 🔌 Configuration SurrealDB

### lib/surrealdb.ts

```typescript
import Surreal from 'surrealdb.js';

class SurrealDBClient {
  private db: Surreal;
  private static instance: SurrealDBClient;

  private constructor() {
    this.db = new Surreal();
  }

  public static getInstance(): SurrealDBClient {
    if (!SurrealDBClient.instance) {
      SurrealDBClient.instance = new SurrealDBClient();
    }
    return SurrealDBClient.instance;
  }

  public async connect() {
    try {
      await this.db.connect('wss://cloud.surrealdb.com:443/rpc');
      await this.db.use('lyxal_solution', 'main');
      
      // Authentification avec Lyxal Identity
      await this.db.signin({
        username: process.env.REACT_APP_SURREAL_USERNAME,
        password: process.env.REACT_APP_SURREAL_PASSWORD,
      });

      console.log('✅ Connected to SurrealDB Cloud');
    } catch (error) {
      console.error('❌ Failed to connect to SurrealDB:', error);
      throw error;
    }
  }

  public getDB() {
    return this.db;
  }

  public async query(query: string) {
    return await this.db.query(query);
  }
}

export const db = SurrealDBClient.getInstance();
```

---

## 🎨 Composant Principal : StudioEngine

### components/studio/StudioEngine.native.tsx

```typescript
import React, { useEffect, useState } from 'react';
import { View, StyleSheet, Image } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { Provider as PaperProvider, DefaultTheme } from 'react-native-paper';
import { db } from '@/lib/surrealdb';
import { useAuth } from '@/hooks/useAuth';
import { StudioMenuNavigator } from './StudioMenuNavigator';

const Drawer = createDrawerNavigator();

interface StudioEngineProps {
  tenant: string;
}

export const StudioEngine: React.FC<StudioEngineProps> = ({ tenant }) => {
  const [config, setConfig] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const { user } = useAuth();

  useEffect(() => {
    const loadConfig = async () => {
      try {
        await db.connect();
        
        const result = await db.query(`
          SELECT fn::studio_get_config('${tenant}')
        `);
        
        if (result?.[0]?.config) {
          setConfig(result[0].config);
        }
      } catch (error) {
        console.error('Failed to load Studio config:', error);
      } finally {
        setLoading(false);
      }
    };

    loadConfig();
  }, [tenant]);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Chargement...</Text>
      </View>
    );
  }

  if (!config) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Configuration introuvable</Text>
      </View>
    );
  }

  // Créer le thème React Native Paper depuis mobile_theme
  const theme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      primary: config.mobile_theme?.primary || '#3B82F6',
      accent: config.mobile_theme?.accent || '#10B981',
      background: config.mobile_theme?.background || '#FFFFFF',
      surface: config.mobile_theme?.surface || '#F9FAFB',
      text: config.mobile_theme?.text || '#1F2937',
      error: config.mobile_theme?.error || '#EF4444',
    },
  };

  return (
    <PaperProvider theme={theme}>
      <NavigationContainer>
        <Drawer.Navigator
          screenOptions={{
            drawerStyle: {
              backgroundColor: config.mobile_theme?.surface,
              width: 280,
            },
            headerStyle: {
              backgroundColor: config.mobile_theme?.primary,
            },
            headerTintColor: '#FFFFFF',
            headerTitle: () => (
              <Image 
                source={{ uri: config.logo }} 
                style={styles.logo}
                resizeMode="contain"
              />
            ),
          }}
        >
          <Drawer.Screen name="Main">
            {() => (
              <StudioMenuNavigator 
                config={config} 
                role={user?.role || 'guest'}
                modules={config.enabled_modules}
              />
            )}
          </Drawer.Screen>
        </Drawer.Navigator>
      </NavigationContainer>
    </PaperProvider>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  errorText: {
    color: '#EF4444',
    fontSize: 16,
    fontWeight: '600',
  },
  logo: {
    width: 120,
    height: 32,
  },
});
```

---

## 🧭 Navigation Dynamique

### components/studio/StudioMenuNavigator.native.tsx

```typescript
import React, { useEffect, useState } from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/Feather';
import { db } from '@/lib/surrealdb';
import { StudioScreen } from './StudioScreen';

const Tab = createBottomTabNavigator();

interface StudioMenuNavigatorProps {
  config: any;
  role: string;
  modules: string[];
}

export const StudioMenuNavigator: React.FC<StudioMenuNavigatorProps> = ({ 
  config, 
  role, 
  modules 
}) => {
  const [menu, setMenu] = useState<any[]>([]);

  useEffect(() => {
    const loadMenu = async () => {
      try {
        const result = await db.query(`
          SELECT fn::studio_get_menu('${config.tenant_id}', '${role}', ${JSON.stringify(modules)})
        `);
        
        if (result?.[0]?.menu) {
          // Filtrer uniquement les menus principaux (pas de parent)
          const mainMenus = result[0].menu.filter((item: any) => !item.parent);
          setMenu(mainMenus.slice(0, 5)); // Max 5 tabs
        }
      } catch (error) {
        console.error('Failed to load menu:', error);
      }
    };

    loadMenu();
  }, [config, role, modules]);

  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: config.mobile_theme?.primary,
        tabBarInactiveTintColor: '#6B7280',
        tabBarStyle: {
          backgroundColor: config.mobile_theme?.surface,
          borderTopColor: '#E5E7EB',
          borderTopWidth: 1,
          height: 60,
          paddingBottom: 8,
          paddingTop: 8,
        },
        headerShown: false,
      }}
    >
      {menu.map((item) => (
        <Tab.Screen
          key={item.code}
          name={item.code}
          options={{
            title: item.label.fr,
            tabBarIcon: ({ color, size }) => (
              <Icon name={item.icon || 'circle'} size={size} color={color} />
            ),
          }}
        >
          {() => <StudioScreen pageCode={item.code} tenant={config.tenant_id} />}
        </Tab.Screen>
      ))}
    </Tab.Navigator>
  );
};
```

---

## 📄 Rendu de Page Dynamique

### components/studio/StudioScreen.native.tsx

```typescript
import React, { useEffect, useState } from 'react';
import { View, ScrollView, StyleSheet, Text } from 'react-native';
import { db } from '@/lib/surrealdb';
import { StudioWidget } from './StudioWidget';

interface StudioScreenProps {
  pageCode: string;
  tenant: string;
}

export const StudioScreen: React.FC<StudioScreenProps> = ({ pageCode, tenant }) => {
  const [pageData, setPageData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadPage = async () => {
      try {
        const result = await db.query(`
          SELECT fn::studio_render_page('${pageCode}', '${tenant}')
        `);
        
        if (result?.[0]) {
          setPageData(result[0]);
        }
      } catch (error) {
        console.error('Failed to load page:', error);
      } finally {
        setLoading(false);
      }
    };

    loadPage();
  }, [pageCode, tenant]);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Chargement de la page...</Text>
      </View>
    );
  }

  if (!pageData) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Page introuvable</Text>
      </View>
    );
  }

  const { page, widgets } = pageData;

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>{page.title.fr}</Text>
        {page.description && (
          <Text style={styles.description}>{page.description.fr}</Text>
        )}
      </View>

      <View style={styles.widgetsContainer}>
        {widgets.map((w: any, index: number) => (
          <StudioWidget
            key={w.widget.code}
            widget={w.widget}
            initialData={w.data}
          />
        ))}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F9FAFB',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    color: '#EF4444',
    fontSize: 16,
  },
  header: {
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
  },
  description: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 4,
  },
  widgetsContainer: {
    padding: 16,
  },
});
```

---

## 📊 Widgets Natifs

### components/studio/StudioWidget.native.tsx

```typescript
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Card } from 'react-native-paper';
import Icon from 'react-native-vector-icons/Feather';
import { LineChart } from 'react-native-chart-kit';
import { db } from '@/lib/surrealdb';

interface StudioWidgetProps {
  widget: any;
  initialData?: any;
}

export const StudioWidget: React.FC<StudioWidgetProps> = ({ widget, initialData }) => {
  const [data, setData] = useState(initialData);

  useEffect(() => {
    if (widget.refresh_interval && widget.query) {
      const interval = setInterval(async () => {
        const result = await db.query(`
          SELECT fn::studio_execute_widget_query('${widget.code}')
        `);
        
        if (result?.[0]?.data) {
          setData(result[0].data);
        }
      }, widget.refresh_interval);

      return () => clearInterval(interval);
    }
  }, [widget]);

  const renderWidget = () => {
    switch (widget.type) {
      case 'stat':
        return <StatWidget widget={widget} data={data} />;
      case 'chart':
        return <ChartWidget widget={widget} data={data} />;
      case 'table':
        return <TableWidget widget={widget} data={data} />;
      default:
        return <Text>Widget type inconnu: {widget.type}</Text>;
    }
  };

  return (
    <Card style={styles.card}>
      {widget.title && (
        <Card.Title title={widget.title.fr} />
      )}
      <Card.Content>
        {renderWidget()}
      </Card.Content>
    </Card>
  );
};

// Stat Widget
const StatWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  return (
    <View style={styles.statContainer}>
      <Icon 
        name={widget.config.icon || 'activity'} 
        size={32} 
        color={widget.config.color || '#3B82F6'} 
      />
      <Text style={styles.statValue}>
        {data?.count || data?.total || 0}
      </Text>
      <Text style={styles.statLabel}>{widget.title?.fr}</Text>
    </View>
  );
};

// Chart Widget
const ChartWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  if (!data || !Array.isArray(data)) {
    return <Text>Pas de données</Text>;
  }

  const chartData = {
    labels: data.map((d: any) => d.month || d.label),
    datasets: [{
      data: data.map((d: any) => d.count || d.value || 0),
    }],
  };

  return (
    <LineChart
      data={chartData}
      width={300}
      height={220}
      chartConfig={{
        backgroundColor: '#FFFFFF',
        backgroundGradientFrom: '#FFFFFF',
        backgroundGradientTo: '#FFFFFF',
        decimalPlaces: 0,
        color: (opacity = 1) => `rgba(59, 130, 246, ${opacity})`,
        style: {
          borderRadius: 16,
        },
      }}
      bezier
      style={styles.chart}
    />
  );
};

// Table Widget
const TableWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  if (!data || !Array.isArray(data)) {
    return <Text>Pas de données</Text>;
  }

  return (
    <View>
      {data.slice(0, 5).map((row: any, i: number) => (
        <View key={i} style={styles.tableRow}>
          {widget.config.columns.map((col: any) => (
            <Text key={col.field} style={styles.tableCell}>
              {row[col.field]}
            </Text>
          ))}
        </View>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    marginBottom: 16,
  },
  statContainer: {
    alignItems: 'center',
    paddingVertical: 16,
  },
  statValue: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#1F2937',
    marginTop: 8,
  },
  statLabel: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 4,
  },
  chart: {
    marginVertical: 8,
    borderRadius: 16,
  },
  tableRow: {
    flexDirection: 'row',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  tableCell: {
    flex: 1,
    fontSize: 14,
    color: '#1F2937',
  },
});
```

---

## 🚀 Utilisation Complète

### App.tsx

```typescript
import React from 'react';
import { StudioEngine } from '@/components/studio/StudioEngine';
import { AuthProvider } from '@/contexts/AuthContext';

export default function App() {
  return (
    <AuthProvider>
      <StudioEngine tenant="lyxal" />
    </AuthProvider>
  );
}
```

**C'est tout !** L'app mobile est complètement pilotée par SurrealDB ! 🎉📱

---

## 🎯 Fonctionnalités Supportées

| Fonctionnalité | Web | Mobile |
|----------------|-----|--------|
| **Configuration dynamique** | ✅ | ✅ |
| **Menus dynamiques** | ✅ | ✅ (Drawer + Tabs) |
| **Pages dynamiques** | ✅ | ✅ (Screens) |
| **Widgets (stat, chart)** | ✅ | ✅ (Natifs) |
| **Formulaires** | ✅ | ✅ |
| **Thèmes** | ✅ (DaisyUI) | ✅ (RN Paper) |
| **LIVE QUERY** | ✅ | ✅ |
| **Offline Mode** | ⚠️ Limité | ✅ (AsyncStorage) |

---

## 📦 Build & Deploy

### iOS

```bash
# Build en développement
npx react-native run-ios

# Build production
cd ios
xcodebuild -workspace LyxalMobile.xcworkspace \
  -scheme LyxalMobile \
  -configuration Release \
  -archivePath build/LyxalMobile.xcarchive archive

# Upload sur App Store Connect
```

### Android

```bash
# Build en développement
npx react-native run-android

# Build production
cd android
./gradlew assembleRelease

# APK disponible dans: android/app/build/outputs/apk/release/app-release.apk
```

---

## 🔄 Synchronisation Web ↔ Mobile

### Config Partagée

```surql
-- 1 seule config pour web ET mobile
CREATE studio_config:lyxal SET
  tenant_id = "lyxal",
  
  -- Web (DaisyUI)
  web_theme = "corporate",
  
  -- Mobile (React Native)
  mobile_theme = {
    primary: "#3B82F6",
    secondary: "#10B981"
  },
  
  -- Partagé
  enabled_modules = ["crm", "sales"];
```

**Mise à jour instantanée sur les 2 plateformes** avec LIVE QUERY ! ⚡

---

## 🎉 Résultat Final

**1 configuration SurrealDB = Web + iOS + Android** ! 🌐📱

**Avantages** :
- ✅ Maintenance divisée par 3
- ✅ Features synchronisées
- ✅ White-Label instantané
- ✅ Deploy ultra rapide

---

## 🔗 Ressources

- [React Native Documentation](https://reactnative.dev)
- [React Navigation](https://reactnavigation.org)
- [React Native Paper](https://reactnativepaper.com)
- [SurrealDB.js](https://github.com/surrealdb/surrealdb.js)

---

**Lyxal Studio Mobile : Build Once, Run Everywhere** 📱🚀

