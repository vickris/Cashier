defmodule Cashier.CashierServer do
  @moduledoc """
  Contains functions that respond to events from the client.
  """

  use GenServer
  require Logger

  defmodule Inventory do
    defstruct price_list: %{
                "GR1" => 3.11,
                "SR1" => 5.00,
                "CF1" => 11.23
              },
              item_names: %{
                "GR1" => "Green Tea",
                "SR1" => "Strawberry",
                "CF1" => "Coffee"
              }
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:view_cart, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:checkout, _from, state) do
    {:ok, total} =
      Enum.reduce(state, Money.new(0, :GBP), fn {product, count}, acc ->
        other = apply_rules({product, count})
        {:ok, acc} = Money.sum([acc, other])
        acc
      end)
      |> Money.to_string()

    {:reply, total, state}
  end

  @impl true
  def handle_cast(
        {:add_to_cart, item},
        state
      ) do
    %Inventory{item_names: item_names} = %Inventory{}

    Logger.info("Adding one #{item_names[item]} to cart")
    count = Map.get(state, item, 0)
    state = Map.put(state, item, count + 1)

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:remove_from_cart, item},
        state
      ) do
    %Inventory{item_names: item_names} = %Inventory{}

    state =
      case Map.get(state, item, 0) do
        0 ->
          Logger.warn("#{item_names[item]} does not exist in cart")
          state

        1 ->
          Logger.info("Successfully removed #{item_names[item]} from cart")
          Map.delete(state, item)

        count ->
          Logger.info("Removing one #{item_names[item]} from cart")
          Map.put(state, item, count - 1)
      end

    {:noreply, state}
  end

  @impl true
  def handle_cast(:clear_cart, _state) do
    {:noreply, %{}}
  end

  defp apply_rules({"GR1", count}) do
    %Inventory{price_list: price_list} = %Inventory{}

    case rem(count, 2) do
      0 ->
        Money.mult!(Money.from_float(price_list["GR1"], :GBP), count / 2)

      _ ->
        Money.mult!(Money.from_float(price_list["GR1"], :GBP), ceil(count / 2))
    end
  end

  defp apply_rules({"SR1", count}) when count >= 3 do
    Money.mult!(Money.from_float(4.50, :GBP), count)
  end

  defp apply_rules({"CF1", count}) when count >= 3 do
    %Inventory{price_list: price_list} = %Inventory{}

    Money.from_float(
      price_list["CF1"],
      :GBP
    )
    |> Money.mult!(count)
    |> Money.mult!(2 / 3)
  end

  defp apply_rules({product, count}) do
    %Inventory{price_list: price_list} = %Inventory{}

    Money.mult!(Money.from_float(price_list[product], :GBP), count)
  end
end
