import { Box, Text, Group, Stack, Button, Modal, NumberInput, Divider, UnstyledButton } from "@mantine/core";
import { useState, useEffect } from "react";

interface MarginValues {
    top: number;
    bottom: number;
    left: number;
    right: number;
}

interface MargesModalProps {
    opened: boolean;
    onClose: () => void;
    selectedMarginType: string;
    setSelectedMarginType: (v: string) => void;
    marginValues: MarginValues;
    setMarginValues: (v: MarginValues) => void;
}

export function MargesModal({
    opened,
    onClose,
    selectedMarginType,
    setSelectedMarginType,
    marginValues,
    setMarginValues
}: MargesModalProps) {
    const [localType, setLocalType] = useState(selectedMarginType);
    const [localValues, setLocalValues] = useState(marginValues);

    useEffect(() => {
        if (opened) {
            setLocalType(selectedMarginType);
            setLocalValues(marginValues);
        }
    }, [opened, selectedMarginType, marginValues]);

    const handleApply = () => {
        setSelectedMarginType(localType);
        setMarginValues(localValues);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Marges" 
            centered 
            size="md"
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' }
            }}
        >
            <Stack gap="md">
                <Text size="xs" fw={700} c="dimmed">Préréglages</Text>
                
                <Group gap="xs" wrap="wrap">
                    {[
                        { id: 'normal', label: 'Normal', values: { top: 2.5, bottom: 2.5, left: 2.5, right: 2.5 } },
                        { id: 'narrow', label: 'Étroit', values: { top: 1.27, bottom: 1.27, left: 1.27, right: 1.27 } },
                        { id: 'moderate', label: 'Modéré', values: { top: 2.54, bottom: 2.54, left: 1.91, right: 1.91 } },
                        { id: 'wide', label: 'Large', values: { top: 2.54, bottom: 2.54, left: 5.08, right: 5.08 } },
                        { id: 'mirrored', label: 'Miroir', values: { top: 2.54, bottom: 2.54, left: 3.18, right: 3.18 } },
                        { id: 'custom', label: 'Personnalisé', values: localValues },
                    ].map((margin) => (
                        <UnstyledButton 
                            key={margin.id}
                            onClick={() => {
                                setLocalType(margin.id);
                                if (margin.id !== 'custom') {
                                    setLocalValues(margin.values);
                                }
                            }}
                            style={{
                                border: `1px solid ${localType === margin.id ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`,
                                borderRadius: '4px',
                                padding: '8px',
                                width: 'calc(33.33% - 8px)',
                                backgroundColor: 'transparent',
                                transition: 'all 0.2s',
                                boxShadow: localType === margin.id ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none'
                            }}
                        >
                            <Stack gap={4} align="center">
                                <Box 
                                    w={40} 
                                    h={50} 
                                    bg="var(--mantine-color-body)" 
                                    style={{ 
                                        border: '1px solid var(--mantine-color-default-border)',
                                        position: 'relative',
                                        overflow: 'hidden'
                                    }}
                                >
                                    <Box 
                                        style={{
                                            position: 'absolute',
                                            top: Math.min(margin.values.top * 4, 20),
                                            bottom: Math.min(margin.values.bottom * 4, 20),
                                            left: Math.min(margin.values.left * 4, 15),
                                            right: Math.min(margin.values.right * 4, 15),
                                            border: '1px dashed var(--mantine-color-surreal-6)',
                                            opacity: 0.5
                                        }}
                                    />
                                </Box>
                                <Text size="xs" fw={500} style={{ textAlign: 'center' }}>{margin.label}</Text>
                            </Stack>
                        </UnstyledButton>
                    ))}
                </Group>

                <Divider label="Valeurs des marges" labelPosition="center" />
                
                <Group grow>
                    <NumberInput 
                        label="Haut" 
                        value={localValues.top} 
                        onChange={(v) => setLocalValues({ ...localValues, top: Number(v) || 0 })}
                        disabled={localType !== 'custom'}
                        suffix=" cm" 
                        decimalScale={2} 
                        size="xs" 
                    />
                    <NumberInput 
                        label="Bas" 
                        value={localValues.bottom} 
                        onChange={(v) => setLocalValues({ ...localValues, bottom: Number(v) || 0 })}
                        disabled={localType !== 'custom'}
                        suffix=" cm" 
                        decimalScale={2} 
                        size="xs" 
                    />
                </Group>
                <Group grow>
                    <NumberInput 
                        label="Gauche" 
                        value={localValues.left} 
                        onChange={(v) => setLocalValues({ ...localValues, left: Number(v) || 0 })}
                        disabled={localType !== 'custom'}
                        suffix=" cm" 
                        decimalScale={2} 
                        size="xs" 
                    />
                    <NumberInput 
                        label="Droite" 
                        value={localValues.right} 
                        onChange={(v) => setLocalValues({ ...localValues, right: Number(v) || 0 })}
                        disabled={localType !== 'custom'}
                        suffix=" cm" 
                        decimalScale={2} 
                        size="xs" 
                    />
                </Group>

                <Group justify="end" mt="xl">
                    <Button variant="subtle" color="slate" size="xs" onClick={onClose}>Annuler</Button>
                    <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                </Group>
            </Stack>
        </Modal>
    );
}

