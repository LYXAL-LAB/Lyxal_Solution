import { adapter } from "~/adapter";
import { useCloudStore } from "~/stores/cloud";
import type { CloudBillingCountry, CloudInstanceType, CloudProfile, CloudRegion } from "~/types";
import { getCloudEndpoints } from "./endpoints";

const MOCK_INSTANCE_TYPES = [
	{
		slug: "free",
		display_name: "Community",
		description: "Shared resources",
		cpu: 0.5,
		memory: 1024,
		price_hour: 0,
		category: "shared",
		default_storage_size: 10,
		max_storage_size: 20,
		compute_units: { min: 1, max: 1 }
	},
	{
		slug: "starter",
		display_name: "Starter",
		description: "Dedicated resources",
		cpu: 2,
		memory: 4096,
		price_hour: 0.15,
		category: "dedicated",
		default_storage_size: 50,
		max_storage_size: 200,
		compute_units: { min: 1, max: 4 }
	}
];

const MOCK_PLAN = {
	id: "enterprise-plan",
	name: "Enterprise",
	description: "Full LyxalOS capabilities",
	regions: ["eu-west", "us-east"],
	instance_types: MOCK_INSTANCE_TYPES,
	storage_instance_types: [],
};

const MOCK_ORGANIZATIONS = [
	{
		id: "lyxal-dev-org",
		name: "Lyxal Enterprise",
		state: "onboarded",
		billing_provider: "stripe",
		max_free_instances: 1,
		max_paid_instances: 10,
		billing_info: true,
		payment_info: true,
		member_count: 3,
		user_role: "owner",
		resources_locked: false,
		plan: MOCK_PLAN,
		available_plans: [MOCK_PLAN],
	}
];

const MOCK_MEMBERS = [
	{
		user_id: "lyxal-admin-id",
		organization_id: "lyxal-dev-org",
		role: "owner",
		name: "Lyxal Administrator",
		username: "lyxal_admin",
		profile_picture: "",
	},
	{
		user_id: "user-2",
		organization_id: "lyxal-dev-org",
		role: "admin",
		name: "John Doe",
		username: "johndoe",
		profile_picture: "",
	},
	{
		user_id: "user-3",
		organization_id: "lyxal-dev-org",
		role: "developer",
		name: "Jane Smith",
		username: "janesmith",
		profile_picture: "",
	}
];

const MOCK_INSTANCES = [
	{
		id: "instance-1",
		name: "Production Cluster",
		host: "prod-cluster.lyxal.cloud",
		region: "eu-west",
		version: "v3.0.0",
		organization_id: "lyxal-dev-org",
		available_versions: ["v3.0.0", "v3.0.0-beta.2"],
		compute_units: 2,
		storage_size: 50,
		can_update_storage_size: true,
		storage_size_update_cooloff_hours: 24,
		state: "ready",
		type: MOCK_INSTANCE_TYPES[1],
		capabilities: {
			allow_scripting: true,
			allow_guests: true,
			allow_graphql: true,
			allow_insecure_storable_closures: false,
			allowed_rpc_methods: ["*"],
			denied_rpc_methods: [],
			allowed_http_endpoints: ["*"],
			denied_http_endpoints: [],
			allowed_networks: ["*"],
			denied_networks: [],
			allowed_functions: ["*"],
			denied_functions: [],
			allowed_experimental: [],
			denied_experimental: [],
			allowed_arbitrary_query: ["*"],
			denied_arbitrary_query: [],
		}
	}
];

const MOCK_REGIONS = [
	{ slug: "eu-west", description: "Western Europe (Paris)" },
	{ slug: "us-east", description: "US East (N. Virginia)" }
];

const MOCK_PROFILE: CloudProfile = {
	username: "lyxal_admin",
	name: "Lyxal Administrator",
	default_org: "lyxal-dev-org",
	enabled_features: ["cloud_enabled", "sandbox_deploy"],
};

/**
 * Execute a fetch request against the API and returns
 * the JSON response
 */
export async function fetchAPI<T = unknown>(
	path: string,
	options?: RequestInit | undefined,
): Promise<T> {
	const { sessionToken } = useCloudStore.getState();
	const { apiBase } = getCloudEndpoints();

	// In simulation mode, we intercept and return mock data
	if (sessionToken === "dummy-session-token") {
		if (path === "/organizations") return MOCK_ORGANIZATIONS as T;
		if (path === "/regions") return MOCK_REGIONS as T;
		if (path === "/instancetypes") return MOCK_INSTANCE_TYPES as T;
		if (path === "/instanceversions") return ["v3.0.0", "v3.0.0-beta.2"] as T;
		if (path === "/billingcountries") return [] as T;
		if (path === "/user/profile") return MOCK_PROFILE as T;

		if (path.startsWith("/organizations/")) {
			const parts = path.split("/");
			const isSubPath = parts.length > 3;

			if (isSubPath) {
				const subPath = parts[3];
				if (subPath === "members") return MOCK_MEMBERS as T;
				if (subPath === "instances") return MOCK_INSTANCES as T;
				if (subPath === "roles") return [
					{ name: "owner", permissions: [] },
					{ name: "admin", permissions: [] },
					{ name: "developer", permissions: [] },
					{ name: "viewer", permissions: [] },
				] as T;

				const arrayPaths = ["invitations", "backups", "invoices", "payments", "usage", "coupons", "referrals"];
				if (arrayPaths.includes(subPath)) return [] as T;
				if (subPath === "billing") return {
					Name: "Lyxal Admin",
					Email: "admin@lyxal.com",
					AddressLine1: "123 Lyxal Way",
					City: "Paris",
					Country: "FR",
				} as T;
				return {} as T;
			}

			const id = parts[2];
			return (MOCK_ORGANIZATIONS.find(o => o.id === id) || MOCK_ORGANIZATIONS[0]) as T;
		}

		if (path.startsWith("/instances/")) {
			const parts = path.split("/");
			if (parts.length === 3) {
				const id = parts[2];
				return (MOCK_INSTANCES.find(i => i.id === id) || MOCK_INSTANCES[0]) as T;
			}

			const subPath = parts[3];
			const arrayPaths = ["usage", "backups"];
			if (arrayPaths.includes(subPath)) return [] as T;
			return {} as T;
		}
	}

	const headers: Record<string, string> = {
		"Content-Type": "application/json",
	};

	if (sessionToken) {
		headers.Authorization = `Bearer ${sessionToken}`;
	}

	try {
		const response = await adapter.fetch(`${apiBase}${path}`, {
			headers: {
				...headers,
				...options?.headers,
			},
			...options,
		});

		if (!response.ok) {
			const isJson =
				response.headers.get("Content-Type")?.startsWith("application/json") ?? false;

			let reason = response.statusText;

			if (isJson) {
				const { message } = await response.json();
				reason = message;
			}

			throw new ApiError(response, reason);
		}

		if (response.headers.get("Content-Type")?.startsWith("application/json")) {
			return await response.json();
		}
	} catch (err) {
		throw new Error(`Failed API request to ${apiBase}${path}: ${err}`);
	}

	return {} as T;
}

/**
 * Fetch essential information from the API
 */
export async function updateCloudInformation() {
	const { setCloudValues, setProfile } = useCloudStore.getState();

	// Load essential information
	const [instanceVersions, instanceTypes, regions, billingCountries] = await Promise.all([
		fetchAPI<string[]>("/instanceversions"),
		fetchAPI<CloudInstanceType[]>("/instancetypes"),
		fetchAPI<CloudRegion[]>("/regions"),
		fetchAPI<CloudBillingCountry[]>("/billingcountries"),
	]);

	setCloudValues({
		instanceVersions,
		instanceTypes,
		regions,
		billingCountries,
	});

	// Load optional information
	const [profile] = await Promise.all([fetchAPI<CloudProfile>("/user/profile")]);

	setProfile(profile);
}

/**
 * Error response from the API
 */
export class ApiError extends Error {
	public status: number;
	public reason: string;

	public constructor(response: Response, reason: string) {
		super(`Request failed for "${response.url}" (${response.status}): ${reason}`);

		this.status = response.status;
		this.reason = reason;
	}
}
