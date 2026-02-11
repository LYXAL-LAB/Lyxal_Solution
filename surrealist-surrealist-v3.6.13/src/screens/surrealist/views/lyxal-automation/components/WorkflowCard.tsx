import { Card, Text, Group, Badge, ActionIcon, Stack, ThemeIcon, Box } from "@mantine/core";
import { Icon } from "~/components/Icon";
import { mdiDotsVertical, mdiToggleSwitch, mdiToggleSwitchOff, mdiCheckboxBlankCircle, mdiAccount, mdiTagOutline } from "@mdi/js";
import classes from "./WorkflowCard.module.scss";

interface WorkflowCardProps {
    name: string;
    active: boolean;
    updatedAt: string;
    tags?: string[];
    isOwner?: boolean;
}

export function WorkflowCard({ name, active, updatedAt, tags, isOwner = true }: WorkflowCardProps) {
    return (
        <Card shadow="sm" padding={0} radius="md" withBorder className={classes.cardLink}>
            <div className={classes.cardHeader}>
                <Group justify="space-between" align="flex-start" wrap="nowrap">
                    <Text className={classes.cardHeading} lineClamp={2}>
                        {name}
                    </Text>
                </Group>
            </div>

            <div className={classes.cardDescription}>
                <Text size="xs" c="dimmed">
                    Updated {updatedAt}
                </Text>
                {tags && tags.length > 0 && (
                    <Group gap={4}>
                        <Icon path={mdiTagOutline} size={0.6} color="var(--surrealist-text-dimmed)" />
                        <Text size="xs" c="dimmed">{tags.length} tags</Text>
                    </Group>
                )}
            </div>

            <div className={classes.cardActions}>
                {/* Ownership Badge / Breadcrumbs Placeholder */}
                {isOwner ? (
                    <Badge 
                        variant="light" 
                        color="gray" 
                        radius="sm" 
                        size="sm" 
                        className={classes.cardBadge}
                        leftSection={<Icon path={mdiAccount} size={0.6} />}
                    >
                        Personal
                    </Badge>
                ) : <div />}

                <Group gap={4}>
                    {active ? (
                        <div className={classes.publishIndicator}>
                            <span className={classes.publishIndicatorDot} />
                            <Text size="xs" fw={500}>Active</Text>
                        </div>
                    ) : (
                        <Text size="xs" c="dimmed" fw={500} mr="xs">Inactive</Text>
                    )}
                    
                    <ActionIcon variant="subtle" color="gray" size="sm">
                        <Icon path={mdiToggleSwitch} size={1} color={active ? "var(--mantine-color-green-6)" : "gray"} />
                    </ActionIcon>
                    
                    <ActionIcon variant="subtle" color="gray" size="sm">
                        <Icon path={mdiDotsVertical} size={0.8} />
                    </ActionIcon>
                </Group>
            </div>
        </Card>
    );
}
