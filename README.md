# CafeLab

A browsing-and-cart slice of an F&B ordering app, built for the iOS take-home assessment.

## Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/CafeLab.git
   cd CafeLab
   ```
2. Open CafeLab.xcodeproj in Xcode (15+).
3. Build & run on any iOS 16+ simulator. No API key, no `Info.plist` changes, no third-party dependencies required.

## Data source

**[DummyJSON](https://dummyjson.com/products)** — `GET https://dummyjson.com/products?limit=100`. No auth. Chosen over TheMealDB because it natively returns `price`, `stock`, and `category` on every item, which map directly onto the assessment's requirements (price + availability) without inventing fake data client-side.

Products are grouped by `category` and reshaped into the app's own `MenuItem` model in `APIService`, so the rest of the app never touches the wire format.

## Checkout

There's no real order API in scope. `CheckoutService.placeOrder` simulates one: a 1.5s artificial delay, then a success response (with a fake order ID) roughly 90% of the time and a failure the rest, so the loading/success/error states in `CartView` are all genuinely exercised rather than theoretical.

## Architecture

- **MVVM.** `MenuViewModel` owns Screen 1's async load lifecycle. `CartManager` is a shared `@EnvironmentObject`, created once in the App struct, holding cart state and checkout state so both screens read from one source of truth.
- **Navigation:** a single `NavigationStack` with a `NavigationLink` from the Menu toolbar to the Cart screen. Simple, native, and sufficient for a two-screen flow — no need for a coordinator or third-party router here.

---

## Design Questions

**1. State management.**
The menu screen has two independent, orthogonal pieces of state: what the *list* looks like (`MenuViewModel.state`: idle/loading/loaded/error, plus the grouped items) and what's *in the cart* (`CartManager.lines`, keyed by item ID). I kept them in separate `ObservableObject`s rather than one big view model because they change for different reasons and have different lifetimes — the item list is fetched once per screen visit, while the cart needs to be readable and writable from both the menu and cart screens simultaneously. `CartManager` is injected as an `@EnvironmentObject` so `MenuItemCard` can show live per-item quantities without the two view models needing a reference to each other.

**2. API contract.**
I'd push for the availability field to be a proper enum with real-time-safe semantics (e.g. `available` / `outOfStock` / `discontinued`), not a derived `stock > 0` check on my end — decrementing stock myself on every "add to cart" is a race condition waiting to happen once there's a real backend and concurrent users. I'd also want a documented idempotency key on the checkout endpoint so a retried "ORDER NOW" tap after a timeout doesn't double-charge.

**3. App lifecycle handling.**
`CartManager` is a `@StateObject` owned by the `App` struct, so it survives backgrounding and scene recreation for as long as the process is alive — SwiftUI doesn't tear down the App struct's state on backgrounding. The corner I cut: it's in-memory only. If iOS terminates the app (e.g. under memory pressure, or the user force-quits), the cart is gone. The assessment explicitly excludes "offline support or local persistence beyond in-memory state," so this is the deliberate trade-off, not an oversight — but it's the first thing I'd fix before shipping (see Q5).

**4. What I'd do differently with more time.**
I'd add a lightweight persistence layer — even just `Codable` cart state written to `UserDefaults` or a small on-disk JSON file — so the cart survives app termination, not just backgrounding. Right now a force-quit mid-order silently loses everything the user added, which is a real, visible failure mode for a shopping cart specifically (as opposed to most other app state, where losing it on force-quit is more forgivable).

**5. Production gap.**
The most significant gap is the checkout flow's lack of idempotency and retry safety — right now a tap on "ORDER NOW" that times out client-side has no way to know if the order actually succeeded server-side before retrying. In production that's a double-order risk, which for a food ordering app is a trust-breaking bug, not just a UI polish issue. I'd want a proper order-status endpoint to poll/reconcile against before I'd be comfortable shipping this to real users.

## What I'd test (not included per the brief)

- `CartManager`: add/increment/decrement/remove arithmetic, especially decrementing to zero removing the line, and that `add()` is a no-op for unavailable items.
- `MenuViewModel`: grouping/sorting logic, and that `loadIfNeeded()` doesn't re-fetch once already loaded.
- `APIService`: decoding against a fixture JSON payload, including a malformed-response case.
