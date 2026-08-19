codeunit 50012 "EDC Post Revenue Line"
{
    TableNo = "EDC HIS Revenue Staging Table";

    trigger OnRun()
    begin
        RevenueEntry.Copy(Rec);
        ProcessLine(RevenueEntry);
        Rec := RevenueEntry;
    end;

    local procedure ProcessLine(var HISRevenueStaging: Record "EDC HIS Revenue Staging Table")
    var
        GenJournalLine: Record "Gen. Journal Line";
        HISGLAccountMapping: Record "EDC HIS GL Accounts Mapping";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        EntryNo: Integer;
        MOPAccountType: Enum "Gen. Journal Account Type";
        MOPAccountNo: Code[20];
        CollectionAccountType: Enum "Gen. Journal Account Type";
        CollectionAccountNo: Code[20];
    begin
        // Check Document Date
        if not CollectionHISDocumentDateValidation(HISRevenueStaging) then
            exit;

        // Check MOP Setup
        HISGLAccountMapping.Reset();
        HISGLAccountMapping.SetRange(Type, HISGLAccountMapping.Type::MOP);
        HISGLAccountMapping.SetRange("MOP Code", HISRevenueStaging."Mode of Payment");

        if not HISGLAccountMapping.FindFirst() then
            exit;

        MOPAccountType := HISGLAccountMapping."Account Type";
        MOPAccountNo := HISGLAccountMapping."Account No.";

        // Check Collection Setup
        HISGLAccountMapping.Reset();
        HISGLAccountMapping.SetRange(Type, HISGLAccountMapping.Type::Collection);
        HISGLAccountMapping.SetRange("Service/Station Head", HISRevenueStaging."HIS Document Type");

        if not HISGLAccountMapping.FindFirst() then
            exit;

        CollectionAccountType := HISGLAccountMapping."Account Type";
        CollectionAccountNo := HISGLAccountMapping."Account No.";


        // MOP Journal Entry
        GenJournalLine.INIT();
        GenJournalLine.VALIDATE("Document Type", HISRevenueStaging."Document Type");
        GenJournalLine.VALIDATE("Document No.", HISRevenueStaging."Document No.");
        GenJournalLine.VALIDATE("Posting Date", HISRevenueStaging."Document Date");

        GenJournalLine.VALIDATE("Account Type", MOPAccountType);
        GenJournalLine.VALIDATE("Account No.", MOPAccountNo);

        GenJournalLine.VALIDATE(Amount, HISRevenueStaging.Amount);
        GenJournalLine.VALIDATE("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.VALIDATE("Cheque Date", HISRevenueStaging."Cheque Date");
        GenJournalLine.VALIDATE("Cheque No.", COPYSTR(HISRevenueStaging."Cheque No.", 1, 10));

        if HISRevenueStaging."Shortcut Dimension 1 Code" <> '' then begin
            GenJournalLine.VALIDATE("Location Code", HISRevenueStaging."Shortcut Dimension 1 Code");
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", HISRevenueStaging."Shortcut Dimension 1 Code");
        end;

        if HISRevenueStaging."Shortcut Dimension 1 Code" <> '' then
            GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", GetMappedDimension(HISRevenueStaging."Shortcut Dimension 2 Code"));

        GenJournalLine.VALIDATE("External Document No.", HISRevenueStaging."Cheque No.");
        GenJournalLine."EDC Narration" := COPYSTR(HISRevenueStaging."Line Narration", 1, 50);
        GenJournalLine."EDC HIS Module" := HISRevenueStaging."HIS Module";
        GenJournalLine."EDC HIS Document Type" := COPYSTR(HISRevenueStaging."HIS Document Type", 1, 60);
        GenJournalLine."EDC UTR No." := HISRevenueStaging."Cheque No.";
        GenJournalLine."EDC Sub Group Code" := HISRevenueStaging."Sub Group";
        GenJournalLine."EDC Receipt No." := COPYSTR(HISRevenueStaging."Receipt No.", 1, 20);
        GenJournalLine."EDC UHID" := HISRevenueStaging.UHID;
        GenJournalLine."EDC Validation Key" := HISRevenueStaging."Validation HIS Key";
        GenJournalLine."EDC Store Code" := HISRevenueStaging."Store Code";
        GenJournalLine."EDC Patient Name" := HISRevenueStaging."Patient Name";
        GenJournalLine."EDC Transaction Type" := HISRevenueStaging.TRANSACTION_TYPE;
        GenJournalLine."EDC Encounter No." := HISRevenueStaging."Encounter No.";

        EntryNo := GenJnlPostLine.RunWithCheck(GenJournalLine);


        // Collection Journal Entry
        Clear(GenJournalLine);
        GenJournalLine.INIT();

        GenJournalLine.VALIDATE("Document Type", HISRevenueStaging."Document Type");
        GenJournalLine.VALIDATE("Document No.", HISRevenueStaging."Document No.");
        GenJournalLine.VALIDATE("Posting Date", HISRevenueStaging."Document Date");

        GenJournalLine.VALIDATE("Account Type", CollectionAccountType);
        GenJournalLine.VALIDATE("Account No.", CollectionAccountNo);

        GenJournalLine.VALIDATE(Amount, -HISRevenueStaging.Amount);
        GenJournalLine.VALIDATE("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.VALIDATE("Cheque Date", HISRevenueStaging."Cheque Date");
        GenJournalLine.VALIDATE("Cheque No.", COPYSTR(HISRevenueStaging."Cheque No.", 1, 10));

        if HISRevenueStaging."Shortcut Dimension 1 Code" <> '' then begin
            GenJournalLine.VALIDATE("Location Code", HISRevenueStaging."Shortcut Dimension 1 Code");
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", HISRevenueStaging."Shortcut Dimension 1 Code");
        end;

        if HISRevenueStaging."Shortcut Dimension 1 Code" <> '' then
            GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", GetMappedDimension(HISRevenueStaging."Shortcut Dimension 2 Code"));

        GenJournalLine.VALIDATE("External Document No.", HISRevenueStaging."External Document No.");
        GenJournalLine."EDC Narration" := COPYSTR(HISRevenueStaging."Line Narration", 1, 50);
        GenJournalLine."EDC HIS Module" := HISRevenueStaging."HIS Module";
        GenJournalLine."EDC HIS Document Type" := COPYSTR(HISRevenueStaging."HIS Document Type", 1, 60);
        GenJournalLine."EDC UTR No." := HISRevenueStaging."Cheque No.";
        GenJournalLine."EDC Sub Group Code" := HISRevenueStaging."Sub Group";
        GenJournalLine."EDC Receipt No." := COPYSTR(HISRevenueStaging."Receipt No.", 1, 20);
        GenJournalLine."EDC UHID" := HISRevenueStaging.UHID;
        GenJournalLine."EDC Validation Key" := HISRevenueStaging."Validation HIS Key";
        GenJournalLine."EDC Store Code" := HISRevenueStaging."Store Code";
        GenJournalLine."EDC Patient Name" := HISRevenueStaging."Patient Name";
        GenJournalLine."EDC Transaction Type" := HISRevenueStaging.TRANSACTION_TYPE;
        GenJournalLine."EDC Encounter No." := HISRevenueStaging."Encounter No.";

        EntryNo := GenJnlPostLine.RunWithCheck(GenJournalLine);


        // Update Staging Record
        if EntryNo <> 0 then begin
            HISRevenueStaging."Created By" := USERID;
            HISRevenueStaging."Created Date Time" := CURRENTDATETIME;
            HISRevenueStaging."General Entries Created" := TRUE;
            HISRevenueStaging.MODIFY();
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

    procedure CollectionHISDocumentDateValidation(
    HISRevenueStaging: Record "EDC HIS Revenue Staging Table"): Boolean
    var
        AllowPostingDate: Record "HIS Allow Posting Date";
        DocDate: Date;
    begin
        DocDate := HISRevenueStaging."Document Date";

        AllowPostingDate.Reset();
        AllowPostingDate.SetRange("Code Unit Name", '50003');
        AllowPostingDate.SetFilter("From Date", '<=%1', DocDate);
        AllowPostingDate.SetFilter("To Date", '>=%1', DocDate);

        exit(AllowPostingDate.FindFirst());
    end;

    var
        RevenueEntry: Record "EDC HIS Revenue Staging Table";

}
