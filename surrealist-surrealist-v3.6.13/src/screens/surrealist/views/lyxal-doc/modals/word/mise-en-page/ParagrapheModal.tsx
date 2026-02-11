import { Box, Text, Group, Stack, Button, Modal, Tabs, Checkbox, Select, NumberInput, Divider, Tooltip, ActionIcon } from "@mantine/core";
import { useState, useEffect } from "react";
import { Icon } from "~/components/Icon";
import { iconTrash } from "~/util/icons";

interface ParagrapheValues {
    alignment: string;
    indentLeft: number;
    indentRight: number;
    indentSpecial: string;
    indentSpecialValue: number;
    spaceBefore: number;
    spaceAfter: number;
    lineSpacing: string;
    lineSpacingValue: number;
    spaceAuto: boolean;
    keepWithNext: boolean;
    widowControl: boolean;
    keepLinesTogether: boolean;
    pageBreakBefore: boolean;
}

interface TabStop {
    id: string;
    position: number;
    alignment: string;
    leader: string;
}

interface ParagrapheModalProps {
    opened: boolean;
    onClose: () => void;
    paragrapheValues: ParagrapheValues;
    setParagrapheValues: (v: ParagrapheValues) => void;
    tabStops: TabStop[];
    setTabStops: (v: TabStop[]) => void;
    defaultTabStop: number;
    setDefaultTabStop: (v: number) => void;
    newTabStop: { position: number, alignment: string, leader: string };
    setNewTabStop: (v: { position: number, alignment: string, leader: string }) => void;
    defaultParagrapheValues: ParagrapheValues;
}

export function ParagrapheModal({
    opened,
    onClose,
    paragrapheValues,
    setParagrapheValues,
    tabStops,
    setTabStops,
    defaultTabStop,
    setDefaultTabStop,
    newTabStop,
    setNewTabStop,
    defaultParagrapheValues
}: ParagrapheModalProps) {
    const [activeParagrapheTab, setActiveParagrapheTab] = useState('indents');
    const [localValues, setLocalValues] = useState(paragrapheValues);
    const [localTabs, setLocalTabs] = useState(tabStops);
    const [localDefaultTab, setLocalDefaultTab] = useState(defaultTabStop);
    const [localNewTab, setLocalNewTab] = useState(newTabStop);

    useEffect(() => {
        if (opened) {
            setLocalValues(paragrapheValues);
            setLocalTabs(tabStops);
            setLocalDefaultTab(defaultTabStop);
            setLocalNewTab(newTabStop);
        }
    }, [opened, paragrapheValues, tabStops, defaultTabStop, newTabStop]);

    const handleApply = () => {
        setParagrapheValues(localValues);
        setTabStops(localTabs);
        setDefaultTabStop(localDefaultTab);
        setNewTabStop(localNewTab);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Paragraphe" 
            centered 
            size="md"
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' }
            }}
        >
            <Stack gap="md">
                <Group 
                    gap={2} 
                    px="xs" 
                    bg="transparent"
                    style={{ borderBottom: '1px solid var(--mantine-color-default-border)' }}
                >
                    {[
                        { value: 'indents', label: 'Retrait et espacement' },
                        { value: 'breaks', label: 'Pagination et tabulations' }
                    ].map((tab) => (
                        <Button
                            key={tab.value}
                            variant="subtle"
                            size="xs"
                            radius="xs"
                            style={{ 
                                border: 'none',
                                borderBottom: activeParagrapheTab === tab.value ? '2px solid var(--mantine-color-surreal-6)' : '2px solid transparent',
                                borderRadius: 0,
                                backgroundColor: 'transparent',
                                color: activeParagrapheTab === tab.value ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-text)',
                                fontWeight: activeParagrapheTab === tab.value ? 600 : 400,
                                height: 32
                            }}
                            onClick={() => setActiveParagrapheTab(tab.value)}
                        >
                            {tab.label}
                        </Button>
                    ))}
                </Group>

                {activeParagrapheTab === 'indents' ? (
                    <Stack gap="md">
                        <Divider label="Général" labelPosition="left" />
                        <Group grow>
                            <Select 
                                label="Alignement :" 
                                size="xs" 
                                value={localValues.alignment}
                                onChange={(v) => setLocalValues({...localValues, alignment: v || 'left'})}
                                data={[
                                    { value: 'left', label: 'Gauche' },
                                    { value: 'center', label: 'Centré' },
                                    { value: 'right', label: 'Droite' },
                                    { value: 'justify', label: 'Justifié' }
                                ]}
                            />
                        </Group>

                        <Divider label="Retrait" labelPosition="left" />
                        <Stack gap="xs">
                            <Group grow>
                                <NumberInput 
                                    label="Gauche :" 
                                    value={localValues.indentLeft}
                                    onChange={(v) => setLocalValues({...localValues, indentLeft: Number(v) || 0})}
                                    suffix=" cm" 
                                    decimalScale={2} 
                                    size="xs" 
                                />
                                <NumberInput 
                                    label="Droite :" 
                                    value={localValues.indentRight}
                                    onChange={(v) => setLocalValues({...localValues, indentRight: Number(v) || 0})}
                                    suffix=" cm" 
                                    decimalScale={2} 
                                    size="xs" 
                                />
                            </Group>
                            <Group grow align="flex-end">
                                <Select 
                                    label="Spécial :" 
                                    size="xs" 
                                    value={localValues.indentSpecial}
                                    onChange={(v) => {
                                        const newType = v || 'none';
                                        setLocalValues({
                                            ...localValues, 
                                            indentSpecial: newType,
                                            indentSpecialValue: newType === 'none' ? 0 : (localValues.indentSpecialValue || 1.25)
                                        });
                                    }}
                                    data={[
                                        { value: 'none', label: '(aucun)' },
                                        { value: 'firstLine', label: 'Première ligne' },
                                        { value: 'hanging', label: 'Négatif' }
                                    ]}
                                />
                                <NumberInput 
                                    label="De :" 
                                    value={localValues.indentSpecial === 'none' ? undefined : localValues.indentSpecialValue}
                                    onChange={(v) => setLocalValues({...localValues, indentSpecialValue: Number(v) || 0})}
                                    suffix=" cm" 
                                    decimalScale={2} 
                                    size="xs" 
                                    disabled={localValues.indentSpecial === 'none'}
                                />
                            </Group>
                        </Stack>

                        <Divider label="Espacement" labelPosition="left" />
                        <Stack gap="xs">
                            <Group grow>
                                <NumberInput 
                                    label="Avant :" 
                                    value={localValues.spaceBefore}
                                    onChange={(v) => setLocalValues({...localValues, spaceBefore: Number(v) || 0})}
                                    suffix=" pt" 
                                    size="xs" 
                                />
                                <NumberInput 
                                    label="Après :" 
                                    value={localValues.spaceAfter}
                                    onChange={(v) => setLocalValues({...localValues, spaceAfter: Number(v) || 0})}
                                    suffix=" pt" 
                                    size="xs" 
                                />
                            </Group>
                            <Group grow align="flex-end">
                                <Select 
                                    label="Interligne :" 
                                    size="xs" 
                                    value={localValues.lineSpacing}
                                    onChange={(v) => {
                                        const type = v || 'multiple';
                                        setLocalValues({
                                            ...localValues, 
                                            lineSpacing: type,
                                            lineSpacingValue: ['unique', '1.5lines', 'double'].includes(type) ? 0 : (localValues.lineSpacingValue || 1)
                                        });
                                    }}
                                    data={[
                                        { value: 'unique', label: 'Unique' },
                                        { value: '1.5lines', label: '1,5 ligne' },
                                        { value: 'double', label: 'Double' },
                                        { value: 'atLeast', label: 'Au minimum' },
                                        { value: 'exact', label: 'Exactement' },
                                        { value: 'multiple', label: 'Multiple' }
                                    ]}
                                />
                                <NumberInput 
                                    label="De :" 
                                    value={['unique', '1.5lines', 'double'].includes(localValues.lineSpacing) ? undefined : localValues.lineSpacingValue}
                                    onChange={(v) => setLocalValues({...localValues, lineSpacingValue: Number(v) || 0})}
                                    suffix={['atLeast', 'exact'].includes(localValues.lineSpacing) ? " pt" : ""}
                                    decimalScale={2} 
                                    size="xs" 
                                    disabled={['unique', '1.5lines', 'double'].includes(localValues.lineSpacing)}
                                />
                            </Group>
                            <Checkbox 
                                label="Ne pas ajouter d'espace entre les paragraphes du même style" 
                                size="xs" 
                                color="surreal"
                                checked={localValues.spaceAuto}
                                onChange={(e) => setLocalValues({...localValues, spaceAuto: e.currentTarget.checked})}
                            />
                        </Stack>
                    </Stack>
                ) : (
                    <Stack gap="xs">
                        <Divider label="Pagination" labelPosition="left" />
                        <Checkbox 
                            label="Gestion des veuves et des orphelins" 
                            size="xs" 
                            color="surreal"
                            checked={localValues.widowControl}
                            onChange={(e) => setLocalValues({...localValues, widowControl: e.currentTarget.checked})}
                        />
                        <Checkbox 
                            label="Paragraphes solidaires" 
                            size="xs" 
                            color="surreal"
                            checked={localValues.keepWithNext}
                            onChange={(e) => setLocalValues({...localValues, keepWithNext: e.currentTarget.checked})}
                        />
                        <Checkbox 
                            label="Maintenir les lignes ensemble" 
                            size="xs" 
                            color="surreal"
                            checked={localValues.keepLinesTogether}
                            onChange={(e) => setLocalValues({...localValues, keepLinesTogether: e.currentTarget.checked})}
                        />
                        <Checkbox 
                            label="Saut de page avant" 
                            size="xs" 
                            color="surreal"
                            checked={localValues.pageBreakBefore}
                            onChange={(e) => setLocalValues({...localValues, pageBreakBefore: e.currentTarget.checked})}
                        />

                        <Divider label="Tabulations" labelPosition="left" mt="md" />
                        
                        <Stack gap="xs">
                            <Group align="flex-end" gap="xs" wrap="nowrap">
                                <NumberInput 
                                    label="Poste :" 
                                    value={localNewTab.position} 
                                    onChange={(v) => setLocalNewTab({...localNewTab, position: Number(v) || 0})}
                                    size="xs" 
                                    w={85}
                                    suffix=" cm" 
                                    decimalScale={2} 
                                />
                                <Select 
                                    label="Alignement :"
                                    size="xs"
                                    style={{ flex: 1 }}
                                    value={localNewTab.alignment}
                                    onChange={(v) => setLocalNewTab({...localNewTab, alignment: v || 'left'})}
                                    data={[
                                        { value: 'left', label: 'Gauche' },
                                        { value: 'center', label: 'Centré' },
                                        { value: 'right', label: 'Droite' }
                                    ]}
                                />
                                <Select 
                                    label="Points de suite :"
                                    size="xs"
                                    style={{ flex: 1 }}
                                    value={localNewTab.leader}
                                    onChange={(v) => setLocalNewTab({...localNewTab, leader: v || 'none'})}
                                    data={[
                                        { value: 'none', label: 'Aucun' },
                                        { value: 'dotted', label: '.......' },
                                        { value: 'dashed', label: '-------' },
                                        { value: 'underline', label: '_______' }
                                    ]}
                                    renderOption={({ option }) => (
                                        <Tooltip label={
                                            option.value === 'none' ? 'Aucun' : 
                                            option.value === 'dotted' ? 'Points' : 
                                            option.value === 'dashed' ? 'Tirets' : 'Souligné'
                                        } position="right" withArrow>
                                            <Group gap="xs" justify="space-between" style={{ width: '100%' }}>
                                                <Text size="xs">{option.label}</Text>
                                            </Group>
                                        </Tooltip>
                                    )}
                                />
                                <Button 
                                    variant="light" 
                                    color="surreal" 
                                    size="xs"
                                    px="xl"
                                    onClick={() => {
                                        const id = Math.random().toString(36).substr(2, 9);
                                        setLocalTabs([...localTabs, { ...localNewTab, id }].sort((a, b) => a.position - b.position));
                                        setLocalNewTab({ position: 0, alignment: 'left', leader: 'none' });
                                    }}
                                >
                                    Ajouter
                                </Button>
                            </Group>

                            <Box 
                                mih={80} 
                                style={{ 
                                    border: '1px solid var(--mantine-color-default-border)', 
                                    borderRadius: '4px', 
                                    overflowY: 'auto',
                                    maxHeight: 120
                                }} 
                                bg="var(--mantine-color-body)"
                                p={4}
                            >
                                {localTabs.length === 0 ? (
                                    <Text size="xs" c="dimmed" style={{ textAlign: 'center', marginTop: 30 }}>Aucun taquet défini</Text>
                                ) : (
                                    <Stack gap={2}>
                                        {localTabs.map((stop) => (
                                            <Group key={stop.id} justify="space-between" px="xs" py={2} style={{ borderRadius: '2px' }} className="tab-stop-item">
                                                <Group gap="xl">
                                                    <Text size="xs" fw={600} w={50}>{stop.position.toFixed(2)} cm</Text>
                                                    <Text size="xs" w={60}>{stop.alignment === 'left' ? 'Gauche' : stop.alignment === 'right' ? 'Droite' : 'Centré'}</Text>
                                                    <Text size="xs" c="dimmed">{
                                                        stop.leader === 'none' ? 'Aucun' : 
                                                        stop.leader === 'dotted' ? '.......' : 
                                                        stop.leader === 'dashed' ? '-------' : '_______'
                                                    }</Text>
                                                </Group>
                                                <ActionIcon 
                                                    variant="subtle" 
                                                    color="red" 
                                                    size="xs" 
                                                    onClick={() => setLocalTabs(localTabs.filter(s => s.id !== stop.id))}
                                                >
                                                    <Icon path={iconTrash} size={12} stroked />
                                                </ActionIcon>
                                            </Group>
                                        ))}
                                    </Stack>
                                )}
                            </Box>

                            <Group justify="space-between" mt="xs">
                                <Group gap="xs">
                                    <Text size="xs">Taquets de tabulations par défaut :</Text>
                                    <NumberInput 
                                        value={localDefaultTab} 
                                        onChange={(v) => setLocalDefaultTab(Number(v) || 0)}
                                        size="xs" 
                                        w={80}
                                        suffix=" cm" 
                                        decimalScale={2} 
                                    />
                                </Group>
                                <Button variant="subtle" color="slate" size="xs" onClick={() => setLocalTabs([])}>Effacer tout</Button>
                            </Group>
                        </Stack>
                    </Stack>
                )}

                <Group justify="end" mt="md">
                    <Button variant="subtle" color="slate" size="xs" onClick={() => {
                        setLocalValues(defaultParagrapheValues);
                        setLocalTabs([]);
                        setLocalDefaultTab(1.25);
                        setLocalNewTab({ position: 0, alignment: 'left', leader: 'none' });
                    }}>Rétablir</Button>
                    <Button variant="subtle" color="slate" size="xs" onClick={onClose}>Annuler</Button>
                    <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                </Group>
            </Stack>
        </Modal>
    );
}

