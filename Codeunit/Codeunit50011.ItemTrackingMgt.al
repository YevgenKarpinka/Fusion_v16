codeunit 50011 "Item Tracking Mgt."
{
    procedure GetItemTrackingSerialNo(ILE_EntryNo: Integer): Code[50]
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Serial No.")
        else
            exit('');
    end;

    procedure GetItemTrackingLotNo(ILE_EntryNo: Integer): Code[50]
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Lot No.")
        else
            exit('');
    end;

    procedure GetItemTrackingQty(ILE_EntryNo: Integer): Decimal
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry.Quantity * -1)
        else
            exit(0);
    end;

    procedure GetItemTrackingWarrantyDate(ILE_EntryNo: Integer): Date
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Warranty Date")
        else
            exit(0D);
    end;

    procedure GetItemTrackingExpirationDate(ILE_EntryNo: Integer): Date
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Expiration Date")
        else
            exit(0D);
    end;

    procedure GetItemTrackingExpirationDateByLotNo(LotNo: Code[50]; ItemNo: Code[20]): Date
    begin
        with glItemLedgerEntry do begin
            SetCurrentKey("Item No.", "Lot No.");
            SetRange("Item No.", ItemNo);
            SetRange("Lot No.", LotNo);
            if FindFirst() then
                exit("Expiration Date")
            else
                exit(0D);
        end;
    end;

    procedure GetItemTrackingWarrantyDateByLotNo(LotNo: Code[50]; ItemNo: Code[20]): Date
    begin
        with glItemLedgerEntry do begin
            SetCurrentKey("Item No.", "Lot No.");
            SetRange("Item No.", ItemNo);
            SetRange("Lot No.", LotNo);
            if FindFirst() then
                exit("Warranty Date")
            else
                exit(0D);
        end;
    end;

    local procedure GetILE(ILE_EntryNo: Integer): Boolean
    begin
        exit(glItemLedgerEntry.Get(ILE_EntryNo));
    end;

    // modify  "Whse.-Shpt Create Pick Avail" to "Whse.-Shpt Create Pick" after test
    [EventSubscriber(ObjectType::Report, Report::"Whse.-Shpt Create Pick Avail", 'OnBeforeSortWhseActivHeaders', '', true, true)]
    local procedure HandleHideNothingToHandleError(FirstActivityNo: Code[20]; LastActivityNo: Code[20]; var WhseActivHeader: Record "Warehouse Activity Header"; var HideNothingToHandleError: Boolean)
    var
        WhseMoveNo: Code[20];
    begin
        if AllCompletePicked(WhseActivHeader) then exit;

        if WhseActivHeader.FindSet(false, false) then
            repeat
                if not CompletePicked(WhseActivHeader."No.") then begin
                    WhsePickToWhseMove(WhseActivHeader."No.", WhseMoveNo);
                    UpdateMoveLines(WhseMoveNo);
                end;
                WhseActivHeader.Delete(true);
            until WhseActivHeader.Next() = 0;

        // to do update warehouse pick serial no. line

        FirstActivityNo := '';
        LastActivityNo := '';
        HideNothingToHandleError := true;
        Message(msgWhseMoveCreated, WhseMoveNo);
    end;

    local procedure UpdateMoveLines(WhseMoveNo: Code[20])
    var
        WhseMoveLine: Record "Warehouse Activity Line";
        // WhseMoveLineForDelete: Record "Warehouse Activity Line";
        tempItem: Record Item temporary;
        ToBinCode: Code[20];
        ToZoneCode: Code[20];
        LineNoForDelete: Integer;
        QtyToMove: Decimal;
    begin
        // create item list to whse move
        with WhseMoveLine do begin
            SetCurrentKey("Action Type", "Bin Code", "Item No.");
            SetRange("Activity Type", "Activity Type"::Movement);
            SetRange("No.", WhseMoveNo);
            SetRange("Action Type", "Action Type"::Take);
            SetRange("Bin Code", '');
            if FindSet(false, false) then
                repeat
                    if not tempItem.Get("Item No.") then begin
                        tempItem."No." := "Item No.";
                        tempItem.Insert();
                    end;
                until Next() = 0;
        end;

        if tempItem.FindFirst() then begin
            // WhseMoveLine.Reset();
            repeat
                // get ToBin from Take where Bin Code exist
                ToBinCode := '';
                ToZoneCode := '';
                LineNoForDelete := 0;

                with WhseMoveLine do begin
                    // SetCurrentKey("Action Type", "Bin Code", "Item No.");
                    // SetRange("Activity Type", "Activity Type"::Movement);
                    // SetRange("No.", WhseMoveNo);
                    // SetRange("Action Type", "Action Type"::Take);
                    SetFilter("Bin Code", '<>%1', '');
                    SetRange("Item No.", tempItem."No.");
                    if FindFirst() then begin
                        ToBinCode := "Bin Code";
                        ToZoneCode := "Zone Code";
                        LineNoForDelete := "Line No.";
                        QtyToMove += Quantity;
                    end;
                end;

                // modify Place record
                with WhseMoveLine do begin
                    // SetCurrentKey("Action Type", "Bin Code", "Item No.");
                    // SetRange("Activity Type", "Activity Type"::Movement);
                    // SetRange("No.", WhseMoveNo);
                    SetFilter("Line No.", '<>%1', LineNoForDelete + 10000);
                    SetRange("Action Type", "Action Type"::Place);
                    // SetFilter("Bin Code", '<>%1', '');
                    // SetRange("Item No.", tempItem."No.");
                    if FindSet(false, true) then
                        repeat
                            Validate("Zone Code", ToZoneCode);
                            Validate("Bin Code", ToBinCode);
                            Modify();
                        until Next() = 0;
                end;

                // delete record completted for pick
                if LineNoForDelete <> 0 then
                    with WhseMoveLine do begin
                        Reset();
                        SetRange("Activity Type", "Activity Type"::Movement);
                        SetRange("No.", WhseMoveNo);
                        SetRange("Line No.", LineNoForDelete, LineNoForDelete + 10000);
                        if FindSet(false, false) then
                            repeat
                                Delete(); // to ensure correct item tracking update
                                DeleteBinContent("Action Type"::Place);
                                UpdateRelatedItemTrkg(WhseMoveLine);
                            until Next() = 0;
                    end;

            until tempItem.Next() = 0;
        end;
    end;

    local procedure AllCompletePicked(var WhsePickHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhsePickLine: Record "Warehouse Activity Line";
    begin
        if WhsePickHeader.FindFirst() then begin
            GetLocation(WhsePickHeader."Location Code");
            if not Location."Create Move" then exit(false);
        end else
            exit(false);

        with WhsePickLine do begin
            SetRange("Activity Type", WhsePickHeader.Type);
            SetRange("No.", WhsePickHeader."No.");
            SetRange("Action Type", "Action Type"::Take);
            SetRange("Bin Code", '');
            exit(IsEmpty);
        end;
    end;

    local procedure CompletePicked(WhsePickNo: Code[20]): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        with WhseActivLine do begin
            SetRange("Activity Type", "Activity Type"::Pick);
            SetRange("No.", WhsePickNo);
            SetRange("Action Type", "Action Type"::Take);
            SetRange("Bin Code", '');
            exit(IsEmpty);
        end;
    end;

    local procedure WhsePickToWhseMove(WhsePickNo: Code[20]; var WhseMoveNo: code[20])
    var
        WhsePickHeader: Record "Warehouse Activity Header";
        WhsePickLine: Record "Warehouse Activity Line";
        WhseMoveHeader: Record "Warehouse Activity Header";
        WhseMoveLine: Record "Warehouse Activity Line";
    begin
        with WhseMoveHeader do begin
            WhsePickHeader.Get(WhseMoveHeader.Type::Pick, WhsePickNo);
            Init();
            TransferFields(WhsePickHeader);
            Type := Type::Movement;
            "No." := '';
            Insert(true);
        end;

        with WhsePickLine do begin
            SetRange("Activity Type", "Activity Type"::Pick);
            SetRange("No.", WhsePickNo);
            FindSet(false, false);
            repeat
                WhseMoveLine.Init();
                WhseMoveLine.TransferFields(WhsePickLine);
                WhseMoveLine."Activity Type" := "Activity Type"::Movement;
                WhseMoveLine."No." := WhseMoveHeader."No.";
                WhseMoveLine.Insert(true);
            until Next() = 0;
        end;
        WhseMoveNo := WhseMoveHeader."No.";
    end;

    local procedure GetLocation(LocationCode: Code[20]);
    begin
        if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    var
        glItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
        msgWhseMoveCreated: TextConst ENU = 'Warehouse Move %1 created.',
                                      RUS = 'Складское передвижение %1 создано.';
}