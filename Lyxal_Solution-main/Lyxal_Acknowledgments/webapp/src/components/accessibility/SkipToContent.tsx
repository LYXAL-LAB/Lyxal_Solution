import React from 'react';
import { useTranslation } from 'react-i18next';

export const SkipToContent: React.FC = () => {
    const { t } = useTranslation();

    return (
        <a
            href="#main-content"
            className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:rounded-md focus:bg-primary focus:px-4 focus:py-2 focus:text-primary-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
        >
            {t('accessibility.skipToContent', 'Aller au contenu principal')}
        </a>
    );
};
