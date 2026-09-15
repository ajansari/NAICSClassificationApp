namespace OnlyCopilotFans.NAICSClassification;

permissionset 60489 "OCPF NAICS - RW"
{
    Caption = 'OCPF NAICS Classification - Read/Write';
    Assignable = true;
    IncludedPermissionSets = "OCPF NAICS - READ";

    Permissions =
        tabledata "ocpf NAICS Code" = RIMD;
}
