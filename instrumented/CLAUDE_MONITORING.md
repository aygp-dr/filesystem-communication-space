# Claude Process Monitoring on FreeBSD

## Current Claude Instances

As of the scan, there are 3 Claude instances running:
- PID 57232: Running for 17+ hours, 19.5% CPU, 2.1% memory
- PID 54336: Running for 14+ hours, 7.7% CPU, 2.0% memory  
- PID 73226: Running for 13+ hours, 0.0% CPU, 1.2% memory

Total memory usage: ~848MB RSS

## Available Tracing Tools on FreeBSD 14.3

### 1. dtrace (Dynamic Tracing)
- Location: `/usr/sbin/dtrace`
- Requires: root privileges
- Best for: System-wide tracing, custom probes

Example commands:
```bash
# Trace all system calls for a process
sudo dtrace -n 'syscall:::entry /pid == $target/ { @[probefunc] = count(); }' -p <PID>

# Monitor file operations
sudo dtrace -n 'syscall::open:entry { printf("%s %s", execname, copyinstr(arg0)); }'

# Track network activity
sudo dtrace -n 'syscall::send*:entry /pid == $target/ { @bytes = sum(arg2); }' -p <PID>
```

### 2. truss (System Call Tracer)
- Location: `/usr/bin/truss`
- Requires: Same user or root
- Best for: Quick system call inspection

Example commands:
```bash
# Basic trace
truss -p <PID>

# Follow forks
truss -f -p <PID>

# Count system calls
truss -c -p <PID>
```

### 3. ktrace (Kernel Trace)
- Location: `/usr/bin/ktrace`
- Requires: Same user or root
- Best for: Detailed kernel event logging

Example commands:
```bash
# Start tracing
ktrace -p <PID> -f trace.out

# View trace
kdump -f trace.out
```

### 4. procstat (Process Statistics)
- Location: `/usr/bin/procstat`
- Best for: Process information snapshots

Example commands:
```bash
# File descriptors
procstat -f <PID>

# Memory mappings
procstat -v <PID>

# Signal disposition
procstat -i <PID>
```

## FIFO Setup for Monitoring

FIFOs created at `~/.claude/fifos/`:
- `syscalls.fifo` - System call traces
- `scheduler.fifo` - Scheduling events
- `api_calls.fifo` - API call logging

## Network Connections

Claude instances connect to:
- `34.36.57.103:443` - Multiple connections (likely Anthropic API)
- `142.250.80.68:443` - Google services
- `160.79.104.10:443` - Additional service
- `192.168.86.101:4317` - Local service (possibly telemetry)

## Scripts Created

1. `trace-claude.sh` - Interactive Claude tracer
2. `claude-monitor.d` - DTrace script for comprehensive monitoring
3. `claude-status.sh` - Status report generator

## Monitoring Workflow

1. Check status: `bash instrumented/claude-status.sh`
2. Start dtrace monitoring: `sudo dtrace -s instrumented/claude-monitor.d -p <PID>`
3. Monitor FIFOs: `tail -f ~/.claude/fifos/*.fifo`
4. Quick trace: `truss -p <PID> | head -100`