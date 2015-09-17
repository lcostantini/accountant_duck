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
      balance: 0,
      movements: [],
      filterText: '',
      sortable: {
        field: 'Date',
        asc: true
      }
    };
  },
  componentDidMount: function() {
    //TODO
    //API.get('movements');
    //TEMP
    var movements = [
      {
        id: 1,
        date: '2015-09-11',
        description: 'Manu brings money',
        amount: 100
      },
      {
        id: 2,
        date: '2015-09-11',
        description: 'Beer',
        amount: -35
      },
      {
        id: 3,
        date: '2015-09-12',
        description: 'Pizza',
        amount: -50
      },
      {
        id: 4,
        date: '2015-09-14',
        description: 'Ice Cream',
        amount: -10
      },
    ];

    this.setState({
      balance: this.calculateBalance(movements),
      movements: movements
    });
  },
  handleAddMovement: function (movement) {
    var updated_movements = this.addNewMovement(movement);
    debugger;
    var updated_balance = this.calculateBalance(updated_movements);
    debugger;
    var sorted_movements = this.sortMovements(this.state.sortable.field, this.state.sortable.asc, updated_movements);

    this.setState({
      balance: updated_balance,
      movements: sorted_movements
    });
  },
  handleFilterMovements: function (filterText) {
    this.setState({
      filterText: filterText
    });
  },
  handleSortTable: function (field) {
    var asc = this.state.sortable.field === field ? !this.state.sortable.asc : true;

    var movements = this.sortMovements(field, asc);

    this.setState({
      sortable: {
        field: field,
        asc: asc
      },
      movements: movements
    });
  },
  calculateBalance: function (movements) {
    balance = 0;

    if(!movements) {
      movements = this.state.movements;
    }

    movements.forEach(function (movement) {
      balance += movement.amount;
      movement.balance = balance;
    });

    return balance;
  },
  sortMovements: function (field, asc, movements) {
    if(!movements) {
      movements = this.state.movements;
    }

    return movements.sort(function (a, b) {
      var f = field.toLowerCase();
      return asc ? a[f].toLowerCase() > b[f].toLowerCase() : a[f].toLowerCase() < b[f].toLowerCase();
    });
  },
  addNewMovement: function (movement) {
    if(this.state.sortable.field === 'Date' && this.state.sortable.asc) {
      var movements_by_date = this.state.movements;
    } else {
      var movements_by_date = this.sortMovements('Date', true, this.state.movements);
    }

    var movement_index = movements_by_date.length;
    var found = false;
    movements_by_date.forEach(function (m, i) {
      if(!found && new Date(m.date) > new Date(movement.date)) {
        movement_index = i
        found = true;
      }
    });

    movements_by_date.splice(movement_index, 0, movement);

    return movements_by_date;

  },
  render: function () {
    return (
      <div>
        <AddMovement onNewMovement={this.handleAddMovement} />
        <MovementsFilter filterText={this.state.filterText} onUserInput={this.handleFilterMovements} />
        <MovementsTable sortable={this.state.sortable}
                        filterText={this.state.filterText}
                        movements={this.state.movements}
                        handleSortTable={this.handleSortTable} />
      </div>
    );
  }
});

var AddMovement = React.createClass({
  handleSubmit: function (e) {
    e.preventDefault();

    var movement = {
      date: this.refs.date.getDOMNode().value,
      description: this.refs.description.getDOMNode().value,
      amount: parseInt(this.refs.amount.getDOMNode().value)
    };
    //TODO
    //API.post('movements', movement);

    this.props.onNewMovement(movement);

    //Reset Form
    this.refs.description.getDOMNode().value = '';
    this.refs.amount.getDOMNode().value = '';
    this.refs.date.getDOMNode().value = '';
    this.refs.description.getDOMNode().focus(true);
  },
  render: function () {
    return (
      <form className="pure-form pure-g" onSubmit={this.handleSubmit}>
        <div className="pure-u-1">
          <fieldset>
            <legend>Add a movement (use negative numbers to add expenses)</legend>
            <div className="pure-u-1-2">
              <input type="text" className="pure-input-1" ref="description" placeholder="Description" required />
            </div>
            <div className="pure-u-1-6">
              <input type="text" className="pure-input-1" ref="amount" placeholder="0.00" required />
            </div>
            <div className="pure-u-1-3">
              <input type="date" className="pure-input-1" ref="date" required />
            </div>
          </fieldset>
        </div>
        <input type="submit" className="hidden" />
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
  handleSortTable: function (field) {
    this.props.handleSortTable(field);
  },
  render: function() {
    var balance = 0;
    var rows = [];
    for (var i = 0; i < this.props.movements.length; i++) {
      if(this.props.movements[i].description.toLowerCase().indexOf(this.props.filterText.toLowerCase()) > -1) {
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
            <MovementsHeadCell sortingByThis={this.props.sortable.field === 'Date'}
                               asc={this.props.sortable.asc}
                               text="Date"
                               sortTable={this.handleSortTable} />
            <MovementsHeadCell sortingByThis={this.props.sortable.field === 'Description'}
                               asc={this.props.sortable.asc}
                               text="Description"
                               sortTable={this.handleSortTable} />
            <MovementsHeadCell sortingByThis={this.props.sortable.field === 'Income'}
                               asc={this.props.sortable.asc}
                               text="Income"
                               sortTable={this.handleSortTable} />
            <MovementsHeadCell sortingByThis={this.props.sortable.field === 'Expense'}
                               asc={this.props.sortable.asc}
                               text="Expense"
                               sortTable={this.handleSortTable} />
            <MovementsHeadCell sortingByThis={this.props.sortable.field === 'Balance'}
                               asc={this.props.sortable.asc}
                               text="Balance"
                               sortTable={this.handleSortTable} />
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
});

var MovementsHeadCell = React.createClass({
  handleCustomSort: function () {
    this.props.sortTable(this.props.text);
  },
  render: function () {
    return (
      <th><a href="#" id={this.props.text} onClick={this.handleCustomSort}>
        {this.props.text} {this.props.sortingByThis ? (this.props.asc ? '▼' : '▲') : ''}
      </a></th>
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
          <td>{moment(this.props.movement.date).format('MMM D, YYYY')}</td>
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