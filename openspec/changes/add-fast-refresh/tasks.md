## 1. Core types and state machine

- [x] 1.1 Add `FastRefreshMode`, `FastRefreshResult`, indicator state, and Header/Footer abstractions
- [x] 1.2 Implement Header/Footer notifiers (offset, mode transitions, task run/finish, noMore lock)
- [x] 1.3 Implement bouncing `ScrollPhysics` and `ScrollBehavior` that inject physics

## 2. Widget and controller

- [x] 2.1 Implement `FastRefresh` (Stack overlay, ScrollConfiguration, mutual exclusion, `resetAfterRefresh`)
- [x] 2.2 Implement `FastRefreshController` (`callRefresh` / `callLoad` / `finish*` / `resetFooter`)
- [x] 2.3 Implement `FastClassicHeader` / `FastClassicFooter` and builder indicators
- [x] 2.4 Export the public API from `fast_package.dart`

## 3. Tests, example, docs

- [x] 3.1 Add widget tests for refresh, load, results, controller, noMore, and mutual exclusion
- [x] 3.2 Add example page and route
- [x] 3.3 Add zh/en docs, sidebar links, and CHANGELOG
