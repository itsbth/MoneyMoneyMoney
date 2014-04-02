local CurrentGold = 0
MoneyMoneyMoney = {
  Name = "MoneyMoneyMoney",
  Version = GetAddOnMetadata("KillTrack", "Version"),
  Frame = CreateFrame("Frame"),
  Events = {
    PLAYER_MONEY = function()
      return print("MMM: Got " .. tostring(CurrentGold()))
    end
  }
}
