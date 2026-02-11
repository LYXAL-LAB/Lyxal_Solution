import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { api } from '../lib/api';

interface User {
    id: string;
    email: string;
    name: string;
    isAdmin: boolean;
}

interface AuthState {
    user: User | null;
    token: string | null;
    loading: boolean;
    initialized: boolean;
    isAuthenticated: boolean;
    isAdmin: boolean;
    checkAuth: () => Promise<void>;
    fetchCurrentUser: () => Promise<void>;
    login: (user: User, token: string) => void;
    logout: () => Promise<void>;
    setUser: (user: User) => void;
}

export const useAuthStore = create<AuthState>()(
    persist(
        (set, get) => ({
            user: null,
            token: null,
            loading: false,
            initialized: false,
            isAuthenticated: false,
            isAdmin: false,

            checkAuth: async () => {
                if (get().initialized) return;

                set({ loading: true });
                try {
                    const response = await api.get<{ data: User }>('/users/me');
                    set({
                        user: response.data,
                        isAuthenticated: true,
                        isAdmin: response.data.isAdmin,
                        initialized: true,
                        loading: false,
                    });
                } catch (error) {
                    set({
                        user: null,
                        isAuthenticated: false,
                        isAdmin: false,
                        initialized: true,
                        loading: false,
                    });
                }
            },

            fetchCurrentUser: async () => {
                try {
                    const response = await api.get<{ data: User }>('/users/me');
                    set({
                        user: response.data,
                        isAuthenticated: true,
                        isAdmin: response.data.isAdmin,
                    });
                } catch (error) {
                    console.error('Failed to fetch user info:', error);
                }
            },

            login: (user, token) => set({
                user,
                token,
                isAuthenticated: true,
                isAdmin: user.isAdmin,
            }),

            logout: async () => {
                try {
                    const response = await api.get<{ redirectUrl?: string }>('/auth/logout');
                    set({
                        user: null,
                        token: null,
                        isAuthenticated: false,
                        isAdmin: false,
                    });

                    if (response.redirectUrl) {
                        window.location.href = response.redirectUrl;
                    } else {
                        window.location.href = '/';
                    }
                } catch (error) {
                    console.error('Logout failed:', error);
                    set({
                        user: null,
                        token: null,
                        isAuthenticated: false,
                        isAdmin: false,
                    });
                    window.location.href = '/';
                }
            },

            setUser: (user) => set({
                user,
                isAuthenticated: true,
                isAdmin: user.isAdmin,
            }),
        }),
        {
            name: 'auth-storage',
        }
    )
);
