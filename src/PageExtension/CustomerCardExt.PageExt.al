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
