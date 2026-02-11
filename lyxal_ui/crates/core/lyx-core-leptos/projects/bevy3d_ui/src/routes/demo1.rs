### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_bevy3d_ui\src\routes\lyx-ui-foundations-lyx_ui_foundations_demo1.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_bevy3d_ui\src\routes\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1.rs
2: ```rust
3: 1: use crate::lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demos::bevylyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1::eventqueue::events::{
4: 2:     ClientInEvents, CounterEvtData,
5: 3: };
6: 4: use crate::lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demos::bevylyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1::scene::Scene;
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
8: 6: 
9: 7: /// 3d view component
10: 8: #[component]
11: 9: pub fn Demo1() -> impl IntoView {
12: 10:     // Setup a Counter
13: 11:     let initial_value: i32 = 0;
14: 12:     let step: i32 = 1;
15: 13:     let (value, set_value) = signal(initial_value);
16: 14: 
17: 15:     // Setup a bevy 3d scene
18: 16:     let scene = Scene::new("#bevy".to_string());
19: 17:     let sender = scene.get_processor().sender;
20: 18:     let (sender_sig, _set_sender_sig) = signal(sender);
21: 19:     let (scene_sig, _set_scene_sig) = signal(scene);
22: 20: 
23: 21:     // We need to add the 3D view onto the canvas post render.
24: 22:     Effect::new(move |_| {
25: 23:         request_animation_frame(move || {
26: 24:             scene_sig.get_untracked().setup();
27: 25:         });
28: 26:     });
29: 27: 
30: 28:     view! {
31: 29:         <div>
32: 30:             <button on:click=move |_| set_value.set(0)>"Clear"</button>
33: 31:             <button on:click=move |_| {
34: 32:                 set_value.update(|value| *value -= step);
35: 33:                 let newpos = (step as f32) / 10.0;
36: 34:                 sender_sig
37: 35:                     .get()
38: 36:                     .send(ClientInEvents::CounterEvt(CounterEvtData { value: -newpos }))
39: 37:                     .expect("could not send event");
40: 38:             }>"-1"</button>
41: 39:             <span>"Value: " {value} "!"</span>
42: 40:             <button on:click=move |_| {
43: 41:                 set_value.update(|value| *value += step);
44: 42:                 let newpos = step as f32 / 10.0;
45: 43:                 sender_sig
46: 44:                     .get()
47: 45:                     .send(ClientInEvents::CounterEvt(CounterEvtData { value: newpos }))
48: 46:                     .expect("could not send event");
49: 47:             }>"+1"</button>
50: 48:         </div>
51: 49: 
52: 50:         <canvas id="bevy" width="800" height="600"></canvas>
53: 51:     }
54: 52: }
55: ```
```
