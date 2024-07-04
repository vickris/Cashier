defmodule Cashier.CashierServer do
  @moduledoc """
  Contains functions that respond to events from the client
  """

  use GenServer

  @price_list %{
    "GR1" => 3.11,
    "SR1" => 5.00,
    "CF1" => 11.23
  }

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
    total =
      Enum.reduce(state, 0, fn {product, count}, acc ->
        acc + apply_rules({product, count})
      end)
      |> Float.round(2)

    {:reply, "£#{total}", state}
  end

  @impl true
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

  @impl true
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

  @impl true
  def handle_cast(:clear_cart, _state) do
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
