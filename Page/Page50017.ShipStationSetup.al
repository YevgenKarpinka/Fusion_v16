page 50017 "ShipStation Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ShipStation Setup";
    CaptionML = ENU = 'ShipStation Setup', RUS = 'ShipStation настройка';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("ShipStation Integration Enable"; "ShipStation Integration Enable")
                {
                    ApplicationArea = All;
                }
                field("Order Status Update"; "Order Status Update")
                {
                    ApplicationArea = All;
                }
                field("Show Error"; "Show Error")
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
            action(UpdateCarriers)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Update Carriers and Services',
                            RUS = 'Обновить услуги доставки';

                trigger OnAction()
                begin
                    ShipStationMgt.UpdateCarriersAndServices();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
        isEditable := "ShipStation Integration Enable";
    end;

    var
        ShipStationMgt: Codeunit "ShipStation Mgt.";
        isEditable: Boolean;
}