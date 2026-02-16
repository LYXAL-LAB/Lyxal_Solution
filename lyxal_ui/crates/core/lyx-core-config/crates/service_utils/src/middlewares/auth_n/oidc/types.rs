1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\types.rs
10: 8: ```rust
11: 9: use actix_web::HttpRequest;
12: 10: use base64::{Engine, engine::general_purpose};
13: 11: use openidconnect::{
14: 12:     AdditionalClaims, AuthorizationCode, CsrfToken, EmptyExtraTokenFields, IdTokenClaims,
15: 13:     IdTokenFields, Nonce, StandardTokenResponse,
16: 14:     core::{
17: 15:         CoreGenderClaim, CoreIdTokenClaims, CoreJsonWebKeyType,
18: 16:         CoreJweContentEncryptionAlgorithm, CoreJwsSigningAlgorithm, CoreTokenResponse,
19: 17:         CoreTokenType,
20: 18:     },
21: 19: };
22: 20: use serde::{Deserialize, Deserializer, Serialize};
23: 21: 
24: 22: #[derive(Serialize, Debug, Deserialize, Clone)]
25: 23: pub(super) struct GlobalUserExtraClaims {
26: 24:     pub(super) organisations: Vec<String>,
27: 25:     pub(super) switch_pass: String,
28: 26: }
29: 27: 
30: 28: impl AdditionalClaims for GlobalUserExtraClaims {}
31: 29: 
32: 30: pub(super) type GlobalUserCoreIdTokenFields = IdTokenFields<
33: 31:     GlobalUserExtraClaims,
34: 32:     EmptyExtraTokenFields,
35: 33:     CoreGenderClaim,
36: 34:     CoreJweContentEncryptionAlgorithm,
37: 35:     CoreJwsSigningAlgorithm,
38: 36:     CoreJsonWebKeyType,
39: 37: >;
40: 38: 
41: 39: pub(super) type GlobalUserTokenResponse =
42: 40:     StandardTokenResponse<GlobalUserCoreIdTokenFields, CoreTokenType>;
43: 41: pub(super) type GlobalUserClaims = IdTokenClaims<GlobalUserExtraClaims, CoreGenderClaim>;
44: 42: 
45: 43: pub(super) type OrgUserTokenResponse = CoreTokenResponse;
46: 44: pub(super) type OrgUserClaims = CoreIdTokenClaims;
47: 45: 
48: 46: #[derive(Serialize)]
49: 47: pub(super) struct ProtectionCookie {
50: 48:     pub(super) csrf: CsrfToken,
51: 49:     pub(super) nonce: Nonce,
52: 50: }
53: 51: 
54: 52: impl<'de> Deserialize<'de> for ProtectionCookie {
55: 53:     fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
56: 54:     where
57: 55:         D: Deserializer<'de>,
58: 56:     {
59: 57:         #[derive(Deserialize)]
60: 58:         struct Helper {
61: 59:             csrf: String,
62: 60:             nonce: Nonce,
63: 61:         }
64: 62:         let helper = Helper::deserialize(deserializer)?;
65: 63: 
66: 64:         let base64_decoded = general_purpose::STANDARD
67: 65:             .decode(&helper.csrf)
68: 66:             .map_err(serde::de::Error::custom)?;
69: 67:         let state: RedirectionState =
70: 68:             serde_json::from_slice(&base64_decoded).map_err(serde::de::Error::custom)?;
71: 69: 
72: 70:         Ok(Self {
73: 71:             nonce: helper.nonce,
74: 72:             csrf: state.csrf,
75: 73:         })
76: 74:     }
77: 75: }
78: 76: 
79: 77: impl ProtectionCookie {
80: 78:     pub(super) fn from_req(req: &HttpRequest) -> Result<Self, String> {
81: 79:         req.cookie("protection")
82: 80:             .ok_or_else(|| "Protection cookie not found".to_string())
83: 81:             .and_then(|c| serde_json::from_str(c.value()).map_err(|e| e.to_string()))
84: 82:     }
85: 83: }
86: 84: 
87: 85: #[derive(Serialize, Deserialize)]
88: 86: pub(super) struct RedirectionState {
89: 87:     pub(super) csrf: CsrfToken,
90: 88:     pub(super) redirect_uri: String,
91: 89: }
92: 90: 
93: 91: pub(super) struct LoginParams {
94: 92:     pub(super) code: AuthorizationCode,
95: 93:     pub(super) state: RedirectionState,
96: 94: }
97: 95: 
98: 96: impl<'de> Deserialize<'de> for LoginParams {
99: 97:     fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
100: 98:     where
101: 99:         D: Deserializer<'de>,
102: 100:     {
103: 101:         #[derive(Deserialize)]
104: 102:         struct Helper {
105: 103:             code: AuthorizationCode,
106: 104:             state: String,
107: 105:         }
108: 106:         let helper = Helper::deserialize(deserializer)?;
109: 107: 
110: 108:         let base64_decoded = general_purpose::STANDARD
111: 109:             .decode(helper.state)
112: 110:             .map_err(serde::de::Error::custom)?;
113: 111:         let state: RedirectionState =
114: 112:             serde_json::from_slice(&base64_decoded).map_err(serde::de::Error::custom)?;
115: 113: 
116: 114:         Ok(Self {
117: 115:             code: helper.code,
118: 116:             state,
119: 117:         })
120: 118:     }
121: 119: }
122: 120: ```
123: 121: ```
124: 122: ```
125: 123: ```
126: ```
```

