#[derive(Debug, Copy, Clone, Hash, Eq, PartialEq, PartialOrd, Ord)]
#[non_exhaustive]
pub enum Method {
	Unknown,
	Ping,
	Info,
	Use,
	Signup,
	Signin,
	Authenticate,
	Refresh,
	Invalidate,
	Revoke,
	Reset,
	Kill,
	Live,
	Set,
	Unset,
	Select,
	Insert,
	Create,
	Upsert,
	Update,
	Merge,
	Patch,
	Delete,
	Version,
	Query,
	Relate,
	Run,
	InsertRelation,
	Attach,
	Sessions,
	Detach,
	Begin,
	Commit,
	Cancel,
	// RTC Methods (P2P Signaling)
	/// Create a new RTC session
	RtcCreate,
	/// Join an existing RTC session
	RtcJoin,
	/// Leave an RTC session
	RtcLeave,
	/// Send RTC signaling data (SDP/ICE)
	RtcSignal,
	/// Poll for pending RTC signals
	RtcPoll,
	/// List active RTC sessions
	RtcList,
	/// Get RTC session info
	RtcInfo,
	/// Close an RTC session
	RtcClose,
	// SFU Methods (Multi-party conferencing)
	/// Create a new SFU session
	SfuCreate,
	/// Join SFU session with SDP offer
	SfuOffer,
	/// Accept SFU SDP answer
	SfuAnswer,
	/// Leave SFU session
	SfuLeave,
	/// Get SFU session info
	SfuInfo,
	/// List SFU sessions
	SfuList,
	/// Get SFU statistics
	SfuStats,
	/// Close SFU session
	SfuClose,
	// Webinar/Role Management Methods
	/// Create a webinar session
	SfuWebinar,
	/// Join with specific role
	SfuJoinRole,
	/// Promote participant to speaker
	SfuPromote,
	/// Demote participant to viewer
	SfuDemote,
	/// Raise hand
	SfuRaiseHand,
	/// Lower hand
	SfuLowerHand,
	/// Get participants with raised hands
	SfuRaisedHands,
	/// Get all participants
	SfuParticipants,
	/// Get speakers only
	SfuSpeakers,
}

impl Method {
	/// Parse a [Method] from a [str] with any case
	pub fn parse_case_insensitive<S>(s: S) -> Self
	where
		S: AsRef<str>,
	{
		Self::parse(s.as_ref().to_ascii_lowercase().as_str())
	}

	/// Parse a [Method] from a [str] in lower case
	pub fn parse_case_sensitive<S>(s: S) -> Self
	where
		S: AsRef<str>,
	{
		Self::parse(s.as_ref())
	}

	/// Parse a [Method] from a [str]
	fn parse<S>(s: S) -> Self
	where
		S: AsRef<str>,
	{
		match s.as_ref() {
			"ping" => Self::Ping,
			"info" => Self::Info,
			"use" => Self::Use,
			"signup" => Self::Signup,
			"signin" => Self::Signin,
			"authenticate" => Self::Authenticate,
			"refresh" => Self::Refresh,
			"invalidate" => Self::Invalidate,
			"revoke" => Self::Revoke,
			"reset" => Self::Reset,
			"kill" => Self::Kill,
			"live" => Self::Live,
			"set" | "let" => Self::Set,
			"unset" => Self::Unset,
			"select" => Self::Select,
			"insert" => Self::Insert,
			"create" => Self::Create,
			"upsert" => Self::Upsert,
			"update" => Self::Update,
			"merge" => Self::Merge,
			"patch" => Self::Patch,
			"delete" => Self::Delete,
			"version" => Self::Version,
			"query" => Self::Query,
			"relate" => Self::Relate,
			"run" => Self::Run,
			"insert_relation" => Self::InsertRelation,
			"attach" => Self::Attach,
			"sessions" => Self::Sessions,
			"detach" => Self::Detach,
			"begin" => Self::Begin,
			"commit" => Self::Commit,
			"cancel" => Self::Cancel,
			// RTC Methods
			"rtc_create" => Self::RtcCreate,
			"rtc_join" => Self::RtcJoin,
			"rtc_leave" => Self::RtcLeave,
			"rtc_signal" => Self::RtcSignal,
			"rtc_poll" => Self::RtcPoll,
			"rtc_list" => Self::RtcList,
			"rtc_info" => Self::RtcInfo,
			"rtc_close" => Self::RtcClose,
			// SFU Methods
			"sfu_create" => Self::SfuCreate,
			"sfu_offer" => Self::SfuOffer,
			"sfu_answer" => Self::SfuAnswer,
			"sfu_leave" => Self::SfuLeave,
			"sfu_info" => Self::SfuInfo,
			"sfu_list" => Self::SfuList,
			"sfu_stats" => Self::SfuStats,
			"sfu_close" => Self::SfuClose,
			_ => Self::Unknown,
		}
	}
}

impl Method {
	pub fn to_str(&self) -> &str {
		match self {
			Self::Unknown => "unknown",
			Self::Ping => "ping",
			Self::Info => "info",
			Self::Use => "use",
			Self::Signup => "signup",
			Self::Signin => "signin",
			Self::Authenticate => "authenticate",
			Self::Refresh => "refresh",
			Self::Invalidate => "invalidate",
			Self::Revoke => "revoke",
			Self::Reset => "reset",
			Self::Kill => "kill",
			Self::Live => "live",
			Self::Set => "set",
			Self::Unset => "unset",
			Self::Select => "select",
			Self::Insert => "insert",
			Self::Create => "create",
			Self::Upsert => "upsert",
			Self::Update => "update",
			Self::Merge => "merge",
			Self::Patch => "patch",
			Self::Delete => "delete",
			Self::Version => "version",
			Self::Query => "query",
			Self::Relate => "relate",
			Self::Run => "run",
			Self::InsertRelation => "insert_relation",
			Self::Attach => "attach",
			Self::Sessions => "sessions",
			Self::Detach => "detach",
			Self::Begin => "begin",
			Self::Commit => "commit",
			Self::Cancel => "cancel",
			// RTC Methods
			Self::RtcCreate => "rtc_create",
			Self::RtcJoin => "rtc_join",
			Self::RtcLeave => "rtc_leave",
			Self::RtcSignal => "rtc_signal",
			Self::RtcPoll => "rtc_poll",
			Self::RtcList => "rtc_list",
			Self::RtcInfo => "rtc_info",
			Self::RtcClose => "rtc_close",
			// SFU Methods
			Self::SfuCreate => "sfu_create",
			Self::SfuOffer => "sfu_offer",
			Self::SfuAnswer => "sfu_answer",
			Self::SfuLeave => "sfu_leave",
			Self::SfuInfo => "sfu_info",
			Self::SfuList => "sfu_list",
			Self::SfuStats => "sfu_stats",
			Self::SfuClose => "sfu_close",
			// Webinar/Role Methods
			Self::SfuWebinar => "sfu_webinar",
			Self::SfuJoinRole => "sfu_join_role",
			Self::SfuPromote => "sfu_promote",
			Self::SfuDemote => "sfu_demote",
			Self::SfuRaiseHand => "sfu_raise_hand",
			Self::SfuLowerHand => "sfu_lower_hand",
			Self::SfuRaisedHands => "sfu_raised_hands",
			Self::SfuParticipants => "sfu_participants",
			Self::SfuSpeakers => "sfu_speakers",
		}
	}
}

impl std::fmt::Display for Method {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		write!(f, "{}", self.to_str())
	}
}

impl Method {
	/// Checks if the provided method is a valid and supported RPC method
	pub fn is_valid(&self) -> bool {
		!matches!(self, Self::Unknown)
	}
}
