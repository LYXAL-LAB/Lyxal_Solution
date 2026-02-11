import { Button, Group, Menu, Stack, Text, Box, Divider, UnstyledButton, Checkbox } from "@mantine/core";
import { LyxalRibbonGroup, LyxalToolbarDivider } from "../../components/LyxalToolbar";
import { Icon } from "~/components/Icon";
import { 
    iconBoxPadding, 
    iconLayoutOrientation, 
    iconLayoutSize, 
    iconLayoutColumns, 
    iconLayoutBreaks, 
    iconLayoutLineNumbers, 
    iconLayoutHyphenation, 
    iconParagraph,
    iconLetterASmall,
    iconFile2,
    iconFileHorizontal,
    iconDroplet,
    iconChevronDown,
    iconPhoto,
    iconBaselineDensityLarge2,
    iconPlus,
    iconListMinus,
    iconListTree,
    iconTextAlignCenter,
    iconTable2,
    iconRedo2,
    iconLineDashed,
    iconFileFilled,
    iconFileHorizontalFilled,
    iconArrowBackUp,
    iconArrowBack,
    iconArrowsVertical,
    iconArrowsHorizontal,
    iconColumns,
    iconListNumbersLines,
    iconListNumbersDigits,
    iconHash2,
    iconTrash
} from "~/util/icons";

interface MiseEnPageRibbonProps {
    setOpenedMargeModal: (opened: boolean) => void;
    orientation: 'portrait' | 'landscape';
    setOrientation: (orientation: 'portrait' | 'landscape') => void;
    setOpenedTailleModal: (opened: boolean) => void;
    setOpenedColonnesModal: (opened: boolean) => void;
    setOpenedLineNumbersModal: (opened: boolean) => void;
    setOpenedPageNumbersModal: (opened: boolean) => void;
    setOpenedHeaderFooterModal: (opened: boolean) => void;
    setOpenedParagrapheModal: (opened: boolean) => void;
    setOpenedPageColorModal: (opened: boolean) => void;
    pageColor: string;
    setOpenedBordureModal: (opened: boolean) => void;
    setInitialPageColor: (color: string) => void;
    selectedPageNumber: { position: 'top' | 'bottom', alignment: number } | null;
    setSelectedPageNumber: (v: { position: 'top' | 'bottom', alignment: number } | null) => void;
    addTotalPages: boolean;
    setAddTotalPages: (v: boolean) => void;
}

export const MiseEnPageRibbon = ({
    setOpenedMargeModal,
    orientation,
    setOrientation,
    setOpenedTailleModal,
    setOpenedColonnesModal,
    setOpenedLineNumbersModal,
    setOpenedPageNumbersModal,
    setOpenedHeaderFooterModal,
    setOpenedParagrapheModal,
    setOpenedPageColorModal,
    pageColor,
    setOpenedBordureModal,
    setInitialPageColor,
    selectedPageNumber,
    setSelectedPageNumber,
    addTotalPages,
    setAddTotalPages
}: MiseEnPageRibbonProps) => {
    return (
        <Group align="center" h={80} gap="xs" px="md" wrap="nowrap">
            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedMargeModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconFile2} size={16} stroked />
                        <Icon 
                            path={iconLineDashed} 
                            size={12} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                left: 0.5,
                                transform: 'rotate(90deg)'
                            }} 
                        />
                        <Icon 
                            path={iconLineDashed} 
                            size={12} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                right: 0.5,
                                transform: 'rotate(90deg)'
                            }} 
                        />
                        <Icon 
                            path={iconLineDashed} 
                            size={12} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                bottom: 7
                            }} 
                        />
                        <Icon 
                            path={iconLineDashed} 
                            size={12} 
                            stroked
                            strokeWidth={3}
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: 7
                            }} 
                        />
                    </Box>
                    <Stack gap={0} align="center" w="100%">
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Marges</Text>
                    </Stack>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={70} 
                p={0} 
                radius="xs" 
                onClick={() => setOrientation(orientation === 'portrait' ? 'landscape' : 'portrait')}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24 }}>
                        <Icon 
                            path={orientation === 'portrait' ? iconFileFilled : iconFile2} 
                            size={orientation === 'portrait' ? 16 : 12} 
                            stroked={orientation !== 'portrait'}
                            noStroke={orientation === 'portrait'}
                            color={orientation === 'portrait' ? "surreal.6" : "currentColor"}
                            style={{ 
                                position: 'absolute',
                                bottom: orientation === 'portrait' ? 0 : 12,
                                right: orientation === 'portrait' ? 0 : 8,
                                zIndex: orientation === 'portrait' ? 1 : 2
                            }} 
                        />
                        <Icon 
                            path={orientation === 'landscape' ? iconFileHorizontalFilled : iconFileHorizontal} 
                            size={orientation === 'landscape' ? 16 : 12} 
                            stroked={orientation !== 'landscape'}
                            noStroke={orientation === 'landscape'}
                            color={orientation === 'landscape' ? "surreal.6" : "currentColor"}
                            style={{ 
                                position: 'absolute',
                                top: orientation === 'landscape' ? 0 : 6,
                                left: orientation === 'landscape' ? 0 : 12,
                                zIndex: orientation === 'landscape' ? 1 : 2
                            }} 
                        />
                        {orientation === 'landscape' && (
                            <Icon 
                                path={iconArrowBackUp} 
                                size={16} 
                                stroked
                                color="surreal.6"
                                style={{ 
                                    position: 'absolute',
                                    bottom: 10,
                                    left: 12,
                                    zIndex: 0
                                }} 
                            />
                        )}
                        {orientation === 'portrait' && (
                            <Icon 
                                path={iconArrowBack} 
                                size={16} 
                                stroked
                                color="surreal.6"
                                style={{ 
                                    position: 'absolute',
                                    bottom: 12,
                                    left: 10,
                                    zIndex: 0,
                                    transform: 'rotate(-90deg)'
                                }} 
                            />
                        )}
                    </Box>
                    <Stack gap={0} align="center" w="100%">
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>{orientation === 'portrait' ? 'Portrait' : 'Paysage'}</Text>
                    </Stack>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedTailleModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconFile2} size={16} stroked />
                        <Icon 
                            path={iconArrowsHorizontal} 
                            size={12} 
                            strokeWidth={3}
                            stroked 
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                bottom: 17
                            }} 
                        />
                        <Icon 
                            path={iconArrowsVertical} 
                            size={12} 
                            strokeWidth={3}
                            stroked 
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                left: 16,
                                bottom: 1
                            }} 
                        />
                    </Box>
                    <Stack gap={0} align="center" w="100%">
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Taille</Text>
                    </Stack>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedColonnesModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconFile2} size={16} stroked />
                        <Icon 
                            path={iconColumns} 
                            size={10} 
                            strokeWidth={3}
                            stroked 
                            color="surreal.6"
                            style={{ 
                                position: 'absolute'
                            }} 
                        />
                    </Box>
                    <Stack gap={0} align="center" w="100%">
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Colonnes</Text>
                    </Stack>
                </Stack>
            </Button>

            <LyxalToolbarDivider />

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                onClick={() => {
                    setInitialPageColor(pageColor);
                    setOpenedPageColorModal(true);
                }}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24 }}>
                        <Icon path={iconFile2} size={16} stroked style={{ position: 'absolute', top: 0, left: 0 }} />
                        <Icon 
                            path={iconDroplet} 
                            size={18} 
                            color={pageColor === 'transparent' ? 'surreal.6' : pageColor}
                            style={{ 
                                position: 'absolute',
                                top: -10,
                                right: -4,
                                filter: 'drop-shadow(0px 1px 1px rgba(0,0,0,0.3))'
                            }} 
                        />
                    </Box>
                    <Stack gap={0} align="center" w="100%">
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Couleur de page</Text>
                    </Stack>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedBordureModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconFile2} size={16} stroked />
                        <Icon 
                            path={iconFile2} 
                            size={10} 
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
                    <Stack gap={0} align="center" w="100%">
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Bordures de page</Text>
                    </Stack>
                </Stack>
            </Button>

            <LyxalToolbarDivider />

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs"
                onClick={() => setOpenedLineNumbersModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconListNumbersLines} size={16} stroked />
                        <Icon 
                            path={iconListNumbersDigits} 
                            size={12} 
                            strokeWidth={3}
                            stroked 
                            color="surreal.6"
                            style={{ position: 'absolute', top: 1.5, left: 0 }}
                        />
                    </Box>
                    <Stack gap={0} align="center" w="100%">
                        <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Numéros de lignes</Text>
                    </Stack>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={80} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedHeaderFooterModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconFile2} size={16} stroked />
                        <Icon 
                            path={iconBaselineDensityLarge2} 
                            size={10} 
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
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={4}>En-tête et pied de page</Text>
                </Stack>
            </Button>

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={70} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedPageNumbersModal(true)}
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' },
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconFile2} size={16} stroked />
                        <Icon 
                            path={iconHash2} 
                            size={10} 
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
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Numéros de page</Text>
                </Stack>
            </Button>

            <LyxalToolbarDivider />

            <Button 
                variant="subtle" 
                color="slate" 
                h={76} 
                w={60} 
                p={0} 
                radius="xs" 
                onClick={() => setOpenedParagrapheModal(true)} 
                styles={{ 
                    inner: { width: '100%', justifyContent: 'center' }, 
                    label: { width: '100%', whiteSpace: 'normal', display: 'block' } 
                }}
            >
                <Stack gap={4} align="center" pt={12} h="100%" w="100%">
                    <Box style={{ position: 'relative', width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon path={iconParagraph} size={16} stroked />
                        <Icon 
                            path={iconLetterASmall} 
                            size={10} 
                            strokeWidth={3}
                            stroked 
                            color="surreal.6"
                            style={{ 
                                position: 'absolute',
                                top: 0,
                                left: 0
                            }} 
                        />
                    </Box>
                    <Text size="10px" fw={500} style={{ lineHeight: 1, textAlign: 'center' }} px={2}>Paragraphe</Text>
                </Stack>
            </Button>
        </Group>
    );
};
