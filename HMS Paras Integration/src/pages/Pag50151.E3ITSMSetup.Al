page 50151 E3ITSMSetup
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "E3 ITSM Setup";
    Caption = 'ITSM Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Code; Rec.Code)
                {
                    Caption = 'Code';
                    ToolTip = 'Enter the unique code for the ITSM setup configuration.';

                }
                field("Auth Token URL"; Rec."Auth Token URL")
                {
                    Caption = 'Auth Token URL';
                    ToolTip = 'Enter the URL to obtain the authentication token from the ITSM API.';
                }
                field("Asset Insert URL"; Rec."Asset Insert URL")
                {
                    Caption = 'Asset Insert URL';
                    ToolTip = 'Enter the URL to insert assets into the ITSM system.';
                }
            }
        }
    }




}