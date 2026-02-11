import { Modal, Button, Group, Stack, Text, Box, Checkbox, UnstyledButton, Divider } from "@mantine/core";
import { useState, useEffect } from "react";
import { Icon } from "~/components/Icon";
import { iconTrash } from "~/util/icons";

interface PageNumbersModalProps {
    opened: boolean;
    onClose: () => void;
    selectedPageNumber: { position: 'top' | 'bottom', alignment: number } | null;
    setSelectedPageNumber: (v: { position: 'top' | 'bottom', alignment: number } | null) => void;
    addTotalPages: boolean;
    setAddTotalPages: (v: boolean) => void;
}

export const PageNumbersModal = ({ 
    opened, 
    onClose, 
    selectedPageNumber, 
    setSelectedPageNumber, 
    addTotalPages, 
    setAddTotalPages 
}: PageNumbersModalProps) => {
    const [localSelected, setLocalSelected] = useState(selectedPageNumber);
    const [localAddTotal, setLocalAddTotal] = useState(addTotalPages);

    useEffect(() => {
        if (opened) {
            setLocalSelected(selectedPageNumber);
            setLocalAddTotal(addTotalPages);
        }
    }, [opened, selectedPageNumber, addTotalPages]);

    const handleApply = () => {
        setSelectedPageNumber(localSelected);
        setAddTotalPages(localAddTotal);
        onClose();
    };

    const handleRemove = () => {
        setLocalSelected(null);
        setLocalAddTotal(false);
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Numéros de page" 
            size="md"
            centered
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' }
            }}
        >
            <Stack gap="md">
                <Box>
                    <Text size="xs" fw={700} c="dimmed" mb="xs">Position du numéro de page :</Text>
                    
                    <Stack gap="sm">
                        <Box>
                            <Text size="xs" fw={600} mb={8} c="dimmed">Haut de page (En-tête)</Text>
                            <Group gap="xs" justify="space-between">
                                {[0, 1, 2].map((pos) => {
                                    const isSelected = localSelected?.position === 'top' && localSelected?.alignment === pos;
                                    return (
                                        <UnstyledButton 
                                            key={`top-${pos}`} 
                                            onClick={() => setLocalSelected({ position: 'top', alignment: pos })}
                                            style={{ flex: 1 }}
                                        >
                                            <Box 
                                                h={100} 
                                                bg="var(--mantine-color-body)" 
                                                style={{ 
                                                    border: isSelected ? '1px solid var(--mantine-color-surreal-6)' : '1px solid var(--mantine-color-default-border)', 
                                                    position: 'relative',
                                                    borderRadius: '4px',
                                                    boxShadow: isSelected ? '0 0 0 1px var(--mantine-color-surreal-6)' : undefined,
                                                    transition: 'all 0.2s'
                                                }}
                                                className="page-preview-box"
                                            >
                                                <Box 
                                                    style={{ 
                                                        position: 'absolute', 
                                                        top: 8, 
                                                        left: pos === 0 ? 8 : (pos === 1 ? '50%' : undefined), 
                                                        right: pos === 2 ? 8 : undefined, 
                                                        transform: pos === 1 ? 'translateX(-50%)' : undefined,
                                                        width: 20,
                                                        height: 2,
                                                        backgroundColor: 'var(--mantine-color-surreal-6)',
                                                        borderRadius: 1
                                                    }} 
                                                />
                                                <Stack gap={2} mt={20} px={8}>
                                                    <Box h={2} bg="var(--mantine-color-slate-1)" w="80%" />
                                                    <Box h={2} bg="var(--mantine-color-slate-1)" w="100%" />
                                                    <Box h={2} bg="var(--mantine-color-slate-1)" w="90%" />
                                                </Stack>
                                            </Box>
                                            <Text size="10px" ta="center" mt={4} c={isSelected ? 'surreal.6' : 'dimmed'} fw={isSelected ? 600 : 400}>
                                                {pos === 0 ? 'Gauche' : (pos === 1 ? 'Centre' : 'Droite')}
                                            </Text>
                                        </UnstyledButton>
                                    );
                                })}
                            </Group>
                        </Box>

                        <Box>
                            <Text size="xs" fw={600} mb={8} c="dimmed">Bas de page (Pied de page)</Text>
                            <Group gap="xs" justify="space-between">
                                {[0, 1, 2].map((pos) => {
                                    const isSelected = localSelected?.position === 'bottom' && localSelected?.alignment === pos;
                                    return (
                                        <UnstyledButton 
                                            key={`bottom-${pos}`} 
                                            onClick={() => setLocalSelected({ position: 'bottom', alignment: pos })}
                                            style={{ flex: 1 }}
                                        >
                                            <Box 
                                                h={100} 
                                                bg="var(--mantine-color-body)" 
                                                style={{ 
                                                    border: isSelected ? '1px solid var(--mantine-color-surreal-6)' : '1px solid var(--mantine-color-default-border)', 
                                                    position: 'relative',
                                                    borderRadius: '4px',
                                                    boxShadow: isSelected ? '0 0 0 1px var(--mantine-color-surreal-6)' : undefined,
                                                    transition: 'all 0.2s'
                                                }}
                                                className="page-preview-box"
                                            >
                                                <Stack gap={2} mt={8} px={8}>
                                                    <Box h={2} bg="var(--mantine-color-slate-1)" w="100%" />
                                                    <Box h={2} bg="var(--mantine-color-slate-1)" w="90%" />
                                                    <Box h={2} bg="var(--mantine-color-slate-1)" w="80%" />
                                                </Stack>
                                                <Box 
                                                    style={{ 
                                                        position: 'absolute', 
                                                        bottom: 8, 
                                                        left: pos === 0 ? 8 : (pos === 1 ? '50%' : undefined), 
                                                        right: pos === 2 ? 8 : undefined, 
                                                        transform: pos === 1 ? 'translateX(-50%)' : undefined,
                                                        width: 20,
                                                        height: 2,
                                                        backgroundColor: 'var(--mantine-color-surreal-6)',
                                                        borderRadius: 1
                                                    }} 
                                                />
                                            </Box>
                                            <Text size="10px" ta="center" mt={4} c={isSelected ? 'surreal.6' : 'dimmed'} fw={isSelected ? 600 : 400}>
                                                {pos === 0 ? 'Gauche' : (pos === 1 ? 'Centre' : 'Droite')}
                                            </Text>
                                        </UnstyledButton>
                                    );
                                })}
                            </Group>
                        </Box>
                    </Stack>
                </Box>

                <Divider />

                <Checkbox 
                    label="Inclure le nombre total de pages (ex: 1 sur 10)" 
                    size="xs" 
                    color="surreal"
                    checked={localAddTotal}
                    onChange={(event) => setLocalAddTotal(event.currentTarget.checked)}
                />

                <Group justify="space-between" mt="md">
                    <Button 
                        variant="subtle" 
                        color="red" 
                        size="xs" 
                        leftSection={<Icon path={iconTrash} size={14} stroked />}
                        onClick={handleRemove}
                        disabled={!localSelected}
                    >
                        Supprimer les numéros
                    </Button>
                    <Group gap="xs">
                        <Button variant="default" size="xs" onClick={onClose}>Annuler</Button>
                        <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                    </Group>
                </Group>
            </Stack>
        </Modal>
    );
};
