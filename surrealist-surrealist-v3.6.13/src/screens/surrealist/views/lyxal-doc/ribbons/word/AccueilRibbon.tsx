import { Group, Stack, Button, Text, Box, Menu } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { 
    iconUndo2, 
    iconRedo2, 
    iconClipboard, 
    iconChevronDown, 
    iconScissors, 
    iconCopy2, 
    iconClipboardType, 
    iconPaintBucket, 
    iconList2, 
    iconListOrdered, 
    iconListChecks, 
    iconListMinus, 
    iconListPlus, 
    iconPilcrowRight, 
    iconPilcrowLeft, 
    iconPilcrow, 
    iconTextAlignStart, 
    iconTextAlignCenter, 
    iconTextAlignEnd, 
    iconTextAlignJustify, 
    iconListChevronsUpDown, 
    iconListTree, 
    iconTable2, 
    iconMic, 
    iconCheck2, 
    iconPuzzle 
} from "~/util/icons";

export function AccueilRibbon() {
    return (
        <Group align="center" h={80} gap="xs" px="md" wrap="nowrap">
            {/* Annuler / Rétablir */}
            <Stack gap={2} justify="center">
                <Button variant="subtle" color="slate" size="xs" h={36} w={36} p={0} radius="xs">
                    <Icon path={iconUndo2} size={16} stroked style={{ transform: 'rotate(-45deg)' }} />
                </Button>
                <Button variant="subtle" color="slate" size="xs" h={36} w={36} p={0} radius="xs">
                    <Icon path={iconRedo2} size={16} stroked style={{ transform: 'rotate(45deg)' }} />
                </Button>
            </Stack>

            {/* Presse-papiers */}
            <Group gap={4} wrap="nowrap">
                <Button 
                    variant="subtle" 
                    color="slate" 
                    h={76} 
                    w={60} 
                    p={0} 
                    radius="xs"
                    styles={{ 
                        inner: { width: '100%', justifyContent: 'center' },
                        label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                    }}
                >
                    <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                        <Icon path={iconClipboard} size={20} stroked />
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Coller</Text>
                    </Stack>
                </Button>
                <Stack gap={2}>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0} radius="xs">
                        <Icon path={iconScissors} size={14} stroked style={{ transform: 'rotate(-90deg)' }} />
                    </Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0} radius="xs">
                        <Icon path={iconCopy2} size={14} stroked />
                    </Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0} radius="xs">
                        <Icon path={iconClipboardType} size={14} stroked />
                    </Button>
                </Stack>
            </Group>

            {/* Police */}
            <Stack gap={4}>
                <Group gap={2}>
                    <Button variant="default" size="xs" h={24} px={8} style={{ fontSize: 11, fontWeight: 500 }}>Calibri</Button>
                    <Button variant="default" size="xs" h={24} px={8} style={{ fontSize: 11, fontWeight: 500 }}>11</Button>
                </Group>
                <Group gap={2}>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0} fw={700}>B</Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0} style={{ fontStyle: 'italic' }}>I</Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0} style={{ textDecoration: 'underline' }}>U</Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0} style={{ textDecoration: 'line-through' }}>S</Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}>
                        <Icon path={iconPaintBucket} size={14} stroked />
                    </Button>
                </Group>
            </Stack>

            {/* Paragraphe */}
            <Stack gap={4}>
                <Group gap={2}>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconList2} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconListOrdered} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconListChecks} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconListMinus} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconListPlus} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconPilcrowRight} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconPilcrowLeft} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconPilcrow} size={14} stroked /></Button>
                </Group>
                <Group gap={2}>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconTextAlignStart} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconTextAlignCenter} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconTextAlignEnd} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconTextAlignJustify} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconListChevronsUpDown} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconListTree} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconTable2} size={14} stroked /></Button>
                    <Button variant="subtle" color="slate" size="xs" h={24} w={24} p={0}><Icon path={iconPaintBucket} size={14} stroked /></Button>
                </Group>
            </Stack>

            {/* Styles */}
            <Group gap={4} wrap="nowrap">
                <Button variant="light" color="surreal" size="xs" h={60} px="xs" styles={{ label: { fontSize: 10, fontWeight: 600 } }}>Normal</Button>
                <Button variant="default" size="xs" h={60} px="xs" styles={{ label: { fontSize: 10, fontWeight: 500 } }}>Sans interligne</Button>
                <Button variant="default" size="xs" h={60} px="xs" styles={{ label: { fontSize: 10, fontWeight: 500 } }}>Titre 1</Button>
            </Group>

            {/* Commande vocale */}
            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs"
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Icon path={iconMic} size={20} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Dicter</Text>
                </Stack>
            </Button>

            {/* Vérification */}
            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs"
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Icon path={iconCheck2} size={20} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Éditeur</Text>
                </Stack>
            </Button>

            {/* Compléments */}
            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={80} 
                p={0} 
                radius="xs"
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Icon path={iconPuzzle} size={20} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Compléments</Text>
                </Stack>
            </Button>
        </Group>
    );
}
