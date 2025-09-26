# WAAS Test Application

A simple web application designed to test WAAS (Web Application and API Security) In-Line protection in Prisma Cloud.

## Features

- **Express.js Web Server**: Lightweight Node.js application
- **Security Middleware**: Uses Helmet for basic security headers
- **Test Endpoints**: Multiple endpoints designed to test various security scenarios
- **Docker Support**: Containerized for easy deployment
- **Health Checks**: Built-in health monitoring

## Quick Start

### Option 1: Using Docker Compose (Recommended)

```bash
# Navigate to the web-app directory
cd web-app

# Build and start the application
docker-compose up --build

# The application will be available at http://localhost:3000
```

### Option 2: Using Node.js directly

```bash
# Navigate to the web-app directory
cd web-app

# Install dependencies
npm install

# Start the application
npm start

# The application will be available at http://localhost:3000
```

## Available Endpoints

### Main Application
- `GET /` - Main application interface with test buttons

### API Endpoints
- `GET /api/users` - Returns list of users (safe endpoint)
- `GET /api/users/:id` - Returns user by ID (SQL injection test)
- `POST /api/login` - Login endpoint (brute force test)
- `GET /api/admin` - Admin endpoint (unauthorized access test)
- `GET /api/search?q=query` - Search endpoint (XSS test)

### System Endpoints
- `GET /health` - Health check endpoint

## Security Test Scenarios

The application includes several endpoints designed to test WAAS protection:

1. **SQL Injection**: `/api/users/1' OR '1'='1`
2. **XSS Attack**: `/api/search?q=<script>alert("XSS")</script>`
3. **Unauthorized Access**: `/api/admin`
4. **Brute Force**: Multiple POST requests to `/api/login`
5. **Path Traversal**: `/api/users/../../../etc/passwd`

## Docker Commands

```bash
# Build the image
docker build -t waas-test-app .

# Run the container
docker run -p 3000:3000 waas-test-app

# Run with environment variables
docker run -p 3000:3000 -e NODE_ENV=production waas-test-app
```

## Environment Variables

- `PORT`: Application port (default: 3000)
- `NODE_ENV`: Environment mode (development/production)

## Security Features

- **Helmet.js**: Security headers
- **CORS**: Cross-origin resource sharing
- **Input Validation**: Basic input sanitization
- **Error Handling**: Comprehensive error handling
- **Non-root User**: Docker container runs as non-root user

## Next Steps

After deploying this application, you can:

1. Configure WAAS In-Line protection in Prisma Cloud
2. Test various security scenarios
3. Monitor WAAS logs and alerts
4. Validate protection effectiveness

## Troubleshooting

### Port Already in Use
```bash
# Check what's using port 3000
lsof -i :3000

# Kill the process or use a different port
PORT=3001 npm start
```

### Docker Issues
```bash
# Clean up Docker resources
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache
```

## License

MIT License - Feel free to use this application for testing and educational purposes.
