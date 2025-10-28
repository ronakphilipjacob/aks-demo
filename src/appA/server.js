const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from public directory
app.use(express.static('public'));

// Root route
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>AppA</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                    background-color: #f0f8ff;
                }
                .container {
                    text-align: center;
                    padding: 2rem;
                    background-color: white;
                    border-radius: 10px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }
                h1 {
                    color: #333;
                    margin-bottom: 1rem;
                }
                .app-info {
                    color: #666;
                    font-size: 1.2rem;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Hi from AppA!</h1>
                <p class="app-info">Node.js Microservice</p>
                <p>Port: ${PORT}</p>
            </div>
        </body>
        </html>
    `);
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy', app: 'AppA', technology: 'Node.js' });
});

app.listen(PORT, () => {
    console.log(`AppA (Node.js) is running on port ${PORT}`);
});