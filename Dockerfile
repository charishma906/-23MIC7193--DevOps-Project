# ABC Technologies Corporate Website - Docker Image
FROM nginx:1.27-alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy custom nginx config (adds /healthz and /nginx_status for monitoring)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy website files
COPY website/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
