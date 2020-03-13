codeunit 50003 "Bank Checks Mgt."
{
    Permissions = tabledata "General Ledger Setup" = r, tabledata "Bank Check Journal Line" = rimd,
    tabledata "Gen. Journal Line" = rimd, tabledata "Gen. Journal Template" = r,
    tabledata "Gen. Journal Batch" = r, tabledata "G/L Entry" = r;

    trigger OnRun()
    begin

    end;

    procedure SetBankCheckStatus(_BankCheck: Record "Bank Check Journal Line"; _newStatus: Integer)
    begin
        with _BankCheck do begin
            if _newStatus = 0 then begin
                if Status = Status::Rejected then begin
                    Status := _newStatus;
                end;
            end else begin
                Status := _newStatus;
            end;
            Modify(true);
            if Status = Status::Confirmed then begin
                // Create Payment Journal Line
                CreatePaymentFromBankCheck(_BankCheck);
            end;
        end;
    end;

    local procedure GetGLSetup()
    begin
        GLSetup.Get();
    end;

    procedure CreatePaymentFromBankCheck(_BankCheck: Record "Bank Check Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        procesGenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        LineNo: Integer;
    begin
        GetGLSetup();
        GLSetup.TestField("Journal Template Name");
        GLSetup.TestField("Journal Batch Name");
        GenJnlTemplate.GET(GLSetup."Journal Template Name");
        GenJnlBatch.GET(GLSetup."Journal Template Name", GLSetup."Journal Batch Name");
        GenJnlBatch.TestField("No. Series");
        GenJnlTemplate.TestField("Source Code");
        // GenJnlBatch.TestField("Reason Code");

        with procesGenJnlLine do begin
            SetRange("Journal Template Name", GLSetup."Journal Template Name");
            SetRange("Journal Batch Name", GLSetup."Journal Batch Name");
            SetRange("External Document No.", _BankCheck."Bank Check No.");
            SetRange("Document Date", _BankCheck."Bank Check Date");
            if not IsEmpty then
                exit; // instead; go to the document

            if PostedBankCheckExist(_BankCheck."Bank Check No.") then begin
                Message(msgBankCheckNoExist, _BankCheck."Bank Check No.");
                exit;
            end;

            SetRange("External Document No.");
            SetRange("Document Date");
            if FindLast() then
                LineNo := "Line No." + 10000
            else
                LineNo := 10000;
        end;

        with GenJnlLine do begin
            Init();
            "Journal Template Name" := GLSetup."Journal Template Name";
            "Journal Batch Name" := GLSetup."Journal Batch Name";
            "Line No." := LineNo;

            "Posting Date" := _BankCheck."Bank Check Date";
            "Document Date" := _BankCheck."Bank Check Date";

            CLEAR(NoSeriesMgt);
            "Document No." := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", "Posting Date", true);

            "Account Type" := "Account Type"::Customer;
            "Document Type" := "Document Type"::Payment;

            Validate("Account No.", _BankCheck."Customer No.");

            "Bal. Account Type" := GenJnlBatch."Bal. Account Type";
            VALIDATE("Bal. Account No.", GenJnlBatch."Bal. Account No.");

            Validate(Amount, -_BankCheck.Amount);
            Description := COPYSTR(_BankCheck.Description, 1, MAXSTRLEN(Description));
            "External Document No." := _BankCheck."Bank Check No.";

            "Source Code" := GenJnlTemplate."Source Code";
            // "Reason Code" := GenJnlBatch."Reason Code";
            "Posting No. Series" := GenJnlBatch."Posting No. Series";
            "System-Created Entry" := true;


            UpdateJournalBatchID();
            Insert(true);
        end;
    end;


    local procedure PostedBankCheckExist(BankCheckNo: Code[35]): Boolean
    var
        GLEntry: Record "G/L Entry";
    begin
        with GLEntry do begin
            SetCurrentKey("External Document No.");
            SetRange("External Document No.", BankCheckNo);
            exit(not IsEmpty);
        end;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        msgBankCheckNoExist: TextConst ENU = 'Bank Check No = %1 Exist!', RUS = 'Банковский Чек Но = %1 существует!';
}