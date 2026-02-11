### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\inner.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\inner.rs
2: ```rust
3: 1: use crate::{
4: 2:     graph::{
5: 3:         AnySource, AnySubscriber, Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, ReactiveNode, ReactiveNodeState,
6: 4:         Source, SourceSet, Subscriber, SubscriberSet, WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
7: 5:     },
8: 6:     owner::{Owner, Storage, StorageAccess},
9: 7: };
10: 8: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
11: 9: use std::{
12: 10:     fmt::Debug,
13: 11:     sync::{Arc, RwLock, RwLockWriteGuard},
14: 12: };
15: 13: 
16: 14: pub struct MemoInner<T, S>
17: 15: where
18: 16:     S: Storage<T>,
19: 17: {
20: 18:     /// Must always be acquired *after* the reactivity lock
21: 19:     pub(crate) value: Arc<RwLock<Option<S::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped>>>,
22: 20:     #[allow(clippy::type_complexity)]
23: 21:     pub(crate) fun: Arc<dyn Fn(Option<T>) -> (T, bool) + Send + Sync>,
24: 22:     pub(crate) owner: Owner,
25: 23:     pub(crate) reactivity: RwLock<MemoInnerReactivity>,
26: 24: }
27: 25: 
28: 26: pub(crate) struct MemoInnerReactivity {
29: 27:     pub(crate) state: ReactiveNodeState,
30: 28:     pub(crate) sources: SourceSet,
31: 29:     pub(crate) subscribers: SubscriberSet,
32: 30:     pub(crate) any_subscriber: AnySubscriber,
33: 31: }
34: 32: 
35: 33: impl<T, S> Debug for MemoInner<T, S>
36: 34: where
37: 35:     S: Storage<T>,
38: 36: {
39: 37:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
40: 38:         f.debug_struct("MemoInner").finish_non_exhaustive()
41: 39:     }
42: 40: }
43: 41: 
44: 42: impl<T: 'static, S> MemoInner<T, S>
45: 43: where
46: 44:     S: Storage<T>,
47: 45: {
48: 46:     #[allow(clippy::type_complexity)]
49: 47:     pub fn new(
50: 48:         fun: Arc<dyn Fn(Option<T>) -> (T, bool) + Send + Sync>,
51: 49:         any_subscriber: AnySubscriber,
52: 50:     ) -> Self {
53: 51:         Self {
54: 52:             value: Arc::new(RwLock::new(None)),
55: 53:             fun,
56: 54:             owner: Owner::new(),
57: 55:             reactivity: RwLock::new(MemoInnerReactivity {
58: 56:                 state: ReactiveNodeState::Dirty,
59: 57:                 sources: Default::default(),
60: 58:                 subscribers: SubscriberSet::new(),
61: 59:                 any_subscriber,
62: 60:             }),
63: 61:         }
64: 62:     }
65: 63: }
66: 64: 
67: 65: impl<T: 'static, S> ReactiveNode for MemoInner<T, S>
68: 66: where
69: 67:     S: Storage<T>,
70: 68: {
71: 69:     fn mark_dirty(&self) {
72: 70:         self.reactivity.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().state = ReactiveNodeState::Dirty;
73: 71:         self.mark_subscribers_check();
74: 72:     }
75: 73: 
76: 74:     fn mark_check(&self) {
77: 75:         /// codegen optimisation:
78: 76:         fn inner(reactivity: &RwLock<MemoInnerReactivity>) {
79: 77:             {
80: 78:                 let mut lock = reactivity.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
81: 79:                 if lock.state != ReactiveNodeState::Dirty {
82: 80:                     lock.state = ReactiveNodeState::Check;
83: 81:                 }
84: 82:             }
85: 83:             for sub in
86: 84:                 (&reactivity.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().subscribers).into_iter()
87: 85:             {
88: 86:                 sub.mark_check();
89: 87:             }
90: 88:         }
91: 89:         inner(&self.reactivity);
92: 90:     }
93: 91: 
94: 92:     fn mark_subscribers_check(&self) {
95: 93:         let lock = self.reactivity.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
96: 94:         for sub in (&lock.subscribers).into_iter() {
97: 95:             sub.mark_check();
98: 96:         }
99: 97:     }
100: 98: 
101: 99:     fn update_if_necessary(&self) -> bool {
102: 100:         /// codegen optimisation:
103: 101:         fn needs_update(reactivity: &RwLock<MemoInnerReactivity>) -> bool {
104: 102:             let (state, sources) = {
105: 103:                 let inner = reactivity.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
106: 104:                 (inner.state, inner.sources.clone())
107: 105:             };
108: 106:             match state {
109: 107:                 ReactiveNodeState::Clean => false,
110: 108:                 ReactiveNodeState::Dirty => true,
111: 109:                 ReactiveNodeState::Check => {
112: 110:                     (&sources).into_iter().any(|source| {
113: 111:                         source.update_if_necessary()
114: 112:                             || reactivity.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().state
115: 113:                                 == ReactiveNodeState::Dirty
116: 114:                     })
117: 115:                 }
118: 116:             }
119: 117:         }
120: 118: 
121: 119:         if needs_update(&self.reactivity) {
122: 120:             // No deadlock risk, because we only hold the value lock.
123: 121:             let value = self.value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().take();
124: 122: 
125: 123:             /// codegen optimisation:
126: 124:             fn inner_1(
127: 125:                 reactivity: &RwLock<MemoInnerReactivity>,
128: 126:             ) -> AnySubscriber {
129: 127:                 let any_subscriber =
130: 128:                     reactivity.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().any_subscriber.clone();
131: 129:                 any_subscriber.clear_sources(&any_subscriber);
132: 130:                 any_subscriber
133: 131:             }
134: 132:             let any_subscriber = inner_1(&self.reactivity);
135: 133: 
136: 134:             let (new_value, changed) = self.owner.with_cleanup(|| {
137: 135:                 any_subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
138: 136:                     (self.fun)(value.map(StorageAccess::into_taken))
139: 137:                 })
140: 138:             });
141: 139: 
142: 140:             // Two locks are acquired, so order matters.
143: 141:             let reactivity_lock = self.reactivity.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
144: 142:             {
145: 143:                 // Safety: Can block endlessly if the user is has a ReadGuard on the value
146: 144:                 let mut value_lock = self.value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
147: 145:                 *value_lock = Some(S::wrap(new_value));
148: 146:             }
149: 147: 
150: 148:             /// codegen optimisation:
151: 149:             fn inner_2(
152: 150:                 changed: bool,
153: 151:                 mut reactivity_lock: RwLockWriteGuard<'_, MemoInnerReactivity>,
154: 152:             ) {
155: 153:                 reactivity_lock.state = ReactiveNodeState::Clean;
156: 154: 
157: 155:                 if changed {
158: 156:                     let subs = reactivity_lock.subscribers.clone();
159: 157:                     drop(reactivity_lock);
160: 158:                     for sub in subs {
161: 159:                         // don't trigger reruns of effects/memos
162: 160:                         // lyx-logic-lyx_logic_lyx-logic-lyx_logic_basically: if one of the oblyx-platform-lyx_platform_lyx-platform-lyx_platform_servers has triggered this memo to
163: 161:                         // run, it doesn't need to be re-triggered because of this change
164: 162:                         if !Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::is(&sub) {
165: 163:                             sub.mark_dirty();
166: 164:                         }
167: 165:                     }
168: 166:                 } else {
169: 167:                     drop(reactivity_lock);
170: 168:                 }
171: 169:             }
172: 170:             inner_2(changed, reactivity_lock);
173: 171: 
174: 172:             changed
175: 173:         } else {
176: 174:             /// codegen optimisation:
177: 175:             fn inner(reactivity: &RwLock<MemoInnerReactivity>) -> bool {
178: 176:                 let mut lock = reactivity.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
179: 177:                 lock.state = ReactiveNodeState::Clean;
180: 178:                 false
181: 179:             }
182: 180:             inner(&self.reactivity)
183: 181:         }
184: 182:     }
185: 183: }
186: 184: 
187: 185: impl<T: 'static, S> Source for MemoInner<T, S>
188: 186: where
189: 187:     S: Storage<T>,
190: 188: {
191: 189:     fn add_subscriber(&self, subscriber: AnySubscriber) {
192: 190:         let mut lock = self.reactivity.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
193: 191:         lock.subscribers.subscribe(subscriber);
194: 192:     }
195: 193: 
196: 194:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
197: 195:         self.reactivity
198: 196:             .write()
199: 197:             .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
200: 198:             .subscribers
201: 199:             .unsubscribe(subscriber);
202: 200:     }
203: 201: 
204: 202:     fn clear_subscribers(&self) {
205: 203:         self.reactivity.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().subscribers.take();
206: 204:     }
207: 205: }
208: 206: 
209: 207: impl<T: 'static, S> Subscriber for MemoInner<T, S>
210: 208: where
211: 209:     S: Storage<T>,
212: 210: {
213: 211:     fn add_source(&self, source: AnySource) {
214: 212:         self.reactivity.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().sources.insert(source);
215: 213:     }
216: 214: 
217: 215:     fn clear_sources(&self, subscriber: &AnySubscriber) {
218: 216:         self.reactivity
219: 217:             .write()
220: 218:             .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
221: 219:             .sources
222: 220:             .clear_sources(subscriber);
223: 221:     }
224: 222: }
225: ```
```
