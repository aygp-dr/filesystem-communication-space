#!/usr/sbin/dtrace -s

/*
 * claude-monitor.d - Monitor Claude instances on FreeBSD
 * 
 * Usage: sudo dtrace -s claude-monitor.d -p <PID>
 * Or:    sudo dtrace -s claude-monitor.d -c "node claude"
 */

#pragma D option quiet

BEGIN
{
    printf("Claude Monitor Started\n");
    printf("Monitoring system calls, file I/O, and network activity\n\n");
    printf("%-8s %-12s %-20s %s\n", "TIME", "TYPE", "FUNCTION", "DETAILS");
}

/* File operations */
syscall::open:entry
/pid == $target/
{
    self->path = copyinstr(arg0);
}

syscall::open:return
/pid == $target && self->path != NULL/
{
    printf("%-8d %-12s %-20s %s (fd=%d)\n", 
        timestamp/1000000, "FILE", "open", self->path, arg0);
    self->path = 0;
}

/* Network operations */
syscall::connect:entry
/pid == $target/
{
    printf("%-8d %-12s %-20s\n", 
        timestamp/1000000, "NETWORK", "connect");
}

syscall::send*:entry
/pid == $target/
{
    @bytes_sent[probefunc] = sum(arg2);
    printf("%-8d %-12s %-20s %d bytes\n", 
        timestamp/1000000, "NETWORK", probefunc, arg2);
}

syscall::recv*:entry
/pid == $target/
{
    @bytes_recv[probefunc] = sum(arg2);
}

/* Process operations */
syscall::fork:entry,
syscall::execve:entry
/pid == $target/
{
    printf("%-8d %-12s %-20s\n", 
        timestamp/1000000, "PROCESS", probefunc);
}

/* Memory operations */
syscall::mmap:entry
/pid == $target/
{
    printf("%-8d %-12s %-20s size=%d\n", 
        timestamp/1000000, "MEMORY", "mmap", arg1);
}

/* Periodic stats */
tick-5s
{
    printf("\n=== 5 Second Stats ===\n");
    printa("Bytes sent via %s: %@d\n", @bytes_sent);
    printa("Bytes recv via %s: %@d\n", @bytes_recv);
    printf("===================\n\n");
}

END
{
    printf("\n=== Final Statistics ===\n");
    printa("Total bytes sent via %s: %@d\n", @bytes_sent);
    printa("Total bytes recv via %s: %@d\n", @bytes_recv);
}