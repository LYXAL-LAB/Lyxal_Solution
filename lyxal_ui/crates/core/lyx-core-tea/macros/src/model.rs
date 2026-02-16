1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lib\macros\src\model.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\model.rs
30: 28: ```rust
31: 29: pub struct Model {
32: 30:   pub vis: syn::Visibility,
33: 31:   pub name: syn::Ident,
34: 32:   pub generics: syn::Generics,
35: 33:   pub is_named: bool,
36: 34:   pub fields: Vec<Field>,
37: 35: }
38: 36: 
39: 37: impl From<syn::DeriveInput> for Model {
40: 38:   fn from(
41: 39:     syn::DeriveInput {
42: 40:       ident: name,
43: 41:       vis,
44: 42:       generics,
45: 43:       data,
46: 44:       ..
47: 45:     }: syn::DeriveInput,
48: 46:   ) -> Self {
49: 47:     match data {
50: 48:       syn::Data::Struct(syn::DataStruct { fields, .. }) => {
51: 49:         if matches!(fields, syn::Fields::Unit) {
52: 50:           abort!(name, "unit structs are not supported");
53: 51:         }
54: 52: 
55: 53:         Model {
56: 54:           vis,
57: 55:           name,
58: 56:           generics,
59: 57:           is_named: matches!(fields, syn::Fields::Named(_)),
60: 58:           fields: fields.into_iter().map(Field::from).collect(),
61: 59:         }
62: 60:       }
63: 61:       syn::Data::Enum(e) => abort!(e.enum_token, "enums are not supported"),
64: 62:       syn::Data::Union(union) => {
65: 63:         abort!(union.union_token, "unions are not supported")
66: 64:       }
67: 65:     }
68: 66:   }
69: 67: }
70: 68: 
71: 69: pub struct Field {
72: 70:   pub vis: syn::Visibility,
73: 71:   pub name: Option<syn::Ident>,
74: 72:   pub ty: syn::Type,
75: 73:   pub is_nested_model: bool,
76: 74: }
77: 75: 
78: 76: impl From<syn::Field> for Field {
79: 77:   fn from(
80: 78:     syn::Field {
81: 79:       attrs,
82: 80:       vis,
83: 81:       ident: name,
84: 82:       ty,
85: 83:       ..
86: 84:     }: syn::Field,
87: 85:   ) -> Self {
88: 86:     Self {
89: 87:       vis,
90: 88:       name,
91: 89:       ty,
92: 90:       is_nested_model: is_nested_model(&attrs),
93: 91:     }
94: 92:   }
95: 93: }
96: 94: 
97: 95: /// Derives all the goodness neaded for making some lyx-core-lyx_core_lyx-core-lyx_core_leptos tea.
98: 96: pub fn model(ast: syn::DeriveInput) -> Model {
99: 97:   Model::from(ast)
100: 98: }
101: 99: 
102: 100: fn is_nested_model(attrs: &[syn::Attribute]) -> bool {
103: 101:   attrs
104: 102:     .iter()
105: 103:     .any(|attr| *attr == syn::parse_quote!(#[model]))
106: 104: }
107: 105: ```
108: 106: ```
109: 107: ```
110: 108: ```
111: 109: ```
112: 110: ```
113: 111: ```
114: 112: ```
115: 113: ```
116: 114: ```
117: 115: ```
118: 116: ```
119: 117: ```
120: 118: ```
121: ```
```

