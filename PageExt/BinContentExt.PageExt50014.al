pageextension 50101 "Bin Content Ext." extends "Bin Content"
{
    layout
    {
        addfirst(Control1)
        {
            field("Lot No."; "Lot No.")
            {
                ApplicationArea = All;
            }
        }
    }
}