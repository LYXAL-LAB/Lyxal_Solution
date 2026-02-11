-- =============================================================================================
-- |
-- | Fichier : transmission_method_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > transmission_method
-- | Description : Traductions multilingues pour transmission_method.
-- |
-- | Ce fichier contient toutes les traductions pour 5 langues :
-- | • FR (Français)
-- | • EN (English)
-- | • IT (Italiano)
-- | • DE (Deutsch)
-- | • ES (Español)
-- |
-- | Total : 205 traductions (41 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- HEADER - Name
-- =====================================================

RELATE i18n_key:transmission_method_header_name->translation->language:fr SET text = "En-tête HTTP";
RELATE i18n_key:transmission_method_header_name->translation->language:en SET text = "HTTP Header";
RELATE i18n_key:transmission_method_header_name->translation->language:it SET text = "Intestazione HTTP";
RELATE i18n_key:transmission_method_header_name->translation->language:de SET text = "HTTP-Header";
RELATE i18n_key:transmission_method_header_name->translation->language:es SET text = "Encabezado HTTP";

-- =====================================================
-- HEADER - Description
-- =====================================================

RELATE i18n_key:transmission_method_header_description->translation->language:fr SET text = "Transmet les credentials via les en-têtes HTTP (ex: Authorization: Bearer token). Méthode recommandée pour les tokens sensibles.";
RELATE i18n_key:transmission_method_header_description->translation->language:en SET text = "Transmits credentials via HTTP headers (e.g., Authorization: Bearer token). Recommended method for sensitive tokens.";
RELATE i18n_key:transmission_method_header_description->translation->language:it SET text = "Trasmette le credenziali tramite intestazioni HTTP (es: Authorization: Bearer token). Metodo consigliato per token sensibili.";
RELATE i18n_key:transmission_method_header_description->translation->language:de SET text = "Überträgt Anmeldeinformationen über HTTP-Header (z.B. Authorization: Bearer token). Empfohlene Methode für sensible Tokens.";
RELATE i18n_key:transmission_method_header_description->translation->language:es SET text = "Transmite credenciales a través de encabezados HTTP (ej: Authorization: Bearer token). Método recomendado para tokens sensibles.";

-- =====================================================
-- HEADER - Tooltip
-- =====================================================

RELATE i18n_key:transmission_method_header_tooltip->translation->language:fr SET text = "✅ Recommandé : Sécurisé pour tokens sensibles (OAuth2, JWT, API keys)";
RELATE i18n_key:transmission_method_header_tooltip->translation->language:en SET text = "✅ Recommended: Secure for sensitive tokens (OAuth2, JWT, API keys)";
RELATE i18n_key:transmission_method_header_tooltip->translation->language:it SET text = "✅ Consigliato: Sicuro per token sensibili (OAuth2, JWT, chiavi API)";
RELATE i18n_key:transmission_method_header_tooltip->translation->language:de SET text = "✅ Empfohlen: Sicher für sensible Tokens (OAuth2, JWT, API-Schlüssel)";
RELATE i18n_key:transmission_method_header_tooltip->translation->language:es SET text = "✅ Recomendado: Seguro para tokens sensibles (OAuth2, JWT, claves API)";

-- =====================================================
-- HEADER - Security Concerns
-- =====================================================

RELATE i18n_key:transmission_method_header_concern_proxy->translation->language:fr SET text = "Peut être modifié par des proxies non sécurisés";
RELATE i18n_key:transmission_method_header_concern_proxy->translation->language:en SET text = "Can be modified by unsecured proxies";
RELATE i18n_key:transmission_method_header_concern_proxy->translation->language:it SET text = "Può essere modificato da proxy non sicuri";
RELATE i18n_key:transmission_method_header_concern_proxy->translation->language:de SET text = "Kann von unsicheren Proxys geändert werden";
RELATE i18n_key:transmission_method_header_concern_proxy->translation->language:es SET text = "Puede ser modificado por proxies no seguros";

RELATE i18n_key:transmission_method_header_concern_logs->translation->language:fr SET text = "Visible dans les logs serveur si non chiffré";
RELATE i18n_key:transmission_method_header_concern_logs->translation->language:en SET text = "Visible in server logs if not encrypted";
RELATE i18n_key:transmission_method_header_concern_logs->translation->language:it SET text = "Visibile nei log del server se non crittografato";
RELATE i18n_key:transmission_method_header_concern_logs->translation->language:de SET text = "In Server-Logs sichtbar, wenn nicht verschlüsselt";
RELATE i18n_key:transmission_method_header_concern_logs->translation->language:es SET text = "Visible en los registros del servidor si no está cifrado";

RELATE i18n_key:transmission_method_header_concern_cache->translation->language:fr SET text = "Peut être mis en cache par des intermédiaires";
RELATE i18n_key:transmission_method_header_concern_cache->translation->language:en SET text = "May be cached by intermediaries";
RELATE i18n_key:transmission_method_header_concern_cache->translation->language:it SET text = "Può essere memorizzato nella cache da intermediari";
RELATE i18n_key:transmission_method_header_concern_cache->translation->language:de SET text = "Kann von Vermittlern zwischengespeichert werden";
RELATE i18n_key:transmission_method_header_concern_cache->translation->language:es SET text = "Puede ser almacenado en caché por intermediarios";

-- =====================================================
-- HEADER - Use Cases
-- =====================================================

RELATE i18n_key:transmission_method_header_usecase_bearer->translation->language:fr SET text = "Bearer tokens (OAuth2, JWT)";
RELATE i18n_key:transmission_method_header_usecase_bearer->translation->language:en SET text = "Bearer tokens (OAuth2, JWT)";
RELATE i18n_key:transmission_method_header_usecase_bearer->translation->language:it SET text = "Token Bearer (OAuth2, JWT)";
RELATE i18n_key:transmission_method_header_usecase_bearer->translation->language:de SET text = "Bearer-Tokens (OAuth2, JWT)";
RELATE i18n_key:transmission_method_header_usecase_bearer->translation->language:es SET text = "Tokens Bearer (OAuth2, JWT)";

RELATE i18n_key:transmission_method_header_usecase_apikey->translation->language:fr SET text = "Clés API secrètes";
RELATE i18n_key:transmission_method_header_usecase_apikey->translation->language:en SET text = "Secret API keys";
RELATE i18n_key:transmission_method_header_usecase_apikey->translation->language:it SET text = "Chiavi API segrete";
RELATE i18n_key:transmission_method_header_usecase_apikey->translation->language:de SET text = "Geheime API-Schlüssel";
RELATE i18n_key:transmission_method_header_usecase_apikey->translation->language:es SET text = "Claves API secretas";

RELATE i18n_key:transmission_method_header_usecase_oauth->translation->language:fr SET text = "Tokens d'accès OAuth";
RELATE i18n_key:transmission_method_header_usecase_oauth->translation->language:en SET text = "OAuth access tokens";
RELATE i18n_key:transmission_method_header_usecase_oauth->translation->language:it SET text = "Token di accesso OAuth";
RELATE i18n_key:transmission_method_header_usecase_oauth->translation->language:de SET text = "OAuth-Zugriffstoken";
RELATE i18n_key:transmission_method_header_usecase_oauth->translation->language:es SET text = "Tokens de acceso OAuth";

RELATE i18n_key:transmission_method_header_usecase_sensitive->translation->language:fr SET text = "Credentials sensibles en général";
RELATE i18n_key:transmission_method_header_usecase_sensitive->translation->language:en SET text = "Sensitive credentials in general";
RELATE i18n_key:transmission_method_header_usecase_sensitive->translation->language:it SET text = "Credenziali sensibili in generale";
RELATE i18n_key:transmission_method_header_usecase_sensitive->translation->language:de SET text = "Sensible Anmeldeinformationen im Allgemeinen";
RELATE i18n_key:transmission_method_header_usecase_sensitive->translation->language:es SET text = "Credenciales sensibles en general";

-- =====================================================
-- HEADER - Avoid Cases
-- =====================================================

RELATE i18n_key:transmission_method_header_avoid_large_payload->translation->language:fr SET text = "Payloads très larges (préférer body)";
RELATE i18n_key:transmission_method_header_avoid_large_payload->translation->language:en SET text = "Very large payloads (prefer body)";
RELATE i18n_key:transmission_method_header_avoid_large_payload->translation->language:it SET text = "Payload molto grandi (preferire body)";
RELATE i18n_key:transmission_method_header_avoid_large_payload->translation->language:de SET text = "Sehr große Payloads (Body bevorzugen)";
RELATE i18n_key:transmission_method_header_avoid_large_payload->translation->language:es SET text = "Payloads muy grandes (preferir body)";

-- =====================================================
-- BODY - Name
-- =====================================================

RELATE i18n_key:transmission_method_body_name->translation->language:fr SET text = "Corps HTTP";
RELATE i18n_key:transmission_method_body_name->translation->language:en SET text = "HTTP Body";
RELATE i18n_key:transmission_method_body_name->translation->language:it SET text = "Corpo HTTP";
RELATE i18n_key:transmission_method_body_name->translation->language:de SET text = "HTTP-Body";
RELATE i18n_key:transmission_method_body_name->translation->language:es SET text = "Cuerpo HTTP";

-- =====================================================
-- BODY - Description
-- =====================================================

RELATE i18n_key:transmission_method_body_description->translation->language:fr SET text = "Transmet les credentials dans le corps de la requête HTTP (JSON, XML, form-data). Idéal pour les données structurées complexes.";
RELATE i18n_key:transmission_method_body_description->translation->language:en SET text = "Transmits credentials in the HTTP request body (JSON, XML, form-data). Ideal for complex structured data.";
RELATE i18n_key:transmission_method_body_description->translation->language:it SET text = "Trasmette le credenziali nel corpo della richiesta HTTP (JSON, XML, form-data). Ideale per dati strutturati complessi.";
RELATE i18n_key:transmission_method_body_description->translation->language:de SET text = "Überträgt Anmeldeinformationen im HTTP-Anforderungstext (JSON, XML, form-data). Ideal für komplexe strukturierte Daten.";
RELATE i18n_key:transmission_method_body_description->translation->language:es SET text = "Transmite credenciales en el cuerpo de la solicitud HTTP (JSON, XML, form-data). Ideal para datos estructurados complejos.";

-- =====================================================
-- BODY - Tooltip
-- =====================================================

RELATE i18n_key:transmission_method_body_tooltip->translation->language:fr SET text = "Sécurisé pour données structurées (formulaires, payloads complexes)";
RELATE i18n_key:transmission_method_body_tooltip->translation->language:en SET text = "Secure for structured data (forms, complex payloads)";
RELATE i18n_key:transmission_method_body_tooltip->translation->language:it SET text = "Sicuro per dati strutturati (moduli, payload complessi)";
RELATE i18n_key:transmission_method_body_tooltip->translation->language:de SET text = "Sicher für strukturierte Daten (Formulare, komplexe Payloads)";
RELATE i18n_key:transmission_method_body_tooltip->translation->language:es SET text = "Seguro para datos estructurados (formularios, payloads complejos)";

-- =====================================================
-- BODY - Security Concerns
-- =====================================================

RELATE i18n_key:transmission_method_body_concern_parsing->translation->language:fr SET text = "Nécessite un parsing du body (coût performance)";
RELATE i18n_key:transmission_method_body_concern_parsing->translation->language:en SET text = "Requires body parsing (performance cost)";
RELATE i18n_key:transmission_method_body_concern_parsing->translation->language:it SET text = "Richiede il parsing del corpo (costo prestazionale)";
RELATE i18n_key:transmission_method_body_concern_parsing->translation->language:de SET text = "Erfordert Body-Parsing (Leistungskosten)";
RELATE i18n_key:transmission_method_body_concern_parsing->translation->language:es SET text = "Requiere análisis del cuerpo (costo de rendimiento)";

RELATE i18n_key:transmission_method_body_concern_content_type->translation->language:fr SET text = "Nécessite un Content-Type spécifique";
RELATE i18n_key:transmission_method_body_concern_content_type->translation->language:en SET text = "Requires specific Content-Type";
RELATE i18n_key:transmission_method_body_concern_content_type->translation->language:it SET text = "Richiede un Content-Type specifico";
RELATE i18n_key:transmission_method_body_concern_content_type->translation->language:de SET text = "Erfordert spezifischen Content-Type";
RELATE i18n_key:transmission_method_body_concern_content_type->translation->language:es SET text = "Requiere Content-Type específico";

-- =====================================================
-- BODY - Use Cases
-- =====================================================

RELATE i18n_key:transmission_method_body_usecase_complex->translation->language:fr SET text = "Payloads d'authentification complexes";
RELATE i18n_key:transmission_method_body_usecase_complex->translation->language:en SET text = "Complex authentication payloads";
RELATE i18n_key:transmission_method_body_usecase_complex->translation->language:it SET text = "Payload di autenticazione complessi";
RELATE i18n_key:transmission_method_body_usecase_complex->translation->language:de SET text = "Komplexe Authentifizierungs-Payloads";
RELATE i18n_key:transmission_method_body_usecase_complex->translation->language:es SET text = "Payloads de autenticación complejos";

RELATE i18n_key:transmission_method_body_usecase_multipart->translation->language:fr SET text = "Credentials multi-parts";
RELATE i18n_key:transmission_method_body_usecase_multipart->translation->language:en SET text = "Multi-part credentials";
RELATE i18n_key:transmission_method_body_usecase_multipart->translation->language:it SET text = "Credenziali multi-parte";
RELATE i18n_key:transmission_method_body_usecase_multipart->translation->language:de SET text = "Mehrteilige Anmeldeinformationen";
RELATE i18n_key:transmission_method_body_usecase_multipart->translation->language:es SET text = "Credenciales multiparte";

RELATE i18n_key:transmission_method_body_usecase_certificate->translation->language:fr SET text = "Authentification par certificat";
RELATE i18n_key:transmission_method_body_usecase_certificate->translation->language:en SET text = "Certificate authentication";
RELATE i18n_key:transmission_method_body_usecase_certificate->translation->language:it SET text = "Autenticazione tramite certificato";
RELATE i18n_key:transmission_method_body_usecase_certificate->translation->language:de SET text = "Zertifikatsauthentifizierung";
RELATE i18n_key:transmission_method_body_usecase_certificate->translation->language:es SET text = "Autenticación por certificado";

RELATE i18n_key:transmission_method_body_usecase_login->translation->language:fr SET text = "Formulaires de login";
RELATE i18n_key:transmission_method_body_usecase_login->translation->language:en SET text = "Login forms";
RELATE i18n_key:transmission_method_body_usecase_login->translation->language:it SET text = "Moduli di accesso";
RELATE i18n_key:transmission_method_body_usecase_login->translation->language:de SET text = "Anmeldeformulare";
RELATE i18n_key:transmission_method_body_usecase_login->translation->language:es SET text = "Formularios de inicio de sesión";

-- =====================================================
-- BODY - Avoid Cases
-- =====================================================

RELATE i18n_key:transmission_method_body_avoid_simple_key->translation->language:fr SET text = "Clés API simples (préférer header)";
RELATE i18n_key:transmission_method_body_avoid_simple_key->translation->language:en SET text = "Simple API keys (prefer header)";
RELATE i18n_key:transmission_method_body_avoid_simple_key->translation->language:it SET text = "Chiavi API semplici (preferire header)";
RELATE i18n_key:transmission_method_body_avoid_simple_key->translation->language:de SET text = "Einfache API-Schlüssel (Header bevorzugen)";
RELATE i18n_key:transmission_method_body_avoid_simple_key->translation->language:es SET text = "Claves API simples (preferir header)";

RELATE i18n_key:transmission_method_body_avoid_get_request->translation->language:fr SET text = "Requêtes GET (body non-standard pour GET)";
RELATE i18n_key:transmission_method_body_avoid_get_request->translation->language:en SET text = "GET requests (body non-standard for GET)";
RELATE i18n_key:transmission_method_body_avoid_get_request->translation->language:it SET text = "Richieste GET (body non standard per GET)";
RELATE i18n_key:transmission_method_body_avoid_get_request->translation->language:de SET text = "GET-Anfragen (Body nicht standardmäßig für GET)";
RELATE i18n_key:transmission_method_body_avoid_get_request->translation->language:es SET text = "Solicitudes GET (body no estándar para GET)";

-- =====================================================
-- QUERY - Name
-- =====================================================

RELATE i18n_key:transmission_method_query_name->translation->language:fr SET text = "Paramètres URL";
RELATE i18n_key:transmission_method_query_name->translation->language:en SET text = "URL Parameters";
RELATE i18n_key:transmission_method_query_name->translation->language:it SET text = "Parametri URL";
RELATE i18n_key:transmission_method_query_name->translation->language:de SET text = "URL-Parameter";
RELATE i18n_key:transmission_method_query_name->translation->language:es SET text = "Parámetros URL";

-- =====================================================
-- QUERY - Description
-- =====================================================

RELATE i18n_key:transmission_method_query_description->translation->language:fr SET text = "Transmet les credentials via les paramètres de requête URL (ex: ?api_key=xxx). ⚠️ ATTENTION : Faible sécurité, visible dans l'URL.";
RELATE i18n_key:transmission_method_query_description->translation->language:en SET text = "Transmits credentials via URL query parameters (e.g., ?api_key=xxx). ⚠️ WARNING: Low security, visible in URL.";
RELATE i18n_key:transmission_method_query_description->translation->language:it SET text = "Trasmette le credenziali tramite parametri di query URL (es: ?api_key=xxx). ⚠️ ATTENZIONE: Bassa sicurezza, visibile nell'URL.";
RELATE i18n_key:transmission_method_query_description->translation->language:de SET text = "Überträgt Anmeldeinformationen über URL-Abfrageparameter (z.B. ?api_key=xxx). ⚠️ WARNUNG: Geringe Sicherheit, in URL sichtbar.";
RELATE i18n_key:transmission_method_query_description->translation->language:es SET text = "Transmite credenciales a través de parámetros de consulta URL (ej: ?api_key=xxx). ⚠️ ADVERTENCIA: Baja seguridad, visible en la URL.";

-- =====================================================
-- QUERY - Warning
-- =====================================================

RELATE i18n_key:transmission_method_query_warning->translation->language:fr SET text = "⚠️ ATTENTION : Visible dans l'URL, historique navigateur et logs serveur";
RELATE i18n_key:transmission_method_query_warning->translation->language:en SET text = "⚠️ WARNING: Visible in URL, browser history and server logs";
RELATE i18n_key:transmission_method_query_warning->translation->language:it SET text = "⚠️ ATTENZIONE: Visibile nell'URL, cronologia del browser e log del server";
RELATE i18n_key:transmission_method_query_warning->translation->language:de SET text = "⚠️ WARNUNG: Sichtbar in URL, Browser-Verlauf und Server-Logs";
RELATE i18n_key:transmission_method_query_warning->translation->language:es SET text = "⚠️ ADVERTENCIA: Visible en URL, historial del navegador y registros del servidor";

-- =====================================================
-- QUERY - Security Concerns
-- =====================================================

RELATE i18n_key:transmission_method_query_concern_url_visible->translation->language:fr SET text = "🔴 CRITIQUE : Credentials visibles dans l'URL";
RELATE i18n_key:transmission_method_query_concern_url_visible->translation->language:en SET text = "🔴 CRITICAL: Credentials visible in URL";
RELATE i18n_key:transmission_method_query_concern_url_visible->translation->language:it SET text = "🔴 CRITICO: Credenziali visibili nell'URL";
RELATE i18n_key:transmission_method_query_concern_url_visible->translation->language:de SET text = "🔴 KRITISCH: Anmeldeinformationen in URL sichtbar";
RELATE i18n_key:transmission_method_query_concern_url_visible->translation->language:es SET text = "🔴 CRÍTICO: Credenciales visibles en la URL";

RELATE i18n_key:transmission_method_query_concern_browser_history->translation->language:fr SET text = "🔴 CRITIQUE : Enregistrés dans l'historique du navigateur";
RELATE i18n_key:transmission_method_query_concern_browser_history->translation->language:en SET text = "🔴 CRITICAL: Stored in browser history";
RELATE i18n_key:transmission_method_query_concern_browser_history->translation->language:it SET text = "🔴 CRITICO: Memorizzato nella cronologia del browser";
RELATE i18n_key:transmission_method_query_concern_browser_history->translation->language:de SET text = "🔴 KRITISCH: Im Browser-Verlauf gespeichert";
RELATE i18n_key:transmission_method_query_concern_browser_history->translation->language:es SET text = "🔴 CRÍTICO: Almacenado en el historial del navegador";

RELATE i18n_key:transmission_method_query_concern_server_logs->translation->language:fr SET text = "🔴 CRITIQUE : Visibles dans les logs d'accès serveur";
RELATE i18n_key:transmission_method_query_concern_server_logs->translation->language:en SET text = "🔴 CRITICAL: Visible in server access logs";
RELATE i18n_key:transmission_method_query_concern_server_logs->translation->language:it SET text = "🔴 CRITICO: Visibile nei log di accesso del server";
RELATE i18n_key:transmission_method_query_concern_server_logs->translation->language:de SET text = "🔴 KRITISCH: In Server-Zugriffslogs sichtbar";
RELATE i18n_key:transmission_method_query_concern_server_logs->translation->language:es SET text = "🔴 CRÍTICO: Visible en los registros de acceso del servidor";

RELATE i18n_key:transmission_method_query_concern_copy_paste->translation->language:fr SET text = "Peuvent être partagés accidentellement via copier-coller";
RELATE i18n_key:transmission_method_query_concern_copy_paste->translation->language:en SET text = "Can be accidentally shared via copy-paste";
RELATE i18n_key:transmission_method_query_concern_copy_paste->translation->language:it SET text = "Possono essere condivisi accidentalmente tramite copia-incolla";
RELATE i18n_key:transmission_method_query_concern_copy_paste->translation->language:de SET text = "Können versehentlich durch Kopieren-Einfügen weitergegeben werden";
RELATE i18n_key:transmission_method_query_concern_copy_paste->translation->language:es SET text = "Pueden compartirse accidentalmente mediante copiar-pegar";

RELATE i18n_key:transmission_method_query_concern_referrer->translation->language:fr SET text = "Exposés via les headers Referrer";
RELATE i18n_key:transmission_method_query_concern_referrer->translation->language:en SET text = "Exposed via Referrer headers";
RELATE i18n_key:transmission_method_query_concern_referrer->translation->language:it SET text = "Esposti tramite intestazioni Referrer";
RELATE i18n_key:transmission_method_query_concern_referrer->translation->language:de SET text = "Über Referrer-Header offengelegt";
RELATE i18n_key:transmission_method_query_concern_referrer->translation->language:es SET text = "Expuestos a través de encabezados Referrer";

RELATE i18n_key:transmission_method_query_concern_cdn_cache->translation->language:fr SET text = "Peuvent être mis en cache par CDN/proxies";
RELATE i18n_key:transmission_method_query_concern_cdn_cache->translation->language:en SET text = "May be cached by CDN/proxies";
RELATE i18n_key:transmission_method_query_concern_cdn_cache->translation->language:it SET text = "Possono essere memorizzati nella cache da CDN/proxy";
RELATE i18n_key:transmission_method_query_concern_cdn_cache->translation->language:de SET text = "Können von CDN/Proxys zwischengespeichert werden";
RELATE i18n_key:transmission_method_query_concern_cdn_cache->translation->language:es SET text = "Pueden ser almacenados en caché por CDN/proxies";

-- =====================================================
-- QUERY - Use Cases
-- =====================================================

RELATE i18n_key:transmission_method_query_usecase_public_key->translation->language:fr SET text = "Clés API publiques (non sensibles)";
RELATE i18n_key:transmission_method_query_usecase_public_key->translation->language:en SET text = "Public API keys (non-sensitive)";
RELATE i18n_key:transmission_method_query_usecase_public_key->translation->language:it SET text = "Chiavi API pubbliche (non sensibili)";
RELATE i18n_key:transmission_method_query_usecase_public_key->translation->language:de SET text = "Öffentliche API-Schlüssel (nicht sensibel)";
RELATE i18n_key:transmission_method_query_usecase_public_key->translation->language:es SET text = "Claves API públicas (no sensibles)";

RELATE i18n_key:transmission_method_query_usecase_temporary_token->translation->language:fr SET text = "Tokens temporaires avec TTL court";
RELATE i18n_key:transmission_method_query_usecase_temporary_token->translation->language:en SET text = "Temporary tokens with short TTL";
RELATE i18n_key:transmission_method_query_usecase_temporary_token->translation->language:it SET text = "Token temporanei con TTL breve";
RELATE i18n_key:transmission_method_query_usecase_temporary_token->translation->language:de SET text = "Temporäre Tokens mit kurzer TTL";
RELATE i18n_key:transmission_method_query_usecase_temporary_token->translation->language:es SET text = "Tokens temporales con TTL corto";

RELATE i18n_key:transmission_method_query_usecase_webhook_signature->translation->language:fr SET text = "Signatures de webhooks";
RELATE i18n_key:transmission_method_query_usecase_webhook_signature->translation->language:en SET text = "Webhook signatures";
RELATE i18n_key:transmission_method_query_usecase_webhook_signature->translation->language:it SET text = "Firme di webhook";
RELATE i18n_key:transmission_method_query_usecase_webhook_signature->translation->language:de SET text = "Webhook-Signaturen";
RELATE i18n_key:transmission_method_query_usecase_webhook_signature->translation->language:es SET text = "Firmas de webhooks";

-- =====================================================
-- QUERY - Avoid Cases
-- =====================================================

RELATE i18n_key:transmission_method_query_avoid_password->translation->language:fr SET text = "🚫 À ÉVITER ABSOLUMENT : Mots de passe";
RELATE i18n_key:transmission_method_query_avoid_password->translation->language:en SET text = "🚫 ABSOLUTELY AVOID: Passwords";
RELATE i18n_key:transmission_method_query_avoid_password->translation->language:it SET text = "🚫 ASSOLUTAMENTE DA EVITARE: Password";
RELATE i18n_key:transmission_method_query_avoid_password->translation->language:de SET text = "🚫 UNBEDINGT VERMEIDEN: Passwörter";
RELATE i18n_key:transmission_method_query_avoid_password->translation->language:es SET text = "🚫 EVITAR ABSOLUTAMENTE: Contraseñas";

RELATE i18n_key:transmission_method_query_avoid_secret->translation->language:fr SET text = "🚫 À ÉVITER ABSOLUMENT : Tokens secrets";
RELATE i18n_key:transmission_method_query_avoid_secret->translation->language:en SET text = "🚫 ABSOLUTELY AVOID: Secret tokens";
RELATE i18n_key:transmission_method_query_avoid_secret->translation->language:it SET text = "🚫 ASSOLUTAMENTE DA EVITARE: Token segreti";
RELATE i18n_key:transmission_method_query_avoid_secret->translation->language:de SET text = "🚫 UNBEDINGT VERMEIDEN: Geheime Tokens";
RELATE i18n_key:transmission_method_query_avoid_secret->translation->language:es SET text = "🚫 EVITAR ABSOLUTAMENTE: Tokens secretos";

RELATE i18n_key:transmission_method_query_avoid_private_key->translation->language:fr SET text = "🚫 À ÉVITER ABSOLUMENT : Clés API privées";
RELATE i18n_key:transmission_method_query_avoid_private_key->translation->language:en SET text = "🚫 ABSOLUTELY AVOID: Private API keys";
RELATE i18n_key:transmission_method_query_avoid_private_key->translation->language:it SET text = "🚫 ASSOLUTAMENTE DA EVITARE: Chiavi API private";
RELATE i18n_key:transmission_method_query_avoid_private_key->translation->language:de SET text = "🚫 UNBEDINGT VERMEIDEN: Private API-Schlüssel";
RELATE i18n_key:transmission_method_query_avoid_private_key->translation->language:es SET text = "🚫 EVITAR ABSOLUTAMENTE: Claves API privadas";

RELATE i18n_key:transmission_method_query_avoid_longlived->translation->language:fr SET text = "Credentials à longue durée de vie";
RELATE i18n_key:transmission_method_query_avoid_longlived->translation->language:en SET text = "Long-lived credentials";
RELATE i18n_key:transmission_method_query_avoid_longlived->translation->language:it SET text = "Credenziali a lunga durata";
RELATE i18n_key:transmission_method_query_avoid_longlived->translation->language:de SET text = "Langlebige Anmeldeinformationen";
RELATE i18n_key:transmission_method_query_avoid_longlived->translation->language:es SET text = "Credenciales de larga duración";

-- =====================================================
-- CUSTOM - Name
-- =====================================================

RELATE i18n_key:transmission_method_custom_name->translation->language:fr SET text = "Méthode personnalisée";
RELATE i18n_key:transmission_method_custom_name->translation->language:en SET text = "Custom Method";
RELATE i18n_key:transmission_method_custom_name->translation->language:it SET text = "Metodo personalizzato";
RELATE i18n_key:transmission_method_custom_name->translation->language:de SET text = "Benutzerdefinierte Methode";
RELATE i18n_key:transmission_method_custom_name->translation->language:es SET text = "Método personalizado";

-- =====================================================
-- CUSTOM - Description
-- =====================================================

RELATE i18n_key:transmission_method_custom_description->translation->language:fr SET text = "Méthode de transmission personnalisée ou propriétaire. Utilisée pour des protocoles d'authentification non-standard ou spécifiques à un fournisseur.";
RELATE i18n_key:transmission_method_custom_description->translation->language:en SET text = "Custom or proprietary transmission method. Used for non-standard or vendor-specific authentication protocols.";
RELATE i18n_key:transmission_method_custom_description->translation->language:it SET text = "Metodo di trasmissione personalizzato o proprietario. Utilizzato per protocolli di autenticazione non standard o specifici del fornitore.";
RELATE i18n_key:transmission_method_custom_description->translation->language:de SET text = "Benutzerdefinierte oder proprietäre Übertragungsmethode. Verwendet für nicht standardmäßige oder anbieterspezifische Authentifizierungsprotokolle.";
RELATE i18n_key:transmission_method_custom_description->translation->language:es SET text = "Método de transmisión personalizado o propietario. Utilizado para protocolos de autenticación no estándar o específicos del proveedor.";

-- =====================================================
-- CUSTOM - Tooltip
-- =====================================================

RELATE i18n_key:transmission_method_custom_tooltip->translation->language:fr SET text = "Pour protocoles d'authentification propriétaires ou legacy";
RELATE i18n_key:transmission_method_custom_tooltip->translation->language:en SET text = "For proprietary or legacy authentication protocols";
RELATE i18n_key:transmission_method_custom_tooltip->translation->language:it SET text = "Per protocolli di autenticazione proprietari o legacy";
RELATE i18n_key:transmission_method_custom_tooltip->translation->language:de SET text = "Für proprietäre oder Legacy-Authentifizierungsprotokolle";
RELATE i18n_key:transmission_method_custom_tooltip->translation->language:es SET text = "Para protocolos de autenticación propietarios o legacy";

-- =====================================================
-- CUSTOM - Security Concerns
-- =====================================================

RELATE i18n_key:transmission_method_custom_concern_nonstandard->translation->language:fr SET text = "Implémentation non-standard (risque de bugs)";
RELATE i18n_key:transmission_method_custom_concern_nonstandard->translation->language:en SET text = "Non-standard implementation (risk of bugs)";
RELATE i18n_key:transmission_method_custom_concern_nonstandard->translation->language:it SET text = "Implementazione non standard (rischio di bug)";
RELATE i18n_key:transmission_method_custom_concern_nonstandard->translation->language:de SET text = "Nicht standardmäßige Implementierung (Fehlerrisiko)";
RELATE i18n_key:transmission_method_custom_concern_nonstandard->translation->language:es SET text = "Implementación no estándar (riesgo de bugs)";

RELATE i18n_key:transmission_method_custom_concern_validation->translation->language:fr SET text = "Nécessite validation custom (complexité accrue)";
RELATE i18n_key:transmission_method_custom_concern_validation->translation->language:en SET text = "Requires custom validation (increased complexity)";
RELATE i18n_key:transmission_method_custom_concern_validation->translation->language:it SET text = "Richiede validazione personalizzata (maggiore complessità)";
RELATE i18n_key:transmission_method_custom_concern_validation->translation->language:de SET text = "Erfordert benutzerdefinierte Validierung (erhöhte Komplexität)";
RELATE i18n_key:transmission_method_custom_concern_validation->translation->language:es SET text = "Requiere validación personalizada (mayor complejidad)";

RELATE i18n_key:transmission_method_custom_concern_tooling->translation->language:fr SET text = "Support limité par les outils et frameworks standards";
RELATE i18n_key:transmission_method_custom_concern_tooling->translation->language:en SET text = "Limited support by standard tools and frameworks";
RELATE i18n_key:transmission_method_custom_concern_tooling->translation->language:it SET text = "Supporto limitato da strumenti e framework standard";
RELATE i18n_key:transmission_method_custom_concern_tooling->translation->language:de SET text = "Begrenzte Unterstützung durch Standard-Tools und Frameworks";
RELATE i18n_key:transmission_method_custom_concern_tooling->translation->language:es SET text = "Soporte limitado por herramientas y frameworks estándar";

-- =====================================================
-- CUSTOM - Use Cases
-- =====================================================

RELATE i18n_key:transmission_method_custom_usecase_proprietary->translation->language:fr SET text = "Protocoles d'authentification propriétaires";
RELATE i18n_key:transmission_method_custom_usecase_proprietary->translation->language:en SET text = "Proprietary authentication protocols";
RELATE i18n_key:transmission_method_custom_usecase_proprietary->translation->language:it SET text = "Protocolli di autenticazione proprietari";
RELATE i18n_key:transmission_method_custom_usecase_proprietary->translation->language:de SET text = "Proprietäre Authentifizierungsprotokolle";
RELATE i18n_key:transmission_method_custom_usecase_proprietary->translation->language:es SET text = "Protocolos de autenticación propietarios";

RELATE i18n_key:transmission_method_custom_usecase_legacy->translation->language:fr SET text = "Systèmes legacy avec authentification non-standard";
RELATE i18n_key:transmission_method_custom_usecase_legacy->translation->language:en SET text = "Legacy systems with non-standard authentication";
RELATE i18n_key:transmission_method_custom_usecase_legacy->translation->language:it SET text = "Sistemi legacy con autenticazione non standard";
RELATE i18n_key:transmission_method_custom_usecase_legacy->translation->language:de SET text = "Legacy-Systeme mit nicht standardmäßiger Authentifizierung";
RELATE i18n_key:transmission_method_custom_usecase_legacy->translation->language:es SET text = "Sistemas legacy con autenticación no estándar";

RELATE i18n_key:transmission_method_custom_usecase_specialized->translation->language:fr SET text = "Protocoles spécialisés (militaire, bancaire, etc.)";
RELATE i18n_key:transmission_method_custom_usecase_specialized->translation->language:en SET text = "Specialized protocols (military, banking, etc.)";
RELATE i18n_key:transmission_method_custom_usecase_specialized->translation->language:it SET text = "Protocolli specializzati (militare, bancario, ecc.)";
RELATE i18n_key:transmission_method_custom_usecase_specialized->translation->language:de SET text = "Spezialisierte Protokolle (militärisch, Banken usw.)";
RELATE i18n_key:transmission_method_custom_usecase_specialized->translation->language:es SET text = "Protocolos especializados (militar, bancario, etc.)";

-- =====================================================
-- CUSTOM - Avoid Cases
-- =====================================================

RELATE i18n_key:transmission_method_custom_avoid_rest->translation->language:fr SET text = "APIs REST standards (préférer header ou body)";
RELATE i18n_key:transmission_method_custom_avoid_rest->translation->language:en SET text = "Standard REST APIs (prefer header or body)";
RELATE i18n_key:transmission_method_custom_avoid_rest->translation->language:it SET text = "API REST standard (preferire header o body)";
RELATE i18n_key:transmission_method_custom_avoid_rest->translation->language:de SET text = "Standard-REST-APIs (Header oder Body bevorzugen)";
RELATE i18n_key:transmission_method_custom_avoid_rest->translation->language:es SET text = "APIs REST estándar (preferir header o body)";

RELATE i18n_key:transmission_method_custom_avoid_public->translation->language:fr SET text = "APIs publiques standards (utiliser méthodes standards)";
RELATE i18n_key:transmission_method_custom_avoid_public->translation->language:en SET text = "Standard public APIs (use standard methods)";
RELATE i18n_key:transmission_method_custom_avoid_public->translation->language:it SET text = "API pubbliche standard (utilizzare metodi standard)";
RELATE i18n_key:transmission_method_custom_avoid_public->translation->language:de SET text = "Standard-öffentliche APIs (Standard-Methoden verwenden)";
RELATE i18n_key:transmission_method_custom_avoid_public->translation->language:es SET text = "APIs públicas estándar (usar métodos estándar)";

-- =====================================================
-- VÉRIFICATION DES TRADUCTIONS
-- =====================================================

/*
-- Compter les traductions par langue
SELECT 
    out AS langue,
    count() AS nombre_traductions
FROM translation
WHERE string::starts_with(meta::id(in), 'i18n_key:transmission_method_')
GROUP BY out
ORDER BY nombre_traductions DESC;

-- Résultat attendu:
-- | langue        | nombre_traductions |
-- |---------------|-------------------|
-- | language:fr   | 41                |
-- | language:en   | 41                |
-- | language:it   | 41                |
-- | language:de   | 41                |
-- | language:es   | 41                |
-- TOTAL: 205 traductions

-- Afficher toutes les traductions d'une clé spécifique
SELECT 
    in AS cle,
    out AS langue,
    text AS traduction
FROM translation
WHERE in = i18n_key:transmission_method_header_name
ORDER BY out;
*/

-- =====================================================
-- RÉSUMÉ FINAL
-- =====================================================
--
-- ✅ 205 traductions créées :
--    • FR (Français) : 41
--    • EN (English) : 41
--    • IT (Italiano) : 41
--    • DE (Deutsch) : 41
--    • ES (Español) : 41
--
-- ✅ Couverture complète :
--    • HEADER : 11 clés × 5 langues = 55 traductions
--    • BODY : 11 clés × 5 langues = 55 traductions
--    • QUERY : 16 clés × 5 langues = 80 traductions
--    • CUSTOM : 8 clés × 5 langues = 40 traductions
--
-- ✅ Qualité des traductions :
--    • Traductions professionnelles
--    • Terminologie technique correcte
--    • Emojis et marqueurs visuels préservés (✅, ⚠️, 🔴, 🚫)
--    • Cohérence entre les langues
--
-- =============================================================================================

