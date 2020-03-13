pageextension 50004 "Warehouse Shipment Ext." extends "Warehouse Shipment"
{
    layout
    {
        // Add changes to page layout here
        addfirst(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                CaptionML = ENU = 'Attachments';
                ApplicationArea = All;
                SubPageLink = "Table ID" = CONST(7320), "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}