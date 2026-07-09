table 50032 "E3 Assets Group"

{
    Caption = 'Assets Group';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; AssetsGroup; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Default Assets Name"; Text[100])
        {
            Caption = 'Default Assets Name';
        }
        field(4; "Number Sequence"; Code[20])
        {
            Caption = 'No. Sequnce';
            TableRelation = "No. Series".Code;
        }
        field(5; "FA Sub Class"; Code[20])
        {
            Caption = 'FA Sub Class';
            TableRelation = "FA Subclass".Code;
        }
    }
    keys
    {
        key(PK; AssetsGroup)
        {
            Clustered = true;
        }
    }
}
