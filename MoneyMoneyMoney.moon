import GetAddOnMetadata, CreateFrame, GetMoney,
  RepairAllItems, InRepairMode,
  MoneyMoneyMoneyDB, LibStub from _G

LibDataBroker = LibStub\GetLibrary "LibDataBroker-1.1"

export MoneyMoneyMoney

MoneyMoneyMoneyDB or= {}

class HierarchicalDB
  new: (@levels, @queriable) =>

MoneyMoneyMoney =
  Name: "MoneyMoneyMoney"
  Version: GetAddOnMetadata("MoneyMoneyMoney", "Version")
  Frame: CreateFrame "Frame"
  Broker: nil
  DB: nil
  Events:
    PLAYER_ENTERING_WORLD: () =>
      @CurrentGold = GetMoney()
    PLAYER_MONEY: () =>
      delta = GetMoney() - @CurrentGold
      @CurrentGold = GetMoney()
      @UpdateMoney(delta)

  OnEvent: (_, evt, ...) =>
    if @Events[evt]
      @Events[evt](@, ...)
    else
      print "Unhandled event #{evt}!"

  UpdateMoney: (delta) =>
    if @Expected[1] and delta == @Expected[1].Amount
      print "MMM: Expected: #{delta} from #{@Expected[1].Category}"
      table.remove(@Expected, 1)
    else
      for category, opts in pairs(@Categories)
        if flag = opts.HasFlag
          if @Flags[flag]
            print "MMM: Flag: #{delta} from #{source}"
            return
      print "MMM: Got #{delta} from unknown source."

  Expect: (category, amount) =>
    @Expected[#@Expected + 1] = Category: category, Amount: amount
    print "MMM: Expecting #{amount} from #{source}"

  CurrentGold: 0
  Categories: {}
  Flags: {}
  Expected: {}
  Timers: {}

  RegisterCategory: (name, opts={}) =>
    @Categories[name] = opts

  RegisterEvent: (name, actions) =>
    @Events[name] = (...) =>
      if flag = actions.SetFlag
        @Flags[flag] = true
      if flag = actions.ClearFlag
        @Flags[flag] = nil
      if timer = actions.SetTimer
        @Timers[timer] = GetTime()

  RegisterHook: (name, fun) =>
    hooksecurefunc(name, (...) -> fun(@, ...))

MMM = MoneyMoneyMoney

MMM.Broker = with LibDataBroker\NewDataObject("MoneyMoneyMoney_Broker", type: "data source", label: "MoneyMoneyMoney", tocname: "MoneyMoneyMoney")
  .OnTooltipShow = () =>
    @AddLine("This is  a test.")
  .text = "MMM: 10|TInterface\\MONEYFRAME\\UI-GoldIcon:0|t"

MMM\RegisterCategory 'Vendor', HasFlag: 'UsingVendor'
MMM\RegisterEvent 'MERCHANT_SHOW', SetFlag: 'UsingVendor'
MMM\RegisterEvent 'MERCHANT_CLOSED', ClearFlag: 'UsingVendor'
MMM\RegisterHook 'BuyMerchantItem', (idx, qty) =>
  _, _, price, defaultQty = GetMerchantItemInfo(idx)
  @Expect 'Vendor', -price * (qty or defaultQty)

MMM\RegisterCategory 'Flights', :EXPENSES
MMM\RegisterHook 'TakeTaxiNode', (id) =>
  @Expect 'Flights', -TaxiNodeCost(id)

MMM\RegisterCategory 'Repair'
MMM\RegisterHook 'RepairAllItems', (guildBankRepair) =>
  @Expect 'Repair', -GetRepairAllCost() unless guildBankRepair

for k, _ in pairs(MMM.Events)
  MMM.Frame\RegisterEvent(k)

MMM.Frame\SetScript "OnEvent", MMM\OnEvent
