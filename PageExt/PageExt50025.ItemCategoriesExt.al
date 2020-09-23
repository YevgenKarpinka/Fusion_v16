pageextension 50025 "Item Categories Ext" extends "Item Categories"
{
    layout
    {
        // Add changes to page layout here
        addlast(content)
        {
            field("Description RU"; "Description RU")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}