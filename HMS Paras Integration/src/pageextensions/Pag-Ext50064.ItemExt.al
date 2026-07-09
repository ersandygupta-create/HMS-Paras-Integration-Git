pageextension 50064 "E3 Item Ext" extends "Item Card"
{
    layout
    {
        addafter("Base Unit of Measure")
        {
            field("E3Capitalization Type"; Rec."E3Capitalization Type")
            {
                ApplicationArea = All;
                Caption = 'Capitalization Type';
                ToolTip = 'Specifies the Capitalization type for the item.';
            }
            field("Assets Group"; Rec."E3 Assets Group")
            {
                ApplicationArea = All;
                Caption = 'Assets Group';
                ToolTip = 'Specifies the Group for the item.';
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        Rec.TestField("Base Unit of Measure");
        exit(true);
    end;

}