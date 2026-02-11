import { Box, Text, Group, Stack, Button, Modal, Checkbox, Tooltip, ColorPicker, TextInput, Divider, Grid, UnstyledButton, Paper } from "@mantine/core";
import { useState, useEffect } from "react";

interface PageColorModalProps {
    opened: boolean;
    onClose: () => void;
    pageColor: string;
    setPageColor: (color: string) => void;
    initialPageColor: string;
    selectedColorSection: 'theme' | 'standard' | 'custom' | 'none';
    setSelectedColorSection: (section: 'theme' | 'standard' | 'custom' | 'none') => void;
    themeColors: { color: string; label: string }[];
    standardColors: { color: string; label: string }[];
    bordureSettings: {
        type: string;
        style: string;
        color: string;
        width: number;
        sides: { top: boolean; bottom: boolean; left: boolean; right: boolean };
    };
    orientation: 'portrait' | 'landscape';
}

export function PageColorModal({
    opened,
    onClose,
    pageColor,
    setPageColor,
    initialPageColor,
    selectedColorSection,
    setSelectedColorSection,
    themeColors,
    standardColors,
    bordureSettings,
    orientation
}: PageColorModalProps) {
    const [localColor, setLocalColor] = useState(pageColor);
    const [localSection, setLocalSection] = useState(selectedColorSection);

    useEffect(() => {
        if (opened) {
            setLocalColor(pageColor);
            setLocalSection(selectedColorSection);
        }
    }, [opened, pageColor, selectedColorSection]);

    const handleApply = () => {
        setPageColor(localColor);
        setSelectedColorSection(localSection);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Couleur de page" 
            centered 
            size="lg"
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' },
                body: { padding: 0 }
            }}
        >
            <Stack gap={0}>
                <Box p="md">
                    <Grid gutter="xl">
                        <Grid.Col span={7} style={{ borderRight: '1px solid var(--mantine-color-default-border)' }}>
                            <Stack gap="lg">
                                <Stack gap="xs">
                                    <Group gap="xs">
                                        <Checkbox 
                                            label="Couleurs du thème" 
                                            size="xs" 
                                            color="surreal"
                                            checked={localSection === 'theme'}
                                            onChange={() => setLocalSection('theme')}
                                        />
                                    </Group>
                                    {localSection === 'theme' && (
                                        <Group gap={4} wrap="wrap" px="xl" mt={4}>
                                            {themeColors.map((c, i) => (
                                                <Tooltip label={c.label} key={i} position="top" withArrow>
                                                    <UnstyledButton 
                                                        onClick={() => setLocalColor(c.color)}
                                                        w={24} h={24} 
                                                        style={{ 
                                                            border: `1px solid ${localColor === c.color ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`, 
                                                            backgroundColor: c.color,
                                                            borderRadius: '4px',
                                                            boxShadow: localColor === c.color ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none',
                                                            transition: 'all 0.1s'
                                                        }} 
                                                    />
                                                </Tooltip>
                                            ))}
                                        </Group>
                                    )}
                                </Stack>

                                <Stack gap="xs">
                                    <Group gap="xs">
                                        <Checkbox 
                                            label="Couleurs standard" 
                                            size="xs" 
                                            color="surreal"
                                            checked={localSection === 'standard'}
                                            onChange={() => setLocalSection('standard')}
                                        />
                                    </Group>
                                    {localSection === 'standard' && (
                                        <Group gap={4} wrap="wrap" px="xl" mt={4}>
                                            {standardColors.map((c, i) => (
                                                <Tooltip label={c.label} key={i} position="top" withArrow>
                                                    <UnstyledButton 
                                                        onClick={() => setLocalColor(c.color)}
                                                        w={24} h={24} 
                                                        style={{ 
                                                            border: `1px solid ${localColor === c.color ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`, 
                                                            backgroundColor: c.color,
                                                            borderRadius: '4px',
                                                            boxShadow: localColor === c.color ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none',
                                                            transition: 'all 0.1s'
                                                        }} 
                                                    />
                                                </Tooltip>
                                            ))}
                                        </Group>
                                    )}
                                </Stack>

                                <Stack gap="xs">
                                    <Group gap="xs">
                                        <Checkbox 
                                            label="Autres couleurs (Personnalisé)" 
                                            size="xs" 
                                            color="surreal"
                                            checked={localSection === 'custom'}
                                            onChange={() => setLocalSection('custom')}
                                        />
                                    </Group>
                                    {localSection === 'custom' && (
                                        <Stack gap="sm" px="xl" mt={4}>
                                            <ColorPicker 
                                                format="hex" 
                                                value={localColor === 'transparent' ? '#ffffff' : (localColor.startsWith('#') ? localColor : `#${localColor}`)} 
                                                onChange={setLocalColor} 
                                                fullWidth
                                                size="xs"
                                            />
                                            <TextInput 
                                                size="xs" 
                                                placeholder="FFFFFF"
                                                value={localColor.startsWith('#') ? localColor.replace('#', '') : ''} 
                                                onChange={(e) => {
                                                    const val = e.currentTarget.value.trim();
                                                    setLocalColor(val.startsWith('#') ? val : `#${val}`);
                                                }}
                                                leftSection={<Text size="xs" fw={700} c="dimmed">#</Text>}
                                                styles={{ input: { textTransform: 'uppercase' } }}
                                            />
                                        </Stack>
                                    )}
                                </Stack>

                                <Stack gap="xs">
                                    <Group gap="xs">
                                        <Checkbox 
                                            label="Aucune couleur" 
                                            size="xs" 
                                            color="surreal"
                                            checked={localSection === 'none'}
                                            onChange={() => {
                                                setLocalSection('none');
                                                setLocalColor('transparent');
                                            }}
                                        />
                                    </Group>
                                </Stack>
                            </Stack>
                        </Grid.Col>

                        <Grid.Col span={5}>
                            <Stack gap="md" h="100%">
                                <Text size="xs" fw={700} c="dimmed">Aperçu</Text>
                                <Group justify="center" align="center" flex={1} mih={200}>
                                    <Paper 
                                        shadow="sm" 
                                        withBorder 
                                        p={0} 
                                        style={{ 
                                            width: orientation === 'portrait' ? 120 : 160, 
                                            height: orientation === 'portrait' ? 160 : 120, 
                                            position: 'relative', 
                                            overflow: 'hidden',
                                            backgroundColor: localColor !== 'transparent' ? localColor : 'var(--mantine-color-white)',
                                            transition: 'all 0.3s ease'
                                        }}
                                    >
                                        {/* Corners - Visual helpers */}
                                        <Box style={{ position: 'absolute', top: 0, left: 0, width: 20, height: 20, borderTop: '1px solid rgba(0,0,0,0.05)', borderLeft: '1px solid rgba(0,0,0,0.05)' }} />
                                        <Box style={{ position: 'absolute', top: 0, right: 0, width: 20, height: 20, borderTop: '1px solid rgba(0,0,0,0.05)', borderRight: '1px solid rgba(0,0,0,0.05)' }} />
                                        <Box style={{ position: 'absolute', bottom: 0, left: 0, width: 20, height: 20, borderBottom: '1px solid rgba(0,0,0,0.05)', borderLeft: '1px solid rgba(0,0,0,0.05)' }} />
                                        <Box style={{ position: 'absolute', bottom: 0, right: 0, width: 20, height: 20, borderBottom: '1px solid rgba(0,0,0,0.05)', borderRight: '1px solid rgba(0,0,0,0.05)' }} />

                                        {/* Content representation */}
                                        <Stack gap={4} p={15} style={{ opacity: 0.1 }}>
                                            <Box h={2} bg="currentColor" w="100%" />
                                            <Box h={2} bg="currentColor" w="80%" />
                                            <Box h={2} bg="currentColor" w="90%" />
                                            <Box h={2} bg="currentColor" w="60%" />
                                        </Stack>

                                        {/* Actual Borders Rendering */}
                                        <Box style={{ 
                                            position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
                                            borderTop: bordureSettings.sides.top ? `${Math.max(bordureSettings.style === 'double' ? 3 : 1, bordureSettings.width/1.5)}px ${bordureSettings.style} ${bordureSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : bordureSettings.color}` : 'none',
                                            borderBottom: bordureSettings.sides.bottom ? `${Math.max(bordureSettings.style === 'double' ? 3 : 1, bordureSettings.width/1.5)}px ${bordureSettings.style} ${bordureSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : bordureSettings.color}` : 'none',
                                            borderLeft: bordureSettings.sides.left ? `${Math.max(bordureSettings.style === 'double' ? 3 : 1, bordureSettings.width/1.5)}px ${bordureSettings.style} ${bordureSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : bordureSettings.color}` : 'none',
                                            borderRight: bordureSettings.sides.right ? `${Math.max(bordureSettings.style === 'double' ? 3 : 1, bordureSettings.width/1.5)}px ${bordureSettings.style} ${bordureSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : bordureSettings.color}` : 'none',
                                            transition: 'all 0.15s ease-out',
                                            pointerEvents: 'none'
                                        }} />
                                    </Paper>
                                </Group>
                            </Stack>
                        </Grid.Col>
                    </Grid>

                    <Group justify="end" gap="xs" mt="xl">
                        <Button variant="subtle" color="slate" size="xs" onClick={onClose}>Annuler</Button>
                        <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                    </Group>
                </Box>
            </Stack>
        </Modal>
    );
}

