codeunit 50011 "DXCEventHandling3"
{     

    [EventSubscriber(ObjectType::Page, 7335, 'OnAfterCreatePick', '', false, false)]
    local procedure HandleOnAfterCreatePickOnWarehouseShipment(WhseShipHeader : Record "Warehouse Shipment Header");
      var          
        WhseShipLine: Record "Warehouse Shipment Line";
    begin
        WhseShipLine.SETRANGE("No.",WhseShipHeader."No.");
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
    // >> AMC-125
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnAfterCheckJnlLine', '', false, false)]
    local procedure HandleAfterCheckJnlLineOnItemJnlPostBatch(ItemJournalLine : Record "Item Journal Line")
      var
        ProdOrder : Record "Production Order";
        ProdOrderLine : Record "Prod. Order Line";
    begin
        if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Output then
          exit;
        if ItemJournalLine."Order Type" <> ItemJournalLine."Order Type"::Production then
          exit;
        ProdOrder.GET(ProdOrder.Status::Released,ItemJournalLine."Order No.");
        ProdOrderLine.GET(ProdOrder.Status::Released,ItemJournalLine."Order No.",ItemJournalLine."Order Line No.");
        if ProdOrderLine."Finished Quantity" + ItemJournalLine.Quantity > ProdOrder.Quantity then
          ERROR(Text002,ProdOrderLine.FIELDCAPTION("Finished Quantity"),ProdOrder.FIELDCAPTION(Quantity),ProdOrder."No."); 
    end;
    // << AMC-125
    // >> AMC-131
    [EventSubscriber(ObjectType::Page, 7365, 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure Handle11(var Rec : Record "Warehouse Journal Line");
    var
        WhseJnlLine : Record "Warehouse Journal Line";
    begin
        
        WhseJnlLine := Rec;
        WhseJnlLine.SETRECFILTER;       

        WhseJnlLine.SETRANGE("Item No.",'');
        WhseJnlLine.SETFILTER("Registering Date",'<>%1',TODAY);
        if WhseJnlLine.FINDFIRST then
          Rec.DELETE;
        
    end;
    // << AMC-131

    // << AMC-131
    [EventSubscriber(ObjectType::Page, 7324, 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure Handle12(var Rec : Record "Warehouse Journal Line");
    var
        WhseJnlLine : Record "Warehouse Journal Line";
    begin
        
        WhseJnlLine := Rec;
        WhseJnlLine.SETRECFILTER;        

        WhseJnlLine.SETRANGE("Item No.",'');
        WhseJnlLine.SETFILTER("Registering Date",'<>%1',TODAY);
        if WhseJnlLine.FINDFIRST then
          Rec.DELETE;
       
    end;
    // << AMC-131

    var
        Text001 : Label '%1 is %2 and %3 is %4 on item %5';
        Text002 : Label '%1 is greater than %2 on Prod. Order %3';
}