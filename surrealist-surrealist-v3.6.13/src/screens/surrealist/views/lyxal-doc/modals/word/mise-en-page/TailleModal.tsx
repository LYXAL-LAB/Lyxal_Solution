import { Box, Text, Group, Stack, Button, Modal, NumberInput, Divider, UnstyledButton } from "@mantine/core";
import { useState, useEffect } from "react";

interface TailleValues {
    width: number;
    height: number;
}

interface TailleModalProps {
    opened: boolean;
    onClose: () => void;
    selectedTailleType: string;
    setSelectedTailleType: (v: string) => void;
    tailleValues: TailleValues;
    setTailleValues: (v: TailleValues) => void;
}

export function TailleModal({
    opened,
    onClose,
    selectedTailleType,
    setSelectedTailleType,
    tailleValues,
    setTailleValues
}: TailleModalProps) {
    const [localType, setLocalType] = useState(selectedTailleType);
    const [localValues, setLocalValues] = useState(tailleValues);

    useEffect(() => {
        if (opened) {
            setLocalType(selectedTailleType);
            setLocalValues(tailleValues);
        }
    }, [opened, selectedTailleType, tailleValues]);

    const handleApply = () => {
        setSelectedTailleType(localType);
        setTailleValues(localValues);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Taille" 
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
                        { id: 'a4', label: 'A4', values: { width: 21, height: 29.7 } },
                        { id: 'letter', label: 'Lettre', values: { width: 21.59, height: 27.94 } },
                        { id: 'legal', label: 'Juridique', values: { width: 21.59, height: 35.56 } },
                        { id: 'a3', label: 'A3', values: { width: 29.7, height: 42 } },
                        { id: 'a5', label: 'A5', values: { width: 14.8, height: 21 } },
                        { id: 'custom', label: 'Personnalisé', values: localValues },
                    ].map((taille) => (
                        <UnstyledButton 
                            key={taille.id}
                            onClick={() => {
                                setLocalType(taille.id);
                                if (taille.id !== 'custom') {
                                    setLocalValues(taille.values);
                                }
                            }}
                            style={{
                                border: `1px solid ${localType === taille.id ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`,
                                borderRadius: '4px',
                                padding: '8px',
                                width: 'calc(33.33% - 8px)',
                                backgroundColor: 'transparent',
                                transition: 'all 0.2s',
                                boxShadow: localType === taille.id ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none'
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
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center'
                                    }}
                                >
                                    <Box 
                                        style={{
                                            width: Math.min(taille.values.width * 1.2, 32),
                                            height: Math.min(taille.values.height * 1.2, 42),
                                            border: '1px solid var(--mantine-color-surreal-6)',
                                            backgroundColor: 'var(--mantine-color-slate-1)',
                                            opacity: 0.5
                                        }}
                                    />
                                </Box>
                                <Text size="xs" fw={500} style={{ textAlign: 'center' }}>{taille.label}</Text>
                                <Text size="10px" c="dimmed" style={{ textAlign: 'center' }}>{taille.values.width} x {taille.values.height} cm</Text>
                            </Stack>
                        </UnstyledButton>
                    ))}
                </Group>

                <Divider label="Dimensions personnalisées" labelPosition="center" />
                
                <Group grow>
                    <NumberInput 
                        label="Largeur" 
                        value={localValues.width} 
                        onChange={(v) => setLocalValues({ ...localValues, width: Number(v) || 0 })}
                        disabled={localType !== 'custom'}
                        suffix=" cm" 
                        decimalScale={2} 
                        size="xs" 
                    />
                    <NumberInput 
                        label="Hauteur" 
                        value={localValues.height} 
                        onChange={(v) => setLocalValues({ ...localValues, height: Number(v) || 0 })}
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

