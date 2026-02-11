### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\attribute_interceptor.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\attribute_interceptor.rs
2: ```rust
3: 1: use crate::attr::{
4: 2:     any_attribute::{AnyAttribute, IntoAnyAttribute},
5: 3:     Attribute, NextAttribute,
6: 4: };
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
8: 6: 
9: 7: /// Function stored to build/rebuild the wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped children when attributes are added.
10: 8: type ChildBuilder<T> = dyn Fn(AnyAttribute) -> T + Send + Sync + 'static;
11: 9: 
12: 10: /// Intercepts attributes passed to your component, allowing passing them to any element.
13: 11: ///
14: 12: /// By default, Leptos passes any attributes passed to your component (e.g. `<MyComponent
15: 13: /// attr:class="some-class"/>`) to the top-level element in the view returned by your component.
16: 14: /// [`AttributeInterceptor`] allows you to intercept this behavior and pass it onto any element in
17: 15: /// your component instead.
18: 16: ///
19: 17: /// Must be the top level element in your component's view.
20: 18: ///
21: 19: /// ## Example
22: 20: ///
23: 21: /// Any attributes passed to MyComponent will be passed to the #inner element.
24: 22: ///
25: 23: /// ```
26: 24: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
27: 25: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::attribute_interceptor::AttributeInterceptor;
28: 26: ///
29: 27: /// #[component]
30: 28: /// pub fn MyComponent() -> impl IntoView {
31: 29: ///     view! {
32: 30: ///         <AttributeInterceptor let:attrs>
33: 31: ///             <div id="wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper">
34: 32: ///                 <div id="inner" {..attrs} />
35: 33: ///             </div>
36: 34: ///         </AttributeInterceptor>
37: 35: ///     }
38: 36: /// }
39: 37: /// ```
40: 38: #[component(transparent)]
41: 39: pub fn AttributeInterceptor<Chil, T>(
42: 40:     /// The elements that will be rendered, with the attributes this component received as a
43: 41:     /// parameter.
44: 42:     children: Chil,
45: 43: ) -> impl IntoView
46: 44: where
47: 45:     Chil: Fn(AnyAttribute) -> T + Send + Sync + 'static,
48: 46:     T: IntoView + 'static,
49: 47: {
50: 48:     AttributeInterceptorInner::new(children)
51: 49: }
52: 50: 
53: 51: /// Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper to intercept attributes passed to a component so you can lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply them to a different
54: 52: /// element.
55: 53: struct AttributeInterceptorInner<T: IntoView, A> {
56: 54:     children_builder: Box<ChildBuilder<T>>,
57: 55:     children: T,
58: 56:     attributes: A,
59: 57: }
60: 58: 
61: 59: impl<T: IntoView> AttributeInterceptorInner<T, ()> {
62: 60:     /// Use this as the returned view from your component to collect the attributes that are passed
63: 61:     /// to your component so you can manually handle them.
64: 62:     pub fn new<F>(children: F) -> Self
65: 63:     where
66: 64:         F: Fn(AnyAttribute) -> T + Send + Sync + 'static,
67: 65:     {
68: 66:         let children_builder = Box::new(children);
69: 67:         let children = children_builder(().into_any_attr());
70: 68: 
71: 69:         Self {
72: 70:             children_builder,
73: 71:             children,
74: 72:             attributes: (),
75: 73:         }
76: 74:     }
77: 75: }
78: 76: 
79: 77: impl<T: IntoView, A: Attribute> Render for AttributeInterceptorInner<T, A> {
80: 78:     type State = <T as Render>::State;
81: 79: 
82: 80:     fn build(self) -> Self::State {
83: 81:         self.children.build()
84: 82:     }
85: 83: 
86: 84:     fn rebuild(self, state: &mut Self::State) {
87: 85:         self.children.rebuild(state);
88: 86:     }
89: 87: }
90: 88: 
91: 89: impl<T: IntoView + 'static, A> AddAnyAttr for AttributeInterceptorInner<T, A>
92: 90: where
93: 91:     A: Attribute,
94: 92: {
95: 93:     type Output<SomeNewAttr: lyx-core-lyx_core_lyx-core-lyx_core_leptos::attr::Attribute> =
96: 94:         AttributeInterceptorInner<T, <<A as NextAttribute>::Output<SomeNewAttr> as Attribute>::CloneableOwned>;
97: 95: 
98: 96:     fn add_any_attr<NewAttr: lyx-core-lyx_core_lyx-core-lyx_core_leptos::attr::Attribute>(
99: 97:         self,
100: 98:         attr: NewAttr,
101: 99:     ) -> Self::Output<NewAttr>
102: 100:     where
103: 101:         Self::Output<NewAttr>: RenderHtml,
104: 102:     {
105: 103:         let attributes =
106: 104:             self.attributes.add_any_attr(attr).into_cloneable_owned();
107: 105: 
108: 106:         let children =
109: 107:             (self.children_builder)(attributes.clone().into_any_attr());
110: 108: 
111: 109:         AttributeInterceptorInner {
112: 110:             children_builder: self.children_builder,
113: 111:             children,
114: 112:             attributes,
115: 113:         }
116: 114:     }
117: 115: }
118: 116: 
119: 117: impl<T: IntoView + 'static, A: Attribute> RenderHtml
120: 118:     for AttributeInterceptorInner<T, A>
121: 119: {
122: 120:     type AsyncOutput = T::AsyncOutput;
123: 121:     type Owned = AttributeInterceptorInner<T, A::CloneableOwned>;
124: 122: 
125: 123:     const MIN_LENGTH: usize = T::MIN_LENGTH;
126: 124: 
127: 125:     fn dry_resolve(&mut self) {
128: 126:         self.children.dry_resolve()
129: 127:     }
130: 128: 
131: 129:     fn resolve(
132: 130:         self,
133: 131:     ) -> impl std::future::Future<Output = Self::AsyncOutput> + Send {
134: 132:         self.children.resolve()
135: 133:     }
136: 134: 
137: 135:     fn to_html_with_buf(
138: 136:         self,
139: 137:         buf: &mut String,
140: 138:         position: &mut lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::view::Position,
141: 139:         escape: bool,
142: 140:         mark_branches: bool,
143: 141:         _extra_attrs: Vec<AnyAttribute>,
144: 142:     ) {
145: 143:         self.children.to_html_with_buf(
146: 144:             buf,
147: 145:             position,
148: 146:             escape,
149: 147:             mark_branches,
150: 148:             vec![],
151: 149:         )
152: 150:     }
153: 151: 
154: 152:     fn hydrate<const FROM_SERVER: bool>(
155: 153:         self,
156: 154:         cursor: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::hydration::Cursor,
157: 155:         position: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::view::PositionState,
158: 156:     ) -> Self::State {
159: 157:         self.children.hydrate::<FROM_SERVER>(cursor, position)
160: 158:     }
161: 159: 
162: 160:     async fn hydrate_async(
163: 161:         self,
164: 162:         cursor: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::hydration::Cursor,
165: 163:         position: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::view::PositionState,
166: 164:     ) -> Self::State {
167: 165:         self.children.hydrate_async(cursor, position).await
168: 166:     }
169: 167: 
170: 168:     fn into_owned(self) -> Self::Owned {
171: 169:         AttributeInterceptorInner {
172: 170:             children_builder: self.children_builder,
173: 171:             children: self.children,
174: 172:             attributes: self.attributes.into_cloneable_owned(),
175: 173:         }
176: 174:     }
177: 175: }
178: ```
```
