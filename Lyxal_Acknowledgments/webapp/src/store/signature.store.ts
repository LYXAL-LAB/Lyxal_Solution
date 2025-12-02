import { create } from 'zustand';
import { api } from '../lib/api';
import { Signature } from '../components/SignatureList';

export interface SignatureStatus {
    docId: string;
    userEmail: string;
    isSigned: boolean;
    signedAt: string | null;
}

interface CreateSignatureRequest {
    docId: string;
    referer?: string;
}

interface SignatureState {
    userSignatures: Signature[];
    documentSignatures: Record<string, Signature[]>;
    signatureStatuses: Record<string, SignatureStatus>;
    loading: boolean;
    error: string | null;

    createSignature: (request: CreateSignatureRequest) => Promise<Signature>;
    fetchUserSignatures: () => Promise<void>;
    fetchDocumentSignatures: (docId: string) => Promise<Signature[]>;
    fetchSignatureStatus: (docId: string) => Promise<SignatureStatus>;
    checkUserSigned: (docId: string) => Promise<boolean>;
    clearError: () => void;
    clearCache: () => void;
}

export const useSignatureStore = create<SignatureState>((set, get) => ({
    userSignatures: [],
    documentSignatures: {},
    signatureStatuses: {},
    loading: false,
    error: null,

    createSignature: async (request) => {
        set({ loading: true, error: null });
        try {
            const signature = await api.post<Signature>('/signatures', request);

            set((state) => {
                const newUserSignatures = state.userSignatures.find(s => s.id === signature.id)
                    ? state.userSignatures
                    : [signature, ...state.userSignatures];

                const currentDocSigs = state.documentSignatures[request.docId] || [];
                const newDocSigs = currentDocSigs.find(s => s.id === signature.id)
                    ? currentDocSigs
                    : [signature, ...currentDocSigs];

                return {
                    userSignatures: newUserSignatures,
                    documentSignatures: {
                        ...state.documentSignatures,
                        [request.docId]: newDocSigs
                    },
                    signatureStatuses: {
                        ...state.signatureStatuses,
                        [request.docId]: {
                            docId: signature.docId,
                            userEmail: signature.userEmail,
                            isSigned: true,
                            signedAt: signature.signedAt,
                        }
                    },
                    loading: false
                };
            });

            return signature;
        } catch (err: any) {
            const message = err.response?.data?.error?.message || 'Failed to create signature';
            set({ error: message, loading: false });
            throw err;
        }
    },

    fetchUserSignatures: async () => {
        set({ loading: true, error: null });
        try {
            const signatures = await api.get<Signature[]>('/signatures/me');
            set({ userSignatures: signatures, loading: false });
        } catch (err: any) {
            const message = err.response?.data?.error?.message || 'Failed to fetch signatures';
            set({ error: message, loading: false });
            throw err;
        }
    },

    fetchDocumentSignatures: async (docId: string) => {
        set({ loading: true, error: null });
        try {
            const signatures = await api.get<Signature[]>(`/signatures/doc/${docId}`);
            set((state) => ({
                documentSignatures: {
                    ...state.documentSignatures,
                    [docId]: signatures
                },
                loading: false
            }));
            return signatures;
        } catch (err: any) {
            const message = err.response?.data?.error?.message || 'Failed to fetch document signatures';
            set({ error: message, loading: false });
            throw err;
        }
    },

    fetchSignatureStatus: async (docId: string) => {
        set({ loading: true, error: null });
        try {
            const status = await api.get<SignatureStatus>(`/signatures/status/${docId}`);
            set((state) => ({
                signatureStatuses: {
                    ...state.signatureStatuses,
                    [docId]: status
                },
                loading: false
            }));
            return status;
        } catch (err: any) {
            const message = err.response?.data?.error?.message || 'Failed to fetch signature status';
            set({ error: message, loading: false });
            throw err;
        }
    },

    checkUserSigned: async (docId: string) => {
        try {
            const status = await get().fetchSignatureStatus(docId);
            return status.isSigned;
        } catch (err) {
            return false;
        }
    },

    clearError: () => set({ error: null }),

    clearCache: () => set({
        userSignatures: [],
        documentSignatures: {},
        signatureStatuses: {},
        error: null
    })
}));
