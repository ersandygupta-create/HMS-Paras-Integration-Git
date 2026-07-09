table 50030 "E3 Asset Staging"

{
    Caption = 'Asset staging';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "PO No."; Code[20])
        {
            Caption = 'Document No.';

        }
        field(4; "GRN Date"; Date)
        {
            Caption = 'GRN Date';
        }
        field(5; "GRN No."; Code[20])
        {
            Caption = 'Document No.';

        }
        field(6; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';

        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Editable = false;
        }
        field(10; "Vendor Name"; Code[100])
        {
            Caption = 'Vendor Name';
            Editable = false;
        }
        field(11; "Asset Group"; Code[20])
        {
            Caption = 'Asset Group';
            Editable = false;
        }
        field(12; "E3 Capitalization Type"; Enum "E3 Capitalization Type")
        {
            Caption = 'Capitalization Type';
            Editable = false;
        }
        field(13; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(14; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
        }
        field(17; "Direct Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
        }
        field(18; "Line Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Line Amount';
        }
        field(19; "Line Discount Per"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Line Discount %';
        }
        field(20; "Line Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Line Discount Amount';
        }
        field(21; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            DecimalPlaces = 0 : 5;
        }
        field(22; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
        }
        field(24; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(25; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(26; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(27; "GST Jurisdiction Type"; enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(28; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(29; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(30; "Capex Id"; Code[50])
        {
            Caption = 'Capex Id';
        }
        field(31; "Asset Details Created"; Boolean)
        {
            Caption = 'Assets Details Created';
        }
        field(32; "Detailed Entry No."; Integer)
        {
            Caption = 'Detailed Entry No.';
            DataClassification = SystemMetadata;
        }
        field(33; "Vendor Invoice No."; Code[35])
        {
            Caption = 'Vendor Invoice No.';
        }
        field(34; "Assets Name"; Text[100])
        {
            Caption = 'Assets Name';
        }
        field(35; "Department Id"; Code[20])
        {
            Caption = 'Department Id';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
