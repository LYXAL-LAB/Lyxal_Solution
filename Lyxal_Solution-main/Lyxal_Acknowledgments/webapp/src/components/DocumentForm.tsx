import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ArrowRight } from 'lucide-react';
import { Button } from './ui/Button';
import { Input } from './ui/Input';
import { useAuthStore } from '../store/auth.store';
import { api } from '../lib/api';

export const DocumentForm: React.FC = () => {
    const { t } = useTranslation();
    const navigate = useNavigate();
    const { isAuthenticated } = useAuthStore();

    const [documentUrl, setDocumentUrl] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);

    const handleSubmit = async () => {
        setErrorMessage(null);

        if (!documentUrl.trim()) {
            const homeRoute = '/';
            if (isAuthenticated) {
                navigate(homeRoute);
            } else {
                // In React version, we redirect to auth page with return url
                navigate(`/auth?returnUrl=${encodeURIComponent(homeRoute)}`);
            }
            return;
        }

        try {
            setIsSubmitting(true);

            // Call API to find or create document
            const response = await api.post<{ docId: string }>('/documents/find-or-create', {
                url: documentUrl.trim()
            });

            const homeRoute = `/?doc=${response.docId}`;
            if (isAuthenticated) {
                navigate(homeRoute);
            } else {
                navigate(`/auth?returnUrl=${encodeURIComponent(homeRoute)}`);
            }
        } catch (error: any) {
            const message = error.response?.data?.error?.message || error.message || 'Une erreur est survenue';
            setErrorMessage(message);
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleKeyUp = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter') {
            handleSubmit();
        }
    };

    return (
        <div className="space-y-4">
            {errorMessage && (
                <div className="w-full rounded-lg bg-red-50 dark:bg-red-950/20 border border-red-200 dark:border-red-900 p-4 text-sm text-red-800 dark:text-red-200">
                    {errorMessage}
                </div>
            )}

            <div className="flex w-full flex-col gap-3 sm:flex-row">
                <Input
                    value={documentUrl}
                    onChange={(e) => setDocumentUrl(e.target.value)}
                    type="text"
                    placeholder={t('admin.documentForm.placeholder', 'Entrez l\'URL du document ou l\'ID')}
                    className="flex-1 h-11"
                    disabled={isSubmitting}
                    onKeyUp={handleKeyUp}
                />
                <Button
                    onClick={handleSubmit}
                    size="lg"
                    className="group whitespace-nowrap"
                    disabled={isSubmitting}
                >
                    {isSubmitting ? (
                        <span>{t('admin.documentForm.submitting', 'Traitement...')}</span>
                    ) : (
                        <span>{t('admin.documentForm.submit', 'Continuer')}</span>
                    )}
                    {!isSubmitting && (
                        <ArrowRight size={16} className="ml-2 transition-transform group-hover:translate-x-1" />
                    )}
                </Button>
            </div>
        </div>
    );
};
