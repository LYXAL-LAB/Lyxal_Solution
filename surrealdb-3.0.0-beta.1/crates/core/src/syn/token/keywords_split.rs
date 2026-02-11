#[repr(u8)]
#[derive(Clone, Copy, Eq, PartialEq, Hash, Debug)]
pub enum SqlKeyword {
    Action,
    After,
    All,
    AllInside,
    And,
    AndKw,
    Any,
    AnyInside,
    As,
    Ascending,
    At,
    Before,
    Begin,
    Break,
    By,
    Cancel,
    Collate,
    Commit,
    Contains,
    ContainsAll,
    ContainsAny,
    ContainsNone,
    ContainsNot,
    Content,
    Continue,
    Count,
    Create,
    Delete,
    Descending,
    Diff,
    Disabled,
    Else,
    End,
    Explain,
    False,
    Fetch,
    For,
    From,
    Get,
    Group,
    If,
    In,
    Inside,
    Insert,
    Intersects,
    Into,
    Is,
    Key,
    Let,
    Like,
    Limit,
    Merge,
    None,
    NoneInside,
    Not,
    NotInside,
    Null,
    On,
    Only,
    OrKw,
    Order,
    Out,
    Outside,
    Parallel,
    Patch,
    Post,
    Put,
    Random,
    Relate,
    Return,
    Search,
    Select,
    Set,
    Split,
    Start,
    Then,
    Throw,
    Timeout,
    Trace,
    Transaction,
    True,
    Unset,
    Update,
    Upsert,
    Use,
    Value,
    Values,
    Version,
    Where,
    With,
}

impl SqlKeyword {
    pub fn as_str(&self) -> &'static str {
        match self {
            SqlKeyword::Action => "ACTION",
            SqlKeyword::After => "AFTER",
            SqlKeyword::All => "ALL",
            SqlKeyword::AllInside => "ALLINSIDE",
            SqlKeyword::And => "AND",
            SqlKeyword::AndKw => "ANDKW",
            SqlKeyword::Any => "ANY",
            SqlKeyword::AnyInside => "ANYINSIDE",
            SqlKeyword::As => "AS",
            SqlKeyword::Ascending => "ASCENDING",
            SqlKeyword::At => "AT",
            SqlKeyword::Before => "BEFORE",
            SqlKeyword::Begin => "BEGIN",
            SqlKeyword::Break => "BREAK",
            SqlKeyword::By => "BY",
            SqlKeyword::Cancel => "CANCEL",
            SqlKeyword::Collate => "COLLATE",
            SqlKeyword::Commit => "COMMIT",
            SqlKeyword::Contains => "CONTAINS",
            SqlKeyword::ContainsAll => "CONTAINSALL",
            SqlKeyword::ContainsAny => "CONTAINSANY",
            SqlKeyword::ContainsNone => "CONTAINSNONE",
            SqlKeyword::ContainsNot => "CONTAINSNOT",
            SqlKeyword::Content => "CONTENT",
            SqlKeyword::Continue => "CONTINUE",
            SqlKeyword::Count => "COUNT",
            SqlKeyword::Create => "CREATE",
            SqlKeyword::Delete => "DELETE",
            SqlKeyword::Descending => "DESCENDING",
            SqlKeyword::Diff => "DIFF",
            SqlKeyword::Disabled => "DISABLED",
            SqlKeyword::Else => "ELSE",
            SqlKeyword::End => "END",
            SqlKeyword::Explain => "EXPLAIN",
            SqlKeyword::False => "false",
            SqlKeyword::Fetch => "FETCH",
            SqlKeyword::For => "FOR",
            SqlKeyword::From => "FROM",
            SqlKeyword::Get => "GET",
            SqlKeyword::Group => "GROUP",
            SqlKeyword::If => "IF",
            SqlKeyword::In => "IN",
            SqlKeyword::Inside => "INSIDE",
            SqlKeyword::Insert => "INSERT",
            SqlKeyword::Intersects => "INTERSECTS",
            SqlKeyword::Into => "INTO",
            SqlKeyword::Is => "IS",
            SqlKeyword::Key => "KEY",
            SqlKeyword::Let => "LET",
            SqlKeyword::Like => "LIKE",
            SqlKeyword::Limit => "LIMIT",
            SqlKeyword::Merge => "MERGE",
            SqlKeyword::None => "NONE",
            SqlKeyword::NoneInside => "NONEINSIDE",
            SqlKeyword::Not => "NOT",
            SqlKeyword::NotInside => "NOTINSIDE",
            SqlKeyword::Null => "NULL",
            SqlKeyword::On => "ON",
            SqlKeyword::Only => "ONLY",
            SqlKeyword::OrKw => "OR",
            SqlKeyword::Order => "ORDER",
            SqlKeyword::Out => "OUT",
            SqlKeyword::Outside => "OUTSIDE",
            SqlKeyword::Parallel => "PARALLEL",
            SqlKeyword::Patch => "PATCH",
            SqlKeyword::Post => "POST",
            SqlKeyword::Put => "PUT",
            SqlKeyword::Random => "RAND",
            SqlKeyword::Relate => "RELATE",
            SqlKeyword::Return => "RETURN",
            SqlKeyword::Search => "SEARCH",
            SqlKeyword::Select => "SELECT",
            SqlKeyword::Set => "SET",
            SqlKeyword::Split => "SPLIT",
            SqlKeyword::Start => "START",
            SqlKeyword::Then => "THEN",
            SqlKeyword::Throw => "THROW",
            SqlKeyword::Timeout => "TIMEOUT",
            SqlKeyword::Trace => "TRACE",
            SqlKeyword::Transaction => "TRANSACTION",
            SqlKeyword::True => "true",
            SqlKeyword::Unset => "UNSET",
            SqlKeyword::Update => "UPDATE",
            SqlKeyword::Upsert => "UPSERT",
            SqlKeyword::Use => "USE",
            SqlKeyword::Value => "VALUE",
            SqlKeyword::Values => "VALUES",
            SqlKeyword::Version => "VERSION",
            SqlKeyword::Where => "WHERE",
            SqlKeyword::With => "WITH",
        }
    }
}

#[repr(u8)]
#[derive(Clone, Copy, Eq, PartialEq, Hash, Debug)]
pub enum SystemKeyword {
    Access,
    Algorithm,
    Alter,
    Always,
    Analyzer,
    Api,
    Array,
    Ascii,
    Assert,
    Auth,
    Authenticate,
    Auto,
    Backend,
    Basic,
    Backup,
    Batch,
    Bearer,
    Binary,
    Blank,
    Bm25,
    Bool,
    Bucket,
    Bytes,
    Camel,
    Capacity,
    Cascade,
    ChangeFeed,
    Changes,
    Class,
    Collection,
    Comment,
    Compact,
    Computed,
    Concurrently,
    Config,
    Database,
    Datetime,
    Decimal,
    Default,
    Define,
    Dimension,
    Distance,
    Drop,
    Duplicate,
    Duration,
    Edgengram,
    Efc,
    Enforced,
    Event,
    Exclude,
    Exists,
    Expired,
    Expunge,
    ExtendCandidates,
    Feature,
    Field,
    Fields,
    File,
    Filters,
    Flexible,
    Float,
    Fn,
    FN,
    Form,
    Full,
    Fulltext,
    Function,
    Functions,
    Geometry,
    Grant,
    Graphql,
    Handler,
    Header,
    Headers,
    Highlight,
    Hmac,
    Highlights,
    Hnsw,
    Ignore,
    Include,
    Index,
    Info,
    Int,
    Issuer,
    Jwks,
    Json,
    Jwt,
    KeepPrunedConnections,
    Kill,
    Language,
    Line,
    Live,
    Lm,
    Lowercase,
    M,
    M0,
    Mapper,
    Method,
    Middleware,
    ML,
    Mod,
    Model,
    Module,
    MultiLine,
    MultiPoint,
    MultiPolygon,
    Namespace,
    Ngram,
    No,
    NoIndex,
    Normal,
    Number,
    Numeric,
    Object,
    Omit,
    Option,
    Original,
    Overwrite,
    Param,
    Passhash,
    Password,
    Path,
    Payload,
    Permissions,
    Point,
    Polygon,
    PostingsCache,
    PostingsOrder,
    Prepare,
    Punct,
    Purge,
    Range,
    Raw,
    Readonly,
    Rebuild,
    Record,
    Reference,
    References,
    Refresh,
    Regex,
    Reject,
    Relation,
    Remove,
    Replace,
    Restore,
    Revoke,
    Revoked,
    Roles,
    Root,
    Rsa,
    Schedule,
    Scheduler,
    Schemafull,
    Schemaless,
    Scope,
    Script,
    Secret,
    Sequence,
    Session,
    Show,
    Signin,
    Signup,
    Silo,
    Since,
    Sleep,
    Snowball,
    Strict,
    Stripe,
    String,
    Structure,
    System,
    Table,
    Tables,
    TempFiles,
    TermsCache,
    TermsOrder,
    Token,
    Tokenizers,
    To,
    Type,
    Ulid,
    Unique,
    Uppercase,
    Url,
    User,
    Uuid,
    Vector,
    Verify,
    Vs,
    Webhook,
    When,
    Credential,
    Expires,
    HmacSha256,
    HmacSha512,
    Ed25519,
    Oauth,
    Custom,
    Respond,
    Immediate,
    Streaming,
    Whitelist,
    Head,
    Response,
    Code,
    Options,
}

impl SystemKeyword {
    pub fn as_str(&self) -> &'static str {
        match self {
            SystemKeyword::Access => "ACCESS",
            SystemKeyword::Algorithm => "ALGORITHM",
            SystemKeyword::Alter => "ALTER",
            SystemKeyword::Always => "ALWAYS",
            SystemKeyword::Analyzer => "ANALYZER",
            SystemKeyword::Api => "API",
            SystemKeyword::Array => "ARRAY",
            SystemKeyword::Ascii => "ASCII",
            SystemKeyword::Assert => "ASSERT",
            SystemKeyword::Authenticate => "AUTHENTICATE",
            SystemKeyword::Auto => "AUTO",
            SystemKeyword::Backend => "BACKEND",
            SystemKeyword::Auth => "AUTH",
            SystemKeyword::Backup => "BACKUP",
            SystemKeyword::Basic => "BASIC",
            SystemKeyword::Batch => "BATCH",
            SystemKeyword::Bearer => "BEARER",
            SystemKeyword::Binary => "BINARY",
            SystemKeyword::Blank => "BLANK",
            SystemKeyword::Bm25 => "BM25",
            SystemKeyword::Bool => "BOOL",
            SystemKeyword::Bucket => "BUCKET",
            SystemKeyword::Bytes => "BYTES",
            SystemKeyword::Camel => "CAMEL",
            SystemKeyword::Capacity => "CAPACITY",
            SystemKeyword::Cascade => "CASCADE",
            SystemKeyword::ChangeFeed => "CHANGEFEED",
            SystemKeyword::Changes => "CHANGES",
            SystemKeyword::Class => "CLASS",
            SystemKeyword::Collection => "COLLECTION",
            SystemKeyword::Comment => "COMMENT",
            SystemKeyword::Compact => "COMPACT",
            SystemKeyword::Computed => "COMPUTED",
            SystemKeyword::Concurrently => "CONCURRENTLY",
            SystemKeyword::Config => "CONFIG",
            SystemKeyword::Database => "DATABASE",
            SystemKeyword::Datetime => "DATETIME",
            SystemKeyword::Decimal => "DECIMAL",
            SystemKeyword::Default => "DEFAULT",
            SystemKeyword::Define => "DEFINE",
            SystemKeyword::Dimension => "DIMENSION",
            SystemKeyword::Distance => "DISTANCE",
            SystemKeyword::Drop => "DROP",
            SystemKeyword::Duplicate => "DUPLICATE",
            SystemKeyword::Duration => "DURATION",
            SystemKeyword::Edgengram => "EDGENGRAM",
            SystemKeyword::Efc => "EFC",
            SystemKeyword::Enforced => "ENFORCED",
            SystemKeyword::Event => "EVENT",
            SystemKeyword::Exclude => "EXCLUDE",
            SystemKeyword::Exists => "EXISTS",
            SystemKeyword::Expired => "EXPIRED",
            SystemKeyword::Expunge => "EXPUNGE",
            SystemKeyword::ExtendCandidates => "EXTEND_CANDIDATES",
            SystemKeyword::Feature => "FEATURE",
            SystemKeyword::Field => "FIELD",
            SystemKeyword::Fields => "FIELDS",
            SystemKeyword::File => "FILE",
            SystemKeyword::Filters => "FILTERS",
            SystemKeyword::Flexible => "FLEXIBLE",
            SystemKeyword::Float => "FLOAT",
            SystemKeyword::Fn => "fn",
            SystemKeyword::FN => "fn",
            SystemKeyword::Form => "FORM",
            SystemKeyword::Full => "FULL",
            SystemKeyword::Fulltext => "FULLTEXT",
            SystemKeyword::Function => "FUNCTION",
            SystemKeyword::Functions => "FUNCTIONS",
            SystemKeyword::Geometry => "GEOMETRY",
            SystemKeyword::Grant => "GRANT",
            SystemKeyword::Graphql => "GRAPHQL",
            SystemKeyword::Handler => "HANDLER",
            SystemKeyword::Header => "HEADER",
            SystemKeyword::Headers => "HEADERS",
            SystemKeyword::Highlight => "HIGHLIGHT",
            SystemKeyword::Hmac => "HMAC",
            SystemKeyword::Highlights => "HIGHLIGHTS",
            SystemKeyword::Hnsw => "HNSW",
            SystemKeyword::Ignore => "IGNORE",
            SystemKeyword::Include => "INCLUDE",
            SystemKeyword::Index => "INDEX",
            SystemKeyword::Info => "INFO",
            SystemKeyword::Int => "INT",
            SystemKeyword::Issuer => "ISSUER",
            SystemKeyword::Json => "JSON",
            SystemKeyword::Jwks => "JWKS",
            SystemKeyword::Jwt => "JWT",
            SystemKeyword::KeepPrunedConnections => "KEEP_PRUNED_CONNECTIONS",
            SystemKeyword::Kill => "KILL",
            SystemKeyword::Language => "LANGUAGE",
            SystemKeyword::Line => "LINE",
            SystemKeyword::Live => "LIVE",
            SystemKeyword::Lm => "LM",
            SystemKeyword::Lowercase => "LOWERCASE",
            SystemKeyword::M => "M",
            SystemKeyword::M0 => "M0",
            SystemKeyword::Mapper => "MAPPER",
            SystemKeyword::Method => "METHOD",
            SystemKeyword::Middleware => "MIDDLEWARE",
            SystemKeyword::ML => "ml",
            SystemKeyword::Mod => "mod",
            SystemKeyword::Model => "MODEL",
            SystemKeyword::Module => "MODULE",
            SystemKeyword::MultiLine => "MULTILINE",
            SystemKeyword::MultiPoint => "MULTIPOINT",
            SystemKeyword::MultiPolygon => "MULTIPOLYGON",
            SystemKeyword::Namespace => "NAMESPACE",
            SystemKeyword::Ngram => "NGRAM",
            SystemKeyword::No => "NO",
            SystemKeyword::NoIndex => "NOINDEX",
            SystemKeyword::Normal => "NORMAL",
            SystemKeyword::Number => "NUMBER",
            SystemKeyword::Numeric => "NUMERIC",
            SystemKeyword::Object => "OBJECT",
            SystemKeyword::Omit => "OMIT",
            SystemKeyword::Option => "OPTION",
            SystemKeyword::Original => "ORIGINAL",
            SystemKeyword::Overwrite => "OVERWRITE",
            SystemKeyword::Param => "PARAM",
            SystemKeyword::Passhash => "PASSHASH",
            SystemKeyword::Password => "PASSWORD",
            SystemKeyword::Path => "PATH",
            SystemKeyword::Payload => "PAYLOAD",
            SystemKeyword::Permissions => "PERMISSIONS",
            SystemKeyword::Point => "POINT",
            SystemKeyword::Polygon => "POLYGON",
            SystemKeyword::PostingsCache => "POSTINGS_CACHE",
            SystemKeyword::PostingsOrder => "POSTINGS_ORDER",
            SystemKeyword::Prepare => "PREPARE",
            SystemKeyword::Punct => "PUNCT",
            SystemKeyword::Purge => "PURGE",
            SystemKeyword::Range => "RANGE",
            SystemKeyword::Raw => "RAW",
            SystemKeyword::Readonly => "READONLY",
            SystemKeyword::Rebuild => "REBUILD",
            SystemKeyword::Record => "RECORD",
            SystemKeyword::Reference => "REFERENCE",
            SystemKeyword::References => "REFERENCES",
            SystemKeyword::Refresh => "REFRESH",
            SystemKeyword::Regex => "REGEX",
            SystemKeyword::Reject => "REJECT",
            SystemKeyword::Relation => "RELATION",
            SystemKeyword::Remove => "REMOVE",
            SystemKeyword::Replace => "REPLACE",
            SystemKeyword::Restore => "RESTORE",
            SystemKeyword::Revoke => "REVOKE",
            SystemKeyword::Revoked => "REVOKED",
            SystemKeyword::Roles => "ROLES",
            SystemKeyword::Root => "ROOT",
            SystemKeyword::Rsa => "RSA",
            SystemKeyword::Schedule => "SCHEDULE",
            SystemKeyword::Scheduler => "SCHEDULER",
            SystemKeyword::Schemafull => "SCHEMAFULL",
            SystemKeyword::Schemaless => "SCHEMALESS",
            SystemKeyword::Scope => "SCOPE",
            SystemKeyword::Script => "SCRIPT",
            SystemKeyword::Secret => "SECRET",
            SystemKeyword::Sequence => "SEQUENCE",
            SystemKeyword::Session => "SESSION",
            SystemKeyword::Show => "SHOW",
            SystemKeyword::Signin => "SIGNIN",
            SystemKeyword::Signup => "SIGNUP",
            SystemKeyword::Silo => "silo",
            SystemKeyword::Since => "SINCE",
            SystemKeyword::Sleep => "SLEEP",
            SystemKeyword::Snowball => "SNOWBALL",
            SystemKeyword::Strict => "STRICT",
            SystemKeyword::Stripe => "STRIPE",
            SystemKeyword::String => "STRING",
            SystemKeyword::Structure => "STRUCTURE",
            SystemKeyword::System => "SYSTEM",
            SystemKeyword::Table => "TABLE",
            SystemKeyword::Tables => "TABLES",
            SystemKeyword::TempFiles => "TEMPFILES",
            SystemKeyword::TermsCache => "TERMS_CACHE",
            SystemKeyword::TermsOrder => "TERMS_ORDER",
            SystemKeyword::Token => "TOKEN",
            SystemKeyword::Tokenizers => "TOKENIZERS",
            SystemKeyword::To => "TO",
            SystemKeyword::Type => "TYPE",
            SystemKeyword::Ulid => "ULID",
            SystemKeyword::Unique => "UNIQUE",
            SystemKeyword::Uppercase => "UPPERCASE",
            SystemKeyword::Url => "URL",
            SystemKeyword::User => "USER",
            SystemKeyword::Uuid => "UUID",
            SystemKeyword::Vector => "VECTOR",
            SystemKeyword::Verify => "VERIFY",
            SystemKeyword::Vs => "VS",
            SystemKeyword::Webhook => "WEBHOOK",
            SystemKeyword::When => "WHEN",
            SystemKeyword::Credential => "CREDENTIAL",
            SystemKeyword::Expires => "EXPIRES",
            SystemKeyword::HmacSha256 => "HMAC_SHA256",
            SystemKeyword::HmacSha512 => "HMAC_SHA512",
            SystemKeyword::Ed25519 => "ED25519",
            SystemKeyword::Oauth => "OAUTH",
            SystemKeyword::Custom => "CUSTOM",
            SystemKeyword::Respond => "RESPOND",
            SystemKeyword::Immediate => "IMMEDIATE",
            SystemKeyword::Streaming => "STREAMING",
            SystemKeyword::Whitelist => "WHITELIST",
            SystemKeyword::Head => "HEAD",
            SystemKeyword::Response => "RESPONSE",
            SystemKeyword::Code => "CODE",
            SystemKeyword::Options => "OPTIONS",
        }
    }
}

#[macro_export]
macro_rules! keyword_t {
    ("ACTION") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Action) };
    ("AFTER") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::After) };
    ("ALL") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::All) };
    ("ALLINSIDE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::AllInside) };
    ("AND") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::And) };
    ("ANDKW") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::AndKw) };
    ("ANY") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Any) };
    ("ANYINSIDE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::AnyInside) };
    ("AS") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::As) };
    ("ASCENDING") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Ascending) };
    ("AT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::At) };
    ("BEFORE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Before) };
    ("BEGIN") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Begin) };
    ("BREAK") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Break) };
    ("BY") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::By) };
    ("CANCEL") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Cancel) };
    ("COLLATE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Collate) };
    ("COMMIT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Commit) };
    ("CONTAINS") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Contains) };
    ("CONTAINSALL") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::ContainsAll) };
    ("CONTAINSANY") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::ContainsAny) };
    ("CONTAINSNONE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::ContainsNone) };
    ("CONTAINSNOT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::ContainsNot) };
    ("CONTENT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Content) };
    ("CONTINUE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Continue) };
    ("COUNT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Count) };
    ("CREATE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Create) };
    ("DELETE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Delete) };
    ("DESCENDING") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Descending) };
    ("DIFF") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Diff) };
    ("DISABLED") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Disabled) };
    ("ELSE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Else) };
    ("END") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::End) };
    ("EXPLAIN") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Explain) };
    ("false") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::False) };
    ("FETCH") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Fetch) };
    ("FOR") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::For) };
    ("FROM") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::From) };
    ("GET") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Get) };
    ("GROUP") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Group) };
    ("IF") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::If) };
    ("IN") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::In) };
    ("INSIDE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Inside) };
    ("INSERT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Insert) };
    ("INTERSECTS") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Intersects) };
    ("INTO") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Into) };
    ("IS") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Is) };
    ("KEY") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Key) };
    ("LET") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Let) };
    ("LIKE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Like) };
    ("LIMIT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Limit) };
    ("MERGE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Merge) };
    ("NONE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::None) };
    ("NONEINSIDE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::NoneInside) };
    ("NOT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Not) };
    ("NOTINSIDE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::NotInside) };
    ("NULL") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Null) };
    ("ON") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::On) };
    ("ONLY") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Only) };
    ("OR") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::OrKw) };
    ("ORDER") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Order) };
    ("OUT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Out) };
    ("OUTSIDE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Outside) };
    ("PARALLEL") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Parallel) };
    ("PATCH") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Patch) };
    ("POST") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Post) };
    ("PUT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Put) };
    ("RAND") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Random) };
    ("RELATE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Relate) };
    ("RETURN") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Return) };
    ("SEARCH") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Search) };
    ("SELECT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Select) };
    ("SET") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Set) };
    ("SPLIT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Split) };
    ("START") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Start) };
    ("THEN") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Then) };
    ("THROW") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Throw) };
    ("TIMEOUT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Timeout) };
    ("TRACE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Trace) };
    ("TRANSACTION") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Transaction) };
    ("true") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::True) };
    ("UNSET") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Unset) };
    ("UPDATE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Update) };
    ("UPSERT") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Upsert) };
    ("USE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Use) };
    ("VALUE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Value) };
    ("VALUES") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Values) };
    ("VERSION") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Version) };
    ("WHERE") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::Where) };
    ("WITH") => { $crate::syn::token::TokenKind::Sql($crate::syn::token::SqlKeyword::With) };
    ("ACCESS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Access) };
    ("ALGORITHM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Algorithm) };
    ("ALTER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Alter) };
    ("ALWAYS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Always) };
    ("ANALYZER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Analyzer) };
    ("API") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Api) };
    ("ARRAY") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Array) };
    ("ASCII") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Ascii) };
    ("ASSERT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Assert) };
    ("AUTH") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Auth) };
    ("AUTHENTICATE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Authenticate) };
    ("AUTO") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Auto) };
    ("BACKEND") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Backend) };
    ("BACKUP") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Backup) };
    ("BASIC") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Basic) };
    ("BATCH") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Batch) };
    ("BEARER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Bearer) };
    ("BLANK") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Blank) };
    ("BM25") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Bm25) };
    ("BOOL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Bool) };
    ("BINARY") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Binary) };
    ("BUCKET") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Bucket) };
    ("BYTES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Bytes) };
    ("CAMEL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Camel) };
    ("CAPACITY") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Capacity) };
    ("CASCADE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Cascade) };
    ("CHANGEFEED") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::ChangeFeed) };
    ("CHANGES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Changes) };
    ("CLASS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Class) };
    ("COLLECTION") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Collection) };
    ("COMMENT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Comment) };
    ("COMPACT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Compact) };
    ("COMPUTED") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Computed) };
    ("CONCURRENTLY") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Concurrently) };
    ("CONFIG") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Config) };
    ("DATABASE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Database) };
    ("DATETIME") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Datetime) };
    ("DECIMAL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Decimal) };
    ("DEFAULT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Default) };
    ("DEFINE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Define) };
    ("DIMENSION") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Dimension) };
    ("DISTANCE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Distance) };
    ("DROP") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Drop) };
    ("DUPLICATE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Duplicate) };
    ("DURATION") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Duration) };
    ("EDGENGRAM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Edgengram) };
    ("EFC") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Efc) };
    ("ENFORCED") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Enforced) };
    ("EVENT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Event) };
    ("EXCLUDE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Exclude) };
    ("EXISTS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Exists) };
    ("EXPIRED") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Expired) };
    ("EXPUNGE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Expunge) };
    ("EXTEND_CANDIDATES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::ExtendCandidates) };
    ("FEATURE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Feature) };
    ("FIELD") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Field) };
    ("FIELDS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Fields) };
    ("FILE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::File) };
    ("FILTERS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Filters) };
    ("FLEXIBLE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Flexible) };
    ("FLOAT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Float) };
    ("fn") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Fn) };
    ("FORM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Form) };
    ("FULL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Full) };
    ("FULLTEXT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Fulltext) };
    ("FUNCTION") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Function) };
    ("FUNCTIONS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Functions) };
    ("GEOMETRY") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Geometry) };
    ("GRANT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Grant) };
    ("GRAPHQL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Graphql) };
    ("HANDLER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Handler) };
    ("HEADER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Header) };
    ("HEADERS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Headers) };
    ("HIGHLIGHT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Highlight) };
    ("HIGHLIGHTS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Highlights) };
    ("HMAC") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Hmac) };
    ("HNSW") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Hnsw) };
    ("IGNORE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Ignore) };
    ("INCLUDE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Include) };
    ("INDEX") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Index) };
    ("INFO") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Info) };
    ("INT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Int) };
    ("ISSUER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Issuer) };
    ("JSON") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Json) };
    ("JWKS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Jwks) };
    ("JWT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Jwt) };
    ("KEEP_PRUNED_CONNECTIONS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::KeepPrunedConnections) };
    ("KILL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Kill) };
    ("LANGUAGE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Language) };
    ("LINE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Line) };
    ("LIVE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Live) };
    ("LM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Lm) };
    ("LOWERCASE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Lowercase) };
    ("M") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::M) };
    ("M0") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::M0) };
    ("MAPPER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Mapper) };
    ("METHOD") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Method) };
    ("MIDDLEWARE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Middleware) };
    ("ml") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::ML) };
    ("mod") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Mod) };
    ("MODEL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Model) };
    ("MODULE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Module) };
    ("MULTILINE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::MultiLine) };
    ("MULTIPOINT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::MultiPoint) };
    ("MULTIPOLYGON") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::MultiPolygon) };
    ("NAMESPACE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Namespace) };
    ("NGRAM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Ngram) };
    ("NO") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::No) };
    ("NOINDEX") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::NoIndex) };
    ("NORMAL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Normal) };
    ("NUMBER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Number) };
    ("NUMERIC") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Numeric) };
    ("OBJECT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Object) };
    ("OMIT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Omit) };
    ("OPTION") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Option) };
    ("ORIGINAL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Original) };
    ("OVERWRITE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Overwrite) };
    ("PARAM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Param) };
    ("PASSHASH") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Passhash) };
    ("PASSWORD") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Password) };
    ("PATH") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Path) };
    ("PAYLOAD") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Payload) };
    ("PERMISSIONS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Permissions) };
    ("POINT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Point) };
    ("POLYGON") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Polygon) };
    ("POSTINGS_CACHE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::PostingsCache) };
    ("POSTINGS_ORDER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::PostingsOrder) };
    ("PREPARE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Prepare) };
    ("PUNCT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Punct) };
    ("PURGE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Purge) };
    ("RANGE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Range) };
    ("RAW") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Raw) };
    ("READONLY") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Readonly) };
    ("REBUILD") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Rebuild) };
    ("RECORD") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Record) };
    ("REFERENCE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Reference) };
    ("REFERENCES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::References) };
    ("REFRESH") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Refresh) };
    ("REGEX") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Regex) };
    ("REJECT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Reject) };
    ("RELATION") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Relation) };
    ("REMOVE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Remove) };
    ("REPLACE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Replace) };
    ("RESTORE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Restore) };
    ("REVOKE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Revoke) };
    ("REVOKED") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Revoked) };
    ("ROLES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Roles) };
    ("ROOT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Root) };
    ("RSA") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Rsa) };
    ("SCHEDULE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Schedule) };
    ("SCHEDULER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Scheduler) }; // Keyword Added
    ("SCHEMAFULL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Schemafull) };
    ("SCHEMALESS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Schemaless) };
    ("SCOPE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Scope) };
    ("SCRIPT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Script) };
    ("SECRET") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Secret) };
    ("SEQUENCE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Sequence) };
    ("SESSION") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Session) };
    ("SHOW") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Show) };
    ("SIGNIN") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Signin) };
    ("SIGNUP") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Signup) };
    ("silo") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Silo) };
    ("SINCE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Since) };
    ("SLEEP") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Sleep) };
    ("SNOWBALL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Snowball) };
    ("STRICT") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Strict) };
    ("STRIPE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Stripe) };
    ("STRING") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::String) };
    ("STRUCTURE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Structure) };
    ("SYSTEM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::System) };
    ("TABLE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Table) };
    ("TABLES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Tables) };
    ("TEMPFILES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::TempFiles) };
    ("TERMS_CACHE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::TermsCache) };
    ("TERMS_ORDER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::TermsOrder) };
    ("TOKEN") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Token) };
    ("TOKENIZERS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Tokenizers) };
    ("TO") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::To) };
    ("TYPE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Type) };
    ("ULID") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Ulid) };
    ("UNIQUE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Unique) };
    ("UPPERCASE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Uppercase) };
    ("URL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Url) };
    ("USER") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::User) };
    ("UUID") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Uuid) };
    ("VECTOR") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Vector) };
    ("VERIFY") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Verify) };
    ("VS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Vs) };
    ("WEBHOOK") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Webhook) };
    ("WHEN") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::When) };
    ("CREDENTIAL") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Credential) };
    ("EXPIRES") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Expires) };
    ("HMAC_SHA256") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::HmacSha256) };
    ("HMAC_SHA512") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::HmacSha512) };
    ("ED25519") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Ed25519) };
    ("OAUTH") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Oauth) };
    ("CUSTOM") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Custom) };
    ("RESPOND") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Respond) };
    ("IMMEDIATE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Immediate) };
    ("STREAMING") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Streaming) };
    ("WHITELIST") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Whitelist) };
    ("HEAD") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Head) };
    ("RESPONSE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Response) };
    ("CODE") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Code) };
    ("OPTIONS") => { $crate::syn::token::TokenKind::System($crate::syn::token::SystemKeyword::Options) };
}

