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
