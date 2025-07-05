#!/bin/bash

echo "=== Quick FIFO Test ==="

# Start reader in background with timeout
timeout 3s node instrumented/fifo-reader.js &
READER_PID=$!

# Give reader time to start
sleep 0.5

# Run writer (it will complete and exit)
node instrumented/fifo-writer.js

# Wait a bit for reader to process
sleep 0.5

# Kill reader if still running
kill $READER_PID 2>/dev/null

echo
echo "Test complete! Check instrumented/function-calls.log for results"
echo
echo "Function calls logged:"
if [ -f instrumented/function-calls.log ]; then
  jq '.' instrumented/function-calls.log 2>/dev/null || cat instrumented/function-calls.log
fi
