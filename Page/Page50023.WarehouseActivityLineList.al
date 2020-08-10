page 50023 "Warehouse Activity Line List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "Warehouse Activity Line";
    CaptionML = ENU = 'Warehouse Activity Line List';

    layout
    {
        area(Content)
        {
            repeater(WarehouseActivityLineList)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
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
            action(DelleteAllWhseActLine)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    WhseActLine: Record "Registered Whse. Activity Line";
                begin
                    CurrPage.SetSelectionFilter(WhseActLine);
                    WhseActLine.DeleteAll();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}