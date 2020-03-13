codeunit 50008 "Upgrade Bin Content"
{
    Permissions = tabledata "Bin Content" = rm, tabledata "Warehouse Entry" = r;

    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        BinContent: Record "Bin Content";
        BinConMod: Record "Bin Content";
        LotNo: Code[50];
    begin
        with BinContent do begin
            SetCurrentKey("Lot No.");
            SetRange("Lot No.", '');
            if FindSet(true, false) then
                repeat
                    if BinConMod.Get("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code") then begin
                        LotNo := GetLotNoFromWhseEntry("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
                        if LotNo <> '' then begin
                            BinConMod.Validate("Lot No.", LotNo);
                            BinConMod.Modify();
                        end;
                    end;
                until Next() = 0;
        end;
    end;

    local procedure GetLotNoFromWhseEntry(Location: Code[10]; BinCode: Code[20]; Item: Code[20]; VariantCode: Code[10]; UoMCode: Code[10]): Code[50];
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        with WhseEntry do begin
            SetCurrentKey("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
            SetRange("Location Code", Location);
            SetRange("Bin Code", BinCode);
            SetRange("Item No.", Item);
            SetRange("Variant Code", VariantCode);
            SetRange("Unit of Measure Code", UoMCode);
            if FindLast() then
                exit("Lot No.");
        end;
        exit('');
    end;
}