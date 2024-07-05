defmodule Cashier.CashierClient do
  @moduledoc """
  Convenience functions for interacting with the Cashier server.
  """

  alias Cashier.CashierServer.Inventory

  @server Cashier.CashierServer

  def start do
    GenServer.start_link(@server, :ok, name: @server)
  end

  def add_to_cart(item)
      when not is_binary(item),
      do: raise(ArgumentError, "Item code must be a string")

  def add_to_cart(""), do: raise(ArgumentError, "Item code cannot be empty")
  def add_to_cart(nil), do: raise(ArgumentError, "Item code cannot be nil")

  def add_to_cart(item) do
    %Inventory{price_list: price_list} = %Inventory{}

    case price_list[item] do
      nil ->
        raise(ArgumentError, "Item code is not part of inventory")

      _ ->
        GenServer.cast(@server, {:add_to_cart, item})
    end
  end

  def remove_from_cart(""), do: raise(ArgumentError, "Item code cannot be empty")
  def remove_from_cart(nil), do: raise(ArgumentError, "Item code cannot be nil")

  def remove_from_cart(item)
      when not is_binary(item),
      do: raise(ArgumentError, "Item code must be a string")

  def remove_from_cart(item) do
    %Inventory{price_list: price_list} = %Inventory{}

    case price_list[item] do
      nil ->
        raise(ArgumentError, "Item code is not part of inventory")

      _ ->
        GenServer.cast(@server, {:remove_from_cart, item})
    end
  end

  def clear_cart() do
    GenServer.cast(@server, :clear_cart)
  end

  def view_cart() do
    GenServer.call(@server, :view_cart)
  end

  def checkout() do
    GenServer.call(@server, :checkout)
  end
end
