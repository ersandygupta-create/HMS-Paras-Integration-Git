page 50152 "E3 Asset Staging Generated"
{
    Caption = 'Asset Staging Generated';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "E3 Asset Staging";
    SourceTableView = SORTING("Entry No.") ORDER(Descending) where("Asset Details Created" = CONST(true));
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = true;


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
                field("Direct unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the direct unit cost.';
                }
                field("Line amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the line amount.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = all;
                    Editable = false;
                    ToolTip = 'Specifies GST Amount';

                }
                field("Line Discount Per"; Rec."Line Discount Per")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line discount percentage.';
                    Editable = false;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line discount amount.';
                    Editable = false;
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity received.';
                    Editable = false;
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GST group code.';
                    Editable = false;
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HSN/SAC code.';
                    Editable = false;
                }
                field("GST Assessable Value"; Rec."GST Assessable Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GST assessable value.';
                    Editable = false;
                }
                field("GST Group Type"; Rec."GST Group Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GST group type.';
                    Editable = false;
                }
                field(Exempted; Rec.Exempted)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether it is exempted.';
                    Editable = false;
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GST jurisdiction type.';
                    Editable = false;
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GST credit.';
                    Editable = false;
                }
                field("Detailed Entry No."; Rec."Detailed Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the detailed entry number.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateAssetDetails)
            {
                ToolTip = 'Generate Asset Details';
                Caption = 'Generate Asset Details';
                Image = Create;
                trigger OnAction()
                var
                    AssetCU: Codeunit "E3 Asset Capatlization";
                begin
                    AssetCU.GenerateAssetDetails();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        //  rec.setrange(rec."Asset Details Created", false);
    end;

}