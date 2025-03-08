#!/bin/bash
# entrypoint.sh

# Start hayhooks server in the background
hayhooks run --host 0.0.0.0 --port 1416 &

# Store the PID of the background process
SERVER_PID=$!

# Wait for the server to start up properly
sleep 5

# Deploy the pipeline files
hayhooks pipeline deploy-files -n llm-only llm_only_pipeline --overwrite

# If you want the container to keep running with the server
# Bring the server process to foreground
wait $SERVER_PID