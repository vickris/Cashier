defmodule CashierClientTest do
  use ExUnit.Case

  alias Cashier.CashierClient

  setup do
    {:ok, _pid} = CashierClient.start()
    :ok
  end

  test "view_cart/0 returns the current cart state" do
    CashierClient.add_to_cart("GR1")
    CashierClient.add_to_cart("SR1")
    assert CashierClient.view_cart() == %{"GR1" => 1, "SR1" => 1}
  end

  test "clear_cart/0 clears the cart" do
    CashierClient.add_to_cart("GR1")
    CashierClient.add_to_cart("SR1")
    CashierClient.clear_cart()

    assert CashierClient.view_cart() == %{}
  end

  describe "checkout/0" do
    test "calculates the correct total price for 2 green teas" do
      CashierClient.add_to_cart("GR1")
      CashierClient.add_to_cart("GR1")

      assert CashierClient.view_cart() == %{"GR1" => 2}
      assert CashierClient.checkout() == "£3.11"
    end

    test "calculates the total price for 3 green teas and 1 strawberry and coffee" do
      ~w(GR1 GR1 GR1 SR1 CF1) |> Enum.each(&CashierClient.add_to_cart/1)

      assert CashierClient.view_cart() == %{"GR1" => 3, "SR1" => 1, "CF1" => 1}
      assert CashierClient.checkout() == "£22.45"
    end

    test "calculates the correct total price for 3 strawberries and one green tea" do
      ~w(SR1 SR1 GR1 SR1) |> Enum.each(&CashierClient.add_to_cart/1)

      assert CashierClient.view_cart() == %{"SR1" => 3, "GR1" => 1}
      assert CashierClient.checkout() == "£16.61"
    end

    test "calculates the correct for 3 coffees 1 green tea and 1 strawberry" do
      ~w(GR1 CF1 SR1 CF1 CF1) |> Enum.each(&CashierClient.add_to_cart/1)

      assert CashierClient.view_cart() == %{"CF1" => 3, "GR1" => 1, "SR1" => 1}
      assert CashierClient.checkout() == "£30.57"
    end
  end

  test "cart is emptied when the only existing item is removed" do
    CashierClient.add_to_cart("GR1")
    CashierClient.remove_from_cart("GR1")

    assert CashierClient.view_cart() == %{}
  end

  test "empty cart remains the same when we pass a valid item code to remove_from_cart" do
    cart_before = CashierClient.view_cart()
    CashierClient.remove_from_cart("GR1")

    assert CashierClient.view_cart() == cart_before
  end

  describe "remove_from_cart/1" do
    test "raises an error when the item code is not a string" do
      assert_raise ArgumentError, fn ->
        CashierClient.remove_from_cart(1)
      end
    end

    test "raises an error when the item code is an empty string" do
      assert_raise ArgumentError, fn ->
        CashierClient.remove_from_cart("")
      end
    end

    test "raises an error when the item code is nil" do
      assert_raise ArgumentError, fn ->
        CashierClient.remove_from_cart(nil)
      end
    end

    test "raises an error when the item code is not part of inventory" do
      assert_raise ArgumentError, fn ->
        CashierClient.remove_from_cart("GR2")
      end
    end

    test "removes item from cart if valid code is supplied" do
      CashierClient.add_to_cart("GR1")
      CashierClient.add_to_cart("SR1")
      CashierClient.remove_from_cart("GR1")

      assert CashierClient.view_cart() == %{"SR1" => 1}
    end
  end

  describe "add_to_cart/1" do
    test "raises an error when the item code is not a string" do
      assert_raise ArgumentError, fn ->
        CashierClient.add_to_cart(1)
      end
    end

    test "raises an error when the item code is not part of inventory" do
      assert_raise ArgumentError, fn ->
        CashierClient.add_to_cart("GR2")
      end
    end

    test "raises an error when the item code is an empty string" do
      assert_raise ArgumentError, fn ->
        CashierClient.add_to_cart("")
      end
    end

    test "adds item to cart" do
      CashierClient.add_to_cart("GR1")
      assert CashierClient.view_cart() == %{"GR1" => 1}
    end
  end
end
