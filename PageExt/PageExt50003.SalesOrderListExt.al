pageextension 50003 "Sales Order List Ext." extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("ShipStation Status"; "ShipStation Status")
            {
                ApplicationArea = All;

            }
            field("ShipStation Order ID"; "ShipStation Order ID")
            {
                ApplicationArea = All;

            }
            field("ShipStation Shipment Amount"; "ShipStation Shipment Amount")
            {
                ApplicationArea = All;

            }
            field("ShipStation Shipment Cost"; "ShipStation Shipment Cost")
            {
                ApplicationArea = All;

            }
            field("ShipStation Insurance Cost"; "ShipStation Insurance Cost")
            {
                ApplicationArea = All;

            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("Work Order")
        {
            action("Sales Order Fusion")
            {
                ApplicationArea = All;
                Image = PrintReport;
                CaptionML = ENU = 'Sales Order Fusion', RUS = 'Заказ продажи Fusion';

                trigger OnAction()
                var
                    _SalesHeader: Record "Sales Header";
                begin
                    _SalesHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(_SalesHeader);
                    Report.Run(Report::"Sales Order Fusion", true, true, _SalesHeader);
                end;
            }
        }
        addbefore("F&unctions")
        {
            group(actionShipStation)
            {
                CaptionML = ENU = 'ShipStation', RUS = 'ShipStation';
                Image = ReleaseShipment;

                action("Create Orders")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Orders', RUS = 'Создать Заказы';
                    Image = CreateDocuments;
                    // Visible = (Status = Status::Released) and ("ShipStation Order Key" = '');

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblOrdersCreated: TextConst ENU = 'Orders Created in ShipStation!', RUS = 'Заказы в ShipStation созданы!';
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        _SH.SetRange(Status, _SH.Status::Released);
                        _SH.SetFilter("ShipStation Order Key", '=%1', '');
                        if _SH.FindSet(false, false) then
                            repeat
                                if (_SH.Status = _SH.Status::Released) and (_SH."ShipStation Order Key" = '') then
                                    ShipStationMgt.CreateOrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblOrdersCreated);
                    end;
                }
                action("Create Labels")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Labels', RUS = 'Создать бирки';
                    Image = PrintReport;
                    // Visible = "ShipStation Order Key" <> '';

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblLabelsCreated: TextConst ENU = 'Labels Created and Attached to Warehouse Shipments!',
                                                    RUS = 'Бирки созданы и прикреплены к Отгрузкам!';
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        _SH.SetFilter("ShipStation Order Key", '<>%1', '');
                        if _SH.FindSet(false, false) then
                            repeat
                                if _SH."ShipStation Order Key" <> '' then
                                    ShipStationMgt.CreateLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblLabelsCreated);
                    end;
                }
                action("Void Labels")
                {
                    ApplicationArea = All;
                    Image = VoidCreditCard;
                    // Visible = "ShipStation Shipment ID" <> '';

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblLabelsVoided: TextConst ENU = 'Labels Voided!',
                                                    RUS = 'Бирки отменены!';
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        _SH.SetFilter("ShipStation Shipment ID", '<>%1', '');
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.VoidLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblLabelsVoided);
                    end;
                }
            }
        }
    }
}