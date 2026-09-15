namespace OnlyCopilotFans.NAICSClassification;

page 60472 "ocpf NAICS Code Card"
{
    Caption = 'NAICS Code Card';
    PageType = Card;
    SourceTable = "ocpf NAICS Code";
    Editable = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                    ToolTip = 'Specifies the NAICS code (2 to 6 digits).';
                    ApplicationArea = All;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of this NAICS classification.';
                    ApplicationArea = All;
                }
                field(level; Rec.Level)
                {
                    Caption = 'Level';
                    ToolTip = 'Specifies the number of digits in the code (2 = Sector through 6 = National Industry), derived automatically from Code.';
                    ApplicationArea = All;
                }
                field(parentCode; Rec."Parent Code")
                {
                    Caption = 'Parent Code';
                    ToolTip = 'Specifies the parent NAICS code one level up in the hierarchy. Blank for a 2-digit Sector code.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
