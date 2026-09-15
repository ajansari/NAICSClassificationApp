namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Customer;

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
