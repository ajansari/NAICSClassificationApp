namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.History;

tableextension 60476 "ocpf Sales Cr Memo Header Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(60476; "NAICS Code"; Code[6])
        {
            Caption = 'NAICS Code';
            ToolTip = 'Specifies the NAICS code that was recorded on the sales document at the time of posting.';
            DataClassification = CustomerContent;
            TableRelation = "ocpf NAICS Code".Code;
            Editable = false;
        }
    }
}
