const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Basic routes for WAAS testing
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WAAS Test Application</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
                .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
                .endpoint { background: #f8f9fa; padding: 15px; margin: 10px 0; border-left: 4px solid #007bff; }
                .method { font-weight: bold; color: #28a745; }
                .url { font-family: monospace; background: #e9ecef; padding: 2px 6px; border-radius: 3px; }
                .description { color: #666; margin-top: 5px; }
                button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 5px; }
                button:hover { background: #0056b3; }
                .test-section { margin: 20px 0; padding: 20px; background: #f8f9fa; border-radius: 5px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🛡️ WAAS Test Application</h1>
                <p>This application is designed to test WAAS (Web Application and API Security) In-Line protection.</p>
                
                <div class="test-section">
                    <h2>Available Endpoints</h2>
                    
                    <div class="endpoint">
                        <span class="method">GET</span> <span class="url">/api/users</span>
                        <div class="description">Returns a list of users (safe endpoint)</div>
                    </div>
                    
                    <div class="endpoint">
                        <span class="method">GET</span> <span class="url">/api/users/:id</span>
                        <div class="description">Returns user by ID (potential SQL injection test)</div>
                    </div>
                    
                    <div class="endpoint">
                        <span class="method">POST</span> <span class="url">/api/login</span>
                        <div class="description">Login endpoint (potential brute force test)</div>
                    </div>
                    
                    <div class="endpoint">
                        <span class="method">GET</span> <span class="url">/api/admin</span>
                        <div class="description">Admin endpoint (potential unauthorized access test)</div>
                    </div>
                    
                    <div class="endpoint">
                        <span class="method">GET</span> <span class="url">/api/search</span>
                        <div class="description">Search endpoint (potential XSS test)</div>
                    </div>
                </div>
                
                <div class="test-section">
                    <h2>Test Actions</h2>
                    <button onclick="testSafeEndpoint()">Test Safe Endpoint</button>
                    <button onclick="testSQLInjection()">Test SQL Injection</button>
                    <button onclick="testXSS()">Test XSS</button>
                    <button onclick="testUnauthorizedAccess()">Test Unauthorized Access</button>
                    <button onclick="testBruteForce()">Test Brute Force</button>
                </div>
                
                <div id="results" style="margin-top: 20px;"></div>
            </div>
            
            <script>
                async function testSafeEndpoint() {
                    try {
                        const response = await fetch('/api/users');
                        const data = await response.json();
                        showResult('Safe Endpoint Test', 'SUCCESS', data);
                    } catch (error) {
                        showResult('Safe Endpoint Test', 'ERROR', error.message);
                    }
                }
                
                async function testSQLInjection() {
                    try {
                        const response = await fetch('/api/users/1\' OR \'1\'=\'1');
                        const data = await response.json();
                        showResult('SQL Injection Test', 'RESPONSE', data);
                    } catch (error) {
                        showResult('SQL Injection Test', 'ERROR', error.message);
                    }
                }
                
                async function testXSS() {
                    try {
                        const response = await fetch('/api/search?q=<script>alert("XSS")</script>');
                        const data = await response.json();
                        showResult('XSS Test', 'RESPONSE', data);
                    } catch (error) {
                        showResult('XSS Test', 'ERROR', error.message);
                    }
                }
                
                async function testUnauthorizedAccess() {
                    try {
                        const response = await fetch('/api/admin');
                        const data = await response.json();
                        showResult('Unauthorized Access Test', 'RESPONSE', data);
                    } catch (error) {
                        showResult('Unauthorized Access Test', 'ERROR', error.message);
                    }
                }
                
                async function testBruteForce() {
                    try {
                        const response = await fetch('/api/login', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ username: 'admin', password: 'wrongpassword' })
                        });
                        const data = await response.json();
                        showResult('Brute Force Test', 'RESPONSE', data);
                    } catch (error) {
                        showResult('Brute Force Test', 'ERROR', error.message);
                    }
                }
                
                function showResult(test, status, data) {
                    const results = document.getElementById('results');
                    const resultDiv = document.createElement('div');
                    resultDiv.style.cssText = 'margin: 10px 0; padding: 15px; border-radius: 5px; background: ' + 
                        (status === 'SUCCESS' ? '#d4edda' : status === 'ERROR' ? '#f8d7da' : '#fff3cd') + ';';
                    resultDiv.innerHTML = '<strong>' + test + '</strong> - ' + status + '<br><pre>' + JSON.stringify(data, null, 2) + '</pre>';
                    results.appendChild(resultDiv);
                }
            </script>
        </body>
        </html>
    `);
});

// API Routes for WAAS testing
app.get('/api/users', (req, res) => {
    const users = [
        { id: 1, name: 'John Doe', email: 'john@example.com', role: 'user' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'user' },
        { id: 3, name: 'Admin User', email: 'admin@example.com', role: 'admin' }
    ];
    res.json({ success: true, users, message: 'Users retrieved successfully' });
});

app.get('/api/users/:id', (req, res) => {
    const { id } = req.params;
    // Simulate potential SQL injection vulnerability
    if (id.includes("'") || id.includes('"') || id.includes('OR') || id.includes('UNION')) {
        res.status(400).json({ 
            success: false, 
            error: 'Invalid user ID format',
            message: 'Potential SQL injection attempt detected'
        });
    } else {
        const user = { id: parseInt(id), name: 'User ' + id, email: `user${id}@example.com`, role: 'user' };
        res.json({ success: true, user });
    }
});

app.post('/api/login', (req, res) => {
    const { username, password } = req.body;
    
    // Simulate login attempt
    if (username === 'admin' && password === 'admin123') {
        res.json({ success: true, message: 'Login successful', token: 'fake-jwt-token' });
    } else {
        res.status(401).json({ 
            success: false, 
            error: 'Invalid credentials',
            message: 'Login failed - invalid username or password'
        });
    }
});

app.get('/api/admin', (req, res) => {
    // Simulate admin endpoint without proper authentication
    res.json({ 
        success: true, 
        message: 'Admin access granted',
        adminData: { users: 100, servers: 5, alerts: 2 }
    });
});

app.get('/api/search', (req, res) => {
    const { q } = req.query;
    
    // Simulate search with potential XSS vulnerability
    if (q && q.includes('<script>')) {
        res.status(400).json({ 
            success: false, 
            error: 'Invalid search query',
            message: 'Potential XSS attempt detected'
        });
    } else {
        res.json({ 
            success: true, 
            query: q,
            results: [
                { title: 'Result 1', description: 'Description for result 1' },
                { title: 'Result 2', description: 'Description for result 2' }
            ]
        });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        version: '1.0.0'
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ 
        success: false, 
        error: 'Internal server error',
        message: 'Something went wrong!'
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ 
        success: false, 
        error: 'Not found',
        message: 'The requested resource was not found'
    });
});

app.listen(PORT, () => {
    console.log(`🛡️ WAAS Test Application running on port ${PORT}`);
    console.log(`📱 Access the application at: http://localhost:${PORT}`);
    console.log(`🔍 Health check available at: http://localhost:${PORT}/health`);
    console.log(`\n📋 Available endpoints:`);
    console.log(`   GET  /api/users - List all users`);
    console.log(`   GET  /api/users/:id - Get user by ID`);
    console.log(`   POST /api/login - Login endpoint`);
    console.log(`   GET  /api/admin - Admin endpoint`);
    console.log(`   GET  /api/search - Search endpoint`);
    console.log(`   GET  /health - Health check`);
});
