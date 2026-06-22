# Lyxal Crates Socket

**Lyxal Crates Socket** est un moteur réseau de bas niveau optimisé, basé sur le standard industriel `socket2`, mais durci et spécialisé pour la **Solution Lyxal**.

Ce crate fournit un contrôle total sur la création et la configuration des sockets (options avancées non disponibles dans `std::net`) tout en garantissant une sécurité accrue et une robustesse adaptée aux environnements de production (Windows, Linux, Apple, Android).

## 🚀 Pourquoi utiliser `lyxal_crates_socket` au lieu de `socket2` ?

Bien que basé sur `socket2`, ce crate a été audité et amélioré avec des fonctionnalités exclusives à la solution Lyxal :

### 1. Durcissement de la Sécurité (Hardening)
- **Windows Safe Defaults** : Contrairement au standard, ce crate force l'activation du flag `WSA_FLAG_NO_HANDLE_INHERIT` par défaut. Cela empêche les fuites de descripteurs (handles) vers les processus enfants, une sécurité critique pour les services Windows.
- **Pointeurs Sécurisés** : Correction des risques d'Undefined Behavior (UB) sur les appels système Windows (`WSASend`, `WSASendTo`) via des casts de pointeurs explicites et vérifiés.

### 2. Robustesse et Fiabilité
- **Gestion Automatique du Retry (EINTR)** : Inclusion de méthodes `_with_retry` (`recv_with_retry`, `send_with_retry`). Ces méthodes gèrent automatiquement les interruptions système fréquentes sur les plateformes mobiles (**Android**, **iOS**) et lors des changements d'état réseau, évitant ainsi des plantages ou des déconnexions inattendues.

### 3. Diagnostics et Monitoring
- **Introspection Avancée** : Accès simplifié aux diagnostics réseau via des méthodes comme `send_buffer_size()`, `recv_buffer_size()` et `get_type()`.
- **Visibilité Lyxal** : Permet au backend Lyxal de monitorer l'état réel des buffers de l'OS pour optimiser la latence.

## 📱 Support Multi-Plateforme

Le support multi-OS est intégralement préservé et testé pour :

| Plateforme | Statut | Particularités Lyxal |
| :--- | :--- | :--- |
| **Windows** | Tier 1 | Sécurité renforcée (Anti-héritage), UB Fixed. |
| **Linux** | Tier 1 | Haute performance, support complet des options TCP/UDP. |
| **macOS / iOS** | Tier 1/2 | Gestion du Retry optimisée pour la mobilité Apple. |
| **Android** | Tier 2 | Résilience accrue face aux interruptions système. |
| **BSD / Others** | Tier 2 | Compatibilité POSIX standard maintenue. |

## 🛠 Utilisation

L'API reste compatible avec l'écosystème Rust standard, permettant une migration facile depuis `std::net` ou `socket2`.

### Exemple : Création d'un socket avec Retry
```rust
use lyxal_crates_socket::{Socket, Domain, Type};
use std::net::SocketAddr;

fn main() -> std::io::Result<()> {
    let socket = Socket::new(Domain::IPV4, Type::STREAM, None)?;
    
    // Utilisation de la méthode de lecture sécurisée Lyxal
    let mut buf = [std::mem::MaybeUninit::uninit(); 1024];
    let n = socket.recv_with_retry(&mut buf)?; 
    
    Ok(())
}
```

## ⚖️ Licence

Ce projet est un fork de `socket2` (Apache-2.0/MIT) et conserve les mêmes droits de licence, tout en étant maintenu spécifiquement pour l'infrastructure Lyxal.
