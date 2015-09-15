var API = {
  request: function (method, endpoint, data) {
    return $.ajax({
      method: method,
      url: 'http://localhost:9292/' + endpoint,
      data: data ? JSON.stringify(data) : null,
      contentType: "application/json",
      cache: false,
      success: init
    });
  },
  get: function(endpoint) {
    return API.request('GET', endpoint, null);
  },
  post: function(endpoint, data) {
    return API.request('POST', endpoint, data);
  }
}

var Login = React.createClass({
  logUser: function (e) {
    e.preventDefault();

    API.post('login', {
      user: {
        name: this.refs.user.getDOMNode().value,
        password: this.refs.password.getDOMNode().value
      }
    })
      .success(init)
      .error(function(xhr, status, err) {
        console.error(xhr.status, status, err.toString());
      });
  },
  render: function () {
    return (
      <form className="pure-form" onSubmit={this.logUser}>
        <fieldset>
          <legend>You need to log in to see the movements</legend>

          <input type="text" ref="user" placeholder="username" />
          <input type="password" ref="password" placeholder="password" />
          <button type="submit" className="pure-button pure-button-primary">Sign in</button>
        </fieldset>
      </form>
    );
  }
});

var AccountantDuck = React.createClass({
  getInitialState: function() {
    return {
      movements: [
        {
          id: 1,
          date: 'Sep 11',
          description: 'Manu brings money',
          amount: 100
        },
        {
          id: 2,
          date: 'Sep 11',
          description: 'Beer',
          amount: -35
        },
        {
          id: 3,
          date: 'Sep 12',
          description: 'Pizza',
          amount: -50
        },
        {
          id: 4,
          date: 'Sep 14',
          description: 'Ice Cream',
          amount: -10
        },
      ],
      filterText: ''
    };
  },
  handleAddMovement: function (movement) {
    this.setState({
      movements: this.state.movements.concat(movement)
    });
  },
  handleFilterMovements: function (filterText) {
    this.setState({
      filterText: filterText
    });
  },
  render: function () {
    return (
      <div>
        <AddMovement onNewMovement={this.handleAddMovement} />
        <MovementsFilter filterText={this.state.filterText} onUserInput={this.handleFilterMovements} />
        <MovementsTable filterText={this.state.filterText} movements={this.state.movements} />
      </div>
    );
  }
});

var AddMovement = React.createClass({
  handleSubmit: function (e) {
    e.preventDefault();

    var movement = {
      date: 'Sep 14', //TEMP
      description: this.refs.description.getDOMNode().value,
      amount: parseInt(this.refs.amount.getDOMNode().value)
    };

    //TODO
    //API.post('movements', movement);

    this.props.onNewMovement(movement);
  },
  render: function () {
    return (
      <form className="pure-form pure-g" onSubmit={this.handleSubmit}>
        <div className="pure-u-1">
          <fieldset>
            <legend>Add a movement (use negative numbers to add expenses)</legend>
            <div className="pure-u-1-2">
              <input type="text" className="pure-input-1" ref="description" placeholder="Description" />
            </div>
            <div className="pure-u-1-6">
              <input type="text" className="pure-input-1" ref="amount" placeholder="0.00" />
            </div>
            <div className="pure-u-1-6">
              <input type="text" className="pure-input-1" ref="date" placeholder="mm/dd/yyyy" />
            </div>
            <div className="pure-u-1-6">
              <button type="submit" className="pure-button pure-button-primary right">Save</button>
            </div>
          </fieldset>
        </div>
      </form>
    );
  }
});

var MovementsFilter = React.createClass({
  handleUserInput: function () {
    this.props.onUserInput(this.refs.filterText.getDOMNode().value);
  },
  render: function () {
    return (
      <form className="search-form pure-form pure-g">
        <div className="pure-u-1">
          <input type="text"
                 className="pure-input-1"
                 ref="filterText"
                 onChange={this.handleUserInput}
                 value={this.props.filterText}
                 placeholder="Search by description..." />
        </div>
      </form>
    );
  }
})

var MovementsTable = React.createClass({
  render: function() {
    var balance = 0;
    var rows = [];
    for (var i = 0; i < this.props.movements.length; i++) {
      balance += this.props.movements[i].amount;

      if(this.props.movements[i].description.indexOf(this.props.filterText) > -1) {
        this.props.movements[i].balance = balance;

        rows.push(<MovementRow odd={i%2} movement={this.props.movements[i]} key={this.props.movements[i].id} />);
      }
    }

    if(!rows.length) {
      if(this.props.filterText.length) {
        var fake_movement = {description: 'No movements found with that description', description_only: true};
      } else {
        var fake_movement = {description: 'There is no movements yet', description_only: true};
      }
      rows.push(<MovementRow movement={fake_movement} />);
    }

    return (
      <table className="pure-table">
        <thead>
          <tr>
            <th>Date</th>
            <th>Description</th>
            <th>Income</th>
            <th>Expense</th>
            <th>Balance</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
});

var MovementRow = React.createClass({
  render: function() {
    if(this.props.movement.amount > 0) {
      this.props.movement.income = this.props.movement.amount;
    } else {
      this.props.movement.expense = this.props.movement.amount;
    }

    if(this.props.movement.description_only) {
      return (
        <tr className={this.props.odd ? 'pure-table-odd' : ''}>
          <td colSpan="5">{this.props.movement.description}</td>
        </tr>
      );
    } else {
      return (
        <tr className={this.props.odd ? 'pure-table-odd' : ''}>
          <td>{this.props.movement.date}</td>
          <td>{this.props.movement.description}</td>
          <td>{this.props.movement.income}</td>
          <td>{this.props.movement.expense}</td>
          <td className={this.props.movement.balance < 0 ? 'negative':''}>
            {this.props.movement.balance}
          </td>
        </tr>
      );
    }
  }
});

function init () {
  API.get('movements')
    .success(showMovementsTableView)
    .error(function (xhr, status, err) {
      /*
      TEMP
      if(xhr.status === 401) {
        showLoginView();
      } else {
      */
        showMovementsTableView([]);
      //}
    });
}

function showLoginView () {
  React.render(
    <Login />,
    document.getElementById('content')
  );
}

function showMovementsTableView (data) {
  React.render(
    <AccountantDuck />,
    document.getElementById('content')
  );
}

init();