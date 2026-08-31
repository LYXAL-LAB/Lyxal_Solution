/**
 * 🏛️ LYXAL OS — Infrastructure Client SDK Central
 * 
 * Client HTTP centralisé avec gestion automatique de l'authentification Bearer/Cookie,
 * extraction du jeton CSRF, parsing d'erreurs typées ApiErrorBody, timeouts et multipart.
 */

export interface ApiErrorBody {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export class ApiError extends Error {
  public status: number;
  public code: string;
  public details?: Record<string, unknown>;

  constructor(status: number, code: string, message: string, details?: Record<string, unknown>) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export interface RequestOptions extends RequestInit {
  timeoutMs?: number;
  params?: Record<string, string | number | boolean | undefined | null>;
}

export class HttpClient {
  private baseUrl: string;
  private defaultHeaders: Record<string, string>;

  constructor(baseUrl: string = '/api/v1', defaultHeaders: Record<string, string> = {}) {
    this.baseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
    this.defaultHeaders = {
      'Accept': 'application/json',
      ...defaultHeaders,
    };
  }

  /**
   * Extrait le jeton CSRF depuis les cookies du navigateur si présent
   */
  private getCsrfToken(): string | null {
    if (typeof document === 'undefined') return null;
    const match = document.cookie.match(/(?:^|; )\s*(?:csrf_token|_csrf|XSRF-TOKEN)\s*=\s*([^;]+)/);
    return match ? decodeURIComponent(match[1]) : null;
  }

  /**
   * Définit dynamiquement le jeton d'authentification Bearer
   */
  public setAuthToken(token: string | null): void {
    if (token) {
      this.defaultHeaders['Authorization'] = `Bearer ${token}`;
    } else {
      delete this.defaultHeaders['Authorization'];
    }
  }

  /**
   * Effectue une requête HTTP générique typée avec gestion des timeouts et erreurs
   */
  public async request<T>(endpoint: string, options: RequestOptions = {}): Promise<T> {
    const { timeoutMs = 15000, params, headers, body, method = 'GET', ...customConfig } = options;

    // Construction de l'URL avec query parameters
    let url = `${this.baseUrl}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;
    if (params) {
      const searchParams = new URLSearchParams();
      Object.entries(params).forEach(([key, val]) => {
        if (val !== undefined && val !== null) {
          searchParams.append(key, String(val));
        }
      });
      const queryString = searchParams.toString();
      if (queryString) {
        url += `?${queryString}`;
      }
    }

    // Gestion du Controller d'annulation et du Timeout
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeoutMs);

    const isFormData = typeof FormData !== 'undefined' && body instanceof FormData;
    const requestHeaders: Record<string, string> = {
      ...this.defaultHeaders,
      ...(headers as Record<string, string>),
    };

    // Ajout automatique du jeton CSRF pour les mutations
    if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(method.toUpperCase())) {
      const csrf = this.getCsrfToken();
      if (csrf && !requestHeaders['X-CSRF-Token']) {
        requestHeaders['X-CSRF-Token'] = csrf;
      }
    }

    if (!isFormData && body && typeof body === 'object') {
      requestHeaders['Content-Type'] = 'application/json';
    }

    try {
      const response = await fetch(url, {
        ...customConfig,
        method,
        credentials: customConfig.credentials || 'same-origin',
        headers: requestHeaders,
        body: isFormData ? (body as FormData) : body ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });

      // Traitement du statut d'erreur HTTP (4xx / 5xx)
      if (!response.ok) {
        let errorData: ApiErrorBody = {
          code: 'HTTP_ERROR',
          message: `HTTP Request failed with status ${response.status}`,
        };
        try {
          const json = await response.json();
          if (json && (json.code || json.message)) {
            errorData = json as ApiErrorBody;
          }
        } catch {
          // Fallback si le corps de réponse n'est pas du JSON
        }
        throw new ApiError(response.status, errorData.code, errorData.message, errorData.details);
      }

      // Réponse vide 204 No Content
      if (response.status === 204) {
        return {} as T;
      }

      return (await response.json()) as T;
    } catch (err: unknown) {
      if (err instanceof ApiError) {
        throw err;
      }
      if (err instanceof Error && err.name === 'AbortError') {
        throw new ApiError(408, 'REQUEST_TIMEOUT', `Request timed out after ${timeoutMs}ms`);
      }
      throw new ApiError(500, 'NETWORK_ERROR', err instanceof Error ? err.message : 'Unknown network failure');
    } finally {
      clearTimeout(id);
    }
  }

  public get<T>(endpoint: string, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'GET' });
  }

  public post<T>(endpoint: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'POST', body: body as BodyInit });
  }

  public put<T>(endpoint: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'PUT', body: body as BodyInit });
  }

  public patch<T>(endpoint: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'PATCH', body: body as BodyInit });
  }

  public delete<T>(endpoint: string, options?: RequestOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'DELETE' });
  }
}

export const httpClient = new HttpClient('/api/v1');
