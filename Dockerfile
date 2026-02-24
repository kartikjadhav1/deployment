
FROM nginx:alpine

COPY /src/index.html /usr/share/nginx/html/
COPY /src/style.css /usr/share/nginx/html/
COPY /src/script.js /usr/share/nginx/html/

EXPOSE 80


CMD ["nginx", "-g", "daemon off;"]