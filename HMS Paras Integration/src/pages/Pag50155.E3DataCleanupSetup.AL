page 50155 "Data Clean-up Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Data Clean-up Setup";
    Caption = 'Data Clean-up Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Setup';

                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the table from which records will be cleaned up date-by-date.';
                }
                field("Date Field ID"; Rec."Date Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field ID of the Date or DateTime field to filter on for each cleanup run.';
                }
                field("Last Cleaned Date"; Rec."Last Cleaned Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the date that was last processed by the job queue cleanup. Clear this field if you want to restart processing from the earliest date in the table.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResetProgress)
            {
                ApplicationArea = All;
                Caption = 'Reset Clean-up Progress';
                ToolTip = 'Clears the Last Cleaned Date so the job queue starts cleaning from the earliest date available in the table.';
                Image = ResetStatus;

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to reset the Last Cleaned Date? The next batch job run will start from the earliest available date in the table.', false) then begin
                        Rec."Last Cleaned Date" := 0D;
                        Rec.Modify(true);
                        Message('Clean-up progress has been reset.');
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Ensure a setup record exists when opening the page
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}