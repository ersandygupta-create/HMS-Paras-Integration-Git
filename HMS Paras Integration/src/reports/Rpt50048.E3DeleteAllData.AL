report 50048 "Delete All Records By Table ID"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    Caption = 'Delete All Records By Table ID';

    dataset
    {
        dataitem(DummyItem; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            trigger OnAfterGetRecord()
            var
                RecRef: RecordRef;
                FieldRef: FieldRef;
            begin
                if TableIdToClear = 0 then
                    Error('Please specify a valid Table ID.');

                // Open the table dynamically using the provided ID
                RecRef.Open(TableIdToClear);

                // Optional Safety Warning: Prevent deleting core system tables if necessary
                if TableIdToClear < 2000000000 then begin
                    // Add custom validation or confirmation checks here if required
                end;

                // Apply date filter if both a Date Field ID and a Date Filter are specified
                if (DateFieldId <> 0) and (DateFilter <> '') then begin
                    FieldRef := RecRef.Field(DateFieldId);
                    if not (FieldRef.Type in [FieldType::Date, FieldType::DateTime]) then
                        Error('Selected Field ID %1 is not of type Date or DateTime.', DateFieldId);

                    FieldRef.SetFilter(DateFilter);
                end;

                // DeleteAll(false) deletes filtered records without triggers (change to true if triggers are needed)
                RecRef.DeleteAll(false);
                Message('Successfully processed deletion for table %1 (%2).', TableIdToClear, RecRef.Caption);
                RecRef.Close();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Parameters)
                {
                    Caption = 'Parameters';

                    field(TableIdToClear; TableIdToClear)
                    {
                        ApplicationArea = All;
                        Caption = 'Table ID';
                        ToolTip = 'Specifies the ID of the table from which you want to delete records.';

                        trigger OnValidate()
                        begin
                            // Optional validation if needed
                        end;
                    }
                    field(DateFieldId; DateFieldId)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Field ID';
                        ToolTip = 'Specifies the Field ID of the Date or DateTime field to filter on (e.g., Posting Date).';
                    }
                    field(DateFilter; DateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Filter';
                        ToolTip = 'Specifies the date filter expression (e.g., ..123125D or 010124..311224). Leave blank to delete all records.';
                    }
                }
            }
        }
    }

    var
        TableIdToClear: Integer;
        DateFieldId: Integer;
        DateFilter: Text;
}