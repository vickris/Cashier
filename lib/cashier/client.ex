defmodule Cashier.CashierClient do
  @moduledoc """
  Convenience functions for interacting with the Cashier server.
  """

  @server Cashier.CashierServer

  def start do
    GenServer.start_link(@server, :ok, name: @server)
  end

  def add_to_cart(item) do
    GenServer.cast(@server, {:add_to_cart, item})
  end

  def remove_from_cart(item) do
    GenServer.cast(@server, {:remove_from_cart, item})
  end

  def clear_cart() do
    GenServer.cast(@server, {:clear_cart})
  end

  def view_cart() do
    GenServer.call(@server, {:view_cart})
  end

  def checkout() do
    GenServer.call(@server, {:checkout})
  end
end
