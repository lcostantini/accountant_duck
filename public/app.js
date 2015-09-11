var baseUrl = 'http://localhost:9292/';

var Login = React.createClass({displayName: "Login",
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
      React.createElement("form", {onSubmit: this.logUser}, 
        React.createElement("input", {type: "text", ref: "user", placeholder: "username"}), 
        React.createElement("input", {type: "password", ref: "password", placeholder: "password"}), 
        React.createElement("input", {type: "submit", value: "Sign in"})
      )
    );
  }
});

function init () {
  debugger;
  $.ajax(baseUrl + 'movements')
    .success(function(data) {
      React.render(
        React.createElement(FilterableProductTable, {products: PRODUCTS}),
        document.getElementById('content')
      );
    })
    .error(function () {
      React.render(
        React.createElement(Login, null),
        document.getElementById('content')
      );
    });
}

init();