# Pre-flight Checklist — NAICS Classification

Run both passes on every object during Step 4, before moving to the next object (Operating Rule
4). One model does both passes (no separate reviewer role in Lite).

## Pass 1 — Pre-generation (on the planned name/fields, from `DesignDoc.md`)

- [ ] Identifier length ≤ 30 characters for every field/control identifier.
- [ ] No reserved AL keyword used as an identifier without a type suffix (Standards §4.3).
- [ ] Localization field-range filter: N/A for this project — every field is new, not an exposed
      base-app field (see `DesignDoc.md` self-check).
- [ ] `ObsoleteState` filter: N/A — no obsolete base-app field/procedure references anywhere in
      this design.
- [ ] Object ID is inside 60470–60499 and matches the `DesignDoc.md` allocation table exactly.
- [ ] `using` namespace matches the MS-Learn-verified table in `DesignDoc.md`.

## Pass 2 — Post-generation (on the actual written file)

- [ ] `Caption` present on the object/field.
- [ ] `ToolTip` present on every field control (not generic — field-specific, per Standards §2.6).
- [ ] Any page with `UsageCategory` also sets `ApplicationArea = All` **at page level** — without
      it the page compiles clean but never appears in BC search (Issue 6).
- [ ] `ApplicationArea = All` on every **page** field control, no exceptions. **`ApplicationArea`
      is a page-control property only — never set it on a `table`/`tableextension` field
      definition** (AL0124 at compile; caught in Batch 1 on 2026-09-15, fixed on
      `"ocpf NAICS Code"` and `"ocpf Customer Ext"`; apply this correction to every table/
      tableextension in Batch 2 as well — `"ocpf Sales Header Ext"`,
      `"ocpf Sales Invoice Header Ext"`, `"ocpf Sales Cr Memo Header Ext"`).
- [ ] **No ML properties, no `TextConst`** anywhere — `CaptionML`, `ToolTipML`,
      `OptionCaptionML`, or any other `…ML` variant is a finding. Single-language `Caption`/
      `ToolTip`/`Label` only (Standards §1.7).
- [ ] Translatable text: no string literals in `Error`/`Message`/`Confirm`/`StrMenu`/
      notifications. This project has exactly one custom `Label`
      (`DeleteBlockedErr`, on `"ocpf NAICS Code"`'s `OnDelete` trigger) — confirm it carries the
      `Err` suffix (Standards §8.3) and no other literal error text exists anywhere.
- [ ] API caption locking: N/A — no API pages/queries in this project.
- [ ] `Rec.`-qualification everywhere (`NoImplicitWith` is enabled — no implicit `WITH`).
- [ ] Dead-code check: no empty triggers, no `// TODO`, no commented-out fields (Standards §1.5).
- [ ] 4-space indentation, no tabs (Standards §1.6).
- [ ] Permission-set `tabledata` coverage: only `"ocpf NAICS Code"` needs a grant (the only table
      this extension owns) — confirm both `"OCPF NAICS - READ"` and `"OCPF NAICS - RW"` cover it
      before moving past the object that introduces the table (Batch 1).
- [ ] **Symbol verification** for every standard/base reference — table numbers, field names,
      `using` namespaces, enum values, event names/signatures — against ground truth. Real
      symbols in `.alpackages/` are usable (corrected 2026-09-15, see `ProjectParameters.md`
      Outstanding Blocker) — the actual compile (`DOTNET_ROOT=~/.dotnet ~/.dotnet/tools/al
      compile -- /project:. /packagecachepath:.alpackages /outfolder:outputAppPackage`) is the
      real verification, not a stand-in for it. Compile after generating each object (or small
      group of related objects) rather than waiting for the whole batch, so a bad reference is
      caught immediately against the object that introduced it, same as Batch 1's ApplicationArea
      and posting-event-name corrections were.

## Batch-sequencing note — table 60470's `OnDelete` trigger

`DesignDoc.md` specifies `"ocpf NAICS Code"`'s deletion check against all four referencing tables
(Customer, Sales Header, Sales Invoice Header, Sales Cr.Memo Header). Since each batch must
compile standalone (Batch 1's own Step 5 cycle happens before Batch 2 is generated), and only
Customer's `"NAICS Code"` field exists during Batch 1, the trigger is completed in two passes:

- **Batch 1**: `OnDelete` checks Customer only.
- **Batch 2**: when `"ocpf Sales Header Ext"`, `"ocpf Sales Invoice Header Ext"`, and
  `"ocpf Sales Cr Memo Header Ext"` are generated, **edit table 60470** (not a new object) to add
  the remaining three checks to the same trigger.

This is a batching-driven implementation sequence, not a deviation from `DesignDoc.md` — the end
state after Batch 2 matches the design exactly. Not logged in `ChangeLog.md` (nothing to log
against — no rule changed, no design assumption was wrong).

## Batch-specific notes

- **Batch 1 (Setup & Master Data)**: generate in this order — `"ocpf NAICS Code"` (table) →
  `"ocpf NAICS Code List"` → `"ocpf NAICS Code Card"` → `"ocpf Customer Ext"` →
  `"ocpf Customer Card Ext"` → `"ocpf Customer List Ext"` → `"OCPF NAICS - READ"` →
  `"OCPF NAICS - RW"` (permission sets last, since they reference the table/pages generated
  earlier in the batch).
- **Batch 2 (Documents)**: generate in this order — `"ocpf Sales Header Ext"` (introduces the
  field the six document page extensions and the posting codeunit all depend on) → the six
  document page extensions (Quote, Order, Invoice, Credit Memo, Return Order, Blanket Order, any
  order among themselves) → `"ocpf Sales Invoice Header Ext"` → `"ocpf Sales Cr Memo Header Ext"`
  → `"ocpf Posted Sales Invoice Ext"` → `"ocpf Posted Sales CrMemo Ext"` →
  `"ocpf Sales Post Subscribers"` (codeunit last, since it references fields on four other
  objects generated earlier).
