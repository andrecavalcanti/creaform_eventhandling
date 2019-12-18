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
    local procedure HandleOnAfterGetCurrRecordWhseReclassJournal(var Rec : Record "Warehouse Journal Line");
    var
        WhseJnlLine : Record "Warehouse Journal Line";
    begin
        EXIT;
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
    local procedure HandlefterGetCurrRecordOnWhseItemJournal(var Rec : Record "Warehouse Journal Line");
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
    // << AMC-129
    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Qty. to Assemble to Stock', false, false)]
    local procedure HandleAfterValidateQtyToAssembleToStock(var Rec : Record "Sales Line"; var xRec : Record "Sales Line";CurrFieldNo : Integer)
    begin
      if (rec."Document Type" <> rec."Document Type"::Order) then
        exit;
      if (Rec.Type <> Rec.Type::Item) then
        exit;
      if (rec."Qty. to Assemble to Stock" > rec.Quantity) then
        Error(Text003);
    end;
    // << AMC-129
    // >> AMC-121
    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertItemLedgEntry', '', false, false)]
    local procedure HandleBeforeInsertItemLedgEntryOnItemJnlPostLine(var ItemLedgerEntry : Record "Item Ledger Entry";ItemJournalLine : Record "Item Journal Line");
    var
        SalesShipHeader : Record "Sales Shipment Header";
        PurchReceiptHeader : Record "Purch. Rcpt. Header";
    begin

        if (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Sale) and (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment") then begin
          if SalesShipHeader.GET(ItemLedgerEntry."Document No.") then
            ItemLedgerEntry."Source Document No." := SalesShipHeader."Order No.";
        end;

        if (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Purchase) and (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Receipt") then begin
          if PurchReceiptHeader.GET(ItemLedgerEntry."Document No.") then
            ItemLedgerEntry."Source Document No." := PurchReceiptHeader."Order No.";
        end;
    end;
    // << AMC-121

     // >> AMC-135
    [EventSubscriber(ObjectType::Table, 5406, 'OnBeforeInsertEvent', '', false, false)]
    local procedure HandleBeforeInsertOnProdOrderLine(var Rec : Record "Prod. Order Line";RunTrigger : Boolean);            
    begin
        Rec."Planning Flexibility" := Rec."Planning Flexibility"::None;        
    end;
    // << AMC-135
    var
        Text001 : Label '%1 is %2 and %3 is %4 on item %5';
        Text002 : Label '%1 is greater than %2 on Prod. Order %3';
        Text003 : Label 'Qty. to Assemble to Stock cannot be greater than Quantity';
}