table 50033 "E3 ITSM Setup"
{
    Caption = 'ITSM Integration Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "Integration Enabled"; Boolean)
        {
            Caption = 'Integration Enabled';
            DataClassification = CustomerContent;
        }

        field(5; Username; Text[50])
        {
            Caption = 'Username';
            DataClassification = CustomerContent;
        }
        field(6; Password; Text[50])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(7; "Auth Token URL"; Text[250])
        {
            Caption = 'Auth Token URL';
            DataClassification = CustomerContent;
        }
        field(8; "Asset Insert URL"; Text[250])
        {
            Caption = 'Asset Insert URL';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

}
