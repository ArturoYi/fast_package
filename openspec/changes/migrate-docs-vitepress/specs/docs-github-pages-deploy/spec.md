## ADDED Requirements

### Requirement: Automated docs build on master push

The repository SHALL include a GitHub Actions workflow that runs on `push` events to the `master` branch, installs Node.js dependencies for the documentation package, and executes the VitePress production build.

#### Scenario: Workflow triggers on master push

- **WHEN** commits are pushed to `master`
- **THEN** the docs deployment workflow runs automatically without manual dispatch

#### Scenario: Build failure blocks deploy

- **WHEN** the VitePress build command exits with a non-zero status
- **THEN** the workflow SHALL fail and SHALL NOT publish broken artifacts to GitHub Pages

### Requirement: Deploy built site to GitHub Pages

The workflow SHALL deploy the VitePress build output directory to GitHub Pages using supported GitHub Actions (for example `actions/upload-pages-artifact` and `actions/deploy-pages`, or `peaceiris/actions-gh-pages` with explicit permissions documented in the workflow).

#### Scenario: Successful deploy updates live site

- **WHEN** the build succeeds on `master`
- **THEN** GitHub Pages serves the newly built static site at the repository's configured Pages URL

#### Scenario: Repository permissions

- **WHEN** the workflow is enabled in GitHub
- **THEN** repository settings SHALL use GitHub Actions as the Pages source (not legacy branch-only publishing of unbuilt Markdown)

### Requirement: Documented base URL for GitHub Pages

The VitePress configuration SHALL set `base` (and locale roots if needed) to match the GitHub Pages URL path for this repository (typically `/fast_package/` for project sites under `ArturoYi/fast_package`), so assets and routes resolve correctly in production.

#### Scenario: Asset links work on Pages

- **WHEN** a reader opens a nested documentation route on the deployed GitHub Pages site
- **THEN** styles, scripts, and internal links load correctly without broken relative paths

### Requirement: Root README points to published docs

The root `README.md` SHALL link to the GitHub Pages documentation URL (or document how to run locally when Pages is unavailable), replacing links that only point to raw `docs/README.*.md` files as the primary documentation entry.

#### Scenario: Reader discovers docs from GitHub repo home

- **WHEN** a reader views the repository README on GitHub
- **THEN** they find a clear link to the live documentation site
