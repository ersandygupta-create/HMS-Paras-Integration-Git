page 50153 "E3 Asset Details Sent"
{
    Caption = 'Asset Details Sent';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "E3 Assets Details";
    DeleteAllowed = true;
    SourceTableView = SORTING("Entry No.") ORDER(Descending)
    where(ITSMSend = CONST(true));
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
                field(Amount; Rec.Amount)
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
            action(GenerateAssetCard)
            {
                ToolTip = 'Generate Asset Card';
                Caption = 'Generate Asset Card';
                Image = Create;
                trigger OnAction()
                var
                    AssetCU: Codeunit "E3 Asset Capatlization";
                begin
                    if not Rec.AssetCreated and (Rec."Put to use Date (ITSM)" <> 0D) then
                        AssetCU.CreateFixedAsset(Rec) else
                        Message('Asset card is already created or Put to use date is not specified');
                end;
            }

            action(CreateJournal)
            {
                ToolTip = 'Create Journal';
                Caption = 'Create Journal';
                Image = Create;
                trigger OnAction()
                var
                    AssetCU: Codeunit "E3 Asset Capatlization";
                begin
                    if Rec.AssetCreated and (Rec."Assets Reference" <> '') then
                        AssetCU.CreateAndPostFAJournal(Rec)
                    else
                        Message('Asset card is not created or Assets Reference is not specified');
                end;
            }
            action(OpenFixedAsset)
            {
                ToolTip = 'Open Fixed Asset Card';
                ApplicationArea = All;
                Caption = 'FA Card';
                Image = FixedAssets;

                trigger OnAction()
                var
                    FixedAsset: Record "Fixed Asset";
                begin
                    if FixedAsset.Get(Rec."Assets Reference") then
                        PAGE.Run(PAGE::"Fixed Asset Card", FixedAsset);
                end;
            }
        }
    }
}