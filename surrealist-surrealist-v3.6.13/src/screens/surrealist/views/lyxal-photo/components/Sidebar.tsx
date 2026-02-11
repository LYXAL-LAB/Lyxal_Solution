import { Stack, Text, ScrollArea, Box } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { Entry } from "~/components/Entry";
import { mdiImage, mdiImageAlbum, mdiAccountGroup, mdiMapMarker, mdiHeart, mdiNewBox, mdiPrinter } from "@mdi/js";
import { useIsLight } from "~/hooks/theme";
import classes from "./style.module.scss";
import { useState } from "react";
import clsx from "clsx";

const MAIN_ITEMS = [
    { label: "Photos", icon: mdiImage },
    { label: "Nouvelles Fonctionnalités", icon: mdiNewBox },
    { label: "Imprimerie", icon: mdiPrinter },
];

const COLLECTION_ITEMS = [
    { label: "Albums", icon: mdiImageAlbum },
    { label: "Personnes", icon: mdiAccountGroup },
    { label: "Lieux", icon: mdiMapMarker },
    { label: "Favoris", icon: mdiHeart },
];

export function Sidebar() {
    const isLight = useIsLight();
    const [active, setActive] = useState("Photos");

    const renderItem = (item: typeof MAIN_ITEMS[0]) => {
        const isActive = active === item.label;
        return (
                            <Entry 
                                key={item.label}
                                isActive={isActive}
                                onClick={() => setActive(item.label)}
                                className={clsx(classes.navEntry, isActive && classes.navEntryActive)}
                                leftSection={<Icon path={item.icon} size={16} />} // Size 16 * 1.5 multiplier = 24px
                            >
                                <Text
                                    truncate
                                    inherit
                                    span
                                    lh="20px" // Label line-height 20
                                    size="sm"
                                    fw={500}
                                >
                                    {item.label}
                                </Text>
                            </Entry>
        );
    };

    return (
        <Stack 
            w={256} 
            h="100%" 
            gap={0}
            bg={isLight ? "slate.0" : "slate.9"}
            style={{ 
                borderRight: "1px solid var(--surrealist-border)",
                flexShrink: 0,
            }}
        >
            <ScrollArea style={{ flex: 1 }}>
                {/* Padding top adjusted to visually push content down slightly as requested, 
                    creating that specific Google Photos breathing room */}
                <Stack p="md" pt={12} gap={4}>
                    {MAIN_ITEMS.map(renderItem)}
                    
                    <Box mt="xl" mb={8} px="xs">
                        <Text 
                            size="xs" 
                            fw={700} 
                            c="dimmed" 
                            tt="uppercase" 
                            style={{ fontSize: '11px', letterSpacing: '0.8px' }}
                        >
                            Collections
                        </Text>
                    </Box>
                    
                    {COLLECTION_ITEMS.map(renderItem)}
                </Stack>
            </ScrollArea>
        </Stack>
    );
}
