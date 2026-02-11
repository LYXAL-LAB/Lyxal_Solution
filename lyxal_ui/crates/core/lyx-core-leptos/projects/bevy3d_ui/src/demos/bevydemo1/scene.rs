### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_bevy3d_ui\src\lyx-ui-foundations-lyx_ui_foundations_demos\bevylyx-ui-foundations-lyx_ui_foundations_demo1\scene.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_bevy3d_ui\src\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demos\bevylyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1\scene.rs
2: ```rust
3: 1: use super::eventqueue::events::{
4: 2:     ClientInEvents, CounterEvtData, EventProcessor, PluginOutEvents,
5: 3: };
6: 4: use super::eventqueue::plugin::DuplexEventsPlugin;
7: 5: use super::state::{Shared, SharedResource, SharedState};
8: 6: use bevy::prelude::*;
9: 7: 
10: 8: /// Represents the Cube in the scene
11: 9: #[derive(Component, Copy, Clone)]
12: 10: pub struct Cube;
13: 11: 
14: 12: /// Represents the 3D Scene
15: 13: #[derive(Clone)]
16: 14: pub struct Scene {
17: 15:     is_setup: bool,
18: 16:     canvas_id: String,
19: 17:     evt_plugin: DuplexEventsPlugin,
20: 18:     shared_state: Shared<SharedState>,
21: 19:     processor: EventProcessor<ClientInEvents, PluginOutEvents>,
22: 20: }
23: 21: 
24: 22: impl Scene {
25: 23:     /// Create a new instance
26: 24:     pub fn new(canvas_id: String) -> Scene {
27: 25:         let plugin = DuplexEventsPlugin::new();
28: 26:         Scene {
29: 27:             is_setup: false,
30: 28:             canvas_id,
31: 29:             evt_plugin: plugin.clone(),
32: 30:             shared_state: SharedState::new(),
33: 31:             processor: plugin.get_processor(),
34: 32:         }
35: 33:     }
36: 34: 
37: 35:     /// Get the shared state
38: 36:     pub fn get_state(&self) -> Shared<SharedState> {
39: 37:         self.shared_state.clone()
40: 38:     }
41: 39: 
42: 40:     /// Get the event processor
43: 41:     pub fn get_processor(
44: 42:         &self,
45: 43:     ) -> EventProcessor<ClientInEvents, PluginOutEvents> {
46: 44:         self.processor.clone()
47: 45:     }
48: 46: 
49: 47:     /// Setup and attach the bevy instance to the html canvas element
50: 48:     pub fn setup(&mut self) {
51: 49:         if self.is_setup {
52: 50:             return;
53: 51:         };
54: 52:         App::new()
55: 53:             .add_plugins(DefaultPlugins.set(WindowPlugin {
56: 54:                 primary_window: Some(Window {
57: 55:                     canvas: Some(self.canvas_id.clone()),
58: 56:                     ..default()
59: 57:                 }),
60: 58:                 ..default()
61: 59:             }))
62: 60:             .add_plugins(self.evt_plugin.clone())
63: 61:             .insert_resource(SharedResource(self.shared_state.clone()))
64: 62:             .add_systems(Startup, setup_scene)
65: 63:             .add_systems(Update, handle_bevy_event)
66: 64:             .run();
67: 65:         self.is_setup = true;
68: 66:     }
69: 67: }
70: 68: 
71: 69: /// Setup the scene
72: 70: fn setup_scene(
73: 71:     mut commands: Commands,
74: 72:     mut meshes: ResMut<Assets<Mesh>>,
75: 73:     mut materials: ResMut<Assets<StandardMaterial>>,
76: 74:     resource: Res<SharedResource>,
77: 75: ) {
78: 76:     let name = resource.0.lock().unwrap().name.clone();
79: 77:     // circular base
80: 78:     commands.spawn((
81: 79:         Mesh3d(meshes.add(Circle::new(4.0))),
82: 80:         MeshMaterial3d(materials.add(Color::WHITE)),
83: 81:         Transform::from_rotation(Quat::from_rotation_x(
84: 82:             -std::f32::consts::FRAC_PI_2,
85: 83:         )),
86: 84:     ));
87: 85: 
88: 86:     // cube
89: 87:     commands.spawn((
90: 88:         Mesh3d(meshes.add(Cuboid::new(1.0, 1.0, 1.0))),
91: 89:         MeshMaterial3d(materials.add(Color::srgb_u8(124, 144, 255))),
92: 90:         Transform::from_xyz(0.0, 0.5, 0.0),
93: 91:         Cube,
94: 92:     ));
95: 93: 
96: 94:     // light
97: 95:     commands.spawn((
98: 96:         PointLight {
99: 97:             shadows_enabled: true,
100: 98:             ..default()
101: 99:         },
102: 100:         Transform::from_xyz(4.0, 8.0, 4.0),
103: 101:     ));
104: 102: 
105: 103:     // camera
106: 104:     commands.spawn((
107: 105:         Camera3d::default(),
108: 106:         Transform::from_xyz(-2.5, 4.5, 9.0).looking_at(Vec3::ZERO, Vec3::Y),
109: 107:     ));
110: 108:     commands.spawn((Text::new(name), TextFont::default()));
111: 109: }
112: 110: 
113: 111: /// Move the Cube on event
114: 112: fn handle_bevy_event(
115: 113:     mut counter_event_reader: EventReader<CounterEvtData>,
116: 114:     mut cube_query: Query<&mut Transform, With<Cube>>,
117: 115: ) {
118: 116:     let mut cube_transform = cube_query.get_single_mut().expect("no cube :(");
119: 117:     for _ev in counter_event_reader.read() {
120: 118:         cube_transform.translation += Vec3::new(0.0, _ev.value, 0.0);
121: 119:     }
122: 120: }
123: ```
```
