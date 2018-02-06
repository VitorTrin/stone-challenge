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
    defstruct code: "BRL", number: 986, exponent: 2
  end

  defmodule Money do
    defstruct int: 0, frac: 0, iso: %ISO{}
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
  def same_currency(first, second) do
    case {is_money(first),
      is_money(second),
      first.iso == second.iso}
    do
      {:true, :true, :true} ->[:ok]
      {:true, :true, :false} ->[:err, "Not same currency"]
      {:false, :false, _} -> [:err, "Parameters aren't currency"]
      {:false, _, _} -> [:err, "Parameter 1 isn't currency"]
      {_, :false, _} -> [:err, "Parameter 2 isn't currency"]
      _ -> [:err]
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
end
