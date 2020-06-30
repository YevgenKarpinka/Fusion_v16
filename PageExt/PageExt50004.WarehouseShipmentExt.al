pageextension 50004 "Warehouse Shipment Ext." extends "Warehouse Shipment"
{
    layout
    {
        // Add changes to page layout here
        addfirst(factboxes)
        {
            part("Work Description"; "Work Description FactBox")
            {
                CaptionML = ENU = 'Work Description', RUS = 'Описание работы';
                ApplicationArea = All;
                Provider = WhseShptLines;
                SubPageLink = "No." = field("Source No."), "Document Type" = const(Order);
                Visible = false;
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                CaptionML = ENU = 'Attachments', RUS = 'Вложения';
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