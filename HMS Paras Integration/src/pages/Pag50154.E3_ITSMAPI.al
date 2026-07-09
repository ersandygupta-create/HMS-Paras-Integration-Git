page 50154 "E3 ITSM API"
{
    APIGroup = 'apiITSM';
    APIPublisher = 'e3';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'ITSMAPI';
    DelayedInsert = true;
    EntityName = 'itsmAssetMaster';
    EntitySetName = 'itsmAssetMasters';
    PageType = API;
    SourceTable = "E3 Assets Details";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(entryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                    Editable = false;
                }
                field("puttouseDate"; rec."Put to use Date (ITSM)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify Put to use Date';
                }
                field("assetUniqueId"; Rec."Asset uniqe ID (ITSM)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify ITSM Asset No';

                }



            }
        }
    }
}
