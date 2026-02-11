import React, { useEffect } from 'react';
import { Routes, Route, useLocation } from 'react-router-dom';
import { Layout } from './components/layout/Layout';
import { NotificationToast } from './components/NotificationToast';
import { useAuthStore } from './store/auth.store';
import { HomePage } from './pages/HomePage';
import { AuthChoicePage } from './pages/AuthChoicePage';
import { SignaturesPage } from './pages/SignaturesPage';
import { EmbedPage } from './pages/EmbedPage';
import { AdminDashboard } from './pages/admin/AdminDashboard';
import { AdminDocumentDetail } from './pages/admin/AdminDocumentDetail';
import { AdminWebhooks } from './pages/admin/AdminWebhooks';
import { AdminWebhookEdit } from './pages/admin/AdminWebhookEdit';
import { NotFoundPage } from './pages/NotFoundPage';

export const App = () => {
    const location = useLocation();
    const checkAuth = useAuthStore((state) => state.checkAuth);

    // Check if current route is an embed page
    const isEmbedPage = location.pathname.startsWith('/embed');

    // Check authentication status on app mount (exactly like Vue original)
    useEffect(() => {
        checkAuth();
    }, [checkAuth]);

    return (
        <div id="app">
            {/* For embed pages, render without Layout */}
            {isEmbedPage ? (
                <Routes>
                    <Route path="/embed" element={<EmbedPage />} />
                </Routes>
            ) : (
                /* For normal pages, wrap with Layout */
                <Layout>
                    <Routes>
                        <Route path="/" element={<HomePage />} />
                        <Route path="/auth" element={<AuthChoicePage />} />
                        <Route path="/signatures" element={<SignaturesPage />} />

                        {/* Admin Routes */}
                        <Route path="/admin" element={<AdminDashboard />} />
                        <Route path="/admin/docs/:docId" element={<AdminDocumentDetail />} />
                        <Route path="/admin/webhooks" element={<AdminWebhooks />} />
                        <Route path="/admin/webhooks/new" element={<AdminWebhookEdit />} />
                        <Route path="/admin/webhooks/:id" element={<AdminWebhookEdit />} />

                        {/* 404 - Must be last */}
                        <Route path="*" element={<NotFoundPage />} />
                    </Routes>
                </Layout>
            )}

            {/* Toast notifications - always visible */}
            <NotificationToast />
        </div>
    );
};
