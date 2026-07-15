codeunit 50028 "E3 Asset Capatlization"
{
    trigger OnRun()
    begin
        PurchRcptHeader.Reset();
        PurchRcptHeader.SetRange(PurchRcptHeader."AssetStaging Created", false);
        PurchRcptHeader.SetRange("EDC Procurement Type", PurchRcptHeader."EDC Procurement Type"::Capex);
        if PurchRcptHeader.FindSet() then
            repeat
                CreateAssetFromPostedReceiptLine(PurchRcptHeader."No.");
                PurchRcptHeader."AssetStaging Created" := true;
                PurchRcptHeader.Modify(true);
            until PurchRcptHeader.Next() = 0;
    end;

    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        AssetCapatlization: Codeunit "E3 Asset Capatlization";


    procedure CreateAssetFromPostedReceiptLine(PostedReceiptNo: Code[20])
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.SetRange("Document No.", PostedReceiptNo);
        PurchRcptLine.SetRange(Type, Type::Item);
        if PurchRcptLine.FindSet() then
            repeat
                InsertIntoAssetStaging(PurchRcptLine);
            until PurchRcptLine.Next() = 0;
    end;

    procedure InsertIntoAssetStaging(PurchRcptLine: Record "Purch. Rcpt. Line")
    var
        AssetStagingRec: Record "E3 Asset Staging";
        Item: Record Item;
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        DimSetEntry: Record "Dimension Set Entry";
        Qty: Integer;
        DimensionValue: Record "Dimension Value";
        GSTPercent: Decimal;
        GSTAmount: Decimal;
        GSTText: Text;

    begin
        Qty := PurchRcptLine.Quantity;
        //for Qty := 1 to PurchRcptLine.Quantity do begin
        AssetStagingRec.LockTable();
        AssetStagingRec.Init();

        if AssetStagingRec.FindLast() then
            AssetStagingRec."Entry No." := AssetStagingRec."Entry No." + 1
        else
            AssetStagingRec."Entry No." := 1;
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document No.", PurchRcptLine."Order No.");
        PurchaseLine.SetRange("Line No.", PurchRcptLine."Order Line No.");
        if PurchaseLine.find('-') then;
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", PurchaseLine."Document No.");
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        if PurchaseHeader.find('-') then;
        AssetStagingRec."PO No." := PurchRcptLine."Order No.";
        AssetStagingRec."GRN Date" := PurchRcptLine."Posting Date";
        AssetStagingRec."GRN No." := PurchRcptLine."Document No.";
        AssetStagingRec.Type := PurchRcptLine.Type;
        AssetStagingRec."No." := PurchRcptLine."No.";
        AssetStagingRec.Description := PurchRcptLine.Description;
        AssetStagingRec."Vendor No." := PurchRcptLine."Buy-from Vendor No.";
        DimSetEntry.SetRange("Dimension Set ID", PurchaseLine."Dimension Set ID");
        DimSetEntry.SetFilter("Dimension Code", '%1', 'CAPEX');
        if DimSetEntry.Find('-') then begin
            DimensionValue.Reset();
            DimensionValue.SetFilter("Dimension Code", '%1', 'CAPEX');
            DimensionValue.SetRange(Code, DimSetEntry."Dimension Value Code");
            if DimensionValue.Find('-') then;
            AssetStagingRec."Capex Id" := DimSetEntry."Dimension Value Code";
            AssetStagingRec."Assets Name" := DimensionValue.Name;
        end

        else begin
            AssetStagingRec."Capex Id" := '';
            AssetStagingRec."Assets Name" := '';
        end;
        //  AssetStagingRec."Capex Id" := PurchaseHeader.
        Vendor.Get(AssetStagingRec."Vendor No.");
        AssetStagingRec."Vendor Name" := Vendor.Name;
        AssetStagingRec."Asset Group" := '';
        Item.Get(PurchRcptLine."No.");
        AssetStagingRec."Capitalization Type" := Item."E3Capitalization Type";
        AssetStagingRec."Gen. Prod. Posting Group" := PurchRcptLine."Gen. Prod. Posting Group";
        AssetStagingRec."Location Code" := PurchRcptLine."Location Code";
        AssetStagingRec.Quantity := PurchaseLine.Quantity;
        AssetStagingRec."Unit of Measure" := PurchRcptLine."Unit of Measure Code";
        AssetStagingRec."Quantity Received" := PurchRcptLine.Quantity;
        AssetStagingRec."Direct Unit Cost" := PurchRcptLine."Direct Unit Cost";
        AssetStagingRec."Line Amount" := PurchaseLine."Line Amount";
        AssetStagingRec."Line Discount Per" := PurchaseLine."Line Discount %";
        AssetStagingRec."Line Discount Amount" := PurchaseLine."Line Discount Amount";
        AssetStagingRec."GST Group Code" := PurchRcptLine."GST Group Code";
        AssetStagingRec."HSN/SAC Code" := PurchRcptLine."HSN/SAC Code";
        AssetStagingRec."GST Assessable Value" := PurchRcptLine."GST Assessable Value";
        AssetStagingRec."GST Group Type" := PurchRcptLine."GST Group Type";
        AssetStagingRec.Exempted := PurchRcptLine.Exempted;
        AssetStagingRec."Asset Group" := Item."E3 Assets Group";
        AssetStagingRec."GST Jurisdiction Type" := PurchRcptLine."GST Jurisdiction Type";
        AssetStagingRec."GST Credit" := PurchRcptLine."GST Credit";
        AssetStagingRec."Asset Details Created" := false;
        AssetStagingRec."Detailed Entry No." := 0;
        AssetStagingRec."Vendor Invoice No." := PurchaseHeader."Vendor Invoice No.";
        AssetStagingRec."Department Id" := PurchaseHeader."Shortcut Dimension 2 Code";
        AssetStagingRec."Amount/Qty" := PurchaseLine."Line Amount" / PurchRcptLine.Quantity;
        Evaluate(GSTPercent, PurchaseLine."GST Group Code");
        if AssetStagingRec."GST Credit" = "GST Credit"::"Non-Availment" then
            AssetStagingRec."GST Amount" := PurchaseLine."Line Amount" * GSTPercent / 100;

        AssetStagingRec.Insert();
        //    end
    end;

    procedure GenerateAssetDetails()
    var
        AssetsStaging: Record "E3 Asset Staging";
        PrevPo: Code[20];
        CapexId: Code[50];
    begin
        PrevPo := '';
        CapexId := '';
        AssetsStaging.SetFilter("Asset Details Created", '%1', false);
        AssetsStaging.SetCurrentKey("Capex Id");
        if AssetsStaging.FindSet() then
            repeat
                if (CapexId <> AssetsStaging."Capex Id") then begin
                    // PrevPo := AssetsStaging."PO No.";
                    CapexId := AssetsStaging."Capex Id";
                    InsertAssetsDetails(AssetsStaging);
                end;

            until AssetsStaging.Next() = 0;
        Message('Asset Details created successfully.');

    end;

    procedure GenerateAssetReference()
    var
        AssetDetails: Record "E3 Assets Details";
        PrevPo: Code[20];
        CapexId: Code[20];
        CapType: Enum "E3 Capitalization Type";
    begin
        PrevPo := '';
        CapexId := '';
        AssetDetails.SetFilter("Asset Reference Created", '%1', false);
        AssetDetails.SetCurrentKey("Capex Id", "Capitalization Type");
        if AssetDetails.FindSet() then
            repeat
                if ((CapexId <> AssetDetails."Capex Id")
                AND (CapType <> AssetDetails."Capitalization Type")) then begin
                    PrevPo := AssetDetails."PO No.";
                    CapexId := AssetDetails."Capex Id";
                    CapType := AssetDetails."Capitalization Type";
                    GenerateAssetId(AssetDetails);
                end;
            until AssetDetails.Next() = 0;
        Message('Asset Reference created successfully.');

    end;

    procedure GenerateAssetId(AssetDetails: Record "E3 Assets Details")
    var
        AssetDetailsRef: Record "E3 Assets Details";
        AssetDetailsM2O: Record "E3 Assets Details";
        AssetGroup: Record "E3 Assets Group";
        Item: Record Item;
        NoSeqMgmt: Codeunit "No. Series";
        NextNo: Code[20];
        i: Integer;
    begin
        // AssetDetailsRef.SetRange("PO No.", AssetDetails."PO No.");
        AssetDetailsRef.SetRange("Capex Id", AssetDetails."Capex Id");
        AssetDetailsRef.SetRange("Capitalization Type", AssetDetails."Capitalization Type");
        AssetDetailsRef.SetRange("Asset Reference Created", false);
        if AssetDetailsRef.FindSet() then
            repeat
                case AssetDetailsRef."Capitalization Type" of
                    "E3 Capitalization Type"::One2Many:
                        begin
                            Item.Get(AssetDetailsRef."No.");
                            AssetGroup.Get(Item."E3 Assets Group", AssetDetailsRef."Location Code");
                            if (AssetGroup."Number Sequence" <> '') then begin
                                AssetDetailsRef."Assets Reference" := NoSeqMgmt.GetNextNo(AssetGroup."Number Sequence");
                                // AssetDetailsRef."Assets Name" := AssetGroup."Default Assets Name";
                                AssetDetailsRef."Asset Reference Created" := true;
                                AssetDetailsRef."FA Sub Class" := AssetGroup."FA Sub Class";
                                AssetDetailsRef."Depreciation Years" := AssetGroup."Depreciation Years";
                                AssetDetailsRef."Depreciation %" := AssetGroup."Depreciation %";
                                AssetDetailsRef."Depreciation Method" := AssetGroup."Depreciation Method";
                                AssetDetailsRef."Put to use Date (ITSM)" := 0D;
                                AssetDetailsRef."Asset uniqe ID (ITSM)" := '';
                                AssetDetailsRef.AssetCreated := false;
                                AssetDetailsRef.Modify(true);
                            end else
                                Message('Number sequence setup is missed for %1 Asset Group', AssetGroup.AssetsGroup);
                        end;
                    "E3 Capitalization Type"::Many2One:
                        begin
                            Item.Get(AssetDetailsRef."No.");
                            AssetGroup.Get(Item."E3 Assets Group", AssetDetailsRef."Location Code");
                            if (AssetGroup."Number Sequence" <> '') then begin
                                NextNo := NoSeqMgmt.GetNextNo(AssetGroup."Number Sequence");
                                AssetDetailsM2O.SetRange("PO No.", AssetDetailsRef."PO No.");
                                AssetDetailsM2O.SetRange("Capex Id", AssetDetailsRef."Capex Id");
                                AssetDetailsM2O.SetRange("Capitalization Type", AssetDetailsRef."Capitalization Type");
                                AssetDetailsM2O.SetRange("Asset Reference Created", false);
                                if AssetDetailsM2O.FindSet() then
                                    repeat
                                        AssetDetailsM2O."Assets Reference" := NextNo;
                                        // AssetDetailsM2O."Assets Name" := AssetGroup."Default Assets Name";
                                        AssetDetailsM2O."Asset Reference Created" := true;
                                        AssetDetailsM2O."FA Sub Class" := AssetGroup."FA Sub Class";
                                        AssetDetailsM2O."Depreciation Years" := AssetGroup."Depreciation Years";
                                        AssetDetailsM2O."Depreciation %" := AssetGroup."Depreciation %";
                                        AssetDetailsM2O."Depreciation Method" := AssetGroup."Depreciation Method";
                                        AssetDetailsM2O."Put to use Date (ITSM)" := 0D;
                                        AssetDetailsM2O."Asset uniqe ID (ITSM)" := '';
                                        AssetDetailsM2O.AssetCreated := false;
                                        AssetDetailsM2O.Modify(true);
                                    until AssetDetailsM2O.Next() = 0;
                            end else
                                Message('Number sequence setup is missed for %1 Asset Group', AssetGroup.AssetsGroup);
                        end;
                end;
            until AssetDetailsRef.Next() = 0;
    end;

    procedure InsertAssetsDetails(AssetsStaging: Record "E3 Asset Staging")
    var
        AssetStagingInsert: Record "E3 Asset Staging";
        AssetDetailsInsert: Record "E3 Assets Details";
        i: Integer;
    begin
        //AssetStagingInsert.SetRange("PO No.", AssetsStaging."PO No.");
        AssetStagingInsert.SetRange("Capex Id", AssetsStaging."Capex Id");
        AssetStagingInsert.SetRange("Asset Details Created", false);
        if AssetStagingInsert.FindSet() then
            repeat
                case AssetStagingInsert."Capitalization Type" of
                    "E3 Capitalization Type"::One2Many:
                        One2ManyInsert(AssetStagingInsert);
                    "E3 Capitalization Type"::Many2One:
                        Many2OneInsert(AssetStagingInsert);
                end;
            until AssetStagingInsert.Next() = 0;
    end;

    procedure One2ManyInsert(AssetsStaging: Record "E3 Asset Staging")
    var
        AssetDetailsInsert: Record "E3 Assets Details";
        AssetsGroup: REcord "E3 Assets Group";
        Eno: Integer;
        i: Integer;

    begin
        for i := 1 to AssetsStaging."Quantity Received" do begin
            AssetDetailsInsert.Init();
            if AssetDetailsInsert.FindLast() then
                AssetDetailsInsert."Entry No." := AssetDetailsInsert."Entry No." + 1
            else
                AssetDetailsInsert."Entry No." := 1;
            Eno := AssetDetailsInsert."Entry No.";
            AssetDetailsInsert.Type := AssetsStaging.Type;
            AssetDetailsInsert."No." := AssetsStaging."No.";
            AssetDetailsInsert.Description := AssetsStaging.Description;
            AssetDetailsInsert."Vendor Name" := AssetsStaging."Vendor Name";
            AssetDetailsInsert."PO No." := AssetsStaging."PO No.";
            AssetDetailsInsert."Capex Id" := AssetsStaging."Capex Id";
            AssetDetailsInsert."GRN No." := AssetsStaging."GRN No.";
            AssetDetailsInsert."Vendor No." := AssetsStaging."Vendor No.";
            AssetDetailsInsert."GRN Date" := AssetsStaging."GRN Date";
            AssetDetailsInsert."Asset Group" := AssetsStaging."Asset Group";
            AssetDetailsInsert.Quantity := 1;
            AssetDetailsInsert."Unit of Measure" := AssetsStaging."Unit of Measure";
            AssetDetailsInsert."Capitalization Type" := AssetsStaging."Capitalization Type";
            AssetDetailsInsert."Location Code" := AssetsStaging."Location Code";
            AssetDetailsInsert."Assets Reference" := '';
            AssetDetailsInsert."Asset Reference Created" := false;
            AssetDetailsInsert."Assets Name" := AssetsStaging."Assets Name";
            AssetDetailsInsert."Vendor Invoice No." := AssetsStaging."Vendor Invoice No.";
            AssetDetailsInsert.Status := '';
            AssetDetailsInsert.ITSMSend := false;
            AssetDetailsInsert."Department Id" := AssetsStaging."Department Id";
            AssetDetailsInsert.Amount := AssetsStaging."Line Amount";
            AssetDetailsInsert."Amount/Qty" := AssetsStaging."Amount/Qty";
            AssetDetailsInsert."GST Amount" := AssetsStaging."GST Amount" / AssetsStaging."Quantity Received";
            AssetDetailsInsert."Put to use Date (ITSM)" := 0D;
            AssetDetailsInsert."Asset uniqe ID (ITSM)" := '';
            AssetDetailsInsert.Insert();
            //  AssetsGroup.Get(AssetsStaging."Asset Group");
        end;
        AssetsStaging."Asset Details Created" := true;
        AssetsStaging."Detailed Entry No." := Eno;
        AssetsStaging.Modify();
    end;

    procedure Many2OneInsert(AssetsStaging: Record "E3 Asset Staging")
    var
        AssetDetailsInsert: Record "E3 Assets Details";
        AssetstagingM2O: Record "E3 Asset Staging";
        Assetstg: Record "E3 Asset Staging";
        ENo: Integer;
    begin
        // Filter staging records
        AssetstagingM2O.Reset();
        AssetstagingM2O.SetRange("Capex Id", AssetsStaging."Capex Id");
        AssetstagingM2O.SetRange("Asset Details Created", false);
        AssetstagingM2O.SetRange("Capitalization Type", AssetsStaging."Capitalization Type");

        if AssetstagingM2O.FindFirst() then begin
            // Get next Entry No.
            AssetDetailsInsert.Reset();
            AssetDetailsInsert.Init();
            if AssetDetailsInsert.FindLast() then
                ENo := AssetDetailsInsert."Entry No." + 1
            else
                ENo := 1;

            AssetDetailsInsert."Entry No." := ENo;
            AssetDetailsInsert.Type := AssetstagingM2O.Type;
            AssetDetailsInsert."No." := AssetstagingM2O."No.";
            AssetDetailsInsert.Description := AssetstagingM2O.Description;
            AssetDetailsInsert."Vendor Name" := AssetstagingM2O."Vendor Name";
            AssetDetailsInsert."PO No." := AssetstagingM2O."PO No.";
            AssetDetailsInsert."Capex Id" := AssetstagingM2O."Capex Id";
            AssetDetailsInsert."GRN No." := AssetstagingM2O."GRN No.";
            AssetDetailsInsert."Vendor No." := AssetstagingM2O."Vendor No.";
            AssetDetailsInsert."GRN Date" := AssetstagingM2O."GRN Date";
            AssetDetailsInsert."Asset Group" := AssetstagingM2O."Asset Group";
            AssetDetailsInsert.Quantity := 1;
            AssetDetailsInsert."Unit of Measure" := AssetstagingM2O."Unit of Measure";
            AssetDetailsInsert."Capitalization Type" := AssetstagingM2O."Capitalization Type";
            AssetDetailsInsert."Location Code" := AssetstagingM2O."Location Code";
            AssetDetailsInsert."Assets Reference" := '';
            AssetDetailsInsert."Asset Reference Created" := false;
            AssetDetailsInsert."Assets Name" := AssetstagingM2O."Assets Name";
            AssetDetailsInsert."Vendor Invoice No." := AssetstagingM2O."Vendor Invoice No.";
            AssetDetailsInsert.Status := '';
            AssetDetailsInsert.ITSMSend := false;
            AssetDetailsInsert."Department Id" := AssetstagingM2O."Department Id";
            AssetDetailsInsert.Amount := AssetstagingM2O."Line Amount";
            AssetDetailsInsert."Amount/Qty" := AssetstagingM2O."Line Amount";
            AssetDetailsInsert."GST Amount" := AssetstagingM2O."GST Amount";
            AssetDetailsInsert."Put to use Date (ITSM)" := 0D;
            AssetDetailsInsert."Asset uniqe ID (ITSM)" := '';
            AssetDetailsInsert.Insert();
            // Update all related staging records (Many → One)
            Assetstg.Reset();
            Assetstg.SetRange("Capex Id", AssetstagingM2O."Capex Id");
            Assetstg.SetRange("Asset Details Created", false);
            Assetstg.SetRange("Capitalization Type", AssetstagingM2O."Capitalization Type");
            if Assetstg.FindSet() then
                repeat
                    Assetstg."Asset Details Created" := true;
                    Assetstg."Detailed Entry No." := ENo;
                    Assetstg.Modify();
                until Assetstg.Next() = 0;

        end;
    end;

    procedure CreateFixedAsset(E3_Assetdetails: Record "E3 Assets Details")
    var
        FixedAsset: Record "Fixed Asset";
        FADepBook: Record "FA Depreciation Book";
        FASubclass: Record "FA Subclass";
    begin
        // Initialize Fixed Asset
        FixedAsset.Init();
        FixedAsset."No." := E3_Assetdetails."Assets Reference";   // You can also use NoSeriesManagement
        FixedAsset.Description := E3_Assetdetails."Assets Name";
        FASubclass.get(E3_Assetdetails."FA Sub Class");
        FixedAsset."Description 2" := E3_Assetdetails."Asset uniqe ID (ITSM)";
        FixedAsset."FA Class Code" := FASubclass."FA Class Code";
        FixedAsset."FA Subclass Code" := FASubclass.Code;
        FixedAsset."FA Posting Group" := FASubclass."Default FA Posting Group";
        FixedAsset."Vendor No." := E3_Assetdetails."Vendor No.";
        FixedAsset.Insert(true);

        // Create Depreciation Book
        FADepBook.Init();
        FADepBook."FA No." := FixedAsset."No.";
        FADepBook."Depreciation Book Code" := 'COMPANY';
        FADepBook."Depreciation Method" := E3_Assetdetails."Depreciation Method";
        FADepBook."Depreciation Starting Date" := E3_Assetdetails."Put to use Date (ITSM)";
        FADepBook."No. of Depreciation Years" := E3_Assetdetails."Depreciation Years";
        if (E3_Assetdetails."Depreciation Method" = "FA Depreciation Method"::"Declining-Balance 1") then
            FADepBook."Declining-Balance %" := E3_Assetdetails."Depreciation %";
        if (E3_Assetdetails."Depreciation Method" = "FA Depreciation Method"::"Straight-Line") then
            FADepBook."Straight-Line %" := E3_Assetdetails."Depreciation %";
        FADepBook."FA Posting Group" := FASubclass."Default FA Posting Group";
        FADepBook.Insert(true);
        E3_Assetdetails.AssetCreated := true;
        E3_Assetdetails.Modify();
        Message('Asset %1 created successfully.', FixedAsset."No.");
    end;

    procedure CreateAndPostFAJournal(AssetDetails: Record "E3 Assets Details")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        FixedAsset: Record "Fixed Asset";
        NoSeriesMgt: Codeunit "No. Series";
        FAPostingGroup: Record "FA Posting Group";
        NextDocNo: Code[20];
        LineNo: Integer;
        DimMgt: Codeunit DimensionManagement;
        ShortcutDimCode: array[8] of Code[20];
        GenPostingSetup: Record "General Posting Setup";
        vendor: Record Vendor;
        Item: Record Item;
    begin
        // Get Fixed Asset
        FixedAsset.Get(AssetDetails."Assets Reference");
        FAPostingGroup.Reset();
        FAPostingGroup.SetRange(Code, FixedAsset."FA Posting Group");
        if FAPostingGroup.Find('-') then;

        // Get Journal Batch
        GenJnlBatch.Get('ASSETS', 'FAJNL-40');

        // Get next document number
        if GenJnlBatch."No. Series" <> '' then
            NextDocNo := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", Today(), true);

        // Find next line number
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatch.Name);

        if GenJnlLine.FindLast() then
            LineNo := GenJnlLine."Line No." + 10000
        else
            LineNo := 10000;

        vendor.Get(AssetDetails."Vendor No.");
        Item.Get(AssetDetails."No.");
        GenPostingSetup.Reset();
        GenPostingSetup.SetRange("Gen. Bus. Posting Group", vendor."Gen. Bus. Posting Group");
        GenPostingSetup.SetRange("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        if GenPostingSetup.Find('-') Then;

        // Create Journal Line
        GenJnlLine.Init();
        GenJnlLine.Validate("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.Validate("Journal Batch Name", GenJnlBatch.Name);

        // GenJnlLine.Validate(sho);

        GenJnlLine."Line No." := LineNo;

        GenJnlLine.Validate("Posting Date", Today());
        GenJnlLine.Validate("Document No.", NextDocNo);

        // Fixed Asset
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"Fixed Asset");
        GenJnlLine.Validate("Account No.", AssetDetails."Assets Reference");


        // FA Posting Type
        GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::"Acquisition Cost");

        // Amount
        GenJnlLine.Validate(Amount, AssetDetails."Amount/Qty" + AssetDetails."GST Amount");

        // Balancing Account
        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
        GenJnlLine.Validate("Bal. Account No.", GenPostingSetup."Purch. Account");
        ShortcutDimCode[1] := AssetDetails."Location Code";
        DimMgt.ValidateShortcutDimValues(1, ShortcutDimCode[1], GenJnlLine."Dimension Set ID");

        ShortcutDimCode[2] := AssetDetails."Department Id";
        DimMgt.ValidateShortcutDimValues(2, ShortcutDimCode[2], GenJnlLine."Dimension Set ID");

        ShortcutDimCode[7] := AssetDetails."Capex Id";
        DimMgt.ValidateShortcutDimValues(7, ShortcutDimCode[7], GenJnlLine."Dimension Set ID");
        GenJnlLine.Validate("Shortcut Dimension 1 Code", AssetDetails."Location Code");
        GenJnlLine.Validate("Shortcut Dimension 2 Code", AssetDetails."Department Id");

        GenJnlLine.Insert(true);

        Message('Fixed Asset Journal created with Document No. %1 for Asset %2',
            NextDocNo, AssetDetails."Assets Reference");
    end;

    procedure CreateAndPostFAJournal_Old(AssetDetails: Record "E3 Assets Details")
    var
        FAJnlLine: Record "FA Journal Line";
        FAJnlPost: Codeunit "FA Jnl.-Post Line";
        FASetup: Record "FA Setup";
        GenJnlBatch: Record "FA Journal Batch";
        LineNo: Integer;

        Fixedasset: Record "Fixed Asset";
    begin
        // Get FA Setup
        FASetup.Get();
        Fixedasset.Get(AssetDetails."Assets Reference");

        // Get Journal Batch (must exist)
        GenJnlBatch.Get('DEFAULT', 'DEFAULT'); // Template Name, Batch Name

        // Find next line no.
        FAJnlLine.Reset();
        FAJnlLine.SetRange("Journal Template Name", 'DEFAULT');
        FAJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
        if FAJnlLine.FindLast() then
            LineNo := FAJnlLine."Line No." + 10000
        else
            LineNo := 10000;

        // Create Journal Line
        FAJnlLine.Init();
        FAJnlLine."Journal Template Name" := 'DEFAULT';
        FAJnlLine."Journal Batch Name" := 'DEFAULT';
        FAJnlLine."Line No." := LineNo;

        FAJnlLine."FA No." := AssetDetails."Assets Reference";
        FAJnlLine.Validate("FA Posting Date", Today());
        FAJnlLine.Validate("Document No.", 'FA-ACQ-001');
        FAJnlLine.Validate("FA Posting Type", FAJnlLine."FA Posting Type"::"Acquisition Cost");
        FAJnlLine.Validate("FA Posting Group", Fixedasset."FA Posting Group");
        FAJnlLine.Validate(Amount, AssetDetails.Amount);

        FAJnlLine.Insert(true);
        AssetDetails.JournalCreated := true;
        AssetDetails.Modify();
        Message('Journal Line for Asset %1 created successfully.', AssetDetails."Assets Reference");

        // Post Journal Line
        // FAJnlPost.Run(FAJnlLine);
    end;


}