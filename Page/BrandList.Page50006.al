page 50006 "Brand List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Brand;
    AccessByPermission = tabledata Brand = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = false;
                field(Code; Code)
                {
                    ApplicationArea = All;

                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;

                }
                field(Name; Name)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {

    }
}