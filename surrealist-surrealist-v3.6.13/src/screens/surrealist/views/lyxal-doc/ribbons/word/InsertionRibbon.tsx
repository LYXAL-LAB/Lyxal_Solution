import { Group, Stack, Button, Text, Menu, Box, Divider, Checkbox, UnstyledButton } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { 
    iconPageBreakBase,
    iconPageBreakLine, 
    iconColumnBreakLine,
    iconTable2, 
    iconGrid3x3_2, 
    iconTemplate, 
    iconListCheck, 
    iconNote, 
    iconListTree, 
    iconPhoto, 
    iconPhotoUp, 
    iconCloudUpload2, 
    iconPhotoSearch, 
    iconPhotoSpark, 
    iconEditCircleBase,
    iconEditCircleStylus,
    iconLink2, 
    iconClock2, 
    iconChevronsRight2, 
    iconFile2,
    iconTableOfContentLines, 
    iconBookmark2, 
    iconBookmarkPlus2, 
    iconBookmarks, 
    iconVideoBase, 
    iconMessageBase,
    iconColumns,
    iconCirclePlusFilled,
    iconOmega,
    iconMathPi,
    iconMoodSmile
} from "~/util/icons";

interface InsertionRibbonProps {
    hoveredGrid: { r: number; c: number };
    setHoveredGrid: (v: { r: number; c: number }) => void;
    setOpenedTableauAdvancedModal: (v: boolean) => void;
    setOpenedLienModal: (v: boolean) => void;
    setOpenedImageModal: (v: boolean) => void;
    showBookmarks: boolean;
    setShowBookmarks: (v: boolean) => void;
    setShowCommentBox: (v: boolean) => void;
}

export function InsertionRibbon({
    hoveredGrid,
    setHoveredGrid,
    setOpenedTableauAdvancedModal,
    setOpenedLienModal,
    setOpenedImageModal,
    showBookmarks,
    setShowBookmarks,
    setShowCommentBox,
}: InsertionRibbonProps) {
    return (
        <Group align="center" h={80} gap="xs" px="md" wrap="nowrap">
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
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconPageBreakBase} size={16} stroked />
                        <Icon 
                            path={iconPageBreakLine} 
                            size={16} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: '50%',
                                left: '50%',
                                transform: 'translate(-50%, -50%)'
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Saut de Page</Text>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={65} 
                p={0} 
                radius="xs" 
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconColumns} size={16} stroked />
                        <Icon 
                            path={iconColumnBreakLine} 
                            size={16} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: '50%',
                                left: '50%',
                                transform: 'translate(-50%, -50%)'
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Saut de Colonne</Text>
                </Stack>
            </Button>

            <Menu shadow="md" width={250} position="bottom-start" trapFocus={false} onClose={() => setHoveredGrid({ r: 0, c: 0 })}>
                <Menu.Target>
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
                            <Icon path={iconTable2} size={16} stroked />
                            <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }}>Tableau</Text>
                        </Stack>
                    </Button>
                </Menu.Target>
                <Menu.Dropdown p="xs">
                    <Stack gap={4}>
                        <Text size="xs" fw={700} c="dimmed" px="xs">
                            {hoveredGrid.r > 0 ? `Tableau ${hoveredGrid.c} x ${hoveredGrid.r}` : "Insérer un tableau"}
                        </Text>
                        <Box p="xs" onMouseLeave={() => setHoveredGrid({ r: 0, c: 0 })}>
                            <Stack gap={2}>
                                {Array.from({ length: 8 }).map((_, r) => (
                                    <Group key={r} gap={2}>
                                        {Array.from({ length: 10 }).map((_, c) => (
                                            <Box 
                                                key={c} 
                                                w={16} 
                                                h={16} 
                                                style={{ 
                                                    border: '1px solid var(--mantine-color-slate-3)',
                                                    backgroundColor: (r < hoveredGrid.r && c < hoveredGrid.c) ? 'var(--mantine-color-slate-1)' : 'transparent',
                                                    cursor: 'pointer'
                                                }}
                                                onMouseEnter={() => setHoveredGrid({ r: r + 1, c: c + 1 })}
                                            />
                                        ))}
                                    </Group>
                                ))}
                            </Stack>
                        </Box>
                        <Divider />
                        <Menu.Item 
                            leftSection={<Icon path={iconGrid3x3_2} size={14} stroked />} 
                            onClick={() => setOpenedTableauAdvancedModal(true)}
                            style={{ fontSize: '12px', whiteSpace: 'nowrap' }}
                        >
                            Choisir une ligne et une colonne
                        </Menu.Item>
                    </Stack>
                </Menu.Dropdown>
            </Menu>

            <Menu shadow="md" width={200} position="bottom-start">
                <Menu.Target>
                    <Button 
                        variant="subtle" 
                        color="slate" 
                        h={76} 
                        w={85} 
                        p={0} 
                        radius="xs" 
                        styles={{ 
                            inner: { width: '100%', justifyContent: 'center' },
                            label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                        }}
                    >
                        <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                            <Icon path={iconTemplate} size={16} stroked />
                            <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Modèles rapides</Text>
                        </Stack>
                    </Button>
                </Menu.Target>
                <Menu.Dropdown p="xs">
                    <Stack gap={4}>
                        <Menu.Item leftSection={<Icon path={iconListCheck} size={14} stroked />} style={{ fontSize: '12px' }}>Liste de tâches</Menu.Item>
                        <Menu.Item leftSection={<Icon path={iconNote} size={14} stroked />} style={{ fontSize: '12px' }}>Notes</Menu.Item>
                        <Menu.Item leftSection={<Icon path={iconListTree} size={14} stroked />} style={{ fontSize: '12px' }}>Plan hebdomadaire</Menu.Item>
                    </Stack>
                </Menu.Dropdown>
            </Menu>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedImageModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconPhoto} size={16} stroked />
                        <Icon 
                            path={iconCirclePlusFilled} 
                            size={10} 
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: '0%',
                                left: '100%',
                                transform: 'translate(-50%, -50%)'
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Image</Text>
                </Stack>
            </Button>

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
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconEditCircleBase} size={16} stroked />
                        <Icon 
                            path={iconEditCircleStylus} 
                            size={16} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: '50%',
                                left: '50%',
                                transform: 'translate(-50%, -50%)'
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Dessin</Text>
                </Stack>
            </Button>

            <Menu shadow="md" width={200} position="bottom-start">
                <Menu.Target>
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
                            <Icon path={iconLink2} size={16} stroked style={{ transform: 'rotate(45deg)' }} />
                            <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Lien</Text>
                        </Stack>
                    </Button>
                </Menu.Target>
                <Menu.Dropdown p="xs">
                    <Stack gap={4}>
                        <Menu.Item 
                            leftSection={<Icon path={iconLink2} size={14} stroked />} 
                            onClick={() => setOpenedLienModal(true)}
                            style={{ fontSize: '12px' }}
                        >
                            Insérer un lien
                        </Menu.Item>
                        <Menu position="right-start" offset={10}>
                            <Menu.Target>
                                <Menu.Item 
                                    leftSection={<Icon path={iconClock2} size={14} stroked />} 
                                    rightSection={<Icon path={iconChevronsRight2} size={10} />}
                                    style={{ fontSize: '12px' }}
                                >
                                    Liens récents
                                </Menu.Item>
                            </Menu.Target>
                            <Menu.Dropdown>
                                <Menu.Label>Liens récents</Menu.Label>
                                <Menu.Item>Document_Final.pdf</Menu.Item>
                                <Menu.Item>https://lyxal.com</Menu.Item>
                            </Menu.Dropdown>
                        </Menu>
                    </Stack>
                </Menu.Dropdown>
            </Menu>

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
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconFile2} size={16} stroked />
                        <Icon 
                            path={iconTableOfContentLines} 
                            size={10} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: '60%',
                                left: '60%',
                                transform: 'translate(-50%, -50%)'
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Table des matières</Text>
                </Stack>
            </Button>

            <Menu shadow="md" width={200} position="bottom-start">
                <Menu.Target>
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
                            <Icon path={iconBookmark2} size={16} stroked />
                            <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Signets</Text>
                        </Stack>
                    </Button>
                </Menu.Target>
                <Menu.Dropdown p="xs">
                    <Stack gap={4}>
                        <Menu.Item leftSection={<Icon path={iconBookmarkPlus2} size={14} stroked />} style={{ fontSize: '12px' }}>Nouveau signet</Menu.Item>
                        <Menu.Item leftSection={<Icon path={iconBookmarks} size={14} stroked />} style={{ fontSize: '12px' }}>Tous les signets</Menu.Item>
                        <Divider />
                        <Checkbox 
                            label="Afficher sur un document" 
                            size="xs" 
                            checked={showBookmarks} 
                            onChange={(event) => setShowBookmarks(event.currentTarget.checked)} 
                            p="xs"
                        />
                    </Stack>
                </Menu.Dropdown>
            </Menu>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={70} 
                p={0} 
                radius="xs" 
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconVideoBase} size={16} stroked />
                        <Icon 
                            path={iconCirclePlusFilled} 
                            size={10} 
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: '0%',
                                left: '100%',
                                transform: 'translate(-50%, -50%)'
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Vidéo en ligne</Text>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={80} 
                p={0} 
                radius="xs" 
                onClick={() => setShowCommentBox(true)} 
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconMessageBase} size={16} stroked />
                        <Icon 
                            path={iconCirclePlusFilled} 
                            size={10} 
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: '0%',
                                left: '100%',
                                transform: 'translate(-50%, -50%)'
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Nouveau commentaire</Text>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={65} 
                p={0} 
                radius="xs"
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Icon path={iconMathPi} size={16} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Équation</Text>
                </Stack>
            </Button>

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
                    <Icon path={iconOmega} size={16} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Symbole</Text>
                </Stack>
            </Button>

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
                    <Icon path={iconMoodSmile} size={16} stroked />
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>Emojis</Text>
                </Stack>
            </Button>
        </Group>
    );
}
