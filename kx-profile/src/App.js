import React, { useState } from 'react';
import logo from './logo.svg';
import './App.css';

function App() {
  const [userInput, setUserInput] = useState('');
  const [aiResponse, setAiResponse] = useState('');

  function sendMessageToBackend() {
    // post message to backend (127.0.0.1:5000/message)
    fetch('http://127.0.0.1:5000/message', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message: userInput }),
    })
    .then(response => response.json())
    .then(data => {
      console.log('AI回复:', data.reply);
      setAiResponse(data.reply); // 更新状态以显示 AI 的回复
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  }

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <input 
          type="text" 
          value={userInput} 
          onChange={(e) => setUserInput(e.target.value)} 
          placeholder="输入您的消息"
        />
        <button onClick={sendMessageToBackend}>发送</button>
        {aiResponse && <p style={{ color: 'white', }}>AI回复: {aiResponse}</p>}
        <p>Hello world!!</p>
        <br />
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;




// function App() {
//   return (
//     <div className="App">
//       <header className="App-header">
//         <img src={logo} className="App-logo" alt="logo" />
//         <p>
//           Edit <code>src/App.js</code> and save to reload.
//         </p>
//         <a
//           className="App-link"
//           href="https://reactjs.org"
//           target="_blank"
//           rel="noopener noreferrer"
//         >
//           Learn React
//         </a>
//       </header>
//     </div>
//   );
// }

// export default App;
