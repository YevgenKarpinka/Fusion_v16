page 50016 "Reservation Entry List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "Reservation Entry";
    CaptionML = ENU = 'Reservation Entry List';

    layout
    {
        area(Content)
        {
            repeater(ReservationEntryList)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; "Source ID")
                {
                    ApplicationArea = All;
                }
                field("Source Ref. No."; "Source Ref. No.")
                {
                    ApplicationArea = All;
                }
                field("Reservation Status"; "Reservation Status")
                {
                    ApplicationArea = All;
                }
                field("Item Tracking"; "Item Tracking")
                {
                    ApplicationArea = All;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}