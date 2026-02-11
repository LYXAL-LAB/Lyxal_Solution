import { Box, Card, Group, Stack, Text, Title, SimpleGrid, RingProgress, Badge } from "@mantine/core";
import { type FC } from "react";
import { Icon } from "~/components/Icon";
import { iconServer, iconAccount } from "~/util/icons";

export const ClusterView: FC = () => {
    return (
        <Stack gap="xl">
            <SimpleGrid cols={{ base: 1, md: 3 }} spacing="lg">
                <Card withBorder radius="md" p="xl">
                    <Stack align="center" gap="xs">
                        <Text size="sm" c="dimmed" fw={500} tt="uppercase">Consensus State</Text>
                        <RingProgress
                            size={120}
                            thickness={12}
                            roundCaps
                            sections={[{ value: 100, color: "green" }]}
                            label={
                                <Text c="green" fw={700} ta="center" size="xl">
                                    RAFT
                                </Text>
                            }
                        />
                        <Badge color="green" variant="light">Healthy: Leader Elected</Badge>
                    </Stack>
                </Card>

                <Card withBorder radius="md" p="xl">
                    <Stack align="center" gap="xs">
                        <Text size="sm" c="dimmed" fw={500} tt="uppercase">Live Nodes</Text>
                        <Title order={1} fz={48}>3 / 3</Title>
                        <Text size="sm" c="dimmed">All nodes responding</Text>
                    </Stack>
                </Card>

                <Card withBorder radius="md" p="xl">
                    <Stack align="center" gap="xs">
                        <Text size="sm" c="dimmed" fw={500} tt="uppercase">Global Traffic</Text>
                        <Title order={1} fz={48}>1.2k</Title>
                        <Text size="sm" c="dimmed">Requests per second</Text>
                    </Stack>
                </Card>
            </SimpleGrid>

            <Title order={3}>Live Topology</Title>

            <SimpleGrid cols={{ base: 1, md: 3 }} spacing="lg">
                {[
                    { id: "node-01", role: "Leader", ip: "10.0.0.1", status: "Active" },
                    { id: "node-02", role: "Follower", ip: "10.0.0.2", status: "Active" },
                    { id: "node-03", role: "Follower", ip: "10.0.0.3", status: "Active" },
                ].map((node) => (
                    <Card key={node.id} withBorder radius="md" padding="lg">
                        <Group justify="space-between" mb="xs">
                            <Group gap="sm">
                                <Icon path={iconServer} size={1.2} color={node.role === "Leader" ? "surreal" : "dimmed"} />
                                <Text fw={600}>{node.id}</Text>
                            </Group>
                            <Badge color={node.role === "Leader" ? "blue" : "gray"}>{node.role}</Badge>
                        </Group>
                        <Stack gap={4}>
                            <Text size="sm">IP Address: {node.ip}</Text>
                            <Group gap={6}>
                                <Box w={8} h={8} style={{ borderRadius: "50%" }} bg="green" />
                                <Text size="xs" c="dimmed">Uptime: 14d 2h 32m</Text>
                            </Group>
                        </Stack>
                    </Card>
                ))}
            </SimpleGrid>
        </Stack>
    );
};
