namespace OnlyCopilotFans.NAICSClassification;

using Microsoft.Sales.Customer;

table 60470 "ocpf NAICS Code"
{
    Caption = 'NAICS Code';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf NAICS Code List";
    DrillDownPageId = "ocpf NAICS Code List";

    fields
    {
        field(1; Code; Code[6])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the NAICS code (2 to 6 digits).';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec.Level := StrLen(Rec.Code);
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of this NAICS classification.';
            DataClassification = CustomerContent;
        }
        field(3; Level; Integer)
        {
            Caption = 'Level';
            ToolTip = 'Specifies the number of digits in the code (2 = Sector through 6 = National Industry), derived automatically from Code.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Parent Code"; Code[6])
        {
            Caption = 'Parent Code';
            ToolTip = 'Specifies the parent NAICS code one level up in the hierarchy. Blank for a 2-digit Sector code.';
            DataClassification = CustomerContent;
            TableRelation = "ocpf NAICS Code".Code;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("NAICS Code", Rec.Code);
        if not Customer.IsEmpty() then
            Error(DeleteBlockedErr);
    end;

    var
        DeleteBlockedErr: Label 'This NAICS Code is assigned to one or more records and cannot be deleted.';
}
