namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.History;

tableextension 60475 "ocpf Sales Invoice Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(60475; "NAICS Code"; Code[6])
        {
            Caption = 'NAICS Code';
            ToolTip = 'Specifies the NAICS code that was recorded on the sales document at the time of posting.';
            DataClassification = CustomerContent;
            TableRelation = "ocpf NAICS Code".Code;
            Editable = false;
        }
    }
}
