var baseUrl = 'http://localhost:9292/';

var Login = React.createClass({
  logUser: function (e) {
    e.preventDefault();
    var data = {
      user: {
        name: this.refs.user.getDOMNode().value,
        password: this.refs.password.getDOMNode().value
      }
    };

    $.ajax({
      url: baseUrl + 'login',
      method: 'POST',
      data: JSON.stringify(data),
      contentType: "application/json",
      cache: false,
      success: init,
      error: function(xhr, status, err) {
        console.error(status, err.toString());
      }
    });
  },
  render: function () {
    return (
      <form onSubmit={this.logUser}>
        <input type="text" ref="user" placeholder="username" />
        <input type="password" ref="password" placeholder="password" />
        <input type="submit" value="Sign in" />
      </form>
    );
  }
});

function init () {
  debugger;
  $.ajax(baseUrl + 'movements')
    .success(function(data) {
      React.render(
        <FilterableProductTable products={PRODUCTS} />,
        document.getElementById('content')
      );
    })
    .error(function () {
      React.render(
        <Login />,
        document.getElementById('content')
      );
    });
}

init();