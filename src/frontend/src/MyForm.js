import React from 'react';
import axios from 'axios';

export default class MyForm extends React.Component {
  constructor(props) {
    super(props);
    this.state={
      label: '',
      text: ''
    };
  }

  onData= (value) => {
    console.log("onData " + value);
    this.setState({
      label: value,
      cancel: null
    })
  }
  inputChange = (event) => {
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;
    if(this.state.cancel) {
      this.state.cancel.cancel("Operation cancelled by user");
    }

    const CancelToken = axios.CancelToken;
    const source = CancelToken.source();
    const onData=this.onData;

    axios.post(this.props.url, {
      request: value
    },{
      cancelToken: source.token
    })
    .then(function (response) {
      console.log(response);
      onData(response.data.response);
    })
    .catch(function (error) {
      console.log(error);
    });

    this.setState({
      [name]: value,
      label: '...',
      cancel: source
    });
  }

  render() {
    return (
      <div>
      <form>
        <label>
          <input
            name="text"
            type="text"
            placeholder="enter something"
            onChange={this.inputChange} />
            <br/>
          {this.state.label}
        </label>
      </form>
      </div>
    );
  }
}
