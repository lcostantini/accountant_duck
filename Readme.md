Accountant Duck
================
![alt text](https://github.com/lcostantini/accountant_duck/blob/master/public/icons/favicon-180.png)

# Description
Accountant Duck is a simple application to register and track all the monetary
movements that you perform. The app let you register deposits or expenses of
money and shows the final balance.

When you go to [Accountant Duck](https://accountant-duck.herokuapp.com/) you need
to login - don't have a signup option - and you will see a table that have five
columns, the first shows the registration date of the transaction, the second
shows a description, in the third and fourth column you will see the value for
deposit and expense of money. Finally the fifth column shows the final balance.

To add a new movement of money you need to add a description, a value for the
operation **(if is an expense you need to use a negative number)** and a date.
By default, the date shows the current date.

**_An important detail is that transactions of today are the only ones
that can be deleted._**
**_You can register a movement with old date but remember that you can't see the
acction buttons for the movement_**

# How to use?
1. Clone this repo.
2. Install [Redis](http://redis.io/download) (sudo apt-get install redis).
3. Run **bundle install** to install the gems.
4. In a console type
```
irb -r './app'
User.create name: "USERNAME", password: Digest::SHA256.hexdigest("USERPASSWORD")
```
5. Run the test **ruby test.rb**.
6. And run **rackup** to start the server.

# Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new pull request so we can talk about it.
