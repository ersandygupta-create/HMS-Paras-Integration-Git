pageextension 50065 "Posted Pur Receipt List Ext" extends "Posted Purchase Receipts"
{
    layout
    {
        addafter("Location Code")
        {
            field("Posting Description"; Rec."Posting Description")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Posting Description';
                ToolTip = 'Specifies a posting description of the order.';
            }
        }

    }

    actions
    {
        addlast(Processing)
        {
            action("Create Asset Staging")
            {
                ApplicationArea = All;
                Caption = 'Create Asset Staging';
                ToolTip = 'Creates an asset staging record from the posted purchase receipt.';

                trigger OnAction()
                var
                    PurchRcptHeader: Record "Purch. Rcpt. Header";
                    AssetCapatlization: Codeunit "E3 Asset Capatlization";

                begin
                    PurchRcptHeader.Get(Rec."No.");
                    if PurchRcptHeader."AssetStaging Created" then begin
                        Message('Asset Staging record has already been created for Posted Purchase Receipt No. %1', Rec."No.");
                        exit;
                    end
                    else
                        if (PurchRcptHeader."EDC Procurement Type" = PurchRcptHeader."EDC Procurement Type"::Capex) then begin
                            AssetCapatlization.CreateAssetFromPostedReceiptLine(Rec."No.");
                            PurchRcptHeader."AssetStaging Created" := true;
                            PurchRcptHeader.Modify(true);
                            Message('Asset Staging record created for Posted Purchase Receipt No. %1', Rec."No.");
                        end
                        else
                            Message('Posted Purchase Receipt No. %1 is not of Capex type.', Rec."No.");
                end;
            }
        }
    }
}