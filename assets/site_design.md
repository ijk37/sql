# Site Design Notes - SQL & Databases

This MkDocs course site follows the shared learning-resource pattern used across `ijk37.com`: a branded Material theme in `assets/stylesheets/extra.css`, a root `index.md` landing page, and a visual card grid for course sections.
### Cross-site hub navigation

Each course site injects a vertical `.resource-sidebar-hub` button group into the MkDocs Material right sidebar, below the page table of contents. This keeps the course homepage card grid focused on course sections while still giving every page quick access to the portfolio home and the two learning-resource hubs.

The buttons are created by `assets/javascripts/extra.js` on page load and on Material instant-navigation updates:

- Home → `https://ijk37.com/`
- Data Science & AI → `https://ijk37.com/data-science-ai/`
- Cyber Security → `https://ijk37.com/cyber-security/`

The styling lives in `assets/stylesheets/extra.css`. The Home button uses the local course theme color; the two hub buttons use the portfolio hub colors: Data Science & AI `#34526b`, Cyber Security `#b4122e`.
