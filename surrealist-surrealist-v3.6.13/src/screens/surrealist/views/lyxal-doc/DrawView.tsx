import { Box, Group, ActionIcon, Paper, Tooltip, Stack, Divider, Text, Slider, ColorInput } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { LyxalToolbar, LyxalToolbarGroup, LyxalToolbarAction, LyxalToolbarDivider } from "./components/LyxalToolbar";
import { 
    iconCircle,
    iconCursor,
    iconFile,
    iconList,
    iconPlus,
    iconText,
    iconChevronLeft,
    iconChevronRight,
    iconDownload
} from "~/util/icons";

export function DrawView() {
	return (
		<Stack h="100%" gap={0} id="lyxal-draw-container">
             {/* Toolbar */}
             <LyxalToolbar id="lyxal-draw-toolbar">
                <Group justify="space-between">
                    <Group>
                        <LyxalToolbarGroup>
                            <LyxalToolbarAction label="Annuler" icon={iconChevronLeft} />
                            <LyxalToolbarAction label="Rétablir" icon={iconChevronRight} />
                        </LyxalToolbarGroup>
                        <LyxalToolbarDivider />
                        <LyxalToolbarGroup>
                             <LyxalToolbarAction label="Exporter SVG" icon={iconDownload} />
                        </LyxalToolbarGroup>
                    </Group>
                </Group>
            </LyxalToolbar>

            <Box flex={1} style={{ position: 'relative', overflow: 'hidden', display: 'flex' }} id="lyxal-draw-main-area">
                {/* Tools Sidebar */}
                 <Paper 
                    withBorder 
                    p="xs" 
                    style={{ 
                        width: 48, 
                        borderTop: 0, 
                        borderBottom: 0, 
                        borderRadius: 0,
                        zIndex: 10,
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        gap: 8
                    }}
                    id="lyxal-draw-tools-sidebar"
                >
                    <Tooltip label="Sélection" position="right"><ActionIcon variant="light" color="blue"><Icon path={iconCursor} size={16} /></ActionIcon></Tooltip>
                    <Divider w="100%" />
                    <Tooltip label="Crayon" position="right"><ActionIcon variant="subtle" color="gray"><Icon path={iconPlus} size={16} /></ActionIcon></Tooltip>
                    <Tooltip label="Rectangle" position="right"><ActionIcon variant="subtle" color="gray"><Icon path={iconFile} size={16} /></ActionIcon></Tooltip>
                    <Tooltip label="Cercle" position="right"><ActionIcon variant="subtle" color="gray"><Icon path={iconCircle} size={16} /></ActionIcon></Tooltip>
                    <Tooltip label="Ligne" position="right"><ActionIcon variant="subtle" color="gray"><Icon path={iconPlus} size={16} /></ActionIcon></Tooltip>
                    <Tooltip label="Texte" position="right"><ActionIcon variant="subtle" color="gray"><Icon path={iconText} size={16} /></ActionIcon></Tooltip>
                </Paper>

                {/* Canvas Grid Background */}
                <Box 
                    flex={1}
                    style={{ 
                        cursor: 'crosshair',
                        backgroundColor: '#f8f9fa',
                        backgroundImage: 'radial-gradient(#dee2e6 1px, transparent 0)',
                        backgroundSize: '24px 24px',
                        position: 'relative'
                    }} 
                    id="lyxal-draw-canvas"
                >
                     {/* Simulated SVG Content */}
                     <svg width="100%" height="100%" style={{ position: 'absolute', top: 0, left: 0 }}>
                        <rect x="200" y="150" width="200" height="120" fill="#e7f5ff" stroke="#228be6" strokeWidth="2" />
                        <circle cx="500" cy="210" r="60" fill="#ffe3e3" stroke="#fa5252" strokeWidth="2" />
                        <text x="300" y="215" textAnchor="middle" fill="#228be6" style={{ fontFamily: 'Arial', fontSize: 14 }}>Objet Groupe</text>
                     </svg>
                </Box>

                {/* Properties Panel */}
                <Paper 
                    withBorder 
                    p="md" 
                    style={{ 
                        width: 250, 
                        borderTop: 0, 
                        borderBottom: 0, 
                        borderRadius: 0,
                        zIndex: 10,
                        backgroundColor: '#fff'
                    }}
                    id="lyxal-draw-properties-panel"
                >
                    <Stack gap="md">
                        <Group gap="xs">
                            <Icon path={iconList} size={14} />
                            <Text size="sm" fw={700}>Propriétés</Text>
                        </Group>
                        
                        <Divider />
                        
                        <Text size="xs" fw={600}>Dimensions</Text>
                        <Group grow>
                             <Text size="xs">X: 200</Text>
                             <Text size="xs">Y: 150</Text>
                        </Group>
                        <Group grow>
                             <Text size="xs">W: 200</Text>
                             <Text size="xs">H: 120</Text>
                        </Group>

                        <Divider />

                        <Text size="xs" fw={600}>Apparence</Text>
                        <Box>
                            <Text size="xs" mb={4}>Remplissage</Text>
                            <ColorInput size="xs" value="#e7f5ff" />
                        </Box>
                        <Box>
                             <Text size="xs" mb={4}>Contour</Text>
                             <ColorInput size="xs" value="#228be6" />
                        </Box>
                        <Box>
                             <Text size="xs" mb={4}>Épaisseur</Text>
                             <Slider size="xs" value={2} min={0} max={10} />
                        </Box>
                        
                        <Divider />

                        <Group gap="xs">
                            <Icon path={iconList} size={14} />
                            <Text size="sm" fw={700}>Calques</Text>
                        </Group>
                        <Stack gap={4}>
                            <Box style={{ fontSize: 11, padding: '4px 8px', backgroundColor: '#e7f5ff', borderRadius: 4, borderLeft: '3px solid #228be6' }}>
                                Rectangle (Sélectionné)
                            </Box>
                            <Box style={{ fontSize: 11, padding: '4px 8px' }}>Cercle</Box>
                            <Box style={{ fontSize: 11, padding: '4px 8px' }}>Texte</Box>
                        </Stack>
                    </Stack>
                </Paper>
            </Box>

            {/* Status Bar */}
             <Paper p={4} withBorder style={{ borderRadius: 0, borderBottom: 0, borderLeft: 0, borderRight: 0, backgroundColor: '#f8f9fa' }} id="lyxal-draw-status-bar">
                <Group justify="space-between" px="xs">
                    <Text size="xs" c="dimmed">Sélection: Rectangle</Text>
                    <Text size="xs" c="dimmed">Zoom: 100%</Text>
                </Group>
            </Paper>
		</Stack>
	);
}

