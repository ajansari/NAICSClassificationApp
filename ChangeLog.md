# ChangeLog — NAICS Classification

## Process Note 1 — Sandbox testing deferred past Step 5

**Problem/context:** The Lite runbook's Step 5 exit gate calls for sandbox testing confirmed
clean before Step 6 begins. The human explicitly chose to skip ahead to Batch 2 generation before
Batch 1 was sandbox-tested (2026-09-15), and then, once both batches compiled clean, explicitly
chose to move into Step 6 before any sandbox testing happened at all (2026-09-15) — deferring
testing to Step 7's `TestScript.md` run instead.

**Resolution:** Not a design deviation — no rule changed, nothing in `DesignDoc.md` is
incorrect as a result. Logged here per Operating Rule 7 as a process-sequencing deviation from the
runbook's normal step order, made explicitly and knowingly by the human. Step 7's exit gate (all
green-team tests pass, all red-team tests fail gracefully) still applies in full — this doesn't
relax that bar, it just moves the first real test run later than the runbook's default sequence.

**Files affected:** none (process note only).

**Design Doc updated:** no.

---

## Issue 1 — Symbol packages wrongly diagnosed as unusable

**Problem:** During Step 1, I inspected `.alpackages/Microsoft_Base Application_*.app` by
extracting and parsing its `SymbolReference.json` (via `unzip`, then re-verified via Python's
`zipfile`). That file listed only ~13 incidental tables (no Customer, Sales Header, etc.) and
similarly near-empty content for System Application/System/Business Foundation/Application. I
concluded the downloaded symbol packages were broken stubs, had the human redownload them via
VS Code (producing byte-identical content, seemingly confirming the diagnosis), and had Step 2's
entire Design Doc proceed under Operating Rule 2's MS Learn fallback instead of real symbol
verification — a real cost: extra round-trips with the human, a design doc caveated throughout,
and one further bug (Issue 2) that the fallback source introduced.

**Root cause:** `SymbolReference.json` for this package apparently reflects only a small curated
subset of the Base Application's real object surface, not the full compilable symbol set. The
package's actual compile-time content includes the complete embedded AL source (8,579 files under
`src/`, present because `app.json`'s `resourceExposurePolicy.includeSourceInSymbolFile` is
`true`), which I never inspected — I treated `SymbolReference.json` as authoritative when it
wasn't the right artifact to answer "are these symbols usable" in the first place. The real
compiler (`alc`) resolves against the full package correctly; I discovered this only when I
found a working compile toolchain (Microsoft's `al` .NET tool, already installed at
`~/.dotnet/tools/al`) during Step 4 and ran an actual compile, which succeeded cleanly, then
correctly rejected a deliberately-invalid field reference — proving real symbol resolution was
working all along.

**Resolution:** Retracted the "unusable symbols" conclusion. `ProjectParameters.md`'s Outstanding
Blocker section rewritten to document the correction and the working compile toolchain
(`DOTNET_ROOT=~/.dotnet ~/.dotnet/tools/al compile -- /project:. /packagecachepath:.alpackages
/outfolder:outputAppPackage`). Real symbol verification (an actual compile) is now the standard
practice for the rest of this project, not a fallback — `PreflightChecklist.md` updated
accordingly. Lesson applied going forward: verify tooling claims ("these symbols don't work") by
testing the actual mechanism that matters (compilation) rather than by inspecting an adjacent
artifact and assuming it's representative.

**Files affected:** `ProjectParameters.md`, `PreflightChecklist.md`.

**Design Doc updated:** yes (reference-table framing corrected; see Issue 2 for the specific
content fix this enabled).

---

## Issue 2 — Posting event names in the Design Doc were fabricated

**Problem:** `DesignDoc.md`'s Codeunit 60487 design (Step 2, under the Issue 1 fallback) recorded
event names `OnAfterInsertInvHeader`/`OnAfterInsertCrMemoHeader` on `Codeunit 80 "Sales-Post"`,
sourced from a WebFetch-summarized read of the MS Learn codeunit reference page. Neither event
exists. Compiling a test subscriber against them failed with AL0280 ("event ... is not found").

**Root cause:** The MS Learn fallback research for this specific fact was unreliable — the
WebFetch tool's AI-summarization step appears to have inferred plausible-sounding event names
(matching the general shape BC posting events take) rather than reporting names actually present
on the page, and I did not independently verify them before writing them into `DesignDoc.md`
alongside a fabricated implementation-detail justification ("no `.Modify()` needed... since the
caller inserts after this event") that happened to sound reasonable but was invented, not
observed.

**Resolution:** Once real symbol access was confirmed (Issue 1), read the actual embedded source
(`src/Sales/Posting/SalesPost.Codeunit.al` inside the Base Application package) directly. The
real events are `OnBeforeSalesInvHeaderInsert`/`OnBeforeSalesCrMemoHeaderInsert` — which fire
*before* the record is inserted, an actually-better hook than the fabricated after-events would
have been (no `.Modify()` call needed, genuinely, because the record isn't inserted yet). Also
required a `using Microsoft.Warehouse.Document;` directive for two parameter types
(`"Warehouse Shipment Header"`, `"Warehouse Receipt Header"`) that appear in the real signatures
but weren't part of the fabricated ones. Verified by a successful compile against real symbols
before committing the fix. `DesignDoc.md`'s Codeunit 60487 section, reference table, and `using`
directives table all corrected.

**Files affected:** `DesignDoc.md`.

**Design Doc updated:** yes.

---

## Issue 3 — `ApplicationArea` incorrectly placed on table/tableextension fields

**Problem:** Batch 1's first compile (table `"ocpf NAICS Code"` and `"ocpf Customer Ext"`) failed
with 5× AL0124 ("The property 'ApplicationArea' cannot be used in this context").

**Root cause:** `ApplicationArea` is a page-control property. I applied the Standards Guide's
general rule ("`Caption`, `ToolTip`, `ApplicationArea = All` on every field, no exceptions") too
literally to `table`/`tableextension` field *definitions*, when the rule (and the Standards
Guide's own template, Standards §1.3) means it for page field *controls*. `DesignDoc.md`'s
per-object code samples for `"ocpf Customer Ext"`, `"ocpf Sales Header Ext"`, and
`"ocpf Sales Invoice Header Ext"` had the same mistake baked in from Step 2.

**Resolution:** Removed `ApplicationArea = All;` from every table/tableextension field in the
generated code (`NAICSCode.Table.al`, `CustomerExt.TableExt.al`) and from the three affected
code samples in `DesignDoc.md`. `PreflightChecklist.md`'s post-generation pass updated with an
explicit rule and a pointer to the two Batch 2 table extensions (`"ocpf Sales Header Ext"`,
`"ocpf Sales Invoice Header Ext"`, `"ocpf Sales Cr Memo Header Ext"`) that must not repeat it —
fixing the rule, not just the file, per Operating Rule 4. Recompiled clean (0 errors, 0
warnings) after the fix.

**Files affected:** `src/Table/NAICSCode.Table.al`, `src/TableExtension/CustomerExt.TableExt.al`,
`DesignDoc.md`, `PreflightChecklist.md`.

**Design Doc updated:** yes.

---

## Issue 4 — Object identifier exceeded the 30-character limit

**Problem:** Batch 2's compile failed with AL0305 on `pageextension 60486`: the object name
`"ocpf Posted Sales Credit Memo Ext"` is 34 characters, over AL's 30-character identifier limit.

**Root cause:** `DesignDoc.md`'s Step 2 self-check explicitly checked "all entity/field names ≤
30 characters" but only spot-checked a couple of examples (`naicsCode`, `parentCode`) rather than
counting every object name — this one was missed. Standards §4.2's abbreviation table (which
lists `Credit Memo` → `CrMemo`) exists exactly for cases like this and wasn't applied here at
design time.

**Resolution:** Renamed to `"ocpf Posted Sales CrMemo Ext"` (28 characters), applying the
Standards-listed abbreviation. Updated `DesignDoc.md`'s object ID table and
`PreflightChecklist.md`'s Batch 2 generation-order note to match. Recompiled clean.

**Files affected:** `src/PageExtension/PostedSalesCreditMemoExt.PageExt.al`, `DesignDoc.md`,
`PreflightChecklist.md`.

**Design Doc updated:** yes.

---

## Deferred 1 — NAICS Code `OnDelete` does not check self-referencing `Parent Code`

**Problem:** `DesignDoc.md`'s deletion-behavior decision for `"ocpf NAICS Code"` (block-if-
referenced) checks four tables — Customer, Sales Header, Sales Invoice Header, Sales Cr.Memo
Header — but not the table's own `Parent Code` field. Deleting a code that other NAICS Code
records reference as their `Parent Code` succeeds, leaving those child records' `Parent Code`
pointing at a no-longer-existing value (an orphaned reference — `TableRelation` only validates on
insert/update of the referencing field, not on deletion of the referenced row).

**Resolution:** Deferred, not fixed — this is a genuine open design question, not an oversight
with an obvious right answer: does an orphaned `Parent Code` matter enough to block deletion
over, given it's an informational hierarchy link rather than a value used in any calculation or
posting? Surfaced explicitly in `TestScript.md` (Red-team item 17) for the human to test and
decide at Step 7, rather than making that call unilaterally during Step 6.

**Files affected:** none (design decision pending).

**Design Doc updated:** no — pending the Step 7 decision.
