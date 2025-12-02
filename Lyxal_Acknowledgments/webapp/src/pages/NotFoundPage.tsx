import React from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

export const NotFoundPage: React.FC = () => {
    const { t } = useTranslation();

    return (
        <div className="min-h-full box-border bg-background text-foreground flex items-center justify-center">
            <div className="text-center">
                <h1 className="text-6xl font-bold text-muted-foreground">404</h1>
                <p className="text-xl text-foreground mt-4">{t('notFound.title', 'Page non trouvée')}</p>
                <p className="text-sm text-muted-foreground mt-2">{t('notFound.description', 'Désolé, la page que vous recherchez n\'existe pas.')}</p>
                <Link
                    to="/"
                    className="mt-6 inline-block text-primary hover:text-primary/80 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background rounded px-2 py-1"
                >
                    {t('notFound.home', 'Retour à l\'accueil')}
                </Link>
            </div>
        </div>
    );
};
