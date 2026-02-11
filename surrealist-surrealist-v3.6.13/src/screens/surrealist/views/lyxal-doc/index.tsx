import { Box, Stack, ScrollArea } from "@mantine/core";
import { useMemo, useState } from "react";
import { 
    iconPlay,
    iconTable,
    iconCursor,
    iconFile
} from "~/util/icons";
import { WordView } from "./WordView";
import { ExcelView } from "./ExcelView";
import { SlidesView } from "./SlidesView";
import { DrawView } from "./DrawView";
import { LyxalHeader } from "./components/LyxalHeader";

export function LyxalDocView() {
    const [activeTab, setActiveTab] = useState<string>("word");

    const activeView = useMemo(() => {
        switch (activeTab) {
            case "word": return <WordView />;
            case "excel": return <ExcelView />;
            case "slides": return <SlidesView />;
            case "draw": return <DrawView />;
            default: return null;
        }
    }, [activeTab]);

    const config = useMemo(() => {
        const configs: Record<string, { color: string, title: string, icon: any }> = {
            word: { color: 'blue', title: 'Document Word', icon: iconFile },
            excel: { color: 'green', title: 'Classeur Excel', icon: iconTable },
            slides: { color: 'orange', title: 'Présentation', icon: iconPlay },
            draw: { color: 'grape', title: 'Dessin Vectoriel', icon: iconCursor },
        };
        return configs[activeTab] || configs.word;
    }, [activeTab]);

    return (
        <Stack h="100%" gap={0} id="lyxal-doc-container">
            {/* Ribbon / Top Bar - Office Cloud Style */}
            <LyxalHeader 
                activeTab={activeTab} 
                onTabChange={setActiveTab} 
                config={config} 
            />

            {/* Main Content Area */}
            <Box flex={1} bg="slate.9" style={{ overflow: 'hidden' }} id="lyxal-doc-viewport">
                <Box h="100%" id="lyxal-doc-viewport-full">{activeView}</Box>
            </Box>
        </Stack>
    );
}

export default LyxalDocView;
