# ObbyGameInfobox

[![Status: production](https://img.shields.io/badge/status-production-2ea043?style=flat-square)](https://obby.wiki/Module:ObbyGameInfobox)
[![Runtime: Scribunto Lua](https://img.shields.io/badge/runtime-Scribunto%20Lua-36c?style=flat-square)](https://www.mediawiki.org/wiki/Extension:Scribunto)
[![Source: Luau](https://img.shields.io/badge/source-Luau-00a2ff?style=flat-square)](../../../CONTRIBUTING.md)
[![License: AGPL--3.0](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)](../../../LICENSE)

The ObbyGameInfobox is the primary omni-infobox for Obby articles and the successor to the previous `{{Obby}}` infobox, powered by InfoboxNeue.

It turns a small set of possible parameters as well as live game metadata Roblox (courtesy of the OW edge API) into the visible infobox. In addition to this, ObbyGameInfobox also does all the plumbing and wiring related to Obby articles, such as handling Cargo records, categories, a short description, and search and other metadata.

> [!IMPORTANT]
> This is a production module used on obby articles, the primary type of page on the Obby Wiki. A display-only change can
> also affect Cargo, categorization, structured data, and SEO. Review every
> output listed below before merging.

**Contributor links:** [TASKS](./TODO.md) ＋ [TEMPLATE DOCUMENTATION](../../../templates/obbywiki.com/ObbyGameInfobox/doc.wikitext) ＋ [MODULE DOCUMENTATION](./doc.wikitext) ＋ [LIVE TEMPLATE](https://obby.wiki/Template:ObbyGameInfobox) ＋ [LIVE MODULE](https://obby.wiki/Module:ObbyGameInfobox) ＋ [CONTRIBUTING](../../../CONTRIBUTING.md) ＋ [DEPENDENCIES](#dependencies)

## At a glance

| | |
| --- | --- |
| Entry | `main` via `{{ObbyGameInfobox}}` |
| Origin | [`ObbyGameInfobox.module.luau`](./ObbyGameInfobox.module.luau) |
| Synced (WikiWire) | ✅ (obbywiki.com) |
| Uses or relies on an external endpoint or API | ✅ |
| Auto-categorizer | ✅ |
| Cargo tables | `Obbies` |
| Internationalization | via i18n2 ([`i18n/`](./i18n/)) |
| Unit tests | ✕ No |
| Type safe | ✕ Partially |
| Uses polyfills | ✕ No |