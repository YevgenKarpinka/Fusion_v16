page 50004 "Bank Checks Archive"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "Bank Check Journal Line";
    AccessByPermission = tabledata "Bank Check Journal Line" = rimd;
    SourceTableView = where(Status = filter(<> New));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field("Bank Check Date"; "Bank Check Date")
                {
                    ApplicationArea = All;
                }
                field("Bank Check No."; "Bank Check No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last Modified DateTime"; "Last Modified DateTime")
                {
                    ApplicationArea = All;
                    // Visible = false;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReturnToJournal)
            {
                ApplicationArea = All;
                Image = Approval;
                CaptionML = ENU = 'Return to Journal', RUS = 'Вернуть в журнал';

                trigger OnAction()
                var
                    _BankCheck: Record "Bank Check Journal Line";
                begin
                    CurrPage.SetSelectionFilter(_BankCheck);
                    if _BankCheck.FindSet(false, false) then
                        repeat
                            _BankCheckMgt.SetBankCheckStatus(_BankCheck, _BankCheck.Status::New);
                        until _BankCheck.Next() = 0;
                end;
            }
        }
    }

    var
        _BankCheckMgt: Codeunit "Bank Checks Mgt.";
}