# Product Catalog

A Flutter product catalog app built for the Neurogine Junior Mobile Developer technical assessment. It consumes the free [DummyJSON](https://dummyjson.com) API to list, search, and view details of products.

## Stack

- **Flutter** (Dart SDK `^3.10.4`)
- **Provider** for state management (`ChangeNotifier`)
- **http** for network requests
- **cached_network_image** for image caching, placeholder, and error handling
- **google_fonts** for typography (Plus Jakarta Sans)

## How to run

```bash
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
```

> Tip: for a smoother demo, use `flutter run --release`. Image decode and list scrolling are noticeably faster than in debug mode.

## Architecture

Two-layer split under `lib/`:

```
lib/
├── data/
│   ├── app_exception.dart   # typed error kinds (network/timeout/server/unknown)
│   ├── models/              # Product, Review, Category, ProductResponse
│   ├── services/            # ProductApiService — raw HTTP + JSON
│   └── repositories/        # ProductRepository — returns domain models
└── presentation/
    ├── viewmodels/          # ProductViewModel (ChangeNotifier)
    ├── views/               # ProductListScreen, ProductDetailScreen
    └── widgets/             # ProductCard, LoadingView, ErrorView, EmptyView
```

**Why this split**

- `ProductApiService` only knows about HTTP and JSON. It doesn't know what a `Product` is.
- `ProductRepository` converts raw JSON into domain models. Perfect boundary for adding a local cache later.
- `ProductViewModel` owns all UI state (loading, error, pagination, search, filters) and exposes methods for the view. The view is dumb: it reads state and calls methods.
- Both `ProductApiService` and `ProductRepository` accept optional constructor parameters, so the view model is testable with a fake repository (dependency injection without a DI framework).

## Features

- Product **grid** with title, thumbnail, price, brand, rating badge, and discount badge
- **Pagination** — 20 items per page, auto-loads when the user is within 200 px of the bottom
- **Detail screen** — always refetches via `GET /products/{id}`; the product passed from the list is shown immediately as a placeholder so the screen never blanks out
- **Four visual states** — loading, empty, error+retry, success
- **Debounced search** (500 ms, server-side)
- **Filter bottom sheet** with category chips, minimum rating slider, and price range slider
- **Pull-to-refresh** with a persistent offline banner if the refresh fails
- **Typed error handling** — network / timeout / server / unknown, each with its own icon and message
- **Reviews, stock, availability, warranty, shipping, and return policy** on the detail screen
- **Image downsampling** (`memCacheWidth`) for lighter memory
- **Premium editorial theme** with Google Fonts (Plus Jakarta Sans)

## Search strategy — server-side, debounced 500 ms

I chose `GET /products/search?q=…` over client-side filtering.

- Client-side would only match products already loaded (the first N pages). Server-side matches the entire catalog.
- 500 ms debounce skips most keystrokes without feeling laggy.
- Pagination is disabled during search because the endpoint returns all matches in one response.

## Filter strategy

- **Category** is server-side via `GET /products/category/{slug}` — clean pagination, only matching products returned.
- **Rating** and **price** are client-side because DummyJSON doesn't support them as query params. They're layered on top of `_products` via a `filteredProducts` getter.

## Error handling

- **Initial load fails** → full-screen `ErrorView` with the right icon and message for the error kind, plus Retry.
- **Pagination fails** (list already has items) → inline retry tile at the bottom; existing products stay visible.
- **Pull-to-refresh fails** → persistent red banner at the top with a Retry button; the list stays visible.
- **Detail refresh fails** → amber banner at the top; the list-passed product data is still shown.
- **Categories fail on cold start** → automatically retried on the next successful product load.

## Tests

- `test/product_test.dart` — model JSON parsing including int-vs-double edge cases and empty lists.
- `test/product_view_model_test.dart` — initial state, fetch, pagination, search, categories (hits live API).

## What I did not finish

- Fake-repository unit tests — DI hooks are in place but tests still hit the live API.
- Widget tests for the list and detail screens.
- Multi-category filter — DummyJSON's category endpoint only accepts one slug; multi-select would degrade pagination cleanliness.

## AI usage disclosure

I used AI (Claude) during development for:
- **Research & guidance** - sanity-checking approach on edge cases (offline pull-to-refresh vs cached fallback, pagination failure UX)
- **Second opinion** - reviewing architectural tradeoffs I had already leaned toward (server-side vs client-side search, when to keep list vs show error screen)
- **Debugging** - e.g. narrowing down a null/type issue in the pagination `skip` calculation faster than tracing manually

Architecture, layering, feature scope, and all final implementation choices are my own, AI was consulted to validate decisions I had already made, not to generate them. Project structure, file organization, and the debounce implementation were written from scratch based on my own design. I read and understood every suggestion before applying it.

