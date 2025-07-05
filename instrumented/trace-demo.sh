#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Node.js FIFO Communication with Tracing Demo ==="
echo "Script location: $SCRIPT_DIR"
echo

# Cleanup previous runs
rm -f "$SCRIPT_DIR/function-calls.log"
rm -f "$SCRIPT_DIR"/strace-*.log

echo "1. Starting FIFO reader with memory tracking..."
node "$SCRIPT_DIR/fifo-reader.js" &
READER_PID=$!
echo "   Reader PID: $READER_PID"

sleep 1

echo
echo "2. Starting FIFO writer with function tracing..."
node "$SCRIPT_DIR/fifo-writer.js" &
WRITER_PID=$!
echo "   Writer PID: $WRITER_PID"

# Wait for writer to complete
wait $WRITER_PID

echo
echo "3. Checking function call log..."
if [ -f "$SCRIPT_DIR/function-calls.log" ]; then
  echo "   Function calls logged:"
  jq -r '"\(.timestamp) - \(.function)(\(.args | length) args) -> \(.result | type)"' "$SCRIPT_DIR/function-calls.log" 2>/dev/null || cat "$SCRIPT_DIR/function-calls.log"
fi

# Stop reader
sleep 1
kill $READER_PID 2>/dev/null

echo
echo "4. Running with strace memory tracing..."
# Check if strace is available
if command -v strace &>/dev/null; then
  echo "   Starting traced reader..."
  strace -e trace=memory -o "$SCRIPT_DIR/strace-reader.log" node "$SCRIPT_DIR/fifo-reader.js" &
  STRACE_READER_PID=$!

  sleep 1

  echo "   Starting traced writer..."
  strace -e trace=memory -o "$SCRIPT_DIR/strace-writer.log" node "$SCRIPT_DIR/fifo-writer.js"

  # Wait and cleanup
  sleep 1
  kill $STRACE_READER_PID 2>/dev/null

  echo
  echo "5. Strace memory operations summary:"
  if [ -f "$SCRIPT_DIR/strace-reader.log" ]; then
    echo "   Reader memory operations:"
    grep -E "mmap|munmap|brk" "$SCRIPT_DIR/strace-reader.log" | head -5
  fi

  if [ -f "$SCRIPT_DIR/strace-writer.log" ]; then
    echo "   Writer memory operations:"
    grep -E "mmap|munmap|brk" "$SCRIPT_DIR/strace-writer.log" | head -5
  fi
else
  echo "   strace not available on this system (FreeBSD uses dtrace/truss instead)"
fi

echo
echo "6. Alternative tracing with ltrace (library calls):"
echo "   ltrace -e malloc+free+mmap node instrumented/fifo-writer.js"

echo
echo "7. SystemTap example for detailed tracing:"
cat <<'EOF'
   # trace-node.stp
   probe process("node").function("*") {
     printf("%s -> %s\n", thread_indent(1), probefunc())
   }
EOF

echo
echo "Demo complete! Check instrumented/ for logs."
