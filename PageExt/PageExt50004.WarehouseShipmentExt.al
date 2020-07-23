pageextension 50004 "Warehouse Shipment Ext." extends "Warehouse Shipment"
{
    layout
    {
        // Add changes to page layout here
        addbefore("No.")
        {
            field(CustomerName; ShipStationMgt.GetCustomerNameFromWhseShipment("No."))
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Customer Name',
                            RUS = 'Имя клиента';
                toolTipML = ENU = 'Specifies customer name the warehouse shipment document.',
                            RUS = 'Определяет имя клиента документа складской отгрузки.';
            }
        }
        addfirst(factboxes)
        {
            part("Work Description"; "Work Description FactBox")
            {
                CaptionML = ENU = 'Work Description', RUS = 'Описание работы';
                ApplicationArea = All;
                Provider = WhseShptLines;
                SubPageLink = "No." = field("Source No."), "Document Type" = const(Order);
                Visible = false;
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                CaptionML = ENU = 'Attachments', RUS = 'Вложения';
                ApplicationArea = All;
                SubPageLink = "Table ID" = CONST(7320), "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        modify("Create Pick")
        {
            Visible = false;
        }
        addbefore("Create Pick")
        {
            action("Create Pick Aveilable")
            {
                ApplicationArea = Warehouse;
                Caption = 'Create Pick';
                Ellipsis = true;
                Image = CreateInventoryPickup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a warehouse pick for the items to be shipped.';

                trigger OnAction()
                begin
                    CurrPage.Update(true);
                    CurrPage.WhseShptLines.PAGE.PickCreateAvailable;
                end;
            }
        }
    }

    var
        ShipStationMgt: Codeunit "ShipStation Mgt.";
}