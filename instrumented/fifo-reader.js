#!/usr/bin/env node

const fs = require('fs');
const readline = require('readline');
const path = require('path');

const FIFO_PATH = path.join(__dirname, 'debug.fifo');
const LOG_PATH = path.join(__dirname, 'function-calls.log');

// Memory usage tracker
class MemoryTracker {
  constructor() {
    this.samples = [];
    this.interval = null;
  }
  
  start() {
    this.interval = setInterval(() => {
      const usage = process.memoryUsage();
      this.samples.push({
        timestamp: Date.now(),
        heapUsed: usage.heapUsed,
        heapTotal: usage.heapTotal,
        rss: usage.rss,
        external: usage.external
      });
    }, 100);
  }
  
  stop() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
  }
  
  report() {
    if (this.samples.length === 0) return;
    
    const avgHeap = this.samples.reduce((sum, s) => sum + s.heapUsed, 0) / this.samples.length;
    const maxHeap = Math.max(...this.samples.map(s => s.heapUsed));
    const minHeap = Math.min(...this.samples.map(s => s.heapUsed));
    
    console.log('\n=== Memory Usage Report ===');
    console.log(`Samples: ${this.samples.length}`);
    console.log(`Heap Used - Avg: ${(avgHeap / 1024 / 1024).toFixed(2)}MB`);
    console.log(`Heap Used - Max: ${(maxHeap / 1024 / 1024).toFixed(2)}MB`);
    console.log(`Heap Used - Min: ${(minHeap / 1024 / 1024).toFixed(2)}MB`);
  }
}

// Function call logger
const logStream = fs.createWriteStream(LOG_PATH, { flags: 'a' });

function logCall(name, args, result) {
  const entry = {
    timestamp: new Date().toISOString(),
    function: name,
    args: args,
    result: result,
    pid: process.pid
  };
  logStream.write(JSON.stringify(entry) + '\n');
}

// Main reader
async function main() {
  console.log('=== FIFO Reader Application ===');
  console.log(`Reading from: ${FIFO_PATH}`);
  console.log(`Logging to: ${LOG_PATH}`);
  
  const memTracker = new MemoryTracker();
  memTracker.start();
  
  // Create readline interface
  const rl = readline.createInterface({
    input: fs.createReadStream(FIFO_PATH),
    crlfDelay: Infinity
  });
  
  let lineCount = 0;
  
  rl.on('line', (line) => {
    lineCount++;
    console.log(`[${lineCount}] Received:`, line);
    
    try {
      const data = JSON.parse(line);
      logCall('processMessage', [line], data);
      
      // Simulate processing
      if (data.processed) {
        console.log(`  - Processed: ${data.processed}`);
        console.log(`  - Reversed: ${data.reversed}`);
      }
    } catch (err) {
      console.error('[ERROR] Failed to parse:', err.message);
      logCall('processMessage', [line], { error: err.message });
    }
  });
  
  rl.on('close', () => {
    console.log('\nFIFO closed');
    memTracker.stop();
    memTracker.report();
    logStream.end();
  });
  
  // Graceful shutdown
  process.on('SIGINT', () => {
    console.log('\n[SIGINT] Shutting down...');
    rl.close();
    process.exit(0);
  });
}

// Run the application
if (require.main === module) {
  main().catch(console.error);
}