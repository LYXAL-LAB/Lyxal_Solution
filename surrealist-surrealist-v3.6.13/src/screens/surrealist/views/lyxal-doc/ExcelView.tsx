import { Box, ScrollArea, Table, Paper, Group, Stack, TextInput, Text, Button, ActionIcon } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { LyxalToolbar, LyxalToolbarGroup, LyxalToolbarAction, LyxalToolbarDivider } from "./components/LyxalToolbar";
import { 
    iconChevronLeft, 
    iconChevronRight, 
    iconFunction, 
    iconSearch,
    iconPlus,
    iconTable,
    iconText
} from "~/util/icons";
import { useState } from "react";

export function ExcelView() {
    const columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];
    const rows = Array.from({ length: 50 }, (_, i) => i + 1);
    const [selectedCell, setSelectedCell] = useState<string>("A1");

    return (
        <Stack h="100%" gap={0} id="lyxal-excel-container">
            {/* Toolbar */}
            <LyxalToolbar id="lyxal-excel-toolbar">
                <Group>
                    <LyxalToolbarGroup>
                        <LyxalToolbarAction label="Annuler" icon={iconChevronLeft} />
                        <LyxalToolbarAction label="Rétablir" icon={iconChevronRight} />
                    </LyxalToolbarGroup>
                    <LyxalToolbarDivider />
                    <LyxalToolbarGroup>
                        <LyxalToolbarAction label="Gras" style={{ fontWeight: 'bold' }}>B</LyxalToolbarAction>
                        <LyxalToolbarAction label="Italique" style={{ fontStyle: 'italic' }}>I</LyxalToolbarAction>
                        <LyxalToolbarAction label="Souligné" style={{ textDecoration: 'underline' }}>U</LyxalToolbarAction>
                    </LyxalToolbarGroup>
                    <LyxalToolbarDivider />
                    <LyxalToolbarGroup>
                         <LyxalToolbarAction label="Couleur de remplissage" icon={iconTable} />
                         <LyxalToolbarAction label="Couleur de texte" icon={iconText} />
                    </LyxalToolbarGroup>
                    <LyxalToolbarDivider />
                    <LyxalToolbarGroup>
                         <LyxalToolbarAction label="Rechercher" icon={iconSearch} />
                    </LyxalToolbarGroup>
                </Group>
            </LyxalToolbar>

            {/* Formula Bar */}
            <Paper p={4} withBorder style={{ borderRadius: 0, borderTop: 0, borderLeft: 0, borderRight: 0, backgroundColor: '#fff' }} id="lyxal-excel-formula-bar">
                <Group gap="xs">
                    <Box w={60} style={{ borderRight: '1px solid #dee2e6', textAlign: 'center' }}>
                        <Text size="sm" fw={700} c="dimmed">{selectedCell}</Text>
                    </Box>
                    <Icon path={iconFunction} size={16} color="gray" />
                    <TextInput 
                        variant="unstyled" 
                        size="xs" 
                        placeholder="fx" 
                        style={{ flex: 1 }} 
                    />
                </Group>
            </Paper>

            {/* Grid */}
            <Box flex={1} bg="white" style={{ overflow: 'hidden' }} id="lyxal-excel-grid">
                <ScrollArea h="100%">
                    <Table withTableBorder withColumnBorders style={{ tableLayout: 'fixed', minWidth: '100%' }}>
                        <Table.Thead>
                            <Table.Tr>
                                <Table.Th style={{ width: 50, textAlign: 'center', backgroundColor: '#f8f9fa', color: '#868e96', fontWeight: 500 }}>
                                    <Icon path={iconTable} size={12} />
                                </Table.Th>
                                {columns.map(col => (
                                    <Table.Th 
                                        key={col} 
                                        style={{ 
                                            width: 100, 
                                            textAlign: 'center', 
                                            backgroundColor: '#f8f9fa',
                                            fontSize: 12,
                                            fontWeight: 600,
                                            color: '#495057'
                                        }}
                                    >
                                        {col}
                                    </Table.Th>
                                ))}
                            </Table.Tr>
                        </Table.Thead>
                        <Table.Tbody>
                            {rows.map(row => (
                                <Table.Tr key={row}>
                                    <Table.Td style={{ textAlign: 'center', backgroundColor: '#f8f9fa', fontSize: 11, color: '#868e96', fontWeight: 500 }}>
                                        {row}
                                    </Table.Td>
                                    {columns.map(col => (
                                        <Table.Td 
                                            key={col} 
                                            onClick={() => setSelectedCell(`${col}${row}`)}
                                            style={{ 
                                                height: 24, 
                                                padding: '2px 6px',
                                                borderRight: '1px solid #e9ecef',
                                                borderBottom: '1px solid #e9ecef',
                                                cursor: 'cell',
                                                outline: selectedCell === `${col}${row}` ? '2px solid #228be6' : 'none',
                                                outlineOffset: -2,
                                                fontSize: 12
                                            }}
                                        >
                                            {/* Simulated content for demo */}
                                            {col === 'B' && row === 2 && 'Ventes 2024'}
                                            {col === 'B' && row === 3 && 'Q1'}
                                            {col === 'C' && row === 3 && 'Q2'}
                                            {col === 'D' && row === 3 && 'Q3'}
                                            {col === 'E' && row === 3 && 'Total'}
                                            {col === 'B' && row === 4 && '1200'}
                                            {col === 'C' && row === 4 && '1500'}
                                            {col === 'D' && row === 4 && '1100'}
                                            {col === 'E' && row === 4 && '3800'}
                                        </Table.Td>
                                    ))}
                                </Table.Tr>
                            ))}
                        </Table.Tbody>
                    </Table>
                </ScrollArea>
            </Box>

            {/* Sheet Tabs */}
            <Paper p={4} withBorder style={{ borderRadius: 0, borderBottom: 0, borderLeft: 0, borderRight: 0, backgroundColor: '#f1f3f5' }} id="lyxal-excel-sheet-tabs">
                <Group gap={2}>
                    <ActionIcon variant="subtle" size="sm" color="gray"><Icon path={iconPlus} size={14} /></ActionIcon>
                    <Button variant="white" size="xs" radius={0} style={{ borderBottom: '2px solid #228be6', color: '#228be6' }}>Feuille 1</Button>
                    <Button variant="subtle" size="xs" color="gray" radius={0}>Feuille 2</Button>
                    <Button variant="subtle" size="xs" color="gray" radius={0}>Feuille 3</Button>
                </Group>
            </Paper>
        </Stack>
    );
}

