import { Stack, Text, ScrollArea } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { Entry } from "~/components/Entry";
import { mdiHome, mdiAccount, mdiChat } from "@mdi/js";
import { useIsLight } from "~/hooks/theme";
import classes from "../style.module.scss";
import { useState } from "react";
import clsx from "clsx";

const NAV_ITEMS = [
    { id: "overview", label: "Overview", icon: mdiHome },
    { id: "personal", label: "Personal", icon: mdiAccount },
    { id: "chat", label: "Chat", icon: mdiChat },
];

export interface SidebarProps {
    active: string;
    onActiveChange: (id: string) => void;
}

export function Sidebar({ active, onActiveChange }: SidebarProps) {
    const isLight = useIsLight();

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
                <Stack p="md" pt={12} gap={4}>
                    {NAV_ITEMS.map((item) => {
                        const isActive = active === item.id;
                        return (
                            <Entry 
                                key={item.id}
                                isActive={isActive}
                                onClick={() => onActiveChange(item.id)}
                                className={clsx(classes.navEntry, isActive && classes.navEntryActive)}
                                leftSection={<Icon path={item.icon} size={16} />}
                            >
                                <Text
                                    truncate
                                    inherit
                                    span
                                    lh="20px"
                                    size="sm"
                                    fw={500}
                                >
                                    {item.label}
                                </Text>
                            </Entry>
                        );
                    })}
                </Stack>
            </ScrollArea>
        </Stack>
    );
}
