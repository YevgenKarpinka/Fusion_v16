codeunit 50006 "IC Extended"
{
    Permissions = tabledata "Sales Header" = rimd, tabledata "Sales Line" = rimd,
    tabledata "Purchase Line" = rimd, tabledata "Purchase Header" = rimd,
    tabledata "IC Partner" = r, tabledata Vendor = r;

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterUpdateAmountsDone', '', false, false)]
    local procedure ChangeItemAllowed(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    var
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        with SalesLine do begin
            if Type <> Type::Item then exit;

            FoundPurchaseOrder("Document No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
            if (_PurchaseOrderNo = '') and (_PostedPurchaseInvoceNo = '') then exit;

            case CurrentFieldNo of
                FieldNo("No."):
                    if ("No." <> xSalesLine."No.") then
                        FieldError("No.");
                FieldNo(Quantity):
                    if (Quantity <> xSalesLine.Quantity) then
                        FieldError(Quantity);
                FieldNo(Amount):
                    if (Amount <> xSalesLine.Amount) then
                        FieldError(Amount);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeInsertEvent', '', false, false)]
    local procedure CheckAllowInsertSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        _purchaseHeader: Record "Purchase Header";
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        // if Rec."Document Type" <> Rec."Document Type"::Order then exit;

        // FoundPurchaseOrder(Rec."Document No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        // if (_PurchaseOrderNo <> '') or (_PostedPurchaseInvoceNo <> '') then
        //     Error(errInsertSalesLineNotAllowed, Rec."Document No.");
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckAllowDeleteSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        _purchaseHeader: Record "Purchase Header";
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        // if Rec."Document Type" <> Rec."Document Type"::Order then exit;

        // FoundPurchaseOrder(Rec."Document No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        // if (_PurchaseOrderNo <> '') or (_PostedPurchaseInvoceNo <> '') then
        //     Error(errInsertSalesLineNotAllowed, Rec."Document No.");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckExistICSalesOrderBeforeManualDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        _ICPartner: Record "IC Partner";
        _PurchHeader: Record "Purchase Header";
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        // with Rec do begin
        //     if "Document Type" <> "Document Type"::Order then exit;

        //     if "External Document No." <> '' then begin
        //         _ICPartner.SetCurrentKey("Customer No.");
        //         _ICPartner.SetRange("Customer No.", "Sell-to Customer No.");
        //         if _ICPartner.FindFirst() then begin
        //             _PurchHeader.ChangeCompany(_ICPartner."Inbox Details");
        //             if _PurchHeader.Get(_PurchHeader."Document Type"::Order, "External Document No.") then
        //                 Error(errDeleteICSalesOrder, "No.", _PurchHeader."No.");
        //         end;
        //     end else begin
        //         _PurchHeader.SetRange("Document Type", _PurchHeader."Document Type"::Order);
        //         _PurchHeader.SetRange("IC Document No.", "No.");
        //         if _PurchHeader.FindFirst() then
        //             Error(errDeleteSalesOrder, "No.", _PurchHeader."No.");
        //     end;

        // end;
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckExistICPurchaseOrderBeforeManualDelete(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    begin
        // with Rec do begin
        //     if "Document Type" <> "Document Type"::Order then exit;

        //     if "IC Document No." <> '' then
        //         Error(errDeletePurchOrder, "No.", "IC Document No.");
        // end;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReopenSalesDoc', '', false, false)]
    procedure DeletePurchOrderAndICSalesOrder(_salesHeader: Record "Sales Header")
    var
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
        _ICSalesOrderNo: Code[20];
        _PostedICSalesInvoiceNo: Code[20];
    begin
        FoundPurchaseOrder(_salesHeader."No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        if _PostedPurchaseInvoceNo <> '' then
            Error(errPurchOrderPosted, _salesHeader."No.", _PostedPurchaseInvoceNo);

        if _PurchaseOrderNo <> '' then
            FoundICSalesOrder(_PurchaseOrderNo, _ICSalesOrderNo, _PostedICSalesInvoiceNo);

        if _PostedICSalesInvoiceNo <> '' then
            Error(errICSalesOrderPosted, _salesHeader."No.", _PostedICSalesInvoiceNo);

        DeleteICSalesOrderAndPurchaseOrder(_salesHeader."No.", _PurchaseOrderNo);
        Message(msgDeletePurchOrderAndICSalesOrder, _PurchaseOrderNo, _PostedPurchaseInvoceNo, _ICSalesOrderNo, _PostedICSalesInvoiceNo);
    end;

    local procedure DeleteICSalesOrderAndPurchaseOrder(_SalesHeaderNo: Code[20]; _PurchaseOrderNo: Code[20]);
    var
        _PurchHeader: Record "Purchase Header";
        _PurchHeaderForDelete: Record "Purchase Header";
        _ICPartner: Record "IC Partner";
        _ICSalesHeader: Record "Sales Header";
        _ICSalesHeaderForDelete: Record "Sales Header";
    begin
        if (_PurchaseOrderNo <> '')
            and _PurchHeader.Get(_PurchHeader."Document Type"::Order, _PurchaseOrderNo)
                and _ICPartner.Get(_PurchHeader."Buy-from IC Partner Code") then begin
            with _ICSalesHeader do begin
                ChangeCompany(_ICPartner."Inbox Details");
                SetCurrentKey("External Document No.");
                SetRange("External Document No.", _PurchaseOrderNo);
                if FindSet(false, false) then
                    repeat
                        _ICSalesHeaderForDelete.ChangeCompany(_ICPartner."Inbox Details");
                        _ICSalesHeaderForDelete.Get("Document Type"::Order, "No.");
                        _ICSalesHeaderForDelete."External Document No." := '';
                        _ICSalesHeaderForDelete.Modify();
                        _ICSalesHeaderForDelete.Delete(true);
                    until Next() = 0;
            end;
        end;

        with _PurchHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", _SalesHeaderNo);
            SetRange("Document Type", "Document Type"::Order);
            if FindSet(false, false) then
                repeat
                    _PurchHeaderForDelete.Get("Document Type"::Order, "No.");
                    _PurchHeaderForDelete."IC Document No." := '';
                    _PurchHeaderForDelete.Modify();
                    _PurchHeaderForDelete.Delete(true);
                until Next() = 0;
        end;
    end;

    procedure FoundICSalesOrder(purchaseOrderNo: Code[20]; var _ICSalesOrderNo: Code[20]; var _PostedICSalesInvoiceNo: Code[20])
    var
        _PurchHeader: Record "Purchase Header";
        _ICPartner: Record "IC Partner";
        _ICSalesHeader: Record "Sales Header";
        _ICSalesInvHeader: Record "Sales Invoice Header";
    begin
        _ICSalesOrderNo := '';
        _PostedICSalesInvoiceNo := '';

        if (purchaseOrderNo <> '')
            and _PurchHeader.Get(_PurchHeader."Document Type"::Order, purchaseOrderNo)
            and _ICPartner.Get(_PurchHeader."Buy-from IC Partner Code") then begin

            with _ICSalesHeader do begin
                ChangeCompany(_ICPartner."Inbox Details");
                SetCurrentKey("External Document No.");
                SetRange("External Document No.", purchaseOrderNo);
                if FindFirst() then begin
                    _ICSalesOrderNo := "No.";
                    exit;
                end;
            end;
        end;

        with _ICSalesInvHeader do begin
            ChangeCompany(_ICPartner."Inbox Details");
            SetCurrentKey("External Document No.");
            SetRange("External Document No.", purchaseOrderNo);
            if FindFirst() then
                _PostedICSalesInvoiceNo := "No.";

        end;

    end;

    procedure FoundParentICSalesOrder(_salesOrderNo: Code[20]; var _ICSalesOrderNo: Code[20])
    var
        _salesHeader: Record "Sales Header";
        _ICPartner: Record "IC Partner";
        _ICPurchaseHeader: Record "Purchase Header";
        _ICPurchaseInvHeader: Record "Purch. Inv. Header";
    begin
        _ICSalesOrderNo := '';

        if _salesHeader.Get(_salesHeader."Document Type"::Order, _salesOrderNo)
            and _ICPartner.Get(_salesHeader."Sell-to IC Partner Code") then begin

            with _ICPurchaseHeader do begin
                ChangeCompany(_ICPartner."Inbox Details");
                if get("Document Type"::Order, _salesHeader."External Document No.") then
                    _ICSalesOrderNo := "IC Document No.";
                exit;
            end;
        end;

        with _ICPurchaseInvHeader do begin
            ChangeCompany(_ICPartner."Inbox Details");
            SetCurrentKey("Order No.");
            SetRange("Order No.", _salesOrderNo);
            if FindFirst() then
                _ICSalesOrderNo := "IC Document No.";
        end;
    end;

    procedure FoundPurchaseOrder(salesOrderNo: Code[20]; var _PurchaseOrderNo: Code[20]; var _PostedPurchaseInvoiceNo: Code[20])
    var
        _PurchHeader: Record "Purchase Header";
        _PurchInvHeader: Record "Purch. Inv. Header";
    begin
        _PurchaseOrderNo := '';
        _PostedPurchaseInvoiceNo := '';

        with _PurchHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", salesOrderNo);
            SetRange("Document Type", "Document Type"::Order);
            if FindFirst() then begin
                _PurchaseOrderNo := "No.";
                exit;
            end;
        end;
        with _PurchInvHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", salesOrderNo);
            if FindFirst() then
                _PostedPurchaseInvoiceNo := "No.";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure CreatePOFromSO(var SalesHeader: Record "Sales Header")
    var
        _PurchHeader: Record "Purchase Header";
        _PurchaseOrderNo: code[20];
        _PostedPurchaseInvoceNo: Code[20];
    begin
        FoundPurchaseOrder(SalesHeader."No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        if (_PurchaseOrderNo = '') and (_PostedPurchaseInvoceNo = '') then begin
            CreateICPurchaseOrder(SalesHeader);
            CreateDeliverySalesLine(SalesHeader."No.", SalesHeader."Sell-to Customer No.");
            CreateItemChargeAssgnt(SalesHeader."No.", SalesHeader."Sell-to Customer No.");
        end;
    end;

    procedure CreateItemChargeAssgnt(_salesOrderNo: Code[20]; _customerNo: Code[20])
    var
        _salesHeader: Record "Sales Header";
        _salesLine: Record "Sales Line";
        _customer: Record Customer;
        _currency: Record Currency;
        _itemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        _itemChargeAssgntLineAmt: Decimal;
        _assignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
    begin
        if not _salesHeader.Get(_salesHeader."Document Type"::Order, _salesOrderNo) then exit;
        if not _customer.Get(_customerNo)
            or (_customer."Sales No. Shipment Cost" = '')
            or (_customer."Posting Type Shipment Cost" <> _customer."Posting Type Shipment Cost"::"Charge (Item)") then
            exit;

        with _salesLine do begin
            SetCurrentKey(Type);
            SetRange("Document Type", _salesHeader."Document Type");
            SetRange("Document No.", _salesHeader."No.");
            SetRange(Type, Type::"Charge (Item)");
            SetRange("No.", _customer."Sales No. Shipment Cost");
            if not FindFirst() then exit;

            TestField("No.");
            TestField(Quantity);

            _currency.Initialize(_salesHeader."Currency Code");
            if ("Inv. Discount Amount" = 0) AND ("Line Discount Amount" = 0) AND
               (NOT _salesHeader."Prices Including VAT")
            then
                _itemChargeAssgntLineAmt := "Line Amount"
            else
                IF _salesHeader."Prices Including VAT" then
                    _itemChargeAssgntLineAmt :=
                      ROUND(CalcLineAmount / (1 + "VAT %" / 100), _currency."Amount Rounding Precision")
                else
                    _itemChargeAssgntLineAmt := CalcLineAmount;

            _itemChargeAssgntSales.RESET;
            _itemChargeAssgntSales.SETRANGE("Document Type", "Document Type");
            _itemChargeAssgntSales.SETRANGE("Document No.", "Document No.");
            _itemChargeAssgntSales.SETRANGE("Document Line No.", "Line No.");
            _itemChargeAssgntSales.SETRANGE("Item Charge No.", "No.");
            if not _itemChargeAssgntSales.FindLast() then begin
                _itemChargeAssgntSales."Document Type" := "Document Type";
                _itemChargeAssgntSales."Document No." := "Document No.";
                _itemChargeAssgntSales."Document Line No." := "Line No.";
                _itemChargeAssgntSales."Item Charge No." := "No.";
                _itemChargeAssgntSales."Unit Cost" :=
                  ROUND(_itemChargeAssgntLineAmt / Quantity, _currency."Unit-Amount Rounding Precision");
            end;

            _itemChargeAssgntLineAmt :=
                  ROUND(_itemChargeAssgntLineAmt * ("Qty. to Invoice" / Quantity), _currency."Amount Rounding Precision");

            _assignItemChargeSales.CreateDocChargeAssgn(_itemChargeAssgntSales, "Shipment No.");
        end;
        SuggestAssignment(_salesLine, _salesLine.Quantity, _itemChargeAssgntLineAmt);
    end;

    procedure SuggestAssignment(_salesLine: Record "Sales Line"; _totalQtyToAssign: Decimal; _totalAmtToAssign: Decimal)
    var
        _itemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        _selection: Integer;
        _suggestItemChargeMenuTxt: Text;
        _selectionTxt: Text;
        _assignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
    begin
        // with _salesLine do begin
        //     TestField("Qty. to Invoice");
        //     _itemChargeAssgntSales.SetRange("Document Type", "Document Type");
        //     _itemChargeAssgntSales.SetRange("Document No.", "Document No.");
        //     _itemChargeAssgntSales.SetRange("Document Line No.", "Line No.");
        // END;
        // IF _itemChargeAssgntSales.IsEmpty THEN
        //     EXIT;


        _selection := 1;
        _suggestItemChargeMenuTxt :=
          STRSUBSTNO('%1,%2,%3,%4', AssignEquallyMenuText, AssignByAmountMenuText, AssignByWeightMenuText, AssignByVolumeMenuText);
        IF _itemChargeAssgntSales.COUNT > 1 THEN
            _selection := 2;

        _selectionTxt := SELECTSTR(_selection, _suggestItemChargeMenuTxt);

        _assignItemChargeSales.AssignItemCharges(_salesLine, _totalQtyToAssign, _totalAmtToAssign, _selectionTxt);
    end;

    procedure AssignEquallyMenuText(): Text
    begin
        exit(EquallyTok)
    end;

    procedure AssignByAmountMenuText(): Text
    begin
        exit(ByAmountTok)
    end;

    procedure AssignByWeightMenuText(): Text
    begin
        exit(ByWeightTok)
    end;

    procedure AssignByVolumeMenuText(): Text
    begin
        exit(ByVolumeTok)
    end;

    procedure CreateDeliverySalesLine(_salesHeaderNo: Code[20]; _customerNo: Code[20])
    var
        _salesHeader: Record "Sales Header";
        _salesLine: Record "Sales Line";
        _salesLineLast: Record "Sales Line";
        _customer: Record Customer;
        LineNo: Integer;
        UpdatedStatus: Boolean;
    begin
        if (not _customer.Get(_customerNo))
            or (_customer."Sales No. Shipment Cost" = '')
            or (not _salesHeader.Get(_salesHeader."Document Type"::Order, _salesHeaderNo))
            or (_salesHeader."ShipStation Shipment Amount" = 0) then
            exit;

        with _salesLineLast do begin
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", _salesHeaderNo);
            if FindLast() then
                LineNo := "Line No." + 10000
            else
                LineNo := 10000;
        end;

        with _salesHeader do
            if Status = Status::Released then begin
                Status := Status::Open;
                Modify();
                UpdatedStatus := true;
            end;

        with _salesLine do begin
            Init;
            "Document Type" := "Document Type"::Order;
            "Document No." := _salesHeaderNo;
            "Line No." := LineNo;
            Insert(true);
            Validate(Type, _customer."Posting Type Shipment Cost");
            Validate("No.", _customer."Sales No. Shipment Cost");
            Validate(Quantity, 1);
            Validate("Unit Price", _salesHeader."ShipStation Shipment Amount");
            Modify(true)
        end;

        if UpdatedStatus then
            with _salesHeader do begin
                Status := Status::Released;
                Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterTransfldsFromSalesToPurchLine', '', false, false)]
    local procedure Update(var FromSalesLine: Record "Sales Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
        if FromSalesLine."Document Type" <> FromSalesLine."Document Type"::Order then exit;
        with ToPurchaseLine do
            Validate("Direct Unit Cost", FromSalesLine."Unit Price");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure UpdateICDocumentNo(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20])
    var
        _ICPartner: Record "IC Partner";
        _ICPurchHeader: Record "Purchase Header";
    begin
        if (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) or (SalesInvHdrNo = '') then exit;

        // Update Purchase Document No
        _ICPartner.SetCurrentKey("Customer No.");
        _ICPartner.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        if _ICPartner.FindFirst()
        and _ICPurchHeader.ChangeCompany(_ICPartner."Inbox Details")
        and _ICPurchHeader.Get(_ICPurchHeader."Document Type"::Order, SalesHeader."External Document No.") then begin
            _ICPurchHeader."Vendor Invoice No." := SalesInvHdrNo;
            _ICPurchHeader.Modify();
        end;
        // Update Status = Shipped Sales Order into Site
        GetShipStationSetup();
        if glShipStationSetup."Order Status Update" then
            if SalesHeader."External Document No." <> '' then begin
                ShipStationMgt.SentOrderShipmentStatusForWooComerse(SalesHeader."No.", 1);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure AutoReservationICSalesLines(var PurchaseHeader: Record "Purchase Header"; PurchInvHdrNo: Code[20])
    var
        _ICSalesHeader: Record "Sales Header";
        _ICSalesLine: Record "Sales Line";
    begin
        if (PurchInvHdrNo = '')
            or (PurchaseHeader."IC Document No." = '')
            or (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order) then
            exit;

        if _ICSalesHeader.Get(_ICSalesHeader."Document Type"::Order, PurchaseHeader."IC Document No.") then begin
            // Update Purchase Document No
            _ICSalesHeader."External Document No." := PurchInvHdrNo;
            _ICSalesHeader.Modify();
            // AutoReserv for each line with Item
            _ICSalesLine.SetCurrentKey(Type, Quantity);
            _ICSalesLine.SetRange("Document Type", _ICSalesLine."Document Type"::Order);
            _ICSalesLine.SetRange("Document No.", _ICSalesHeader."No.");
            _ICSalesLine.SetRange(Type, _ICSalesLine.Type::Item);
            _ICSalesLine.SetFilter(Quantity, '<>%1', 0);
            if _ICSalesLine.FindSet(true, false) then begin
                _ICSalesLine.AutoReserve();
            end;
            // Update Status = Assembled Sales Order into Site
            GetShipStationSetup();
            if glShipStationSetup."Order Status Update" then
                ShipStationMgt.SentOrderShipmentStatusForWooComerse(_ICSalesHeader."No.", 0);
        end;
    end;

    local procedure CreateICPurchaseOrder(fromSalesHeader: Record "Sales Header")
    var
        fromSalesLine: Record "Sales Line";
        toPurchHeader: Record "Purchase Header";
        ICVendorNo: Code[20];
    begin
        if fromSalesHeader."Document Type" <> fromSalesHeader."Document Type"::Order then exit;

        ICVendorNo := GetICVendor(CompanyName);
        if (ICVendorNo = '') then exit;

        with fromSalesLine do begin
            SetRange("Document Type", fromSalesHeader."Document Type");
            SetRange("Document No.", fromSalesHeader."No.");
            SetRange(Type, Type::Item);
            SetFilter(Quantity, '<>%1', 0);
            if fromSalesLine.IsEmpty then exit;
        end;

        // Copy Sales Order to Purchase Order
        CopySalesOrder2PurchaseOrder(ICVendorNo, fromSalesHeader, toPurchHeader);

        // Send Intercompany Purchase Order
        SendIntercompanyPurchaseOrder(toPurchHeader);
    end;

    procedure SendIntercompanyPurchaseOrder(var toPurchHeader: Record "Purchase Header")
    begin
        if ApprovalsMgmt.PrePostApprovalCheckPurch(toPurchHeader) then
            ICInOutboxMgt.SendPurchDoc(toPurchHeader, false);
    end;

    procedure CopySalesOrder2PurchaseOrder(ICVendorNo: Code[20]; fromSalesHeader: Record "Sales Header"; var toPurchHeader: Record "Purchase Header")
    begin
        if fromSalesHeader."Document Type" <> fromSalesHeader."Document Type"::Order then exit;

        toPurchHeader."Document Type" := toPurchHeader."Document Type"::Order;
        toPurchHeader."IC Document No." := fromSalesHeader."No.";
        CLEAR(CopyDocumentMgt);
        CopyDocumentMgt.SetProperties(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE);
        CopyDocumentMgt.CopyFromSalesToPurchDoc(ICVendorNo, fromSalesHeader, toPurchHeader);
    end;

    local procedure GetICVendor(ICPartner: Text[100]): Code[20]
    var
        _Vendor: Record Vendor;
    begin
        with _Vendor do begin
            if ICPartner <> CompanyName then
                ChangeCompany(ICPartner);
            SetCurrentKey("IC Partner Code");
            SetFilter("IC Partner Code", '<>%1', '');
            SetRange(Blocked, Blocked::" ");
            if FindFirst() then
                exit("No.")
            else
                exit('');
        end;
    end;

    local procedure GetShipStationSetup()
    begin
        if not glShipStationSetupGetted then begin
            glShipStationSetup.Get();
            glShipStationSetupGetted := true;
        end;
    end;

    var
        glShipStationSetupGetted: Boolean;
        glShipStationSetup: Record "ShipStation Setup";
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ShipStationMgt: Codeunit "ShipStation Mgt.";
        errPurchOrderPosted: TextConst ENU = 'Reopen Sales Order = %1 not allowed!\Purchase Order = %2 Posted!',
                                        RUS = 'Открыть Заказ Продажи = %1 нельзя!\Заказ Покупки = %2 учтен!';
        errICSalesOrderPosted: TextConst ENU = 'Reopen Sales Order = %1 not allowed!\Intercompany Sales Order = %2 Posted!',
                                            RUS = 'Открыть Заказ Продажи = %1 нельзя!\Межфирменный Заказ Продажи = %2 учтен!';
        errDeletePurchOrder: TextConst ENU = 'Delete Purchase Order = %1 not allowed!\Delete Sales Order = %2 first!',
                                        RUS = 'Удалить Заказ Покупки = %1 нельзя!\Первым удалите Заказ Продажи = %2!';
        errDeleteICSalesOrder: TextConst ENU = 'Delete Intercompany Sales Order = %1 not allowed!\Delete Purchase Order = %2 first!',
                                        RUS = 'Удалить Межфирменный Заказ Продажи = %1 нельзя!\Первым удалите Заказ Покупки = %2!';
        errWhseShipmentExist: TextConst ENU = 'Delete Intercompany Sales Order = %1 not allowed!\Warehouse Shipment = %2 exist!',
                                        RUS = 'Удалить Межфирменный Заказ Продажи = %1 нельзя!\Удалите Складскую отгрузку = %2!';
        errPostedWhseShipmentExist: TextConst ENU = 'Delete Intercompany Sales Order = %1 not allowed!\Posted Warehouse Shipment = %2 exist!',
                                        RUS = 'Удалить Межфирменный Заказ Продажи = %1 нельзя!\Удалите Складскую отгрузку = %2!';
        errInsertSalesLineNotAllowed: TextConst ENU = 'Insert Sales Line in Intercompany Sales Order = %1 Not Allowed!\Delete Purchase Order and IC Sales Order first!',
                                        RUS = 'Добавить строку в Межфирменный Заказ Продажи = %1 нельзя!\Сначала удалите Заказ Покупки и МФ Заказ Продажи!';
        errDeleteSalesOrder: TextConst ENU = 'Delete Sales Order = %1 not allowed!\Delete Purchase Order = %2 first!',
                                        RUS = 'Удалить Заказ Продажи = %1 нельзя!\Первым удалите Заказ Покупки = %2!';
        errChangeFieldNotAllowed: TextConst ENU = 'Change Field in Intercompany Sales Order = %1 not allowed!',
                                        RUS = 'Изменять поля в Межфирменном Заказ Продажи = %1 нельзя!';
        msgDeletePurchOrderAndICSalesOrder: TextConst ENU = 'Deleted Purchase Order = %1\Deleted Posted Purchase Order = %2\Deleted Sales Order = %3\Deleted Posted Sales Order = %4',
                                        RUS = 'Удален Заказ Покупки = %1\Удален Учтенный Заказ Покупки = %2\Удален Заказ Продажи = %3\Удален Учтенный Заказ Продажи = %4';
        EquallyTok: TextConst ENU = 'Equally', RUS = 'Поровну';
        ByAmountTok: TextConst ENU = 'By Amount', RUS = 'По сумме';
        ByWeightTok: TextConst ENU = 'By Weight', RUS = 'По весу';
        ByVolumeTok: TextConst ENU = 'By Volume', RUS = 'По объему';
}