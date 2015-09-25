var ReactCSSTransitionGroup = React.addons.CSSTransitionGroup;

var API = {
  request: function (method, endpoint, data) {
    return $.ajax({
      method: method,
      url: '/' + endpoint,
      data: data ? JSON.stringify(data) : null,
      contentType: "application/json"
    });
  },
  get: function(endpoint) {
    return API.request('GET', endpoint, null);
  },
  post: function(endpoint, data) {
    return API.request('POST', endpoint, data);
  },
  delete: function(endpoint, id) {
    return API.request('DELETE', endpoint + '/' + id, null);
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
      .success(function () {
        React.render(
          <AccountantDuck />,
          document.getElementById('content')
        );
      })
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
      loadingMovements: true,
      filterText: '',
      sortable: {
        field: 'Date',
        asc: true
      }
    };
  },
  componentDidMount: function() {
    API.get('movements')
      .success(function (movements) {
        this.setState({
          balance: this.calculateBalance(movements),
          movements: movements,
          loadingMovements: false
        });
      }.bind(this))
      .error(function (xhr, status, err) {
        if(xhr.status === 401) {
          React.render(
            <Login />,
            document.getElementById('content')
          );
        }
      });
  },
  handleAddMovement: function (movement) {
    var updated_movements = this.addNewMovement(movement);
    var updated_balance = this.calculateBalance(updated_movements);
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
  handleRemoveMovement: function (id) {
    API.delete('movements',id)
      .success(function(movements) {
        this.setState({
          balance: this.calculateBalance(movements),
          movements: movements
        });
      }.bind(this));
  },
  calculateBalance: function (movements) {
    balance = 0;

    if(!movements) {
      movements = this.state.movements;
    }

    movements.forEach(function (movement) {
      var amount = parseFloat(movement.price);
      if(movement.type === 'Extraction') {
        amount *= -1;
      }

      balance += amount;
      movement.balance = balance;
    });

    return balance;
  },
  sortMovements: function (field, asc, movements) {

    var field = field === 'Date' ? 'created_at' : field.toLowerCase();

    if(!movements) {
      movements = this.state.movements;
    }

    return movements.sort(function (a, b) {
      a = a[field].toLowerCase();
      b = b[field].toLowerCase();
      return asc ? a > b : a < b;
    });
  },
  addNewMovement: function (movement) {
    if(this.state.sortable.field === 'created_at' && this.state.sortable.asc) {
      var movements_by_date = this.state.movements;
    } else {
      var movements_by_date = this.sortMovements('created_at', true, this.state.movements);
    }

    var movement_index = movements_by_date.length;
    var found = false;
    movements_by_date.forEach(function (m, i) {
      if(!found && new Date(m.created_at) > new Date(movement.created_at)) {
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
                        handleSortTable={this.handleSortTable}
                        handleRemoveMovement={this.handleRemoveMovement}
                        loadingMovements={this.state.loadingMovements} />
      </div>
    );
  }
});

var AddMovement = React.createClass({
  handleSubmit: function (e) {
    e.preventDefault();
    var price = parseFloat(this.refs.price.getDOMNode().value);

    var movement = {
      created_at: this.refs.date.getDOMNode().value,
      description: this.refs.description.getDOMNode().value,
      price: Math.abs(price),
      type: price < 0 ? 'Extraction' : 'Deposit'
    };

    API.post('movements', {movement: movement})
      .success(function(id) {
        movement.id = id;
        this.props.onNewMovement(movement);

        //Reset Form
        this.refs.description.getDOMNode().value = '';
        this.refs.price.getDOMNode().value = '';
        this.refs.description.getDOMNode().focus(true);
      }.bind(this));
  },
  componentDidMount: function () {
    this.refs.date.getDOMNode().value = moment().format('YYYY-MM-DD');
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
              <input type="text" className="pure-input-1" ref="price" placeholder="0.00" required />
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
  handleRemoveMovement: function (id) {
    this.props.handleRemoveMovement(id);
  },
  render: function() {
    var balance = 0;
    var rows = [];
    for (var i = 0; i < this.props.movements.length; i++) {
      if(this.props.movements[i].description.toLowerCase().indexOf(this.props.filterText.toLowerCase()) > -1) {
        rows.push(<MovementRow odd={i%2} movement={this.props.movements[i]}
                               key={this.props.movements[i].id}
                               onRemove={this.handleRemoveMovement} />);
      }
    }

    if(!rows.length) {
      if(this.props.filterText.length) {
        var fake_movement = {description: 'No movements found with that description', description_only: true};
      } else if(this.props.loadingMovements) {
        var fake_movement = {description: 'Loading movements...', description_only: true};
      } else {
        var fake_movement = {description: 'There is no movements yet', description_only: true};
      }

      rows.push(<MovementRow movement={fake_movement} />);
    }

    return (
      <table className="pure-table">
        <thead>
          <tr>
            <MovementsHeadCell />
            <MovementsHeadCell sortingByThis={this.props.sortable.field === 'Date'}
                               asc={this.props.sortable.asc}
                               text="Date"
                               sortTable={this.handleSortTable} />
            <MovementsHeadCell sortingByThis={this.props.sortable.field === 'Description'}
                               asc={this.props.sortable.asc}
                               text="Description"
                               sortTable={this.handleSortTable} />
            <MovementsHeadCell text="Income" />
            <MovementsHeadCell text="Expense" />
            <MovementsHeadCell text="Balance" />
          </tr>
        </thead>
        <ReactCSSTransitionGroup component="tbody" transitionName="tableRow" transitionAppear={true}>
          {rows}
        </ReactCSSTransitionGroup>
      </table>
    );
  }
});

var MovementsHeadCell = React.createClass({
  handleCustomSort: function () {
    this.props.sortTable(this.props.text);
  },
  render: function () {
    if(this.props.sortTable) {
      return (
        <th id={this.props.text}><a href="#" onClick={this.handleCustomSort}>
          {this.props.text} {this.props.sortingByThis ? (this.props.asc ? '▼' : '▲') : ''}
        </a></th>
      );
    } else {
      return (
        <th id={this.props.text} >{this.props.text}</th>
      );
    }
  }
});

var MovementRow = React.createClass({
  handleDelete: function () {
    var response = confirm('Are you sure you want to remove "' + this.props.movement.description + '" ?');

    if(response) {
      this.props.onRemove(this.props.movement.id);
    }
  },
  render: function() {
    if(this.props.movement.type === 'Deposit') {
      this.props.movement.income = parseFloat(this.props.movement.price);
    } else {
      this.props.movement.expense = parseFloat(this.props.movement.price);
    }

    if(this.props.movement.description_only) {
      return (
        <tr className={this.props.odd ? 'pure-table-odd' : ''}>
          <td colSpan="6">{this.props.movement.description}</td>
        </tr>
      );
    } else {
      return (
        <tr className={this.props.odd ? 'pure-table-odd' : ''}>
          <td>
            <button title="Delete this movement"
                    className="pure-button button-error"
                    onClick={this.handleDelete}>
              X
            </button>
          </td>
          <td>{moment(this.props.movement.created_at).format('MMM D, YYYY')}</td>
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

React.render(
  <AccountantDuck />,
  document.getElementById('content')
);
