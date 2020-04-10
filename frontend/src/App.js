import React from 'react';
import logo from './logo.svg';
import './App.css';
import MyForm from './MyForm';

function App() {
  return (
    <div className="App">
      <MyForm url={process.env.REACT_APP_URL}/>
    </div>
  );
}

export default App;
