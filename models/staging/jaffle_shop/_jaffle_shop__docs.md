{%docs customer_id %}

The primary key of customers table, unique per customer

{% enddocs %}

{%docs order_id %}

The primary key of orders table, unique per order

{% enddocs %}

{%docs first_name %}

Customers first name

{% enddocs %}

{%docs last_name %}

Customers last name

{% enddocs %}

{%docs order_status %}

The status of the customer's order. One of the following values:
"completed", "placed", "return_pending", "returned", "shipped"

| Status | Meaning |
|:-------|:--------|
| Completed | The order has been successfully received |
| Placed | The order has been made, but not dispatched |
| Return_Pending | The Customer has indicated they will return the item, but it has not been received |
| Returned | We have received the Customer's returned item |
| Shipped | The order has been dispatched but not yet received |

{% enddocs %}