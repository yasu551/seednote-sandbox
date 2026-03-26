# AGENTS.md

## Project

Seednote is an iOS note app for capturing thought fragments and using AI to analyze, connect, and draft from them.

- Target OS: iOS 17+
- Language: Swift 5.9 / SwiftUI / SwiftData
- UI language: Japanese
- External dependencies: none beyond Apple frameworks

## Build And Test

The project is managed with XcodeGen.

```bash
xcodegen generate
```

Standard CLI build check:

```bash
xcodebuild \
  -project Seednote.xcodeproj \
  -scheme SeednoteTests \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/seednote-derived \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Preferred test execution in this repo:

- Use `mcp__XcodeBuildMCP__test_sim` for test runs
- Shared scheme is `SeednoteTests`

## Architecture

- MVVM with `View` + `ViewModel`
- `AppRouter.shared` acts as the DI container
- Services are protocol-first

## Coding Rules

### ViewModel

- Add `@MainActor`
- Conform to `ObservableObject`
- Expose state with `@Published`
- Inject dependencies via protocol types in `init`

### Model

- Use SwiftData `@Model`
- Use `@Attribute(.unique) var id: UUID` for identifiers

### UI

- User-facing strings must be Japanese

## TDD Workflow

When the user asks to do TDD, follow `.claude/commands/tdd.md` as the canonical workflow. Treat it as a required procedure, not a suggestion.

Requested behavior: user-provided requirement

Run the TDD cycle one step at a time:

### Step 1: Red

1. Add exactly one test for the requested behavior.
2. Use Swift Testing (`@Test`, `#expect`), not XCTest.
3. Name the test function in Japanese so the intent is explicit.
4. Follow Arrange-Act-Assert.
5. Run `mcp__XcodeBuildMCP__test_sim`.
6. Confirm the new test fails for the expected reason.
7. Report which test failed and why.

### Step 2: Green

1. Write only the minimum production code needed for that single failing test.
2. Do not add speculative code.
3. Run `mcp__XcodeBuildMCP__test_sim`.
4. Confirm the target test passes and existing tests remain green.
5. Report the test result summary.

### Step 3: Refactor

1. Review both test and production code for cleanup opportunities.
2. If a refactor improves naming, duplication, or structure, apply it.
3. Run `mcp__XcodeBuildMCP__test_sim` again.
4. Report what changed, or explicitly state that no refactor was needed.

### TDD Constraints

- Never write production code before the test.
- In Red, add only one new test at a time.
- In Green, implement the minimum necessary behavior only.
- Always execute tests in each phase.
- Use Swift Testing for new tests.

## Note For Codex

Codex does not automatically consume Claude command files as slash commands. This repository uses `AGENTS.md` to expose the same TDD procedure to Codex. Keep `.claude/commands/tdd.md` and this file aligned if the workflow changes.
