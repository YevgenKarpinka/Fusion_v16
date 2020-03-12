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

                    // trigger OnValidate()
                    // begin
                    //     isEditable := "ShipStation Integration Enable";
                    // end;
                }
                field("Order Status Update"; "Order Status Update")
                {
                    ApplicationArea = All;
                    // Editable = isEditable;
                }
            }
        }
    }

    var
        isEditable: Boolean;

    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
        isEditable := "ShipStation Integration Enable";
    end;
}