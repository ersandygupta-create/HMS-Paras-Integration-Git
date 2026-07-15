page 50150 "E3 Assets Group"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "e3 assets group";
    DeleteAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(AssetsGroup; Rec.AssetsGroup)
                {
                    Caption = 'Code';
                    ToolTip = 'Specifies Asset Group';
                }
                field(Name; Rec.Name)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies Assets Name';
                }
                field("Default Assets Name";
                rec."Default Assets Name")
                {
                    Caption = 'Default Assets Name';
                    ToolTip = 'Specifies Default Assets Name';
                }
                field("Location Code"; Rec."Location Code")
                {
                    Caption = 'Location Code';
                    ToolTip = 'Specifies Location Code';
                }
                field("Number Sequence"; Rec."Number Sequence")
                {
                    Caption = 'No. Sequnce';
                    ToolTip = 'Specifies Number sequence';
                }
                field("FA Sub Class"; Rec."FA Sub Class")
                {
                    Caption = 'FA Sub Class';
                    ToolTip = 'Specifies FA Sub Class';
                }
                field("Depreciation Years"; Rec."Depreciation Years")
                {
                    Caption = 'Depreciation Years';
                    ToolTip = 'Depreciation Years';
                }
                field("Depreciation Method"; Rec."Depreciation Method")
                {
                    Caption = 'Depreciation Method';
                    ToolTip = 'Depreciation Method';
                }
                field("Depreciation %"; Rec."Depreciation %")
                {
                    Caption = 'Depreciation %';
                    ToolTip = 'Depreciation %';
                }
            }
        }
    }
}