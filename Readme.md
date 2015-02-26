Accountant Duck
================

# A brief history

# Description
Accountant duck is a simple app to register and track all the monetary movements
that you perform. The app let you register deposits or extractions of money and
shows what remains of total cash after operations.

When you go to [Accountant Duck](https://accountant-duck.herokuapp.com/) you see
a table that have three column, the first shows the registration date of the
transaction, the second shows a description and the third shows the price for
the operation.

If the table has any movement recorded, you see numbers with colors, the **red**
are **extractions** and the **blue** are **deposits**. You also see the total
of the movements price. The total is calculated adding all deposits and
subtracting all extractions.

To add a new operation in the app and edit or delete, you need to be register.
You find the [login](https://accountant-duck.herokuapp.com/login) link up in the
righ corner.

After you register you see again the page with the table but this time with a
form can let you add a deposit or extraction, and a new column in the table
called Actions.
The column **Actions** have two buttons than let you edit and delete each
movement. **_An important detail is that transactions of today are the only ones
that you can edit and delete._**
In the form you need to add a **description**, **price**, if is a **deposit**
or **extraction** and the **date**. By default, the date shows today date,
but you can modify.**_You can register a movement with old date but remember
that you can't see the acction buttons for the movement_**

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
