defmodule CashierClientTest do
  use ExUnit.Case

  alias Cashier.CashierClient

  setup do
    {:ok, _pid} = CashierClient.start()
    :ok
  end

  test "add_to_cart/1 adds item to cart" do
    CashierClient.add_to_cart("GR1")
    assert CashierClient.view_cart() == %{"GR1" => 1}
  end

  test "view_cart/0 returns the current cart state" do
    CashierClient.add_to_cart("GR1")
    CashierClient.add_to_cart("SR1")
    assert CashierClient.view_cart() == %{"GR1" => 1, "SR1" => 1}
  end

  test "remove_from_cart/1 removes item from cart" do
    CashierClient.add_to_cart("GR1")
    CashierClient.add_to_cart("SR1")
    CashierClient.remove_from_cart("GR1")

    assert CashierClient.view_cart() == %{"SR1" => 1}
  end

  test "clear_cart/0 clears the cart" do
    CashierClient.add_to_cart("GR1")
    CashierClient.add_to_cart("SR1")
    CashierClient.clear_cart()

    assert CashierClient.view_cart() == %{}
  end

  test "checkout/0 calculates the correct total price for 2 green teas" do
    CashierClient.add_to_cart("GR1")
    CashierClient.add_to_cart("GR1")

    assert CashierClient.view_cart() == %{"GR1" => 2}
    assert CashierClient.checkout() == "£3.11"
  end

  test "checkout/0 calculates the total price for 3 green teas and 1 strawberry and coffee" do
    ~w(GR1 GR1 GR1 SR1 CF1) |> Enum.each(&CashierClient.add_to_cart/1)

    assert CashierClient.view_cart() == %{"GR1" => 3, "SR1" => 1, "CF1" => 1}
    assert CashierClient.checkout() == "£22.45"
  end

  test "checkout/0 calculates the correct total price for 3 strawberries and one green tea" do
    ~w(SR1 SR1 GR1 SR1) |> Enum.each(&CashierClient.add_to_cart/1)

    assert CashierClient.view_cart() == %{"SR1" => 3, "GR1" => 1}
    assert CashierClient.checkout() == "£16.61"
  end

  test "checkout/0 calculates the correct for 3 coffees 1 green tea and 1 strawberry" do
    ~w(GR1 CF1 SR1 CF1 CF1) |> Enum.each(&CashierClient.add_to_cart/1)

    assert CashierClient.view_cart() == %{"CF1" => 3, "GR1" => 1, "SR1" => 1}
    assert CashierClient.checkout() == "£30.57"
  end
end
