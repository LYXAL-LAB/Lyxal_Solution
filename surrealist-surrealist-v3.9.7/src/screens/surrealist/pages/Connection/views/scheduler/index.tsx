import { useSearchParams } from "~/hooks/routing";
import { SchedulerAlerts } from "./SchedulerAlerts";
import { SchedulerCalendars } from "./SchedulerCalendars";
import { SchedulerConsole } from "./SchedulerConsole";
import { SchedulerDashboard } from "./SchedulerDashboard";
import { SchedulerDeadLetters } from "./SchedulerDeadLetters";
import { SchedulerExecutions } from "./SchedulerExecutions";
import { SchedulerJobs } from "./SchedulerJobs";
import { SchedulerRunners } from "./SchedulerRunners";
import { SchedulerSettings } from "./SchedulerSettings";

export interface SchedulerViewProps {
	idPrefix?: string;
}

export function SchedulerView({ idPrefix = "scheduler-view" }: SchedulerViewProps) {
	const search = useSearchParams();
	const activeTab = search.tab || "dashboard";

	return (
		<div id={`${idPrefix}-root`} style={{ width: "100%", height: "100%", overflowY: "auto" }}>
			<div
				id={`${idPrefix}-container`}
				style={{
					maxWidth: 1600,
					margin: "0 auto",
					padding: "1rem",
					width: "100%",
				}}
			>
				{/* Full-width Active Subview Content Panel */}
				<div id={`${idPrefix}-content-panel`} style={{ width: "100%" }}>
					{activeTab === "dashboard" && <SchedulerDashboard idPrefix={`${idPrefix}-dashboard`} />}
					{activeTab === "jobs" && <SchedulerJobs idPrefix={`${idPrefix}-jobs`} />}
					{activeTab === "executions" && <SchedulerExecutions idPrefix={`${idPrefix}-executions`} />}
					{activeTab === "runners" && <SchedulerRunners idPrefix={`${idPrefix}-runners`} />}
					{activeTab === "dead-letters" && <SchedulerDeadLetters idPrefix={`${idPrefix}-dead-letters`} />}
					{activeTab === "alerts" && <SchedulerAlerts idPrefix={`${idPrefix}-alerts`} />}
					{activeTab === "calendars" && <SchedulerCalendars idPrefix={`${idPrefix}-calendars`} />}
					{activeTab === "console" && <SchedulerConsole idPrefix={`${idPrefix}-console`} />}
					{activeTab === "settings" && <SchedulerSettings idPrefix={`${idPrefix}-settings`} />}
				</div>
			</div>
		</div>
	);
}

export default SchedulerView;
