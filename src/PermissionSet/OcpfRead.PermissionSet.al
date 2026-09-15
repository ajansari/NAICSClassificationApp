namespace OnlyCopilotFans.NAICSClassification;

permissionset 60488 "OCPF NAICS - READ"
{
    Caption = 'OCPF NAICS Classification - Read';
    Assignable = true;

    Permissions =
        tabledata "ocpf NAICS Code" = R,
        page "ocpf NAICS Code List" = X,
        page "ocpf NAICS Code Card" = X;
}
