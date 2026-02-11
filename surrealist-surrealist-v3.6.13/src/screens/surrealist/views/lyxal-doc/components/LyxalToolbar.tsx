import { Paper, Group, ActionIcon, Tooltip, Divider, PaperProps, ActionIconProps, MantineSize, Stack, Text, Button, Box, ScrollArea } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { PropsWithChildren, MouseEventHandler } from "react";

interface LyxalToolbarProps extends PaperProps {
    id?: string;
    activeMenu?: string;
    onMenuChange?: (menu: string) => void;
    menuItems?: string[];
}

export function LyxalToolbar({ children, id, activeMenu, onMenuChange, menuItems, ...props }: PropsWithChildren<LyxalToolbarProps>) {
    return (
        <Paper 
            withBorder 
            style={{ borderRadius: 0, borderTop: 0, borderLeft: 0, borderRight: 0, display: 'flex', flexDirection: 'column' }} 
            id={id}
            bg="var(--mantine-color-body)"
            {...props}
        >
            {menuItems && (
                <Group 
                    gap={2} 
                    px="xs" 
                    pt={4} 
                    bg="var(--mantine-color-body)"
                    style={{ borderBottom: '1px solid var(--mantine-color-default-border)' }}
                >
                    {menuItems.map((item) => {
                        const isActive = activeMenu === item;
                        const isFile = item === "Fichier";
                        
                        return (
                            <Button
                                key={item}
                                variant={isFile ? "filled" : (isActive ? "default" : "subtle")}
                                color={isFile ? "surreal" : (isActive ? undefined : "slate")}
                                size="xs"
                                radius="xs"
                                style={isFile ? {
                                    backgroundColor: 'var(--mantine-color-surreal-6)',
                                    color: 'white',
                                    borderBottomLeftRadius: 0,
                                    borderBottomRightRadius: 0,
                                } : { 
                                    border: 'none',
                                    borderBottom: isActive ? '2px solid var(--mantine-color-surreal-6)' : '2px solid transparent',
                                    borderRadius: 0,
                                    backgroundColor: 'transparent',
                                    color: isActive ? 'var(--mantine-color-surreal-6)' : 'var(--mantine-color-text)',
                                    fontWeight: isActive ? 600 : 400,
                                    height: 32
                                }}
                                onClick={() => onMenuChange?.(item)}
                            >
                                {item}
                            </Button>
                        );
                    })}
                </Group>
            )}
            <Box p="xs" style={{ flex: 1, overflow: 'hidden' }} bg="var(--mantine-color-body)">
                <ScrollArea 
                    type="hover" 
                    scrollbars="x"
                    styles={{
                        scrollbar: { backgroundColor: 'transparent' },
                        thumb: { backgroundColor: 'var(--mantine-color-surreal-6)' },
                        corner: { backgroundColor: 'transparent' }
                    }}
                >
                    <Box style={{ minWidth: 'fit-content' }}>
                        {children}
                    </Box>
                </ScrollArea>
            </Box>
        </Paper>
    );
}

export function LyxalToolbarDivider() {
    return <Divider orientation="vertical" />;
}

export function LyxalToolbarGroup({ children }: PropsWithChildren) {
    return <Group gap={4}>{children}</Group>;
}

interface LyxalRibbonGroupProps {
    label?: string;
}

export function LyxalRibbonGroup({ label, children }: PropsWithChildren<LyxalRibbonGroupProps>) {
    return (
        <Stack gap={4} align="center" style={{ height: '100%', position: 'relative', paddingBottom: label ? 14 : 0 }}>
            <Group gap={4} style={{ flex: 1, alignItems: 'flex-start', paddingTop: 4 }}>
                {children}
            </Group>
            {label && <Text size="xs" c="dimmed" style={{ fontSize: 10, lineHeight: 1, position: 'absolute', bottom: 0, width: '100%', textAlign: 'center' }}>{label}</Text>}
        </Stack>
    );
}

interface LyxalToolbarActionProps extends ActionIconProps {
    label: string;
    icon?: string;
    iconSize?: number | MantineSize;
    active?: boolean;
    stroked?: boolean;
    iconStyle?: React.CSSProperties;
    onClick?: MouseEventHandler<HTMLButtonElement>;
}

export function LyxalToolbarAction({ label, icon, iconSize = 16, children, active, stroked, iconStyle, ...props }: PropsWithChildren<LyxalToolbarActionProps>) {
    
    // Calculer la taille du bouton pour accommoder l'icône + padding
    // Le composant Icon applique un ratio de 1.5 sur la taille brute
    const rawIconSize = typeof iconSize === 'number' ? iconSize : 16;
    const renderedIconSize = rawIconSize * 1.5;
    const buttonSize = renderedIconSize + 10; // + 10px pour le padding (5px * 2)

    return (
        <Tooltip label={label}>
            <ActionIcon 
                variant={active ? "light" : "subtle"} 
                color={active ? "surreal" : "slate"} 
                p={0}
                {...props}
                style={{ 
                    width: buttonSize, 
                    height: buttonSize, 
                    minWidth: buttonSize, 
                    minHeight: buttonSize,
                    display: 'flex',
                    alignItems: 'flex-start',
                    justifyContent: 'center',
                    paddingTop: 8, // Alignement à 8px pour toutes les icônes
                    ...props.style 
                }}
            >
                {icon ? <Icon path={icon} size={iconSize} stroked={stroked} style={iconStyle} /> : children}
            </ActionIcon>
        </Tooltip>
    );
}
