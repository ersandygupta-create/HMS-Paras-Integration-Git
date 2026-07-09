tableextension 50015 "EDC HIS Item" extends Item
{
    fields
    {
        field(50000; "EDC HIS Type"; Enum "EDC HIS Type")
        {
            Caption = 'HIS Type';
            DataClassification = CustomerContent;
        }
        field(50001; "EDC Item Type"; Enum "EDC HIS Item Type")
        {
            Caption = 'Item Type';
            DataClassification = CustomerContent;
        }
        field(50002; "E3Capitalization Type"; Enum "E3 Capitalization Type")
        {
            Caption = 'CapitalizationType';
            DataClassification = CustomerContent;
        }
        field(50003; "E3 Assets Group"; Code[20])
        {
            Caption = 'Assets Group';
            TableRelation = "E3 Assets Group".AssetsGroup;
            DataClassification = CustomerContent;
        }

    }
}
