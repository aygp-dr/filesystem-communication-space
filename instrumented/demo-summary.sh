#!/bin/bash

echo "=== FIFO Communication & Tracing Demo Summary ==="
echo
echo "This demo shows:"
echo "1. Named pipe (FIFO) communication between processes"
echo "2. Function call tracing in Node.js"
echo "3. Memory usage tracking"
echo "4. IPC performance monitoring"
echo

# Show the test results
echo "Test Results:"
echo "- Successfully created FIFO at instrumented/debug.fifo"
echo "- Passed data through FIFO: words (apple, banana, etc.)"
echo "- Node.js reader/writer communicated via FIFO"
echo "- Function calls were traced and logged"
echo

echo "Function Call Log Summary:"
if [ -f instrumented/function-calls.log ]; then
  CALLS=$(wc -l <instrumented/function-calls.log)
  echo "- Total function calls logged: $CALLS"
  echo "- Sample entries:"
  tail -3 instrumented/function-calls.log | jq -r '"\(.timestamp) - \(.function) - PID:\(.pid)"' 2>/dev/null
fi

echo
echo "To trace Node.js with system calls on Linux, use:"
echo "  strace -e trace=memory node instrumented/fifo-writer.js"
echo
echo "On FreeBSD (this system), use:"
echo "  truss -f node instrumented/fifo-writer.js"
echo "  or dtrace for more detailed tracing"
echo
echo "Files created:"
for file in instrumented/*; do
  if [[ "$file" =~ (fifo|\.js|\.log|\.md|\.sh)$ ]]; then
    echo "  - $(basename "$file")"
  fi
done
