pageextension 50020 "Bin Content Ext." extends "Bin Content"
{
    layout
    {
        addfirst(Control1)
        {
            field("Lot No."; Rec."Lot No.")
            {
                ApplicationArea = All;
            }
        }
    }
}