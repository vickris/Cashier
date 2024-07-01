defmodule Checkout do
  @moduledoc """
  Simple Cashier function that adds products to a cart and displays the total price
  SPECIAL RULES:
  1. The CEO is a big fan of buy-one-get-one-free offers and of green tea. He wants us to add a
      rule to do this.
  2. The COO, though, likes low prices and wants people buying strawberries to get a price
      discount for bulk purchases. If you buy 3 or more strawberries, the price should drop to £4.50
      per strawberry.
  3. The CTO is a coffee addict. If you buy 3 or more coffees, the price of all coffees should drop
      to two thirds of the original price.
  """
  use GenServer

  @price_list %{
    "GR1" => 3.11,
    "SR1" => 5.00,
    "CF1" => 11.23
  }

  ########################################
  # CLIENT
  ########################################
  def start do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_to_cart(item) do
    GenServer.cast(__MODULE__, {:add_to_cart, item})
  end

  def remove_from_cart(item) do
    GenServer.cast(__MODULE__, {:remove_from_cart, item})
  end

  def clear_cart() do
    GenServer.cast(__MODULE__, {:clear_cart})
  end

  def view_cart() do
    GenServer.call(__MODULE__, {:view_cart})
  end

  def checkout() do
    GenServer.call(__MODULE__, {:checkout})
  end

  ########################################
  # SERVER
  ########################################
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:view_cart}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:checkout}, _from, state) do
    total =
      Enum.reduce(state, 0, fn {product, count}, acc ->
        acc + apply_rules({product, count})
      end)
      |> Float.round(2)

    {:reply, "£#{total}", state}
  end

  def handle_cast({:add_to_cart, item}, state) do
    state =
      case Map.has_key?(@price_list, item) do
        true ->
          count = Map.get(state, item, 0)
          Map.put(state, item, count + 1)

        false ->
          state
      end

    {:noreply, state}
  end

  def handle_cast({:remove_from_cart, item}, state) do
    state =
      case Map.has_key?(@price_list, item) do
        true ->
          case Map.get(state, item, 0) do
            0 -> state
            1 -> Map.delete(state, item)
            count -> Map.put(state, item, count - 1)
          end

        false ->
          state
      end

    {:noreply, state}
  end

  def handle_cast({:clear_cart}, _state) do
    {:noreply, %{}}
  end

  defp apply_rules({"GR1", count}) do
    case rem(count, 2) do
      0 -> count / 2 * @price_list["GR1"]
      _ -> ceil(count / 2) * @price_list["GR1"]
    end
  end

  defp apply_rules({"SR1", count}) when count >= 3 do
    count * 4.50
  end

  defp apply_rules({"CF1", count}) when count >= 3 do
    count * @price_list["CF1"] * 2 / 3
  end

  defp apply_rules({product, count}) do
    count * @price_list[product]
  end
end
