import { Box, Group, Tooltip, ActionIcon, Text } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { 
    mdiPlus, 
    mdiHelpCircleOutline, 
    mdiCogOutline, 
    mdiDotsGrid, 
    mdiAccountCircle 
} from "@mdi/js";
import { SearchBar } from "./SearchBar";
import classes from "./style.module.scss";
import { useIsLight } from "~/hooks/theme";

export function Header() {
    const isLight = useIsLight();
    const sidebarBg = isLight ? "slate.0" : "slate.9";

    return (
        <div className={classes.globalHeader} id="lyxal-header-root">
            {/* Wrapper Div: 64px height, padding 16px */}
            <Box h={64} px={16} w="100%" style={{ display: 'flex', alignItems: 'center' }} id="lyxal-header-wrapper">
                
                {/* Logo Area: Matches Sidebar Width (256px) */}
                <Box w={256} h="100%" style={{ display: 'flex', alignItems: 'center', borderRight: "1px solid var(--surrealist-border)" }} bg={sidebarBg} id="lyxal-header-logo-area">
                    {/* "on a ensuite une autre div avec une hauteur 64 px et un padding left 16" */}
                    <Box h={64} pl={16} style={{ display: 'flex', alignItems: 'center' }} id="lyxal-header-logo-container-inner">
                        {/* New Wrapper Div: dimensions auto, no padding, no margin */}
                        <Box m={0} p={0} style={{ display: 'flex', alignItems: 'center' }} id="lyxal-header-logo-brand-wrapper">
                            {/* "dedans Lyxal fait hauteur 23 un margin right 5 px" */}
                            <Box h={23} mr={5} style={{ display: 'flex', alignItems: 'center' }} id="lyxal-header-brand-lyxal-box">
                                <Text span fw={700} size="xl" c="var(--surrealist-primary)" style={{ lineHeight: 1, letterSpacing: '-0.5px' }} id="lyxal-header-brand-lyxal-text">
                                    Lyxal
                                </Text>
                            </Box>
                            {/* "et Photos hauteur 24 pas de margin pas de padding" */}
                            <Box h={24} m={0} p={0} style={{ display: 'flex', alignItems: 'center' }} id="lyxal-header-brand-photos-box">
                                <Text span fw={400} size="xl" c="var(--surrealist-text)" style={{ lineHeight: 1, letterSpacing: '-0.5px' }} id="lyxal-header-brand-photos-text">
                                    Photos
                                </Text>
                            </Box>
                        </Box>
                    </Box>
                </Box>

                {/* Right Area: Search & Icons */}
                <Box style={{ flex: 1, display: 'flex', alignItems: 'center', paddingLeft: 24, paddingRight: 24 }} id="lyxal-header-right-area">
                    <Box style={{ flex: 1, display: 'flex', justifyContent: 'flex-start' }} id="lyxal-header-search-container">
                        <SearchBar />
                    </Box>
                    <Group gap="xs" id="lyxal-header-actions-group">
                        <Tooltip label="Créer et ajouter des photos" id="lyxal-header-tooltip-plus">
                            <ActionIcon variant="subtle" color="gray" size="lg" radius="xl" id="lyxal-header-action-plus">
                                <Icon path={mdiPlus} id="lyxal-header-icon-plus" />
                            </ActionIcon>
                        </Tooltip>
                        <Tooltip label="Aide et commentaires" id="lyxal-header-tooltip-help">
                            <ActionIcon variant="subtle" color="gray" size="lg" radius="xl" id="lyxal-header-action-help">
                                <Icon path={mdiHelpCircleOutline} id="lyxal-header-icon-help" />
                            </ActionIcon>
                        </Tooltip>
                        <Tooltip label="Configuration" id="lyxal-header-tooltip-config">
                            <ActionIcon variant="subtle" color="gray" size="lg" radius="xl" id="lyxal-header-action-config">
                                <Icon path={mdiCogOutline} id="lyxal-header-icon-config" />
                            </ActionIcon>
                        </Tooltip>
                            <Tooltip label="Applications Lyxal" id="lyxal-header-tooltip-apps">
                            <ActionIcon variant="subtle" color="gray" size="lg" radius="xl" id="lyxal-header-action-apps">
                                <Icon path={mdiDotsGrid} id="lyxal-header-icon-apps" />
                            </ActionIcon>
                        </Tooltip>
                        <Tooltip label="Compte Lyxal" id="lyxal-header-tooltip-account">
                            <ActionIcon variant="transparent" color="gray" size="xl" radius="xl" id="lyxal-header-action-account">
                                <Icon path={mdiAccountCircle} size="xl" id="lyxal-header-icon-account" />
                            </ActionIcon>
                        </Tooltip>
                    </Group>
                </Box>
            </Box>
        </div>
    );
}
