namespace OnlyCopilotFans.NAICSClassification;

permissionset 60489 "OCPF - READ/WRITE"
{
    Caption = 'OCPF NAICS Classification - Read/Write';
    Assignable = true;
    IncludedPermissionSets = "OCPF - READ";

    Permissions =
        tabledata "ocpf NAICS Code" = RIMD;
}
