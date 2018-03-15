defmodule FinancialSystem do
  @moduledoc """
  Documentation for FinancialSystem.
  """

  @doc """
  Hello world.

  ## Examples

      iex> FinancialSystem.hello
      :world

  """
  def hello do
    :world
  end

  defmodule Currency do
    @moduledoc """
    Provides a struct that stores ISO 4217 information.
    More info at https://en.wikipedia.org/wiki/ISO_4217
    """

    defstruct [alpha_code: "BRL", numeric_code: 986, exponent: 2]
  end

  defmodule Money do
    @moduledoc """
    Provides a struct that stores currency amounts.

    The int field stores the integer part of the number, and the frac stores the
    fractional part of the number.

    When the value is negative, both int and frac store are negative.
    """

    defstruct [int: 0, frac: 0, currency: %Currency{}]
  end

  defmodule Account do
    @moduledoc """
    Has an unique id and stores the balance in a List of Money.
    The negative ids are reserved for internal use.
    """

    defstruct id: 0, balance: [%Money{}]
  end

  defmodule Ratio do
    @moduledoc """
    Provides a struct that stores exchange rates.
    """

    defstruct [value: 1, neg_exp_of_ten: 0]
  end


  @doc """
  Integer power that is missing from the standard library.
  source: https://twitter.com/quviq/status/768435047569448960
  """
  # Works because 10^exp in numeric base 'base' is base^exp.
  @spec pow(integer, integer) :: integer
  def pow(base, exp) do
    Integer.undigits([1 | :lists.duplicate(exp, 0)], base)
  end

  @doc """
  Tests if 2 maps use the same currency by checking their currency field.
  """
  @spec same_currency(FinancialSystem.Money, FinancialSystem.Money) :: boolean
  def same_currency(first, second) do
    unless(first.currency == second.currency) do
      exit("Attempt to operate distinct currencies without exchange")
    end
      true
  end

  @doc """
  Sums money.
  """
  @spec sum(FinancialSystem.Money, FinancialSystem.Money) :: FinancialSystem.Money
  def sum(first, second) do
    same_currency(first, second)

    frac_sum = first.frac + second.frac
    int_sum = first.int + second.int
    # ten_times_exponent is the fist value too big for the frac.
    ten_times_exponent = pow(10, first.currency.exponent)
    carryover =
      if abs(frac_sum) >= abs(ten_times_exponent) do
        1
      else
        0
      end

    # Performs the carryover.
    return = %Money{int: int_sum + carryover,
      frac: frac_sum - (ten_times_exponent * carryover),
      currency: first.currency}
    # Makes int and frac have the same sign.
    return = if(return.int != 0 and return.frac != 0) do
      case {return.int < 0, return.frac < 0} do
        {true, false} -> %{return | int: return.int + 1,
        frac: return.frac - ten_times_exponent}
        {false, true} -> %{return | int: return.int - 1,
        frac: return.frac + ten_times_exponent}
        _ -> return
      end
      else
        return
      end

    return
  end

  @doc """
  Subtracts money.
  """
  @spec sub(FinancialSystem.Money, FinancialSystem.Money) :: FinancialSystem.Money
  def sub(first, second) do
    sum(first, %{second | int: -second.int, frac: -second.frac})
  end

  @doc """
  Compares Money. Returns the atoms :greater, :equal or :smaller.
  """
  @spec compare(FinancialSystem.Money, FinancialSystem.Money) :: :atom
  def compare(first, second) do
    same_currency(first, second)

    cond do
      first.int > second.int ->
        :greater
      first.int == second.int && first.frac > second.frac ->
        :greater
      first.int == second.int && first.frac == second.frac ->
        :equal
      true ->
        :smaller
    end

  end

  @doc """
  Transfers Money from one Account to another.

  ### Parameters
   - source:  The Account that is sending the money. Must have enough to pay.
   - destination: The Account that is receiving the money.
   - ammount: How much and what currency is going to be transfered.

  ### Return
    {FinancialSystem.Account, FinancialSystem.Account}, where the fist one is an
    updated source and the second one is an updated second.
  """
  @spec transfer(FinancialSystem.Account, FinancialSystem.Account, FinancialSystem.Money) :: %{source: FinancialSystem.Account, destination: FinancialSystem.Account}
  def transfer(source, destination, amount) do
    # Check if source has that amount.
    [sour_balance | _] = Enum.filter(source.balance,
      fn(x) -> x.currency == amount.currency)) end)
    source = if(compare(sour_balance, amount) != :smaller) do
    # Updating the source.
     %{source | balance: Enum.map(source.balance, fn(x) ->
        if x == sour_balance do
          sub(sour_balance, amount)
        else
          x
        end end)}
      else
        exit("Attempt to transfer more than source account currently has")
      end

    # Updating or creating the destination.
    [dest_balance | _] = Enum.filter(destination.balance,
      fn(x) -> x.currency == amount.currency) end)

    destination = if dest_balance == nil do
      # If there is no such currency on the destination, we create it.
      %{destination | balance: [amount | destination.balance]}
    else
      %{destination | balance: Enum.map(destination.balance, fn(x) ->
      if(x == dest_balance) do
        sum(dest_balance, amount)
      else
        x
      end end)}
    end

    %{source: source, destination: destination}
  end

  #Used by exchange to perform int to frac carryovers. Should greater or equal
  #to the largest currency exponent in the ISO_4217
  @padding 4

  @doc """
  Performs monetary exchange.

  ### Parameters
    - source: The amount that is going to be converted.
    - return: The Currency that is going to be the end result
    - rate: The Ratio between the source and the return.
  """
  @spec exchange(FinancialSystem.Money, FinancialSystem.Currency, FinancialSystem.Ratio) :: FinancialSystem.Money
  def exchange(source, return, rate) do
    # Fist we apply the rate to the integer part.
    raw_int = source.int * rate.value
    digits_raw_int = Integer.digits(raw_int)
    int_of_raw_int = digits_raw_int |>
      Enum.slice(0, length(digits_raw_int) - rate.neg_exp_of_ten) |>
      Integer.undigits()

    # The fractionary part of the raw_int must be used in the raw_frac.
    frac_of_raw_int = digits_raw_int |>
      Enum.slice(length(digits_raw_int) - rate.neg_exp_of_ten, rate.neg_exp_of_ten) |>
      Integer.undigits()

    # Padding zeroes.
    overpadded_list = Integer.digits(frac_of_raw_int) ++ List.duplicate(0, @padding)
    frac_of_raw_int = Enum.slice(overpadded_list, 0, return.exponent) |>
      Integer.undigits()

    # We must truncate the frac_of_raw_int to add to frac_sum
    trunc_frac_of_raw_int = Integer.digits(frac_of_raw_int) |>
      Enum.slice(0, return.exponent) |> Integer.undigits()


    # Diff_in_size lets us know if the size of frac will change and how much
    # it is positive if it should grow.
    diff_in_size = return.exponent - source.currency.exponent

    raw_frac = source.frac * rate.value
    digits_raw_frac = Integer.digits(raw_frac)
    # Truncating the frac part by removing any aditional digits, after this line
    # it is in the return frac size.
    truncated_frac = digits_raw_frac |>
      Enum.slice(0, length(digits_raw_frac) - rate.neg_exp_of_ten + diff_in_size) |>
      Integer.undigits()

    # We are almost there, but we should solve carryovers first.
    almost_final_frac = truncated_frac + trunc_frac_of_raw_int
    digits_afc = Integer.digits(almost_final_frac)

    {int_carryover, final_frac} =
      if length(digits_afc) > return.exponent do
        {digits_afc |>
          Enum.slice(0, length(digits_afc) - return.exponent) |>
          Integer.undigits(),
         digits_afc |>
           Enum.slice(length(digits_afc) - return.exponent,
           length(digits_afc)) |> Integer.undigits()}
      else
        {0, almost_final_frac}
      end

    final_int = int_of_raw_int + int_carryover

    %Money{int: final_int, frac: final_frac, currency: return}
  end

  #FIXME:Documentation.
  # For the moment, currency exchanged doesn't need to come from other account,
  # which isn't right. In a more complex system, there would be exchange office
  # account.
  @spec account_exchange(FinancialSystem.Account, FinancialSystem.Money,
   FinancialSystem.Currency, FinancialSystem.Ratio) :: FinancialSystem.Account
  def account_exchange(account, source_ammount, result_currency, ratio) do
    # To exchange, first we transfer from the account.
    %{source: account, destination: temp_acc} =
      transfer(account, %Account{id: -1}, source_ammount)

    temp_acc_balance = first(temp_acc.balance)0

    exchanged_money = exchange(temp_acc_balance, result_currency, ratio)
    %{temp_acc | balance: [exchanged_money]}

    %{source: temp_acc, destination: account} =
      transfer(temp_acc, account, exchanged_money)

    account
  end

  @spec sum_ratios(FinancialSystem.Ratio, FinancialSystem.Ratio) :: FinancialSystem.Ratio
  defp sum_ratios(first_ratio, second_ratio) do
    # First they must be in the same base, and for that we use the greatest base.
    greatest_base = if (first_ratio.neg_exp_of_ten >
    second_ratio.neg_exp_of_ten) do
      first_ratio.neg_exp_of_ten
    else
      second_ratio.neg_exp_of_ten
    end

    diff_base = greatest_base - first_ratio.neg_exp_of_ten
    first_ratio = %{first_ratio | value: first_ratio.value * pow(10, diff_base)}

    diff_base = greatest_base - second_ratio.neg_exp_of_ten
    second_ratio = %{second_ratio | value: second_ratio.value * pow(10, diff_base)}

    %Ratio{value: first_ratio.value + second_ratio.value,
      neg_exp_of_ten: greatest_base}

  end

  @spec is_sum_one([FinancialSystem.Ratio]) :: nil
  defp is_sum_one(ratios) do
    total_ratios = Enum.reduce(ratios, fn(x, acc) -> sum_ratios(x, acc) end)
    # There are infinite ways to write one in the ratio notation, so the best check is:
    should_be_zero = sum_ratios(total_ratios, %Ratio{value: -1, neg_exp_of_ten: 0})
    unless (should_be_zero.value == 0) do
      exit("The sum of the splits isn't the same as the total")
    end
  end

  @spec mult(FinancialSystem.Money, FinancialSystem.Ratio) :: FinancialSystem.Money
  defp mult(money, rate) do
    # Rate multiplication is a case of exchange where the currency stays the same.
    exchange(money, money.currency, rate)
  end

  @doc """
  Performs split payment.

  ### Parameters
    - source: The account the money comes from.
    - splits: A list of maps that are pairs of destination account and it's ratio
    - total_transfer: How much is the transfer.
  """

  @spec transfer_split(FinancialSystem.Account, [%{account: FinancialSystem.Account, ratio: FinancialSystem.Ratio}], FinancialSystem.Money) :: [FinancialSystem.Account]
  def transfer_split(source, splits, total_transfer) do
      # First we much check if the sum of all rations is 1.
      just_the_ratios = Enum.map(splits, fn(x) -> x.ratio end)
      is_sum_one(just_the_ratios)

      # To perform the transfer, first we transfer from the source to a temp account.
      %{source: source, destination: temp_acc} = transfer(source, %Account{id: -1}, total_transfer)

      # If sucessful, now we can spread it around.
      [source | Enum.map(splits, fn(x) -> transfer(temp_acc, x.account,
        mult(total_transfer, x.ratio)).destination end )]
  end

end
