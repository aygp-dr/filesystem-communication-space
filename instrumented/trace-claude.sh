#!/bin/bash

# Trace Claude instances on FreeBSD
# Uses dtrace, truss, and ktrace

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIFO_DIR="$HOME/.claude/fifos"

echo "=== Claude Instance Tracer for FreeBSD ==="
echo "System: $(uname -a)"
echo

# Check if FIFO directory exists
if [ ! -d "$FIFO_DIR" ]; then
    echo "Creating FIFO directory..."
    mkdir -p "$FIFO_DIR"
fi

# Create FIFOs if they don't exist
for fifo in syscalls scheduler api_calls; do
    if [ ! -p "$FIFO_DIR/${fifo}.fifo" ]; then
        echo "Creating ${fifo}.fifo..."
        mkfifo "$FIFO_DIR/${fifo}.fifo"
        chmod 666 "$FIFO_DIR/${fifo}.fifo"
    fi
done

echo "Available tracing tools on FreeBSD:"
echo "- dtrace: Dynamic tracing framework"
echo "- truss: System call tracer"
echo "- ktrace: Kernel trace logging"
echo

# Find Claude processes
echo "Claude instances:"
ps -o pid,ppid,pcpu,pmem,etime,args | grep -E "(claude|anthropic)" | grep -v grep | grep -v trace-claude

echo
echo "Choose tracing method:"
echo "1. dtrace - System calls (requires root)"
echo "2. truss - System call trace"
echo "3. ktrace - Kernel trace"
echo "4. Monitor FIFOs"
echo

read -p "Selection (1-4): " choice

case $choice in
    1)
        echo "Starting dtrace (requires sudo)..."
        echo "Tracing system calls for Claude processes..."
        sudo dtrace -n 'syscall:::entry /execname == "node"/ { @[probefunc] = count(); }' \
            -c "sleep 10" 2>&1 | tee "$FIFO_DIR/syscalls.fifo"
        ;;
    2)
        echo "Select Claude PID to trace:"
        ps -o pid,args | grep "node: claude" | grep -v grep
        read -p "Enter PID: " pid
        echo "Tracing PID $pid with truss..."
        truss -p "$pid" 2>&1 | tee "$FIFO_DIR/syscalls.fifo"
        ;;
    3)
        echo "Select Claude PID to trace:"
        ps -o pid,args | grep "node: claude" | grep -v grep
        read -p "Enter PID: " pid
        echo "Tracing PID $pid with ktrace..."
        ktrace -p "$pid" -f "$FIFO_DIR/claude.ktrace"
        echo "Use 'kdump -f $FIFO_DIR/claude.ktrace' to view"
        ;;
    4)
        echo "Monitoring FIFOs..."
        echo "In separate terminals, run:"
        echo "  tail -f $FIFO_DIR/syscalls.fifo"
        echo "  tail -f $FIFO_DIR/scheduler.fifo"
        echo "  tail -f $FIFO_DIR/api_calls.fifo"
        ;;
esac

echo
echo "DTrace examples for Claude monitoring:"
echo "# Count system calls by name:"
echo "sudo dtrace -n 'syscall:::entry /pid == \$target/ { @[probefunc] = count(); }' -p <PID>"
echo
echo "# Trace file operations:"
echo "sudo dtrace -n 'syscall::open:entry /pid == \$target/ { printf(\"%s\", copyinstr(arg0)); }' -p <PID>"
echo
echo "# Monitor network activity:"
echo "sudo dtrace -n 'syscall::send*:entry /pid == \$target/ { @bytes = sum(arg2); }' -p <PID>"