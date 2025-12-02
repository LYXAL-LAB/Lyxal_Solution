import React, { useState, useEffect, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useAuthStore } from '../store/auth.store';
import { api } from '../lib/api';
import { cn } from '../lib/utils';

interface Signature {
    userEmail: string;
    signedAt: string;
}

interface SignButtonProps {
    docId?: string;
    referer?: string;
    disabled?: boolean;
    signatures?: Signature[];
    onSigned?: (docId: string) => void;
    onError?: (error: string) => void;
}

export const SignButton: React.FC<SignButtonProps> = ({
    docId,
    referer,
    disabled,
    signatures,
    onSigned,
    onError
}) => {
    const { t } = useTranslation();
    const { user, isAuthenticated, checkAuth, initialized } = useAuthStore();

    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [isSigned, setIsSigned] = useState(false);
    const [signedAt, setSignedAt] = useState<string | null>(null);

    // Check if current user has signed based on signatures list
    useEffect(() => {
        const checkIfSigned = async () => {
            if (!initialized) {
                try {
                    await checkAuth();
                } catch {
                    // Ignore errors
                }
            }

            if (!signatures || !user?.email) {
                setIsSigned(false);
                setSignedAt(null);
                return;
            }

            const userSignature = signatures.find(
                sig => sig.userEmail === user.email
            );

            setIsSigned(!!userSignature);
            setSignedAt(userSignature?.signedAt || null);
        };

        checkIfSigned();
    }, [signatures, user, initialized, checkAuth]);

    const buttonClasses = cn(
        'inline-flex items-center justify-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white transition-colors w-full sm:w-auto',
        (loading || disabled || !docId)
            ? 'bg-indigo-400 cursor-not-allowed'
            : 'bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500'
    );

    const handleSign = async () => {
        if (!docId) {
            const msg = t('signButton.error.missingDocId', 'ID du document manquant');
            setError(msg);
            return;
        }

        // Check auth
        if (!initialized) {
            await checkAuth();
        }

        if (!isAuthenticated) {
            try {
                // Redirect to login preserving current location
                const returnUrl = window.location.pathname + window.location.search;
                window.location.href = `/auth?returnUrl=${encodeURIComponent(returnUrl)}`;
            } catch (err) {
                const msg = t('signButton.error.authFailed', 'Authentification requise');
                setError(msg);
                if (onError) onError(msg);
            }
            return;
        }

        setLoading(true);
        setError(null);

        try {
            await api.post('/signatures', {
                docId,
                referer
            });

            setIsSigned(true);
            setSignedAt(new Date().toISOString());
            if (onSigned) onSigned(docId);
        } catch (err: any) {
            const errorMessage = err.response?.data?.error?.message || 'Impossible de confirmer la lecture';
            setError(errorMessage);
            if (onError) onError(errorMessage);
        } finally {
            setLoading(false);
        }
    };

    const formatDate = (dateString: string) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('fr-FR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
        });
    };

    return (
        <div className="w-full">
            {!isSigned ? (
                <button
                    onClick={handleSign}
                    disabled={loading || disabled || !docId}
                    className={buttonClasses}
                    type="button"
                >
                    {loading ? (
                        <svg
                            className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                        >
                            <circle
                                className="opacity-25"
                                cx="12"
                                cy="12"
                                r="10"
                                stroke="currentColor"
                                strokeWidth="4"
                            ></circle>
                            <path
                                className="opacity-75"
                                fill="currentColor"
                                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                            ></path>
                        </svg>
                    ) : (
                        <svg
                            className="-ml-1 mr-3 h-5 w-5"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                        >
                            <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth="2"
                                d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
                            />
                        </svg>
                    )}
                    {loading ? t('signButton.signing', 'Signature en cours...') : t('signButton.confirmAction', 'Confirmer la lecture')}
                </button>
            ) : (
                <div className="p-4 bg-green-50 dark:bg-green-900/20 border-2 border-green-300 dark:border-green-800 rounded-lg">
                    <div className="flex items-center justify-center space-x-2 text-green-700 dark:text-green-400">
                        <svg
                            className="h-6 w-6"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                        >
                            <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth="2"
                                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                            />
                        </svg>
                        <span className="font-semibold">{t('signButton.confirmed', 'Confirmé')}</span>
                    </div>
                    {signedAt && (
                        <p className="mt-2 text-sm text-muted-foreground text-center">
                            {t('signButton.on', 'Le')} {formatDate(signedAt)}
                        </p>
                    )}
                </div>
            )}

            {error && (
                <div className="mt-4 text-red-600 text-sm text-center">
                    {error}
                </div>
            )}
        </div>
    );
};
