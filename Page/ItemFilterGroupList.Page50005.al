page 50005 "Item Filter Group List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Item Filter Group";
    AccessByPermission = tabledata "Item Filter Group" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = IsEditable;
                field(ItemNo; "Item No.")
                {
                    ApplicationArea = All;
                    Visible = visibleItemNo;
                }
                field(FilterGroup; "Filter Group")
                {
                    ApplicationArea = All;
                    Visible = visibleGroup;
                }
                field(FilterValue; "Filter Value")
                {
                    ApplicationArea = All;
                    Visible = visibleValue;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if (GetFilters() = '') or IsEditable then begin
            visibleItemNo := true;
            visibleGroup := true;
            visibleValue := true;
            IsEditable := true;
            exit;
        end;

        // visibleItemNo := (GetFilter("Item No.") <> '') or (GetFilter("Filter Group") <> '') or (GetFilter("Filter Value") <> '');
        visibleGroup := (GetFilter("Filter Group") <> '') or (GetFilter("Filter Value") <> '');
        visibleValue := (GetFilter("Filter Value") <> '');
        IsEditable := false;

        Reset();
        FindFirst();
    end;

    procedure SetInit(_isEditable: Boolean)
    begin
        IsEditable := _isEditable;
    end;

    var
        IsEditable: Boolean;
        visibleItemNo: Boolean;
        visibleGroup: Boolean;
        visibleValue: Boolean;
}