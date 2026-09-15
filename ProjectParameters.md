# Project Parameters — NAICS Classification

> Authoritative source for every name, ID, version, and quoting decision used across this
> project. Never hardcode these values in AL — always derive them from this file. Populated
> during Step 1 (DEFINE) on 2026-09-15.

| Parameter | Value | Notes |
|---|---|---|
| **Extension Name** | NAICS Classification | → `app.json "name"` |
| **Publisher** | OnlyCopilotFans | → `app.json "publisher"` |
| **Deployment Target** | SaaS PTE | |
| **Use Namespace (y/n)** | Yes | |
| **Namespace** | `OnlyCopilotFans.NAICSClassification` | PascalCase, no spaces |
| **Localization** | US | NAICS is the US/North American standard classification |
| **AL Object Prefix** | `ocpf` | Used in page names/identifiers |
| **APIPublisher / APIGroup Prefix / APIVersion** | N/A | No API pages/queries in this project (confirmed 2026-09-15) |
| **Permission Set Prefix** | `OCPF - ` | Uppercase, no AL quotes |
| **Object ID range(s)** | Primary: **60470–60499** (30 IDs). No Additional ranges. | Covers all 19 planned objects + buffer (Standards §5.2) |
| **Permission Sets required?** | Yes | Extension owns the new NAICS Code table → `PTE0004` requires it. 2 IDs reserved. |
| **AL Runtime** | 17.0 | Confirmed against the real Base Application manifest (`NavxManifest.xml`: `Platform="28.0.0.0" Runtime="17.0"`) — matches `app.json` exactly, no change needed. |
| **BC Application Minimum** | 28.0.0.0 | Confirmed against the same manifest. Also confirms the downloaded Base Application is the **US**-localized build (`Brief="Base Application (US)"`), matching our Localization parameter. |
| **Symbol Source** | `.alpackages/` in project root — **CORRECTED, see note** | `.alpackages/` packages are real and fully usable. The earlier "unusable stub" conclusion (logged here through most of Step 2 and early Step 4) was **wrong, and caused by my own inspection method**, not a problem with the packages: I was parsing `SymbolReference.json` directly (via `unzip`/Python `zipfile`), which for this Base Application package only lists ~13 incidental objects — apparently a curated/partial subset, not the full compilable symbol surface. The package also embeds the full AL source (8,579 files under `src/`, since `app.json`'s `includeSourceInSymbolFile: true`), and the real compiler resolves against that correctly. Discovered 2026-09-15 during Step 4 when a real `alc` compile of Batch 1 succeeded cleanly, then a deliberately-invalid field reference was correctly rejected (AL0280/AL0118), proving genuine symbol resolution is working. See `ChangeLog.md` for the full correction entry, including the downstream fix this required in `DesignDoc.md`'s posting codeunit (the MS-Learn-sourced event names it had recorded, `OnAfterInsertInvHeader`/`OnAfterInsertCrMemoHeader`, don't exist either — real names are `OnBeforeSalesInvHeaderInsert`/`OnBeforeSalesCrMemoHeaderInsert`, confirmed against the real embedded source and compiled successfully). |
| **Compile tooling** | Microsoft's `al` .NET tool, already installed as a dotnet global tool at `~/.dotnet/tools/al` (version 18.0.41, matching the AL extension) | Works when invoked with `DOTNET_ROOT=~/.dotnet` set inline (its own apphost can't locate the runtime without it — a per-invocation environment variable I set myself each time, never asked of the human, consistent with Rule 6d). Usage: `DOTNET_ROOT=~/.dotnet ~/.dotnet/tools/al compile -- /project:. /packagecachepath:.alpackages /outfolder:outputAppPackage`. This satisfies Operating Rule 4's mandatory compile — no VS Code or MCP bridge dependency needed for it. The AL MCP Bridge (`.mcp.json`, `al-mcp-bridge` entry) and a second, self-registered stdio MCP server (`.mcp.json`, `al` entry, using `al launchmcpserver`) are also configured for richer tooling (symbol search, diagnostics) once this session picks up the updated `.mcp.json` (requires a session restart). |
| **Onboarding — Assisted Setup Wizard?** | No | |
| **Onboarding — Role Center Activity Cues?** | No | |
| **Onboarding — Departments/"My Business Central" placement?** | Yes | |
| **Framework files in `.gitignore`?** | Yes | This runbook (`CLAUDE.md`), `LITE_RunbookChangeLog.md`, `LITE_RunbookSchematics.md`, `.ocpf/` (if present) excluded from this project's git tracking. `ChangeLog.md` (the project's own) is always tracked, never gitignored. |
| **Working language** | English | |
| **Target languages** | English (en-US) only, required at first release. No additional languages. | |
| **Source language** | en-US | |
| **Source wording** | W1 (Microsoft's standard English wording in source) + en-US translation file | Standard pattern, chosen over the "US wording only, no translation files" simplification (2026-09-15) |
| **Documents in other languages** | N/A — English only | |
| **Customer-language documents / translatable data** | No | NAICS Code/Description must be *visible* (English) on Quote/Invoice pages — not rendered in multiple languages. Clarified 2026-09-15 after an initially ambiguous answer (see `ProblemStatement.md`). No NAICS Code Translation table needed. |

## Quoting reference (applies everywhere)

`app.json`/`launch.json` use standard JSON strings; AL string property values use single quotes
(`APIPublisher = 'Contoso';`); AL object names use double quotes
(`page 90800 "acmeCustomers"`); BC field names with spaces use double quotes
(`Rec."Document No."`).

## Packages

All built `.app` packages land in **`outputAppPackage/`** in the project root — never `out/` or
`output/`. Named `<ExtensionName, spaces→underscores>_<version>.app`, read from `app.json` at
build time.

## Outstanding blocker — RESOLVED (2026-09-15, during Step 4)

**No blocker remains.** What was logged here through Step 2 and early Step 4 as an unusable
symbol package was a false alarm caused by my own flawed inspection method, not a real problem —
see the Symbol Source row above and `ChangeLog.md` Issue 1 for the full account. Real symbol
verification is now the standard (not the fallback) for the remainder of this project, using the
compile tooling documented above. `DesignDoc.md`'s MS-Learn-verified reference table has been
spot-corrected where the fallback data was wrong (the posting codeunit's event names); every
object still needs its standard-reference row re-confirmed by an actual compile as it's
generated in Batch 2, same as Batch 1 already was.
