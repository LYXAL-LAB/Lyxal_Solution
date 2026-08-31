import { useSearchParams } from "~/hooks/routing";
import { BookingAvailability } from "./BookingAvailability";
import { BookingDashboard } from "./BookingDashboard";
import { BookingEventTypes } from "./BookingEventTypes";
import { BookingInvites } from "./BookingInvites";
import { BookingList } from "./BookingList";
import { BookingResources } from "./BookingResources";
import { BookingSettings } from "./BookingSettings";
import { BookingTeams } from "./BookingTeams";

export interface BookingViewProps {
	idPrefix?: string;
}

export function BookingView({ idPrefix = "booking-view" }: BookingViewProps) {
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
				<div id={`${idPrefix}-content-panel`} style={{ width: "100%" }}>
					{activeTab === "dashboard" && <BookingDashboard idPrefix={`${idPrefix}-dashboard`} />}
					{activeTab === "bookings" && <BookingList idPrefix={`${idPrefix}-bookings`} />}
					{activeTab === "event-types" && <BookingEventTypes idPrefix={`${idPrefix}-event-types`} />}
					{activeTab === "availability" && <BookingAvailability idPrefix={`${idPrefix}-availability`} />}
					{activeTab === "teams" && <BookingTeams idPrefix={`${idPrefix}-teams`} />}
					{activeTab === "resources" && <BookingResources idPrefix={`${idPrefix}-resources`} />}
					{activeTab === "invites" && <BookingInvites idPrefix={`${idPrefix}-invites`} />}
					{activeTab === "settings" && <BookingSettings idPrefix={`${idPrefix}-settings`} />}
				</div>
			</div>
		</div>
	);
}

export default BookingView;
