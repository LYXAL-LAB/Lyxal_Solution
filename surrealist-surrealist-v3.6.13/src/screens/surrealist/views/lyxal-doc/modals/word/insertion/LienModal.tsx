import { Modal, Stack, TextInput, Tabs, Button, Group } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { iconChevronDown, iconChevronRight } from "~/util/icons";
import { useState, useEffect } from "react";

interface LienModalProps {
    opened: boolean;
    onClose: () => void;
    linkText: string;
    setLinkText: (v: string) => void;
    linkUrl: string;
    setLinkUrl: (v: string) => void;
    expandTitres: boolean;
    setExpandTitres: (v: boolean) => void;
    expandSignets: boolean;
    setExpandSignets: (v: boolean) => void;
}

export function LienModal({
    opened,
    onClose,
    linkText,
    setLinkText,
    linkUrl,
    setLinkUrl,
    expandTitres,
    setExpandTitres,
    expandSignets,
    setExpandSignets
}: LienModalProps) {
    const [localText, setLocalText] = useState(linkText);
    const [localUrl, setLocalUrl] = useState(linkUrl);

    useEffect(() => {
        if (opened) {
            setLocalText(linkText);
            setLocalUrl(linkUrl);
        }
    }, [opened, linkText, linkUrl]);

    const handleApply = () => {
        setLinkText(localText);
        setLinkUrl(localUrl);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Lien" 
            centered 
            size="md"
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' }
            }}
        >
            <Stack gap="md">
                <TextInput 
                    label="Texte affiché :" 
                    placeholder="Saisir le texte" 
                    size="xs" 
                    value={localText} 
                    onChange={(e) => setLocalText(e.currentTarget.value)}
                />
                <Tabs defaultValue="url" variant="pills" color="surreal">
                    <Tabs.List>
                        <Tabs.Tab value="url">Entrer le lien</Tabs.Tab>
                        <Tabs.Tab value="internal">Titres et signets</Tabs.Tab>
                    </Tabs.List>

                    <Tabs.Panel value="url" pt="xs">
                        <TextInput 
                            placeholder="Entrer le lien" 
                            size="xs" 
                            value={localUrl} 
                            onChange={(e) => setLocalUrl(e.currentTarget.value)}
                        />
                    </Tabs.Panel>
                    <Tabs.Panel value="internal" pt="xs">
                        <Stack gap="xs">
                            <Button 
                                variant="subtle" 
                                fullWidth 
                                justify="start" 
                                leftSection={<Icon path={expandTitres ? iconChevronDown : iconChevronRight} size={10} />} 
                                size="xs"
                                onClick={() => setExpandTitres(!expandTitres)}
                            >
                                Titres
                            </Button>
                            <Button 
                                variant="subtle" 
                                fullWidth 
                                justify="start" 
                                leftSection={<Icon path={expandSignets ? iconChevronDown : iconChevronRight} size={10} />} 
                                size="xs"
                                onClick={() => setExpandSignets(!expandSignets)}
                            >
                                Signets
                            </Button>
                        </Stack>
                    </Tabs.Panel>
                </Tabs>
                <Group justify="end" mt="md">
                    <Button variant="subtle" color="slate" size="xs" onClick={onClose}>Annuler</Button>
                    <Button color="surreal" size="xs" disabled={!localUrl} onClick={handleApply}>Appliquer</Button>
                </Group>
            </Stack>
        </Modal>
    );
}
