namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Document;

pageextension 60483 "ocpf Sales Return Order Ext" extends "Sales Return Order"
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
