import React, { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { FileCheck } from 'lucide-react';
import { useSignatureStore } from '../store/signature.store';
import { useAuthStore } from '../store/auth.store';
import { SignatureList } from '../components/SignatureList';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../components/ui/Card';

export const SignaturesPage: React.FC = () => {
    const { t } = useTranslation();
    const { userSignatures, fetchUserSignatures, loading } = useSignatureStore();
    const { isAuthenticated, initialized, checkAuth } = useAuthStore();

    useEffect(() => {
        const init = async () => {
            if (!initialized) {
                await checkAuth();
            }
            if (isAuthenticated) {
                fetchUserSignatures();
            }
        };
        init();
    }, [isAuthenticated, initialized, checkAuth, fetchUserSignatures]);

    return (
        <div className="container mx-auto px-4 py-8 max-w-4xl">
            <div className="mb-8">
                <h1 className="text-3xl font-bold tracking-tight text-foreground mb-2">
                    {t('signatures.title', 'Mes Confirmations')}
                </h1>
                <p className="text-muted-foreground">
                    {t('signatures.subtitle', 'Retrouvez l\'historique de tous les documents que vous avez signés.')}
                </p>
            </div>

            <Card className="clay-card">
                <CardHeader>
                    <div className="flex items-center space-x-3">
                        <div className="rounded-lg bg-primary/10 p-2">
                            <FileCheck size={24} className="text-primary" />
                        </div>
                        <div>
                            <CardTitle>{t('signatures.history.title', 'Historique')}</CardTitle>
                            <CardDescription>
                                {t('signatures.history.description', 'Liste de vos signatures électroniques valides.')}
                            </CardDescription>
                        </div>
                    </div>
                </CardHeader>
                <CardContent>
                    <SignatureList
                        signatures={userSignatures}
                        loading={loading}
                        showUserInfo={false}
                        showDetails={true}
                        showActions={true}
                        emptyMessage={t('signatures.empty', 'Vous n\'avez pas encore signé de document.')}
                    />
                </CardContent>
            </Card>
        </div>
    );
};
