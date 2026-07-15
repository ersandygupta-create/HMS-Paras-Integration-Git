table 50031 "E3 Assets Details"

{
    Caption = 'Asset Details';
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
        field(12; "Capitalization Type"; Enum "E3 Capitalization Type")
        {
            Caption = 'capitalization Type';
            Editable = false;
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
        field(29; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(30; "Capex Id"; Code[50])
        {
            Caption = 'Capex Id';
        }
        field(32; "Assets Reference"; Code[20])
        {
            Caption = 'Assets Reference/Asset No';
        }
        field(33; "Assets Name"; Text[100])
        {
            Caption = 'Assets Name';
        }
        field(34; "Put to use Date (ITSM)"; Date)
        {
            Caption = 'Put to use Date (ITSM)';
        }
        field(35; "Asset uniqe ID (ITSM)"; Code[20])
        {
            Caption = 'Asset Unique Id (ITSM)';
        }
        field(36; "Asset Reference Created"; Boolean)
        {
            Caption = 'Asset Reference created';
        }
        field(37; "Vendor Invoice No."; Code[35])
        {
            Caption = 'Vendor Invoice No.';
        }
        field(38; Status; Text[250])
        {
            Caption = 'Status';
        }
        field(39; ITSMSend; Boolean)
        {
            Caption = 'Sent to ITSM';
        }
        field(40; "Department Id"; Code[20])
        {
            Caption = 'Department Id';
        }
        field(41; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 2;
        }
        field(43; AssetCreated; Boolean)
        {
            Caption = 'Asset Created';
        }
        field(44; JournalCreated; Boolean)
        {
            Caption = 'Journal Created';
        }
        field(45; "FA Sub Class"; Code[20])
        {
            Caption = 'FA Sub Class';
        }
        field(46; "Depreciation Years"; Integer)
        {
            Caption = 'Depreciation Years';
        }
        field(47; "Depreciation Method"; Enum "FA Depreciation Method")
        {
            Caption = 'Depreciation Method';
        }
        field(48; "Depreciation %"; Decimal)
        {
            Caption = 'Depreciation %';
        }
        field(49; "Amount/Qty"; Decimal)
        {
            Caption = 'Amount per FA';
        }
        field(50; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
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
