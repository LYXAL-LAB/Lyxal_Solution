import { Modal, Button, Group, Stack, Text, Box, Divider, Tabs, Center, TextInput, Grid, Skeleton, ScrollArea, Paper, ActionIcon, Tooltip, Breadcrumbs, UnstyledButton } from "@mantine/core";
import { useState, useRef, useEffect } from "react";
import { Icon } from "~/components/Icon";
import { 
    iconPhotoUp, 
    iconCloud, 
    iconPhotoSearch, 
    iconPhoto,
    iconPlus,
    iconSearch,
    iconVideoBase,
    iconLink2,
    iconChevronUp,
    iconChevronsUp,
    iconLayoutGrid,
    iconList,
    iconClock2,
    iconFolderSecure,
    iconAccount,
    iconFolder,
    iconChevronRight
} from "~/util/icons";

interface ImageModalProps {
    opened: boolean;
    onClose: () => void;
}

export function ImageModal({ opened, onClose }: ImageModalProps) {
    const [activeTab, setActiveTab] = useState<'importer' | 'webcam' | 'lien' | 'photos' | 'drive' | 'lyxal_photos'>('importer');
    const [driveSubTab, setDriveSubTab] = useState<'recents' | 'mon_drive' | 'partage'>('mon_drive');
    const [drivePath, setDrivePath] = useState<string[]>(['Mon drive']);
    const [lyxalPhotosSubTab, setLyxalPhotosSubTab] = useState<'explorer' | 'favoris' | 'albums'>('explorer');
    const [driveViewMode, setDriveViewMode] = useState<'grid' | 'list'>('grid');
    const [lyxalPhotosViewMode, setLyxalPhotosViewMode] = useState<'grid' | 'list'>('grid');
    const [dragOver, setDragOver] = useState(false);
    const [fileError, setFileError] = useState<string | null>(null);
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [previewUrl, setPreviewUrl] = useState<string | null>(null);
    const [linkUrl, setLinkUrl] = useState("");
    const [selectedPhotoId, setSelectedPhotoId] = useState<string | null>(null);
    const [selectedDriveFileId, setSelectedDriveFileId] = useState<string | null>(null);
    const [selectedLyxalPhotoId, setSelectedLyxalPhotoId] = useState<string | null>(null);
    const [isLinkLoading, setIsLinkLoading] = useState(false);
    const [webcamStream, setWebcamStream] = useState<MediaStream | null>(null);
    const [isWebcamActive, setIsWebcamActive] = useState(false);
    const [showScrollTop, setShowScrollTop] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const videoRef = useRef<HTMLVideoElement>(null);
    const scrollViewportRef = useRef<HTMLDivElement>(null);
    const driveScrollRef = useRef<HTMLDivElement>(null);
    const photosScrollRef = useRef<HTMLDivElement>(null);
    const lyxalPhotosScrollRef = useRef<HTMLDivElement>(null);

    // Gestion du scroll pour le bouton "Retour en haut"
    useEffect(() => {
        const handleScroll = (e: Event) => {
            const viewport = e.target as HTMLDivElement;
            const isPastThreshold = viewport.scrollTop > viewport.scrollHeight / 4;
            setShowScrollTop(isPastThreshold);
        };

        const mainViewport = scrollViewportRef.current;
        const driveViewport = driveScrollRef.current;
        const photosViewport = photosScrollRef.current;
        const lyxalPhotosViewport = lyxalPhotosScrollRef.current;

        mainViewport?.addEventListener('scroll', handleScroll);
        driveViewport?.addEventListener('scroll', handleScroll);
        photosViewport?.addEventListener('scroll', handleScroll);
        lyxalPhotosViewport?.addEventListener('scroll', handleScroll);

        return () => {
            mainViewport?.removeEventListener('scroll', handleScroll);
            driveViewport?.removeEventListener('scroll', handleScroll);
            photosViewport?.removeEventListener('scroll', handleScroll);
            lyxalPhotosViewport?.removeEventListener('scroll', handleScroll);
        };
    }, [activeTab]);

    // Fonction pour remonter lentement (1.5s)
    const slowScrollToTop = () => {
        const viewport = activeTab === 'photos' ? photosScrollRef.current :
                         activeTab === 'drive' ? driveScrollRef.current : 
                         activeTab === 'lyxal_photos' ? lyxalPhotosScrollRef.current : 
                         scrollViewportRef.current;
        if (!viewport) return;
        
        const start = viewport.scrollTop;
        const duration = 1500;
        const startTime = performance.now();
        
        const animate = (currentTime: number) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const ease = 1 - Math.pow(1 - progress, 3);
            
            viewport.scrollTop = start * (1 - ease);
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };
        
        requestAnimationFrame(animate);
    };

    // Reset de l'état à l'ouverture du modal
    useEffect(() => {
        if (opened) {
            setActiveTab('importer');
            setDriveSubTab('mon_drive');
            setDrivePath(['Mon drive']);
            setLyxalPhotosSubTab('explorer');
            setSelectedDriveFileId(null);
            setSelectedLyxalPhotoId(null);
            clearSelection();
            stopWebcam();
            setLinkUrl("");
        }
    }, [opened]);

    // Validation du lien image
    useEffect(() => {
        if (activeTab === 'lien' && linkUrl.trim().length > 10) {
            // On nettoie l'URL des paramètres et fragments pour vérifier l'extension réelle
            const cleanUrl = linkUrl.split(/[?#]/)[0];
            const isImage = /\.(jpg|jpeg|png|webp|avif|gif|svg)$/i.test(cleanUrl) || linkUrl.startsWith('data:image/');
            
            if (isImage) {
                setFileError(null);
                setPreviewUrl(linkUrl);
            } else {
                setPreviewUrl(null);
                if (linkUrl.includes('wikipedia.org/wiki/')) {
                    setFileError("Attention : ceci est un lien vers une page Wikipedia, pas vers l'image elle-même. Utilisez 'Copier l'adresse de l'image'.");
                }
            }
        } else if (activeTab === 'lien') {
            setPreviewUrl(null);
        }
    }, [linkUrl, activeTab]);

    // Arrêt de la webcam si on change d'onglet
    useEffect(() => {
        if (activeTab !== 'webcam') {
            stopWebcam();
        }
    }, [activeTab]);

    const stopWebcam = () => {
        if (webcamStream) {
            webcamStream.getTracks().forEach(track => track.stop());
            setWebcamStream(null);
        }
        setIsWebcamActive(false);
    };

    const startWebcam = async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            setWebcamStream(stream);
            setIsWebcamActive(true);
            if (videoRef.current) {
                videoRef.current.srcObject = stream;
            }
        } catch (err) {
            console.error("Erreur accès webcam:", err);
            setFileError("Impossible d'accéder à la caméra. Veuillez vérifier les autorisations.");
        }
    };

    const capturePhoto = () => {
        if (videoRef.current) {
            const canvas = document.createElement('canvas');
            canvas.width = videoRef.current.videoWidth;
            canvas.height = videoRef.current.videoHeight;
            const ctx = canvas.getContext('2d');
            if (ctx) {
                ctx.drawImage(videoRef.current, 0, 0);
                canvas.toBlob((blob) => {
                    if (blob) {
                        const file = new File([blob], `capture_${Date.now()}.png`, { type: 'image/png' });
                        setSelectedFile(file);
                        const url = URL.createObjectURL(file);
                        setPreviewUrl(url);
                        setActiveTab('importer'); // On revient sur l'onglet importer pour voir l'aperçu
                        stopWebcam();
                    }
                }, 'image/png');
            }
        }
    };

    const handleFileSelect = (files: FileList | null) => {
        setFileError(null);
        if (files && files.length > 0) {
            const file = files[0];
            
            // Vérification du type
            if (!file.type.startsWith('image/')) {
                setFileError("Le fichier sélectionné n'est pas une image valide.");
                return;
            }

            // Vérification de la taille (10 Mo)
            if (file.size > 10 * 1024 * 1024) {
                setFileError("Le fichier est trop volumineux. La taille maximale est de 10 Mo.");
                return;
            }

            setSelectedFile(file);
            const url = URL.createObjectURL(file);
            setPreviewUrl(url);
        }
    };

    const clearSelection = () => {
        if (previewUrl && !previewUrl.startsWith('http') && !previewUrl.startsWith('data:')) URL.revokeObjectURL(previewUrl);
        setSelectedFile(null);
        setPreviewUrl(null);
        setFileError(null);
        setSelectedPhotoId(null);
    };

    const handlePhotoSelect = (id: string, url: string) => {
        setSelectedPhotoId(id);
        setPreviewUrl(url);
        // On simule un fichier sélectionné pour l'UI
        setSelectedFile({ name: `Photo_${id}.svg`, size: 45000 } as any);
    };

    const mockPhotosFlattened: Array<{ type: 'date'; label: string } | { type: 'photo'; id: string; url: string }> = [
        { type: 'date', label: "Aujourd'hui - 10 Janvier 2026" },
        ...Array.from({ length: 15 }).map((_, i) => ({
            type: 'photo' as const,
            id: `today-${i}`,
            url: `https://placehold.co/300x200/6b65fb/ffffff.svg?text=Lyxal+${i+1}`,
        })),
        { type: 'date', label: "Hier - 9 Janvier 2026" },
        ...Array.from({ length: 2 }).map((_, i) => ({
            type: 'photo' as const,
            id: `yesterday-${i}`,
            url: `https://placehold.co/250x250/6c757d/ffffff.svg?text=Archive+${i+1}`,
        })),
        { type: 'date', label: "8 Janvier 2026" },
        {
            type: 'photo' as const,
            id: `jan8-0`,
            url: `https://placehold.co/400x300/495057/ffffff.svg?text=Seul+1`,
        },
        { type: 'date', label: "7 Janvier 2026" },
        ...Array.from({ length: 25 }).map((_, i) => ({
            type: 'photo' as const,
            id: `jan7-${i}`,
            url: `https://placehold.co/300x200/5c940d/ffffff.svg?text=Travail+${i+1}`,
        })),
        { type: 'date', label: "5 Janvier 2026" },
        ...Array.from({ length: 40 }).map((_, i) => ({
            type: 'photo' as const,
            id: `jan5-${i}`,
            url: `https://placehold.co/300x200/e67700/ffffff.svg?text=Projet+${i+1}`,
        })),
        { type: 'date', label: "1 Janvier 2026" },
        ...Array.from({ length: 30 }).map((_, i) => ({
            type: 'photo' as const,
            id: `jan1-${i}`,
            url: `https://placehold.co/300x200/d9480f/ffffff.svg?text=NouvelAn+${i+1}`,
        })),
        { type: 'date', label: "Décembre 2025" },
        ...Array.from({ length: 60 }).map((_, i) => ({
            type: 'photo' as const,
            id: `dec25-${i}`,
            url: `https://placehold.co/300x200/5f3dc4/ffffff.svg?text=Decembre+${i+1}`,
        })),
    ];

    const tabs = [
        { value: 'importer', label: 'Importer' },
        { value: 'webcam', label: 'Webcam' },
        { value: 'lien', label: 'Lien' },
        { value: 'photos', label: 'Photos' },
        { value: 'drive', label: 'Lyxal Drive' },
        { value: 'lyxal_photos', label: 'Lyxal Photos' }
    ] as const;

    return (
        <Modal 
            opened={opened} 
            onClose={() => { clearSelection(); onClose(); }} 
            title="Insérer une image depuis :" 
            centered 
            size="90%"
            styles={{
                root: { overflow: 'hidden' },
                title: { fontWeight: 600, fontSize: '14px', color: 'var(--mantine-color-surreal-6)' },
                body: { padding: 0, height: '80vh', display: 'flex', flexDirection: 'column', overflow: 'hidden' },
                content: { maxWidth: '1000px', display: 'flex', flexDirection: 'column' }
            }}
            onDragOver={(e) => e.preventDefault()}
            onDrop={(e) => e.preventDefault()}
        >
            <style>
                {`
                    .hide-scrollbar::-webkit-scrollbar {
                        display: none;
                    }
                    .drive-item {
                        transition: all 0.15s ease;
                    }
                    .drive-item:hover {
                        border-color: var(--mantine-color-surreal-6) !important;
                        background-color: var(--mantine-color-default-hover) !important;
                    }
                `}
            </style>
            <Stack 
                gap={0} 
                style={{ flex: 1, overflow: 'hidden', position: 'relative' }}
                onDragOver={(e) => e.preventDefault()}
                onDrop={(e) => e.preventDefault()}
            >
                {/* Header fixe : Onglets avec scroll horizontal Lyxal */}
                <Box style={{ borderBottom: '1px solid var(--mantine-color-default-border)', flexShrink: 0 }}>
                    <ScrollArea 
                        type="hover" 
                        scrollbars="x"
                        styles={{
                            scrollbar: { backgroundColor: 'transparent' },
                            thumb: { backgroundColor: 'var(--mantine-color-surreal-6)' },
                            corner: { backgroundColor: 'transparent' }
                        }}
                    >
                        <Group 
                            gap={2} 
                            px="xs" 
                            bg="transparent"
                            wrap="nowrap"
                        >
                            {tabs.map((tab) => (
                                <Button
                                    key={tab.value}
                                    variant="subtle"
                                    size="xs"
                                    radius="xs"
                                    style={{ 
                                        border: 'none',
                                        borderBottom: activeTab === tab.value ? '2px solid var(--mantine-color-surreal-6)' : '2px solid transparent',
                                        borderRadius: 0,
                                        backgroundColor: 'transparent',
                                        color: activeTab === tab.value ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-text)',
                                        fontWeight: activeTab === tab.value ? 600 : 400,
                                        height: 32,
                                        flexShrink: 0
                                    }}
                                    onClick={() => {
                                        setActiveTab(tab.value);
                                        setFileError(null);
                                    }}
                                >
                                    {tab.label}
                                </Button>
                            ))}
                        </Group>
                    </ScrollArea>
                </Box>

                {/* Zone de contenu défilante */}
                <Box 
                    ref={scrollViewportRef}
                    className="hide-scrollbar"
                    style={{ 
                        flex: 1, 
                        overflowY: (activeTab === 'drive' || activeTab === 'lyxal_photos' || activeTab === 'photos') ? 'hidden' : 'auto', 
                        minHeight: 0,
                        scrollbarWidth: 'none',
                        msOverflowStyle: 'none',
                        position: 'relative'
                    }}
                >
                    {activeTab === 'importer' && (
                        <Stack align="center" justify="center" mih="100%" gap="lg" p="xl">
                            {!selectedFile ? (
                                <>
                                    <input 
                                        type="file" 
                                        ref={fileInputRef} 
                                        style={{ display: 'none' }} 
                                        accept="image/png, image/jpeg, image/gif, image/webp, image/svg+xml"
                                        onChange={(e) => handleFileSelect(e.target.files)}
                                    />
                                    
                                    <Box 
                                        onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
                                        onDragLeave={() => setDragOver(false)}
                                        onDrop={(e) => { e.preventDefault(); setDragOver(false); handleFileSelect(e.dataTransfer.files); }}
                                        style={{ 
                                            width: '100%',
                                            maxWidth: 600,
                                            padding: '8% 40px',
                                            borderRadius: '8px',
                                            border: `2px dashed ${dragOver ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-default-border)'}`,
                                            backgroundColor: dragOver ? 'var(--mantine-color-default-hover)' : 'var(--mantine-color-body)',
                                            transition: 'all 0.2s'
                                        }}
                                    >
                                        <Stack align="center" gap="md">
                                            <Box style={{ 
                                                width: 64, 
                                                height: 64, 
                                                borderRadius: '50%', 
                                                backgroundColor: 'transparent', 
                                                display: 'flex', 
                                                alignItems: 'center', 
                                                justifyContent: 'center'
                                            }}>
                                                <Icon path={iconPhotoUp} size={40} color={fileError ? "red.6" : "slate.5"} stroked />
                                            </Box>
                                            <Stack gap={2} align="center">
                                                <Text fw={600} size="md">Choisir une photo à importer</Text>
                                                <Text size="sm" c="dimmed">ou faites glisser une image ici</Text>
                                            </Stack>
                                            <Button 
                                                color="surreal" 
                                                size="xs" 
                                                mt="md"
                                                onClick={() => fileInputRef.current?.click()}
                                            >
                                                Importer
                                            </Button>

                                            {fileError && (
                                                <Text size="xs" c="red.6" fw={500} mt="sm" ta="center">
                                                    {fileError}
                                                </Text>
                                            )}
                                        </Stack>
                                    </Box>
                                    <Text size="xs" c="dimmed">Formats supportés : JPG, PNG, GIF, WebP, SVG (Max 10Mo)</Text>
                                </>
                            ) : (
                                <Stack align="center" gap="md" w="100%" style={{ maxWidth: 600 }}>
                                    <Paper withBorder p="xs" radius="md" bg="var(--mantine-color-body)" shadow="sm">
                                        <img 
                                            src={previewUrl || ''} 
                                            alt="Aperçu" 
                                            style={{ 
                                                maxWidth: '100%', 
                                                maxHeight: '300px', 
                                                display: 'block',
                                                borderRadius: '4px'
                                            }} 
                                        />
                                    </Paper>
                                    <Stack gap={2} align="center">
                                        <Text fw={600} size="sm">{selectedFile.name}</Text>
                                        <Text size="xs" c="dimmed">{(selectedFile.size / (1024 * 1024)).toFixed(2)} Mo</Text>
                                    </Stack>
                                    <Group gap="sm">
                                        <Button variant="subtle" color="slate" size="xs" onClick={clearSelection}>Changer d'image</Button>
                                    </Group>
                                </Stack>
                            )}
                        </Stack>
                    )}

                    {activeTab === 'webcam' && (
                        <Center h="100%">
                            {!isWebcamActive ? (
                                <Stack align="center" gap="md">
                                    <Box style={{ 
                                        width: 80, 
                                        height: 80, 
                                        borderRadius: '50%', 
                                        backgroundColor: 'var(--mantine-color-body)', 
                                        display: 'flex', 
                                        alignItems: 'center', 
                                        justifyContent: 'center',
                                        border: '1px solid var(--mantine-color-default-border)'
                                    }}>
                                        <Icon path={iconVideoBase} size={40} c="slate.5" stroked />
                                    </Box>
                                    <Text size="sm" c="dimmed">Autorisez l'accès à votre caméra pour prendre une photo</Text>
                                    <Button color="surreal" size="xs" onClick={startWebcam}>Autoriser la caméra</Button>
                                    {fileError && <Text size="xs" c="red.6" ta="center">{fileError}</Text>}
                                </Stack>
                            ) : (
                                <Stack align="center" gap="md" w="100%" p="xl">
                                    <Box style={{ 
                                        width: '100%', 
                                        maxWidth: 600, 
                                        aspectRatio: '16/9', 
                                        backgroundColor: 'black', 
                                        borderRadius: '8px', 
                                        overflow: 'hidden',
                                        position: 'relative'
                                    }}>
                                        <video 
                                            ref={videoRef} 
                                            autoPlay 
                                            playsInline 
                                            style={{ width: '100%', height: '100%', objectFit: 'cover' }} 
                                        />
                                    </Box>
                                    <Group>
                                        <Button variant="subtle" color="slate" size="xs" onClick={stopWebcam}>Annuler</Button>
                                        <Button color="surreal" size="xs" onClick={capturePhoto}>Prendre la photo</Button>
                                    </Group>
                                </Stack>
                            )}
                        </Center>
                    )}

                    {activeTab === 'lien' && (
                        <Box p="xl" style={{ maxWidth: 600, margin: '0 auto' }}>
                            <Stack gap="md">
                                <Text size="sm" fw={500}>Coller l'URL de l'image :</Text>
                                <TextInput 
                                    placeholder="https://exemple.com/image.jpg" 
                                    size="sm"
                                    value={linkUrl}
                                    onChange={(e) => setLinkUrl(e.currentTarget.value)}
                                    error={linkUrl && !previewUrl && linkUrl.length > 10 ? "L'URL ne semble pas pointer vers une image valide" : null}
                                />
                                <Text size="xs" c="dimmed">
                                    Si l'URL est correcte, un aperçu de l'image s'affichera ici.
                                </Text>
                                <Box 
                                    h={250} 
                                    bg="var(--mantine-color-body)" 
                                    style={{ 
                                        borderRadius: '8px', 
                                        border: '1px dashed var(--mantine-color-default-border)', 
                                        display: 'flex', 
                                        alignItems: 'center', 
                                        justifyContent: 'center',
                                        overflow: 'hidden'
                                    }}
                                >
                                    {previewUrl ? (
                                        <img 
                                            src={previewUrl} 
                                            alt="Aperçu du lien" 
                                            style={{ maxWidth: '100%', maxHeight: '100%', objectFit: 'contain' }}
                                            onError={() => {
                                                setPreviewUrl(null);
                                                setFileError("Impossible de charger l'image depuis ce lien.");
                                            }}
                                        />
                                    ) : (
                                        <Stack align="center" gap="xs">
                                            <Icon path={iconPhoto} size={48} color="slate.5" stroked />
                                            {fileError && <Text size="xs" c="red.6">{fileError}</Text>}
                                        </Stack>
                                    )}
                                </Box>
                            </Stack>
                        </Box>
                    )}

                    {activeTab === 'photos' && (
                        <Box ref={photosScrollRef} h="100%" style={{ overflowY: 'auto' }} className="hide-scrollbar">
                            <Box p="md">
                                <Grid gutter="xs">
                                    {mockPhotosFlattened.map((item, index) => (
                                        <Grid.Col key={index} span={{ base: 6, sm: 4, md: 2.4 }}>
                                            {item.type === 'date' ? (
                                                <Center h={120} p="xs">
                                                    <Text size="xs" fw={700} c="surreal.6" tt="uppercase" ta="center" style={{ letterSpacing: '0.5px', lineHeight: 1.2 }}>
                                                        {(item as any).label}
                                                    </Text>
                                                </Center>
                                            ) : (
                                                <Box 
                                                    onClick={() => handlePhotoSelect((item as any).id, (item as any).url)}
                                                    style={{ 
                                                        position: 'relative',
                                                        cursor: 'pointer',
                                                        borderRadius: '4px',
                                                        overflow: 'hidden',
                                                        border: selectedPhotoId === (item as any).id ? '3px solid var(--mantine-color-surreal-6)' : '1px solid var(--mantine-color-default-border)',
                                                        height: 120, // Hauteur fixe uniforme
                                                        transition: 'transform 0.1s ease',
                                                        transform: selectedPhotoId === (item as any).id ? 'scale(0.98)' : 'none',
                                                        display: 'flex',
                                                        alignItems: 'center',
                                                        justifyContent: 'center',
                                                        backgroundColor: 'var(--mantine-color-body)'
                                                    }}
                                                >
                                                    <img 
                                                        src={(item as any).url} 
                                                        alt="" 
                                                        style={{ 
                                                            maxWidth: '100%', 
                                                            maxHeight: '100%', 
                                                            objectFit: 'contain',
                                                            display: 'block'
                                                        }}
                                                    />
                                                    {selectedPhotoId === (item as any).id && (
                                                        <Box style={{ 
                                                            position: 'absolute', 
                                                            top: 4, 
                                                            right: 4, 
                                                            backgroundColor: 'var(--mantine-color-surreal-6)', 
                                                            borderRadius: '50%', 
                                                            width: 18, 
                                                            height: 18, 
                                                            display: 'flex', 
                                                            alignItems: 'center', 
                                                            justifyContent: 'center' 
                                                        }}>
                                                            <Icon path={iconPlus} size={12} color="white" style={{ transform: 'rotate(45deg)' }} />
                                                        </Box>
                                                    )}
                                                </Box>
                                            )}
                                        </Grid.Col>
                                    ))}
                                </Grid>
                            </Box>
                        </Box>
                    )}

                    {activeTab === 'drive' && (
                        <Group gap={0} align="stretch" h="100%" wrap="nowrap">
                            {/* Sidebar gauche */}
                            <Stack 
                                w={160} 
                                p="xs" 
                                gap={4} 
                                style={{ borderRight: '1px solid var(--mantine-color-default-border)', flexShrink: 0 }}
                            >
                                <Button 
                                    variant={driveSubTab === 'recents' ? 'light' : 'subtle'} 
                                    color={driveSubTab === 'recents' ? 'surreal' : 'slate'}
                                    justify="start"
                                    size="xs"
                                    radius="sm"
                                    h={32}
                                    onClick={() => { setDriveSubTab('recents'); setShowScrollTop(false); }}
                                >
                                    Récents
                                </Button>
                                <Button 
                                    variant={driveSubTab === 'mon_drive' ? 'light' : 'subtle'} 
                                    color={driveSubTab === 'mon_drive' ? 'surreal' : 'slate'}
                                    justify="start"
                                    size="xs"
                                    radius="sm"
                                    h={32}
                                    onClick={() => { 
                                        setDriveSubTab('mon_drive'); 
                                        setDrivePath(['Mon drive']);
                                        setShowScrollTop(false); 
                                    }}
                                >
                                    Mon drive
                                </Button>
                                <Button 
                                    variant={driveSubTab === 'partage' ? 'light' : 'subtle'} 
                                    color={driveSubTab === 'partage' ? 'surreal' : 'slate'}
                                    justify="start"
                                    size="xs"
                                    radius="sm"
                                    h={32}
                                    onClick={() => { 
                                        setDriveSubTab('partage'); 
                                        setDrivePath(['Partagé avec moi']);
                                        setShowScrollTop(false); 
                                    }}
                                >
                                    Partagé avec moi
                                </Button>
                            </Stack>

                            {/* Zone droite avec header fixe */}
                            <Stack style={{ flex: 1, minWidth: 0 }} gap={0}>
                                {/* Header fixe */}
                                <Box p="xl" pb="xs" style={{ borderBottom: '1px solid var(--mantine-color-default-border)', flexShrink: 0 }}>
                                    <Stack gap="lg">
                                        <Stack gap={6}>
                                            {(driveSubTab === 'mon_drive' || driveSubTab === 'partage') ? (
                                                <Breadcrumbs 
                                                    separator={<Icon path={iconChevronRight} size={10} c="dimmed" />}
                                                    styles={{
                                                        root: { flexWrap: 'nowrap', overflow: 'hidden' },
                                                        breadcrumb: { fontSize: '13px' },
                                                        separator: { margin: '0 8px' }
                                                    }}
                                                >
                                                    {drivePath.map((item, index) => (
                                                        <UnstyledButton 
                                                            key={index} 
                                                            onClick={() => {
                                                                setDrivePath(drivePath.slice(0, index + 1));
                                                                setSelectedDriveFileId(null);
                                                                driveScrollRef.current?.scrollTo({ top: 0, behavior: 'instant' });
                                                            }}
                                                            style={{ 
                                                                color: index === drivePath.length - 1 ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-text)',
                                                                fontWeight: index === drivePath.length - 1 ? 600 : 500
                                                            }}
                                                        >
                                                            {item}
                                                        </UnstyledButton>
                                                    ))}
                                                </Breadcrumbs>
                                            ) : (
                                                <Text size="sm" fw={600} c="surreal.6">
                                                    {driveSubTab === 'recents' ? 'Fichiers récents' : 'Fichiers partagés'}
                                                </Text>
                                            )}
                                            <Group gap="xs">
                                                <TextInput 
                                                    placeholder={`Rechercher dans ${driveSubTab === 'recents' ? 'Récents' : driveSubTab === 'mon_drive' ? 'Mon drive' : 'Partagé avec moi'}...`} 
                                                    leftSection={<Icon path={iconSearch} size={14} />}
                                                    size="sm"
                                                    style={{ flex: 1 }}
                                                />
                                                <Tooltip label={driveViewMode === 'grid' ? "Vue liste" : "Vue grille"} color="slate">
                                                    <ActionIcon 
                                                        variant="subtle" 
                                                        color="slate" 
                                                        size="lg"
                                                        onClick={() => setDriveViewMode(driveViewMode === 'grid' ? 'list' : 'grid')}
                                                    >
                                                        <Icon path={driveViewMode === 'grid' ? iconList : iconLayoutGrid} size={20} />
                                                    </ActionIcon>
                                                </Tooltip>
                                            </Group>
                                        </Stack>
                                    </Stack>
                                </Box>

                                {/* Contenu défilant */}
                                <Box ref={driveScrollRef} style={{ flex: 1, overflowY: 'auto' }} p="xl" className="hide-scrollbar">
                                    {driveViewMode === 'grid' ? (
                                        <Stack gap="xl">
                                            {/* Section Dossiers */}
                                            {(driveSubTab === 'mon_drive' || driveSubTab === 'partage') && (
                                                <Stack gap="md">
                                                    <Text size="xs" fw={700} c="dimmed" tt="uppercase" style={{ letterSpacing: '0.8px' }}>Dossiers</Text>
                                                    <Grid gutter="md">
                                                        {(driveSubTab === 'mon_drive' 
                                                            ? (drivePath.length === 1 
                                                                ? ['Projets 2025', 'Archives Lyxal', 'Screenshots'] 
                                                                : (drivePath.length < 5 
                                                                    ? [`Sous-dossier ${drivePath.length}`, `Ressources (Niv ${drivePath.length})`, `Brouillons ${drivePath.length}`] 
                                                                    : []))
                                                            : (drivePath.length === 1
                                                                ? ['Dossier Partagé Alpha', 'Asset Design v2']
                                                                : (drivePath.length < 5 
                                                                    ? [`Archives partagées (Niv ${drivePath.length})`, `Éléments collaboratifs (${drivePath.length})`] 
                                                                    : []))
                                                        ).map((folder, idx) => (
                                                            <Grid.Col key={folder + idx} span={{ base: 6, sm: 4, md: 3 }}>
                                                                <UnstyledButton 
                                                                    onClick={() => {
                                                                        if (drivePath[drivePath.length - 1] === folder) return;
                                                                        setDrivePath([...drivePath, folder]);
                                                                        setSelectedDriveFileId(null);
                                                                        driveScrollRef.current?.scrollTo({ top: 0, behavior: 'instant' });
                                                                    }}
                                                                    style={{ 
                                                                        width: '100%',
                                                                        padding: '12px',
                                                                        borderRadius: '6px',
                                                                        border: '1px solid var(--mantine-color-default-border)',
                                                                        backgroundColor: 'var(--mantine-color-body)',
                                                                        transition: 'all 0.1s'
                                                                    }}
                                                                    className="drive-item"
                                                                >
                                                                    <Group gap="sm" wrap="nowrap">
                                                                        <Icon path={iconFolder} size={20} color="surreal.6" stroked />
                                                                        <Text size="xs" fw={600} truncate>{folder}</Text>
                                                                    </Group>
                                                                </UnstyledButton>
                                                            </Grid.Col>
                                                        ))}
                                                    </Grid>
                                                </Stack>
                                            )}

                                            {/* Section Fichiers */}
                                            <Stack gap="md">
                                                {(driveSubTab === 'mon_drive' || driveSubTab === 'partage') && (
                                                    <Text size="xs" fw={700} c="dimmed" tt="uppercase" style={{ letterSpacing: '0.8px' }}>Fichiers</Text>
                                                )}
                                                <Grid gutter="md">
                                                    {Array.from({ length: drivePath.length === 1 ? (driveSubTab === 'partage' ? 10 : 24) : 12 }).map((_, i) => (
                                                        <Grid.Col key={i} span={{ base: 6, sm: 4, md: 3 }}>
                                                            <Box 
                                                                onClick={() => setSelectedDriveFileId(`drive-${drivePath.length}-${i}`)}
                                                                style={{ 
                                                                    cursor: 'pointer',
                                                                    borderRadius: '6px',
                                                                    overflow: 'hidden',
                                                                    border: selectedDriveFileId === `drive-${drivePath.length}-${i}` ? '2px solid var(--mantine-color-surreal-6)' : '1px solid var(--mantine-color-default-border)',
                                                                    backgroundColor: 'var(--mantine-color-body)',
                                                                    transition: 'all 0.15s ease',
                                                                    transform: selectedDriveFileId === `drive-${drivePath.length}-${i}` ? 'scale(0.98)' : 'none',
                                                                    boxShadow: selectedDriveFileId === `drive-${drivePath.length}-${i}` ? 'var(--mantine-shadow-sm)' : 'none'
                                                                }}
                                                                className="drive-item"
                                                            >
                                                                {/* Zone image carrée centrée */}
                                                                <Box style={{ 
                                                                    height: 120, 
                                                                    width: '100%', 
                                                                    display: 'flex', 
                                                                    alignItems: 'center', 
                                                                    justifyContent: 'center',
                                                                    backgroundColor: 'var(--mantine-color-body)',
                                                                    borderBottom: '1px solid var(--mantine-color-default-border)'
                                                                }}>
                                                                    <img 
                                                                        src={`https://placehold.co/150x150/${selectedDriveFileId === `drive-${drivePath.length}-${i}` ? (driveSubTab === 'partage' ? '5f3dc4' : '6b65fb') : 'slate'}/ffffff.svg?text=${driveSubTab === 'partage' ? 'Shared' : drivePath[drivePath.length-1].substring(0,3).replace(/ /g, '+')}+${i+1}`}
                                                                        alt={`Image ${i+1}`}
                                                                        style={{ 
                                                                            maxWidth: '100%', 
                                                                            maxHeight: '100%', 
                                                                            objectFit: 'contain',
                                                                            display: 'block'
                                                                        }}
                                                                    />
                                                                </Box>
                                                                
                                                                {/* Zone info fichier */}
                                                                <Group gap="xs" p="xs" wrap="nowrap" align="center">
                                                                    <Icon path={iconPhoto} size={16} color="surreal.6" stroked />
                                                                    <Text size="xs" fw={500} truncate>
                                                                        {driveSubTab === 'partage' ? `Shared_File_${i+1}.jpg` : `${drivePath[drivePath.length-1].replace(/ /g, '_')}_Img_{i+1}.png`}
                                                                    </Text>
                                                                </Group>
                                                            </Box>
                                                        </Grid.Col>
                                                    ))}
                                                </Grid>
                                            </Stack>
                                        </Stack>
                                    ) : (
                                        <Stack gap="md">
                                            {/* Header unique pour le tableau */}
                                            <Box style={{ borderBottom: '1px solid var(--mantine-color-default-border)', paddingBottom: '8px' }}>
                                                <Group gap="md" px="xs" wrap="nowrap">
                                                    <Text size="xs" fw={700} c="dimmed" tt="uppercase" style={{ flex: 1.5, letterSpacing: '0.8px' }}>Nom</Text>
                                                    <Text size="xs" fw={700} c="dimmed" tt="uppercase" style={{ flex: 1, letterSpacing: '0.8px' }}>
                                                        {driveSubTab === 'partage' ? 'Partagé par' : 'Propriétaire'}
                                                    </Text>
                                                    <Text size="xs" fw={700} c="dimmed" tt="uppercase" style={{ flex: 1, letterSpacing: '0.8px' }}>
                                                        {driveSubTab === 'partage' ? 'Date de partage' : 'Dernière modification'}
                                                    </Text>
                                                    <Text size="xs" fw={700} c="dimmed" tt="uppercase" style={{ flex: 0.5, letterSpacing: '0.8px' }} ta="right">Taille</Text>
                                                </Group>
                                            </Box>

                                            <Stack gap="xs">
                                                {/* Dossiers en premier */}
                                                {(driveSubTab === 'mon_drive' || driveSubTab === 'partage') && (
                                                    (driveSubTab === 'mon_drive' 
                                                        ? (drivePath.length === 1 
                                                            ? ['Projets 2025', 'Archives Lyxal', 'Screenshots'] 
                                                            : (drivePath.length < 5 
                                                                ? [`Sous-dossier ${drivePath.length}`, `Ressources (Niv ${drivePath.length})`, `Brouillons ${drivePath.length}`] 
                                                                : []))
                                                        : (drivePath.length === 1
                                                            ? ['Dossier Partagé Alpha', 'Asset Design v2']
                                                            : (drivePath.length < 5 
                                                                ? [`Archives partagées (Niv ${drivePath.length})`, `Éléments collaboratifs (${drivePath.length})`] 
                                                                : []))
                                                    ).map((folder, idx) => (
                                                        <Paper 
                                                            key={folder + idx} 
                                                            withBorder 
                                                            p="xs" 
                                                            radius="sm"
                                                            style={{ 
                                                                cursor: 'pointer'
                                                            }}
                                                            onClick={() => {
                                                                if (drivePath[drivePath.length - 1] === folder) return;
                                                                setDrivePath([...drivePath, folder]);
                                                                setSelectedDriveFileId(null);
                                                                driveScrollRef.current?.scrollTo({ top: 0, behavior: 'instant' });
                                                            }}
                                                            className="drive-item"
                                                        >
                                                            <Group gap="md" wrap="nowrap">
                                                                <Group gap="md" style={{ flex: 1.5 }} wrap="nowrap">
                                                                    <Icon path={iconFolder} size={20} color="surreal.6" stroked />
                                                                    <Text size="sm" fw={600} truncate>{folder}</Text>
                                                                </Group>
                                                                <Text size="xs" c="dimmed" style={{ flex: 1 }}>
                                                                    {driveSubTab === 'partage' ? (idx === 0 ? 'Marie Durand' : 'Paul Lefebvre') : 'Moi'}
                                                                </Text>
                                                                <Text size="xs" c="dimmed" style={{ flex: 1 }}>{12-idx} Jan 2026</Text>
                                                                <Text size="xs" c="dimmed" style={{ flex: 0.5 }} ta="right">---</Text>
                                                            </Group>
                                                        </Paper>
                                                    ))
                                                )}

                                                {/* Fichiers en dessous */}
                                                {Array.from({ length: drivePath.length === 1 ? (driveSubTab === 'partage' ? 10 : 24) : 12 }).map((_, i) => (
                                                    <Paper 
                                                        key={i} 
                                                        withBorder 
                                                        p={0}
                                                        radius="sm" 
                                                        style={{ 
                                                            cursor: 'pointer', 
                                                            overflow: 'hidden',
                                                            borderColor: selectedDriveFileId === `drive-list-${drivePath.length}-${i}` ? 'var(--mantine-color-surreal-6)' : undefined,
                                                            backgroundColor: selectedDriveFileId === `drive-list-${drivePath.length}-${i}` ? 'var(--mantine-color-surreal-0)' : undefined
                                                        }}
                                                        onClick={() => setSelectedDriveFileId(`drive-list-${drivePath.length}-${i}`)}
                                                    >
                                                        <Group gap="md" wrap="nowrap" p="xs" align="center">
                                                            <Group gap="md" style={{ flex: 1.5 }} wrap="nowrap">
                                                                <Box style={{ 
                                                                    width: 32, 
                                                                    height: 32, 
                                                                    display: 'flex', 
                                                                    alignItems: 'center', 
                                                                    justifyContent: 'center',
                                                                    backgroundColor: 'var(--mantine-color-default-hover)',
                                                                    borderRadius: '4px',
                                                                    overflow: 'hidden',
                                                                    flexShrink: 0
                                                                }}>
                                                                    <img 
                                                                        src={`https://placehold.co/100x100/${driveSubTab === 'partage' ? '5f3dc4' : '6b65fb'}/ffffff.svg?text=${i+1}`}
                                                                        alt="" 
                                                                        style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                                                                    />
                                                                </Box>
                                                                <Text size="sm" fw={500} truncate>
                                                                    {driveSubTab === 'partage' ? `Shared_File_${i+1}.jpg` : `${drivePath[drivePath.length-1].replace(/ /g, '_')}_Img_${i+1}.png`}
                                                                </Text>
                                                            </Group>
                                                            <Text size="xs" c="dimmed" style={{ flex: 1 }}>
                                                                {driveSubTab === 'partage' ? (i % 2 === 0 ? 'Marie Durand' : 'Paul Lefebvre') : (i % 4 === 0 ? 'Jean Dupont' : 'Moi')}
                                                            </Text>
                                                            <Text size="xs" c="dimmed" style={{ flex: 1 }}>{10-Math.floor(i/3)} Jan 2026</Text>
                                                            <Text size="xs" c="dimmed" style={{ flex: 0.5 }} ta="right">{(1.2 + (i * 0.1)).toFixed(1)} Mo</Text>
                                                        </Group>
                                                    </Paper>
                                                ))}
                                            </Stack>
                                        </Stack>
                                    )}
                                </Box>
                            </Stack>
                        </Group>
                    )}

                    {activeTab === 'lyxal_photos' && (
                        <Group gap={0} align="stretch" h="100%" wrap="nowrap">
                            {/* Sidebar gauche */}
                            <Stack 
                                w={160} 
                                p="xs" 
                                gap={4} 
                                style={{ borderRight: '1px solid var(--mantine-color-default-border)', flexShrink: 0 }}
                            >
                                <Button 
                                    variant={lyxalPhotosSubTab === 'explorer' ? 'light' : 'subtle'} 
                                    color={lyxalPhotosSubTab === 'explorer' ? 'surreal' : 'slate'}
                                    justify="start"
                                    size="xs"
                                    radius="sm"
                                    h={32}
                                    onClick={() => { setLyxalPhotosSubTab('explorer'); setShowScrollTop(false); }}
                                >
                                    Explorer
                                </Button>
                                <Button 
                                    variant={lyxalPhotosSubTab === 'favoris' ? 'light' : 'subtle'} 
                                    color={lyxalPhotosSubTab === 'favoris' ? 'surreal' : 'slate'}
                                    justify="start"
                                    size="xs"
                                    radius="sm"
                                    h={32}
                                    onClick={() => { setLyxalPhotosSubTab('favoris'); setShowScrollTop(false); }}
                                >
                                    Favoris
                                </Button>
                                <Button 
                                    variant={lyxalPhotosSubTab === 'albums' ? 'light' : 'subtle'} 
                                    color={lyxalPhotosSubTab === 'albums' ? 'surreal' : 'slate'}
                                    justify="start"
                                    size="xs"
                                    radius="sm"
                                    h={32}
                                    onClick={() => { setLyxalPhotosSubTab('albums'); setShowScrollTop(false); }}
                                >
                                    Albums
                                </Button>
                            </Stack>

                            {/* Zone droite avec header fixe */}
                            <Stack style={{ flex: 1, minWidth: 0 }} gap={0}>
                                {/* Header fixe */}
                                <Box p="xl" pb="xs" style={{ borderBottom: '1px solid var(--mantine-color-default-border)', flexShrink: 0 }}>
                                    <Stack gap="lg">
                                        <Stack gap={6}>
                                            <Text size="sm" fw={600} c="surreal.6">
                                                {lyxalPhotosSubTab === 'explorer' ? 'Explorer Lyxal Photos' : lyxalPhotosSubTab === 'favoris' ? 'Mes Favoris' : 'Mes Albums'}
                                            </Text>
                                            <Group gap="xs">
                                                <TextInput 
                                                    placeholder="Rechercher des images haute qualité..." 
                                                    leftSection={<Icon path={iconSearch} size={14} />}
                                                    size="sm"
                                                    style={{ flex: 1 }}
                                                />
                                                <Tooltip label={lyxalPhotosViewMode === 'grid' ? "Vue liste" : "Vue grille"} color="slate">
                                                    <ActionIcon 
                                                        variant="subtle" 
                                                        color="slate" 
                                                        size="lg"
                                                        onClick={() => setLyxalPhotosViewMode(lyxalPhotosViewMode === 'grid' ? 'list' : 'grid')}
                                                    >
                                                        <Icon path={lyxalPhotosViewMode === 'grid' ? iconList : iconLayoutGrid} size={20} />
                                                    </ActionIcon>
                                                </Tooltip>
                                            </Group>
                                        </Stack>
                                    </Stack>
                                </Box>

                                {/* Contenu défilant */}
                                <Box ref={lyxalPhotosScrollRef} style={{ flex: 1, overflowY: 'auto' }} p="xl" className="hide-scrollbar">
                                    {lyxalPhotosViewMode === 'grid' ? (
                                        <Grid gutter="md">
                                            {Array.from({ length: 40 }).map((_, i) => (
                                                <Grid.Col key={i} span={{ base: 6, sm: 4, md: 3 }}>
                                                    <Box 
                                                        onClick={() => setSelectedLyxalPhotoId(`lyxal-photo-${i}`)}
                                                        style={{ 
                                                            cursor: 'pointer',
                                                            borderRadius: '6px',
                                                            overflow: 'hidden',
                                                            border: selectedLyxalPhotoId === `lyxal-photo-${i}` ? '2px solid var(--mantine-color-surreal-6)' : '1px solid var(--mantine-color-default-border)',
                                                            backgroundColor: 'var(--mantine-color-body)',
                                                            transition: 'all 0.15s ease',
                                                            transform: selectedLyxalPhotoId === `lyxal-photo-${i}` ? 'scale(0.98)' : 'none'
                                                        }}
                                                        className="drive-item"
                                                    >
                                                        <Box style={{ 
                                                            height: 140, 
                                                            width: '100%', 
                                                            display: 'flex', 
                                                            alignItems: 'center', 
                                                            justifyContent: 'center',
                                                            backgroundColor: 'var(--mantine-color-body)',
                                                            borderBottom: '1px solid var(--mantine-color-default-border)'
                                                        }}>
                                                            <img 
                                                                src={`https://placehold.co/200x200/${(i % 5 === 0) ? 'e67700' : (i % 3 === 0) ? '5f3dc4' : '6b65fb'}/ffffff.svg?text=Stock+${i+1}`}
                                                                alt={`Stock ${i+1}`}
                                                                style={{ 
                                                                    maxWidth: '100%', 
                                                                    maxHeight: '100%', 
                                                                    objectFit: 'cover',
                                                                    display: 'block'
                                                                }}
                                                            />
                                                        </Box>
                                                        <Group gap="xs" p="xs" wrap="nowrap" align="center">
                                                            <Icon path={iconPhoto} size={16} color="surreal.6" stroked />
                                                            <Text size="xs" truncate fw={500}>Lyxal_Stock_{i+1}</Text>
                                                        </Group>
                                                    </Box>
                                                </Grid.Col>
                                            ))}
                                        </Grid>
                                    ) : (
                                        <Stack gap="xs">
                                            {Array.from({ length: 20 }).map((_, i) => (
                                                <Paper 
                                                    key={i} 
                                                    withBorder 
                                                    p="xs"
                                                    radius="sm" 
                                                    style={{ 
                                                        cursor: 'pointer',
                                                        borderColor: selectedLyxalPhotoId === `lyxal-list-${i}` ? 'var(--mantine-color-surreal-6)' : undefined,
                                                        backgroundColor: selectedLyxalPhotoId === `lyxal-list-${i}` ? 'var(--mantine-color-surreal-0)' : undefined
                                                    }}
                                                    onClick={() => setSelectedLyxalPhotoId(`lyxal-list-${i}`)}
                                                >
                                                    <Group gap="md" wrap="nowrap">
                                                        <Box style={{ width: 50, height: 50, borderRadius: '4px', overflow: 'hidden' }}>
                                                            <img src={`https://placehold.co/100x100/6b65fb/ffffff.svg?text=${i+1}`} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                                        </Box>
                                                        <Box style={{ flex: 1 }}>
                                                            <Text size="sm" fw={500}>Photo_Stock_HD_{i+1}.jpg</Text>
                                                            <Text size="xs" c="dimmed">Résolution: 1920x1080 • 2.4 Mo</Text>
                                                        </Box>
                                                    </Group>
                                                </Paper>
                                            ))}
                                        </Stack>
                                    )}
                                </Box>
                            </Stack>
                        </Group>
                    )}
                </Box>

                {(activeTab === 'photos' || activeTab === 'drive' || activeTab === 'lyxal_photos') && showScrollTop && (
                    <Tooltip label="Retour en haut" color="surreal">
                        <ActionIcon
                            color="surreal"
                            variant="filled"
                            size="lg"
                            radius="xl"
                            style={{
                                position: 'absolute',
                                bottom: 80,
                                right: 20,
                                zIndex: 100,
                                boxShadow: 'var(--mantine-shadow-md)',
                                transition: 'opacity 0.2s, visibility 0.2s',
                                opacity: showScrollTop ? 1 : 0,
                                visibility: showScrollTop ? 'visible' : 'hidden'
                            }}
                            onClick={slowScrollToTop}
                        >
                            <Icon path={iconChevronsUp} size={20} />
                        </ActionIcon>
                    </Tooltip>
                )}

                {/* Footer fixe : Boutons */}
                <Group justify="end" px="md" py="md" style={{ borderTop: '1px solid var(--mantine-color-default-border)', flexShrink: 0 }}>
                    <Button variant="subtle" color="slate" onClick={onClose} size="xs">Annuler</Button>
                    <Button 
                        color="surreal" 
                        size="xs"
                        onClick={() => {
                            // L'insertion réelle dans le document n'est pas encore implémentée
                            // dans la zone centrale (WordView), on ferme juste le modal.
                            onClose();
                        }}
                    >
                        Insérer
                    </Button>
                </Group>
            </Stack>
        </Modal>
    );
}
