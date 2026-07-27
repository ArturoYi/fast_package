## ADDED Requirements

### Requirement: VitePress documentation site structure

The repository SHALL provide a VitePress-based documentation site that builds to static HTML and replaces monolithic README-style docs as the primary documentation experience.

#### Scenario: Local development preview

- **WHEN** a contributor runs the documented local dev command from the repository root or docs package directory
- **THEN** the VitePress dev server starts and serves the documentation site with hot reload

#### Scenario: Production build

- **WHEN** a contributor runs the documented build command
- **THEN** VitePress emits static assets suitable for hosting on GitHub Pages without manual post-processing

### Requirement: Bilingual locales (Chinese and English)

The documentation site SHALL support at least two locales: Simplified Chinese (`zh-CN` or root locale per VitePress i18n config) and English (`en-US`), each with independent sidebar and navigation labels appropriate to that language.

#### Scenario: Language switch

- **WHEN** a reader uses the locale switcher in the site chrome
- **THEN** the reader is taken to the equivalent page in the selected language when a translation exists

#### Scenario: Default entry

- **WHEN** a reader opens the site base URL without a locale path (if applicable per config)
- **THEN** the site SHALL serve a defined default locale home page (documented in site config)

### Requirement: Local full-text search

The site SHALL enable VitePress local search using MiniSearch by setting `themeConfig.search.provider` to `'local'` in `.vitepress/config.ts` (or equivalent locale-specific theme config).

#### Scenario: Search finds migrated content

- **WHEN** a reader enters a keyword from migrated API or tutorial pages in the search box
- **THEN** the search UI returns matching pages with fuzzy full-text results without calling an external search API

### Requirement: Default VitePress theme with project branding

The site SHALL use the default VitePress theme styling (no custom CSS framework that diverges from VitePress defaults unless required for logo sizing). The site SHALL display a project-specific logo in the navigation bar and a favicon derived from the same brand asset.

#### Scenario: Logo visible in nav

- **WHEN** a reader loads any documentation page
- **THEN** the navigation bar shows the Fast Package logo image configured in `themeConfig.logo`

#### Scenario: Favicon in browser tab

- **WHEN** a reader loads the site in a browser
- **THEN** the tab icon reflects the project favicon configured in site head or public assets

### Requirement: Content migration from legacy Markdown

All substantive sections currently in `docs/README.zh-CN.md` and `docs/README.en-US.md` SHALL be represented in the VitePress site (split into logical pages such as guide, API/modules, and UI components), preserving code samples and headings semantics.

#### Scenario: Feature parity for Chinese

- **WHEN** a reader browses the Chinese locale sidebar
- **THEN** they can access pages covering installation, core utilities (debounce, throttle, rate limit, async queue, extensions, scan), and UI components described in the legacy Chinese README

#### Scenario: Feature parity for English

- **WHEN** a reader browses the English locale sidebar
- **THEN** they can access the English equivalents of the same topics as the legacy English README
