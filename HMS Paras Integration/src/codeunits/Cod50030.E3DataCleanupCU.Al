codeunit 50030 "Delete Data Date By Date"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        CleanUpSetup: Record "Data Clean-up Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TargetDate: Date;
    begin
        // 1. Get configuration from Setup
        if not CleanUpSetup.Get() then
            Error('Data Clean-up Setup record does not exist.');

        if CleanUpSetup."Table ID" = 0 then
            Error('Table ID is not configured in Setup.');

        if CleanUpSetup."Date Field ID" = 0 then
            Error('Date Field ID is not configured in Setup.');

        // 2. Open the table dynamically
        RecRef.Open(CleanUpSetup."Table ID");
        FieldRef := RecRef.Field(CleanUpSetup."Date Field ID");

        if not (FieldRef.Type in [FieldType::Date, FieldType::DateTime]) then
            Error('Configured Field ID %1 is not of type Date or DateTime.', CleanUpSetup."Date Field ID");

        // 3. Find the next date to process
        if CleanUpSetup."Last Cleaned Date" = 0D then begin
            // First run: Find the absolute earliest date present in the table
            RecRef.Ascending(true);
            if RecRef.FindSet() then
                TargetDate := DT2Date(FieldRef.Value())
            else begin
                RecRef.Close();
                Message('No records found in table %1.', CleanUpSetup."Table ID");
                exit;
            end;
        end else begin
            // Subsequent runs: Find the next date strictly greater than the last cleaned date
            FieldRef.SetFilter('>%1', CleanUpSetup."Last Cleaned Date");
            RecRef.Ascending(true);
            if RecRef.FindSet() then
                TargetDate := DT2Date(FieldRef.Value())
            else begin
                RecRef.Close();
                Message('Clean-up completed successfully. No further dates to process.');
                exit;
            end;
        end;

        // 4. Reset filters and target ONLY this specific single date
        RecRef.Reset();
        FieldRef := RecRef.Field(CleanUpSetup."Date Field ID");
        FieldRef.SetRange(TargetDate);

        // 5. Delete records for this date without row triggers
        RecRef.DeleteAll(false);
        RecRef.Close();

        // 6. Update setup so the next run picks up the subsequent date
        CleanUpSetup."Last Cleaned Date" := TargetDate;
        CleanUpSetup.Modify();

        Message('Successfully deleted all records for date %1 in table %2.', TargetDate, CleanUpSetup."Table ID");
    end;
}
/*codeunit 50030 "Delete Data Date By Date"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        CleanUpSetup: Record "Data Clean-up Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TargetDate: Date;
    begin
        // 1. Get configuration from Setup
        if not CleanUpSetup.Get() then
            Error('Data Clean-up Setup record does not exist.');

        if CleanUpSetup."Table ID" = 0 then
            Error('Table ID is not configured in Setup.');

        // 2. Security Check: Whitelist allowed tables only
        if not IsTableAllowed(CleanUpSetup."Table ID") then
            Error('Table ID %1 is not permitted to be cleaned up by this batch job for safety reasons.', CleanUpSetup."Table ID");

        if CleanUpSetup."Date Field ID" = 0 then
            Error('Date Field ID is not configured in Setup.');

        // 3. Open the table dynamically
        RecRef.Open(CleanUpSetup."Table ID");
        FieldRef := RecRef.Field(CleanUpSetup."Date Field ID");

        if not (FieldRef.Type in [FieldType::Date, FieldType::DateTime]) then
            Error('Configured Field ID %1 is not of type Date or DateTime.', CleanUpSetup."Date Field ID");

        // 4. Find the next date to process
        if CleanUpSetup."Last Cleaned Date" = 0D then begin
            // First run: Find the absolute earliest date present in the table
            RecRef.Ascending(true);
            if RecRef.FindSet() then
                TargetDate := DT2Date(FieldRef.Value())
            else begin
                RecRef.Close();
                Message('No records found in table %1.', CleanUpSetup."Table ID");
                exit;
            end;
        end else begin
            // Subsequent runs: Find the next date strictly greater than the last cleaned date
            FieldRef.SetFilter('>%1', CleanUpSetup."Last Cleaned Date");
            RecRef.Ascending(true);
            if RecRef.FindSet() then
                TargetDate := DT2Date(FieldRef.Value())
            else begin
                RecRef.Close();
                Message('Clean-up completed successfully. No further dates to process.');
                exit;
            end;
        end;

        // 5. Reset filters and target ONLY this specific single date
        RecRef.Reset();
        FieldRef := RecRef.Field(CleanUpSetup."Date Field ID");
        FieldRef.SetRange(TargetDate);

        // 6. Delete records for this date without row triggers
        RecRef.DeleteAll(false);
        RecRef.Close();

        // 7. Update setup so the next run picks up the subsequent date
        CleanUpSetup."Last Cleaned Date" := TargetDate;
        CleanUpSetup.Modify();

        Message('Successfully deleted all records for date %1 in table %2.', TargetDate, CleanUpSetup."Table ID");
    end;

    local procedure IsTableAllowed(TableId: Integer): Boolean
    begin
        // Add all Table IDs that you want to explicitly whitelist for deletion
        case TableId of
            50100, 50101, 50205: // Replace or expand with your custom table IDs
                exit(true);
            else
                exit(false);
        end;
    end;
}*/