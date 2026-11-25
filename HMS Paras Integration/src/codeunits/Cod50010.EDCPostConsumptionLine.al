codeunit 50010 "EDC Post Consumption Line"
{
    TableNo = "EDC HIS Consumption Entries";

    trigger OnRun()
    begin
        ConsumptionEntry.Copy(Rec);
        ProcessLine(ConsumptionEntry);
        Rec := ConsumptionEntry;
    end;

    var
        ConsumptionEntry: Record "EDC HIS Consumption Entries";
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;

        // Caches to eliminate redundant database hits
        ItemMappingCache: Dictionary of [Text, Code[20]];       // Key: EntryType + '|' + ItemCategoryCode
        DimMappingCache: Dictionary of [Code[20], Code[20]];    // Key: HISCCode
        PostingDateCache: Dictionary of [Date, Boolean];        // Key: PostingDate

    local procedure ProcessLine(var HISConsumptionEntry: Record "EDC HIS Consumption Entries")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        EntryNo: Integer;
        CacheKey: Text;
        ConsumptionGLAcc: Code[20];
        POGLAcc: Code[20];
    begin
        if not ConsHISDocumentDateValidation(HISConsumptionEntry."Posting Date") then
            exit;

        // 1. Get Consumption Mapping (Cached)
        CacheKey := Format(HISGLAccountMappingEntryType::Consumption) + '|' + HISConsumptionEntry."Item Category Code";
        if not ItemMappingCache.Get(CacheKey, ConsumptionGLAcc) then begin
            ConsumptionGLAcc := GetItemMapping(Enum::"EDC HIS Item Map. Entry Type"::Consumption, HISConsumptionEntry."Item Category Code");
            if ConsumptionGLAcc = '' then
                exit;
            ItemMappingCache.Add(CacheKey, ConsumptionGLAcc);
        end;

        // 2. Get Purchase Order Mapping (Cached)
        CacheKey := Format(HISGLAccountMappingEntryType::"Purchase Order") + '|' + HISConsumptionEntry."Item Category Code";
        if not ItemMappingCache.Get(CacheKey, POGLAcc) then begin
            POGLAcc := GetItemMapping(Enum::"EDC HIS Item Map. Entry Type"::"Purchase Order", HISConsumptionEntry."Item Category Code");//ak
            if POGLAcc = '' then
                exit;
            ItemMappingCache.Add(CacheKey, POGLAcc);
        end;

        GenJournalLine.INIT();
        GenJournalLine.VALIDATE("Document Type", HISConsumptionEntry."Document Type");
        GenJournalLine.VALIDATE("Document No.", HISConsumptionEntry."Document No.");
        GenJournalLine.VALIDATE("Posting Date", HISConsumptionEntry."Posting Date");

        GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.VALIDATE("Account No.", ConsumptionGLAcc);

        GenJournalLine.VALIDATE(Amount, HISConsumptionEntry.Amount);
        GenJournalLine.VALIDATE("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.VALIDATE("Bal. Account No.", POGLAcc);

        if HISConsumptionEntry."Shortcut Dimension 1 Code" <> '' then begin
            GenJournalLine.VALIDATE("Location Code", HISConsumptionEntry."Shortcut Dimension 1 Code");
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", HISConsumptionEntry."Shortcut Dimension 1 Code");
        end;

        if HISConsumptionEntry."Shortcut Dimension 2 Code" <> '' then
            GenJournalLine.VALIDATE(
                "Shortcut Dimension 2 Code",
                GetMappedDimension(HISConsumptionEntry."Shortcut Dimension 2 Code"));

        GenJournalLine.VALIDATE("External Document No.", HISConsumptionEntry."External Document No.");
        GenJournalLine."EDC Narration" := COPYSTR(HISConsumptionEntry."Line Narration", 1, 50);
        GenJournalLine."EDC HIS Module" := HISConsumptionEntry."HIS Module";
        GenJournalLine."EDC HIS Document Type" := COPYSTR(HISConsumptionEntry."HIS Document Type", 1, 60);
        GenJournalLine."EDC Sub Group Code" := HISConsumptionEntry."Sub Group";
        GenJournalLine."EDC Receipt No." := COPYSTR(HISConsumptionEntry."Receipt No.", 1, 20);
        GenJournalLine."EDC UHID" := HISConsumptionEntry.UHID;
        GenJournalLine."EDC Validation Key" := HISConsumptionEntry."Validation HIS Key";
        GenJournalLine."EDC Store Code" := HISConsumptionEntry."Store Code";
        GenJournalLine."EDC Patient Name" := HISConsumptionEntry."Patient Name";
        GenJournalLine."EDC Transaction Type" := HISConsumptionEntry.TRANSACTION_TYPE;
        GenJournalLine."EDC Speciality" := HISConsumptionEntry.Speciality;
        GenJournalLine."EDC Encounter No." := HISConsumptionEntry."Encounter No.";

        EntryNo := GenJnlPostLine.RunWithCheck(GenJournalLine);

        if EntryNo <> 0 then begin
            HISConsumptionEntry."Created By" := USERID;
            HISConsumptionEntry."Created Date Time" := CURRENTDATETIME;
            HISConsumptionEntry."General Entries Created" := TRUE;
            HISConsumptionEntry.MODIFY();
        end;
    end;

    local procedure GetItemMapping(EntryType: enum "EDC HIS Item Map. Entry Type"; ItemCategoryCode: Code[20]): Code[20]
    var
        HISGLAccountMapping: Record "EDC HIS Item Mapping";
    begin
        HISGLAccountMapping.Reset();
        HISGLAccountMapping.SetRange("Entry Type", EntryType);
        HISGLAccountMapping.SetRange("Item Category Code", ItemCategoryCode);
        if HISGLAccountMapping.FindFirst() then
            exit(HISGLAccountMapping."G/L Account No.");
        exit('');
    end;

    local procedure GetMappedDimension(HISCCode: Code[20]): Code[20]
    var
        DimensionMapping: Record "EDC HIS GL Accounts Mapping";
        MappedDimCode: Code[20];
    begin
        if HISCCode = '' then
            exit('');

        if DimMappingCache.Get(HISCCode, MappedDimCode) then
            exit(MappedDimCode);

        if not GLSetupRead then begin
            GLSetup.Get();
            GLSetupRead := true;
        end;

        DimensionMapping.Reset();
        DimensionMapping.SetRange(Type, DimensionMapping.Type::Dimension);
        DimensionMapping.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
        DimensionMapping.SetRange("HIS Code", HISCCode);
        if DimensionMapping.FindFirst() then
            MappedDimCode := DimensionMapping."Department Code";

        DimMappingCache.Add(HISCCode, MappedDimCode);
        exit(MappedDimCode);
    end;

    local procedure ConsHISDocumentDateValidation(DocDate: Date): Boolean
    var
        AllowPostingDate: Record "HIS Allow Posting Date";
        IsValid: Boolean;
    begin
        if PostingDateCache.Get(DocDate, IsValid) then
            exit(IsValid);

        AllowPostingDate.Reset();
        AllowPostingDate.SetRange("Code Unit Name", '50010');
        AllowPostingDate.SetFilter("From Date", '<=%1', DocDate);
        AllowPostingDate.SetFilter("To Date", '>=%1', DocDate);

        IsValid := AllowPostingDate.FindFirst();
        PostingDateCache.Add(DocDate, IsValid);
        exit(IsValid);
    end;

    procedure ConsumptionValidation()
    var
        TempConsumptionEntry: Record "EDC HIS Consumption Entries";
        HISGLAccountMapping: Record "EDC HIS Item Mapping";
        ConsumptionMappingError: Text[100];
        PurchaseOrderMappingError: Text[100];
    begin
        TempConsumptionEntry.Reset();
        TempConsumptionEntry.SetRange("General Entries Created", false);

        if TempConsumptionEntry.FindSet(true) then
            repeat
                TempConsumptionEntry."Error Description" := '';
                ConsumptionMappingError := '';
                PurchaseOrderMappingError := '';

                if TempConsumptionEntry."Item Category Code" = '' then
                    ConsumptionMappingError := StrSubstNo('Entry No. %1: Item Category Code cannot be blank', TempConsumptionEntry."Entry No.")
                else begin
                    HISGLAccountMapping.Reset();
                    HISGLAccountMapping.SetRange("Entry Type", HISGLAccountMapping."Entry Type"::Consumption);
                    HISGLAccountMapping.SetRange("Item Category Code", TempConsumptionEntry."Item Category Code");
                    if not HISGLAccountMapping.FindFirst() then
                        ConsumptionMappingError := StrSubstNo('Entry No. %1: Consumption mapping setup missing for Item Category %2', TempConsumptionEntry."Entry No.", TempConsumptionEntry."Item Category Code");

                    HISGLAccountMapping.Reset();
                    HISGLAccountMapping.SetRange("Entry Type", HISGLAccountMapping."Entry Type"::"Purchase Order");
                    HISGLAccountMapping.SetRange("Item Category Code", TempConsumptionEntry."Item Category Code");
                    if not HISGLAccountMapping.FindFirst() then
                        PurchaseOrderMappingError := StrSubstNo('Entry No. %1: Purchase Order mapping setup missing for Item Category %2', TempConsumptionEntry."Entry No.", TempConsumptionEntry."Item Category Code");
                end;

                TempConsumptionEntry."Error Description" := ConsumptionMappingError + ' ' + PurchaseOrderMappingError;
                TempConsumptionEntry.Modify(true);

            until TempConsumptionEntry.Next() = 0;
    end;

    var
        HISGLAccountMappingEntryType: Option Consumption,"Purchase Order";
}
/*codeunit 50010 "EDC Post Consumption Line"
{
    TableNo = "EDC HIS Consumption Entries";

    trigger OnRun()
    begin
        ConsumptionEntry.Copy(Rec);
        ProcessLine(ConsumptionEntry);
        Rec := ConsumptionEntry;
    end;

    local procedure ProcessLine(var HISConsumptionEntry: Record "EDC HIS Consumption Entries")
    var
        GenJournalLine: Record "Gen. Journal Line";
        HISGLAccountMapping: Record "EDC HIS Item Mapping";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DocumentTypeLbl: Label 'Setup not found for Entry No. %1.';
        EntryNo: Integer;
    begin

        //ConsumptionValidation();
        if not ConsHISDocumentDateValidation(HISConsumptionEntry) then
            exit;

        GenJournalLine.INIT();
        GenJournalLine.VALIDATE("Document Type", HISConsumptionEntry."Document Type");
        GenJournalLine.VALIDATE("Document No.", HISConsumptionEntry."Document No.");
        GenJournalLine.VALIDATE("Posting Date", HISConsumptionEntry."Posting Date");

        // Check Consumption Mapping
        HISGLAccountMapping.Reset();
        HISGLAccountMapping.SetRange("Entry Type", HISGLAccountMapping."Entry Type"::Consumption);
        HISGLAccountMapping.SetRange("Item Category Code", HISConsumptionEntry."Item Category Code");

        if not HISGLAccountMapping.FindFirst() then
            exit;

        GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.VALIDATE("Account No.", HISGLAccountMapping."G/L Account No.");

        GenJournalLine.VALIDATE(Amount, HISConsumptionEntry.Amount);
        GenJournalLine.VALIDATE("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");

        // Check Purchase Order Mapping
        HISGLAccountMapping.Reset();
        HISGLAccountMapping.SetRange("Entry Type", HISGLAccountMapping."Entry Type"::"Purchase Order");
        HISGLAccountMapping.SetRange("Item Category Code", HISConsumptionEntry."Item Category Code");

        if not HISGLAccountMapping.FindFirst() then
            exit;

        GenJournalLine.VALIDATE("Bal. Account No.", HISGLAccountMapping."G/L Account No.");

        if HISConsumptionEntry."Shortcut Dimension 1 Code" <> '' then begin
            GenJournalLine.VALIDATE("Location Code", HISConsumptionEntry."Shortcut Dimension 1 Code");
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", HISConsumptionEntry."Shortcut Dimension 1 Code");
        end;

        if HISConsumptionEntry."Shortcut Dimension 1 Code" <> '' then
            GenJournalLine.VALIDATE(
                "Shortcut Dimension 2 Code",
                GetMappedDimension(HISConsumptionEntry."Shortcut Dimension 2 Code"));

        GenJournalLine.VALIDATE("External Document No.", HISConsumptionEntry."External Document No.");
        GenJournalLine."EDC Narration" := COPYSTR(HISConsumptionEntry."Line Narration", 1, 50);
        GenJournalLine."EDC HIS Module" := HISConsumptionEntry."HIS Module";
        GenJournalLine."EDC HIS Document Type" := COPYSTR(HISConsumptionEntry."HIS Document Type", 1, 60);
        GenJournalLine."EDC Sub Group Code" := HISConsumptionEntry."Sub Group";
        GenJournalLine."EDC Receipt No." := COPYSTR(HISConsumptionEntry."Receipt No.", 1, 20);
        GenJournalLine."EDC UHID" := HISConsumptionEntry.UHID;
        GenJournalLine."EDC Validation Key" := HISConsumptionEntry."Validation HIS Key";
        GenJournalLine."EDC Store Code" := HISConsumptionEntry."Store Code";
        GenJournalLine."EDC Patient Name" := HISConsumptionEntry."Patient Name";
        GenJournalLine."EDC Transaction Type" := HISConsumptionEntry.TRANSACTION_TYPE;
        GenJournalLine."EDC Speciality" := HISConsumptionEntry.Speciality;
        GenJournalLine."EDC Encounter No." := HISConsumptionEntry."Encounter No.";

        EntryNo := GenJnlPostLine.RunWithCheck(GenJournalLine);

        if EntryNo <> 0 then begin
            HISConsumptionEntry."Created By" := USERID;
            HISConsumptionEntry."Created Date Time" := CURRENTDATETIME;
            HISConsumptionEntry."General Entries Created" := TRUE;
            HISConsumptionEntry.MODIFY();
        end;
    end;

    local procedure GetMappedDimension(HISCCode: Code[20]): Code[20]
    var
        LGeneralLedgerSetup: Record "General Ledger Setup";
        DimensionMapping: Record "EDC HIS GL Accounts Mapping";
    begin
        if HISCCode = '' then
            exit('');

        LGeneralLedgerSetup.Get();

        DimensionMapping.Reset();
        DimensionMapping.SetRange(Type, DimensionMapping.Type::Dimension);
        DimensionMapping.SetRange("Dimension Code", LGeneralLedgerSetup."Global Dimension 2 Code");
        DimensionMapping.SetRange("HIS Code", HISCCode);
        if DimensionMapping.FindFirst() then
            exit(DimensionMapping."Department Code");
    end;

    procedure ConsHISDocumentDateValidation(HISConsumptionEntry1: Record "EDC HIS Consumption Entries"): Boolean
    var
        AllowPostingDate: Record "HIS Allow Posting Date";
        DocDate: Date;

    begin
        DocDate := HISConsumptionEntry1."Posting Date";

        AllowPostingDate.Reset();
        AllowPostingDate.SetRange("Code Unit Name", '50010');
        AllowPostingDate.SetFilter("From Date", '<=%1', DocDate);
        AllowPostingDate.SetFilter("To Date", '>=%1', DocDate);

        exit(AllowPostingDate.FindFirst());
    end;

    procedure ConsumptionValidation()
    var
        TempConsumptionEntry: Record "EDC HIS Consumption Entries";
        HISGLAccountMapping: Record "EDC HIS Item Mapping";
        ConsumptionMappingError: Text[100];
        PurchaseOrderMappingError: Text[100];
    begin
        TempConsumptionEntry.Reset();
        TempConsumptionEntry.SetRange("General Entries Created", false);

        if TempConsumptionEntry.FindSet() then
            repeat
                TempConsumptionEntry."Error Description" := '';
                ConsumptionMappingError := '';
                PurchaseOrderMappingError := '';

                HISGLAccountMapping.Reset();
                HISGLAccountMapping.SetRange("Entry Type", HISGLAccountMapping."Entry Type"::Consumption);
                HISGLAccountMapping.SetRange("Item Category Code", TempConsumptionEntry."Item Category Code");
                if not HISGLAccountMapping.FindFirst() then
                    ConsumptionMappingError := StrSubstNo('Entry No. %1: Consumption mapping setup missing for Item Category %2', TempConsumptionEntry."Entry No.", TempConsumptionEntry."Item Category Code");

                if TempConsumptionEntry."Item Category Code" = '' then
                    ConsumptionMappingError := StrSubstNo('Entry No. %1: Item Category Code cannot be blank', TempConsumptionEntry."Entry No.");

                HISGLAccountMapping.Reset();
                HISGLAccountMapping.SetRange("Entry Type", HISGLAccountMapping."Entry Type"::"Purchase Order");
                HISGLAccountMapping.SetRange("Item Category Code", TempConsumptionEntry."Item Category Code");
                if not HISGLAccountMapping.FindFirst() then
                    PurchaseOrderMappingError := StrSubstNo('Entry No. %1: Purchase Order mapping setup missing for Item Category %2', TempConsumptionEntry."Entry No.", TempConsumptionEntry."Item Category Code");
                TempConsumptionEntry."Error Description" := ConsumptionMappingError + ' ' + PurchaseOrderMappingError;

                TempConsumptionEntry.Modify(true);

            until TempConsumptionEntry.Next() = 0;
    end;


    var
        ConsumptionEntry: Record "EDC HIS Consumption Entries";

}
*/
