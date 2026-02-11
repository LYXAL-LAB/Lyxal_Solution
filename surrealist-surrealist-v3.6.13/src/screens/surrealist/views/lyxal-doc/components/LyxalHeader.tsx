import { ActionIcon, Box, Group, Paper, Stack, Tabs, Text, Title, Button, Tooltip, Divider } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { 
    iconAccount, iconCloud, iconDownload, iconFile, iconHistory, iconPlay, iconTable, iconCursor, iconFloppy, iconStar 
} from "~/util/icons";

interface LyxalHeaderProps {
    activeTab: string;
    onTabChange: (tab: string) => void;
    config: { color: string, title: string, icon: any };
}

export function LyxalHeader({ activeTab, onTabChange, config }: LyxalHeaderProps) {
    return (
        <Paper 
            p="xs" 
            withBorder 
            shadow="none"
            bg="var(--mantine-color-body)"
            style={{ borderRadius: 0, borderTop: 0, borderLeft: 0, borderRight: 0, borderBottomColor: 'var(--mantine-color-default-border)' }} 
            id="lyxal-doc-header"
        >
            <Stack gap="xs">
                <Group justify="space-between" id="lyxal-doc-title-bar">
                    <Group gap="sm" id="lyxal-doc-branding">
                        <ActionIcon variant="filled" color={config.color} size="lg"><Icon path={config.icon} size="md" /></ActionIcon>
                        <Box>
                            <Title order={5}>{config.title} sans titre</Title>
                            <Text size="xs" c="dimmed" style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                                <Icon path={iconCloud} size={12} /> Enregistré sur Lyxal Sync
                            </Text>
                        </Box>
                    </Group>
                    
                    <Group id="lyxal-doc-actions">
                        <Tooltip label="Historique des versions"><ActionIcon variant="subtle"><Icon path={iconHistory} size="md" /></ActionIcon></Tooltip>
                        <Tooltip label="Collaborateurs"><ActionIcon variant="subtle"><Icon path={iconAccount} size="md" /></ActionIcon></Tooltip>
                        <Button size="xs" leftSection={<Icon path={iconStar} size="sm" />} variant="light" color={config.color}>Partager</Button>
                        <Button size="xs" color={config.color}>Publier</Button>
                    </Group>
                </Group>

                <Divider />

                <Group gap="xs" id="lyxal-doc-navigation">
                    <Tabs 
                        value={activeTab} 
                        onChange={(v) => onTabChange(v || "word")} 
                        variant="pills" 
                        color={config.color} 
                        bg="transparent"
                        id="lyxal-doc-tabs"
                    >
                        <Tabs.List bg="transparent">
                            <Tabs.Tab value="word" leftSection={<Icon path={iconFile} size="sm" />} style={{ fontSize: 12, height: 32 }}>Document</Tabs.Tab>
                            <Tabs.Tab value="excel" leftSection={<Icon path={iconTable} size="sm" />} style={{ fontSize: 12, height: 32 }}>Données</Tabs.Tab>
                            <Tabs.Tab value="slides" leftSection={<Icon path={iconPlay} size="sm" />} style={{ fontSize: 12, height: 32 }}>Présentation</Tabs.Tab>
                            <Tabs.Tab value="draw" leftSection={<Icon path={iconCursor} size="sm" />} style={{ fontSize: 12, height: 32 }}>Dessin</Tabs.Tab>
                        </Tabs.List>
                    </Tabs>
                    
                    <Divider orientation="vertical" />

                    <Group gap={4} id="lyxal-doc-quick-actions">
                        <Tooltip label="Enregistrer"><ActionIcon variant="subtle" size="sm"><Icon path={iconFloppy} size="sm" /></ActionIcon></Tooltip>
                        <Tooltip label="Exporter PDF"><ActionIcon variant="subtle" size="sm"><Icon path={iconDownload} size="sm" /></ActionIcon></Tooltip>
                    </Group>

                    <Divider orientation="vertical" />
                    
                    <Text size="xs" c="dimmed" fs="italic" id="lyxal-doc-context-message">Outils contextuels pour {activeTab}...</Text>
                </Group>
            </Stack>
        </Paper>
    );
}

