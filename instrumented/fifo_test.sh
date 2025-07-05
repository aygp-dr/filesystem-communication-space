#!/bin/bash

# Start reader in background
echo "Starting FIFO reader..."
cat instrumented/debug.fifo >instrumented/output.log &
READER_PID=$!
echo "Reader PID: $READER_PID"

# Give reader time to start
sleep 0.1

# Write initial test data
echo "Writing initial test data..."
echo "apple" >instrumented/debug.fifo
echo "banana" >instrumented/debug.fifo
echo "cherry" >instrumented/debug.fifo
echo "date" >instrumented/debug.fifo

# Check what was read
echo "Initial data written. Checking output..."
sleep 0.1
cat instrumented/output.log

# Write more test data
echo "Writing additional test data..."
echo "elephant" >instrumented/debug.fifo
echo "fox" >instrumented/debug.fifo
echo "giraffe" >instrumented/debug.fifo

# Final check
sleep 0.1
echo "Final output:"
cat instrumented/output.log

# Cleanup
kill $READER_PID 2>/dev/null
echo "Test complete!"
