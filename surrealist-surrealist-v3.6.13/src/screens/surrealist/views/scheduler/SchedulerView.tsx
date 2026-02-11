import { Box, Button, Group, Stack, Text, Title, Badge, SimpleGrid, Card, ThemeIcon } from "@mantine/core";
import { useEffect, useState } from "react";
import { useInterval } from "@mantine/hooks";
import { ContentPane } from "~/components/Pane";
import { iconClock, iconRefresh, iconPlay, iconPause, iconDelete } from "~/util/icons";
import { Icon } from "~/components/Icon";
import { Spacer } from "~/components/Spacer";
import { executeQuery, executeQuerySingle } from "~/screens/surrealist/connection/connection";
import { DataTable } from "~/components/DataTable";
import classes from "./style.module.scss";

type JobStatus = 'pending' | 'running' | 'failed' | 'dlq' | 'disabled';

interface Job {
	id: string;
	name?: string;
	action: string;
	cron: string;
	status: JobStatus;
	next_run: string;
	priority: number;
	attempts: number;
	max_retries: number;
}

interface SchedulerStats {
	total_jobs: number;
	by_status: Record<string, number>;
	next_scheduled_run: string | null;
}

export function SchedulerView() {
	const [jobs, setJobs] = useState<Job[]>([]);
	const [stats, setStats] = useState<SchedulerStats | null>(null);
	const [loading, setLoading] = useState(false);

	const fetchData = async () => {
		setLoading(true);
		try {
			// Fetch stats
			const statsRes = await executeQuerySingle<SchedulerStats>("RETURN schedule::stats()");
			setStats(statsRes);

			// Fetch jobs
			// TODO: Implement pagination
			const jobsRes = await executeQuerySingle<Job[]>("RETURN schedule::list()");
			setJobs(jobsRes || []);
		} catch (err) {
			console.error("Failed to fetch scheduler data", err);
		} finally {
			setLoading(false);
		}
	};

	useEffect(() => {
		fetchData();
	}, []);

	useInterval(fetchData, 5000);

	return (
		<Box className={classes.container}>
			<ContentPane
				title="Scheduler"
				icon={iconClock}
				rightSection={
					<Group>
						<Button
							variant="light"
							color="slate"
							leftSection={<Icon path={iconRefresh} />}
							onClick={fetchData}
							loading={loading}
						>
							Refresh
						</Button>
					</Group>
				}
			>
				<Box className={classes.content}>
					<Stack gap="lg">
						{/* Stats Grid */}
						<SimpleGrid cols={{ base: 1, sm: 2, md: 4 }}>
							<StatCard
								label="Total Jobs"
								value={stats?.total_jobs ?? 0}
								icon={iconClock}
								color="blue"
							/>
							<StatCard
								label="Running"
								value={stats?.by_status?.running ?? 0}
								icon={iconPlay}
								color="green"
							/>
							<StatCard
								label="Failed"
								value={stats?.by_status?.failed ?? 0}
								icon={iconDelete} // using delete icon as trash/warning
								color="red"
							/>
							<StatCard
								label="Pending"
								value={stats?.by_status?.pending ?? 0}
								icon={iconPause}
								color="gray"
							/>
						</SimpleGrid>

						{/* Jobs Table */}
						<Card p="md" radius="md" withBorder>
							<Title order={3} mb="md">Jobs</Title>
							<DataTable
								data={jobs}
								headers={["id", "action", "status", "next_run", "priority"]}
								sorting={null}
							/>
						</Card>
					</Stack>
				</Box>
			</ContentPane>
		</Box>
	);
}

function StatCard({ label, value, icon, color }: { label: string, value: number | string, icon: string, color: string }) {
	return (
		<Card p="md" radius="md" withBorder className={classes.statCard}>
			<Group>
				<ThemeIcon size="xl" radius="md" variant="light" color={color}>
					<Icon path={icon} size="lg" />
				</ThemeIcon>
				<Stack gap={0}>
					<Text c="dimmed" size="xs" fw={700} tt="uppercase">
						{label}
					</Text>
					<Text fw={700} size="xl">
						{value}
					</Text>
				</Stack>
			</Group>
		</Card>
	);
}

export default SchedulerView;

