## VERSIONS 
Elixir 1.14.5
Erlang/OTP 26 

## USAGE
Start Shopping
```
Cashier.start()
```

Add items to Cart
```
Cashier.add_to_cart("GR1")
Cashier.add_to_cart("SR1")
```

Checkout
```
Cashier.checkout()
```

**------ NOT PART OF INITIAL SCOPE BUT WOULD BE HANDY -------**
View Cart
```
Cashier.view_cart()
```

Remove From Cart
```
Cashier.remove_from_cart("GR1")
```

Clear Cart
```
Cashier.clear_cart()
```

**Other things to Note:** **Agent** would have solved the task as well.