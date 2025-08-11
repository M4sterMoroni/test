# MPIV Welcome Page

A simple nginx container serving a welcome page for MPIV.

## Quick Start

1. Build and run the container:
   ```bash
   docker-compose up --build
   ```

2. Or run with Docker directly:
   ```bash
   docker build -t mpiv-welcome .
   docker run -p 8088:8088 mpiv-welcome
   ```

3. Open your browser and navigate to:
   ```
   http://localhost:8088
   ```

## Port

The application runs on port **8088** (an unusual port to avoid conflicts).

## Files

- `index.html` - The welcome page
- `nginx.conf` - Custom nginx configuration
- `Dockerfile` - Container definition
- `docker-compose.yml` - Easy deployment
