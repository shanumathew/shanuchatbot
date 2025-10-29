import React, { useState, useRef, useEffect } from 'react';
import { GoogleGenerativeAI } from '@google/generative-ai';
import './Chatbot.css';

interface Message {
  id: string;
  text: string;
  sender: 'user' | 'bot';
  timestamp: Date;
}

const Chatbot: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: 'Hello! I\'m your AI chatbot. How can I help you today?',
      sender: 'bot',
      timestamp: new Date(),
    },
  ]);
  const [inputValue, setInputValue] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const genAI = useRef<GoogleGenerativeAI | null>(null);

  // Initialize Google Generative AI
  useEffect(() => {
    const apiKey = 'AIzaSyB53p7H1z3_PY8-7yq8I1cbAE_eU-XLW94';
    genAI.current = new GoogleGenerativeAI(apiKey);
  }, []);

  // Scroll to bottom when messages change
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!inputValue.trim()) return;

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      text: inputValue,
      sender: 'user',
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInputValue('');
    setIsLoading(true);

    try {
      // Get response from Google Generative AI
      if (genAI.current) {
        const model = genAI.current.getGenerativeModel({ model: 'gemini-2.0-flash' });
        const result = await model.generateContent(inputValue);
        const response = await result.response;
        const botMessage: Message = {
          id: (Date.now() + 1).toString(),
          text: response.text(),
          sender: 'bot',
          timestamp: new Date(),
        };
        setMessages((prev) => [...prev, botMessage]);
      }
    } catch (error) {
      console.error('Error:', error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        text: 'Sorry, I encountered an error. Please try again.',
        sender: 'bot',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="chatbot-container">
      <div className="chatbot-header">
        <h1>AI Chatbot</h1>
        <p>Powered by Google Gemini</p>
      </div>

      <div className="messages-container">
        {messages.map((message) => (
          <div key={message.id} className={`message message-${message.sender}`}>
            <div className="message-content">
              <p>{message.text}</p>
              <span className="message-time">
                {message.timestamp.toLocaleTimeString([], {
                  hour: '2-digit',
                  minute: '2-digit',
                })}
              </span>
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="message message-bot">
            <div className="message-content">
              <div className="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={sendMessage} className="input-form">
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          placeholder="Type your message..."
          disabled={isLoading}
          className="message-input"
        />
        <button type="submit" disabled={isLoading} className="send-button">
          {isLoading ? 'Sending...' : 'Send'}
        </button>
      </form>
    </div>
  );
};

export default Chatbot;
