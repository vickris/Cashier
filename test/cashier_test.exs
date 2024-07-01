defmodule CashierTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = Cashier.start()
    :ok
  end

  test "add_to_cart/1 adds item to cart" do
    Cashier.add_to_cart("GR1")
    assert Cashier.view_cart() == %{"GR1" => 1}
  end

  test "view_cart/0 returns the current cart state" do
    Cashier.add_to_cart("GR1")
    Cashier.add_to_cart("SR1")
    assert Cashier.view_cart() == %{"GR1" => 1, "SR1" => 1}
  end

  test "remove_from_cart/1 removes item from cart" do
    Cashier.add_to_cart("GR1")
    Cashier.add_to_cart("SR1")
    Cashier.remove_from_cart("GR1")

    assert Cashier.view_cart() == %{"SR1" => 1}
  end

  test "clear_cart/0 clears the cart" do
    Cashier.add_to_cart("GR1")
    Cashier.add_to_cart("SR1")
    Cashier.clear_cart()

    assert Cashier.view_cart() == %{}
  end

  test "Cashier/0 calculates the correct total price for 2 green teas" do
    Cashier.add_to_cart("GR1")
    Cashier.add_to_cart("GR1")

    assert Cashier.view_cart() == %{"GR1" => 2}
    assert Cashier.checkout() == "£3.11"
  end

  test "Cashier/0 calculates the total price for 3 green teas and 1 strawberry and coffee" do
    ~w(GR1 GR1 GR1 SR1 CF1) |> Enum.each(&Cashier.add_to_cart/1)

    assert Cashier.view_cart() == %{"GR1" => 3, "SR1" => 1, "CF1" => 1}
    assert Cashier.checkout() == "£22.45"
  end

  test "Cashier/0 calculates the correct total price for 3 strawberries and one green tea" do
    ~w(SR1 SR1 GR1 SR1) |> Enum.each(&Cashier.add_to_cart/1)

    assert Cashier.view_cart() == %{"SR1" => 3, "GR1" => 1}
    assert Cashier.checkout() == "£16.61"
  end

  test "Cashier/0 calculates the correct for 3 coffees 1 green tea and 1 strawberry" do
    ~w(GR1 CF1 SR1 CF1 CF1) |> Enum.each(&Cashier.add_to_cart/1)

    assert Cashier.view_cart() == %{"CF1" => 3, "GR1" => 1, "SR1" => 1}
    assert Cashier.checkout() == "£30.57"
  end
end
