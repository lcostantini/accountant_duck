Accountant Duck
================

# A brief history

# Description
Accountant duck is a simple app to register extraction and deposits.

When you go to [Accountant Duck](https://accountant-duck.herokuapp.com/) you see
a table that have three column, the first shows the registration date of the transaction,
the second shows a description and the third shows the price for the operation.

The numbers have two colors, the **red** ones are **extractions** and the **blue**
ones are **deposits**.

The total is calculated adding all deposits and subtracting all extractions.
Is why extractions have the minus sign.

To add a new operation in the app, you need to be register. You find the
[login](https://accountant-duck.herokuapp.com/login) link up in the righ corner.
After you register you will return and see the page with the table but this time with more information.

You can see in the table a new column called **Actions** that have two buttons
than let you edit and delete each operation. **_An important detail is that
transactions of the present day are the only ones that you can edit and delete._**

Other new thing that you can see is the form to add a deposit or extraction
you need to add a **description**, **price**, if is a **deposit** or **extraction**
and the **date**. By default, the date shows today date, but you can modify.

# Install
1. Clone this repo.
2. Run [Redis](http://redis.io/download).
3. And run **rackup**

# Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new pull request so we can talk about it.
