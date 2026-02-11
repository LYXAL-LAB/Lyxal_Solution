import { Box, Paper, Stack, Text, Flex, Title, Group, ScrollArea } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { LyxalToolbar, LyxalToolbarGroup, LyxalToolbarAction, LyxalToolbarDivider } from "./components/LyxalToolbar";
import { 
    iconPlus, 
    iconPlay, 
    iconText, 
    iconImage, 
    iconCursor,
    iconChevronLeft,
    iconChevronRight
} from "~/util/icons";

export function SlidesView() {
    return (
        <Stack h="100%" gap={0} id="lyxal-slides-container">
             {/* Toolbar */}
             <LyxalToolbar id="lyxal-slides-toolbar">
                <Group justify="space-between">
                    <Group>
                        <LyxalToolbarGroup>
                            <LyxalToolbarAction label="Annuler" icon={iconChevronLeft} />
                            <LyxalToolbarAction label="Rétablir" icon={iconChevronRight} />
                        </LyxalToolbarGroup>
                        <LyxalToolbarDivider />
                        <LyxalToolbarGroup>
                            <LyxalToolbarAction label="Nouvelle diapositive" icon={iconPlus} />
                            <LyxalToolbarAction label="Mise en page" icon={iconImage} />
                        </LyxalToolbarGroup>
                        <LyxalToolbarDivider />
                        <LyxalToolbarGroup>
                            <LyxalToolbarAction label="Texte" icon={iconText} />
                            <LyxalToolbarAction label="Forme" icon={iconCursor} />
                            <LyxalToolbarAction label="Image" icon={iconImage} />
                        </LyxalToolbarGroup>
                    </Group>
                    <Group>
                        <LyxalToolbarAction label="Lancer la présentation" icon={iconPlay} active />
                    </Group>
                </Group>
            </LyxalToolbar>

            <Flex flex={1} style={{ overflow: 'hidden' }} id="lyxal-slides-main-area">
                {/* Slides Sidebar */}
                <Stack w={240} gap={0} bg="gray.0" style={{ borderRight: '1px solid #dee2e6' }} id="lyxal-slides-sidebar">
                    <ScrollArea h="100%" p="xs">
                        <Stack gap="sm">
                            <SlideThumbnail index={1} title="Introduction" active />
                            <SlideThumbnail index={2} title="Architecture" />
                            <SlideThumbnail index={3} title="AST & Compilation" />
                            <SlideThumbnail index={4} title="Roadmap" />
                        </Stack>
                    </ScrollArea>
                </Stack>
    
                {/* Main Slide Stage */}
                <Box flex={1} bg="gray.2" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }} id="lyxal-slides-stage">
                    <Paper 
                        shadow="xl" 
                        radius={0}
                        style={{ 
                            aspectRatio: '16/9', 
                            width: '80%', 
                            backgroundColor: 'white',
                            display: 'flex',
                            flexDirection: 'column',
                            position: 'relative'
                        }}
                    >
                         {/* Content of the active slide (simulated) */}
                         <Box p={60} style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                            <Title order={1} style={{ fontSize: 48, marginBottom: 20, color: '#228be6' }}>
                                Lyxal Document Engine
                            </Title>
                            <Text size="xl" c="dimmed" style={{ fontSize: 24 }}>
                                Une nouvelle ère pour la bureautique universelle
                            </Text>
                            <Box mt={60}>
                                <Text fw={700}>Présenté par l'équipe Lyxal</Text>
                                <Text size="sm" c="dimmed">Janvier 2026</Text>
                            </Box>
                         </Box>
                    </Paper>
                </Box>
            </Flex>

            {/* Status Bar */}
             <Paper p={4} withBorder style={{ borderRadius: 0, borderBottom: 0, borderLeft: 0, borderRight: 0, backgroundColor: '#f8f9fa' }} id="lyxal-slides-status-bar">
                <Group justify="space-between" px="xs">
                    <Text size="xs" c="dimmed">Diapositive 1 sur 4</Text>
                    <Text size="xs" c="dimmed">Thème par défaut</Text>
                </Group>
            </Paper>
        </Stack>
    );
}

const SlideThumbnail = ({ index, title, active }: { index: number, title: string, active?: boolean }) => (
    <Group gap="xs" align="start" style={{ opacity: active ? 1 : 0.7 }}>
        <Text size="xs" w={15} pt={4} c="dimmed">{index}</Text>
        <Paper 
            withBorder 
            shadow={active ? 'sm' : 'xs'} 
            style={{ 
                flex: 1, 
                aspectRatio: '16/9', 
                border: active ? '2px solid #228be6' : '1px solid #dee2e6', 
                cursor: 'pointer',
                backgroundColor: 'white',
                padding: 4,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
            }}
        >
             <Text size="xs" style={{ fontSize: 8, textAlign: 'center' }}>{title}</Text>
        </Paper>
    </Group>
);

