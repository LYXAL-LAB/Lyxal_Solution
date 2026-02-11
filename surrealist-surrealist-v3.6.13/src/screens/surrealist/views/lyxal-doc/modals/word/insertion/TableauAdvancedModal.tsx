import { Modal, Stack, Tooltip, NumberInput, Group, Button } from "@mantine/core";
import { useState, useEffect } from "react";

interface TableauAdvancedModalProps {
    opened: boolean;
    onClose: () => void;
    numCols: number;
    setNumCols: (v: number) => void;
    numRows: number;
    setNumRows: (v: number) => void;
}

export function TableauAdvancedModal({
    opened,
    onClose,
    numCols,
    setNumCols,
    numRows,
    setNumRows
}: TableauAdvancedModalProps) {
    const [localCols, setLocalCols] = useState(numCols);
    const [localRows, setLocalRows] = useState(numRows);

    useEffect(() => {
        if (opened) {
            setLocalCols(numCols);
            setLocalRows(numRows);
        }
    }, [opened, numCols, numRows]);

    const handleApply = () => {
        setNumCols(localCols);
        setNumRows(localRows);
        onClose();
    };

    return (
        <Modal 
            opened={opened} 
            onClose={onClose} 
            title="Insérer un tableau" 
            centered 
            size="xs"
            styles={{
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' }
            }}
        >
            <Stack gap="md">
                <Tooltip label="Entrez un nombre entier compris entre 1 et 63." position="right" withArrow>
                    <NumberInput 
                        label="Nombre de colonnes :" 
                        value={localCols} 
                        onChange={(v) => setLocalCols(Number(v) || 1)} 
                        min={1} 
                        max={63} 
                        size="xs" 
                    />
                </Tooltip>
                <Tooltip label="Entrez un nombre entier compris entre 1 et 100." position="right" withArrow>
                    <NumberInput 
                        label="Nombre de lignes :" 
                        value={localRows} 
                        onChange={(v) => setLocalRows(Number(v) || 1)} 
                        min={1} 
                        max={100} 
                        size="xs" 
                    />
                </Tooltip>
                <Group justify="end" mt="md">
                    <Button variant="subtle" color="slate" size="xs" onClick={onClose}>Annuler</Button>
                    <Button color="surreal" size="xs" onClick={handleApply}>Appliquer</Button>
                </Group>
            </Stack>
        </Modal>
    );
}
