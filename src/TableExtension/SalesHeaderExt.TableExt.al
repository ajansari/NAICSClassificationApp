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
