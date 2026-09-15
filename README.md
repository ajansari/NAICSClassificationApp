# NAICS Classification Extension for Business Central

A Business Central per-tenant extension that adds comprehensive NAICS (North American Industry Classification System) code management and tracking across the sales lifecycle.

## Overview

This extension enables organizations to:

- Maintain a structured NAICS code master data table with hierarchical classification levels
- Assign NAICS codes to customers for classification and analysis
- Automatically carry NAICS codes from customers through the entire sales document workflow — quotes, orders, invoices, and credit memos
- Track NAICS classifications on posted financial documents for reporting and analytics

## Features

### NAICS Code Master Data
- Hierarchical NAICS code list with support for 2-6 digit codes
- Parent-child relationships tracking (Sector → Subsector → Industry → Industry Group → National Industry)
- Built-in list and card pages for easy browsing and maintenance

### Customer Integration
- NAICS Code field on Customer master data
- Visible on both Customer Card and Customer List pages
- Searchable and filterable

### Sales Document Flow
- NAICS Code field on all sales documents (Quote, Order, Invoice, Credit Memo, Blanket Order, Return Order)
- Auto-defaulted from the customer with override capability
- Automatically posted to Sales Invoice Header and Sales Credit Memo Header for reporting

### Permission Sets
- **Read-only permission set** for viewing NAICS codes and classified data
- **Read/Write permission set** for maintaining NAICS codes and updating customer/document classifications

## Technical Details

- **BC Application Minimum Version:** 28.0.0.0
- **AL Runtime:** 17.0
- **Deployment Model:** SaaS Per-Tenant Extension
- **Namespace:** OnlyCopilotFans.NAICSClassification
- **Publisher:** OnlyCopilotFans

## Installation

1. Download the extension package from `outputAppPackage/`
2. In Business Central, go to **Extension Management**
3. Upload the `.app` package
4. Choose **Schema Sync Mode: Add** (or **Force Sync** if updating a prior version with schema changes)
5. Assign the appropriate permission sets (`OCPF NAICS - READ` or `OCPF NAICS - RW`) to users

## Documentation

- **DesignDoc.md** — Complete technical specification and design decisions
- **Docs.md** — API reference, deployment guide, and end-user guide
- **TestScript.md** — Comprehensive test scenarios for functionality validation
- **ChangeLog.md** — Detailed log of all changes and issues resolved during development

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Created By

Created by AJ Ansari  
OnlyCopilotFans, 2026
