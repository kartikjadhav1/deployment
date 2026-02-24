
FROM nginx:alpine

# Copy application files to nginx html directory
COPY /src/index.html /usr/share/nginx/html/
COPY /src/style.css /usr/share/nginx/html/
COPY /src/script.js /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]