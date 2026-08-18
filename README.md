# ObbyWiki Shared Modules & Templates Repository

> [!NOTE]
> This is the central repository for (mostly) every module and template on the [Obby Wiki](https://obby.wiki). Here, modules and templates are automatically uploaded to the wiki via WikiWire. [Learn more about the Obby Wiki here](https://obby.wiki/OW:About).

---

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=4bec7a43ac62&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

---

# 1. What this repository is

This is the OWSMT repository, also known as the Obby Wiki Shared Modules and Templates repository. This is the central repository where the majority of OW-developed modules and templates are stored in their raw source form, often in Luau.

## 1.1. Layout

The layout and organization of this repository is governed by WikiWire's format:

* `modules/` for modules,
* `templates/` for templates,
* and `mediawiki/` for all MediaWiki: namespace items/pages

Under any of these folders are three types of sub-folders:

* host folders (i.e., obbywiki.com) that contain modules only for that specific site (i.e., ObbyGameInfobox)
* the shared folder or shared site-groups folders
* the common folder
* (as well as any junk folders like _legacy)

More information on WikiWire here: https://github.com/obbywiki/wikiwire

# 2. Why Luau?

Some people may believe that Luau is Roblox-specific and can only be used in Roblox. While Luau is both developed by Roblox and most commonly applied to that use case, many programmers have built tooling around Luau because of its worthwhile benefits over vanilla Lua. In this case, Luau is not used directly, as Scribunto and MediaWiki do not support it. Instead, here, Luau is transpiled to Lua via the automated production CI pipeline (WikiWire & DarkLua) and patched with the necessary polyfills and compatibility scripts to function correctly.

With this, Luau offers significant advantages such as modern Lua features, typing, and the Luau language server protocol (Luau-LSP).

# 3. Contributing

At first, contributing may be overwhelming for new contributors. However, it is relatively similar unless to other central module repositories, unless you are adding a new module/template.

Please note that only some polyfills like `table.find`, `string.split`, `table.clear`, and `table.create` are available at this moment. Feel free to add or request more at the `scripts/polyfill.js` script.

Requirements:

* Rokit, Aftman

```bash
rokit install
aftman install
lute setup
```

# 4. Licensing

Dedicated modules/templates/content are available under the license at LICENSE in this repository. Please note that content marked as imported, or under the _imported/ folder, adhere to their own license respectively, as defined by the place that they were sourced from.

# 5. See Also

* [WikiWire](https://github.com/obbywiki/wikiwire)
* [Luau](https://luau.org/)

---

[ObbyWiki OSS](https://obbywiki.github.io/) - [Obby Wiki](https://obby.wiki) - [Use our DigitalOcean referral for $200 free for 60 days](https://www.digitalocean.com/?refcode=4bec7a43ac62)
