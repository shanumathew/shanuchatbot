# React Chatbot with Google Gemini AI

A modern, responsive React chatbot powered by Google's Generative AI (Gemini) API.

## Features

✨ **Modern UI** - Beautiful gradient design with smooth animations
💬 **Real-time Chat** - Instant responses from Google Gemini AI
📱 **Responsive Design** - Works seamlessly on desktop and mobile
⚡ **Fast & Lightweight** - Built with Vite and React for optimal performance
🎨 **Typing Indicator** - Visual feedback while waiting for responses

## Tech Stack

- **React 18** - UI library
- **TypeScript** - Type-safe development
- **Vite** - Next-generation frontend tooling
- **Google Generative AI** - AI model integration
- **CSS3** - Modern styling with gradients and animations

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

1. The project dependencies are already installed. If needed, install them:

```bash
npm install
```

2. The Google Generative AI API key is already configured in the `Chatbot.tsx` file.

### Development

Start the development server:

```bash
npm run dev
```

The chatbot will be available at `http://localhost:5173`

### Build

Build the project for production:

```bash
npm run build
```

The optimized build will be in the `dist` folder.

### Preview

Preview the production build:

```bash
npm run preview
```

## Project Structure

```
src/
├── Chatbot.tsx        # Main chatbot component with AI integration
├── Chatbot.css        # Chatbot styling
├── App.tsx            # App wrapper component
├── App.css            # App styling
├── main.tsx           # Application entry point
└── index.css          # Global styles
```

## API Configuration

The chatbot uses Google's Generative AI API. The API key is configured in `src/Chatbot.tsx`:

```typescript
const apiKey = 'AIzaSyB53p7H1z3_PY8-7yq8I1cbAE_eU-XLW94';
```

### Note on API Key Security

⚠️ **Important**: For production deployments, store sensitive API keys in environment variables, not in source code:

```typescript
const apiKey = import.meta.env.VITE_GOOGLE_API_KEY;
```

Then create a `.env.local` file:

```
VITE_GOOGLE_API_KEY=your_api_key_here
```

## Usage

1. Open the application in your browser
2. Type your message in the input field at the bottom
3. Press "Send" or hit Enter to submit
4. Wait for the AI to respond
5. Continue the conversation as needed

## Features Details

### Message Rendering
- User messages appear on the right side with purple gradient background
- Bot messages appear on the left side with white background
- Each message displays a timestamp
- Smooth slide-in animation for all messages

### Typing Indicator
- Shows animated dots while waiting for AI response
- Automatically disappears when response arrives
- Provides visual feedback to the user

### Responsive Design
- Adapts to different screen sizes
- Full-height viewport on desktop
- Optimized layout for mobile devices

## Customization

### Change AI Model

In `src/Chatbot.tsx`, modify the model name:

```typescript
const model = genAI.current.getGenerativeModel({ model: 'gemini-pro' });
```

Available models:
- `gemini-pro` - Standard model
- `gemini-pro-vision` - For vision tasks (requires image input)

### Customize Colors

Edit `src/Chatbot.css` and change the gradient colors:

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Adjust Chat Window

Modify the container width in `src/Chatbot.css`:

```css
max-width: 900px; /* Adjust as needed */
```

## Troubleshooting

### API Errors

If you see "Sorry, I encountered an error" messages:

1. Verify the API key is correct
2. Check your internet connection
3. Ensure the Google Generative AI API is enabled
4. Check browser console for detailed error messages

### Messages Not Showing

1. Check if the Chatbot component is properly imported in `App.tsx`
2. Verify TypeScript compilation has no errors
3. Clear browser cache and reload

### Build Issues

1. Delete `node_modules` and `package-lock.json`
2. Run `npm install` again
3. Try `npm run build` again

## License

MIT

## Support

For issues and questions, please check the project repository or contact support.
