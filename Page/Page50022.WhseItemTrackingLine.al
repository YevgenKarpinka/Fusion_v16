page 50022 "Whse. Item Tracking Line"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Whse. Item Tracking Line";

    layout
    {
        area(Content)
        {
            repeater(repeaterName)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;

                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;

                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = All;

                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = All;

                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;

                }
                field("Source ID"; "Source ID")
                {
                    ApplicationArea = All;

                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = All;

                }
                field("Quantity Handled (Base)"; "Quantity Handled (Base)")
                {
                    ApplicationArea = All;

                }
                field("Qty. to Handle (Base)"; "Qty. to Handle (Base)")
                {
                    ApplicationArea = All;

                }
                field("Put-away Qty. (Base)"; "Put-away Qty. (Base)")
                {
                    ApplicationArea = All;

                }
                field("Pick Qty. (Base)"; "Pick Qty. (Base)")
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}