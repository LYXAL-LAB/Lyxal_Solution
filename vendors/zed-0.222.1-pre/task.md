# Task: Fix Gemini API Rate Limiting

- [x] **Planning**
    - [x] Create initial task list
    - [x] Create implementation plan
    - [x] User approval of the plan
- [x] **Investigation: Architecture et Token Usage**
    - [x] Research session management and history in `agent.rs`
    - [x] Analyze `Thread` struct in `thread.rs`
    - [x] Research token calculation and display logic (Gemini -> Zed -> UI)
- [/] **Implementation: Error Handling**
    - [/] Modify `google_ai.rs` to parse `Retry-After` header
    - [ ] Update `google.rs` to propagate `retry_after` to the core engine
- [x] **Implementation: Throttling**
    - [x] Enhance `RateLimiter` or add a specific throttler for Gemini
    - [x] Add a minimum delay between subsequent Gemini requests
- [x] **Verification**
    - [x] Verify that 429 errors now include a delay
    - [x] Test with tool-heavy conversations to ensure throttling works
    - [x] Create walkthrough with results
- [x] **Build Environment**
    - [x] Install CMake and Go
    - [x] Install VS Spectre-mitigated libs
    - [x] Install Protoc
    - [x] Perform final compilation

- [x] **Research: Thread Summarization and Naming**
    - [x] Locate summarization logic in `text_thread.rs`
    - [x] Examine summarization prompt in `agent_settings`
    - [x] Investigate `NewNativeAgentThreadFromSummary` action
    - [x] Understand how Zed triggers initial thread naming

- [/] **Implementation: UI and Summarization Enhancements**
    - [ ] Modify `google_ai.rs` to support `thought: String`
    - [ ] Update `google.rs` to stream the actual thinking text
    - [ ] Update `summarize_thread_detailed_prompt.txt` with work-checkpoint instructions
    - [ ] Implement automatic 97% trigger in `agent.rs`
    - [ ] Implement in-place compaction in `thread.rs`
