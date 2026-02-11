import { useAuthStore } from '../store/auth.store';
import { useToastStore } from '../store/toast.store';

const BASE_URL = '/api/v1';

interface RequestOptions extends RequestInit {
    headers?: Record<string, string>;
}

async function request<T>(endpoint: string, options: RequestOptions = {}): Promise<T> {
    const { token } = useAuthStore.getState();

    const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        ...options.headers,
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    try {
        const response = await fetch(`${BASE_URL}${endpoint}`, {
            ...options,
            headers,
        });

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            const errorMessage = errorData.error || errorData.message || `HTTP Error ${response.status}`;

            // Handle 401 Unauthorized
            if (response.status === 401) {
                useAuthStore.getState().logout();
            }

            throw new Error(errorMessage);
        }

        // Handle 204 No Content
        if (response.status === 204) {
            return {} as T;
        }

        return await response.json();
    } catch (error: any) {
        useToastStore.getState().addToast({
            message: error.message || 'Network error',
            type: 'error',
        });
        throw error;
    }
}

export const api = {
    get: <T>(endpoint: string, options?: RequestOptions) => request<T>(endpoint, { ...options, method: 'GET' }),
    post: <T>(endpoint: string, body: any, options?: RequestOptions) => request<T>(endpoint, { ...options, method: 'POST', body: JSON.stringify(body) }),
    put: <T>(endpoint: string, body: any, options?: RequestOptions) => request<T>(endpoint, { ...options, method: 'PUT', body: JSON.stringify(body) }),
    delete: <T>(endpoint: string, options?: RequestOptions) => request<T>(endpoint, { ...options, method: 'DELETE' }),
};
