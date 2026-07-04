# Site Design Notes - SQL & Databases

This MkDocs course site follows the shared learning-resource pattern used across `ijk37.com`: a branded Material theme in `assets/stylesheets/extra.css`, a root `index.md` landing page, and a visual card grid for course sections.

### Cross-site hub navigation

Each course homepage starts with a right-aligned `.resource-hub-nav` button group immediately below the intro copy and before the course card grid:

```markdown
<div class="resource-hub-nav" markdown>

[:octicons-home-16: Home](https://ijk37.com/){ .hub-nav-button .hub-nav-home }

[:octicons-graph-16: Data Science & AI](https://ijk37.com/data-science-ai/){ .hub-nav-button .hub-nav-dsai }

[:octicons-shield-lock-16: Cyber Security](https://ijk37.com/cyber-security/){ .hub-nav-button .hub-nav-cyber }

</div>
```

The button styling lives in `assets/stylesheets/extra.css`. Keep the buttons as Markdown links inside a `markdown`-enabled div so MkDocs Material processes the Octicons and `attr_list` classes consistently. The Home button uses the local course theme color; the two hub buttons use the portfolio hub colors: Data Science & AI `#34526b`, Cyber Security `#b4122e`.