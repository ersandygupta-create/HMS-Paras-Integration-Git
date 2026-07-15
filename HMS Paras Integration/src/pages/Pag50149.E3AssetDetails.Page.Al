page 50149 "E3 Asset Details"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "E3 Assets Details";
    DeleteAllowed = true;
    SourceTableView = SORTING("Entry No.") ORDER(Descending)
    where(ITSMSend = CONST(false));
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                    Visible = false;
                }
                field("PO No."; Rec."PO No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purchase order number.';
                    Editable = false;
                }
                field("GRN Date"; Rec."GRN Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GRN date.';
                    Editable = false;
                }
                field("GRN No."; Rec."GRN No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GRN number.';
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type.';
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                    Editable = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number.';
                    Editable = false;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor name.';
                    Editable = false;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor invoice number.';
                    Editable = false;
                }
                field("Asset Group"; Rec."Asset Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the asset group.';
                    Editable = false;
                }
                field("Department Id"; Rec."Department Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Department Id.';
                    Editable = true;
                }
                field("Capitalization Type"; Rec."Capitalization Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the capitalization type.';
                    Editable = true;
                }
                field("Capex Id"; Rec."Capex Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Capex Id.';
                    Editable = true;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code.';
                    Editable = false;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    Editable = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure.';
                    Editable = false;
                }
                field("Assets Reference"; Rec."Assets Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Assets Reference';
                }
                field("Assets Name"; Rec."Assets Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify Assets Name';
                }
                field(Amount; Rec."Amount/Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify Amount';
                    Editable = false;
                    DecimalPlaces = 2;
                }
                field("Put to use Date"; rec."Put to use Date (ITSM)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify Put to use Date';
                }
                field("Asset Unique Id"; Rec."Asset uniqe ID (ITSM)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify ITSM Asset No';

                }
                field("asset reference generated"; Rec."Asset Reference Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify Asset Reference Generated';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status.';
                    Editable = false;
                }
                field(SentToITSM; Rec.ITSMSend)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to send to ITSM.';
                    Editable = true;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GenerateAssetReference)
            {
                ToolTip = 'Generate Asset Reference';
                Caption = 'Generate Asset Reference';
                Image = Create;
                trigger OnAction()
                var
                    AssetCU: Codeunit "E3 Asset Capatlization";
                begin
                    AssetCU.GenerateAssetReference();
                end;
            }
            action(SendAssetDetails)
            {
                ToolTip = 'Send Asset Details to E3';
                Caption = 'Send Asset Details';
                Image = SendTo;
                trigger OnAction()
                var
                    E3AssetsDetails: Record "E3 Assets Details";
                    ITSMApiIntegration: Codeunit "E3 ITSM API Integration";
                begin
                    E3AssetsDetails := Rec;
                    CurrPage.SetSelectionFilter(E3AssetsDetails);
                    if E3AssetsDetails.FindSet() then
                        repeat
                            if (not E3AssetsDetails.ITSMSend) then
                                ITSMApiIntegration.SendAssetDetails(E3AssetsDetails)
                            else
                                Message('Asset details with Entry No. %1 has been sent to ITSM, cannot be sent again.', E3AssetsDetails."Entry No.");
                        until E3AssetsDetails.Next() = 0;
                end;
            }
        }
    }
}