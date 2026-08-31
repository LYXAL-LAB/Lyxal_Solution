import {
	iconAuth as iconUser,
	iconBroadcastOn,
	iconBug,
	iconClock,
	iconCog,
	iconConsole,
	iconDataTable,
	iconKey,
	iconPlay,
	iconServer,
	iconTable,
} from "@surrealdb/ui";
import { useMemo } from "react";
import { hasOrganizationRoles, ORG_ROLES_ADMIN } from "~/cloud/helpers";
import { useCloudInstanceQuery } from "~/cloud/queries/instances";
import { useCloudOrganizationQuery } from "~/cloud/queries/organizations";
import { CONNECTION_SETTINGS_TAB_LABELS } from "~/constants";
import { useAvailableViews, useConnection } from "~/hooks/connection";
import {
	useConnectionAndView,
	useConnectionFromRoute,
	useConnectionNavigator,
	useSearchParams,
} from "~/hooks/routing";
import { useConfigStore } from "~/stores/config";
import type { ConnectionSettingsTab, ViewPage } from "~/types";
import { connectionSettingsPath } from "~/util/connection-settings";
import { optional } from "~/util/helpers";
import {
	type SidebarEntry,
	SidebarNavigation,
	SidebarPortal,
	type SidebarSubLink,
	useSidebar,
} from "../../sidebar/portal";
import { canChangeInstanceVersion } from "./settings/helpers";

const VIEW_NAVIGATION: ViewPage[][] = [
	["dashboard", "scheduler", "booking", "monitor", "migrations", "documentation"],
	["query", "explorer", "graphql"],
	["designer", "authentication", "parameters", "functions"],
];

const ALWAYS_SETTINGS_TABS: ConnectionSettingsTab[] = ["general", "databases", "data"];

const ADMIN_CLOUD_SETTINGS_TABS: ConnectionSettingsTab[] = ["compute"];

export function ConnectionSidebar() {
	const { setLocation } = useSidebar();
	const connection = useConnectionFromRoute();
	const [, activeView] = useConnectionAndView();
	const search = useSearchParams();
	const activeTab = search.tab || "dashboard";
	const navigateConnection = useConnectionNavigator();
	const sidebarViews = useConfigStore((s) => s.settings.appearance.sidebarViews);
	const views = useAvailableViews();

	const isCloud = useConnection((s) => s?.authentication.mode === "cloud");
	const instanceId = useConnection((s) => s?.authentication.cloudInstance);
	const instanceQuery = useCloudInstanceQuery(instanceId);
	const organisationQuery = useCloudOrganizationQuery(instanceQuery.data?.organization_id);

	const organisation = organisationQuery.data;
	const isAdmin = organisation ? hasOrganizationRoles(organisation, ORG_ROLES_ADMIN) : false;

	const navigation: SidebarEntry[][] = useMemo(() => {
		if (!connection) {
			return [];
		}

		// When inside Scheduler view, replace the main sidebar with Scheduler sub-navigation
		if (activeView === "scheduler") {
			return [
				[
					{
						name: "Dashboard",
						icon: iconDataTable,
						match: [`/c/${connection}/scheduler?tab=dashboard`],
						isActive: activeTab === "dashboard",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=dashboard`),
					},
					{
						name: "Jobs",
						icon: iconTable,
						match: [`/c/${connection}/scheduler?tab=jobs`],
						isActive: activeTab === "jobs",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=jobs`),
					},
					{
						name: "Executions",
						icon: iconPlay,
						match: [`/c/${connection}/scheduler?tab=executions`],
						isActive: activeTab === "executions",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=executions`),
					},
					{
						name: "Runners",
						icon: iconServer,
						match: [`/c/${connection}/scheduler?tab=runners`],
						isActive: activeTab === "runners",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=runners`),
					},
					{
						name: "Dead Letters",
						icon: iconBug,
						match: [`/c/${connection}/scheduler?tab=dead-letters`],
						isActive: activeTab === "dead-letters",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=dead-letters`),
					},
					{
						name: "Alerts",
						icon: iconBroadcastOn,
						match: [`/c/${connection}/scheduler?tab=alerts`],
						isActive: activeTab === "alerts",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=alerts`),
					},
					{
						name: "Console",
						icon: iconConsole,
						match: [`/c/${connection}/scheduler?tab=console`],
						isActive: activeTab === "console",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=console`),
					},
				],
				[
					{
						name: "Calendars",
						icon: iconClock,
						match: [`/c/${connection}/scheduler?tab=calendars`],
						isActive: activeTab === "calendars",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=calendars`),
					},
					{
						name: "Settings",
						icon: iconCog,
						match: [`/c/${connection}/scheduler?tab=settings`],
						isActive: activeTab === "settings",
						onClick: () => setLocation(`/c/${connection}/scheduler?tab=settings`),
					},
				],
			];
		}

		// When inside Booking view, replace main sidebar with Booking sub-navigation
		if (activeView === "booking") {
			return [
				[
					{
						name: "Dashboard",
						icon: iconDataTable,
						match: [`/c/${connection}/booking?tab=dashboard`],
						isActive: activeTab === "dashboard",
						onClick: () => setLocation(`/c/${connection}/booking?tab=dashboard`),
					},
					{
						name: "Bookings",
						icon: iconClock,
						match: [`/c/${connection}/booking?tab=bookings`],
						isActive: activeTab === "bookings",
						onClick: () => setLocation(`/c/${connection}/booking?tab=bookings`),
					},
					{
						name: "Event Types",
						icon: iconTable,
						match: [`/c/${connection}/booking?tab=event-types`],
						isActive: activeTab === "event-types",
						onClick: () => setLocation(`/c/${connection}/booking?tab=event-types`),
					},
					{
						name: "Availability",
						icon: iconClock,
						match: [`/c/${connection}/booking?tab=availability`],
						isActive: activeTab === "availability",
						onClick: () => setLocation(`/c/${connection}/booking?tab=availability`),
					},
					{
						name: "Teams",
						icon: iconUser,
						match: [`/c/${connection}/booking?tab=teams`],
						isActive: activeTab === "teams",
						onClick: () => setLocation(`/c/${connection}/booking?tab=teams`),
					},
					{
						name: "Resources",
						icon: iconServer,
						match: [`/c/${connection}/booking?tab=resources`],
						isActive: activeTab === "resources",
						onClick: () => setLocation(`/c/${connection}/booking?tab=resources`),
					},
					{
						name: "Invites",
						icon: iconKey,
						match: [`/c/${connection}/booking?tab=invites`],
						isActive: activeTab === "invites",
						onClick: () => setLocation(`/c/${connection}/booking?tab=invites`),
					},
				],
				[
					{
						name: "Settings",
						icon: iconCog,
						match: [`/c/${connection}/booking?tab=settings`],
						isActive: activeTab === "settings",
						onClick: () => setLocation(`/c/${connection}/booking?tab=settings`),
					},
				],
			];
		}

		// Default Main Surrealist Sidebar View Groups
		const viewGroups = VIEW_NAVIGATION.flatMap((row) => {
			const items = row.flatMap((id) => {
				const info = views[id];

				if (!info || sidebarViews[id] === false) {
					return [];
				}

				return {
					name: info.name,
					icon: info.icon,
					match: [`/c/*/${info.id}`],
					disabled: !connection,
					onClick: () => {
						navigateConnection(connection, info.id);
					},
				};
			});

			return items.length > 0 ? [items] : [];
		});

		const canChangeVersion =
			instanceQuery.data &&
			organisation &&
			canChangeInstanceVersion(instanceQuery.data, organisation);

		const settingsTabs = [
			...ALWAYS_SETTINGS_TABS,
			...optional(isCloud && isAdmin && "capabilities"),
			...optional(isCloud && canChangeVersion && "version"),
			...optional(isCloud && isAdmin && ADMIN_CLOUD_SETTINGS_TABS),
			...optional(isCloud && "backups"),
		];

		const subLink = (tab: ConnectionSettingsTab): SidebarSubLink => ({
			name: CONNECTION_SETTINGS_TAB_LABELS[tab],
			match: [`/c/${connection}/settings/${tab}`],
			onClick: () => setLocation(connectionSettingsPath(connection, tab)),
		});

		const settingsGroup: SidebarEntry[] = [
			{
				name: "Settings",
				icon: iconCog,
				items: settingsTabs.map(subLink),
			},
		];

		return [...viewGroups, settingsGroup];
	}, [
		views,
		sidebarViews,
		connection,
		activeView,
		activeTab,
		isCloud,
		isAdmin,
		instanceQuery.data,
		organisation,
		setLocation,
		navigateConnection,
	]);

	const backButton = instanceId
		? {
				name: "Organization" as const,
				onClick: () => setLocation(`/o/${instanceQuery.data?.organization_id}`),
			}
		: {
				name: "Overview" as const,
				onClick: () => {
					if (activeView === "scheduler" && connection) {
						setLocation(`/c/${connection}/query`);
					} else {
						setLocation("/");
					}
				},
			};

	return (
		<SidebarPortal>
			<SidebarNavigation
				items={navigation}
				backButton={backButton}
			/>
		</SidebarPortal>
	);
}
