import { Box, Paper, Text, Group, Stack, ScrollArea, Button, TextInput, Tabs, Avatar, ActionIcon } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { LyxalToolbar } from "./components/LyxalToolbar";
import { BorduresModal } from "./modals/word/mise-en-page/BorduresModal";
import { PageColorModal } from "./modals/word/mise-en-page/PageColorModal";
import { ParagrapheModal } from "./modals/word/mise-en-page/ParagrapheModal";
import { ColonnesModal } from "./modals/word/mise-en-page/ColonnesModal";
import { MargesModal } from "./modals/word/mise-en-page/MargesModal";
import { TailleModal } from "./modals/word/mise-en-page/TailleModal";
import { LineNumbersModal } from "./modals/word/mise-en-page/LineNumbersModal";
import { PageNumbersModal } from "./modals/word/mise-en-page/PageNumbersModal";
import { HeaderFooterModal } from "./modals/word/mise-en-page/HeaderFooterModal";
import { LienModal } from "./modals/word/insertion/LienModal";
import { ImageModal } from "./modals/word/insertion/ImageModal";
import { TableauAdvancedModal } from "./modals/word/insertion/TableauAdvancedModal";
import { AccueilRibbon } from "./ribbons/word/AccueilRibbon";
import { InsertionRibbon } from "./ribbons/word/InsertionRibbon";
import { MiseEnPageRibbon } from "./ribbons/word/MiseEnPageRibbon";
import { ReferencesRibbon } from "./ribbons/word/ReferencesRibbon";
import { RevisionRibbon } from "./ribbons/word/RevisionRibbon";
import { AffichageRibbon } from "./ribbons/word/AffichageRibbon";
import { AideRibbon } from "./ribbons/word/AideRibbon";
import { 
    iconSearch,
    iconX2
} from "~/util/icons";
import { useState, useMemo, useEffect } from "react";

export function WordView() {
    const [activeMenu, setActiveMenu] = useState<string>("Accueil");
    const [openedLienModal, setOpenedLienModal] = useState(false);
    const [openedImageModal, setOpenedImageModal] = useState(false);
    const [openedTableauAdvancedModal, setOpenedTableauAdvancedModal] = useState(false);
    const [showBookmarks, setShowBookmarks] = useState(true);
    const [hoveredGrid, setHoveredGrid] = useState({ r: 0, c: 0 });
    const [showCommentBox, setShowCommentBox] = useState(false);
    const [commentText, setCommentText] = useState("");
    const [numCols, setNumCols] = useState(5);
    const [numRows, setNumRows] = useState(2);
    const [linkText, setLinkText] = useState("");
    const [linkUrl, setLinkUrl] = useState("");
    const [expandTitres, setExpandTitres] = useState(false);
    const [expandSignets, setExpandSignets] = useState(false);
    const [addTotalPages, setAddTotalPages] = useState(false);
    const [selectedPageNumber, setSelectedPageNumber] = useState<{ position: 'top' | 'bottom', alignment: number } | null>(null);
    const [openedMargeModal, setOpenedMargeModal] = useState(false);
    const [selectedMarginType, setSelectedMarginType] = useState<string>("normal");
    const [marginValues, setMarginValues] = useState({ top: 2.5, bottom: 2.5, left: 2.5, right: 2.5 });
    
    const [openedOrientationModal, setOpenedOrientationModal] = useState(false);
    const [orientation, setOrientation] = useState<'portrait' | 'landscape'>('portrait');

    const [openedTailleModal, setOpenedTailleModal] = useState(false);
    const [selectedTailleType, setSelectedTailleType] = useState<string>("a4");
    const [tailleValues, setTailleValues] = useState({ width: 21, height: 29.7 });
    const [openedColonnesModal, setOpenedColonnesModal] = useState(false);
    const [openedLineNumbersModal, setOpenedLineNumbersModal] = useState(false);
    const [openedPageNumbersModal, setOpenedPageNumbersModal] = useState(false);
    const [openedHeaderFooterModal, setOpenedHeaderFooterModal] = useState(false);
    const [headerFooterSettings, setHeaderFooterSettings] = useState({
        showHeader: true,
        showFooter: true,
        differentFirstPage: false,
        differentOddEvenPages: false
    });
    const [lineNumbersSettings, setLineNumbersSettings] = useState<{
        enabled: boolean;
        startAt: number;
        distanceFromText: number | 'auto';
        countBy: number;
        restartMode: 'continuous' | 'newPage' | 'newSection';
    }>({
        enabled: false,
        startAt: 1,
        distanceFromText: 'auto',
        countBy: 1,
        restartMode: 'continuous'
    });
    const [openedPageColorModal, setOpenedPageColorModal] = useState(false);
    const [openedBordureModal, setOpenedBordureModal] = useState(false);
    const [bordureSettings, setBordureSettings] = useState({
        type: 'encadrement' as 'aucun' | 'encadrement' | 'ombre' | '3d' | 'personnalise',
        style: 'solid',
        color: 'currentColor',
        width: 1,
        sides: { top: true, bottom: true, left: true, right: true }
    });
    const [initialBordureSettings, setInitialBordureSettings] = useState(bordureSettings);
    const [initialPageColor, setInitialPageColor] = useState('transparent');
    const [selectedColorSection, setSelectedColorSection] = useState<'theme' | 'standard' | 'custom' | 'none'>('theme');
    const [pageColor, setPageColor] = useState('transparent');

    const themeColors = [
        { color: '#ffffff', label: 'Blanc' }, { color: '#000000', label: 'Noir' }, { color: '#eeece1', label: 'Gris clair' }, { color: '#1f497d', label: 'Bleu foncé' }, { color: '#4f81bd', label: 'Bleu' }, { color: '#c0504d', label: 'Rouge' }, { color: '#9bbb59', label: 'Vert' }, { color: '#8064a2', label: 'Violet' }, { color: '#4bacc6', label: 'Bleu ciel' }, { color: '#f79646', label: 'Orange' },
        { color: '#f2f2f2', label: 'Blanc, plus sombre 5%' }, { color: '#7f7f7f', label: 'Noir, plus clair 50%' }, { color: '#ddd9c3', label: 'Gris clair, plus sombre 10%' }, { color: '#c6d9f0', label: 'Bleu foncé, plus clair 80%' }, { color: '#dbe5f1', label: 'Bleu, plus clair 80%' }, { color: '#f2dcdb', label: 'Rouge, plus clair 80%' }, { color: '#ebf1de', label: 'Vert, plus clair 80%' }, { color: '#e5e0ec', label: 'Violet, plus clair 80%' }, { color: '#dbeef3', label: 'Bleu ciel, plus clair 80%' }, { color: '#fde9d9', label: 'Orange, plus clair 80%' },
        { color: '#d8d8d8', label: 'Blanc, plus sombre 15%' }, { color: '#595959', label: 'Noir, plus clair 35%' }, { color: '#c4bd97', label: 'Gris clair, plus sombre 25%' }, { color: '#8db3e2', label: 'Bleu foncé, plus clair 60%' }, { color: '#b8cce4', label: 'Bleu, plus clair 60%' }, { color: '#e5b9b7', label: 'Rouge, plus clair 60%' }, { color: '#d7e3bc', label: 'Vert, plus clair 60%' }, { color: '#ccc1d9', label: 'Violet, plus clair 60%' }, { color: '#b7dee8', label: 'Bleu ciel, plus clair 60%' }, { color: '#fbd5b5', label: 'Orange, plus clair 60%' },
        { color: '#bfbfbf', label: 'Blanc, plus sombre 25%' }, { color: '#3f3f3f', label: 'Noir, plus clair 25%' }, { color: '#938953', label: 'Gris clair, plus sombre 50%' }, { color: '#548dd4', label: 'Bleu foncé, plus clair 40%' }, { color: '#95b3d7', label: 'Bleu, plus clair 40%' }, { color: '#d99694', label: 'Rouge, plus clair 40%' }, { color: '#c3d69b', label: 'Vert, plus clair 40%' }, { color: '#b2a2c7', label: 'Violet, plus clair 40%' }, { color: '#92cddc', label: 'Bleu ciel, plus clair 40%' }, { color: '#fac08f', label: 'Orange, plus clair 40%' },
        { color: '#a5a5a5', label: 'Blanc, plus sombre 35%' }, { color: '#262626', label: 'Noir, plus clair 15%' }, { color: '#494429', label: 'Gris clair, plus sombre 75%' }, { color: '#17365d', label: 'Bleu foncé, plus sombre 25%' }, { color: '#366092', label: 'Bleu, plus sombre 25%' }, { color: '#953734', label: 'Rouge, plus sombre 25%' }, { color: '#76923c', label: 'Vert, plus sombre 25%' }, { color: '#5f497a', label: 'Violet, plus sombre 25%' }, { color: '#31859b', label: 'Bleu ciel, plus sombre 25%' }, { color: '#e36c09', label: 'Orange, plus sombre 25%' },
        { color: '#7b7b7b', label: 'Blanc, plus sombre 50%' }, { color: '#0c0c0c', label: 'Noir, plus clair 5%' }, { color: '#1d1b10', label: 'Gris clair, plus sombre 90%' }, { color: '#0f243e', label: 'Bleu foncé, plus sombre 50%' }, { color: '#244061', label: 'Bleu, plus sombre 50%' }, { color: '#632423', label: 'Rouge, plus sombre 50%' }, { color: '#4f6128', label: 'Vert, plus sombre 50%' }, { color: '#3f3151', label: 'Violet, plus sombre 50%' }, { color: '#205867', label: 'Bleu ciel, plus sombre 50%' }, { color: '#974806', label: 'Orange, plus sombre 50%' }
    ];

    const standardColors = [
        { color: '#c00000', label: 'Rouge foncé' }, { color: '#ff0000', label: 'Rouge' }, { color: '#ffc000', label: 'Orange' }, { color: '#ffff00', label: 'Jaune' }, { color: '#92d050', label: 'Vert clair' }, { color: '#00b050', label: 'Vert' }, { color: '#00b0f0', label: 'Bleu clair' }, { color: '#0070c0', label: 'Bleu' }, { color: '#002060', label: 'Bleu foncé' }, { color: '#7030a0', label: 'Violet' }
    ];
    const [selectedColonnesType, setSelectedColonnesType] = useState<string>("one");
    const [numColonnesValue, setNumColonnesValue] = useState<number | string>(1);
    const [equalWidths, setEqualWidths] = useState(true);
    const [lineBetween, setLineBetween] = useState(false);
    const [columnWidths, setColumnWidths] = useState<number[]>([15]);
    const [columnSpacings, setColumnSpacings] = useState<number[]>([1.25]);

    const [openedParagrapheModal, setOpenedParagrapheModal] = useState(false);
    
    const defaultParagrapheValues = {
        alignment: 'left',
        indentLeft: 0,
        indentRight: 0,
        indentSpecial: 'none', 
        indentSpecialValue: 1.25,
        spaceBefore: 0,
        spaceAfter: 8,
        lineSpacing: 'multiple',
        lineSpacingValue: 1.08,
        spaceAuto: false,
        keepWithNext: false,
        widowControl: true,
        keepLinesTogether: false,
        pageBreakBefore: false
    };

    const [paragrapheValues, setParagrapheValues] = useState(defaultParagrapheValues);
    
    // États pour les tabulations
    const [tabStops, setTabStops] = useState<{id: string, position: number, alignment: string, leader: string}[]>([]);
    const [defaultTabStop, setDefaultTabStop] = useState(1.25);
    const [newTabStop, setNewTabStop] = useState({
        position: 0,
        alignment: 'left',
        leader: 'none'
    });

    const disponibleWidth = useMemo(() => {
            return Math.max(0.16, tailleValues.width - marginValues.left - marginValues.right);
        }, [tailleValues.width, marginValues.left, marginValues.right]);

        // Recalculer les colonnes si la largeur de la page ou les marges changent
        useEffect(() => {
            const n = Number(numColonnesValue) || 1;
            if (n === 1) {
                setColumnWidths([disponibleWidth]);
                setColumnSpacings([]);
            } else if (equalWidths) {
                // En mode égal, on conserve l'espacement et on ajuste la largeur
                const currentS = columnSpacings[0] || 1.27;
                const totalS = currentS * (n - 1);
                const newW = Math.max(1.27, (disponibleWidth - totalS) / n);
                setColumnWidths(Array(n).fill(parseFloat(newW.toFixed(2))));
                setColumnSpacings(Array(n - 1).fill(currentS));
            } else {
                // En mode inégal, on ajuste proportionnellement ou on réinitialise si trop petit
                const currentTotal = columnWidths.reduce((a, b) => a + b, 0) + columnSpacings.reduce((a, b) => a + b, 0);
                const ratio = disponibleWidth / currentTotal;
                
                setColumnWidths(columnWidths.map(w => parseFloat(Math.max(1.27, w * ratio).toFixed(2))));
                setColumnSpacings(columnSpacings.map(s => parseFloat(Math.max(0, s * ratio).toFixed(2))));
            }
        }, [disponibleWidth]);
    
    const menuItems = ["Fichier", "Accueil", "Insertion", "Mise en page", "Références", "Révision", "Affichage", "Aide"];

    return (
        <Stack gap={0} h="100%" bg="var(--mantine-color-body)" style={{ overflow: 'hidden' }}>
            <style dangerouslySetInnerHTML={{ __html: `
                .page-preview-box {
                    transition: border-color 0.2s, box-shadow 0.2s;
                    cursor: pointer;
                }
                .page-preview-box:hover {
                    border-color: var(--mantine-color-surreal-6) !important;
                    box-shadow: 0 0 0 1px var(--mantine-color-surreal-6);
                }
                /* Masquer les barres de défilement dans les modals */
                .mantine-Modal-body, 
                .mantine-Modal-content {
                    scrollbar-width: none;
                    -ms-overflow-style: none;
                }
                .mantine-Modal-body::-webkit-scrollbar, 
                .mantine-Modal-content::-webkit-scrollbar {
                    display: none;
                }
            `}} />
            <LyxalToolbar activeMenu={activeMenu} onMenuChange={setActiveMenu} menuItems={menuItems}>
                {activeMenu === "Accueil" && <AccueilRibbon />}

                    {activeMenu === "Insertion" && (
                        <InsertionRibbon 
                            hoveredGrid={hoveredGrid}
                            setHoveredGrid={setHoveredGrid}
                            setOpenedTableauAdvancedModal={setOpenedTableauAdvancedModal}
                            setOpenedLienModal={setOpenedLienModal}
                            setOpenedImageModal={setOpenedImageModal}
                            showBookmarks={showBookmarks}
                            setShowBookmarks={setShowBookmarks}
                            setShowCommentBox={setShowCommentBox}
                        />
                    )}

                {activeMenu === "Mise en page" && (
                    <MiseEnPageRibbon 
                        setOpenedMargeModal={setOpenedMargeModal}
                        orientation={orientation}
                        setOrientation={setOrientation}
                        setOpenedTailleModal={setOpenedTailleModal}
                        setOpenedColonnesModal={setOpenedColonnesModal}
                        setOpenedLineNumbersModal={setOpenedLineNumbersModal}
                        setOpenedPageNumbersModal={setOpenedPageNumbersModal}
                        setOpenedHeaderFooterModal={setOpenedHeaderFooterModal}
                        setOpenedParagrapheModal={setOpenedParagrapheModal}
                        setOpenedPageColorModal={setOpenedPageColorModal}
                        pageColor={pageColor}
                        setOpenedBordureModal={setOpenedBordureModal}
                        setInitialPageColor={setInitialPageColor}
                        selectedPageNumber={selectedPageNumber}
                        setSelectedPageNumber={setSelectedPageNumber}
                        addTotalPages={addTotalPages}
                        setAddTotalPages={setAddTotalPages}
                    />
                )}

                {activeMenu === "Références" && <ReferencesRibbon />}

                {activeMenu === "Révision" && <RevisionRibbon />}

                {activeMenu === "Affichage" && <AffichageRibbon />}

                {activeMenu === "Aide" && <AideRibbon />}
            </LyxalToolbar>

            <Box style={{ flex: 1, display: 'flex', overflow: 'hidden' }}>
                {/* Volet Navigation (Gauche) */}
                <Box w={260} p="md" bg="var(--mantine-color-body)" style={{ borderRight: '1px solid var(--mantine-color-default-border)' }}>
                    <Stack gap="md">
                        <Text fw={700} size="sm" c="surreal">Navigation</Text>
                        <TextInput 
                            placeholder="Rechercher dans le document" 
                            size="xs" 
                            variant="filled"
                            leftSection={<Icon path={iconSearch} size={14} stroked />} 
                        />
                        <Tabs defaultValue="headings" variant="pills" color="surreal" bg="transparent" styles={{ tab: { fontSize: '10px', fontWeight: 600 } }}>
                            <Tabs.List grow bg="transparent">
                                <Tabs.Tab value="headings">Titres</Tabs.Tab>
                                <Tabs.Tab value="pages">Pages</Tabs.Tab>
                                <Tabs.Tab value="results">Résultats</Tabs.Tab>
                            </Tabs.List>
                            <Tabs.Panel value="headings" pt="md">
                                <Text size="xs" c="dimmed" style={{ textAlign: 'center' }}>Créez un plan en appliquant des styles de titre.</Text>
                            </Tabs.Panel>
                            <Tabs.Panel value="pages" pt="md">
                                <Box h={120} w={90} bg="var(--mantine-color-default)" style={{ border: '1px solid var(--mantine-color-default-border)', margin: '0 auto', boxShadow: '0 2px 4px rgba(0,0,0,0.2)', borderRadius: '2px' }} />
                                <Text size="10px" style={{ textAlign: 'center' }} mt={4} fw={500}>Page 1</Text>
                            </Tabs.Panel>
                        </Tabs>
                    </Stack>
                </Box>

                {/* Zone Centrale (Document) */}
                <Box style={{ flex: 1, position: 'relative', overflow: 'hidden' }} bg="var(--mantine-color-body)">
                    <ScrollArea h="100%" p="xl">
                        <Group justify="center" align="start" py="xl">
                            <Paper 
                                shadow="xl" 
                                p={80} 
                                w={800} 
                                mih={1100} 
                                radius="xs" 
                                style={{ 
                                    position: 'relative', 
                                    border: '1px solid var(--mantine-color-default-border)',
                                    backgroundColor: pageColor !== 'transparent' ? pageColor : 'light-dark(var(--mantine-color-white), var(--mantine-color-dark-9))'
                                }}
                            >
                                <Text c="dimmed">Commencez à rédiger votre document...</Text>
                            </Paper>
                        </Group>
                    </ScrollArea>
                </Box>

                {/* Volet Commentaires (Droite) */}
                {showCommentBox && (
                    <Box w={320} p="md" bg="var(--mantine-color-body)" style={{ borderLeft: '1px solid var(--mantine-color-default-border)' }}>
                        <Stack gap="md">
                            <Group justify="space-between">
                                <Text fw={700} size="sm" c="surreal">Commentaires</Text>
                                <ActionIcon variant="subtle" color="slate" size="xs" onClick={() => setShowCommentBox(false)}>
                                    <Icon path={iconX2} size={14} />
                                </ActionIcon>
                            </Group>
                            
                            <Paper shadow="sm" p="sm" withBorder radius="md" bg="var(--mantine-color-default)" style={{ borderLeft: '4px solid var(--mantine-color-surreal-6)' }}>
                                <Stack gap="xs">
                                    <Group gap="xs">
                                        <Avatar color="surreal" size="sm" radius="xl">JD</Avatar>
                                        <Text size="xs" fw={700}>Jean Dupont</Text>
                                    </Group>
                                    <TextInput 
                                        placeholder="@mention ou commentaire" 
                                        size="xs" 
                                        variant="filled"
                                        value={commentText} 
                                        onChange={(e) => setCommentText(e.currentTarget.value)}
                                    />
                                    <Group justify="end" gap="xs">
                                        <Button variant="subtle" size="xs" color="slate" onClick={() => { setCommentText(""); setShowCommentBox(false); }}>Annuler</Button>
                                        <Button size="xs" color="surreal" disabled={!commentText}>Commenter</Button>
                                    </Group>
                                </Stack>
                            </Paper>
                        </Stack>
                    </Box>
                )}
            </Box>

            {/* Modals */}
            <LienModal 
                opened={openedLienModal}
                onClose={() => setOpenedLienModal(false)}
                linkText={linkText}
                setLinkText={setLinkText}
                linkUrl={linkUrl}
                setLinkUrl={setLinkUrl}
                expandTitres={expandTitres}
                setExpandTitres={setExpandTitres}
                expandSignets={expandSignets}
                setExpandSignets={setExpandSignets}
            />

            <TableauAdvancedModal 
                opened={openedTableauAdvancedModal}
                onClose={() => setOpenedTableauAdvancedModal(false)}
                numCols={numCols}
                setNumCols={setNumCols}
                numRows={numRows}
                setNumRows={setNumRows}
            />

            <ImageModal 
                opened={openedImageModal}
                onClose={() => setOpenedImageModal(false)}
            />

            <MargesModal 
                opened={openedMargeModal}
                onClose={() => setOpenedMargeModal(false)}
                selectedMarginType={selectedMarginType}
                setSelectedMarginType={setSelectedMarginType}
                marginValues={marginValues}
                setMarginValues={setMarginValues}
            />

            <TailleModal 
                opened={openedTailleModal}
                onClose={() => setOpenedTailleModal(false)}
                selectedTailleType={selectedTailleType}
                setSelectedTailleType={setSelectedTailleType}
                tailleValues={tailleValues}
                setTailleValues={setTailleValues}
            />

            <ColonnesModal 
                opened={openedColonnesModal}
                onClose={() => setOpenedColonnesModal(false)}
                selectedColonnesType={selectedColonnesType}
                setSelectedColonnesType={setSelectedColonnesType}
                numColonnesValue={numColonnesValue}
                setNumColonnesValue={setNumColonnesValue}
                equalWidths={equalWidths}
                setEqualWidths={setEqualWidths}
                lineBetween={lineBetween}
                setLineBetween={setLineBetween}
                columnWidths={columnWidths}
                setColumnWidths={setColumnWidths}
                columnSpacings={columnSpacings}
                setColumnSpacings={setColumnSpacings}
                disponibleWidth={disponibleWidth}
            />
            <LineNumbersModal
                opened={openedLineNumbersModal}
                onClose={() => setOpenedLineNumbersModal(false)}
                lineNumbersSettings={lineNumbersSettings}
                setLineNumbersSettings={setLineNumbersSettings}
            />
            <PageNumbersModal
                opened={openedPageNumbersModal}
                onClose={() => setOpenedPageNumbersModal(false)}
                selectedPageNumber={selectedPageNumber}
                setSelectedPageNumber={setSelectedPageNumber}
                addTotalPages={addTotalPages}
                setAddTotalPages={setAddTotalPages}
            />
            <HeaderFooterModal 
                opened={openedHeaderFooterModal}
                onClose={() => setOpenedHeaderFooterModal(false)}
                settings={headerFooterSettings}
                onApply={setHeaderFooterSettings}
            />
            <ParagrapheModal 
                opened={openedParagrapheModal}
                onClose={() => setOpenedParagrapheModal(false)}
                paragrapheValues={paragrapheValues}
                setParagrapheValues={setParagrapheValues}
                tabStops={tabStops}
                setTabStops={setTabStops}
                defaultTabStop={defaultTabStop}
                setDefaultTabStop={setDefaultTabStop}
                newTabStop={newTabStop}
                setNewTabStop={setNewTabStop}
                defaultParagrapheValues={defaultParagrapheValues}
            />

            <PageColorModal 
                opened={openedPageColorModal} 
                onClose={() => setOpenedPageColorModal(false)}
                pageColor={pageColor}
                setPageColor={setPageColor}
                initialPageColor={initialPageColor}
                selectedColorSection={selectedColorSection}
                setSelectedColorSection={setSelectedColorSection}
                themeColors={themeColors}
                standardColors={standardColors}
                bordureSettings={bordureSettings}
                orientation={orientation}
            />

            <BorduresModal 
                opened={openedBordureModal} 
                onClose={() => setOpenedBordureModal(false)}
                bordureSettings={bordureSettings}
                setBordureSettings={setBordureSettings}
                initialBordureSettings={initialBordureSettings}
                setInitialBordureSettings={setInitialBordureSettings}
                themeColors={themeColors}
                standardColors={standardColors}
                pageColor={pageColor}
                orientation={orientation}
            />
        </Stack>
    );
}
