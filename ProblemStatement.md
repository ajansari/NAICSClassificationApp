# Problem Statement — NAICS Classification

## Business outcome required

Business Central currently has no way to record a customer's NAICS (North American Industry
Classification System) code. This extension adds a maintainable NAICS code list, lets a NAICS
code be assigned to a Customer, and carries that code from the customer down through the sales
process — quote through posted invoice/credit memo — so the classification is available for
reporting and analysis at every stage of the sales cycle, including on posted (historical)
records.

## Consumers

- **Users**: BC users maintaining customer master data and processing sales documents (sales
  reps, order processors, AR/credit staff).
- **Other systems / BI / reporting**: not required for this release — no API/OData access was
  requested (confirmed with the human 2026-09-15). Reporting consumers would read the field
  directly from BC tables/pages, not via a dedicated endpoint.
- **AI tools**: none identified.

## Countries and languages

- Primary market: United States (NAICS is the US/North American standard classification).
- Localization: **US**.
- Working language for this project's conversation: **English**.
- Target language at first release: **English (en-US) only**. No other language is required.
- Source wording: **W1** (Microsoft's standard W1 English wording in source), with an **en-US**
  translation file — the standard pattern, even though en-US is the only target, per the human's
  choice on 2026-09-15.
- No customer-facing multi-language requirement: the NAICS Code and Description need to be
  *visible* (in English) on Quote/Invoice pages, not rendered in more than one language. Confirmed
  with the human 2026-09-15 after an initial ambiguous answer — see resolution below.

## Domain vocabulary

- **NAICS** — North American Industry Classification System. A hierarchical code: 2-digit Sector
  → 3-digit Subsector → 4-digit Industry Group → 5-digit Industry → 6-digit National Industry.
- No standard BC term collides with "NAICS" across US/other markets (BC has no built-in NAICS,
  SIC, or generic "Industry" classification table — confirmed by symbol search, see verification
  note below).

## Scope

**In scope:**
1. A new, maintainable **NAICS Code** table: flat list of codes at any digit length, with a
   **Level** (code length) field and a **Parent Code** field (self-referencing) so the hierarchy
   is navigable without a separate hierarchy table. List page (browse/maintain all codes) and
   Card page (view/edit one code).
2. A **NAICS Code** field on **Customer**, pickable via lookup to the NAICS Code table. Shown on
   the Customer Card and as a column on the Customer List.
3. The NAICS Code flows down to sales documents that share the **Sales Header** table: Quote,
   Order, Invoice, Credit Memo, Return Order, Blanket Order. Stored field, auto-populated from the
   Customer when the customer is selected, **overridable** per document (required since posted
   documents need a permanent snapshot — a FlowField cannot survive posting).
4. The NAICS Code flows to **posted financial documents**: Posted Sales Invoice and Posted Sales
   Credit Memo.
5. Read and Read/Write permission sets (required — the extension owns a new table; `PTE0004`
   fires at publish without them).

**Explicitly out of scope for this release** (documented decisions, not oversights):
- **Posted Sales Shipment and Posted Return Receipt** do not get the NAICS Code field. The human
  confirmed (2026-09-15) that only the financial posted documents (Invoice, Credit Memo) are
  needed — these are what carry the industry classification for reporting/analysis. Shipment and
  Return Receipt (quantity documents) are deferred; revisit if a future need for them emerges.
- **API/OData access.** No API pages or queries — UI (Card/List/document) pages only, confirmed
  2026-09-15. `APIPublisher`/`APIGroup`/`APIVersion` and Step 2's caption-locking decisions
  therefore do not apply to this project.
- **Multi-language NAICS descriptions.** The Description field is English-only; it does not need
  a separate translation table. See resolution below.
- **Report/printout layout changes.** The requirement is for the field to appear on the sales
  document *pages*; no request was made to modify printed report layouts (e.g. the Sales
  Quote/Invoice report). If a printed layout also needs the field, that is a follow-up, not part
  of this release.
- **Onboarding**: no Assisted Setup Wizard, no Role Center Activity Cues. Only **Departments
  placement** was requested (confirmed 2026-09-15).

## Ambiguity resolved during intake (2026-09-15)

The human's initial answer to "does this extension have customer-facing documents in the
customer's language, or store user-entered text needing per-language versions?" was "Yes, in
quotes and invoices" — which on its face contradicted the earlier "English only" target-language
decision, since XLIFF translation files translate AL source labels/captions, not table *data*
like a NAICS Description. Asked directly, the human clarified they meant only that the
Description should be *visible* (in English) on those documents, not rendered in multiple
languages. No NAICS Code Translation table is needed as a result.

## Quick gap check against standard BC modules

- **Corrected 2026-09-15 (Step 4).** The original search here used a flawed inspection method
  (parsing `SymbolReference.json` directly, which turned out to only list a small incidental
  subset of Base Application's real objects — not a genuine "no symbols" condition; see
  `ChangeLog.md` Issue 1) and concluded, wrongly, that there was no match. Re-run properly against
  the package's full embedded source (8,579 files): **BC does have existing "Industry Group"
  tables** — `Table 5057 "Industry Group"` (`Microsoft.CRM.Setup`: `Code[10]` + `Description`,
  flat, no hierarchy) and `Table 5058 "Contact Industry Group"` (`Microsoft.CRM.Contact`: a
  many-to-many junction between `Contact` and `Industry Group`).
- **Analyzed and rejected as a substitute for a new NAICS Code table**, for reasons distinct
  enough to record rather than just assert:
  1. **Wrong association target.** `Contact Industry Group` links to `Contact`, not `Customer`.
     The requirement is a single classification stored directly on the Customer record and
     flowed to sales documents — not a Contact-level many-to-many tag.
  2. **Wrong cardinality.** `Contact Industry Group` is explicitly many-to-many (a contact can
     have several industry groups). The requirement is a single NAICS code per customer/document.
  3. **No hierarchy.** `Industry Group` is a flat `Code`/`Description` pair with no digit-based
     breakdown — the requirement explicitly asks for "NAICS codes with breakdowns," i.e. the
     Sector→Subsector→Industry Group→Industry→National Industry hierarchy this project's `Level`/
     `Parent Code` fields capture.
  4. **Free-form, not the NAICS standard.** `Industry Group` holds whatever codes a user types in
     — it isn't pre-populated with, or semantically tied to, the actual NAICS code list. Repurposing
     it to mean "NAICS code" would be a values/semantics stretch that could collide with any
     unrelated existing use of that generic CRM feature.
  - **Conclusion unchanged**: a new NAICS Code table remains justified. Also searched for "NAICS"
    and "SIC" specifically — genuinely no matches anywhere in the real source (unlike "Industry,"
    which matched but for unrelated reasons above).
- Sales Quote, Order, Invoice, Credit Memo, Return Order, and Blanket Order all share the
  **Sales Header** table (differentiated by `Document Type`) — confirmed from BC domain knowledge
  of the modern Sales module structure; to be corroborated against real symbols at Step 2. This
  means one table extension covers all six document types pre-posting; each still needs its own
  page extension since each document type has a distinct page object.
- Posted counterparts exist as separate tables per BC's standard document-posting pattern:
  **Sales Invoice Header** (Posted Sales Invoice) and **Sales Cr.Memo Header** (Posted Sales
  Credit Memo) — to be verified against real symbols at Step 2.

## Initial entity/object list (19 files — see scoping note)

| # | Object | Type | Notes |
|---|---|---|---|
| 1 | NAICS Code | table (new) | Code, Description, Level, Parent Code |
| 2 | NAICS Code List | page (new) | List/maintain all codes |
| 3 | NAICS Code Card | page (new) | View/edit one code |
| 4 | Customer | tableextension | NAICS Code field |
| 5 | Customer Card | pageextension | Show NAICS Code |
| 6 | Customer List | pageextension | NAICS Code column |
| 7 | Sales Header | tableextension | NAICS Code field (covers Quote/Order/Invoice/Cr.Memo/Return Order/Blanket Order) |
| 8 | Sales Quote | pageextension | Show NAICS Code |
| 9 | Sales Order | pageextension | Show NAICS Code |
| 10 | Sales Invoice | pageextension | Show NAICS Code |
| 11 | Sales Credit Memo | pageextension | Show NAICS Code |
| 12 | Sales Return Order | pageextension | Show NAICS Code |
| 13 | Blanket Sales Order | pageextension | Show NAICS Code |
| 14 | Sales Invoice Header | tableextension | NAICS Code field (posted) |
| 15 | Posted Sales Invoice | pageextension | Show NAICS Code |
| 16 | Sales Cr.Memo Header | tableextension | NAICS Code field (posted) |
| 17 | Posted Sales Credit Memo | pageextension | Show NAICS Code |
| 18 | Sales Post Subscribers | codeunit (new) | Event subscribers on `Codeunit 80 "Sales-Post"` (`OnAfterInsertInvHeader`, `OnAfterInsertCrMemoHeader`) to copy NAICS Code into the posted header during posting — table/page extensions alone cannot populate a field on a record being newly inserted by a different table's posting process |
| 19 | Read permission set | permissionset (new) | |
| 20 | Read/Write permission set | permissionset (new) | |

## Scoping note — Lite framework file-count threshold

This object list (20 files — revised up from an initial 19 once Step 2 design work surfaced the
need for a posting event-subscriber codeunit) exceeds the Lite framework's stated ~10-file
graduation threshold.
This was raised explicitly with the human on 2026-09-15 (options: graduate to the full framework,
trim scope, or proceed in Lite anyway). **The human chose to proceed in Lite anyway.** This is a
deliberate, informed decision, not an oversight — recorded here per the framework's
human-in-the-loop discipline.

## Open questions

None outstanding. All scope ambiguities were resolved with the human during intake on 2026-09-15
(see resolution note above and the Explicitly out of scope list).
