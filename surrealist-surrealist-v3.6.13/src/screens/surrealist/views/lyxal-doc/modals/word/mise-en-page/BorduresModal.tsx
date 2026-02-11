import { Box, Text, Group, Stack, Button, Modal, UnstyledButton, Tooltip, ActionIcon, Select, Grid, Paper, Checkbox, ColorPicker, Divider, TextInput } from "@mantine/core";
import { useState, useEffect } from "react";

interface BordureSettings {
    type: 'aucun' | 'encadrement' | 'ombre' | '3d' | 'personnalise';
    style: string;
    color: string;
    width: number;
    sides: { top: boolean; bottom: boolean; left: boolean; right: boolean };
}

interface BorduresModalProps {
    opened: boolean;
    onClose: () => void;
    bordureSettings: BordureSettings;
    setBordureSettings: (settings: BordureSettings) => void;
    initialBordureSettings: BordureSettings;
    setInitialBordureSettings: (settings: BordureSettings) => void;
    themeColors: { color: string; label: string }[];
    standardColors: { color: string; label: string }[];
    pageColor: string;
    orientation: 'portrait' | 'landscape';
}

export function BorduresModal({
    opened,
    onClose,
    bordureSettings,
    setBordureSettings,
    initialBordureSettings,
    setInitialBordureSettings,
    themeColors,
    standardColors,
    pageColor,
    orientation
}: BorduresModalProps) {
    const [selectedColorSection, setSelectedColorSection] = useState<'theme' | 'standard' | 'custom'>('theme');
    const [localSettings, setLocalSettings] = useState(bordureSettings);

    useEffect(() => {
        if (opened) {
            setLocalSettings(bordureSettings);
        }
    }, [opened, bordureSettings]);

    const handleApply = () => {
        setBordureSettings(localSettings);
        setInitialBordureSettings(localSettings);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose}
            title="Bordures de page"
            size="xl"
            centered
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' },
                body: { padding: 0 }
            }}
        >
            <Stack gap={0}>
                <Box p="xl" bg="var(--mantine-color-body)">
                    <Grid gutter="xl">
                        {/* Colonne 1: Réglage (Gauche) */}
                        <Grid.Col span={3}>
                            <Stack gap="xs">
                                <Text size="xs" fw={700} c="dimmed">Réglage :</Text>
                                <Stack gap={8}>
                                    {[
                                        { id: 'encadrement', label: 'Encadrement', sides: { top: true, bottom: true, left: true, right: true }, iconStyle: { border: '2px solid currentColor' } },
                                        { id: 'haut', label: 'Haut', sides: { top: true, bottom: false, left: false, right: false }, iconStyle: { borderTop: '2px solid currentColor' } },
                                        { id: 'bas', label: 'Bas', sides: { top: false, bottom: true, left: false, right: false }, iconStyle: { borderBottom: '2px solid currentColor' } },
                                        { id: 'gauche', label: 'Gauche', sides: { top: false, bottom: false, left: true, right: false }, iconStyle: { borderLeft: '2px solid currentColor' } },
                                        { id: 'droite', label: 'Droite', sides: { top: false, bottom: false, left: false, right: true }, iconStyle: { borderRight: '2px solid currentColor' } }
                                    ].map((item) => {
                                        const isActive = item.id === 'encadrement' 
                                            ? (localSettings.sides.top && localSettings.sides.bottom && localSettings.sides.left && localSettings.sides.right)
                                            : (
                                                (item.id === 'haut' && localSettings.sides.top) ||
                                                (item.id === 'bas' && localSettings.sides.bottom) ||
                                                (item.id === 'gauche' && localSettings.sides.left) ||
                                                (item.id === 'droite' && localSettings.sides.right)
                                            );

                                        return (
                                            <UnstyledButton 
                                                key={item.id}
                                                onClick={() => {
                                                    if (item.id === 'encadrement') {
                                                        const allActive = localSettings.sides.top && localSettings.sides.bottom && localSettings.sides.left && localSettings.sides.right;
                                                        setLocalSettings({ 
                                                            ...localSettings, 
                                                            type: allActive ? 'aucun' : 'encadrement',
                                                            sides: { top: !allActive, bottom: !allActive, left: !allActive, right: !allActive }
                                                        });
                                                    } else {
                                                        const newSides = { ...localSettings.sides };
                                                        if (item.id === 'haut') newSides.top = !newSides.top;
                                                        if (item.id === 'bas') newSides.bottom = !newSides.bottom;
                                                        if (item.id === 'gauche') newSides.left = !newSides.left;
                                                        if (item.id === 'droite') newSides.right = !newSides.right;
                                                        
                                                        setLocalSettings({ 
                                                            ...localSettings, 
                                                            type: 'personnalise',
                                                            sides: newSides 
                                                        });
                                                    }
                                                }}
                                                p={6}
                                                style={{ 
                                                    borderRadius: '4px',
                                                    border: `1px solid ${isActive ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`,
                                                    backgroundColor: 'transparent',
                                                    transition: 'all 0.2s',
                                                    boxShadow: isActive ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none',
                                                    width: '100%'
                                                }}
                                            >
                                                <Group gap="md">
                                                    <Box 
                                                        w={32} 
                                                        h={32} 
                                                        bg="var(--mantine-color-body)" 
                                                        style={{ 
                                                            border: '1px solid var(--mantine-color-default-border)', 
                                                            display: 'flex', 
                                                            alignItems: 'center', 
                                                            justifyContent: 'center',
                                                            borderRadius: '2px'
                                                        }}
                                                    >
                                                        <Box w={16} h={16} c={isActive ? 'surreal.6' : 'dimmed'} style={item.iconStyle} />
                                                    </Box>
                                                    <Text size="xs" fw={isActive ? 600 : 500}>{item.label}</Text>
                                                </Group>
                                            </UnstyledButton>
                                        );
                                    })}
                                </Stack>
                            </Stack>
                        </Grid.Col>

                        {/* Colonne 2: Style, Largeur, Couleur (Centre) */}
                        <Grid.Col span={4} style={{ borderLeft: '1px solid var(--mantine-color-default-border)', borderRight: '1px solid var(--mantine-color-default-border)' }} px="xl">
                            <Stack gap="lg">
                                <Box>
                                    <Text size="xs" fw={700} c="dimmed" mb={8}>Style :</Text>
                                    <Select 
                                        size="xs"
                                        value={localSettings.style}
                                        onChange={(v) => v && setLocalSettings({ ...localSettings, style: v })}
                                        data={[
                                            { value: 'solid', label: 'Unis' },
                                            { value: 'double', label: 'Double' },
                                            { value: 'dotted', label: 'Pointillé' },
                                            { value: 'dashed', label: 'Tirets' }
                                        ]}
                                        leftSection={
                                            <Box w={40} h={12} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                <Box w="100%" style={{ 
                                                    borderBottom: localSettings.style === 'double' ? '3px double currentColor' : `2px ${localSettings.style} currentColor`
                                                }} />
                                            </Box>
                                        }
                                        leftSectionWidth={50}
                                        renderOption={({ option }) => (
                                            <Group gap="xs" wrap="nowrap">
                                                <Box w={40} h={12} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                    <Box w="100%" style={{ 
                                                        borderBottom: option.value === 'double' ? '3px double currentColor' : `2px ${option.value} currentColor`
                                                    }} />
                                                </Box>
                                                <Text size="xs" flex={1}>{option.label}</Text>
                                            </Group>
                                        )}
                                    />
                                </Box>

                                <Box>
                                    <Text size="xs" fw={700} c="dimmed" mb={8}>Largeur :</Text>
                                    <Select 
                                        size="xs"
                                        data={['0.25 pt', '0.5 pt', '0.75 pt', '1 pt', '1.5 pt', '2.25 pt', '3 pt', '4.5 pt', '6 pt']}
                                        value={`${localSettings.width} pt`}
                                        onChange={(v) => setLocalSettings({ ...localSettings, width: parseFloat(v?.replace(' pt', '') || '1') })}
                                        leftSection={
                                            <Box w={40} h={12} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                <Box w="100%" bg="currentColor" style={{ height: ({'0.25':1,'0.5':2,'0.75':3,'1':4,'1.5':5,'2.25':6,'3':7,'4.5':9,'6':11} as any)[String(localSettings.width)] || 1 }} />
                                            </Box>
                                        }
                                        leftSectionWidth={50}
                                        comboboxProps={{ withinPortal: false }}
                                        renderOption={({ option }) => (
                                            <Group gap="xs" w="100%" wrap="nowrap">
                                                <Box w={40} h={12} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                    <Box w="100%" bg="currentColor" style={{ height: ({'0.25':1,'0.5':2,'0.75':3,'1':4,'1.5':5,'2.25':6,'3':7,'4.5':9,'6':11} as any)[String(parseFloat(option.value.replace(' pt', '')))] || 1 }} />
                                                </Box>
                                                <Text size="xs" flex={1}>{option.value}</Text>
                                            </Group>
                                        )}
                                    />
                                </Box>

                                <Box>
                                    <Text size="xs" fw={700} c="dimmed" mb={8}>Couleur :</Text>
                                    <Stack gap={4}>
                                        <Checkbox 
                                            label="Couleurs du thème" 
                                            size="xs" 
                                            color="surreal"
                                            checked={selectedColorSection === 'theme'}
                                            onChange={() => setSelectedColorSection('theme')}
                                        />
                                        {selectedColorSection === 'theme' && (
                                            <Group gap={4} wrap="wrap" px="xs" mt={4}>
                                                {themeColors.map((c, i) => (
                                                    <Tooltip label={c.label} key={i} position="top" withArrow>
                                                        <UnstyledButton 
                                                            onClick={() => setLocalSettings({ ...localSettings, color: c.color })}
                                                            w={24} h={24} 
                                                            style={{ 
                                                                border: `1px solid ${localSettings.color === c.color ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`, 
                                                                backgroundColor: c.color,
                                                                borderRadius: '4px',
                                                                boxShadow: localSettings.color === c.color ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none',
                                                                transition: 'all 0.1s'
                                                            }} 
                                                        />
                                                    </Tooltip>
                                                ))}
                                            </Group>
                                        )}

                                        <Checkbox 
                                            label="Couleurs standard" 
                                            size="xs" 
                                            color="surreal"
                                            checked={selectedColorSection === 'standard'}
                                            onChange={() => setSelectedColorSection('standard')}
                                            mt={4}
                                        />
                                        {selectedColorSection === 'standard' && (
                                            <Group gap={4} wrap="wrap" px="xs" mt={4}>
                                                {standardColors.map((c, i) => (
                                                    <Tooltip label={c.label} key={i} position="top" withArrow>
                                                        <UnstyledButton 
                                                            onClick={() => setLocalSettings({ ...localSettings, color: c.color })}
                                                            w={24} h={24} 
                                                            style={{ 
                                                                border: `1px solid ${localSettings.color === c.color ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`, 
                                                                backgroundColor: c.color,
                                                                borderRadius: '4px',
                                                                boxShadow: localSettings.color === c.color ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none',
                                                                transition: 'all 0.1s'
                                                            }} 
                                                        />
                                                    </Tooltip>
                                                ))}
                                            </Group>
                                        )}

                                        <Checkbox 
                                            label="Personnalisé" 
                                            size="xs" 
                                            color="surreal"
                                            checked={selectedColorSection === 'custom'}
                                            onChange={() => setSelectedColorSection('custom')}
                                            mt={4}
                                        />
                                        {selectedColorSection === 'custom' && (
                                            <Stack gap="xs" px="xs" mt={4}>
                                                <ColorPicker 
                                                    format="hex" 
                                                    value={localSettings.color.startsWith('#') ? localSettings.color : '#000000'} 
                                                    onChange={(c) => setLocalSettings({ ...localSettings, color: c })} 
                                                    fullWidth
                                                    size="xs"
                                                />
                                                <TextInput 
                                                    size="xs" 
                                                    placeholder="000000"
                                                    value={localSettings.color.startsWith('#') ? localSettings.color.replace('#', '') : ''} 
                                                    onChange={(e) => {
                                                        const val = e.currentTarget.value.trim();
                                                        setLocalSettings({ ...localSettings, color: val.startsWith('#') ? val : `#${val}` });
                                                    }}
                                                    leftSection={<Text size="xs" fw={700} c="dimmed">#</Text>}
                                                    styles={{ input: { textTransform: 'uppercase' } }}
                                                />
                                            </Stack>
                                        )}
                                    </Stack>
                                </Box>
                            </Stack>
                        </Grid.Col>

                        {/* Colonne 3: Aperçu (Droite) */}
                        <Grid.Col span={5}>
                            <Stack gap="md">
                                <Text size="xs" fw={700} c="dimmed">Aperçu</Text>
                                <Group justify="center" align="center" gap="xl" style={{ position: 'relative' }} h={280}>
                                    {/* The Visual Page */}
                                    <Paper 
                                        shadow="sm" 
                                        withBorder 
                                        p={0} 
                                        style={{ 
                                            width: orientation === 'portrait' ? 140 : 180, 
                                            height: orientation === 'portrait' ? 180 : 140, 
                                            position: 'relative', 
                                            overflow: 'hidden',
                                            backgroundColor: pageColor !== 'transparent' ? pageColor : 'var(--mantine-color-white)',
                                            transition: 'all 0.3s ease'
                                        }}
                                    >
                                        {/* Corners - Visual helpers */}
                                        <Box style={{ position: 'absolute', top: 0, left: 0, width: 20, height: 20, borderTop: '1px solid rgba(0,0,0,0.05)', borderLeft: '1px solid rgba(0,0,0,0.05)' }} />
                                        <Box style={{ position: 'absolute', top: 0, right: 0, width: 20, height: 20, borderTop: '1px solid rgba(0,0,0,0.05)', borderRight: '1px solid rgba(0,0,0,0.05)' }} />
                                        <Box style={{ position: 'absolute', bottom: 0, left: 0, width: 20, height: 20, borderBottom: '1px solid rgba(0,0,0,0.05)', borderLeft: '1px solid rgba(0,0,0,0.05)' }} />
                                        <Box style={{ position: 'absolute', bottom: 0, right: 0, width: 20, height: 20, borderBottom: '1px solid rgba(0,0,0,0.05)', borderRight: '1px solid rgba(0,0,0,0.05)' }} />

                                        {/* Content representation */}
                                        <Stack gap={6} p={20} style={{ opacity: 0.1 }}>
                                            <Box h={2} bg="currentColor" w="100%" />
                                            <Box h={2} bg="currentColor" w="80%" />
                                            <Box h={2} bg="currentColor" w="90%" />
                                            <Box h={2} bg="currentColor" w="60%" />
                                            <Box h={2} bg="currentColor" w="95%" />
                                        </Stack>

                                        {/* Actual Borders Rendering */}
                                        <Box style={{ 
                                            position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
                                            borderTop: localSettings.sides.top ? `${Math.max(localSettings.style === 'double' ? 3 : 1, localSettings.width/1.5)}px ${localSettings.style} ${localSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : localSettings.color}` : 'none',
                                            borderBottom: localSettings.sides.bottom ? `${Math.max(localSettings.style === 'double' ? 3 : 1, localSettings.width/1.5)}px ${localSettings.style} ${localSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : localSettings.color}` : 'none',
                                            borderLeft: localSettings.sides.left ? `${Math.max(localSettings.style === 'double' ? 3 : 1, localSettings.width/1.5)}px ${localSettings.style} ${localSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : localSettings.color}` : 'none',
                                            borderRight: localSettings.sides.right ? `${Math.max(localSettings.style === 'double' ? 3 : 1, localSettings.width/1.5)}px ${localSettings.style} ${localSettings.color === 'currentColor' ? 'var(--mantine-color-text)' : localSettings.color}` : 'none',
                                            transition: 'all 0.15s ease-out',
                                            pointerEvents: 'none'
                                        }} />
                                    </Paper>
                                </Group>

                                <Box>
                                    <Text size="xs" fw={700} c="dimmed" mb={4}>Appliquer à :</Text>
                                    <Select 
                                        size="xs" 
                                        data={[
                                            { value: 'all', label: 'Document entier' },
                                            { value: 'first', label: 'Uniquement la première page' },
                                            { value: 'exceptFirst', label: 'Toutes sauf la première page' }
                                        ]}
                                        defaultValue="all"
                                        comboboxProps={{ withinPortal: false }}
                                    />
                                </Box>
                            </Stack>
                        </Grid.Col>
                    </Grid>

                    <Group justify="space-between" mt="xl">
                        <Button 
                            variant="subtle" 
                            color="red" 
                            size="xs" 
                            onClick={() => {
                                setLocalSettings({
                                    ...localSettings,
                                    type: 'aucun',
                                    sides: { top: false, bottom: false, left: false, right: false }
                                });
                            }}
                        >
                            Supprimer la bordure de page
                        </Button>
                        <Group gap="xs">
                            <Button variant="default" size="xs" onClick={onClose}>Annuler</Button>
                            <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                        </Group>
                    </Group>
                </Box>
            </Stack>
        </Modal>
    );
}
