defmodule FinancialSystemTest do
  use ExUnit.Case
  doctest FinancialSystem
  import FinancialSystem

  #Sum
  test "sum/2 should sum Money" do
    #1 + 1 = 2
    assert sum(%FinancialSystem.Money{int: 1}, %FinancialSystem.Money{int: 1})
      == %FinancialSystem.Money{int: 2}
    #50 + 200 = 250
    assert sum(%FinancialSystem.Money{int: 50}, %FinancialSystem.Money{int: 200})
      == %FinancialSystem.Money{int: 250}
    #(-50) + 200 = 150
    assert sum(%FinancialSystem.Money{int: -50}, %FinancialSystem.Money{int: 200})
      == %FinancialSystem.Money{int: 150}
    #(-50) + (-200) = (-250)
    assert sum(%FinancialSystem.Money{int: -50}, %FinancialSystem.Money{int: -200})
        == %FinancialSystem.Money{int: -250}
    #0.1 + 0.1 = 0.2
    assert sum(%FinancialSystem.Money{frac: 1},
    %FinancialSystem.Money{frac: 1})
      == %FinancialSystem.Money{frac: 2}
    #0.2 + 0.73 = 0.93
    assert sum(%FinancialSystem.Money{frac: 20},
    %FinancialSystem.Money{frac: 73})
      == %FinancialSystem.Money{frac: 93}
    #0.9 + 0.1 = 1
    assert sum(%FinancialSystem.Money{frac: 90},
    %FinancialSystem.Money{frac: 10})
      == %FinancialSystem.Money{int: 1}
    #0.56 + 0.74 = 1.3
    assert sum(%FinancialSystem.Money{frac: 56},
    %FinancialSystem.Money{frac: 74})
      == %FinancialSystem.Money{int: 1, frac: 30}
    #12.34 + 56.78 = 69.12
    assert sum(%FinancialSystem.Money{int: 12, frac: 34},
    %FinancialSystem.Money{int: 56, frac: 78})
      == %FinancialSystem.Money{int: 69, frac: 12}
    #1.75 + (- 0.99) = 0.76
    assert sum(%FinancialSystem.Money{int: 1, frac: 75},
    %FinancialSystem.Money{int: 0, frac: -99})
      == %FinancialSystem.Money{int: 0, frac: 76}
  end

  #Sub
  test "sub/2 should subtract Money" do
    #1 - 1 = 0
    assert sub(%FinancialSystem.Money{int: 1}, %FinancialSystem.Money{int: 1})
      == %FinancialSystem.Money{int: 0}
    #50 - 200 = (-150)
    assert sub(%FinancialSystem.Money{int: 50}, %FinancialSystem.Money{int: 200})
      == %FinancialSystem.Money{int: -150}
    #(-50) - 200 = (-250)
    assert sub(%FinancialSystem.Money{int: -50}, %FinancialSystem.Money{int: 200})
      == %FinancialSystem.Money{int: -250}
    #(-50) - (-200) = 150
    assert sub(%FinancialSystem.Money{int: -50}, %FinancialSystem.Money{int: -200})
        == %FinancialSystem.Money{int: 150}
    #0.1 - 0.1 = 0
    assert sub(%FinancialSystem.Money{frac: 1},
    %FinancialSystem.Money{frac: 1})
      == %FinancialSystem.Money{int: 0}
    #0.2 - 0.73 = (-0.53)
    assert sub(%FinancialSystem.Money{frac: 20},
    %FinancialSystem.Money{frac: 73})
      == %FinancialSystem.Money{frac: -53}
    #0.9 - 0.1 = 0.8
    assert sub(%FinancialSystem.Money{frac: 90},
    %FinancialSystem.Money{frac: 10})
      == %FinancialSystem.Money{frac: 80}
    #0.56 - 0.74 = (-0.18)
    assert sub(%FinancialSystem.Money{frac: 56},
    %FinancialSystem.Money{frac: 74})
      == %FinancialSystem.Money{int: 0, frac: -18}
    #12.34 - 56.78 = 44.44
    assert sub(%FinancialSystem.Money{int: 12, frac: 34},
    %FinancialSystem.Money{int: 56, frac: 78})
      == %FinancialSystem.Money{int: -44, frac: -44}
    #1.75 - (- 0.99) = 1.74
    assert sub(%FinancialSystem.Money{int: 1, frac: 75},
    %FinancialSystem.Money{int: 0, frac: -99})
      == %FinancialSystem.Money{int: 2, frac: 74}
  end



  #Behavior tests
  # test "User should be able to transfer money to another account" do
  #   donor_balance = %FinancialSystem.Money{int: 5000, frac: 99}
  #   recipient_balance = %FinancialSystem.Money{int: 303, frac: 67}
  #
  #   recipient = %FinancialSystem.Account{id: 0, balance: [recipient_balance]}
  #   donor = %FinancialSystem.Account{id: 1, balance: [donor_balance]}
  #
  #   transfer_ammount = %FinancialSystem.Money{int: 102, frac: 50}
  #
  #   [donor_result, recipient_result] = FinancialSystem.transfer(donor, recipient, transfer_ammount)
  #
  #   donor_money = List.first(donor_result.balance)
  #   recipient_money = List.first(recipient_result.balance)
  #
  #   assert donor_money.int == 4898
  #   assert donor_money.frac == 49
  #
  #   assert recipient_money.int == 406
  #   assert recipient_money.frac == 17
  # end
  #
  # test "User cannot transfer if not enough money available on the account" do
  #   donor_balance = %FinancialSystem.Money{int: 5000, frac: 99}
  #   recipient_balance = %FinancialSystem.Money{int: 303, frac: 67}
  #
  #   recipient = %FinancialSystem.Account{id: 0, balance: [recipient_balance]}
  #   donor = %FinancialSystem.Account{id: 1, balance: [donor_balance]}
  #
  #   transfer_ammount = %FinancialSystem.Money{int: 60002, frac: 50}
  #
  #   [donor_result, recipient_result] = FinancialSystem.transfer(donor, recipient, transfer_ammount)
  #
  #   # donor_money = List.first(donor_result.balance)
  #   # recipient_money = List.first(recipient_result.balance)
  #   #
  #   # assert donor_money.int == 4898
  #   # assert donor_money.frac == 49
  #   #
  #   # assert recipient_money.int == 406
  #   # assert recipient_money.frac == 17
  #
  # end
  #
  # test "A transfer should be cancelled if an error occurs" do
  #   assert :false
  # end
  #
  # test "A transfer can be splitted between 2 or more accounts" do
  #   assert :false
  # end
  #
  # test "User should be able to exchange money between different currencies" do
  #   assert :false
  # end
  #
  # test "Currencies should be in compliance with ISO 4217" do
  #   assert :false
  # end
end
