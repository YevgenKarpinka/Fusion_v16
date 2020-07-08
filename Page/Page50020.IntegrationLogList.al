page 50020 "Integration Log List"
{
    CaptionML = ENU = 'Integration Log List',
                RUS = 'Список операций интеграции';
    InsertAllowed = false;
    SourceTable = "Integration Log";
    CardPageId = "Integration Log Card";
    SourceTableView = sorting("Entry No.") order(Descending);
    DataCaptionFields = "Entry No.", "Source Operation";
    ApplicationArea = All;
    Editable = false;
    PageType = List;
    UsageCategory = History;
    AccessByPermission = tabledata "Integration Log" = r;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = false;
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;

                }
                field("Operation Date"; "Operation Date")
                {
                    ApplicationArea = All;

                }
                field("Source Operation"; "Source Operation")
                {
                    ApplicationArea = All;

                }
                field("Operation Status"; Success)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    { }
}