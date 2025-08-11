FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the HTML file
COPY index.html /usr/share/nginx/html/index.html

# Expose the custom port
EXPOSE 8088

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
