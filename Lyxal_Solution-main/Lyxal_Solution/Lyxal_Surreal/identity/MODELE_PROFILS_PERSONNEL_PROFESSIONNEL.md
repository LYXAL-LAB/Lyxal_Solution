# 👤💼 Modèle Profils Personnel/Professionnel - Lyxal

## 🎯 Concept Clé

### Un Template Universel, Plusieurs Contextes d'Usage

```
LYXAL (Un seul template complet)
├─ Module CRM
├─ Module Ventes
├─ Module Trésorerie
├─ Module Comptabilité
├─ Module Projets
├─ Module RH
├─ Module Documents
├─ Module Analytics
└─ Etc.

Ce template unique est utilisé dans différents PROFILS :
├─ 👤 Profil PERSONNEL (usage privé)
└─ 💼 Profil(s) PROFESSIONNEL(S) (usage entreprise)
```

**MÊMES MODULES, DONNÉES DIFFÉRENTES selon le profil actif**

---

## 👤 Profil Personnel - Usage Privé

### Exemple : Jean Dupont (8h - Usage Personnel)

```
┌────────────────────────────────────────────────────────────┐
│  👤 PROFIL PERSONNEL - Jean Dupont                         │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 Mon Dashboard Personnel                                │
│  ├─ Budget mensuel : 3 500€                                │
│  ├─ Dépenses du mois : 2 100€                              │
│  └─ Économies : 15 000€                                    │
│                                                             │
│  📱 Modules Disponibles                                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                │
│  │ 💰       │  │ 📋       │  │ 📁       │                │
│  │Trésorerie│  │ Projets  │  │Documents │                │
│  │ Perso    │  │ Maison   │  │ Perso    │                │
│  └──────────┘  └──────────┘  └──────────┘                │
│                                                             │
│  🏠 Projet en cours                                        │
│  └─ Rénovation cuisine (Budget: 8 000€)                    │
│                                                             │
│  🛒 Achats à faire                                         │
│  ├─ Ordinateur portable                                    │
│  └─ Aspirateur robot                                       │
└────────────────────────────────────────────────────────────┘
```

### Données Stockées (Profil Personnel)

```sql
NAMESPACE: profile_jean_dupont_personal

-- Contacts personnels
crm_contacts [
  { name: "Marie (épouse)", phone: "...", type: "famille" },
  { name: "Paul (ami)", phone: "...", type: "ami" }
]

-- Compte bancaire personnel
tresorerie_comptes [
  { name: "Compte Courant Perso", bank: "BNP", solde: 3500 }
]

-- Projets personnels
projets [
  { name: "Rénovation cuisine", budget: 8000, progress: 45% },
  { name: "Vacances été 2024", budget: 3000, progress: 10% }
]

-- Documents personnels
documents [
  { name: "Facture EDF.pdf", type: "facture", date: "2024-01" },
  { name: "Assurance voiture.pdf", type: "assurance" }
]
```

---

## 💼 Profil Professionnel - Usage Entreprise

### Exemple : Jean Dupont (9h - Usage Professionnel)

```
┌────────────────────────────────────────────────────────────┐
│  💼 PROFIL PROFESSIONNEL - Martin Bâtiment SARL            │
│  Jean Dupont (Gérant)                                      │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 Dashboard Entreprise                                   │
│  ├─ CA du mois : 78 000€                                   │
│  ├─ Trésorerie : 45 000€                                   │
│  ├─ 12 chantiers en cours                                  │
│  └─ 5 employés                                             │
│                                                             │
│  📱 Modules Disponibles                                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ 🏗️       │  │ 💼       │  │ 💰       │  │ 👥       │ │
│  │Chantiers │  │  Ventes  │  │Trésorerie│  │   RH     │ │
│  │          │  │          │  │Entreprise│  │          │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │
│                                                             │
│  🏗️ Chantiers en cours (12)                               │
│  ├─ Villa Dupont (80% - En retard 3j)                     │
│  ├─ Immeuble Centre (45%)                                  │
│  └─ [Voir tous les chantiers]                              │
│                                                             │
│  💼 Devis en attente (8)                                   │
│  ├─ Rénovation appartement - 45 000€                       │
│  └─ [Voir tous les devis]                                  │
└────────────────────────────────────────────────────────────┘
```

### Données Stockées (Profil Professionnel)

```sql
NAMESPACE: profile_martin_batiment_sarl

-- Clients entreprise
crm_contacts [
  { name: "Société ABC", siret: "...", type: "client" },
  { name: "Promoteur XYZ", siret: "...", type: "client" }
]

-- Compte bancaire entreprise
tresorerie_comptes [
  { name: "Compte Pro SARL", bank: "BNP Pro", solde: 45000 }
]

-- Chantiers (projets entreprise)
projets [
  { name: "Villa Dupont", client: "M. Dupont", budget: 180000, progress: 80% },
  { name: "Immeuble Centre", client: "ABC", budget: 450000, progress: 45% }
]

-- Devis et factures
ventes_devis [
  { numero: "D-2024-001", client: "...", montant: 45000, statut: "en_attente" }
]

ventes_factures [
  { numero: "F-2024-032", client: "...", montant: 25000, statut: "payee" }
]

-- Employés
rh_employes [
  { name: "Marc Martin", poste: "Maçon", salaire: 2500 },
  { name: "Julie Petit", poste: "Chef de chantier", salaire: 3500 }
]
```

---

## 🔄 Switch entre Profils - Journée Type

### Monsieur Dupont - Journée Complète

```
┌────────────────────────────────────────────────────────────┐
│  8h00 - CONNEXION UNIQUE                                   │
│  jean.dupont@email.fr                                      │
│  ✅ Connecté pour la journée                               │
└────────────────────────────────────────────────────────────┘
                        ↓
┌────────────────────────────────────────────────────────────┐
│  8h05 - 👤 PROFIL PERSONNEL                                │
│  ├─ Recherche ordinateur sur Amazon                        │
│  ├─ Consulte budget personnel (3 500€)                     │
│  └─ Ajoute dépense rénovation cuisine                      │
│                                                             │
│  Temps passé : 15 minutes                                  │
└────────────────────────────────────────────────────────────┘
                        ↓
        [CLIC Switch Profil] 🔄 (<50ms)
                        ↓
┌────────────────────────────────────────────────────────────┐
│  9h00 - 💼 PROFIL PROFESSIONNEL (Martin Bâtiment)          │
│  ├─ Consulte chantiers en cours (12)                       │
│  ├─ Valide facture client ABC (25 000€)                    │
│  ├─ Crée devis pour nouveau client (45 000€)               │
│  └─ Planifie équipes pour la semaine                       │
│                                                             │
│  Temps passé : 3h30                                        │
└────────────────────────────────────────────────────────────┘
                        ↓
        [CLIC Switch Profil] 🔄 (<50ms)
                        ↓
┌────────────────────────────────────────────────────────────┐
│  12h30 - 👤 PROFIL PERSONNEL                               │
│  ├─ Commande déjeuner en ligne                             │
│  ├─ Valide achat ordinateur (800€)                         │
│  └─ Met à jour budget mensuel                              │
│                                                             │
│  Temps passé : 20 minutes                                  │
└────────────────────────────────────────────────────────────┘
                        ↓
        [CLIC Switch Profil] 🔄 (<50ms)
                        ↓
┌────────────────────────────────────────────────────────────┐
│  13h00 - 💼 PROFIL PROFESSIONNEL (Martin Bâtiment)          │
│  ├─ Réunion de chantier (notes)                            │
│  ├─ Suivi trésorerie entreprise                            │
│  ├─ Validation heures employés                             │
│  └─ Préparation appel d'offres                             │
│                                                             │
│  Temps passé : 5h                                          │
└────────────────────────────────────────────────────────────┘
                        ↓
        [CLIC Switch Profil] 🔄 (<50ms)
                        ↓
┌────────────────────────────────────────────────────────────┐
│  18h30 - 👤 PROFIL PERSONNEL                               │
│  └─ Planifie vacances d'été (projet personnel)             │
└────────────────────────────────────────────────────────────┘

✨ TOUTE LA JOURNÉE :
   - 1 connexion
   - 5 switchs de profil (instantanés)
   - 0 friction
   - Données complètement isolées
```

---

## 🏗️ Architecture SurrealDB

### Table des Profils

```sql
-- =====================================================
-- TABLE : user_profiles
-- =====================================================
USE NAMESPACE lyxal_identity;
USE DATABASE main;

DEFINE TABLE user_profiles SCHEMAFULL;

DEFINE FIELD profile_id ON user_profiles TYPE string;
DEFINE FIELD lyxal_id ON user_profiles TYPE string;

-- Type de profil
DEFINE FIELD profile_type ON user_profiles TYPE string
  ASSERT $value IN ['personal', 'business'];

-- Informations profil
DEFINE FIELD profile_name ON user_profiles TYPE string;
DEFINE FIELD avatar ON user_profiles TYPE string;
DEFINE FIELD namespace ON user_profiles TYPE string;

-- Informations entreprise (si business)
DEFINE FIELD company_name ON user_profiles TYPE string;
DEFINE FIELD company_siret ON user_profiles TYPE string;
DEFINE FIELD company_type ON user_profiles TYPE string;
DEFINE FIELD role ON user_profiles TYPE string;

-- Métadonnées
DEFINE FIELD favorite ON user_profiles TYPE bool DEFAULT false;
DEFINE FIELD color ON user_profiles TYPE string;
DEFINE FIELD created_at ON user_profiles TYPE datetime DEFAULT time::now();
DEFINE FIELD last_accessed ON user_profiles TYPE datetime;

DEFINE INDEX profile_id_unique ON user_profiles FIELDS profile_id UNIQUE;
DEFINE INDEX lyxal_id_profiles ON user_profiles FIELDS lyxal_id;

-- =====================================================
-- EXEMPLES : Jean Dupont avec ses profils
-- =====================================================

-- Profil personnel
CREATE user_profiles SET
  profile_id = 'jean_dupont_personal',
  lyxal_id = 'jean_dupont_123abc',
  profile_type = 'personal',
  profile_name = 'Jean Dupont (Personnel)',
  avatar = '/avatars/jean-perso.jpg',
  namespace = 'profile_jean_dupont_personal',
  favorite = true,
  color = '#3B82F6',
  created_at = time::now();

-- Profil professionnel 1
CREATE user_profiles SET
  profile_id = 'martin_batiment_sarl',
  lyxal_id = 'jean_dupont_123abc',
  profile_type = 'business',
  profile_name = 'Martin Bâtiment',
  avatar = '/avatars/martin-batiment.jpg',
  namespace = 'profile_martin_batiment_sarl',
  company_name = 'Martin Bâtiment SARL',
  company_siret = '12345678900012',
  company_type = 'SARL',
  role = 'gerant',
  favorite = true,
  color = '#F59E0B',
  created_at = time::now();

-- Profil professionnel 2 (si Jean a plusieurs entreprises)
CREATE user_profiles SET
  profile_id = 'dupontconseil_sas',
  lyxal_id = 'jean_dupont_123abc',
  profile_type = 'business',
  profile_name = 'DupontConseil',
  namespace = 'profile_dupontconseil_sas',
  company_name = 'DupontConseil SAS',
  company_siret = '98765432100019',
  company_type = 'SAS',
  role = 'associe',
  favorite = false,
  color = '#10B981',
  created_at = time::now();
```

### Namespaces par Profil

```sql
-- =====================================================
-- NAMESPACE : profile_jean_dupont_personal
-- =====================================================
USE NAMESPACE profile_jean_dupont_personal;
USE DATABASE main;

-- Modules (structure identique pour tous les profils)
DEFINE TABLE crm_contacts SCHEMAFULL;
DEFINE TABLE tresorerie_comptes SCHEMAFULL;
DEFINE TABLE projets SCHEMAFULL;
DEFINE TABLE documents SCHEMAFULL;
DEFINE TABLE tresorerie_transactions SCHEMAFULL;

-- Données personnelles de Jean
CREATE crm_contacts SET
  name = 'Marie Dupont',
  type = 'famille',
  phone = '+33 6 12 34 56 78';

CREATE tresorerie_comptes SET
  name = 'Compte Courant Perso',
  bank = 'BNP Paribas',
  iban = 'FR76...',
  solde = 3500;

CREATE projets SET
  name = 'Rénovation cuisine',
  type = 'maison',
  budget = 8000,
  spent = 3600,
  progress = 45;

-- =====================================================
-- NAMESPACE : profile_martin_batiment_sarl
-- =====================================================
USE NAMESPACE profile_martin_batiment_sarl;
USE DATABASE main;

-- MÊMES tables (structure identique)
DEFINE TABLE crm_contacts SCHEMAFULL;
DEFINE TABLE tresorerie_comptes SCHEMAFULL;
DEFINE TABLE projets SCHEMAFULL;
DEFINE TABLE ventes_devis SCHEMAFULL;
DEFINE TABLE ventes_factures SCHEMAFULL;
DEFINE TABLE rh_employes SCHEMAFULL;
DEFINE TABLE documents SCHEMAFULL;

-- Données entreprise
CREATE crm_contacts SET
  name = 'Société ABC',
  type = 'client',
  siret = '12345678900012',
  phone = '+33 1 23 45 67 89';

CREATE tresorerie_comptes SET
  name = 'Compte Pro SARL',
  bank = 'BNP Paribas Pro',
  iban = 'FR76...',
  solde = 45000;

CREATE projets SET
  name = 'Villa Dupont',
  type = 'chantier',
  client = 'M. Dupont',
  budget = 180000,
  spent = 144000,
  progress = 80;

CREATE rh_employes SET
  name = 'Marc Martin',
  poste = 'Maçon',
  salaire = 2500,
  date_embauche = '2022-03-15';
```

---

## 💻 Code - Switch de Profils

### Hook React

```typescript
// =====================================================
// HOOK : useProfileSwitch
// =====================================================

interface Profile {
  profile_id: string;
  lyxal_id: string;
  profile_type: 'personal' | 'business';
  profile_name: string;
  namespace: string;
  company_name?: string;
  role?: string;
  avatar?: string;
  color?: string;
  favorite: boolean;
}

export const useProfileSwitch = () => {
  const { user } = useLyxalAuth();
  const [currentProfile, setCurrentProfile] = useState<Profile | null>(null);
  const [availableProfiles, setAvailableProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(false);
  
  // Chargement des profils
  useEffect(() => {
    loadProfiles();
  }, [user]);
  
  const loadProfiles = async () => {
    const profiles = await surrealClient.query(`
      SELECT * FROM user_profiles
      WHERE lyxal_id = $lyxal_id
      ORDER BY favorite DESC, last_accessed DESC
    `, { lyxal_id: user.lyxal_id });
    
    setAvailableProfiles(profiles[0]);
    
    // Profil par défaut
    const lastProfileId = localStorage.getItem('last_profile_id');
    const defaultProfile = lastProfileId
      ? profiles[0].find(p => p.profile_id === lastProfileId)
      : profiles[0][0];
    
    if (defaultProfile) {
      await switchProfile(defaultProfile.profile_id, false);
    }
  };
  
  // Switch de profil
  const switchProfile = async (profileId: string, updateLastAccessed = true) => {
    const newProfile = availableProfiles.find(p => p.profile_id === profileId);
    if (!newProfile) return;
    
    setLoading(true);
    
    try {
      // 1. Mise à jour état local
      setCurrentProfile(newProfile);
      
      // 2. Sauvegarde préférence
      localStorage.setItem('last_profile_id', profileId);
      
      // 3. Switch namespace SurrealDB
      await surrealClient.use({
        namespace: newProfile.namespace,
        database: 'main'
      });
      
      // 4. Mise à jour last_accessed
      if (updateLastAccessed) {
        await surrealClient.query(`
          UPDATE user_profiles SET
            last_accessed = time::now()
          WHERE profile_id = $profile_id
        `, { profile_id: profileId });
      }
      
      // 5. Event pour modules
      window.dispatchEvent(new CustomEvent('profile-changed', {
        detail: { profile: newProfile }
      }));
      
    } finally {
      setLoading(false);
    }
  };
  
  return {
    currentProfile,
    availableProfiles,
    switchProfile,
    loading,
    isPersonal: currentProfile?.profile_type === 'personal',
    isBusiness: currentProfile?.profile_type === 'business'
  };
};
```

### Composant Sélecteur

```typescript
// =====================================================
// COMPOSANT : ProfileSelector
// =====================================================

const ProfileSelector: React.FC = () => {
  const { 
    currentProfile, 
    availableProfiles, 
    switchProfile,
    loading 
  } = useProfileSwitch();
  
  const [isOpen, setIsOpen] = useState(false);
  
  const personalProfiles = availableProfiles.filter(
    p => p.profile_type === 'personal'
  );
  
  const businessProfiles = availableProfiles.filter(
    p => p.profile_type === 'business'
  );
  
  return (
    <div className="profile-selector">
      {/* Bouton profil actuel */}
      <button
        className="current-profile"
        onClick={() => setIsOpen(!isOpen)}
        disabled={loading}
      >
        <div className="profile-avatar">
          {currentProfile?.profile_type === 'personal' ? '👤' : '💼'}
        </div>
        <div className="profile-info">
          <span className="profile-name">{currentProfile?.profile_name}</span>
          {currentProfile?.company_name && (
            <span className="company-name">{currentProfile.company_name}</span>
          )}
        </div>
        <ChevronDown />
      </button>
      
      {/* Dropdown */}
      {isOpen && (
        <div className="profile-dropdown">
          {/* Section Personnel */}
          <div className="section">
            <h3>👤 Profils Personnels</h3>
            {personalProfiles.map(profile => (
              <ProfileItem
                key={profile.profile_id}
                profile={profile}
                isActive={profile.profile_id === currentProfile?.profile_id}
                onClick={() => {
                  switchProfile(profile.profile_id);
                  setIsOpen(false);
                }}
              />
            ))}
            <button className="create-profile">
              ➕ Créer un profil personnel
            </button>
          </div>
          
          {/* Section Professionnel */}
          <div className="section">
            <h3>💼 Profils Professionnels</h3>
            {businessProfiles.map(profile => (
              <ProfileItem
                key={profile.profile_id}
                profile={profile}
                isActive={profile.profile_id === currentProfile?.profile_id}
                onClick={() => {
                  switchProfile(profile.profile_id);
                  setIsOpen(false);
                }}
              />
            ))}
            <button className="create-profile">
              ➕ Créer une entreprise
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

// Item de profil
const ProfileItem: React.FC<{
  profile: Profile;
  isActive: boolean;
  onClick: () => void;
}> = ({ profile, isActive, onClick }) => {
  return (
    <div
      className={`profile-item ${isActive ? 'active' : ''}`}
      onClick={onClick}
      style={{ borderLeft: `3px solid ${profile.color}` }}
    >
      <div className="profile-avatar">
        {profile.profile_type === 'personal' ? '👤' : '💼'}
      </div>
      <div className="profile-details">
        <div className="profile-name">{profile.profile_name}</div>
        {profile.company_name && (
          <div className="company-info">
            <span className="company-name">{profile.company_name}</span>
            {profile.role && <span className="role">({profile.role})</span>}
          </div>
        )}
      </div>
      {profile.favorite && <StarIcon />}
      {isActive && <CheckIcon />}
    </div>
  );
};
```

---

## 🎯 Cas d'Usage Réels

### 1. Freelance Multi-Entreprises

```
JULIE MARTIN (Freelance Consultante)

👤 Profil Personnel
├─ Gestion finances personnelles
├─ Budget familial
└─ Projets maison

💼 Julie Martin Conseil (Freelance)
├─ Missions clients
├─ Facturation
├─ Trésorerie freelance
└─ Temps passé

💼 StartupX SAS (Associée 20%)
├─ Suivi investissement
├─ Accès comptabilité
└─ Réunions actionnaires

💼 AgenceY (Consultante externe)
├─ Projets clients AgenceY
├─ Timesheet
└─ Reporting

✨ Julie switch 10-15 fois par jour entre ses profils
✨ Chaque profil = Données isolées
✨ Facturation par profil professionnel
```

### 2. Chef d'Entreprise

```
PIERRE DUPONT (Chef d'entreprise bâtiment + Investisseur)

👤 Profil Personnel
├─ Budget familial (6 000€/mois)
├─ Projet rénovation maison
└─ Investissements immobiliers perso

💼 Dupont Bâtiment SARL (Gérant)
├─ 12 chantiers en cours
├─ 5 employés
├─ Trésorerie : 45 000€
├─ CA : 800K€/an
└─ Facturation clients

💼 Immo Invest SCI (Associé)
├─ 3 immeubles locatifs
├─ Locataires
├─ Loyers
└─ Charges

✨ Pierre utilise principalement profil pro le jour
✨ Profil perso le soir et weekend
```

### 3. Multi-Activités

```
MARIE LEBLANC (Prof + Auto-entrepreneur + Association)

👤 Profil Personnel
├─ Budget mensuel
├─ Courses
└─ Vacances

💼 Marie Leblanc AE (Auto-entrepreneur)
├─ Cours particuliers
├─ Factures élèves
└─ Déclaration URSSAF

💼 Association "Les Étoiles" (Trésorière)
├─ Comptabilité association
├─ Adhérents
└─ Événements

✨ Marie switch selon l'activité du moment
```

---

## 📊 Comparaisons

### Google

```
GOOGLE
├─ Compte Personnel (jean@gmail.com)
│  └─ Gmail, Drive, Photos perso
│
└─ Google Workspace (jean@entreprise.com)
   └─ Gmail pro, Drive pro, Calendar pro

✅ Switch entre comptes
✅ Données isolées
✅ MÊME interface Gmail/Drive

LYXAL = Identique !
├─ 👤 Profil Personnel
└─ 💼 Profil(s) Professionnel(s)
```

### Notion

```
NOTION
├─ Workspace Personnel
│  └─ Notes perso, projets perso
│
└─ Workspace Entreprise
   └─ Docs entreprise, projets pro

✅ Switch entre workspaces
✅ Données isolées

LYXAL = Identique !
```

### Slack

```
SLACK
├─ Espace Personnel
└─ Espaces Professionnels (plusieurs entreprises)

✅ Switch entre espaces
✅ Notifications séparées

LYXAL = Identique !
```

---

## 💰 Modèle de Facturation

### Facturation par Profil Professionnel

```
JEAN DUPONT (Utilisateur)
├─ 👤 Profil Personnel : GRATUIT
│
├─ 💼 Martin Bâtiment SARL : 49€/mois
│  └─ Plan "Entreprise" (jusqu'à 10 employés)
│
└─ 💼 DupontConseil SAS : 29€/mois
   └─ Plan "Freelance" (sans employés)

TOTAL FACTURE : 78€/mois
```

**Avantages** :
- Profil personnel gratuit (usage privé)
- Facturation par entreprise (juste)
- Pas de limite de profils personnels
- Tarif dégressif si plusieurs entreprises

---

## ✅ Récapitulatif

### Un Seul Template, Plusieurs Profils

```
TEMPLATE LYXAL (Unique)
    ↓
Un utilisateur = Plusieurs profils
    ├─ 1 profil personnel (gratuit)
    └─ N profils professionnels (payants)
        ↓
Switch instantané (<50ms)
    ↓
Données isolées par profil
    ↓
Mêmes modules, contextes différents
```

### Performance

- Switch de profil : **<50ms**
- Rechargement données : **<200ms**
- Perception : **INSTANTANÉ** ✨

### Isolation

- Namespace dédié par profil
- Aucun accès cross-profil
- Sécurité maximale

---

**Version** : 1.0  
**Créé le** : 2024-01-20  
**Statut** : ✅ Modèle Profils Personnel/Professionnel documenté

**Référence** : Voir `INTEGRATION_LYXAL_IDENTITY_COMPLETE.md` (v1.4) pour l'architecture complète

