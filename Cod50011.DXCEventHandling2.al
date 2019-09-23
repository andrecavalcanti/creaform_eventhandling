codeunit 50011 "DXCEventHandling3"
{        
    [EventSubscriber(ObjectType::Page, 7335, 'OnAfterActionEvent', 'Create Pick', false, false)]
    local procedure HandleOnAfterActionCreatePickOnWarehouseShipment(var Rec : Record "Warehouse Shipment Header");
      var          
              WhseShipLine: Record "Warehouse Shipment Line";
    begin
        WhseShipLine.SETRANGE("No.",Rec."No.");
        WhseShipLine.SETAUTOCALCFIELDS("Pick Qty. (Base)");
        if WhseShipLine.FINDFIRST then
          repeat
            if (WhseShipLine."Pick Qty. (Base)" <> WhseShipLine."Qty. (Base)") then begin
              MESSAGE(Text001,WhseShipLine.FIELDCAPTION("Pick Qty. (Base)"),
                WhseShipLine."Pick Qty. (Base)", WhseShipLine.FIELDCAPTION("Qty. (Base)"), WhseShipLine."Qty. (Base)",WhseShipLine."Item No.");
              exit;
            end;
          until WhseShipLine.NEXT = 0;
    end;

    var
        Text001 : Label '%1 is %2 and %3 is %4 on item %5';
}