export MoneyMoneyMoney

CurrentGold = 0

MoneyMoneyMoney =
  Name: "MoneyMoneyMoney"
  Version: GetAddOnMetadata("KillTrack", "Version")
  Frame: CreateFrame "Frame"
  Events:
    PLAYER_MONEY: () ->
      print "MMM: Got #{CurrentGold()}"