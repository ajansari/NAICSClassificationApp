# Design Doc — NAICS Classification

> Self-sufficient design document per the Lite framework Step 2. Anyone who has never seen this
> project should be able to produce every object correctly from this document alone, combined
> with `ProjectParameters.md` and `standardsGuide/ocpfALDevStandardsGuide.md`.

---

## Part A — What & Why

### Purpose

Add a maintainable NAICS (North American Industry Classification System) code list to Business
Central, let a NAICS code be assigned to a Customer, and carry that code from the customer
through the sales document lifecycle — quote through posted invoice/credit memo — for reporting
and analysis.

### Scope

See `ProblemStatement.md` for the full scope statement, the explicitly out-of-scope items, and
the intake decisions behind them. Summary of in-scope work:

1. New **NAICS Code** table + List + Card pages.
2. **NAICS Code** field on Customer (pickable), shown on Customer Card and Customer List.
3. **NAICS Code** field on Sales Header (covers Quote, Order, Invoice, Credit Memo, Blanket Order,
   Return Order), auto-defaulted from the customer, overridable per document.
4. **NAICS Code** field on the posted financial documents: Sales Invoice Header and Sales
   Cr.Memo Header, populated at posting time via event subscribers.
5. Read and Read/Write permission sets.

### Platform requirements

- BC Application minimum: `28.0.0.0` (current `app.json` value — pending re-confirmation; see
  `ProjectParameters.md` Outstanding Blocker).
- AL runtime: `17.0` (current `app.json` value — same caveat).
- Deployment Target: **SaaS PTE**.

### Entity/object inventory (Read vs. Read/Write)

Set per Standards §2.2 (master data and open documents editable; posted entries read-only):

| # | Object | Source table | R/W |
|---|---|---|---|
| 1 | NAICS Code | new table | Read/Write (master data) |
| 2 | NAICS Code List | new table | Read/Write |
| 3 | NAICS Code Card | new table | Read/Write |
| 4 | Customer (ext.) | Customer (18) | Read/Write (master data) |
| 5 | Customer Card (ext.) | Customer (18) | Read/Write |
| 6 | Customer List (ext.) | Customer (18) | Read/Write |
| 7 | Sales Header (ext.) | Sales Header (36) | Read/Write (open document) |
| 8–13 | Sales Quote/Order/Invoice/Credit Memo/Return Order/Blanket Order (ext.) | Sales Header (36) | Read/Write |
| 14 | Sales Invoice Header (ext.) | Sales Invoice Header (112) | **Read-only** (posted entry) |
| 15 | Posted Sales Invoice (ext.) | Sales Invoice Header (112) | Read-only |
| 16 | Sales Cr.Memo Header (ext.) | Sales Cr.Memo Header (114) | **Read-only** (posted entry) |
| 17 | Posted Sales Credit Memo (ext.) | Sales Cr.Memo Header (114) | Read-only |
| 18 | Sales Post Subscribers | Codeunit 80 "Sales-Post" (event subscribers, no UI) | N/A |
| 19 | Read permission set | — | — |
| 20 | Read/Write permission set | — | — |

### Non-functional requirements

- Zero compile errors/warnings before PROVE (Operating Rule 5).
- No performance-sensitive logic — all triggers are single-record lookups/copies, no loops over
  large sets.
- Compliance: no PII/sensitive data introduced beyond what Customer/Sales tables already carry;
  NAICS Code and Description are public classification data (`DataClassification = CustomerContent`
  to match the pattern used by the base Customer/Sales tables' comparable fields).

### Languages and markets

- Localization: **US**. Working language: English. Target language at first release: **en-US
  only**. Source wording: **W1** + `en-US` translation file (per `ProjectParameters.md`).
- No customer-language document requirement — NAICS Code/Description are visible in English only
  on Quote/Invoice pages (resolved ambiguity, see `ProblemStatement.md`).
- No translatable data beyond standard AL `Caption`/`ToolTip`/`Label` properties, which the `.g.xlf`
  build step exports automatically. No custom translation table is needed.

---

## Part B — How

### System identity (from `ProjectParameters.md` — do not restate elsewhere, do not hardcode)

| Parameter | Value |
|---|---|
| Publisher | OnlyCopilotFans |
| Namespace | `OnlyCopilotFans.NAICSClassification` |
| AL Object Prefix | `ocpf` |
| Permission Set Prefix | `OCPF - ` |
| Object ID range | 60470–60499 (Primary; no Additional) |
| AL Runtime / BC Application Minimum | 17.0 / 28.0.0.0 (pending re-confirmation) |
| Symbol Source | MS Learn Base Application docs (Operating Rule 2 fallback — see blocker note) |

**Object ID allocation** (sequential; 20 objects, 60470–60489; buffer 60490–60499 = 10 IDs
unallocated, meeting Standards §5.2's "up to 50 objects → 10 IDs reserved" minimum):

| ID | Object | AL type |
|---|---|---|
| 60470 | `"ocpf NAICS Code"` | table |
| 60471 | `"ocpf NAICS Code List"` | page |
| 60472 | `"ocpf NAICS Code Card"` | page |
| 60473 | `"ocpf Customer Ext"` | tableextension (extends `Customer`, table 18) |
| 60474 | `"ocpf Sales Header Ext"` | tableextension (extends `"Sales Header"`, table 36) |
| 60475 | `"ocpf Sales Invoice Header Ext"` | tableextension (extends `"Sales Invoice Header"`, table 112) |
| 60476 | `"ocpf Sales Cr Memo Header Ext"` | tableextension (extends `"Sales Cr.Memo Header"`, table 114) |
| 60477 | `"ocpf Customer Card Ext"` | pageextension (extends `"Customer Card"`) |
| 60478 | `"ocpf Customer List Ext"` | pageextension (extends `"Customer List"`) |
| 60479 | `"ocpf Sales Quote Ext"` | pageextension (extends `"Sales Quote"`) |
| 60480 | `"ocpf Sales Order Ext"` | pageextension (extends `"Sales Order"`) |
| 60481 | `"ocpf Sales Invoice Ext"` | pageextension (extends `"Sales Invoice"`) |
| 60482 | `"ocpf Sales Credit Memo Ext"` | pageextension (extends `"Sales Credit Memo"`) |
| 60483 | `"ocpf Sales Return Order Ext"` | pageextension (extends `"Sales Return Order"`) |
| 60484 | `"ocpf Blanket Sales Order Ext"` | pageextension (extends `"Blanket Sales Order"`) |
| 60485 | `"ocpf Posted Sales Invoice Ext"` | pageextension (extends `"Posted Sales Invoice"`) |
| 60486 | `"ocpf Posted Sales CrMemo Ext"` | pageextension (extends `"Posted Sales Credit Memo"`) — `Credit Memo` → `CrMemo` (Standards §4.2), full name is 34 chars, over the 30-char limit |
| 60487 | `"ocpf Sales Post Subscribers"` | codeunit |
| 60488 | `"OCPF - READ"` | permissionset |
| 60489 | `"OCPF - READ/WRITE"` | permissionset |

### Standard object reference table

*(Originally sourced via the Operating Rule 2 MS Learn fallback; **corrected and now confirmed
against real downloaded symbols** as of Step 4 — see `ProjectParameters.md`'s Outstanding
Blocker section for the full account of why the fallback was used and then found unnecessary.
The `Sales-Post` event names row below was wrong in the MS-Learn version and has been corrected
to the real event names, verified by an actual successful compile.)*

| Object | Type | ID | Namespace |
|---|---|---|---|
| Customer | table | 18 | `Microsoft.Sales.Customer` |
| Customer Card | page | (not captured — page extensions reference by name, not ID) | `Microsoft.Sales.Customer` |
| Customer List | page | — | `Microsoft.Sales.Customer` |
| Sales Header | table | 36 | `Microsoft.Sales.Document` |
| "Sales Document Type" | enum | 36 | `Microsoft.Sales.Document` — values: `Quote`, `Order`, `Invoice`, `"Credit Memo"`, `"Blanket Order"`, `"Return Order"` |
| Sales Quote | page | — | `Microsoft.Sales.Document` |
| Sales Order | page | — | `Microsoft.Sales.Document` |
| Sales Invoice | page | — | `Microsoft.Sales.Document` |
| Sales Credit Memo | page | — | `Microsoft.Sales.Document` |
| Sales Return Order | page | — | `Microsoft.Sales.Document` |
| Blanket Sales Order | page | — | `Microsoft.Sales.Document` |
| Sales Invoice Header | table | 112 | `Microsoft.Sales.History` |
| Sales Cr.Memo Header | table | 114 | `Microsoft.Sales.History` |
| Posted Sales Invoice | page | — | `Microsoft.Sales.History` |
| Posted Sales Credit Memo | page | — | `Microsoft.Sales.History` |
| Sales-Post | codeunit | 80 | `Microsoft.Sales.Posting` — real events (corrected 2026-09-15): `OnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; WhseShip: Boolean; WhseShptHeader: Record "Warehouse Shipment Header"; InvtPickPutaway: Boolean)`, `OnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesInvHeader: Record "Sales Invoice Header")` |

**Gap check corroboration:** see `ProblemStatement.md`'s Quick Gap Check for the full, corrected
analysis — BC's `Industry Group`/`Contact Industry Group` tables (5057/5058) were found and
deliberately rejected as a substitute (wrong association target, wrong cardinality, no hierarchy,
free-form not NAICS-standard). "NAICS" and "SIC" have no matches anywhere in the real source. No
standard BC table exists to reuse instead of a new one.

---

### Per-object spec

#### 1. Table 60470 `"ocpf NAICS Code"`

```
namespace OnlyCopilotFans.NAICSClassification;

table 60470 "ocpf NAICS Code"
{
    Caption = 'NAICS Code';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf NAICS Code List";
    DrillDownPageId = "ocpf NAICS Code List";

    fields { ... see Per-field spec ... }
    keys
    {
        key(PK; Code) { Clustered = true; }
    }
}
```

- `PageType` N/A (table). Not an API object — `APIGroup`/`ODataKeyFields`/`DelayedInsert` do not
  apply.
- **Deletion behavior:** **block-if-referenced.** `OnDelete` trigger checks Customer, Sales
  Header, Sales Invoice Header, and Sales Cr.Memo Header for any record where `"NAICS Code" =
  Rec.Code`; raises `DeleteBlockedErr` if any exist. (These are the four tables this extension
  adds the field to — an intentional, closed check list, not a generic search.)
- **Computed-field pattern:** `Level` is a **stored** field, seeded by `OnValidate(Code)` —
  `Rec.Level := StrLen(Rec.Code);` — not a FlowField (there is nothing to aggregate; it's a
  same-record derivation). Editable = false on both pages.

#### 2. Page 60471 `"ocpf NAICS Code List"`

- `PageType = List`; `SourceTable = "ocpf NAICS Code"`; `Editable = true` (master data).
- `ApplicationArea = All` on every field; `UsageCategory = Lists`; `AdditionalSearchTerms` not
  required.
- **Departments placement** (Step 1 onboarding decision): `promoted` action group not required;
  add this page's entry point under **Departments → Sales → NAICS Classification** navigation
  group per Standards' general navigation guidance (no Standards-specific rule beyond standard AL
  `Navigate` menu-suite entries — implemented via the page's own `UsageCategory = Lists` plus
  a `Card`/`List` link surfaced by BC's standard Departments aggregation, which auto-populates
  from `UsageCategory`; no separate object needed).

#### 3. Page 60472 `"ocpf NAICS Code Card"`

- `PageType = Card`; `SourceTable = "ocpf NAICS Code"`; `Editable = true`.
- Not an API page — `ODataKeyFields`/`DelayedInsert` do not apply. Uses standard card layout.

#### 4. Tableextension 60473 `"ocpf Customer Ext"` extends `Customer`

```al
namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Customer;

tableextension 60473 "ocpf Customer Ext" extends Customer
{
    fields
    {
        field(60473; "NAICS Code"; Code[6])
        {
            Caption = 'NAICS Code';
            ToolTip = 'Specifies the NAICS (North American Industry Classification System) code assigned to this customer.';
            DataClassification = CustomerContent;
            TableRelation = "ocpf NAICS Code".Code;
        }
    }
}
```

No `OnValidate` needed here — this is the source field the sales-document default reads from; no
downstream logic on Customer itself.

#### 5. Tableextension 60474 `"ocpf Sales Header Ext"` extends `"Sales Header"`

```al
namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;

tableextension 60474 "ocpf Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(60474; "NAICS Code"; Code[6])
        {
            Caption = 'NAICS Code';
            ToolTip = 'Specifies the NAICS code carried from the customer. Defaults when the customer is selected and can be changed on this document.';
            DataClassification = CustomerContent;
            TableRelation = "ocpf NAICS Code".Code;
        }

        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get(Rec."Sell-to Customer No.") then
                    Rec.Validate("NAICS Code", Customer."NAICS Code")
                else
                    Rec.Validate("NAICS Code", '');
            end;
        }
    }
}
```

- **Computed-field pattern:** stored field, **defaulted, overridable** (human decision,
  2026-09-15). Re-selecting `"Sell-to Customer No."` re-defaults the field, matching how BC
  natively re-defaults comparable inherited fields (e.g. `"Customer Price Group"`,
  `"Salesperson Code"`) on that same trigger — this is the standard BC pattern, not a deviation
  from it. Manual edits the user makes to `"NAICS Code"` after that persist until the customer is
  changed again.
- Applies uniformly across all six document types sharing this table (`Document Type` = Quote,
  Order, Invoice, Credit Memo, Blanket Order, Return Order) — no `SourceTableView` filter needed
  since the field and its behavior don't vary by document type.

#### 6. Tableextension 60475 `"ocpf Sales Invoice Header Ext"` extends `"Sales Invoice Header"`

```al
namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.History;

tableextension 60475 "ocpf Sales Invoice Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(60475; "NAICS Code"; Code[6])
        {
            Caption = 'NAICS Code';
            ToolTip = 'Specifies the NAICS code that was recorded on the sales document at the time of posting.';
            DataClassification = CustomerContent;
            TableRelation = "ocpf NAICS Code".Code;
            Editable = false;
        }
    }
}
```

- Read-only (posted entry, Standards §2.2). Populated by the `"ocpf Sales Post Subscribers"`
  codeunit (object 18 below) — never set interactively.

#### 7. Tableextension 60476 `"ocpf Sales Cr Memo Header Ext"` extends `"Sales Cr.Memo Header"`

Same shape as #6, field ID 60476, `Editable = false`, same `ToolTip`, extends
`"Sales Cr.Memo Header"` (`using Microsoft.Sales.History;`).

#### 8. Pageextension 60477 `"ocpf Customer Card Ext"` extends `"Customer Card"`

```al
namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Customer;

pageextension 60477 "ocpf Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter("Customer Posting Group")
        {
            field(naicsCode; Rec."NAICS Code")
            {
                Caption = 'NAICS Code';
                ToolTip = 'Specifies the NAICS code assigned to this customer.';
                ApplicationArea = All;
            }
        }
    }
}
```

(`addafter` anchor field to be confirmed against the real Customer Card layout once symbols are
available — `"Customer Posting Group"` is a stable, commonly-present field on that page; flagged
for Step 4 pre-flight re-check.)

#### 9. Pageextension 60478 `"ocpf Customer List Ext"` extends `"Customer List"`

```al
pageextension 60478 "ocpf Customer List Ext" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field(naicsCode; Rec."NAICS Code")
            {
                Caption = 'NAICS Code';
                ToolTip = 'Specifies the NAICS code assigned to this customer.';
                ApplicationArea = All;
            }
        }
    }
}
```

#### 10–15. Pageextensions 60479–60484 (Sales Quote/Order/Invoice/Credit Memo/Return Order/Blanket
Order) and 60485–60486 (Posted Sales Invoice/Credit Memo)

All six pre-posting document pageextensions follow the same shape (add the field to the document
header `General` FastTab):

```al
namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Document;

pageextension 60479 "ocpf Sales Quote Ext" extends "Sales Quote"
{
    layout
    {
        addafter("Salesperson Code")
        {
            field(naicsCode; Rec."NAICS Code")
            {
                Caption = 'NAICS Code';
                ToolTip = 'Specifies the NAICS code carried from the customer. Defaults when the customer is selected and can be changed on this document.';
                ApplicationArea = All;
            }
        }
    }
}
```

Repeat identically for 60480 (`"Sales Order"`), 60481 (`"Sales Invoice"`), 60482 (`"Sales Credit
Memo"`), 60483 (`"Sales Return Order"`), 60484 (`"Blanket Sales Order"`) — object name, ID, and
`extends` target change; field control and `ToolTip` are identical since the underlying field is
the same `"Sales Header"."NAICS Code"` in every case. `"Salesperson Code"` is the anchor field
(present on all six document pages); confirm per-page at Step 4 pre-flight.

Posted pages (`Editable = false`, matching the source field):

```al
namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.History;

pageextension 60485 "ocpf Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Salesperson Code")
        {
            field(naicsCode; Rec."NAICS Code")
            {
                Caption = 'NAICS Code';
                ToolTip = 'Specifies the NAICS code that was recorded on the sales document at the time of posting.';
                ApplicationArea = All;
            }
        }
    }
}
```

Repeat for 60486 (`"Posted Sales Credit Memo"`, extends `"Sales Cr.Memo Header"`'s field).

#### 16. Codeunit 60487 `"ocpf Sales Post Subscribers"`

**Correction (2026-09-15, Step 4):** the events originally recorded here from the MS Learn
fallback (`OnAfterInsertInvHeader`/`OnAfterInsertCrMemoHeader`) do not exist — confirmed by
compiling a test subscriber against them, which failed with AL0280 ("event ... is not found").
Real symbol access turned out to be available after all (see the correction note in
`ProjectParameters.md`'s Outstanding Blocker section); reading the actual embedded Base
Application source (`src/Sales/Posting/SalesPost.Codeunit.al`, `Codeunit 80 "Sales-Post"`) gives
the real events: `OnBeforeSalesInvHeaderInsert` and `OnBeforeSalesCrMemoHeaderInsert`. These fire
**before** `SalesInvHeader.Insert(true)` / `SalesCrMemoHeader.Insert(true)` — better than the
originally-assumed after-events, since setting the field here means it's captured by the initial
insert with no separate `.Modify()` call needed at all (not "not needed because the caller
handles it" — genuinely because the record isn't inserted yet at this point).

```al
namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Warehouse.Document;

codeunit 60487 "ocpf Sales Post Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; WhseShip: Boolean; WhseShptHeader: Record "Warehouse Shipment Header"; InvtPickPutaway: Boolean)
    begin
        SalesInvHeader."NAICS Code" := SalesHeader."NAICS Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesInvHeader: Record "Sales Invoice Header")
    begin
        SalesCrMemoHeader."NAICS Code" := SalesHeader."NAICS Code";
    end;
}
```

Full parameter lists are copied verbatim from the real event declarations — an `EventSubscriber`
signature must match the publisher's parameter count/types/`var`-ness exactly. No UI, no dead
code, no empty triggers — both procedures do exactly one field copy. **This has been compiled
successfully against the real downloaded symbols** (not just MS-Learn-verified) — see
`ProjectParameters.md`.

#### 17. Permission set 60488 `"OCPF - READ"`

```al
namespace OnlyCopilotFans.NAICSClassification;

permissionset 60488 "OCPF - READ"
{
    Caption = 'OCPF NAICS Classification - Read';
    Assignable = true;

    Permissions =
        tabledata "ocpf NAICS Code" = R,
        page "ocpf NAICS Code List" = X,
        page "ocpf NAICS Code Card" = X;
}
```

Only the NAICS Code table needs a `tabledata` grant — Customer/Sales Header/Sales Invoice
Header/Sales Cr.Memo Header are base tables this extension only adds fields to; their access is
governed by BC's own base permission sets (`D365 READ` / `D365 BUS FULL ACCESS`), not by this
extension's permission sets. Page extensions and table extensions attach to base pages/tables
already covered by those base sets — no separate `page X` grant needed for them.

#### 18. Permission set 60489 `"OCPF - READ/WRITE"`

```al
namespace OnlyCopilotFans.NAICSClassification;

permissionset 60489 "OCPF - READ/WRITE"
{
    Caption = 'OCPF NAICS Classification - Read/Write';
    Assignable = true;
    IncludedPermissionSets = "OCPF - READ";

    Permissions =
        tabledata "ocpf NAICS Code" = RIMD;
}
```

**Deployment note** (Standards §5.3): consumers also need base permissions —
read-only consumers: `OCPF - READ` + `D365 READ`; read/write consumers: `OCPF - READ/WRITE` +
`D365 BUS FULL ACCESS`.

---

### Per-field spec — Table 60470 `"ocpf NAICS Code"`

| Source/AL name | camelCase (control) | Type | Length | Caption | ToolTip | Notes |
|---|---|---|---|---|---|---|
| `Code` | `code` | Code | 6 | 'Code' | 'Specifies the NAICS code (2 to 6 digits).' | Primary key |
| `Description` | `description` | Text | 100 | 'Description' | 'Specifies the description of this NAICS classification.' | |
| `Level` | `level` | Integer | — | 'Level' | 'Specifies the number of digits in the code (2 = Sector through 6 = National Industry), derived automatically from Code.' | `Editable = false` on both pages; set via `OnValidate(Code)` |
| `"Parent Code"` | `parentCode` | Code | 6 | 'Parent Code' | 'Specifies the parent NAICS code one level up in the hierarchy. Blank for a 2-digit Sector code.' | `TableRelation = "ocpf NAICS Code".Code` |

No reserved-keyword collisions (§4.3). All identifiers well under 30 characters (§4.1). No
localization field-exclusion concerns — this is entirely new data, not exposed base-app fields.

### Per-field spec — added fields on standard tables

| Table | Field | camelCase (control) | Type | TableRelation | Editable |
|---|---|---|---|---|---|
| Customer (18) | `"NAICS Code"` | `naicsCode` | Code[6] | `"ocpf NAICS Code".Code` | Yes |
| Sales Header (36) | `"NAICS Code"` | `naicsCode` | Code[6] | `"ocpf NAICS Code".Code` | Yes |
| Sales Invoice Header (112) | `"NAICS Code"` | `naicsCode` | Code[6] | `"ocpf NAICS Code".Code` | **No** |
| Sales Cr.Memo Header (114) | `"NAICS Code"` | `naicsCode` | Code[6] | `"ocpf NAICS Code".Code` | **No** |

### `using` directives (per object, exact namespace from MS-Learn verification above)

| Object | `using` |
|---|---|
| NAICS Code table/pages | none needed (self-contained; no base-table references) |
| Customer Ext | `Microsoft.Sales.Customer` |
| Sales Header Ext | `Microsoft.Sales.Document`, `Microsoft.Sales.Customer` |
| Sales Invoice Header Ext | `Microsoft.Sales.History` |
| Sales Cr Memo Header Ext | `Microsoft.Sales.History` |
| Customer Card/List Ext | `Microsoft.Sales.Customer` |
| Sales Quote/Order/Invoice/Credit Memo/Return Order/Blanket Order Ext | `Microsoft.Sales.Document` |
| Posted Sales Invoice/Credit Memo Ext | `Microsoft.Sales.History` |
| Sales Post Subscribers | `Microsoft.Sales.Document`, `Microsoft.Sales.History`, `Microsoft.Sales.Posting`, `Microsoft.Warehouse.Document` |

`NoImplicitWith` is enforced project-wide (mandatory, not optional) — every field reference in
generated code is `Rec.field` or `Customer.field`, never implicit.

### Translatable text

Only one custom `Label` is needed in this entire project:

```al
DeleteBlockedErr: Label 'This NAICS Code is assigned to one or more records and cannot be deleted.';
```

No placeholders, so no `Comment` needed. Suffix `Err` per Standards §8.3. Not `Locked` — this is
user-facing text and should translate if a future language is added. Lives on table 60470's
`OnDelete` trigger.

All other text is standard AL `Caption`/`ToolTip` properties (single-language, per Standards
§1.7 — no `CaptionML`/`ToolTipML`/`TextConst` anywhere in this project). These export to
`.g.xlf` automatically at Step 5's full build; the `en-US` target file is synced and drafted per
the ALL ALONG translation cycle even though source and target wording are both English (per the
human's Step 1 choice of the standard W1 + en-US pattern over the "no translation files"
simplification).

**API caption locking:** N/A — no API pages or queries in this project (confirmed 2026-09-15).

### Special notes

- **Singletons:** none.
- **Header/line pairs:** none — NAICS Code applies at the document-header level only (customer
  classification, not per-line).
- **Naming conflicts:** none identified — `"NAICS Code"` does not collide with any existing field
  name on Customer, Sales Header, Sales Invoice Header, or Sales Cr.Memo Header (confirmed against
  the MS Learn field listings fetched during Step 2 verification).
- **Deletion behavior, every entity this extension touches:**
  - NAICS Code: **block-if-referenced** (see Table spec above) — checked against Customer, Sales
    Header, Sales Invoice Header, Sales Cr.Memo Header.
  - Customer, Sales Header, Sales Invoice Header, Sales Cr.Memo Header: **unchanged** from BC
    standard deletion behavior — this extension only adds a field, it does not alter these
    tables' own deletion rules. No *other* table references `"ocpf NAICS Code"` by
    `TableRelation` besides the four listed above.

---

## Self-check (Step 2 exit gate)

- [x] Every entity from Step 1's object list maps to an object here (1:1 — 20 objects both places,
      after the Step 2 discovery that a posting-event codeunit was needed; `ProblemStatement.md`
      updated to match).
- [x] Every object has a valid ID inside 60470–60499 (60470–60489 used, 60490–60499 buffer).
- [x] Every source table number is **symbol-verified by successful compile** (Customer 18, Sales
      Header 36, Sales Invoice Header 112, Sales Cr.Memo Header 114, Sales-Post codeunit 80) — see
      `ProjectParameters.md` Outstanding Blocker for the correction history (originally thought
      unusable due to a flawed inspection method on my part, resolved 2026-09-15).
- [x] No field complies-with-Localization concerns apply — no base-app fields are being exposed
      via API; all touched fields are new fields this extension adds itself.
- [x] Every `using` namespace is symbol-verified by successful compile (table above).
- [x] All entity/field names ≤ 30 characters (`naicsCode`, `parentCode`, longest control/identifier
      well under the limit).
- [x] Read vs. read/write designations match data mutability (posted headers read-only, everything
      else read/write) — see Entity Inventory table.
- [x] Permission sets fully enumerated — only `"ocpf NAICS Code"` needs a `tabledata` grant (the
      only table this extension owns); both sets specified above.
- [x] Every entity's deletion behavior explicitly decided (Special notes above) — not a template
      default.
- [x] Target language (en-US) has no named reviewer requirement beyond the working conventions
      already in place — single-language project, glossary not required (no non-English terms
      introduced). No regional-term glossary rows apply.
- [x] API page/query caption locking: N/A, no API objects.

**0 blocking issues.** Outstanding non-blocking item: real symbol re-verification, tracked in
`ProjectParameters.md` and re-raised at Step 5.

---

## Step 6 — As-Built Review (2026-09-15)

**Gap-check:** all 20 objects in `src/` match this document's Object ID Allocation table exactly
— same IDs (60470–60489), same names, same `extends` targets. No object planned but not built, no
object built but not planned. One design detail was completed in two passes across the two
batches (table 60470's `OnDelete` trigger — Batch 1 checked only Customer, Batch 2 added the
three Sales-table checks once those fields existed) — a batching-sequencing artifact, not a gap;
see `PreflightChecklist.md`'s batch-sequencing note.

**Deviations during BUILD**, all logged in `ChangeLog.md`:
- Issue 1: a symbol-package misdiagnosis (my own inspection error) that sent Step 2 through the
  MS Learn fallback unnecessarily — retracted, real symbols confirmed working.
- Issue 2: the MS-Learn-sourced posting-event names in this document's original Codeunit 60487
  design were fabricated and didn't exist — corrected to the real events
  (`OnBeforeSalesInvHeaderInsert`/`OnBeforeSalesCrMemoHeaderInsert`), verified by compile.
- Issue 3: `ApplicationArea` was incorrectly placed on table/tableextension fields in three
  code samples in this document (Step 2) and the corresponding generated files (Step 4) —
  removed; `ApplicationArea` is a page-control property only.
- Issue 4: `"ocpf Posted Sales Credit Memo Ext"` (34 characters) exceeded the 30-character
  identifier limit — renamed to `"ocpf Posted Sales CrMemo Ext"` (28 characters) using the
  Standards §4.2 `Credit Memo` → `CrMemo` abbreviation.
- Process Note 1: sandbox testing was deferred past Step 5 at the human's explicit direction —
  a process-sequencing choice, not a design deviation.

**Code review:** ran a full mechanical sweep (no ML properties/`TextConst`, no dead code/TODOs,
no tabs, consistent 4-space indentation, `Caption`/`ToolTip`/`ApplicationArea = All` present on
every page field, `Rec.`-qualification throughout — guaranteed by `NoImplicitWith` failing the
compile otherwise) plus a targeted pass against the BCQuality snapshot's most relevant knowledge
articles (data-modeling: owning-table-delete-dependents — correctly not applied, since NAICS
Code's referencing tables are independent entities, not owned dependents, so block-if-referenced
is the right pattern, not cascade-delete; table-relation-extensions-top-down — not applicable, no
existing `TableRelation` is being extended; events: publisher-design articles — not applicable,
this project only subscribes, never publishes; style: file-naming pattern, page-name-matches-
source-table, named-invocations-not-object-ids, no-else-after-terminating-statement — all
checked and compliant). **Note on method:** the snapshot's full automated dispatch
(`skills/entry.md`) requires a PowerShell-built knowledge index (`Build-KnowledgeIndex.ps1`),
and no PowerShell is installed on this machine (Rule 6b — not installed without asking, and not
asked since this is a secondary, non-blocking pass). Substituted a manual, targeted read of the
knowledge domains actually relevant to this project's code (data-modeling, events, style) instead
of the full JSON-dispatch protocol. No findings survived — see `ChangeLog.md` for anything that
did surface (all caught earlier, by the compiler, and already logged as Issues 1–4).

**Anti-Patterns table (Standards Part 7):** checked line by line against the codebase — no
violations. Several rows are structurally N/A (no API pages, no Option fields, no legacy price
tables). Translation-state rows (§8.2–§8.7) are not yet applicable — the `.g.xlf`/`.en-US.xlf`
pair exists (generated automatically by the `TranslationFile` feature) but has not yet been
through human review/approval; tracked as an open item for Step 7's release gate, not a Step 6
finding.
