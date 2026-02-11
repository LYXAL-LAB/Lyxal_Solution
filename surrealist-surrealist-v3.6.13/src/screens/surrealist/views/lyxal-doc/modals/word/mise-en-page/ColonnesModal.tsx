import { Box, Text, Group, Stack, Button, Modal, Checkbox, NumberInput, Divider, Tooltip, UnstyledButton } from "@mantine/core";
import { useState, useEffect } from "react";

interface ColonnesModalProps {
    opened: boolean;
    onClose: () => void;
    selectedColonnesType: string;
    setSelectedColonnesType: (v: string) => void;
    numColonnesValue: number | string;
    setNumColonnesValue: (v: number | string) => void;
    equalWidths: boolean;
    setEqualWidths: (v: boolean) => void;
    lineBetween: boolean;
    setLineBetween: (v: boolean) => void;
    columnWidths: number[];
    setColumnWidths: (v: number[]) => void;
    columnSpacings: number[];
    setColumnSpacings: (v: number[]) => void;
    disponibleWidth: number;
}

export function ColonnesModal({
    opened,
    onClose,
    selectedColonnesType,
    setSelectedColonnesType,
    numColonnesValue,
    setNumColonnesValue,
    equalWidths,
    setEqualWidths,
    lineBetween,
    setLineBetween,
    columnWidths,
    setColumnWidths,
    columnSpacings,
    setColumnSpacings,
    disponibleWidth
}: ColonnesModalProps) {
    const [localType, setLocalType] = useState(selectedColonnesType);
    const [localNum, setLocalNum] = useState(numColonnesValue);
    const [localEqual, setLocalEqual] = useState(equalWidths);
    const [localLine, setLocalLine] = useState(lineBetween);
    const [localWidths, setLocalWidths] = useState(columnWidths);
    const [localSpacings, setLocalSpacings] = useState(columnSpacings);

    useEffect(() => {
        if (opened) {
            setLocalType(selectedColonnesType);
            setLocalNum(numColonnesValue);
            setLocalEqual(equalWidths);
            setLocalLine(lineBetween);
            setLocalWidths(columnWidths);
            setLocalSpacings(columnSpacings);
        }
    }, [opened, selectedColonnesType, numColonnesValue, equalWidths, lineBetween, columnWidths, columnSpacings]);

    const handleApply = () => {
        setSelectedColonnesType(localType);
        setNumColonnesValue(localNum);
        setEqualWidths(localEqual);
        setLineBetween(localLine);
        setColumnWidths(localWidths);
        setColumnSpacings(localSpacings);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Colonnes" 
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
                        { id: 'one', label: 'Une', count: 1 },
                        { id: 'two', label: 'Deux', count: 2 },
                        { id: 'three', label: 'Trois', count: 3 },
                        { id: 'left', label: 'Gauche', count: 2 },
                        { id: 'right', label: 'Droite', count: 2 },
                        { id: 'custom', label: 'Personnalisé', count: localNum },
                    ].map((col) => (
                        <UnstyledButton 
                            key={col.id}
                            onClick={() => {
                                setLocalType(col.id);
                                const count = typeof col.count === 'string' ? parseInt(col.count) : col.count;
                                
                                if (col.id === 'left') {
                                    setLocalNum(2);
                                    setLocalEqual(false);
                                    const spacing = 1.27;
                                    const narrow = 4.7; 
                                    const available = disponibleWidth - spacing;
                                    const w1 = parseFloat(Math.min(narrow, available - 1.27).toFixed(2));
                                    const w2 = parseFloat((available - w1).toFixed(2));
                                    
                                    setLocalWidths([w1, w2]);
                                    setLocalSpacings([spacing]);
                                }
                                else if (col.id === 'right') {
                                    setLocalNum(2);
                                    setLocalEqual(false);
                                    const spacing = 1.27;
                                    const narrow = 4.7;
                                    const available = disponibleWidth - spacing;
                                    const w2 = parseFloat(Math.min(narrow, available - 1.27).toFixed(2));
                                    const w1 = parseFloat((available - w2).toFixed(2));
                                    
                                    setLocalWidths([w1, w2]);
                                    setLocalSpacings([spacing]);
                                }
                                else if (col.id !== 'custom') {
                                    setLocalNum(count);
                                    setLocalEqual(true);
                                    
                                    if (count === 1) {
                                        setLocalWidths([disponibleWidth]);
                                        setLocalSpacings([]);
                                    } else {
                                        const s = 1.27;
                                        const w = parseFloat(((disponibleWidth - (s * (count - 1))) / count).toFixed(2));
                                        setLocalWidths(Array(count).fill(w));
                                        setLocalSpacings(Array(count - 1).fill(s));
                                    }
                                }
                            }}
                            style={{
                                border: `1px solid ${localType === col.id ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`,
                                borderRadius: '4px',
                                padding: '8px',
                                width: 'calc(33.33% - 8px)',
                                backgroundColor: 'transparent',
                                transition: 'all 0.2s',
                                boxShadow: localType === col.id ? '0 0 0 1px var(--mantine-color-surreal-6)' : 'none'
                            }}
                        >
                            <Stack gap={4} align="center">
                                <Box 
                                    w={40} 
                                    h={40} 
                                    bg="var(--mantine-color-body)" 
                                    style={{ 
                                        border: '1px solid var(--mantine-color-default-border)',
                                        position: 'relative',
                                        display: 'flex',
                                        gap: 2,
                                        padding: 4
                                    }}
                                >
                                    {col.id === 'one' && <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />}
                                    {col.id === 'two' && <>
                                        <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                        <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                    </>}
                                    {col.id === 'three' && <>
                                        <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                        <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                        <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                    </>}
                                    {col.id === 'left' && <>
                                        <Box w={8} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                        <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                    </>}
                                    {col.id === 'right' && <>
                                        <Box flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                        <Box w={8} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                    </>}
                                    {col.id === 'custom' && Array.from({ length: Math.min(Number(localNum) || 1, 4) }).map((_, i) => (
                                        <Box key={i} flex={1} bg="var(--mantine-color-slate-1)" style={{ border: '1px solid var(--mantine-color-surreal-6)', opacity: 0.5 }} />
                                    ))}
                                </Box>
                                <Text size="xs" fw={500} style={{ textAlign: 'center' }}>{col.label}</Text>
                            </Stack>
                        </UnstyledButton>
                    ))}
                </Group>

                <Divider label="Paramètres personnalisés" labelPosition="center" />
                
                <Tooltip label="Entrez un nombre entier entre 1 et 12." position="top" withArrow>
                <NumberInput 
                    label="Nombre de colonnes" 
                    value={localNum} 
                    onChange={(v) => {
                        const n = Number(v) || 1;
                        setLocalNum(n);
                        if (n > 1) setLocalType('custom');
                        
                        if (n === 1) {
                            setLocalWidths([disponibleWidth]);
                            setLocalSpacings([]);
                            return;
                        }

                        // Valeurs par défaut Microsoft Word
                        const defaultS = 1.27;
                        const totalS = defaultS * (n - 1);
                        let actualS = defaultS;
                        
                        // Si l'espacement par défaut ne laisse pas 1.27cm par colonne
                        if (totalS > disponibleWidth - (n * 1.27)) {
                            actualS = Math.max(0, (disponibleWidth - (n * 1.27)) / (n - 1));
                        }

                        const colW = parseFloat(((disponibleWidth - (actualS * (n - 1))) / n).toFixed(2));
                        const newWidths = Array(n).fill(colW);
                        const newSpacings = Array(n - 1).fill(parseFloat(actualS.toFixed(2)));
                        
                        setLocalWidths(newWidths);
                        setLocalSpacings(newSpacings);
                    }}
                    disabled={localType !== 'custom'}
                    min={1}
                    max={12}
                    size="xs" 
                />
                </Tooltip>

                <Group gap="xl" mt="xs">
                <Checkbox 
                    label="Largeur de colonne identique" 
                    size="xs" 
                    checked={localEqual}
                    disabled={localType === 'left' || localType === 'right' || localType === 'one'}
                    onChange={(e) => {
                        const isChecked = e.currentTarget.checked;
                        setLocalEqual(isChecked);
                        
                        if (isChecked && Number(localNum) > 1) {
                            // Appliquer l'espacement de la première colonne à tous
                            const firstSpacing = localSpacings[0] || 1.27;
                            const n = Number(localNum);
                            const totalSpacing = firstSpacing * (n - 1);
                            
                            // Calculer la nouvelle largeur unique
                            const newW = Math.max(1.27, (disponibleWidth - totalSpacing) / n);
                            const actualSpacing = parseFloat(((disponibleWidth - (newW * n)) / (n - 1)).toFixed(2));
                            
                            setLocalWidths(Array(n).fill(parseFloat(newW.toFixed(2))));
                            setLocalSpacings(Array(n - 1).fill(actualSpacing));
                        }
                    }} 
                />
                    <Checkbox 
                        label="Ligne séparatrice" 
                        size="xs" 
                        checked={localLine} 
                        onChange={(e) => setLocalLine(e.currentTarget.checked)} 
                    />
                </Group>

                <Divider label="Largeur et espacement" labelPosition="center" mt="md" />
                
                <Box>
                    <Stack gap="xs">
                        <Group grow gap="xs">
                            <Text size="xs" fw={700} w={40}>Col.</Text>
                            <Text size="xs" fw={700}>Largeur</Text>
                            <Text size="xs" fw={700}>Espacement</Text>
                        </Group>
                        
                        {localEqual ? (
                            <Group grow gap="xs">
                                <Text size="xs" w={40}>Toutes:</Text>
                                <Tooltip 
                                    label={Number(localNum) <= 1 ? "Largeur fixe." : `Entrez un nombre entre 1,27 cm et ${parseFloat((disponibleWidth - (Math.max(0, (Number(localNum) || 1) - 1) * 0)).toFixed(2))} cm.`} 
                                    position="top" 
                                    withArrow
                                >
                                    <NumberInput 
                                        size="xs" 
                                        value={localWidths[0] || disponibleWidth} 
                                        onChange={(v) => {
                                            const val = Number(v) || 1.27;
                                            const n = Number(localNum) || 1;
                                            if (n > 1) {
                                                const totalW = val * n;
                                                const potentialS = (disponibleWidth - totalW) / (n - 1);
                                                if (potentialS >= 0) {
                                                    setLocalWidths(Array(n).fill(val));
                                                    setLocalSpacings(Array(n - 1).fill(parseFloat(potentialS.toFixed(2))));
                                                }
                                            }
                                        }}
                                        min={1.27}
                                        max={parseFloat((disponibleWidth / (Number(localNum) || 1)).toFixed(2))}
                                        suffix=" cm" 
                                        decimalScale={2} 
                                        disabled={Number(localNum) <= 1 || ['left', 'right'].includes(localType)}
                                    />
                                </Tooltip>
                                <Tooltip 
                                    label={Number(localNum) <= 1 ? "Désactivé." : `Entrez un nombre entre 0 cm et ${parseFloat((disponibleWidth - (Number(localNum) * 1.27)).toFixed(2))} cm.`} 
                                    position="top" 
                                    withArrow
                                >
                                    <NumberInput 
                                        size="xs" 
                                        value={Number(localNum) <= 1 ? "" : (localSpacings[0] || 0)} 
                                        onChange={(v) => {
                                            const val = Number(v) || 0;
                                            const n = Number(localNum) || 1;
                                            if (n > 1) {
                                                const totalS = val * (n - 1);
                                                const potentialW = (disponibleWidth - totalS) / n;
                                                if (potentialW >= 1.27) {
                                                    setLocalSpacings(Array(n - 1).fill(val));
                                                    setLocalWidths(Array(n).fill(parseFloat(potentialW.toFixed(2))));
                                                }
                                            }
                                        }}
                                        min={0}
                                        max={parseFloat((disponibleWidth - (Number(localNum) * 1.27)).toFixed(2))}
                                        suffix=" cm" 
                                        decimalScale={2} 
                                        disabled={Number(localNum) <= 1 || ['left', 'right'].includes(localType)} 
                                        placeholder={Number(localNum) <= 1 ? "" : "0"}
                                    />
                                </Tooltip>
                            </Group>
                        ) : (
                            localWidths.map((w, i) => {
                                const isLast = i === localWidths.length - 1;
                                const n = localWidths.length;
                                
                                const maxWidthStatic = parseFloat((disponibleWidth - (n - 1) * 0).toFixed(2));
                                const maxSpacingStatic = parseFloat((disponibleWidth - n * 1.27).toFixed(2));

                                return (
                                    <Group key={`${i}-${localNum}`} grow gap="xs">
                                        <Text size="xs" w={40}>{i + 1}:</Text>
                                        <Tooltip label={`Entrez un nombre entre 1,27 cm et ${maxWidthStatic} cm.`} position="top" withArrow>
                                            <NumberInput 
                                                size="xs" 
                                                value={w} 
                                                onChange={(v) => {
                                                    const val = Number(v) || 1.27;
                                                    const newWidths = [...localWidths];
                                                    const newSpacings = [...localSpacings];
                                                    const oldVal = newWidths[i];
                                                    let delta = val - oldVal;

                                                    // On applique la valeur cible
                                                    newWidths[i] = val;
                                                    
                                                    if (delta > 0) {
                                                        // AUGMENTATION : On réduit les autres colonnes d'abord
                                                        let remainingDelta = delta;
                                                        
                                                        // 1. Réduire les colonnes à droite puis à gauche
                                                        for (let j = 0; j < n; j++) {
                                                            if (i === j) continue;
                                                            const canTake = Math.max(0, newWidths[j] - 1.27);
                                                            const take = Math.min(remainingDelta, canTake);
                                                            newWidths[j] = parseFloat((newWidths[j] - take).toFixed(2));
                                                            remainingDelta -= take;
                                                            if (remainingDelta < 0.001) break;
                                                        }

                                                        // 2. Si pas assez, réduire TOUS les espacements équitablement
                                                        if (remainingDelta > 0.001 && newSpacings.length > 0) {
                                                            const totalSpacings = newSpacings.reduce((a, b) => a + b, 0);
                                                            const takeFromSpacings = Math.min(remainingDelta, totalSpacings);
                                                            
                                                            if (takeFromSpacings > 0) {
                                                                const ratio = 1 - (takeFromSpacings / totalSpacings);
                                                                for (let k = 0; k < newSpacings.length; k++) {
                                                                    newSpacings[k] = parseFloat((newSpacings[k] * ratio).toFixed(2));
                                                                }
                                                                remainingDelta -= takeFromSpacings;
                                                            }
                                                        }

                                                        // Si toujours pas bon, on annule (limite atteinte)
                                                        if (remainingDelta > 0.01) {
                                                            newWidths[i] = parseFloat((val - remainingDelta).toFixed(2));
                                                        }

                                                    } else if (delta < 0) {
                                                        // DIMINUTION : On augmente la colonne suivante (ou précédente si dernière)
                                                        const targetIdx = i < n - 1 ? i + 1 : i - 1;
                                                        if (targetIdx >= 0) {
                                                            newWidths[targetIdx] = parseFloat((newWidths[targetIdx] + Math.abs(delta)).toFixed(2));
                                                        }
                                                    }

                                                    setLocalWidths(newWidths);
                                                    setLocalSpacings(newSpacings);
                                                }}
                                                min={1.27}
                                                max={maxWidthStatic}
                                                suffix=" cm" 
                                                decimalScale={2} 
                                                disabled={['left', 'right'].includes(localType)}
                                            />
                                        </Tooltip>
                                        <Tooltip label={isLast ? "Désactivé." : `Entrez un nombre entre 0 cm et ${maxSpacingStatic} cm.`} position="top" withArrow>
                                            <NumberInput 
                                                size="xs" 
                                                value={isLast ? "" : (localSpacings[i] || 0)} 
                                                onChange={(v) => {
                                                    const val = Number(v) || 0;
                                                    const newSpacings = [...localSpacings];
                                                    const newWidths = [...localWidths];
                                                    let delta = val - (newSpacings[i] || 0);

                                                    newSpacings[i] = val;

                                                    if (delta > 0) {
                                                        // AUGMENTATION ESPACEMENT
                                                        let remainingDelta = delta;

                                                        // 1. Compenser sur les colonnes APRÈS
                                                        const colsAfter = newWidths.slice(i + 1);
                                                        if (colsAfter.length > 0) {
                                                            const availableAfter = colsAfter.reduce((acc, w) => acc + Math.max(0, w - 1.27), 0);
                                                            const takeFromAfter = Math.min(remainingDelta, availableAfter);
                                                            
                                                            if (takeFromAfter > 0) {
                                                                const ratio = takeFromAfter / availableAfter;
                                                                for (let k = i + 1; k < n; k++) {
                                                                    const canGive = Math.max(0, newWidths[k] - 1.27);
                                                                    const take = parseFloat((canGive * ratio).toFixed(2));
                                                                    newWidths[k] = parseFloat((newWidths[k] - take).toFixed(2));
                                                                }
                                                                remainingDelta -= takeFromAfter;
                                                            }
                                                        }

                                                        // 2. Compenser sur les colonnes AVANT
                                                        if (remainingDelta > 0.01) {
                                                            const colsBefore = newWidths.slice(0, i + 1);
                                                            const availableBefore = colsBefore.reduce((acc, w) => acc + Math.max(0, w - 1.27), 0);
                                                            const takeFromBefore = Math.min(remainingDelta, availableBefore);

                                                            if (takeFromBefore > 0) {
                                                                const ratio = takeFromBefore / availableBefore;
                                                                for (let k = 0; k <= i; k++) {
                                                                    const canGive = Math.max(0, newWidths[k] - 1.27);
                                                                    const take = parseFloat((canGive * ratio).toFixed(2));
                                                                    newWidths[k] = parseFloat((newWidths[k] - take).toFixed(2));
                                                                }
                                                                remainingDelta -= takeFromBefore;
                                                            }
                                                        }

                                                        // 3. Compenser sur les autres espacements
                                                        if (remainingDelta > 0.01) {
                                                            const otherSpacingsIndices = newSpacings.map((_, idx) => idx).filter(idx => idx !== i);
                                                            const availableSpacings = otherSpacingsIndices.reduce((acc, idx) => acc + newSpacings[idx], 0);
                                                            const takeFromSpacings = Math.min(remainingDelta, availableSpacings);

                                                            if (takeFromSpacings > 0) {
                                                                const ratio = takeFromSpacings / availableSpacings;
                                                                otherSpacingsIndices.forEach(idx => {
                                                                    const take = parseFloat((newSpacings[idx] * ratio).toFixed(2));
                                                                    newSpacings[idx] = parseFloat((newSpacings[idx] - take).toFixed(2));
                                                                });
                                                                remainingDelta -= takeFromSpacings;
                                                            }
                                                        }
                                                        
                                                        if (remainingDelta > 0.01) {
                                                            newSpacings[i] = parseFloat((val - remainingDelta).toFixed(2));
                                                        }

                                                    } else if (delta < 0) {
                                                        // DIMINUTION ESPACEMENT
                                                        const colsAfterCount = n - (i + 1);
                                                        if (colsAfterCount > 0) {
                                                            const addPerCol = Math.abs(delta) / colsAfterCount;
                                                            for (let k = i + 1; k < n; k++) {
                                                                newWidths[k] = parseFloat((newWidths[k] + addPerCol).toFixed(2));
                                                            }
                                                        }
                                                    }

                                                    setLocalSpacings(newSpacings);
                                                    setLocalWidths(newWidths);
                                                }}
                                                min={0}
                                                max={maxSpacingStatic}
                                                suffix=" cm" 
                                                decimalScale={2} 
                                                disabled={isLast || ['left', 'right'].includes(localType)} 
                                                placeholder={isLast ? "" : "0"}
                                            />
                                        </Tooltip>
                                    </Group>
                                );
                            })
                        )}
                    </Stack>
                </Box>

                <Group justify="end" mt="xl">
                    <Button variant="subtle" color="slate" size="xs" onClick={onClose}>Annuler</Button>
                    <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                </Group>
            </Stack>
        </Modal>
    );
}

