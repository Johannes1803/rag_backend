# Start a new stage for a smaller final image
FROM deepset/hayhooks:v0.6.0

# Set up working directory
WORKDIR /app

# Copy your application code
COPY rag_backend .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
