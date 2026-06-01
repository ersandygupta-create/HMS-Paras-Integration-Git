query 50027 "E3 Posted GL Budget Entry"
{
    APIGroup = 'apiHIS';
    APIPublisher = 'edhate';
    APIVersion = 'v2.0';
    Caption = 'Posted GL Budget Entry';
    EntityName = 'postedBudgetEntry';
    EntitySetName = 'postedBudgetEntrys';
    QueryType = API;

    elements
    {
        dataitem(BudgetLayout; "EDC Budget Layout")
        {
            column(sNo; "S. No.")
            {
            }
            column(budgetName; "Budget Name") { }
            column(itemType; "Item Type") { }
            column(toGLAccountNo; "To G/L Account No.") { }
            column(toGlobalDimension1code; "To Global Dimension 1 code") { }
            column(toGlobalDimension2code; "To Global Dimension 2 code") { }
            column(toDate; "To Date") { }
            column(budgetType; "Budget Type") { }
            column(toAmount; "To Amount") { }
            column(fromAmount; "From Amount") { }
            column(fromGLAccountNo; "From G/L Account No.") { }
            column(fromGlobalDimension1code; "From Global Dimension 1 code") { }
            column(fromGlobalDimension2code; "From Global Dimension 2 code") { }
            column(fromDate; "From Date") { }
            column(description; Description) { }
            column(remarks; Remarks) { }
            column(createdDateTime; "Created DateTime") { }
            column(createdUSERID; "Created USER ID") { }
            column(modifiedDateTime; "Modified DateTime") { }
            column(modifiedUSERID; "Modified USER ID") { }
            column(posted; Posted) { }
            column(postedUserID; "Posted User ID") { }
            column(postedDateTime; "Posted DateTime") { }
            column(toBudgetDimension1Code; "To Budget Dimension 1 Code") { }
            column(toBudgetDimension2Code; "To Budget Dimension 2 Code") { }
            column(toBudgetDimension3Code; "To Budget Dimension 3 Code") { }
            column(toBudgetDimension4Code; "To Budget Dimension 4 Code") { }
            column(toBudgetDimension5Code; "To Budget Dimension 5 Code") { }
            column(toBudgetDimension6Code; "To Budget Dimension 6 Code") { }
            column(toBudgetDimension7Code; "To Budget Dimension 7 Code") { }
            column(toBudgetDimension8Code; "To Budget Dimension 8 Code") { }
            column(fromBudgetDimension1Code; "From Budget Dimension 1 Code") { }
            column(fromBudgetDimension2Code; "From Budget Dimension 2 Code") { }
            column(fromBudgetDimension3Code; "From Budget Dimension 3 Code") { }
            column(fromBudgetDimension4Code; "From Budget Dimension 4 Code") { }
            column(fromBudgetDimension5Code; "From Budget Dimension 5 Code") { }
            column(fromBudgetDimension6Code; "From Budget Dimension 6 Code") { }
            column(fromBudgetDimension7Code; "From Budget Dimension 7 Code") { }
            column(fromBudgetDimension8Code; "From Budget Dimension 8 Code") { }
            column(spendCode; "EDC Spend Code") { }
            column(spendName; "EDC Spend Name") { }
            column(costElementCode; "EDC Cost Element Code") { }
            column(costElementName; "EDC Cost Element Name") { }
            column(financialYear; "EDC Financial Year") { }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}