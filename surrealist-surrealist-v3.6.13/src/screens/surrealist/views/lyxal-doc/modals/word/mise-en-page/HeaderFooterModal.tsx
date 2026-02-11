import { Modal, Button, Group, Stack, Text, Box, Checkbox, Divider } from "@mantine/core";
import { useState, useEffect } from "react";

interface HeaderFooterModalProps {
    opened: boolean;
    onClose: () => void;
    settings: {
        showHeader: boolean;
        showFooter: boolean;
        differentFirstPage: boolean;
        differentOddEvenPages: boolean;
    };
    onApply: (settings: { 
        showHeader: boolean; 
        showFooter: boolean; 
        differentFirstPage: boolean; 
        differentOddEvenPages: boolean; 
    }) => void;
}

export const HeaderFooterModal = ({ 
    opened, 
    onClose, 
    settings,
    onApply
}: HeaderFooterModalProps) => {
    const [localSettings, setLocalSettings] = useState(settings);

    useEffect(() => {
        if (opened) {
            setLocalSettings(settings);
        }
    }, [opened, settings]);

    const handleApply = () => {
        onApply(localSettings);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="En-tête et pied de page" 
            size="md"
            centered
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' }
            }}
        >
            <Stack gap="md">
                <Box>
                    <Text size="xs" fw={700} c="dimmed" mb="sm">Activation :</Text>
                    <Stack gap="xs">
                        <Checkbox 
                            label="Afficher l'en-tête" 
                            size="xs" 
                            color="surreal"
                            checked={localSettings.showHeader}
                            onChange={(e) => setLocalSettings({ ...localSettings, showHeader: e.currentTarget.checked })}
                        />
                        <Checkbox 
                            label="Afficher le pied de page" 
                            size="xs" 
                            color="surreal"
                            checked={localSettings.showFooter}
                            onChange={(e) => setLocalSettings({ ...localSettings, showFooter: e.currentTarget.checked })}
                        />
                    </Stack>
                </Box>

                <Divider />

                <Box>
                    <Text size="xs" fw={700} c="dimmed" mb="sm">Options de mise en page :</Text>
                    <Stack gap="xs">
                        <Checkbox 
                            label="Première page différente" 
                            size="xs" 
                            color="surreal"
                            checked={localSettings.differentFirstPage}
                            onChange={(e) => setLocalSettings({ ...localSettings, differentFirstPage: e.currentTarget.checked })}
                        />
                        <Checkbox 
                            label="Pages paires et impaires différentes" 
                            size="xs" 
                            color="surreal"
                            checked={localSettings.differentOddEvenPages}
                            onChange={(e) => setLocalSettings({ ...localSettings, differentOddEvenPages: e.currentTarget.checked })}
                        />
                    </Stack>
                </Box>

                <Group justify="end" mt="md" gap="xs">
                    <Button variant="default" size="xs" onClick={onClose}>Annuler</Button>
                    <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                </Group>
            </Stack>
        </Modal>
    );
};
