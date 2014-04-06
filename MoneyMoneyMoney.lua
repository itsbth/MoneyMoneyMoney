local GetAddOnMetadata, CreateFrame, GetMoney, RepairAllItems, InRepairMode, MoneyMoneyMoneyDB, LibStub
do
  local _obj_0 = _G
  GetAddOnMetadata, CreateFrame, GetMoney, RepairAllItems, InRepairMode, MoneyMoneyMoneyDB, LibStub = _obj_0.GetAddOnMetadata, _obj_0.CreateFrame, _obj_0.GetMoney, _obj_0.RepairAllItems, _obj_0.InRepairMode, _obj_0.MoneyMoneyMoneyDB, _obj_0.LibStub
end
local LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1")
MoneyMoneyMoneyDB = MoneyMoneyMoneyDB or { }
local HierarchicalDB
do
  local _base_0 = { }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, levels, queriable)
      self.levels, self.queriable = levels, queriable
    end,
    __base = _base_0,
    __name = "HierarchicalDB"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  HierarchicalDB = _class_0
end
MoneyMoneyMoney = {
  Name = "MoneyMoneyMoney",
  Version = GetAddOnMetadata("MoneyMoneyMoney", "Version"),
  Frame = CreateFrame("Frame"),
  Broker = nil,
  DB = nil,
  Events = {
    PLAYER_ENTERING_WORLD = function(self)
      self.CurrentGold = GetMoney()
    end,
    PLAYER_MONEY = function(self)
      local delta = GetMoney() - self.CurrentGold
      self.CurrentGold = GetMoney()
      return self:UpdateMoney(delta)
    end
  },
  OnEvent = function(self, _, evt, ...)
    if self.Events[evt] then
      return self.Events[evt](self, ...)
    else
      return print("Unhandled event " .. tostring(evt) .. "!")
    end
  end,
  UpdateMoney = function(self, delta)
    if self.Expected[1] and delta == self.Expected[1].Amount then
      print("MMM: Expected: " .. tostring(delta) .. " from " .. tostring(self.Expected[1].Category))
      return table.remove(self.Expected, 1)
    else
      for category, opts in pairs(self.Categories) do
        do
          local flag = opts.HasFlag
          if flag then
            if self.Flags[flag] then
              print("MMM: Flag: " .. tostring(delta) .. " from " .. tostring(source))
              return 
            end
          end
        end
      end
      return print("MMM: Got " .. tostring(delta) .. " from unknown source.")
    end
  end,
  Expect = function(self, source, amount)
    self.Expected[#self.Expected + 1] = {
      Source = source,
      Amount = amount
    }
    return print("MMM: Expecting " .. tostring(amount) .. " from " .. tostring(source))
  end,
  CurrentGold = 0,
  Categories = { },
  Flags = { },
  Expected = { },
  Timers = { },
  RegisterCategory = function(self, name, opts)
    if opts == nil then
      opts = { }
    end
    self.Categories[name] = opts
  end,
  RegisterEvent = function(self, name, actions)
    self.Events[name] = function(self, ...)
      do
        local flag = actions.SetFlag
        if flag then
          self.Flags[flag] = true
        end
      end
      do
        local flag = actions.ClearFlag
        if flag then
          self.Flags[flag] = nil
        end
      end
      do
        local timer = actions.SetTimer
        if timer then
          self.Timers[timer] = GetTime()
        end
      end
    end
  end,
  RegisterHook = function(self, name, fun)
    return hooksecurefunc(name, function(...)
      return fun(self, ...)
    end)
  end
}
local MMM = MoneyMoneyMoney
do
  local _with_0 = LibDataBroker:NewDataObject("MoneyMoneyMoney_Broker", {
    type = "data source",
    label = "MoneyMoneyMoney",
    tocname = "MoneyMoneyMoney"
  })
  _with_0.OnTooltipShow = function(self)
    return self:AddLine("This is  a test.")
  end
  _with_0.text = "MMM: 10|TInterface\\MONEYFRAME\\UI-GoldIcon:0|t"
  MMM.Broker = _with_0
end
MMM:RegisterCategory('Vendor', {
  HasFlag = 'UsingVendor'
})
MMM:RegisterEvent('MERCHANT_SHOW', {
  SetFlag = 'UsingVendor'
})
MMM:RegisterEvent('MERCHANT_CLOSED', {
  ClearFlag = 'UsingVendor'
})
MMM:RegisterHook('BuyMerchantItem', function(self, idx, qty)
  local _, price, defaultQty
  _, _, price, defaultQty = GetMerchantItemInfo(idx)
  return self:Expect('Vendor', -price * (qty or defaultQty))
end)
MMM:RegisterCategory('Flights', {
  EXPENSES = EXPENSES
})
MMM:RegisterHook('TakeTaxiNode', function(self, id)
  return self:Expect('Flights', -TaxiNodeCost(id))
end)
MMM:RegisterCategory('Repair')
MMM:RegisterHook('RepairAllItems', function(self, guildBankRepair)
  if not (guildBankRepair) then
    return self:Expect('Repair', -GetRepairAllCost())
  end
end)
for k, _ in pairs(MMM.Events) do
  MMM.Frame:RegisterEvent(k)
end
return MMM.Frame:SetScript("OnEvent", (function()
  local _base_0 = MMM
  local _fn_0 = _base_0.OnEvent
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())
