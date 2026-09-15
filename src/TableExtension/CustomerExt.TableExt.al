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
