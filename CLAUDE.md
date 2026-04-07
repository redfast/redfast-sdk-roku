# Redfast SDK for Roku

Roku SceneGraph SDK for displaying promotional prompts (modals, video dialogs, inline banners) in BrightScript/Roku channels.

## Language & Framework

- **BrightScript** (.brs) — Roku's scripting language. No semicolons, `sub`/`function`/`end sub`/`end function` blocks, `m` is the component scope (like `this`), `m.top` references the XML component node.
- **SceneGraph XML** (.xml) — Declares Roku components, their interfaces (public fields/functions), child node trees, and script imports. Each `.xml` file pairs with a `.brs` file of the same name.
- Components extend base types like `Group`, `Task`, `Node`, `Rectangle`, `Scene`.
- `<interface>` in XML defines public fields (`<field>`) and callable functions (`<function>`).
- Observer pattern: `observeField("fieldName", "callbackSub")` for async communication between components.

## Project Structure

### source/
- **main.brs** — App entry point. Creates `roSGScreen`, instantiates `MainScene`, and runs the main event loop.

### components/MainScene (.brs/.xml)
- Root scene component extending `Scene`. Instantiates `PromotionManager` (id=`promoMgr`), calls `initPromotion` with appId/userId/fonts, then loads the demo app (`RedflixMain`) into `sceneStack` once initialized.

### components/redfast/ — The SDK

#### Core
- **PromotionManager.brs/.xml** — Central SDK controller (extends `Group`). Manages the full promotion lifecycle:
  - `initPromotion(params)` — Initializes with appId, userId, anonymousUserId, fonts, deviceType.
  - Ping loop (`updatePing`) — Periodic server pings to fetch promotion paths/configs with ETag caching and exponential backoff.
  - `onScreenChanged(params)` — Trigger-based prompt display on screen navigation.
  - `onButtonClicked(params)` — Trigger-based prompt display on button click events.
  - `getPrompt/getPrompts/getTriggerablePrompts` — Query available prompts by pathId, pathType, zoneId, screenName, clickId.
  - `showPrompt(params)` / `showInline(params)` — Programmatic prompt display.
  - `sendPromptEvent(params)` — Fire analytics events (impression, dismiss, goal, holdout, etc.).
  - IAP integration via `ChannelStore` node (billing): `getIapItems`, `purchaseIap`, `getPuchasedItems`.
  - `customTrack`, `ping`, `setUserId`, `setAnonymousUserId`, `resetGoal`, `getMetas`, `getVersion`.
  - Exports all public functions via `<interface>` in the XML.
  - Has a `.NOIAP` variant (PromotionManager.brs.NOIAP / .xml.NOIAP) that strips IAP/billing support.

- **PromotionApi.brs/.xml** — Network layer (extends `Task` for background threading). `fireEvent(params)` sends HTTP requests to `conduit.redfast.com` for events: ping, impression, dismiss, goal, click, customTrack, resetGoal, holdout. Returns parsed JSON via `content` field.

- **consts.brs** — Shared constants and utilities:
  - `PromotionResult()` — Result/interaction codes (ok, error, button1-3, dismissed, timerExpired, holdout, etc.).
  - `PathType()` — Prompt types (invisible, modal, horizontal, video, interstitial, bottomBanner).
  - `ZoneType()` — Inline zone types (billboard, featured, roku-horizontal).
  - `DeviceType()` — Platform identifiers.
  - `parseKeyValuePair()`, `pxToInteger()`, `pxToFloat()` — Utility functions.
  - `preparePromptResult()` — Enriches result objects with prompt metadata.

- **LocalStorage.brs** — Suppression/cooldown persistence using `roRegistrySection("Redfast")`. Tracks overlay display intervals (time-based, visit-based, infinite) and holdout keys.

#### UI Components
- **PromotionDialog.brs/.xml** — Modal/interstitial/bottom-banner prompt (extends `Group`). Renders a background image poster with up to 3 CTA buttons, a countdown timer, and handles accept/decline/dismiss/timeout interactions. Supports popup sizes (small/medium/large), banner positioning, auto or fixed button widths.

- **PromotionVideoDialog.brs/.xml** — Video prompt (extends `Group`). Plays a video with poster fallback, accept/decline buttons. Supports loop, controls, mute, and preload settings.

- **PromotionInline.brs/.xml** — Inline/horizontal banner (extends `Group`). Renders a poster image within a parent container, supports focus highlight and tile interaction (goal tracking on OK press).

- **CtaButton.brs/.xml** — Reusable call-to-action button (extends `Rectangle`). Supports label, colors, focus highlight, border styling, and fires `buttonSelected` on OK key press.

- **DebugView.brs/.xml** — Dev-only debug component (extends `Node`). Options key opens a keyboard dialog to change userId or reset goals.

## Build

- `build-sdk.sh [iap|noiap]` — Packages the `components/redfast/` folder into `roku-sdk.zip`. Picks IAP or NOIAP variant of PromotionManager.
- `build-demo.sh` — Packages the full demo app into `roku-demo.zip`.

## Key Patterns

- All SDK components include `consts.brs` and `LocalStorage.brs` via `<script>` tags (BrightScript has no module imports — scripts are concatenated per component scope).
- Async HTTP via `Task` nodes: create a `PromotionApi` node, call `fireEvent()`, observe `state` or `content` for results.
- Prompt display flow: PromotionManager creates a dialog node, appends it to a root Group, observes `result` field for dismiss/accept callbacks, then removes the child.
- Version is hardcoded in `PromotionManager.brs:getVersion()` (currently `"1.0.44"`).
