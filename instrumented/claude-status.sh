#!/bin/bash

echo "=== Claude Process Status on FreeBSD ==="
echo "Date: $(date)"
echo "System: $(uname -mrs)"
echo

# System resources
echo "System Resources:"
echo "  CPU Cores: $(sysctl -n hw.ncpu)"
echo "  Memory: $(sysctl -n hw.physmem | awk '{print int($1/1024/1024/1024)"GB"}')"
echo "  Load: $(uptime | awk -F'load averages:' '{print $2}')"
echo

# Claude processes
echo "Claude Instances:"
echo "PID    PPID   %CPU  %MEM  ELAPSED  COMMAND"
ps -o pid,ppid,pcpu,pmem,etime,args | grep "node: claude" | grep -v grep | head -10

echo
echo "Memory Usage by Claude:"
ps aux | grep "node: claude" | grep -v grep | awk '{sum+=$6} END {print "Total RSS: " int(sum/1024) "MB"}'

echo
echo "Network Connections:"
sockstat -4 -6 | grep -E "(claude|node)" | head -10

echo
echo "Open Files:"
for pid in $(ps -o pid,args | grep "node: claude" | grep -v grep | awk '{print $1}'); do
    echo "PID $pid:"
    fstat -p "$pid" 2>/dev/null | head -5
done

echo
echo "Available Tracing Tools:"
echo "- dtrace: $(which dtrace)"
echo "- truss: $(which truss)"
echo "- ktrace: $(which ktrace)"
echo "- procstat: $(which procstat)"

echo
echo "Quick Trace Commands:"
echo "# System calls:"
echo "truss -p <PID>"
echo
echo "# File descriptors:"
echo "procstat -f <PID>"
echo
echo "# Memory map:"
echo "procstat -v <PID>"
echo
echo "# Network connections:"
echo "sockstat -P tcp,udp | grep <PID>"