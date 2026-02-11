import { Card, Group, Stack, Table, Text, Title, Badge, ThemeIcon, ScrollArea } from "@mantine/core";
import { type FC } from "react";
import { Icon } from "~/components/Icon";
import { iconCreditCard, iconArrowUpRight, iconArrowDownFat } from "~/util/icons";

export const LedgerView: FC = () => {
    const transactions = [
        { id: "TXN-890", realm: "Production-Alpha", type: "Usage", amount: "+$12.40", time: "2 minutes ago" },
        { id: "TXN-889", realm: "Staging-Test", type: "Usage", amount: "+$0.05", time: "15 minutes ago" },
        { id: "TXN-888", realm: "Production-Alpha", type: "Settlement", amount: "-$150.00", time: "1 hour ago" },
        { id: "TXN-887", realm: "Legacy-App", type: "Usage", amount: "+$0.00", time: "2 hours ago" },
    ];

    return (
        <Stack gap="lg">
            <Group justify="space-between">
                <Stack gap={0}>
                    <Text size="sm" c="dimmed">Total Unsettled Revenue</Text>
                    <Title order={2} c="green">$12,450.32</Title>
                </Stack>
                <Card withBorder p="sm" radius="md">
                    <Group gap="xs">
                        <ThemeIcon color="blue" variant="light">
                            <Icon path={iconCreditCard} size={0.8} />
                        </ThemeIcon>
                        <Text fw={500}>Last Settlement: 2024-05-15</Text>
                    </Group>
                </Card>
            </Group>

            <Title order={3}>Live Transaction Ledger</Title>

            <Card withBorder radius="md" p={0}>
                <ScrollArea h={400}>
                    <Table verticalSpacing="md">
                        <Table.Thead>
                            <Table.Tr>
                                <Table.Th>TX ID</Table.Th>
                                <Table.Th>Realm Source</Table.Th>
                                <Table.Th>Event Type</Table.Th>
                                <Table.Th>Amount</Table.Th>
                                <Table.Th ta="right">Timestamp</Table.Th>
                            </Table.Tr>
                        </Table.Thead>
                        <Table.Tbody>
                            {transactions.map((txn) => (
                                <Table.Tr key={txn.id}>
                                    <Table.Td>
                                        <Text fw={500} ff="monospace">{txn.id}</Text>
                                    </Table.Td>
                                    <Table.Td>{txn.realm}</Table.Td>
                                    <Table.Td>
                                        <Badge variant="light" color={txn.type === "Usage" ? "blue" : "orange"}>
                                            {txn.type}
                                        </Badge>
                                    </Table.Td>
                                    <Table.Td>
                                        <Text color={txn.amount.startsWith("+") ? "green" : "red"} fw={600}>
                                            {txn.amount}
                                        </Text>
                                    </Table.Td>
                                    <Table.Td ta="right">
                                        <Text size="sm" c="dimmed">{txn.time}</Text>
                                    </Table.Td>
                                </Table.Tr>
                            ))}
                        </Table.Tbody>
                    </Table>
                </ScrollArea>
            </Card>
        </Stack>
    );
};
