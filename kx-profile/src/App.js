// import React, { useState } from 'react';
// import './App.css';

// function App() {
//   const [userInput, setUserInput] = useState('');
//   const [aiResponse, setAiResponse] = useState('');

//   function sendMessageToBackend() {
//     // post message to backend (127.0.0.1:5000/message)
//     fetch('http://127.0.0.1:5000/message', {
//       method: 'POST',
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: JSON.stringify({ message: userInput }),
//     })
//     .then(response => response.json())
//     .then(data => {
//       console.log('AI回复:', data.reply);
//       setAiResponse(data.reply); // 更新状态以显示 AI 的回复
//     })
//     .catch((error) => {
//       console.error('Error:', error);
//     });
//   }

//   return (
//     <div className="App">
//       <header className="App-header">
//         <input 
//           type="text" 
//           value={userInput} 
//           onChange={(e) => setUserInput(e.target.value)} 
//           placeholder="输入您的消息"
//         />
//         <button onClick={sendMessageToBackend}>发送</button>
//         {aiResponse && <p style={{ color: 'white', }}>Katharine的回复: {aiResponse}</p>}
//         <p>Hello world!!</p>
//         <br />
//       </header>
//     </div>
//   );
// }

// export default App;






import React, { useState } from 'react';
import './App.css';

function App() {
  const [userInput, setUserInput] = useState('');
  const [conversation, setConversation] = useState([]);

  function sendMessageToBackend() {
    // 将用户输入添加到对话历史
    setConversation([...conversation, { role: 'user', content: userInput }]);

    // 发送请求到后端
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
      // 将 AI 回复添加到对话历史
      setConversation(prev => [...prev, { role: 'ai', content: data.reply }]);
    })
    .catch((error) => {
      console.error('Error:', error);
      // 在出错时也更新对话历史
      setConversation(prev => [...prev, { role: 'ai', content: '发生错误，请重试。' }]);
    });

    // 清空用户输入
    setUserInput('');
  }

  return (
    <div className="App">
      <header className="App-header">
        <input 
          type="text" 
          value={userInput} 
          onChange={(e) => setUserInput(e.target.value)} 
          placeholder="输入您的消息"
        />
        <button onClick={sendMessageToBackend}>发送</button>
        <div style={{ textAlign: 'left', color: 'white', marginTop: '10px' }}>
          {conversation.map((msg, index) => (
            <p key={index}>
              {msg.role === 'user' ? '您: ' : 'Katharine的回复: '}
              {msg.content}
            </p>
          ))}
        </div>
      </header>
    </div>
  );
}

export default App;
