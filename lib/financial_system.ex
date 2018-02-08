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
      _ -> :false
    end
  end

  @doc """
    Tests if 2 maps use the same currency by checking their iso field.
  """
  # @spec same_currency(Money, Money) :: list(atom)
  # def same_currency(first, second) do
  #   case {is_money(first),
  #     is_money(second),
  #     first.iso == second.iso}
  #   do
  #     {:true, :true, :true} ->[:ok]
  #     {:true, :true, :false} ->[:err, "Not same currency"]
  #     {:false, :false, _} -> [:err, "Parameters aren't currency"]
  #     {:false, _, _} -> [:err, "Parameter 1 isn't currency"]
  #     {_, :false, _} -> [:err, "Parameter 2 isn't currency"]
  #     _ -> [:err]
  #   end
  # end

  @spec same_currency(Money, Money) :: boolean
  def same_currency(first, second) do
    case {is_money(first),
      is_money(second),
      first.iso == second.iso}
    do
      {:true, :true, :true} -> true
      _ -> false
    end
  end



  def sum(first, second) do
    guard = same_currency(first, second)
    if guard do
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
          {true, false} -> %{return | int: return.int - 1,
          frac: return.frac + ten_times_exponent}
          {false, true} -> %{return | int: return.int + 1,
          frac: return.frac - ten_times_exponent}
        end
        else
          return
        end
      return
    else
      guard
    end
  end

  def sub(first, second) do
    #dummy
  end

  def compare(first, second) do
    guard = same_currency(first, second)
    if guard do
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
    else
      guard
    end
  end

  def transfer(source, destination, amount) do
    #check if source has that amount
    [result | _] = Enum.filter(source.balance, fn(x) -> (same_currency(x, amount)) end)
    source = if(compare(result, amount) >= 0) do
    #updating the source
     %{source | balance: Enum.map(source.balance, fn(x) ->
        if x == result do
          sub(result, amount)
        else
          x
        end end)}
      else
        [:err]
      end

    #updating or creating the destination
    [result | _] = Enum.filter(destination.balance, fn(x) -> (same_currency(x, amount)) end)
    destination =  cond do
      #if source returned an error, destination should not be an error too
      source == [:err] -> [:err]
      #case there is no such currency on the destination, we create it
      result == nil -> %{destination | balance: [amount | destination.balance]}
      true -> %{destination | balance: Enum.map(destination.balance, fn(x) ->
        if(x == result) do
          sum(result, amount)
        else
          x
        end end)}
    end
    [source, destination]
  end

end
