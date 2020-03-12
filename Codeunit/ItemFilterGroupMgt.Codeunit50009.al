codeunit 50009 "Item Filter Group Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure OnLookUpItemNo(var filterByItemNo: Text; var locItemFilterGroup: Record "Item Filter Group")
    var
        tempItemFilterGroup: Record "Item Filter Group" temporary;
    begin
        if not tempItemFilterGroup.IsTemporary then exit;
        tempItemFilterGroup.Reset();
        tempItemFilterGroup.DeleteAll();

        with locItemFilterGroup do begin
            FindSet(false, false);
            repeat
                tempItemFilterGroup.SetRange("Item No.", "Item No.");
                if not tempItemFilterGroup.FindFirst() then begin
                    tempItemFilterGroup.TransferFields(locItemFilterGroup);
                    tempItemFilterGroup.Insert();
                end;
            until Next() = 0;
        end;

        if Page.RunModal(Page::"Item Filter Group List", tempItemFilterGroup) = Action::LookupOK then begin
            filterByItemNo += StrSubstNo('|%1', tempItemFilterGroup."Item No.");
            if StrPos(filterByItemNo, '|') = 1 then
                filterByItemNo := CopyStr(filterByItemNo, 2, StrLen(filterByItemNo));
        end;
    end;

    procedure OnLookUpGroup(var filterByGroup: Text; locItemFilterGroup: Record "Item Filter Group")
    var
        tempItemFilterGroup: Record "Item Filter Group" temporary;
    begin
        if not tempItemFilterGroup.IsTemporary then exit;
        tempItemFilterGroup.Reset();
        tempItemFilterGroup.DeleteAll();

        with locItemFilterGroup do begin
            FindSet(false, false);
            repeat
                tempItemFilterGroup.SetRange("Filter Group", "Filter Group");
                if not tempItemFilterGroup.FindFirst() then begin
                    tempItemFilterGroup.TransferFields(locItemFilterGroup);
                    tempItemFilterGroup.Insert();
                end;
            until Next() = 0;
        end;

        if Page.RunModal(Page::"Item Filter Group List", tempItemFilterGroup) = Action::LookupOK then begin
            filterByGroup += StrSubstNo('|%1', tempItemFilterGroup."Filter Group");
            if StrPos(filterByGroup, '|') = 1 then
                filterByGroup := CopyStr(filterByGroup, 2, StrLen(filterByGroup));
        end;
    end;

    procedure OnLookUpValue(var filterByValue: Text; var _ItemFilterGroup: Record "Item Filter Group")
    var
        tempItemFilterGroup: Record "Item Filter Group" temporary;
        locItemFilterGroup: Record "Item Filter Group";
    begin
        if not tempItemFilterGroup.IsTemporary then exit;
        tempItemFilterGroup.Reset();
        tempItemFilterGroup.DeleteAll();

        with locItemFilterGroup do begin
            SetFilter("Filter Group", _ItemFilterGroup.GetFilter("Filter Group"));
            FindSet(false, false);
            repeat
                tempItemFilterGroup.SetRange("Filter Value", "Filter Value");
                if not tempItemFilterGroup.FindFirst() then begin
                    tempItemFilterGroup.TransferFields(locItemFilterGroup);
                    tempItemFilterGroup.Insert();
                end;
            until Next() = 0;
        end;

        if Page.RunModal(Page::"Item Filter Group List", tempItemFilterGroup) = Action::LookupOK then begin
            filterByValue += StrSubstNo('|%1', tempItemFilterGroup."Filter Value");
            if StrPos(filterByValue, '|') = 1 then
                filterByValue := CopyStr(filterByValue, 2, StrLen(filterByValue));
        end;
    end;
}