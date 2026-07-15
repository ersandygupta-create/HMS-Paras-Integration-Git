page 50154 "E3 ITSM API"
{
    APIGroup = 'apiITSM';
    APIPublisher = 'mindcurve';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'ITSMAPI';
    DelayedInsert = true;
    EntityName = 'itsmAssetMaster';
    EntitySetName = 'itsmAssetMasters';
    PageType = API;
    SourceTable = "E3 Assets Details";
    ODataKeyFields = "Entry No.";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field("puttouseDate"; rec."Put to use Date (ITSM)")
                {
                    Caption = 'Put to use Date (ITSM)';
                }
                field("assetUniqueId"; Rec."Asset uniqe ID (ITSM)")
                {
                    Caption = 'Asset uniqe ID (ITSM)';

                }
            }
        }
    }
}
