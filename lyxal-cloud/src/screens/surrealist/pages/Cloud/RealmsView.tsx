import { Button, Card, Group, Stack, Table, Text, Title, Badge, ActionIcon, TextInput, Box } from "@mantine/core";
import { type FC } from "react";
import { Icon } from "~/components/Icon";
import { iconSearch, iconPlus, iconDotsVertical, iconStop, iconDelete } from "~/util/icons";

export const RealmsView: FC = () => {
    const realms = [
        { id: "realm_8293", name: "Production-Alpha", plan: "Enterprise", status: "Active", usage: "45.2 GB" },
        { id: "realm_4120", name: "Staging-Test", plan: "Standard", status: "Active", usage: "1.2 GB" },
        { id: "realm_9012", name: "Legacy-App", plan: "Free", status: "Suspended", usage: "512 MB" },
    ];

    return (
        <Stack gap="lg">
            <Group justify="space-between">
                <TextInput
                    placeholder="Search realms..."
                    leftSection={<Icon path={iconSearch} size={0.8} />}
                    w={300}
                />
                <Button leftSection={<Icon path={iconPlus} size={0.8} />} variant="filled" color="surreal">
                    Create New Realm
                </Button>
            </Group>

            <Card withBorder radius="md" p={0}>
                <Table verticalSpacing="md" highlightOnHover>
                    <Table.Thead>
                        <Table.Tr>
                            <Table.Th>Realm ID</Table.Th>
                            <Table.Th>Name</Table.Th>
                            <Table.Th>Plan</Table.Th>
                            <Table.Th>Storage</Table.Th>
                            <Table.Th>Status</Table.Th>
                            <Table.Th ta="right">Actions</Table.Th>
                        </Table.Tr>
                    </Table.Thead>
                    <Table.Tbody>
                        {realms.map((realm) => (
                            <Table.Tr key={realm.id}>
                                <Table.Td>
                                    <Text fw={500} ff="monospace">{realm.id}</Text>
                                </Table.Td>
                                <Table.Td>{realm.name}</Table.Td>
                                <Table.Td>
                                    <Badge variant="outline" color={realm.plan === "Enterprise" ? "violet" : "blue"}>
                                        {realm.plan}
                                    </Badge>
                                </Table.Td>
                                <Table.Td>{realm.usage}</Table.Td>
                                <Table.Td>
                                    <Group gap={6}>
                                        <Box w={8} h={8} style={{ borderRadius: "50%" }} bg={realm.status === "Active" ? "green" : "red"} />
                                        <Text size="sm">{realm.status}</Text>
                                    </Group>
                                </Table.Td>
                                <Table.Td>
                                    <Group justify="flex-end" gap="xs">
                                        <ActionIcon variant="subtle" color="orange" title="Suspend">
                                            <Icon path={iconStop} size={0.8} />
                                        </ActionIcon>
                                        <ActionIcon variant="subtle" color="red" title="Delete">
                                            <Icon path={iconDelete} size={0.8} />
                                        </ActionIcon>
                                        <ActionIcon variant="subtle">
                                            <Icon path={iconDotsVertical} size={0.8} />
                                        </ActionIcon>
                                    </Group>
                                </Table.Td>
                            </Table.Tr>
                        ))}
                    </Table.Tbody>
                </Table>
            </Card>
        </Stack>
    );
};
