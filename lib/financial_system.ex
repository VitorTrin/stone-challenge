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

  defmodule ISO do
    @moduledoc """
    Provides a struct that stores ISO 4217 information.
    More info at https://en.wikipedia.org/wiki/ISO_4217
    """
    defstruct alpha_code: "BRL", numeric_code: 986, exponent: 2
  end

  defmodule Money do
    @moduledoc """
    Provides a struct that stores currency amounts.

    The int field stores the integer part of the number, and the frac stores the
    fractional part of the number.

    When the value is negative, both int and frac store are negative.
    """
    defstruct int: 0, frac: 0, iso: %ISO{}
  end

  defmodule Account do
    defstruct user: 0, balance: [%Money{}]
  end

  @doc """
    Tests if a suspect is a FinancialSystem.Money struct

    ## Parameters

      - suspect: Maps that we want to ensure is Money.
  """
  def is_money(suspect) do
    case{is_map(suspect),
      Map.has_key?(suspect, :int),
      Map.has_key?(suspect, :frac),
      Map.has_key?(suspect, :iso)}
    do
      {:true, :true, :true, true} -> :true
      _ -> exit("Attempt to execute monetary operations with something else")
    end
  end

  @doc """
    Tests if 2 maps use the same currency by checking their iso field.
  """
  @spec same_currency(Money, Money) :: boolean
  def same_currency(first, second) do
    is_money(first)
    is_money(second)
    unless(first.iso == second.iso) do
      exit("Attempt to operate distinct currencies without convertion")
    end
      :ok
  end



  def sum(first, second) do
    same_currency(first, second)

    frac_sum = first.frac + second.frac
    int_sum = first.int + second.int
    #fist value too big for the frac
    ten_times_exponent = :math.pow(10, first.iso.exponent) |> round
    carryover =
      if abs(frac_sum) > abs(ten_times_exponent) do
        1
      else
        0
      end
    #performs the carryover
    return = %Money{int: int_sum + carryover,
      frac: frac_sum - (ten_times_exponent * carryover),
      iso: first.iso}
    #makes int and frac have the same sign
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

  def sub(first, second) do
    sum(first, %{second | int: -second.int, frac: -second.frac})
  end

  def compare(first, second) do
    same_currency(first, second)

    cond do
      first.int > second.int ->
        1
      first.int == second.int && first.frac > second.frac ->
        1
      first.int == second.int && first.frac == second.frac ->
        0
      true ->
        -1
    end

  end

  def transfer(source, destination, amount) do
    #check if source has that amount
    [sour_balance | _] = Enum.filter(source.balance,
      fn(x) -> (same_currency(x, amount)) end)
    source = if(compare(sour_balance, amount) >= 0) do
    #updating the source
     %{source | balance: Enum.map(source.balance, fn(x) ->
        if x == sour_balance do
          sub(sour_balance, amount)
        else
          x
        end end)}
      else
        exit("Attempt to transfer more than source account currently has")
      end

    #updating or creating the destination
    [dest_balance | _] = Enum.filter(destination.balance,
      fn(x) -> (same_currency(x, amount)) end)
    destination =  if dest_balance == nil do
      #if there is no such currency on the destination, we create it
      %{destination | balance: [amount | destination.balance]}
    else
      %{destination | balance: Enum.map(destination.balance, fn(x) ->
      if(x == dest_balance) do
        sum(dest_balance, amount)
      else
        x
      end end)}
    end
    [source, destination]
  end

end
