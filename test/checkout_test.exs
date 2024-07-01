defmodule CheckoutTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = Checkout.start()
    :ok
  end

  test "add_to_cart/1 adds item to cart" do
    Checkout.add_to_cart("GR1")
    assert Checkout.view_cart() == %{"GR1" => 1}
  end

  test "view_cart/0 returns the current cart state" do
    Checkout.add_to_cart("GR1")
    Checkout.add_to_cart("SR1")
    assert Checkout.view_cart() == %{"GR1" => 1, "SR1" => 1}
  end

  test "remove_from_cart/1 removes item from cart" do
    Checkout.add_to_cart("GR1")
    Checkout.add_to_cart("SR1")
    Checkout.remove_from_cart("GR1")

    assert Checkout.view_cart() == %{"SR1" => 1}
  end

  test "clear_cart/0 clears the cart" do
    Checkout.add_to_cart("GR1")
    Checkout.add_to_cart("SR1")
    Checkout.clear_cart()

    assert Checkout.view_cart() == %{}
  end

  test "checkout/0 calculates the correct total price for 2 green teas" do
    Checkout.add_to_cart("GR1")
    Checkout.add_to_cart("GR1")

    assert Checkout.view_cart() == %{"GR1" => 2}
    assert Checkout.checkout() == "£3.11"
  end

  test "checkout/0 calculates the total price for 3 green teas and 1 strawberry and coffee" do
    ~w(GR1 GR1 GR1 SR1 CF1) |> Enum.each(&Checkout.add_to_cart/1)

    assert Checkout.view_cart() == %{"GR1" => 3, "SR1" => 1, "CF1" => 1}
    assert Checkout.checkout() == "£22.45"
  end

  test "checkout/0 calculates the correct total price for 3 strawberries and one green tea" do
    ~w(SR1 SR1 GR1 SR1) |> Enum.each(&Checkout.add_to_cart/1)

    assert Checkout.view_cart() == %{"SR1" => 3, "GR1" => 1}
    assert Checkout.checkout() == "£16.61"
  end

  test "checkout/0 calculates the correct for 3 coffees 1 green tea and 1 strawberry" do
    ~w(GR1 CF1 SR1 CF1 CF1) |> Enum.each(&Checkout.add_to_cart/1)

    assert Checkout.view_cart() == %{"CF1" => 3, "GR1" => 1, "SR1" => 1}
    assert Checkout.checkout() == "£30.57"
  end
end
