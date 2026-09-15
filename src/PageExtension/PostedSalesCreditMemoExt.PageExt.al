namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.History;

pageextension 60486 "ocpf Posted Sales CrMemo Ext" extends "Posted Sales Credit Memo"
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
