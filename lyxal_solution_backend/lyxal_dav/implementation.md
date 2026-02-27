# Plan d'Implémentation Granulaire Lyxal DAV

Ce document répertorie fichier par fichier (ou dossier par dossier) les composants à conserver ou à isoler.

## 📂 Analyse Granulaire des Dossiers

### 1. Crate: `jmap-proto` (Objets)
| Fichier | Type | Statut |
| :--- | :--- | :--- |
| `object/calendar.rs` | DAV | ✅ Garder |
| `object/calendar_event.rs` | DAV | ✅ Garder |
| `object/contact.rs` | DAV | ✅ Garder |
| `object/addressbook.rs` | DAV | ✅ Garder |
| `object/principal.rs` | Identité | ✅ Garder |
| `object/email.rs` | Email | ❌ Isoler |
| `object/mailbox.rs` | Email | ❌ Isoler |
| `object/thread.rs` | Email | ❌ Isoler |
| `object/sieve.rs` | Email | ❌ Isoler |
| `object/vacation_response.rs` | Email | ❌ Isoler |

### 2. Crate: `directory` (Backends)
| Dossier | Type | Statut |
| :--- | :--- | :--- |
| `backend/internal`, `sql`, `ldap`, `oidc`, `memory` | Générique | ✅ Garder (Identity) |
| `backend/smtp` | Email | ❌ Isoler |
| `backend/imap` | Email | ❌ Isoler |

### 3. Crate: `common` (Dossier critique)
| Sous-dossier / Fichier | Contenu | Statut |
| :--- | :--- | :--- |
| `scripts/` | Moteur Sieve complet | ❌ Isoler |
| `config/smtp/` | Config transport mail | ❌ Isoler |
| `config/imap.rs` | Config IMAP | ❌ Isoler |
| `config/spamfilter.rs` | Anti-spam | ❌ Isoler |
| `auth/` | AccessTokens & OAuth | ✅ Garder |
| `storage/` | Blobs & States | 🟡 Garder (À adapter Surreal) |
| `sharing/` | ACLs & Permissions | ✅ Garder |
| `expr/functions/email.rs` | Fonctions calcul email | ❌ Isoler |

### 4. Crates Purement Email
| Crate | Raison | Statut |
| :--- | :--- | :--- |
| `imap-proto` | Protocole IMAP complet | ❌ Isoler |

---
*Mise à jour suite à l'analyse systématique fichier par fichier.*
