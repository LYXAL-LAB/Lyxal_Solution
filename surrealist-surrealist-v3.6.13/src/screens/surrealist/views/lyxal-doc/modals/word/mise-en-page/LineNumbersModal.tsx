import { Modal, Button, Group, Stack, Text, Radio, NumberInput, Checkbox, Tooltip } from "@mantine/core";
import { useState, useEffect } from "react";

interface LineNumbersModalProps {
    opened: boolean;
    onClose: () => void;
    lineNumbersSettings: {
        enabled: boolean;
        startAt: number;
        distanceFromText: number | 'auto';
        countBy: number;
        restartMode: 'continuous' | 'newPage' | 'newSection';
    };
    setLineNumbersSettings: (settings: any) => void;
}

export const LineNumbersModal = ({ opened, onClose, lineNumbersSettings, setLineNumbersSettings }: LineNumbersModalProps) => {
    const [localSettings, setLocalSettings] = useState(lineNumbersSettings);

    useEffect(() => {
        if (opened) {
            setLocalSettings(lineNumbersSettings);
        }
    }, [opened, lineNumbersSettings]);

    const handleSave = () => {
        setLineNumbersSettings(localSettings);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Numéros de lignes" 
            size="md" 
            centered
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' }
            }}
        >
            <Stack gap="md">
                <Checkbox 
                    label="Ajouter la numérotation des lignes" 
                    checked={localSettings.enabled}
                    onChange={(e) => setLocalSettings({ ...localSettings, enabled: e.currentTarget.checked })}
                />

                <Stack gap="xs" style={{ opacity: localSettings.enabled ? 1 : 0.5, pointerEvents: localSettings.enabled ? 'auto' : 'none' }}>
                    <Group grow align="flex-start">
                        <Tooltip label="Entrez le numéro du début de la propriété de 1 à 32767" position="top-start" withArrow>
                            <NumberInput
                                label="Commencer à :"
                                size="xs"
                                min={1}
                                max={32767}
                                allowDecimal={false}
                                value={localSettings.startAt}
                                onChange={(val) => setLocalSettings({ ...localSettings, startAt: Number(val) || 1 })}
                            />
                        </Tooltip>
                        
                        <Tooltip label="Entrez le nombre des nombres de la propriété de 1 à 32767" position="top-start" withArrow>
                            <NumberInput
                                label="Compter par :"
                                size="xs"
                                min={1}
                                max={32767}
                                allowDecimal={false}
                                value={localSettings.countBy}
                                onChange={(val) => setLocalSettings({ ...localSettings, countBy: Number(val) || 1 })}
                            />
                        </Tooltip>
                    </Group>

                    <Group align="flex-end">
                        <Tooltip label="Entrez le nombre de la propriété de texte de 0.1 à 22" position="top-start" withArrow>
                            <NumberInput
                                label="À partir du texte :"
                                size="xs"
                                min={0.1}
                                max={22}
                                step={0.1}
                                decimalScale={1}
                                disabled={localSettings.distanceFromText === 'auto'}
                                value={localSettings.distanceFromText === 'auto' ? '' : localSettings.distanceFromText}
                                onChange={(val) => setLocalSettings({ ...localSettings, distanceFromText: Number(val) })}
                                suffix=" cm"
                                style={{ flex: 1 }}
                            />
                        </Tooltip>
                        <Checkbox 
                            label="Automatique" 
                            size="xs" 
                            mb={6}
                            checked={localSettings.distanceFromText === 'auto'}
                            onChange={(e) => {
                                if (e.currentTarget.checked) {
                                    setLocalSettings({ ...localSettings, distanceFromText: 'auto' });
                                } else {
                                    // Valeur par défaut quand on décoche
                                    setLocalSettings({ ...localSettings, distanceFromText: 0.1 });
                                }
                            }}
                        />
                    </Group>

                    <Text size="sm" fw={500} mt="xs">Numérotation</Text>
                    <Radio.Group
                        value={localSettings.restartMode}
                        onChange={(val) => setLocalSettings({ ...localSettings, restartMode: val as any })}
                    >
                        <Stack gap="xs">
                            <Radio value="newPage" label="Redémarrer à chaque page" size="xs" />
                            <Radio value="newSection" label="Redémarrer à chaque section" size="xs" />
                            <Radio value="continuous" label="Continu" size="xs" />
                        </Stack>
                    </Radio.Group>
                </Stack>

                <Group justify="space-between" mt="md" wrap="nowrap">
                    <Button variant="subtle" color="slate" size="xs" px={4}>Supprimer pour le paragraphe actif</Button>
                    <Group gap="xs" wrap="nowrap">
                        <Button variant="default" onClick={onClose} size="xs">Annuler</Button>
                        <Button color="surreal" onClick={handleSave} size="xs">Appliquer</Button>
                    </Group>
                </Group>
            </Stack>
        </Modal>
    );
};
