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
    defstruct integer: 0, frac: 0, iso: %ISO{}
  end

  def is_money(suspect) do
    case{is_map(suspect),
      Map.has_key?(suspect, :integer),
      Map.has_key?(suspect, :frac),
      Map.has_key?(suspect, :iso)}
    do
      {:true, :true, :true, true} -> :true
      _ -> :false
    end
  end

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

  # def sum (first, second) do
  #   if first do
  #
  #   end
  # end

end
