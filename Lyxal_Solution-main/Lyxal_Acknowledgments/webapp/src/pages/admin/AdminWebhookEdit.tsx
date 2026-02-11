import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Loader2, Save, ArrowLeft } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { Textarea } from '../../components/ui/Textarea';
import { Alert, AlertDescription } from '../../components/ui/Alert';
import { api } from '../../lib/api';

interface Webhook {
    id: number;
    title: string;
    targetUrl: string;
    secret?: string;
    active: boolean;
    events: string[];
    description?: string;
}

const availableWebhookEvents = [
    { key: 'signature.created', labelKey: 'admin.webhooks.events.signature_created' },
    { key: 'document.created', labelKey: 'admin.webhooks.events.document_created' },
];

export const AdminWebhookEdit: React.FC = () => {
    const { t } = useTranslation();
    const navigate = useNavigate();
    const { id } = useParams<{ id: string }>();
    const isNew = !id;

    const [loading, setLoading] = useState(false);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');

    const [formData, setFormData] = useState<{
        title: string;
        targetUrl: string;
        secret: string;
        active: boolean;
        events: string[];
        description: string;
    }>({
        title: '',
        targetUrl: '',
        secret: '',
        active: true,
        events: [],
        description: ''
    });

    useEffect(() => {
        const load = async () => {
            if (isNew) return;
            try {
                setLoading(true);
                const data = await api.get<Webhook>(`/admin/webhooks/${id}`);
                setFormData({
                    title: data.title || '',
                    targetUrl: data.targetUrl,
                    secret: '', // Secret is never returned
                    active: data.active,
                    events: data.events || [],
                    description: data.description || ''
                });
            } catch (err: any) {
                setError(err.response?.data?.error?.message || err.message || 'Failed to load webhook');
            } finally {
                setLoading(false);
            }
        };
        load();
    }, [id, isNew]);

    const toggleEvent = (key: string) => {
        setFormData(prev => ({
            ...prev,
            events: prev.events.includes(key)
                ? prev.events.filter(k => k !== key)
                : [...prev.events, key]
        }));
    };

    const save = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');

        if (!formData.title || !formData.targetUrl || (!formData.secret && isNew) || formData.events.length === 0) {
            setError(t('admin.webhooks.form.validation', 'Veuillez remplir tous les champs obligatoires'));
            return;
        }

        try {
            setSaving(true);
            const payload: any = {
                title: formData.title.trim(),
                targetUrl: formData.targetUrl.trim(),
                secret: formData.secret.trim(),
                active: formData.active,
                events: formData.events,
                description: formData.description.trim() || undefined,
            };

            if (isNew) {
                await api.post('/admin/webhooks', payload);
            } else {
                if (!payload.secret) delete payload.secret;
                await api.patch(`/admin/webhooks/${id}`, payload);
            }
            navigate('/admin/webhooks');
        } catch (err: any) {
            setError(err.response?.data?.error?.message || err.message || 'Failed to save webhook');
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6 lg:px-8">
            <div className="mb-6 flex items-center justify-between">
                <h1 className="text-2xl font-bold">{isNew ? t('admin.webhooks.new', 'Nouveau Webhook') : t('admin.webhooks.editTitle', 'Éditer le Webhook')}</h1>
                <Button variant="outline" onClick={() => navigate('/admin/webhooks')}>
                    <ArrowLeft size={16} className="mr-2" /> {t('common.back', 'Retour')}
                </Button>
            </div>

            {error && (
                <Alert variant="destructive" className="mb-4">
                    <AlertDescription>{error}</AlertDescription>
                </Alert>
            )}

            <Card className="clay-card">
                <CardHeader>
                    <CardTitle>{t('admin.webhooks.form.title', 'Configuration')}</CardTitle>
                    <CardDescription>{t('admin.webhooks.form.subtitle', 'Détails du webhook')}</CardDescription>
                </CardHeader>
                <CardContent>
                    {loading ? (
                        <div className="flex items-center gap-3 py-10">
                            <Loader2 size={24} className="animate-spin" />
                            <span>{t('admin.loading', 'Chargement...')}</span>
                        </div>
                    ) : (
                        <form onSubmit={save} className="space-y-5">
                            <div>
                                <label className="block text-sm font-medium mb-2">{t('admin.webhooks.form.nameLabel', 'Nom')}</label>
                                <Input
                                    value={formData.title}
                                    onChange={e => setFormData({ ...formData, title: e.target.value })}
                                    required
                                    placeholder={t('admin.webhooks.form.namePlaceholder', 'Ex: Intégration Slack')}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-2">{t('admin.webhooks.form.urlLabel', 'URL Cible')}</label>
                                <Input
                                    value={formData.targetUrl}
                                    onChange={e => setFormData({ ...formData, targetUrl: e.target.value })}
                                    type="url"
                                    required
                                    placeholder="https://example.com/webhook"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-2">{t('admin.webhooks.form.secretLabel', 'Secret de signature')}</label>
                                <Input
                                    value={formData.secret}
                                    onChange={e => setFormData({ ...formData, secret: e.target.value })}
                                    type={isNew ? 'text' : 'password'}
                                    placeholder={isNew ? t('admin.webhooks.form.secretPlaceholder', 'Secret aléatoire ou personnalisé') : t('admin.webhooks.form.secretKeep', '(Laisser vide pour conserver l\'actuel)')}
                                    required={isNew}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-2">{t('admin.webhooks.form.eventsLabel', 'Événements déclencheurs')}</label>
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                                    {availableWebhookEvents.map(e => (
                                        <label key={e.key} className="flex items-center gap-2 cursor-pointer">
                                            <input
                                                type="checkbox"
                                                checked={formData.events.includes(e.key)}
                                                onChange={() => toggleEvent(e.key)}
                                                className="rounded border-gray-300 text-primary focus:ring-primary"
                                            />
                                            <span>{t(e.labelKey, e.key)}</span>
                                        </label>
                                    ))}
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-2">{t('admin.webhooks.form.descriptionLabel', 'Description')}</label>
                                <Textarea
                                    value={formData.description}
                                    onChange={e => setFormData({ ...formData, description: e.target.value })}
                                    placeholder={t('admin.webhooks.form.descriptionPlaceholder', 'Description optionnelle')}
                                />
                            </div>

                            <div className="pt-2">
                                <Button type="submit" disabled={saving}>
                                    {saving ? (
                                        <Loader2 size={16} className="mr-2 animate-spin" />
                                    ) : (
                                        <Save size={16} className="mr-2" />
                                    )}
                                    {t('common.save', 'Enregistrer')}
                                </Button>
                            </div>
                        </form>
                    )}
                </CardContent>
            </Card>
        </div>
    );
};
