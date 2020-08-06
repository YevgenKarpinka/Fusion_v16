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
        if not Confirm(cnfCreateWahseMove, true) then exit;

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
        WhseMoveLineForSplit: Record "Warehouse Activity Line";
        WhseMoveLineForSplitPlace: Record "Warehouse Activity Line";
        tempItem: Record Item temporary;
        ToBinCode: Code[20];
        ToZoneCode: Code[20];
        FromBinCode: Code[20];
        FromZoneCode: Code[20];
        PickFilter: Text[1024];
        ReservationEntry: Record "Reservation Entry";
        ReservationEntryLotNo: Record "Reservation Entry";
        BinContent: Record "Bin Content";
        remQtytoMove: Decimal;
        EntriesExist: Boolean;
    begin
        // create item list to whse move
        CreateTempItemList(WhseMoveNo, tempItem);

        if tempItem.FindFirst() then begin
            repeat
                // get ToBin from Action Take where Bin Code exist
                ToBinCode := '';
                ToZoneCode := '';

                with WhseMoveLine do begin
                    SetCurrentKey("Action Type", "Bin Code", "Item No.");
                    SetRange("Activity Type", "Activity Type"::Movement);
                    SetRange("No.", WhseMoveNo);
                    SetRange("Action Type", "Action Type"::Take);
                    SetFilter("Bin Code", '<>%1', '');
                    SetRange("Item No.", tempItem."No.");
                    if FindSet(false, false) then begin
                        ToBinCode := "Bin Code";
                        ToZoneCode := "Zone Code";
                        // delete record completted for pick
                        DeleteWhseMoveLine("No.", "Line No.");
                    end else begin
                        Reset();
                        SetRange("Activity Type", "Activity Type"::Movement);
                        SetRange("No.", WhseMoveNo);
                        FindFirst();
                        // get pick filter
                        PickFilter := CreatePick.GetBinTypeFilter(3);
                        // find empty toBin
                        Bin.SetCurrentKey("Bin Type Code");
                        Bin.SetRange("Location Code", "Location Code");
                        Bin.SetRange("Bin Type Code", PickFilter);
                        Bin.SetRange(Empty, true);
                        Bin.FindFirst();
                        // if not Bin.FindFirst() then
                        //     Error(errNoEmptyBinForPick, "Location Code", PickFilter);
                        ToBinCode := Bin.Code;
                        ToZoneCode := Bin."Zone Code";
                    end;
                end;

                // modify Place record
                with WhseMoveLine do begin
                    SetRange("Action Type", "Action Type"::Place);
                    SetFilter("Bin Code", '<>%1', '');
                    SetRange("Item No.", tempItem."No.");
                    if FindSet(false, true) then
                        repeat
                            Validate("Zone Code", ToZoneCode);
                            Validate("Bin Code", ToBinCode);
                            Modify();
                        until Next() = 0;
                end;

                with WhseMoveLine do begin
                    Reset();
                    SetRange("Activity Type", "Activity Type"::Movement);
                    SetRange("No.", WhseMoveNo);
                    SetRange("Action Type", "Action Type"::Take);
                    SetRange("Item No.", tempItem."No.");
                    FindFirst();
                    GetLocation("Location Code");
                    ReservationEntry.SetCurrentKey("Source ID", "Source Ref. No.");
                    BinContent.SetCurrentKey("Lot No.");
                    repeat
                        PlaceLineNo := "Line No." + 10000;
                        remQtytoMove := Quantity;
                        ReservationEntry.SetRange("Source ID", "Source No.");
                        ReservationEntry.SetRange("Source Ref. No.", "Source Line No.");
                        if ReservationEntry.FindFirst() then
                            repeat
                                ReservationEntryLotNo.Get(ReservationEntry."Entry No.", true);
                                if ReservationEntryLotNo."Item Tracking" = ReservationEntryLotNo."Item Tracking"::"Lot No." then begin
                                    // find FromBin
                                    BinContent.SetRange("Lot No.", ReservationEntryLotNo."Lot No.");
                                    if BinContent.FindFirst() then begin
                                        "Lot No." := BinContent."Lot No.";
                                        "Expiration Date" := ItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code",
                                            ReservationEntryLotNo."Lot No.", '', false, EntriesExist);
                                        "Zone Code" := BinContent."Zone Code";
                                        "Bin Code" := BinContent."Bin Code";
                                        Modify();
                                        UpdatePlaceLine(WhseMoveLine, ToZoneCode, ToBinCode);
                                        if ReservationEntryLotNo.Quantity < remQtytoMove then begin
                                            // calculate remaining qty
                                            remQtytoMove := Quantity - ReservationEntryLotNo.Quantity;
                                            Validate("Qty. to Handle", ReservationEntryLotNo.Quantity);
                                            Modify(true);
                                            // split Place line for remaining quantity
                                            SplitPlaceLineForRemQty(WhseMoveLine);
                                            // split Take line for remaining quantity
                                            WhseMoveLineForSplit.Copy(WhseMoveLine);
                                            SplitLine(WhseMoveLineForSplit);
                                            WhseMoveLine.Copy(WhseMoveLineForSplit);
                                            Next();
                                        end;
                                    end;
                                end;
                            until ReservationEntry.Next() = 0;
                    until Next() = 0;
                end;
            until tempItem.Next() = 0;
        end;
    end;

    procedure SplitPlaceLine(var WhseActivLine: Record "Warehouse Activity Line")
    var
        NewWhseActivLine: Record "Warehouse Activity Line";
        LineSpacing: Integer;
        NewLineNo: Integer;
    begin
        NewWhseActivLine := WhseActivLine;
        NewWhseActivLine.SetRange("No.", WhseActivLine."No.");
        if NewWhseActivLine.Find('>') then
            LineSpacing :=
              (NewWhseActivLine."Line No." - WhseActivLine."Line No.") div 2
        else
            LineSpacing := 10000;

        if LineSpacing = 0 then begin
            ReNumberAllLines(NewWhseActivLine, WhseActivLine."Line No.", NewLineNo);
            WhseActivLine.Get(WhseActivLine."Activity Type", WhseActivLine."No.", NewLineNo);
            LineSpacing := 5000;
        end;

        NewWhseActivLine.Reset();
        NewWhseActivLine.Init();
        NewWhseActivLine := WhseActivLine;
        NewWhseActivLine."Line No." := NewWhseActivLine."Line No." + LineSpacing;
        NewWhseActivLine.Quantity :=
          WhseActivLine."Qty. Outstanding" - WhseActivLine."Qty. to Handle";
        NewWhseActivLine."Qty. (Base)" :=
          WhseActivLine."Qty. Outstanding (Base)" - WhseActivLine."Qty. to Handle (Base)";
        NewWhseActivLine."Qty. Outstanding" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. Outstanding (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. to Handle" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. to Handle (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. Handled" := 0;
        NewWhseActivLine."Qty. Handled (Base)" := 0;
        GetLocation(NewWhseActivLine."Location Code");
        if Location."Directed Put-away and Pick" then begin
            WMSMgt.CalcCubageAndWeight(
              NewWhseActivLine."Item No.", NewWhseActivLine."Unit of Measure Code",
              NewWhseActivLine."Qty. to Handle", NewWhseActivLine.Cubage, NewWhseActivLine.Weight);
        end;
        NewWhseActivLine.Insert();

        WhseActivLine.Quantity := WhseActivLine."Qty. to Handle" + WhseActivLine."Qty. Handled";
        WhseActivLine."Qty. (Base)" :=
          WhseActivLine."Qty. to Handle (Base)" + WhseActivLine."Qty. Handled (Base)";
        WhseActivLine."Qty. Outstanding" := WhseActivLine."Qty. to Handle";
        WhseActivLine."Qty. Outstanding (Base)" := WhseActivLine."Qty. to Handle (Base)";
        if Location."Directed Put-away and Pick" then
            WMSMgt.CalcCubageAndWeight(
              WhseActivLine."Item No.", WhseActivLine."Unit of Measure Code",
              WhseActivLine."Qty. to Handle", WhseActivLine.Cubage, WhseActivLine.Weight);
        WhseActivLine.Modify();

        PlaceLineNo := NewWhseActivLine."Line No.";
    end;

    local procedure ReNumberAllLines(var NewWhseActivityLine: Record "Warehouse Activity Line"; OldLineNo: Integer; var NewLineNo: Integer)
    var
        TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary;
        LineNo: Integer;
    begin
        NewWhseActivityLine.FindSet;
        repeat
            LineNo += 10000;
            TempWarehouseActivityLine := NewWhseActivityLine;
            TempWarehouseActivityLine."Line No." := LineNo;
            TempWarehouseActivityLine.Insert();
            if NewWhseActivityLine."Line No." = OldLineNo then
                NewLineNo := LineNo;
        until NewWhseActivityLine.Next = 0;
        NewWhseActivityLine.DeleteAll();

        TempWarehouseActivityLine.FindSet;
        repeat
            NewWhseActivityLine := TempWarehouseActivityLine;
            NewWhseActivityLine.Insert();
        until TempWarehouseActivityLine.Next = 0;
    end;

    local procedure UpdatePlaceLine(WhseMoveLine: Record "Warehouse Activity Line"; ToZoneCode: Code[10]; ToBinCode: Code[20])
    var
        WhseMoveLineForSplit: Record "Warehouse Activity Line";
    begin
        with WhseMoveLine do begin
            WhseMoveLineForSplit.Get("Activity Type", "No.", PlaceLineNo);
            WhseMoveLineForSplit."Lot No." := "Lot No.";
            WhseMoveLineForSplit."Expiration Date" := "Expiration Date";
            // WhseMoveLineForSplit."Zone Code" := ToZoneCode;
            // WhseMoveLineForSplit."Bin Code" := ToBinCode;
            WhseMoveLineForSplit.Modify();
        end;
    end;

    local procedure SplitPlaceLineForRemQty(WhseMoveLine: Record "Warehouse Activity Line")
    var
        WhseMoveLineForSplit: Record "Warehouse Activity Line";
    begin
        with WhseMoveLine do begin
            WhseMoveLineForSplit.Get("Activity Type", "No.", PlaceLineNo);
            WhseMoveLineForSplit.Validate("Qty. to Handle", "Qty. to Handle");
            WhseMoveLineForSplit.Modify(true);
            SplitPlaceLine(WhseMoveLineForSplit);
        end;
    end;

    local procedure DeleteWhseMoveLine(WhseMoveNo: Code[20]; LineNo: Integer)
    var
        WhseMoveLine: Record "Warehouse Activity Line";
    begin
        with WhseMoveLine do begin
            SetRange("Activity Type", "Activity Type"::Movement);
            SetRange("No.", WhseMoveNo);
            SetRange("Line No.", LineNo, LineNo + 10000);
            Ascending(false);
            if FindSet(false, false) then
                repeat
                    Delete(); // to ensure correct item tracking update
                    DeleteBinContent("Action Type"::Place);
                    UpdateRelatedItemTrkg(WhseMoveLine);
                until Next() = 0;
        end;
    end;

    local procedure CreateTempItemList(WhseMoveNo: Code[20]; var tempItem: Record Item temporary)
    var
        WhseMoveLine: Record "Warehouse Activity Line";
    begin
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
    end;

    procedure GetLocation(LocationCode: Code[10])
    begin
        IF Location.Code <> LocationCode THEN BEGIN
            IF LocationCode = '' THEN
                Location.GetLocationSetup(LocationCode, Location)
            ELSE
                Location.GET(LocationCode);
        END;
    end;

    local procedure AllCompletePicked(var WhsePickHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhsePickLine: Record "Warehouse Activity Line";
    begin
        if WhsePickHeader.FindFirst() then begin
            GetLocation(WhsePickHeader."Location Code");
            if not Location."Create Move" then exit(true);
        end else
            exit(true);

        repeat
            with WhsePickLine do begin
                SetCurrentKey("Shipping Advice");
                SetRange("Activity Type", WhsePickHeader.Type);
                SetRange("No.", WhsePickHeader."No.");
                SetRange("Action Type", "Action Type"::Take);
                SetRange("Bin Code", '');
                exit(IsEmpty);
            end;
        until WhsePickHeader.Next() = 0;
        exit(true);
    end;

    local procedure CompletePicked(WhsePickNo: Code[20]): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        with WhseActivLine do begin
            SetCurrentKey("Shipping Advice");
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

    var
        glItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
        Bin: Record Bin;
        BinType: Record "Bin Type";
        CreatePick: Codeunit "Create Pick";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseAvailMgt: Codeunit "Warehouse Availability Mgt.";
        WMSMgt: Codeunit "WMS Management";
        PlaceLineNo: Integer;
        msgWhseMoveCreated: TextConst ENU = 'Warehouse Movement %1 created.',
                                      RUS = 'Складское передвижение %1 создано.';
        cnfCreateWahseMove: TextConst ENU = 'Create Warehouse Move?',
                                      RUS = 'Создать Складское передвижение?';
        errNoEmptyBinForPick: TextConst ENU = 'No Empty Bin For Pick. Location %1. Zona %2.',
                                      RUS = 'Нет свбодных ячеек для подбора. Склад %1. Зона %2.';
}