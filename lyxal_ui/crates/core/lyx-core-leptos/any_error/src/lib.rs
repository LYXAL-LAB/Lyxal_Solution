### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\any_error\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\any_error\src\lib.rs
2: ```rust
3: 1: #![forbid(unsafe_code)]
4: 2: #![deny(missing_docs)]
5: 3: 
6: 4: //! A utility library for wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping arbitrary errors, and for “throwing” errors in a way
7: 5: //! that can be caught by user-defined error hooks.
8: 6: 
9: 7: use std::{
10: 8:     cell::RefCell,
11: 9:     error,
12: 10:     fmt::{self, Display},
13: 11:     future::Future,
14: 12:     ops,
15: 13:     pin::Pin,
16: 14:     sync::Arc,
17: 15:     task::{Context, Poll},
18: 16: };
19: 17: 
20: 18: /* Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper Types */
21: 19: 
22: 20: /// A generic wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for any error.
23: 21: #[derive(Debug, Clone)]
24: 22: #[repr(transparent)]
25: 23: pub struct Error(Arc<dyn error::Error + Send + Sync>);
26: 24: 
27: 25: impl Error {
28: 26:     /// Converts the wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper into the inner reference-counted error.
29: 27:     pub fn into_inner(self) -> Arc<dyn error::Error + Send + Sync> {
30: 28:         Arc::clone(&self.0)
31: 29:     }
32: 30: }
33: 31: 
34: 32: impl ops::Deref for Error {
35: 33:     type Target = Arc<dyn error::Error + Send + Sync>;
36: 34: 
37: 35:     fn deref(&self) -> &Self::Target {
38: 36:         &self.0
39: 37:     }
40: 38: }
41: 39: 
42: 40: impl fmt::Display for Error {
43: 41:     fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
44: 42:         write!(f, "{}", self.0)
45: 43:     }
46: 44: }
47: 45: 
48: 46: impl<T> From<T> for Error
49: 47: where
50: 48:     T: Into<Box<dyn error::Error + Send + Sync + 'static>>,
51: 49: {
52: 50:     fn from(value: T) -> Self {
53: 51:         Error(Arc::from(value.into()))
54: 52:     }
55: 53: }
56: 54: 
57: 55: /// Implements behavior that allows for global or scoped error handling.
58: 56: ///
59: 57: /// This allows for both "throwing" errors to register them, and "clearing" errors when they are no
60: 58: /// longer valid. This is useful for something like a user interface, in which an error can be
61: 59: /// "thrown" on some invalid user input, and later "cleared" if the user corrects the input.
62: 60: /// Keeping a unique identifier for each error allows the UI to be updated accordingly.
63: 61: pub trait ErrorHook: Send + Sync {
64: 62:     /// Handles the given error, returning a unique identifier.
65: 63:     fn throw(&self, error: Error) -> ErrorId;
66: 64: 
67: 65:     /// Clears the error associated with the given identifier.
68: 66:     fn clear(&self, id: &ErrorId);
69: 67: }
70: 68: 
71: 69: /// A unique identifier for an error. This is returned when you call [`throw`], which calls a
72: 70: /// global error handler.
73: 71: #[derive(Debug, PartialEq, Eq, Hash, Clone, Default)]
74: 72: pub struct ErrorId(usize);
75: 73: 
76: 74: impl Display for ErrorId {
77: 75:     fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
78: 76:         Display::fmt(&self.0, f)
79: 77:     }
80: 78: }
81: 79: 
82: 80: impl From<usize> for ErrorId {
83: 81:     fn from(value: usize) -> Self {
84: 82:         Self(value)
85: 83:     }
86: 84: }
87: 85: 
88: 86: thread_local! {
89: 87:     static ERROR_HOOK: RefCell<Option<Arc<dyn ErrorHook>>> = RefCell::new(None);
90: 88: }
91: 89: 
92: 90: /// Resets the error hook to its previous state when dropped.
93: 91: pub struct ResetErrorHookOnDrop(Option<Arc<dyn ErrorHook>>);
94: 92: 
95: 93: impl Drop for ResetErrorHookOnDrop {
96: 94:     fn drop(&mut self) {
97: 95:         ERROR_HOOK.with_borrow_mut(|this| *this = self.0.take())
98: 96:     }
99: 97: }
100: 98: 
101: 99: /// Returns the current error hook.
102: 100: pub fn get_error_hook() -> Option<Arc<dyn ErrorHook>> {
103: 101:     ERROR_HOOK.with_borrow(Clone::clone)
104: 102: }
105: 103: 
106: 104: /// Sets the current thread-local error hook, which will be invoked when [`throw`] is called.
107: 105: pub fn set_error_hook(hook: Arc<dyn ErrorHook>) -> ResetErrorHookOnDrop {
108: 106:     ResetErrorHookOnDrop(
109: 107:         ERROR_HOOK.with_borrow_mut(|this| Option::replace(this, hook)),
110: 108:     )
111: 109: }
112: 110: 
113: 111: /// Invokes the error hook set by [`set_error_hook`] with the given error.
114: 112: pub fn throw(error: impl Into<Error>) -> ErrorId {
115: 113:     ERROR_HOOK
116: 114:         .with_borrow(|hook| hook.as_ref().map(|hook| hook.throw(error.into())))
117: 115:         .unwrap_or_default()
118: 116: }
119: 117: 
120: 118: /// Clears the given error from the current error hook.
121: 119: pub fn clear(id: &ErrorId) {
122: 120:     ERROR_HOOK
123: 121:         .with_borrow(|hook| hook.as_ref().map(|hook| hook.clear(id)))
124: 122:         .unwrap_or_default()
125: 123: }
126: 124: 
127: 125: pin_project_lite::pin_project! {
128: 126:     /// A [`Future`] that reads the error hook that is set when it is created, and sets this as the
129: 127:     /// current error hook whenever it is polled.
130: 128:     pub struct ErrorHookFuture<Fut> {
131: 129:         hook: Option<Arc<dyn ErrorHook>>,
132: 130:         #[pin]
133: 131:         inner: Fut
134: 132:     }
135: 133: }
136: 134: 
137: 135: impl<Fut> ErrorHookFuture<Fut> {
138: 136:     /// Reads the current hook and wraps the given [`Future`], returning a new `Future` that will
139: 137:     /// set the error hook whenever it is polled.
140: 138:     pub fn new(inner: Fut) -> Self {
141: 139:         Self {
142: 140:             hook: ERROR_HOOK.with_borrow(Clone::clone),
143: 141:             inner,
144: 142:         }
145: 143:     }
146: 144: }
147: 145: 
148: 146: impl<Fut> Future for ErrorHookFuture<Fut>
149: 147: where
150: 148:     Fut: Future,
151: 149: {
152: 150:     type Output = Fut::Output;
153: 151: 
154: 152:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
155: 153:         let this = self.project();
156: 154:         let _hook = this
157: 155:             .hook
158: 156:             .as_ref()
159: 157:             .map(|hook| set_error_hook(Arc::clone(hook)));
160: 158:         this.inner.poll(cx)
161: 159:     }
162: 160: }
163: 161: 
164: 162: #[cfg(test)]
165: 163: mod tests {
166: 164:     use super::*;
167: 165:     use std::error::Error as StdError;
168: 166: 
169: 167:     #[derive(Debug)]
170: 168:     struct MyError;
171: 169: 
172: 170:     impl Display for MyError {
173: 171:         fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
174: 172:             write!(f, "MyError")
175: 173:         }
176: 174:     }
177: 175: 
178: 176:     impl StdError for MyError {}
179: 177: 
180: 178:     #[test]
181: 179:     fn test_from() {
182: 180:         let e = MyError;
183: 181:         let _le = Error::from(e);
184: 182: 
185: 183:         let e = "some error".to_string();
186: 184:         let _le = Error::from(e);
187: 185: 
188: 186:         let e = anyhow::anyhow!("anyhow error");
189: 187:         let _le = Error::from(e);
190: 188:     }
191: 189: }
192: ```
```
