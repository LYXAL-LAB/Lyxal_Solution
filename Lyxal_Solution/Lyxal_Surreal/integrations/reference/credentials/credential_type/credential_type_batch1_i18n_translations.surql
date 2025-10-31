-- =============================================================================================
-- |
-- | Fichier : credential_type_batch1_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 1 des credential types.
-- |
-- | Batch 1 : Credentials fondamentaux (9 types)
-- | • HTTP génériques (7) : BasicAuth, BearerAuth, CustomAuth, DigestAuth, HeaderAuth, QueryAuth, SslAuth
-- | • OAuth génériques (2) : OAuth1Api, OAuth2Api
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 135 traductions (27 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- HTTP BASIC AUTH
-- =====================================================

RELATE i18n_key:credential_type_http_basic_auth_name->translation->language:fr SET text = "HTTP Basic Auth";
RELATE i18n_key:credential_type_http_basic_auth_name->translation->language:en SET text = "HTTP Basic Auth";
RELATE i18n_key:credential_type_http_basic_auth_name->translation->language:it SET text = "HTTP Basic Auth";
RELATE i18n_key:credential_type_http_basic_auth_name->translation->language:de SET text = "HTTP Basic Auth";
RELATE i18n_key:credential_type_http_basic_auth_name->translation->language:es SET text = "HTTP Basic Auth";

RELATE i18n_key:credential_type_http_basic_auth_description->translation->language:fr SET text = "Authentification HTTP Basic générique avec nom d'utilisateur et mot de passe. Simple mais nécessite HTTPS pour la sécurité.";
RELATE i18n_key:credential_type_http_basic_auth_description->translation->language:en SET text = "Generic HTTP Basic authentication with username and password. Simple but requires HTTPS for security.";
RELATE i18n_key:credential_type_http_basic_auth_description->translation->language:it SET text = "Autenticazione HTTP Basic generica con nome utente e password. Semplice ma richiede HTTPS per la sicurezza.";
RELATE i18n_key:credential_type_http_basic_auth_description->translation->language:de SET text = "Generische HTTP-Basic-Authentifizierung mit Benutzername und Passwort. Einfach, erfordert jedoch HTTPS für Sicherheit.";
RELATE i18n_key:credential_type_http_basic_auth_description->translation->language:es SET text = "Autenticación HTTP Basic genérica con nombre de usuario y contraseña. Simple pero requiere HTTPS para seguridad.";

RELATE i18n_key:credential_type_http_basic_auth_tooltip->translation->language:fr SET text = "⚠️ Simple mais faible sécurité - HTTPS obligatoire";
RELATE i18n_key:credential_type_http_basic_auth_tooltip->translation->language:en SET text = "⚠️ Simple but low security - HTTPS required";
RELATE i18n_key:credential_type_http_basic_auth_tooltip->translation->language:it SET text = "⚠️ Semplice ma bassa sicurezza - HTTPS obbligatorio";
RELATE i18n_key:credential_type_http_basic_auth_tooltip->translation->language:de SET text = "⚠️ Einfach aber geringe Sicherheit - HTTPS erforderlich";
RELATE i18n_key:credential_type_http_basic_auth_tooltip->translation->language:es SET text = "⚠️ Simple pero baja seguridad - HTTPS requerido";

-- =====================================================
-- HTTP BEARER AUTH
-- =====================================================

RELATE i18n_key:credential_type_http_bearer_auth_name->translation->language:fr SET text = "HTTP Bearer Token";
RELATE i18n_key:credential_type_http_bearer_auth_name->translation->language:en SET text = "HTTP Bearer Token";
RELATE i18n_key:credential_type_http_bearer_auth_name->translation->language:it SET text = "HTTP Bearer Token";
RELATE i18n_key:credential_type_http_bearer_auth_name->translation->language:de SET text = "HTTP Bearer Token";
RELATE i18n_key:credential_type_http_bearer_auth_name->translation->language:es SET text = "HTTP Bearer Token";

RELATE i18n_key:credential_type_http_bearer_auth_description->translation->language:fr SET text = "Authentification HTTP Bearer générique avec token. Standard moderne pour APIs REST, souvent utilisé avec JWT.";
RELATE i18n_key:credential_type_http_bearer_auth_description->translation->language:en SET text = "Generic HTTP Bearer authentication with token. Modern standard for REST APIs, often used with JWT.";
RELATE i18n_key:credential_type_http_bearer_auth_description->translation->language:it SET text = "Autenticazione HTTP Bearer generica con token. Standard moderno per API REST, spesso utilizzato con JWT.";
RELATE i18n_key:credential_type_http_bearer_auth_description->translation->language:de SET text = "Generische HTTP-Bearer-Authentifizierung mit Token. Moderner Standard für REST-APIs, oft mit JWT verwendet.";
RELATE i18n_key:credential_type_http_bearer_auth_description->translation->language:es SET text = "Autenticación HTTP Bearer genérica con token. Estándar moderno para APIs REST, a menudo usado con JWT.";

RELATE i18n_key:credential_type_http_bearer_auth_tooltip->translation->language:fr SET text = "✅ Standard moderne pour tokens (JWT, session)";
RELATE i18n_key:credential_type_http_bearer_auth_tooltip->translation->language:en SET text = "✅ Modern standard for tokens (JWT, session)";
RELATE i18n_key:credential_type_http_bearer_auth_tooltip->translation->language:it SET text = "✅ Standard moderno per token (JWT, sessione)";
RELATE i18n_key:credential_type_http_bearer_auth_tooltip->translation->language:de SET text = "✅ Moderner Standard für Tokens (JWT, Sitzung)";
RELATE i18n_key:credential_type_http_bearer_auth_tooltip->translation->language:es SET text = "✅ Estándar moderno para tokens (JWT, sesión)";

-- =====================================================
-- HTTP CUSTOM AUTH
-- =====================================================

RELATE i18n_key:credential_type_http_custom_auth_name->translation->language:fr SET text = "HTTP Custom Auth";
RELATE i18n_key:credential_type_http_custom_auth_name->translation->language:en SET text = "HTTP Custom Auth";
RELATE i18n_key:credential_type_http_custom_auth_name->translation->language:it SET text = "HTTP Custom Auth";
RELATE i18n_key:credential_type_http_custom_auth_name->translation->language:de SET text = "HTTP Custom Auth";
RELATE i18n_key:credential_type_http_custom_auth_name->translation->language:es SET text = "HTTP Custom Auth";

RELATE i18n_key:credential_type_http_custom_auth_description->translation->language:fr SET text = "Authentification HTTP personnalisée pour protocoles non-standard. Permet configuration flexible des headers, query params, body et JSON.";
RELATE i18n_key:credential_type_http_custom_auth_description->translation->language:en SET text = "Custom HTTP authentication for non-standard protocols. Allows flexible configuration of headers, query params, body and JSON.";
RELATE i18n_key:credential_type_http_custom_auth_description->translation->language:it SET text = "Autenticazione HTTP personalizzata per protocolli non standard. Consente configurazione flessibile di header, query params, body e JSON.";
RELATE i18n_key:credential_type_http_custom_auth_description->translation->language:de SET text = "Benutzerdefinierte HTTP-Authentifizierung für nicht-standardisierte Protokolle. Ermöglicht flexible Konfiguration von Headern, Query-Parametern, Body und JSON.";
RELATE i18n_key:credential_type_http_custom_auth_description->translation->language:es SET text = "Autenticación HTTP personalizada para protocolos no estándar. Permite configuración flexible de headers, query params, body y JSON.";

RELATE i18n_key:credential_type_http_custom_auth_tooltip->translation->language:fr SET text = "Flexible pour APIs propriétaires et non-standard";
RELATE i18n_key:credential_type_http_custom_auth_tooltip->translation->language:en SET text = "Flexible for proprietary and non-standard APIs";
RELATE i18n_key:credential_type_http_custom_auth_tooltip->translation->language:it SET text = "Flessibile per API proprietarie e non standard";
RELATE i18n_key:credential_type_http_custom_auth_tooltip->translation->language:de SET text = "Flexibel für proprietäre und nicht-standardisierte APIs";
RELATE i18n_key:credential_type_http_custom_auth_tooltip->translation->language:es SET text = "Flexible para APIs propietarias y no estándar";

-- =====================================================
-- HTTP DIGEST AUTH
-- =====================================================

RELATE i18n_key:credential_type_http_digest_auth_name->translation->language:fr SET text = "HTTP Digest Auth";
RELATE i18n_key:credential_type_http_digest_auth_name->translation->language:en SET text = "HTTP Digest Auth";
RELATE i18n_key:credential_type_http_digest_auth_name->translation->language:it SET text = "HTTP Digest Auth";
RELATE i18n_key:credential_type_http_digest_auth_name->translation->language:de SET text = "HTTP Digest Auth";
RELATE i18n_key:credential_type_http_digest_auth_name->translation->language:es SET text = "HTTP Digest Auth";

RELATE i18n_key:credential_type_http_digest_auth_description->translation->language:fr SET text = "Authentification HTTP Digest avec hash MD5. Plus sécurisé que Basic Auth mais peu utilisé aujourd'hui.";
RELATE i18n_key:credential_type_http_digest_auth_description->translation->language:en SET text = "HTTP Digest authentication with MD5 hash. More secure than Basic Auth but rarely used today.";
RELATE i18n_key:credential_type_http_digest_auth_description->translation->language:it SET text = "Autenticazione HTTP Digest con hash MD5. Più sicuro di Basic Auth ma poco utilizzato oggi.";
RELATE i18n_key:credential_type_http_digest_auth_description->translation->language:de SET text = "HTTP-Digest-Authentifizierung mit MD5-Hash. Sicherer als Basic Auth, aber heute selten verwendet.";
RELATE i18n_key:credential_type_http_digest_auth_description->translation->language:es SET text = "Autenticación HTTP Digest con hash MD5. Más seguro que Basic Auth pero poco usado hoy.";

RELATE i18n_key:credential_type_http_digest_auth_tooltip->translation->language:fr SET text = "Plus sécurisé que Basic Auth mais peu populaire";
RELATE i18n_key:credential_type_http_digest_auth_tooltip->translation->language:en SET text = "More secure than Basic Auth but unpopular";
RELATE i18n_key:credential_type_http_digest_auth_tooltip->translation->language:it SET text = "Più sicuro di Basic Auth ma poco popolare";
RELATE i18n_key:credential_type_http_digest_auth_tooltip->translation->language:de SET text = "Sicherer als Basic Auth aber unbeliebt";
RELATE i18n_key:credential_type_http_digest_auth_tooltip->translation->language:es SET text = "Más seguro que Basic Auth pero poco popular";

-- =====================================================
-- HTTP HEADER AUTH
-- =====================================================

RELATE i18n_key:credential_type_http_header_auth_name->translation->language:fr SET text = "HTTP Header Auth";
RELATE i18n_key:credential_type_http_header_auth_name->translation->language:en SET text = "HTTP Header Auth";
RELATE i18n_key:credential_type_http_header_auth_name->translation->language:it SET text = "HTTP Header Auth";
RELATE i18n_key:credential_type_http_header_auth_name->translation->language:de SET text = "HTTP Header Auth";
RELATE i18n_key:credential_type_http_header_auth_name->translation->language:es SET text = "HTTP Header Auth";

RELATE i18n_key:credential_type_http_header_auth_description->translation->language:fr SET text = "Authentification via header HTTP personnalisé (ex: X-API-Key, X-Auth-Token). Flexible pour APIs avec headers spécifiques.";
RELATE i18n_key:credential_type_http_header_auth_description->translation->language:en SET text = "Authentication via custom HTTP header (e.g., X-API-Key, X-Auth-Token). Flexible for APIs with specific headers.";
RELATE i18n_key:credential_type_http_header_auth_description->translation->language:it SET text = "Autenticazione tramite intestazione HTTP personalizzata (es: X-API-Key, X-Auth-Token). Flessibile per API con header specifici.";
RELATE i18n_key:credential_type_http_header_auth_description->translation->language:de SET text = "Authentifizierung über benutzerdefinierten HTTP-Header (z.B. X-API-Key, X-Auth-Token). Flexibel für APIs mit spezifischen Headern.";
RELATE i18n_key:credential_type_http_header_auth_description->translation->language:es SET text = "Autenticación mediante encabezado HTTP personalizado (ej: X-API-Key, X-Auth-Token). Flexible para APIs con encabezados específicos.";

RELATE i18n_key:credential_type_http_header_auth_tooltip->translation->language:fr SET text = "Flexible pour headers personnalisés (X-API-Key, etc.)";
RELATE i18n_key:credential_type_http_header_auth_tooltip->translation->language:en SET text = "Flexible for custom headers (X-API-Key, etc.)";
RELATE i18n_key:credential_type_http_header_auth_tooltip->translation->language:it SET text = "Flessibile per header personalizzati (X-API-Key, ecc.)";
RELATE i18n_key:credential_type_http_header_auth_tooltip->translation->language:de SET text = "Flexibel für benutzerdefinierte Header (X-API-Key usw.)";
RELATE i18n_key:credential_type_http_header_auth_tooltip->translation->language:es SET text = "Flexible para encabezados personalizados (X-API-Key, etc.)";

-- =====================================================
-- HTTP QUERY AUTH
-- =====================================================

RELATE i18n_key:credential_type_http_query_auth_name->translation->language:fr SET text = "HTTP Query Auth";
RELATE i18n_key:credential_type_http_query_auth_name->translation->language:en SET text = "HTTP Query Auth";
RELATE i18n_key:credential_type_http_query_auth_name->translation->language:it SET text = "HTTP Query Auth";
RELATE i18n_key:credential_type_http_query_auth_name->translation->language:de SET text = "HTTP Query Auth";
RELATE i18n_key:credential_type_http_query_auth_name->translation->language:es SET text = "HTTP Query Auth";

RELATE i18n_key:credential_type_http_query_auth_description->translation->language:fr SET text = "Authentification via paramètres de requête URL (ex: ?api_key=xxx). ⚠️ Faible sécurité car visible dans URL et logs.";
RELATE i18n_key:credential_type_http_query_auth_description->translation->language:en SET text = "Authentication via URL query parameters (e.g., ?api_key=xxx). ⚠️ Low security as visible in URL and logs.";
RELATE i18n_key:credential_type_http_query_auth_description->translation->language:it SET text = "Autenticazione tramite parametri di query URL (es: ?api_key=xxx). ⚠️ Bassa sicurezza poiché visibile nell'URL e nei log.";
RELATE i18n_key:credential_type_http_query_auth_description->translation->language:de SET text = "Authentifizierung über URL-Abfrageparameter (z.B. ?api_key=xxx). ⚠️ Geringe Sicherheit, da in URL und Logs sichtbar.";
RELATE i18n_key:credential_type_http_query_auth_description->translation->language:es SET text = "Autenticación mediante parámetros de consulta URL (ej: ?api_key=xxx). ⚠️ Baja seguridad ya que visible en URL y logs.";

RELATE i18n_key:credential_type_http_query_auth_tooltip->translation->language:fr SET text = "⚠️ Faible sécurité - Éviter pour données sensibles";
RELATE i18n_key:credential_type_http_query_auth_tooltip->translation->language:en SET text = "⚠️ Low security - Avoid for sensitive data";
RELATE i18n_key:credential_type_http_query_auth_tooltip->translation->language:it SET text = "⚠️ Bassa sicurezza - Evitare per dati sensibili";
RELATE i18n_key:credential_type_http_query_auth_tooltip->translation->language:de SET text = "⚠️ Geringe Sicherheit - Für sensible Daten vermeiden";
RELATE i18n_key:credential_type_http_query_auth_tooltip->translation->language:es SET text = "⚠️ Baja seguridad - Evitar para datos sensibles";

-- =====================================================
-- HTTP SSL AUTH
-- =====================================================

RELATE i18n_key:credential_type_http_ssl_auth_name->translation->language:fr SET text = "HTTP SSL Certificate";
RELATE i18n_key:credential_type_http_ssl_auth_name->translation->language:en SET text = "HTTP SSL Certificate";
RELATE i18n_key:credential_type_http_ssl_auth_name->translation->language:it SET text = "HTTP SSL Certificate";
RELATE i18n_key:credential_type_http_ssl_auth_name->translation->language:de SET text = "HTTP SSL Certificate";
RELATE i18n_key:credential_type_http_ssl_auth_name->translation->language:es SET text = "HTTP SSL Certificate";

RELATE i18n_key:credential_type_http_ssl_auth_description->translation->language:fr SET text = "Authentification via certificat SSL/TLS client. Utilisé pour mutual TLS (mTLS) et authentification par certificat.";
RELATE i18n_key:credential_type_http_ssl_auth_description->translation->language:en SET text = "Authentication via client SSL/TLS certificate. Used for mutual TLS (mTLS) and certificate-based authentication.";
RELATE i18n_key:credential_type_http_ssl_auth_description->translation->language:it SET text = "Autenticazione tramite certificato SSL/TLS client. Utilizzato per mutual TLS (mTLS) e autenticazione basata su certificato.";
RELATE i18n_key:credential_type_http_ssl_auth_description->translation->language:de SET text = "Authentifizierung über Client-SSL/TLS-Zertifikat. Verwendet für Mutual TLS (mTLS) und zertifikatsbasierte Authentifizierung.";
RELATE i18n_key:credential_type_http_ssl_auth_description->translation->language:es SET text = "Autenticación mediante certificado SSL/TLS cliente. Usado para mutual TLS (mTLS) y autenticación basada en certificado.";

RELATE i18n_key:credential_type_http_ssl_auth_tooltip->translation->language:fr SET text = "Sécurisé pour mutual TLS et certificats clients";
RELATE i18n_key:credential_type_http_ssl_auth_tooltip->translation->language:en SET text = "Secure for mutual TLS and client certificates";
RELATE i18n_key:credential_type_http_ssl_auth_tooltip->translation->language:it SET text = "Sicuro per mutual TLS e certificati client";
RELATE i18n_key:credential_type_http_ssl_auth_tooltip->translation->language:de SET text = "Sicher für Mutual TLS und Client-Zertifikate";
RELATE i18n_key:credential_type_http_ssl_auth_tooltip->translation->language:es SET text = "Seguro para mutual TLS y certificados cliente";

-- =====================================================
-- OAUTH1 API
-- =====================================================

RELATE i18n_key:credential_type_oauth1_api_name->translation->language:fr SET text = "OAuth 1.0a Generic";
RELATE i18n_key:credential_type_oauth1_api_name->translation->language:en SET text = "OAuth 1.0a Generic";
RELATE i18n_key:credential_type_oauth1_api_name->translation->language:it SET text = "OAuth 1.0a Generic";
RELATE i18n_key:credential_type_oauth1_api_name->translation->language:de SET text = "OAuth 1.0a Generic";
RELATE i18n_key:credential_type_oauth1_api_name->translation->language:es SET text = "OAuth 1.0a Generic";

RELATE i18n_key:credential_type_oauth1_api_description->translation->language:fr SET text = "OAuth 1.0a générique avec signature cryptographique. Pour APIs legacy supportant OAuth 1.0a (Twitter v1, Trello, etc.).";
RELATE i18n_key:credential_type_oauth1_api_description->translation->language:en SET text = "Generic OAuth 1.0a with cryptographic signature. For legacy APIs supporting OAuth 1.0a (Twitter v1, Trello, etc.).";
RELATE i18n_key:credential_type_oauth1_api_description->translation->language:it SET text = "OAuth 1.0a generico con firma crittografica. Per API legacy che supportano OAuth 1.0a (Twitter v1, Trello, ecc.).";
RELATE i18n_key:credential_type_oauth1_api_description->translation->language:de SET text = "Generisches OAuth 1.0a mit kryptografischer Signatur. Für Legacy-APIs mit OAuth 1.0a-Unterstützung (Twitter v1, Trello usw.).";
RELATE i18n_key:credential_type_oauth1_api_description->translation->language:es SET text = "OAuth 1.0a genérico con firma criptográfica. Para APIs legacy que soportan OAuth 1.0a (Twitter v1, Trello, etc.).";

RELATE i18n_key:credential_type_oauth1_api_tooltip->translation->language:fr SET text = "⚠️ Legacy - Préférer OAuth 2.0 pour nouveaux projets";
RELATE i18n_key:credential_type_oauth1_api_tooltip->translation->language:en SET text = "⚠️ Legacy - Prefer OAuth 2.0 for new projects";
RELATE i18n_key:credential_type_oauth1_api_tooltip->translation->language:it SET text = "⚠️ Legacy - Preferire OAuth 2.0 per nuovi progetti";
RELATE i18n_key:credential_type_oauth1_api_tooltip->translation->language:de SET text = "⚠️ Legacy - OAuth 2.0 für neue Projekte bevorzugen";
RELATE i18n_key:credential_type_oauth1_api_tooltip->translation->language:es SET text = "⚠️ Legacy - Preferir OAuth 2.0 para nuevos proyectos";

-- =====================================================
-- OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_oauth2_api_name->translation->language:fr SET text = "OAuth 2.0 Generic";
RELATE i18n_key:credential_type_oauth2_api_name->translation->language:en SET text = "OAuth 2.0 Generic";
RELATE i18n_key:credential_type_oauth2_api_name->translation->language:it SET text = "OAuth 2.0 Generic";
RELATE i18n_key:credential_type_oauth2_api_name->translation->language:de SET text = "OAuth 2.0 Generic";
RELATE i18n_key:credential_type_oauth2_api_name->translation->language:es SET text = "OAuth 2.0 Generic";

RELATE i18n_key:credential_type_oauth2_api_description->translation->language:fr SET text = "OAuth 2.0 générique avec refresh tokens. Standard moderne pour authentification sécurisée. Compatible avec toute API supportant OAuth 2.0.";
RELATE i18n_key:credential_type_oauth2_api_description->translation->language:en SET text = "Generic OAuth 2.0 with refresh tokens. Modern standard for secure authentication. Compatible with any API supporting OAuth 2.0.";
RELATE i18n_key:credential_type_oauth2_api_description->translation->language:it SET text = "OAuth 2.0 generico con refresh token. Standard moderno per autenticazione sicura. Compatibile con qualsiasi API che supporta OAuth 2.0.";
RELATE i18n_key:credential_type_oauth2_api_description->translation->language:de SET text = "Generisches OAuth 2.0 mit Refresh-Tokens. Moderner Standard für sichere Authentifizierung. Kompatibel mit jeder API, die OAuth 2.0 unterstützt.";
RELATE i18n_key:credential_type_oauth2_api_description->translation->language:es SET text = "OAuth 2.0 genérico con refresh tokens. Estándar moderno para autenticación segura. Compatible con cualquier API que soporte OAuth 2.0.";

RELATE i18n_key:credential_type_oauth2_api_tooltip->translation->language:fr SET text = "✅ Recommandé - Standard de l'industrie";
RELATE i18n_key:credential_type_oauth2_api_tooltip->translation->language:en SET text = "✅ Recommended - Industry standard";
RELATE i18n_key:credential_type_oauth2_api_tooltip->translation->language:it SET text = "✅ Consigliato - Standard industriale";
RELATE i18n_key:credential_type_oauth2_api_tooltip->translation->language:de SET text = "✅ Empfohlen - Industriestandard";
RELATE i18n_key:credential_type_oauth2_api_tooltip->translation->language:es SET text = "✅ Recomendado - Estándar de la industria";

-- =============================================================================================

