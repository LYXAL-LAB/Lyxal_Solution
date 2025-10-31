-- =============================================================================================
-- |
-- | Fichier : auth_type_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > auth_type
-- | Description : Traductions multilingues pour auth_type.
-- |
-- | Ce fichier contient toutes les traductions pour 5 langues :
-- | • FR (Français)
-- | • EN (English)
-- | • IT (Italiano)
-- | • DE (Deutsch)
-- | • ES (Español)
-- |
-- | Total : 375 traductions (75 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- OAUTH2 - Name, Description, Tooltip
-- =====================================================

RELATE i18n_key:auth_type_oauth2_name->translation->language:fr SET text = "OAuth 2.0";
RELATE i18n_key:auth_type_oauth2_name->translation->language:en SET text = "OAuth 2.0";
RELATE i18n_key:auth_type_oauth2_name->translation->language:it SET text = "OAuth 2.0";
RELATE i18n_key:auth_type_oauth2_name->translation->language:de SET text = "OAuth 2.0";
RELATE i18n_key:auth_type_oauth2_name->translation->language:es SET text = "OAuth 2.0";

RELATE i18n_key:auth_type_oauth2_description->translation->language:fr SET text = "Protocole d'autorisation moderne permettant aux applications d'accéder aux ressources d'un utilisateur sans exposer ses credentials. Supporte refresh tokens et multiple grant types.";
RELATE i18n_key:auth_type_oauth2_description->translation->language:en SET text = "Modern authorization protocol allowing applications to access user resources without exposing credentials. Supports refresh tokens and multiple grant types.";
RELATE i18n_key:auth_type_oauth2_description->translation->language:it SET text = "Protocollo di autorizzazione moderno che consente alle applicazioni di accedere alle risorse dell'utente senza esporre le credenziali. Supporta refresh token e diversi grant types.";
RELATE i18n_key:auth_type_oauth2_description->translation->language:de SET text = "Modernes Autorisierungsprotokoll, das Anwendungen den Zugriff auf Benutzerressourcen ermöglicht, ohne Anmeldeinformationen preiszugeben. Unterstützt Refresh-Tokens und mehrere Grant-Typen.";
RELATE i18n_key:auth_type_oauth2_description->translation->language:es SET text = "Protocolo de autorización moderno que permite a las aplicaciones acceder a los recursos del usuario sin exponer credenciales. Soporta refresh tokens y múltiples grant types.";

RELATE i18n_key:auth_type_oauth2_tooltip->translation->language:fr SET text = "✅ Recommandé : Standard de l'industrie pour authentification sécurisée";
RELATE i18n_key:auth_type_oauth2_tooltip->translation->language:en SET text = "✅ Recommended: Industry standard for secure authentication";
RELATE i18n_key:auth_type_oauth2_tooltip->translation->language:it SET text = "✅ Consigliato: Standard industriale per autenticazione sicura";
RELATE i18n_key:auth_type_oauth2_tooltip->translation->language:de SET text = "✅ Empfohlen: Industriestandard für sichere Authentifizierung";
RELATE i18n_key:auth_type_oauth2_tooltip->translation->language:es SET text = "✅ Recomendado: Estándar de la industria para autenticación segura";

-- OAUTH2 - Use Cases
RELATE i18n_key:auth_type_oauth2_usecase_user_auth->translation->language:fr SET text = "Authentification utilisateur (login social)";
RELATE i18n_key:auth_type_oauth2_usecase_user_auth->translation->language:en SET text = "User authentication (social login)";
RELATE i18n_key:auth_type_oauth2_usecase_user_auth->translation->language:it SET text = "Autenticazione utente (login sociale)";
RELATE i18n_key:auth_type_oauth2_usecase_user_auth->translation->language:de SET text = "Benutzerauthentifizierung (Social Login)";
RELATE i18n_key:auth_type_oauth2_usecase_user_auth->translation->language:es SET text = "Autenticación de usuario (login social)";

RELATE i18n_key:auth_type_oauth2_usecase_third_party->translation->language:fr SET text = "Intégrations tierces (Google, Facebook, GitHub)";
RELATE i18n_key:auth_type_oauth2_usecase_third_party->translation->language:en SET text = "Third-party integrations (Google, Facebook, GitHub)";
RELATE i18n_key:auth_type_oauth2_usecase_third_party->translation->language:it SET text = "Integrazioni di terze parti (Google, Facebook, GitHub)";
RELATE i18n_key:auth_type_oauth2_usecase_third_party->translation->language:de SET text = "Drittanbieter-Integrationen (Google, Facebook, GitHub)";
RELATE i18n_key:auth_type_oauth2_usecase_third_party->translation->language:es SET text = "Integraciones de terceros (Google, Facebook, GitHub)";

-- OAUTH2 - Advantages
RELATE i18n_key:auth_type_oauth2_advantage_secure->translation->language:fr SET text = "Très sécurisé avec tokens d'accès et refresh tokens";
RELATE i18n_key:auth_type_oauth2_advantage_secure->translation->language:en SET text = "Highly secure with access tokens and refresh tokens";
RELATE i18n_key:auth_type_oauth2_advantage_secure->translation->language:it SET text = "Altamente sicuro con token di accesso e refresh token";
RELATE i18n_key:auth_type_oauth2_advantage_secure->translation->language:de SET text = "Hochsicher mit Zugriffs-Tokens und Refresh-Tokens";
RELATE i18n_key:auth_type_oauth2_advantage_secure->translation->language:es SET text = "Muy seguro con tokens de acceso y refresh tokens";

RELATE i18n_key:auth_type_oauth2_advantage_standard->translation->language:fr SET text = "Standard de l'industrie largement adopté";
RELATE i18n_key:auth_type_oauth2_advantage_standard->translation->language:en SET text = "Widely adopted industry standard";
RELATE i18n_key:auth_type_oauth2_advantage_standard->translation->language:it SET text = "Standard industriale ampiamente adottato";
RELATE i18n_key:auth_type_oauth2_advantage_standard->translation->language:de SET text = "Weit verbreiteter Industriestandard";
RELATE i18n_key:auth_type_oauth2_advantage_standard->translation->language:es SET text = "Estándar de la industria ampliamente adoptado";

-- OAUTH2 - Disadvantages
RELATE i18n_key:auth_type_oauth2_disadvantage_complex->translation->language:fr SET text = "Configuration et implémentation complexes";
RELATE i18n_key:auth_type_oauth2_disadvantage_complex->translation->language:en SET text = "Complex configuration and implementation";
RELATE i18n_key:auth_type_oauth2_disadvantage_complex->translation->language:it SET text = "Configurazione e implementazione complesse";
RELATE i18n_key:auth_type_oauth2_disadvantage_complex->translation->language:de SET text = "Komplexe Konfiguration und Implementierung";
RELATE i18n_key:auth_type_oauth2_disadvantage_complex->translation->language:es SET text = "Configuración e implementación complejas";

RELATE i18n_key:auth_type_oauth2_disadvantage_implementation->translation->language:fr SET text = "Courbe d'apprentissage élevée pour débutants";
RELATE i18n_key:auth_type_oauth2_disadvantage_implementation->translation->language:en SET text = "Steep learning curve for beginners";
RELATE i18n_key:auth_type_oauth2_disadvantage_implementation->translation->language:it SET text = "Curva di apprendimento ripida per principianti";
RELATE i18n_key:auth_type_oauth2_disadvantage_implementation->translation->language:de SET text = "Steile Lernkurve für Anfänger";
RELATE i18n_key:auth_type_oauth2_disadvantage_implementation->translation->language:es SET text = "Curva de aprendizaje pronunciada para principiantes";

-- =====================================================
-- OAUTH1 - Name, Description, Tooltip
-- =====================================================

RELATE i18n_key:auth_type_oauth1_name->translation->language:fr SET text = "OAuth 1.0a";
RELATE i18n_key:auth_type_oauth1_name->translation->language:en SET text = "OAuth 1.0a";
RELATE i18n_key:auth_type_oauth1_name->translation->language:it SET text = "OAuth 1.0a";
RELATE i18n_key:auth_type_oauth1_name->translation->language:de SET text = "OAuth 1.0a";
RELATE i18n_key:auth_type_oauth1_name->translation->language:es SET text = "OAuth 1.0a";

RELATE i18n_key:auth_type_oauth1_description->translation->language:fr SET text = "Ancienne version d'OAuth utilisant des signatures cryptographiques. Majoritairement remplacé par OAuth 2.0, mais encore utilisé par certaines APIs legacy.";
RELATE i18n_key:auth_type_oauth1_description->translation->language:en SET text = "Older version of OAuth using cryptographic signatures. Mostly replaced by OAuth 2.0, but still used by some legacy APIs.";
RELATE i18n_key:auth_type_oauth1_description->translation->language:it SET text = "Vecchia versione di OAuth che utilizza firme crittografiche. Sostituita principalmente da OAuth 2.0, ma ancora utilizzata da alcune API legacy.";
RELATE i18n_key:auth_type_oauth1_description->translation->language:de SET text = "Ältere Version von OAuth mit kryptografischen Signaturen. Größtenteils durch OAuth 2.0 ersetzt, aber noch von einigen Legacy-APIs verwendet.";
RELATE i18n_key:auth_type_oauth1_description->translation->language:es SET text = "Versión antigua de OAuth que utiliza firmas criptográficas. Mayormente reemplazado por OAuth 2.0, pero aún utilizado por algunas APIs legacy.";

RELATE i18n_key:auth_type_oauth1_tooltip->translation->language:fr SET text = "⚠️ Legacy : Préférer OAuth 2.0 pour nouveaux projets";
RELATE i18n_key:auth_type_oauth1_tooltip->translation->language:en SET text = "⚠️ Legacy: Prefer OAuth 2.0 for new projects";
RELATE i18n_key:auth_type_oauth1_tooltip->translation->language:it SET text = "⚠️ Legacy: Preferire OAuth 2.0 per nuovi progetti";
RELATE i18n_key:auth_type_oauth1_tooltip->translation->language:de SET text = "⚠️ Legacy: OAuth 2.0 für neue Projekte bevorzugen";
RELATE i18n_key:auth_type_oauth1_tooltip->translation->language:es SET text = "⚠️ Legacy: Preferir OAuth 2.0 para nuevos proyectos";

-- OAUTH1 - Use Cases
RELATE i18n_key:auth_type_oauth1_usecase_legacy->translation->language:fr SET text = "APIs legacy (Twitter v1.1, Trello)";
RELATE i18n_key:auth_type_oauth1_usecase_legacy->translation->language:en SET text = "Legacy APIs (Twitter v1.1, Trello)";
RELATE i18n_key:auth_type_oauth1_usecase_legacy->translation->language:it SET text = "API legacy (Twitter v1.1, Trello)";
RELATE i18n_key:auth_type_oauth1_usecase_legacy->translation->language:de SET text = "Legacy-APIs (Twitter v1.1, Trello)";
RELATE i18n_key:auth_type_oauth1_usecase_legacy->translation->language:es SET text = "APIs legacy (Twitter v1.1, Trello)";

RELATE i18n_key:auth_type_oauth1_usecase_signature->translation->language:fr SET text = "Systèmes nécessitant signatures cryptographiques";
RELATE i18n_key:auth_type_oauth1_usecase_signature->translation->language:en SET text = "Systems requiring cryptographic signatures";
RELATE i18n_key:auth_type_oauth1_usecase_signature->translation->language:it SET text = "Sistemi che richiedono firme crittografiche";
RELATE i18n_key:auth_type_oauth1_usecase_signature->translation->language:de SET text = "Systeme, die kryptografische Signaturen erfordern";
RELATE i18n_key:auth_type_oauth1_usecase_signature->translation->language:es SET text = "Sistemas que requieren firmas criptográficas";

-- OAUTH1 - Advantages
RELATE i18n_key:auth_type_oauth1_advantage_secure->translation->language:fr SET text = "Signature cryptographique robuste";
RELATE i18n_key:auth_type_oauth1_advantage_secure->translation->language:en SET text = "Strong cryptographic signature";
RELATE i18n_key:auth_type_oauth1_advantage_secure->translation->language:it SET text = "Firma crittografica robusta";
RELATE i18n_key:auth_type_oauth1_advantage_secure->translation->language:de SET text = "Starke kryptografische Signatur";
RELATE i18n_key:auth_type_oauth1_advantage_secure->translation->language:es SET text = "Firma criptográfica robusta";

-- OAUTH1 - Disadvantages
RELATE i18n_key:auth_type_oauth1_disadvantage_complex->translation->language:fr SET text = "Très complexe à implémenter correctement";
RELATE i18n_key:auth_type_oauth1_disadvantage_complex->translation->language:en SET text = "Very complex to implement correctly";
RELATE i18n_key:auth_type_oauth1_disadvantage_complex->translation->language:it SET text = "Molto complesso da implementare correttamente";
RELATE i18n_key:auth_type_oauth1_disadvantage_complex->translation->language:de SET text = "Sehr komplex korrekt zu implementieren";
RELATE i18n_key:auth_type_oauth1_disadvantage_complex->translation->language:es SET text = "Muy complejo de implementar correctamente";

RELATE i18n_key:auth_type_oauth1_disadvantage_deprecated->translation->language:fr SET text = "Déprécié en faveur d'OAuth 2.0";
RELATE i18n_key:auth_type_oauth1_disadvantage_deprecated->translation->language:en SET text = "Deprecated in favor of OAuth 2.0";
RELATE i18n_key:auth_type_oauth1_disadvantage_deprecated->translation->language:it SET text = "Deprecato a favore di OAuth 2.0";
RELATE i18n_key:auth_type_oauth1_disadvantage_deprecated->translation->language:de SET text = "Zugunsten von OAuth 2.0 veraltet";
RELATE i18n_key:auth_type_oauth1_disadvantage_deprecated->translation->language:es SET text = "Deprecado en favor de OAuth 2.0";

-- =====================================================
-- API_KEY - Name, Description, Tooltip
-- =====================================================

RELATE i18n_key:auth_type_api_key_name->translation->language:fr SET text = "Clé API";
RELATE i18n_key:auth_type_api_key_name->translation->language:en SET text = "API Key";
RELATE i18n_key:auth_type_api_key_name->translation->language:it SET text = "Chiave API";
RELATE i18n_key:auth_type_api_key_name->translation->language:de SET text = "API-Schlüssel";
RELATE i18n_key:auth_type_api_key_name->translation->language:es SET text = "Clave API";

RELATE i18n_key:auth_type_api_key_description->translation->language:fr SET text = "Authentification simple via une clé secrète générée. Populaire pour les APIs publiques et l'automation. Facile à implémenter mais nécessite une rotation régulière.";
RELATE i18n_key:auth_type_api_key_description->translation->language:en SET text = "Simple authentication via a generated secret key. Popular for public APIs and automation. Easy to implement but requires regular rotation.";
RELATE i18n_key:auth_type_api_key_description->translation->language:it SET text = "Autenticazione semplice tramite una chiave segreta generata. Popolare per API pubbliche e automazione. Facile da implementare ma richiede rotazione regolare.";
RELATE i18n_key:auth_type_api_key_description->translation->language:de SET text = "Einfache Authentifizierung über einen generierten geheimen Schlüssel. Beliebt für öffentliche APIs und Automatisierung. Einfach zu implementieren, erfordert jedoch regelmäßige Rotation.";
RELATE i18n_key:auth_type_api_key_description->translation->language:es SET text = "Autenticación simple mediante una clave secreta generada. Popular para APIs públicas y automatización. Fácil de implementar pero requiere rotación regular.";

RELATE i18n_key:auth_type_api_key_tooltip->translation->language:fr SET text = "Simple et populaire pour APIs et scripts";
RELATE i18n_key:auth_type_api_key_tooltip->translation->language:en SET text = "Simple and popular for APIs and scripts";
RELATE i18n_key:auth_type_api_key_tooltip->translation->language:it SET text = "Semplice e popolare per API e script";
RELATE i18n_key:auth_type_api_key_tooltip->translation->language:de SET text = "Einfach und beliebt für APIs und Skripte";
RELATE i18n_key:auth_type_api_key_tooltip->translation->language:es SET text = "Simple y popular para APIs y scripts";

-- API_KEY - Use Cases
RELATE i18n_key:auth_type_api_key_usecase_simple->translation->language:fr SET text = "APIs simples (météo, géolocalisation, etc.)";
RELATE i18n_key:auth_type_api_key_usecase_simple->translation->language:en SET text = "Simple APIs (weather, geolocation, etc.)";
RELATE i18n_key:auth_type_api_key_usecase_simple->translation->language:it SET text = "API semplici (meteo, geolocalizzazione, ecc.)";
RELATE i18n_key:auth_type_api_key_usecase_simple->translation->language:de SET text = "Einfache APIs (Wetter, Geolokalisierung usw.)";
RELATE i18n_key:auth_type_api_key_usecase_simple->translation->language:es SET text = "APIs simples (clima, geolocalización, etc.)";

RELATE i18n_key:auth_type_api_key_usecase_automation->translation->language:fr SET text = "Scripts d'automation et CI/CD";
RELATE i18n_key:auth_type_api_key_usecase_automation->translation->language:en SET text = "Automation scripts and CI/CD";
RELATE i18n_key:auth_type_api_key_usecase_automation->translation->language:it SET text = "Script di automazione e CI/CD";
RELATE i18n_key:auth_type_api_key_usecase_automation->translation->language:de SET text = "Automatisierungsskripte und CI/CD";
RELATE i18n_key:auth_type_api_key_usecase_automation->translation->language:es SET text = "Scripts de automatización y CI/CD";

-- API_KEY - Advantages
RELATE i18n_key:auth_type_api_key_advantage_simple->translation->language:fr SET text = "Très simple à implémenter et utiliser";
RELATE i18n_key:auth_type_api_key_advantage_simple->translation->language:en SET text = "Very simple to implement and use";
RELATE i18n_key:auth_type_api_key_advantage_simple->translation->language:it SET text = "Molto semplice da implementare e utilizzare";
RELATE i18n_key:auth_type_api_key_advantage_simple->translation->language:de SET text = "Sehr einfach zu implementieren und zu verwenden";
RELATE i18n_key:auth_type_api_key_advantage_simple->translation->language:es SET text = "Muy simple de implementar y usar";

RELATE i18n_key:auth_type_api_key_advantage_popular->translation->language:fr SET text = "Très populaire et bien supporté";
RELATE i18n_key:auth_type_api_key_advantage_popular->translation->language:en SET text = "Very popular and well supported";
RELATE i18n_key:auth_type_api_key_advantage_popular->translation->language:it SET text = "Molto popolare e ben supportato";
RELATE i18n_key:auth_type_api_key_advantage_popular->translation->language:de SET text = "Sehr beliebt und gut unterstützt";
RELATE i18n_key:auth_type_api_key_advantage_popular->translation->language:es SET text = "Muy popular y bien soportado";

-- API_KEY - Disadvantages
RELATE i18n_key:auth_type_api_key_disadvantage_security->translation->language:fr SET text = "Sécurité moyenne (pas d'expiration automatique)";
RELATE i18n_key:auth_type_api_key_disadvantage_security->translation->language:en SET text = "Medium security (no automatic expiration)";
RELATE i18n_key:auth_type_api_key_disadvantage_security->translation->language:it SET text = "Sicurezza media (nessuna scadenza automatica)";
RELATE i18n_key:auth_type_api_key_disadvantage_security->translation->language:de SET text = "Mittlere Sicherheit (kein automatischer Ablauf)";
RELATE i18n_key:auth_type_api_key_disadvantage_security->translation->language:es SET text = "Seguridad media (sin expiración automática)";

RELATE i18n_key:auth_type_api_key_disadvantage_rotation->translation->language:fr SET text = "Rotation manuelle des clés nécessaire";
RELATE i18n_key:auth_type_api_key_disadvantage_rotation->translation->language:en SET text = "Manual key rotation required";
RELATE i18n_key:auth_type_api_key_disadvantage_rotation->translation->language:it SET text = "Richiesta rotazione manuale delle chiavi";
RELATE i18n_key:auth_type_api_key_disadvantage_rotation->translation->language:de SET text = "Manuelle Schlüsselrotation erforderlich";
RELATE i18n_key:auth_type_api_key_disadvantage_rotation->translation->language:es SET text = "Rotación manual de claves requerida";

-- =====================================================
-- BASIC_AUTH - Name, Description, Tooltip
-- =====================================================

RELATE i18n_key:auth_type_basic_auth_name->translation->language:fr SET text = "Basic Auth";
RELATE i18n_key:auth_type_basic_auth_name->translation->language:en SET text = "Basic Auth";
RELATE i18n_key:auth_type_basic_auth_name->translation->language:it SET text = "Basic Auth";
RELATE i18n_key:auth_type_basic_auth_name->translation->language:de SET text = "Basic Auth";
RELATE i18n_key:auth_type_basic_auth_name->translation->language:es SET text = "Basic Auth";

RELATE i18n_key:auth_type_basic_auth_description->translation->language:fr SET text = "Méthode d'authentification HTTP la plus simple : username et password encodés en base64. ⚠️ HTTPS obligatoire car credentials facilement décodables.";
RELATE i18n_key:auth_type_basic_auth_description->translation->language:en SET text = "Simplest HTTP authentication method: username and password encoded in base64. ⚠️ HTTPS mandatory as credentials are easily decodable.";
RELATE i18n_key:auth_type_basic_auth_description->translation->language:it SET text = "Metodo di autenticazione HTTP più semplice: username e password codificati in base64. ⚠️ HTTPS obbligatorio poiché le credenziali sono facilmente decodificabili.";
RELATE i18n_key:auth_type_basic_auth_description->translation->language:de SET text = "Einfachste HTTP-Authentifizierungsmethode: Benutzername und Passwort in base64 kodiert. ⚠️ HTTPS zwingend, da Anmeldeinformationen leicht dekodierbar sind.";
RELATE i18n_key:auth_type_basic_auth_description->translation->language:es SET text = "Método de autenticación HTTP más simple: usuario y contraseña codificados en base64. ⚠️ HTTPS obligatorio ya que las credenciales son fácilmente decodificables.";

RELATE i18n_key:auth_type_basic_auth_tooltip->translation->language:fr SET text = "⚠️ Faible sécurité : HTTPS obligatoire";
RELATE i18n_key:auth_type_basic_auth_tooltip->translation->language:en SET text = "⚠️ Low security: HTTPS mandatory";
RELATE i18n_key:auth_type_basic_auth_tooltip->translation->language:it SET text = "⚠️ Bassa sicurezza: HTTPS obbligatorio";
RELATE i18n_key:auth_type_basic_auth_tooltip->translation->language:de SET text = "⚠️ Geringe Sicherheit: HTTPS zwingend";
RELATE i18n_key:auth_type_basic_auth_tooltip->translation->language:es SET text = "⚠️ Baja seguridad: HTTPS obligatorio";

-- BASIC_AUTH - Use Cases
RELATE i18n_key:auth_type_basic_auth_usecase_internal->translation->language:fr SET text = "APIs internes (intranet)";
RELATE i18n_key:auth_type_basic_auth_usecase_internal->translation->language:en SET text = "Internal APIs (intranet)";
RELATE i18n_key:auth_type_basic_auth_usecase_internal->translation->language:it SET text = "API interne (intranet)";
RELATE i18n_key:auth_type_basic_auth_usecase_internal->translation->language:de SET text = "Interne APIs (Intranet)";
RELATE i18n_key:auth_type_basic_auth_usecase_internal->translation->language:es SET text = "APIs internas (intranet)";

RELATE i18n_key:auth_type_basic_auth_usecase_dev->translation->language:fr SET text = "Environnements de développement";
RELATE i18n_key:auth_type_basic_auth_usecase_dev->translation->language:en SET text = "Development environments";
RELATE i18n_key:auth_type_basic_auth_usecase_dev->translation->language:it SET text = "Ambienti di sviluppo";
RELATE i18n_key:auth_type_basic_auth_usecase_dev->translation->language:de SET text = "Entwicklungsumgebungen";
RELATE i18n_key:auth_type_basic_auth_usecase_dev->translation->language:es SET text = "Entornos de desarrollo";

-- BASIC_AUTH - Advantages
RELATE i18n_key:auth_type_basic_auth_advantage_simple->translation->language:fr SET text = "Extrêmement simple à implémenter";
RELATE i18n_key:auth_type_basic_auth_advantage_simple->translation->language:en SET text = "Extremely simple to implement";
RELATE i18n_key:auth_type_basic_auth_advantage_simple->translation->language:it SET text = "Estremamente semplice da implementare";
RELATE i18n_key:auth_type_basic_auth_advantage_simple->translation->language:de SET text = "Extrem einfach zu implementieren";
RELATE i18n_key:auth_type_basic_auth_advantage_simple->translation->language:es SET text = "Extremadamente simple de implementar";

-- BASIC_AUTH - Disadvantages
RELATE i18n_key:auth_type_basic_auth_disadvantage_security->translation->language:fr SET text = "Faible sécurité (base64 facilement décodable)";
RELATE i18n_key:auth_type_basic_auth_disadvantage_security->translation->language:en SET text = "Low security (base64 easily decodable)";
RELATE i18n_key:auth_type_basic_auth_disadvantage_security->translation->language:it SET text = "Bassa sicurezza (base64 facilmente decodificabile)";
RELATE i18n_key:auth_type_basic_auth_disadvantage_security->translation->language:de SET text = "Geringe Sicherheit (base64 leicht dekodierbar)";
RELATE i18n_key:auth_type_basic_auth_disadvantage_security->translation->language:es SET text = "Baja seguridad (base64 fácilmente decodificable)";

RELATE i18n_key:auth_type_basic_auth_disadvantage_https->translation->language:fr SET text = "HTTPS obligatoire pour toute sécurité";
RELATE i18n_key:auth_type_basic_auth_disadvantage_https->translation->language:en SET text = "HTTPS mandatory for any security";
RELATE i18n_key:auth_type_basic_auth_disadvantage_https->translation->language:it SET text = "HTTPS obbligatorio per qualsiasi sicurezza";
RELATE i18n_key:auth_type_basic_auth_disadvantage_https->translation->language:de SET text = "HTTPS für jede Sicherheit zwingend";
RELATE i18n_key:auth_type_basic_auth_disadvantage_https->translation->language:es SET text = "HTTPS obligatorio para cualquier seguridad";

-- =====================================================
-- BEARER_TOKEN - Name, Description, Tooltip
-- =====================================================

RELATE i18n_key:auth_type_bearer_token_name->translation->language:fr SET text = "Bearer Token";
RELATE i18n_key:auth_type_bearer_token_name->translation->language:en SET text = "Bearer Token";
RELATE i18n_key:auth_type_bearer_token_name->translation->language:it SET text = "Bearer Token";
RELATE i18n_key:auth_type_bearer_token_name->translation->language:de SET text = "Bearer Token";
RELATE i18n_key:auth_type_bearer_token_name->translation->language:es SET text = "Bearer Token";

RELATE i18n_key:auth_type_bearer_token_description->translation->language:fr SET text = "Authentification via un token transmis dans le header Authorization. Souvent utilisé avec JWT. Stateless et scalable.";
RELATE i18n_key:auth_type_bearer_token_description->translation->language:en SET text = "Authentication via a token transmitted in the Authorization header. Often used with JWT. Stateless and scalable.";
RELATE i18n_key:auth_type_bearer_token_description->translation->language:it SET text = "Autenticazione tramite un token trasmesso nell'intestazione Authorization. Spesso utilizzato con JWT. Stateless e scalabile.";
RELATE i18n_key:auth_type_bearer_token_description->translation->language:de SET text = "Authentifizierung über ein Token, das im Authorization-Header übertragen wird. Oft mit JWT verwendet. Stateless und skalierbar.";
RELATE i18n_key:auth_type_bearer_token_description->translation->language:es SET text = "Autenticación mediante un token transmitido en el encabezado Authorization. A menudo utilizado con JWT. Stateless y escalable.";

RELATE i18n_key:auth_type_bearer_token_tooltip->translation->language:fr SET text = "Standard moderne pour tokens (JWT, session tokens)";
RELATE i18n_key:auth_type_bearer_token_tooltip->translation->language:en SET text = "Modern standard for tokens (JWT, session tokens)";
RELATE i18n_key:auth_type_bearer_token_tooltip->translation->language:it SET text = "Standard moderno per token (JWT, token di sessione)";
RELATE i18n_key:auth_type_bearer_token_tooltip->translation->language:de SET text = "Moderner Standard für Tokens (JWT, Session-Tokens)";
RELATE i18n_key:auth_type_bearer_token_tooltip->translation->language:es SET text = "Estándar moderno para tokens (JWT, tokens de sesión)";

-- BEARER_TOKEN - Use Cases
RELATE i18n_key:auth_type_bearer_token_usecase_jwt->translation->language:fr SET text = "JWT tokens (authentication stateless)";
RELATE i18n_key:auth_type_bearer_token_usecase_jwt->translation->language:en SET text = "JWT tokens (stateless authentication)";
RELATE i18n_key:auth_type_bearer_token_usecase_jwt->translation->language:it SET text = "Token JWT (autenticazione stateless)";
RELATE i18n_key:auth_type_bearer_token_usecase_jwt->translation->language:de SET text = "JWT-Tokens (stateless Authentifizierung)";
RELATE i18n_key:auth_type_bearer_token_usecase_jwt->translation->language:es SET text = "Tokens JWT (autenticación stateless)";

RELATE i18n_key:auth_type_bearer_token_usecase_session->translation->language:fr SET text = "Session tokens après login";
RELATE i18n_key:auth_type_bearer_token_usecase_session->translation->language:en SET text = "Session tokens after login";
RELATE i18n_key:auth_type_bearer_token_usecase_session->translation->language:it SET text = "Token di sessione dopo il login";
RELATE i18n_key:auth_type_bearer_token_usecase_session->translation->language:de SET text = "Session-Tokens nach Anmeldung";
RELATE i18n_key:auth_type_bearer_token_usecase_session->translation->language:es SET text = "Tokens de sesión después del login";

-- BEARER_TOKEN - Advantages
RELATE i18n_key:auth_type_bearer_token_advantage_simple->translation->language:fr SET text = "Simple et standard (RFC 6750)";
RELATE i18n_key:auth_type_bearer_token_advantage_simple->translation->language:en SET text = "Simple and standard (RFC 6750)";
RELATE i18n_key:auth_type_bearer_token_advantage_simple->translation->language:it SET text = "Semplice e standard (RFC 6750)";
RELATE i18n_key:auth_type_bearer_token_advantage_simple->translation->language:de SET text = "Einfach und standardisiert (RFC 6750)";
RELATE i18n_key:auth_type_bearer_token_advantage_simple->translation->language:es SET text = "Simple y estándar (RFC 6750)";

RELATE i18n_key:auth_type_bearer_token_advantage_stateless->translation->language:fr SET text = "Stateless (pas de stockage serveur)";
RELATE i18n_key:auth_type_bearer_token_advantage_stateless->translation->language:en SET text = "Stateless (no server storage)";
RELATE i18n_key:auth_type_bearer_token_advantage_stateless->translation->language:it SET text = "Stateless (nessuna memoria server)";
RELATE i18n_key:auth_type_bearer_token_advantage_stateless->translation->language:de SET text = "Stateless (keine Serverspeicherung)";
RELATE i18n_key:auth_type_bearer_token_advantage_stateless->translation->language:es SET text = "Stateless (sin almacenamiento en servidor)";

-- BEARER_TOKEN - Disadvantages
RELATE i18n_key:auth_type_bearer_token_disadvantage_expiration->translation->language:fr SET text = "Gestion de l'expiration et refresh nécessaire";
RELATE i18n_key:auth_type_bearer_token_disadvantage_expiration->translation->language:en SET text = "Expiration and refresh management required";
RELATE i18n_key:auth_type_bearer_token_disadvantage_expiration->translation->language:it SET text = "Gestione scadenza e refresh necessaria";
RELATE i18n_key:auth_type_bearer_token_disadvantage_expiration->translation->language:de SET text = "Ablauf- und Refresh-Verwaltung erforderlich";
RELATE i18n_key:auth_type_bearer_token_disadvantage_expiration->translation->language:es SET text = "Gestión de expiración y refresh requerida";

RELATE i18n_key:auth_type_bearer_token_disadvantage_theft->translation->language:fr SET text = "Vulnérable au vol de token (XSS)";
RELATE i18n_key:auth_type_bearer_token_disadvantage_theft->translation->language:en SET text = "Vulnerable to token theft (XSS)";
RELATE i18n_key:auth_type_bearer_token_disadvantage_theft->translation->language:it SET text = "Vulnerabile al furto di token (XSS)";
RELATE i18n_key:auth_type_bearer_token_disadvantage_theft->translation->language:de SET text = "Anfällig für Token-Diebstahl (XSS)";
RELATE i18n_key:auth_type_bearer_token_disadvantage_theft->translation->language:es SET text = "Vulnerable al robo de tokens (XSS)";

-- =====================================================
-- DIGEST_AUTH, HEADER_AUTH, QUERY_AUTH, CUSTOM
-- (Je vais continuer avec les 4 derniers types...)
-- =====================================================

-- DIGEST_AUTH - Name, Description, Tooltip
RELATE i18n_key:auth_type_digest_auth_name->translation->language:fr SET text = "Digest Auth";
RELATE i18n_key:auth_type_digest_auth_name->translation->language:en SET text = "Digest Auth";
RELATE i18n_key:auth_type_digest_auth_name->translation->language:it SET text = "Digest Auth";
RELATE i18n_key:auth_type_digest_auth_name->translation->language:de SET text = "Digest Auth";
RELATE i18n_key:auth_type_digest_auth_name->translation->language:es SET text = "Digest Auth";

RELATE i18n_key:auth_type_digest_auth_description->translation->language:fr SET text = "Version améliorée de Basic Auth utilisant un hash MD5. Plus sécurisé que Basic Auth mais peu utilisé aujourd'hui.";
RELATE i18n_key:auth_type_digest_auth_description->translation->language:en SET text = "Improved version of Basic Auth using MD5 hash. More secure than Basic Auth but rarely used today.";
RELATE i18n_key:auth_type_digest_auth_description->translation->language:it SET text = "Versione migliorata di Basic Auth che utilizza hash MD5. Più sicuro di Basic Auth ma poco utilizzato oggi.";
RELATE i18n_key:auth_type_digest_auth_description->translation->language:de SET text = "Verbesserte Version von Basic Auth mit MD5-Hash. Sicherer als Basic Auth, aber heute selten verwendet.";
RELATE i18n_key:auth_type_digest_auth_description->translation->language:es SET text = "Versión mejorada de Basic Auth usando hash MD5. Más seguro que Basic Auth pero poco usado hoy.";

RELATE i18n_key:auth_type_digest_auth_tooltip->translation->language:fr SET text = "Plus sécurisé que Basic Auth mais peu populaire";
RELATE i18n_key:auth_type_digest_auth_tooltip->translation->language:en SET text = "More secure than Basic Auth but unpopular";
RELATE i18n_key:auth_type_digest_auth_tooltip->translation->language:it SET text = "Più sicuro di Basic Auth ma poco popolare";
RELATE i18n_key:auth_type_digest_auth_tooltip->translation->language:de SET text = "Sicherer als Basic Auth, aber unbeliebt";
RELATE i18n_key:auth_type_digest_auth_tooltip->translation->language:es SET text = "Más seguro que Basic Auth pero poco popular";

RELATE i18n_key:auth_type_digest_auth_usecase_legacy->translation->language:fr SET text = "Systèmes legacy nécessitant plus de sécurité que Basic";
RELATE i18n_key:auth_type_digest_auth_usecase_legacy->translation->language:en SET text = "Legacy systems requiring more security than Basic";
RELATE i18n_key:auth_type_digest_auth_usecase_legacy->translation->language:it SET text = "Sistemi legacy che richiedono più sicurezza di Basic";
RELATE i18n_key:auth_type_digest_auth_usecase_legacy->translation->language:de SET text = "Legacy-Systeme, die mehr Sicherheit als Basic benötigen";
RELATE i18n_key:auth_type_digest_auth_usecase_legacy->translation->language:es SET text = "Sistemas legacy que requieren más seguridad que Basic";

RELATE i18n_key:auth_type_digest_auth_usecase_http->translation->language:fr SET text = "HTTP sans TLS (non recommandé)";
RELATE i18n_key:auth_type_digest_auth_usecase_http->translation->language:en SET text = "HTTP without TLS (not recommended)";
RELATE i18n_key:auth_type_digest_auth_usecase_http->translation->language:it SET text = "HTTP senza TLS (non raccomandato)";
RELATE i18n_key:auth_type_digest_auth_usecase_http->translation->language:de SET text = "HTTP ohne TLS (nicht empfohlen)";
RELATE i18n_key:auth_type_digest_auth_usecase_http->translation->language:es SET text = "HTTP sin TLS (no recomendado)";

RELATE i18n_key:auth_type_digest_auth_advantage_secure->translation->language:fr SET text = "Plus sécurisé que Basic Auth (hash MD5)";
RELATE i18n_key:auth_type_digest_auth_advantage_secure->translation->language:en SET text = "More secure than Basic Auth (MD5 hash)";
RELATE i18n_key:auth_type_digest_auth_advantage_secure->translation->language:it SET text = "Più sicuro di Basic Auth (hash MD5)";
RELATE i18n_key:auth_type_digest_auth_advantage_secure->translation->language:de SET text = "Sicherer als Basic Auth (MD5-Hash)";
RELATE i18n_key:auth_type_digest_auth_advantage_secure->translation->language:es SET text = "Más seguro que Basic Auth (hash MD5)";

RELATE i18n_key:auth_type_digest_auth_disadvantage_unpopular->translation->language:fr SET text = "Peu populaire et mal supporté";
RELATE i18n_key:auth_type_digest_auth_disadvantage_unpopular->translation->language:en SET text = "Unpopular and poorly supported";
RELATE i18n_key:auth_type_digest_auth_disadvantage_unpopular->translation->language:it SET text = "Poco popolare e mal supportato";
RELATE i18n_key:auth_type_digest_auth_disadvantage_unpopular->translation->language:de SET text = "Unbeliebt und schlecht unterstützt";
RELATE i18n_key:auth_type_digest_auth_disadvantage_unpopular->translation->language:es SET text = "Poco popular y mal soportado";

RELATE i18n_key:auth_type_digest_auth_disadvantage_complex->translation->language:fr SET text = "Plus complexe que Basic Auth";
RELATE i18n_key:auth_type_digest_auth_disadvantage_complex->translation->language:en SET text = "More complex than Basic Auth";
RELATE i18n_key:auth_type_digest_auth_disadvantage_complex->translation->language:it SET text = "Più complesso di Basic Auth";
RELATE i18n_key:auth_type_digest_auth_disadvantage_complex->translation->language:de SET text = "Komplexer als Basic Auth";
RELATE i18n_key:auth_type_digest_auth_disadvantage_complex->translation->language:es SET text = "Más complejo que Basic Auth";

-- HEADER_AUTH - Name, Description, Tooltip
RELATE i18n_key:auth_type_header_auth_name->translation->language:fr SET text = "Header personnalisé";
RELATE i18n_key:auth_type_header_auth_name->translation->language:en SET text = "Custom Header";
RELATE i18n_key:auth_type_header_auth_name->translation->language:it SET text = "Header personalizzato";
RELATE i18n_key:auth_type_header_auth_name->translation->language:de SET text = "Benutzerdefinierter Header";
RELATE i18n_key:auth_type_header_auth_name->translation->language:es SET text = "Encabezado personalizado";

RELATE i18n_key:auth_type_header_auth_description->translation->language:fr SET text = "Authentification via header HTTP personnalisé (ex: X-API-Key, X-Auth-Token). Flexible mais non-standard.";
RELATE i18n_key:auth_type_header_auth_description->translation->language:en SET text = "Authentication via custom HTTP header (e.g., X-API-Key, X-Auth-Token). Flexible but non-standard.";
RELATE i18n_key:auth_type_header_auth_description->translation->language:it SET text = "Autenticazione tramite intestazione HTTP personalizzata (es: X-API-Key, X-Auth-Token). Flessibile ma non standard.";
RELATE i18n_key:auth_type_header_auth_description->translation->language:de SET text = "Authentifizierung über benutzerdefinierten HTTP-Header (z.B. X-API-Key, X-Auth-Token). Flexibel, aber nicht standardmäßig.";
RELATE i18n_key:auth_type_header_auth_description->translation->language:es SET text = "Autenticación mediante encabezado HTTP personalizado (ej: X-API-Key, X-Auth-Token). Flexible pero no estándar.";

RELATE i18n_key:auth_type_header_auth_tooltip->translation->language:fr SET text = "Flexible pour APIs propriétaires";
RELATE i18n_key:auth_type_header_auth_tooltip->translation->language:en SET text = "Flexible for proprietary APIs";
RELATE i18n_key:auth_type_header_auth_tooltip->translation->language:it SET text = "Flessibile per API proprietarie";
RELATE i18n_key:auth_type_header_auth_tooltip->translation->language:de SET text = "Flexibel für proprietäre APIs";
RELATE i18n_key:auth_type_header_auth_tooltip->translation->language:es SET text = "Flexible para APIs propietarias";

RELATE i18n_key:auth_type_header_auth_usecase_proprietary->translation->language:fr SET text = "APIs propriétaires avec headers spécifiques";
RELATE i18n_key:auth_type_header_auth_usecase_proprietary->translation->language:en SET text = "Proprietary APIs with specific headers";
RELATE i18n_key:auth_type_header_auth_usecase_proprietary->translation->language:it SET text = "API proprietarie con header specifici";
RELATE i18n_key:auth_type_header_auth_usecase_proprietary->translation->language:de SET text = "Proprietäre APIs mit spezifischen Headern";
RELATE i18n_key:auth_type_header_auth_usecase_proprietary->translation->language:es SET text = "APIs propietarias con encabezados específicos";

RELATE i18n_key:auth_type_header_auth_usecase_custom->translation->language:fr SET text = "Headers personnalisés (X-API-Token, X-Tenant-ID)";
RELATE i18n_key:auth_type_header_auth_usecase_custom->translation->language:en SET text = "Custom headers (X-API-Token, X-Tenant-ID)";
RELATE i18n_key:auth_type_header_auth_usecase_custom->translation->language:it SET text = "Header personalizzati (X-API-Token, X-Tenant-ID)";
RELATE i18n_key:auth_type_header_auth_usecase_custom->translation->language:de SET text = "Benutzerdefinierte Header (X-API-Token, X-Tenant-ID)";
RELATE i18n_key:auth_type_header_auth_usecase_custom->translation->language:es SET text = "Encabezados personalizados (X-API-Token, X-Tenant-ID)";

RELATE i18n_key:auth_type_header_auth_advantage_flexible->translation->language:fr SET text = "Flexible et adaptable";
RELATE i18n_key:auth_type_header_auth_advantage_flexible->translation->language:en SET text = "Flexible and adaptable";
RELATE i18n_key:auth_type_header_auth_advantage_flexible->translation->language:it SET text = "Flessibile e adattabile";
RELATE i18n_key:auth_type_header_auth_advantage_flexible->translation->language:de SET text = "Flexibel und anpassbar";
RELATE i18n_key:auth_type_header_auth_advantage_flexible->translation->language:es SET text = "Flexible y adaptable";

RELATE i18n_key:auth_type_header_auth_disadvantage_nonstandard->translation->language:fr SET text = "Non-standard (documentation nécessaire)";
RELATE i18n_key:auth_type_header_auth_disadvantage_nonstandard->translation->language:en SET text = "Non-standard (documentation required)";
RELATE i18n_key:auth_type_header_auth_disadvantage_nonstandard->translation->language:it SET text = "Non standard (documentazione necessaria)";
RELATE i18n_key:auth_type_header_auth_disadvantage_nonstandard->translation->language:de SET text = "Nicht standardmäßig (Dokumentation erforderlich)";
RELATE i18n_key:auth_type_header_auth_disadvantage_nonstandard->translation->language:es SET text = "No estándar (documentación requerida)";

RELATE i18n_key:auth_type_header_auth_disadvantage_documentation->translation->language:fr SET text = "Nécessite documentation spécifique";
RELATE i18n_key:auth_type_header_auth_disadvantage_documentation->translation->language:en SET text = "Requires specific documentation";
RELATE i18n_key:auth_type_header_auth_disadvantage_documentation->translation->language:it SET text = "Richiede documentazione specifica";
RELATE i18n_key:auth_type_header_auth_disadvantage_documentation->translation->language:de SET text = "Erfordert spezifische Dokumentation";
RELATE i18n_key:auth_type_header_auth_disadvantage_documentation->translation->language:es SET text = "Requiere documentación específica";

-- QUERY_AUTH - Name, Description, Tooltip
RELATE i18n_key:auth_type_query_auth_name->translation->language:fr SET text = "Paramètre de requête";
RELATE i18n_key:auth_type_query_auth_name->translation->language:en SET text = "Query Parameter";
RELATE i18n_key:auth_type_query_auth_name->translation->language:it SET text = "Parametro di query";
RELATE i18n_key:auth_type_query_auth_name->translation->language:de SET text = "Abfrageparameter";
RELATE i18n_key:auth_type_query_auth_name->translation->language:es SET text = "Parámetro de consulta";

RELATE i18n_key:auth_type_query_auth_description->translation->language:fr SET text = "Credentials transmis via URL (?api_key=xxx). ⚠️ ATTENTION : Faible sécurité car visible dans logs, historique et URL.";
RELATE i18n_key:auth_type_query_auth_description->translation->language:en SET text = "Credentials transmitted via URL (?api_key=xxx). ⚠️ WARNING: Low security as visible in logs, history and URL.";
RELATE i18n_key:auth_type_query_auth_description->translation->language:it SET text = "Credenziali trasmesse tramite URL (?api_key=xxx). ⚠️ ATTENZIONE: Bassa sicurezza poiché visibile in log, cronologia e URL.";
RELATE i18n_key:auth_type_query_auth_description->translation->language:de SET text = "Anmeldeinformationen über URL übertragen (?api_key=xxx). ⚠️ WARNUNG: Geringe Sicherheit, da in Logs, Verlauf und URL sichtbar.";
RELATE i18n_key:auth_type_query_auth_description->translation->language:es SET text = "Credenciales transmitidas vía URL (?api_key=xxx). ⚠️ ADVERTENCIA: Baja seguridad ya que visible en logs, historial y URL.";

RELATE i18n_key:auth_type_query_auth_tooltip->translation->language:fr SET text = "⚠️ Faible sécurité : À éviter pour données sensibles";
RELATE i18n_key:auth_type_query_auth_tooltip->translation->language:en SET text = "⚠️ Low security: Avoid for sensitive data";
RELATE i18n_key:auth_type_query_auth_tooltip->translation->language:it SET text = "⚠️ Bassa sicurezza: Evitare per dati sensibili";
RELATE i18n_key:auth_type_query_auth_tooltip->translation->language:de SET text = "⚠️ Geringe Sicherheit: Für sensible Daten vermeiden";
RELATE i18n_key:auth_type_query_auth_tooltip->translation->language:es SET text = "⚠️ Baja seguridad: Evitar para datos sensibles";

RELATE i18n_key:auth_type_query_auth_usecase_public->translation->language:fr SET text = "APIs publiques avec clés non sensibles";
RELATE i18n_key:auth_type_query_auth_usecase_public->translation->language:en SET text = "Public APIs with non-sensitive keys";
RELATE i18n_key:auth_type_query_auth_usecase_public->translation->language:it SET text = "API pubbliche con chiavi non sensibili";
RELATE i18n_key:auth_type_query_auth_usecase_public->translation->language:de SET text = "Öffentliche APIs mit nicht sensiblen Schlüsseln";
RELATE i18n_key:auth_type_query_auth_usecase_public->translation->language:es SET text = "APIs públicas con claves no sensibles";

RELATE i18n_key:auth_type_query_auth_usecase_embed->translation->language:fr SET text = "Widgets et embeds";
RELATE i18n_key:auth_type_query_auth_usecase_embed->translation->language:en SET text = "Widgets and embeds";
RELATE i18n_key:auth_type_query_auth_usecase_embed->translation->language:it SET text = "Widget e embed";
RELATE i18n_key:auth_type_query_auth_usecase_embed->translation->language:de SET text = "Widgets und Embeds";
RELATE i18n_key:auth_type_query_auth_usecase_embed->translation->language:es SET text = "Widgets y embeds";

RELATE i18n_key:auth_type_query_auth_advantage_simple->translation->language:fr SET text = "Très simple à implémenter";
RELATE i18n_key:auth_type_query_auth_advantage_simple->translation->language:en SET text = "Very simple to implement";
RELATE i18n_key:auth_type_query_auth_advantage_simple->translation->language:it SET text = "Molto semplice da implementare";
RELATE i18n_key:auth_type_query_auth_advantage_simple->translation->language:de SET text = "Sehr einfach zu implementieren";
RELATE i18n_key:auth_type_query_auth_advantage_simple->translation->language:es SET text = "Muy simple de implementar";

RELATE i18n_key:auth_type_query_auth_disadvantage_security->translation->language:fr SET text = "Faible sécurité (visible dans URL)";
RELATE i18n_key:auth_type_query_auth_disadvantage_security->translation->language:en SET text = "Low security (visible in URL)";
RELATE i18n_key:auth_type_query_auth_disadvantage_security->translation->language:it SET text = "Bassa sicurezza (visibile nell'URL)";
RELATE i18n_key:auth_type_query_auth_disadvantage_security->translation->language:de SET text = "Geringe Sicherheit (in URL sichtbar)";
RELATE i18n_key:auth_type_query_auth_disadvantage_security->translation->language:es SET text = "Baja seguridad (visible en URL)";

RELATE i18n_key:auth_type_query_auth_disadvantage_logs->translation->language:fr SET text = "Exposé dans logs et historique navigateur";
RELATE i18n_key:auth_type_query_auth_disadvantage_logs->translation->language:en SET text = "Exposed in logs and browser history";
RELATE i18n_key:auth_type_query_auth_disadvantage_logs->translation->language:it SET text = "Esposto in log e cronologia del browser";
RELATE i18n_key:auth_type_query_auth_disadvantage_logs->translation->language:de SET text = "In Logs und Browser-Verlauf offengelegt";
RELATE i18n_key:auth_type_query_auth_disadvantage_logs->translation->language:es SET text = "Expuesto en logs e historial del navegador";

-- CUSTOM - Name, Description, Tooltip
RELATE i18n_key:auth_type_custom_name->translation->language:fr SET text = "Personnalisé";
RELATE i18n_key:auth_type_custom_name->translation->language:en SET text = "Custom";
RELATE i18n_key:auth_type_custom_name->translation->language:it SET text = "Personalizzato";
RELATE i18n_key:auth_type_custom_name->translation->language:de SET text = "Benutzerdefiniert";
RELATE i18n_key:auth_type_custom_name->translation->language:es SET text = "Personalizado";

RELATE i18n_key:auth_type_custom_description->translation->language:fr SET text = "Méthode d'authentification personnalisée ou propriétaire. Utilisée pour protocoles non-standard ou spécifiques.";
RELATE i18n_key:auth_type_custom_description->translation->language:en SET text = "Custom or proprietary authentication method. Used for non-standard or specific protocols.";
RELATE i18n_key:auth_type_custom_description->translation->language:it SET text = "Metodo di autenticazione personalizzato o proprietario. Utilizzato per protocolli non standard o specifici.";
RELATE i18n_key:auth_type_custom_description->translation->language:de SET text = "Benutzerdefinierte oder proprietäre Authentifizierungsmethode. Für nicht standardmäßige oder spezifische Protokolle verwendet.";
RELATE i18n_key:auth_type_custom_description->translation->language:es SET text = "Método de autenticación personalizado o propietario. Utilizado para protocolos no estándar o específicos.";

RELATE i18n_key:auth_type_custom_tooltip->translation->language:fr SET text = "Pour protocoles propriétaires ou très spécifiques";
RELATE i18n_key:auth_type_custom_tooltip->translation->language:en SET text = "For proprietary or very specific protocols";
RELATE i18n_key:auth_type_custom_tooltip->translation->language:it SET text = "Per protocolli proprietari o molto specifici";
RELATE i18n_key:auth_type_custom_tooltip->translation->language:de SET text = "Für proprietäre oder sehr spezifische Protokolle";
RELATE i18n_key:auth_type_custom_tooltip->translation->language:es SET text = "Para protocolos propietarios o muy específicos";

RELATE i18n_key:auth_type_custom_usecase_proprietary->translation->language:fr SET text = "Protocoles d'authentification propriétaires";
RELATE i18n_key:auth_type_custom_usecase_proprietary->translation->language:en SET text = "Proprietary authentication protocols";
RELATE i18n_key:auth_type_custom_usecase_proprietary->translation->language:it SET text = "Protocolli di autenticazione proprietari";
RELATE i18n_key:auth_type_custom_usecase_proprietary->translation->language:de SET text = "Proprietäre Authentifizierungsprotokolle";
RELATE i18n_key:auth_type_custom_usecase_proprietary->translation->language:es SET text = "Protocolos de autenticación propietarios";

RELATE i18n_key:auth_type_custom_usecase_specialized->translation->language:fr SET text = "Systèmes spécialisés (militaire, bancaire)";
RELATE i18n_key:auth_type_custom_usecase_specialized->translation->language:en SET text = "Specialized systems (military, banking)";
RELATE i18n_key:auth_type_custom_usecase_specialized->translation->language:it SET text = "Sistemi specializzati (militare, bancario)";
RELATE i18n_key:auth_type_custom_usecase_specialized->translation->language:de SET text = "Spezialisierte Systeme (militärisch, Banken)";
RELATE i18n_key:auth_type_custom_usecase_specialized->translation->language:es SET text = "Sistemas especializados (militar, bancario)";

RELATE i18n_key:auth_type_custom_advantage_flexible->translation->language:fr SET text = "Totalement flexible et adaptable";
RELATE i18n_key:auth_type_custom_advantage_flexible->translation->language:en SET text = "Totally flexible and adaptable";
RELATE i18n_key:auth_type_custom_advantage_flexible->translation->language:it SET text = "Totalmente flessibile e adattabile";
RELATE i18n_key:auth_type_custom_advantage_flexible->translation->language:de SET text = "Völlig flexibel und anpassbar";
RELATE i18n_key:auth_type_custom_advantage_flexible->translation->language:es SET text = "Totalmente flexible y adaptable";

RELATE i18n_key:auth_type_custom_disadvantage_implementation->translation->language:fr SET text = "Implémentation custom nécessaire";
RELATE i18n_key:auth_type_custom_disadvantage_implementation->translation->language:en SET text = "Custom implementation required";
RELATE i18n_key:auth_type_custom_disadvantage_implementation->translation->language:it SET text = "Implementazione personalizzata necessaria";
RELATE i18n_key:auth_type_custom_disadvantage_implementation->translation->language:de SET text = "Benutzerdefinierte Implementierung erforderlich";
RELATE i18n_key:auth_type_custom_disadvantage_implementation->translation->language:es SET text = "Implementación personalizada requerida";

RELATE i18n_key:auth_type_custom_disadvantage_maintenance->translation->language:fr SET text = "Maintenance et documentation complexes";
RELATE i18n_key:auth_type_custom_disadvantage_maintenance->translation->language:en SET text = "Complex maintenance and documentation";
RELATE i18n_key:auth_type_custom_disadvantage_maintenance->translation->language:it SET text = "Manutenzione e documentazione complesse";
RELATE i18n_key:auth_type_custom_disadvantage_maintenance->translation->language:de SET text = "Komplexe Wartung und Dokumentation";
RELATE i18n_key:auth_type_custom_disadvantage_maintenance->translation->language:es SET text = "Mantenimiento y documentación complejos";

-- =====================================================
-- RÉSUMÉ FINAL
-- =====================================================
--
-- ✅ 375 traductions créées :
--    • FR (Français) : 75
--    • EN (English) : 75
--    • IT (Italiano) : 75
--    • DE (Deutsch) : 75
--    • ES (Español) : 75
--
-- =============================================================================================

