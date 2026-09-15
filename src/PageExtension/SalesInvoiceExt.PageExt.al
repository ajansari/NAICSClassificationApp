namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Document;

pageextension 60481 "ocpf Sales Invoice Ext" extends "Sales Invoice"
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
