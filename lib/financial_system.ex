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
  
  # def sum (first, second) do
  #   if first do
  #
  #   end
  # end

end
