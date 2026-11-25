table 50048 "Data Clean-up Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Data Clean-up Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
        }
        field(3; "Date Field ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Field ID';
        }
        field(4; "Last Cleaned Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Cleaned Date';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}