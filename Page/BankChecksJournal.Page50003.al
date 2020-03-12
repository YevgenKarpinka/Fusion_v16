page 50003 "Bank Checks Journal"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Bank Check Journal Line";
    SourceTableView = where(Status = const(New));
    AccessByPermission = tabledata "Bank Check Journal Line" = rimd;

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
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Last Modified DateTime"; "Last Modified DateTime")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Confirm)
            {
                ApplicationArea = All;
                Image = Approval;
                CaptionML = ENU = 'Confirm', RUS = 'Подтвердить';

                trigger OnAction()
                var
                    _BankCheck: Record "Bank Check Journal Line";
                begin
                    CurrPage.SetSelectionFilter(_BankCheck);
                    if _BankCheck.FindSet(false, false) then
                        repeat
                            _BankCheckMgt.SetBankCheckStatus(_BankCheck, _BankCheck.Status::Confirmed);
                        until _BankCheck.Next() = 0;
                end;
            }
            action(Reject)
            {
                ApplicationArea = All;
                Image = Reject;
                CaptionML = ENU = 'Reject', RUS = 'Отказать';

                trigger OnAction()
                var
                    _BankCheck: Record "Bank Check Journal Line";
                begin
                    CurrPage.SetSelectionFilter(_BankCheck);
                    if _BankCheck.FindSet(false, false) then
                        repeat
                            _BankCheckMgt.SetBankCheckStatus(_BankCheck, _BankCheck.Status::Rejected);
                        until _BankCheck.Next() = 0;
                end;
            }
        }
    }

    var
        _BankCheckMgt: Codeunit "Bank Checks Mgt.";
}