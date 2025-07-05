#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const FIFO_PATH = path.join(__dirname, 'debug.fifo');

// Function to trace calls
function trace(fn, name) {
  return function(...args) {
    console.log(`[TRACE] Calling ${name}(${args.map(a => JSON.stringify(a)).join(', ')})`);
    const start = process.hrtime.bigint();
    const result = fn.apply(this, args);
    const end = process.hrtime.bigint();
    console.log(`[TRACE] ${name} completed in ${(end - start) / 1000000n}ms`);
    return result;
  };
}

// Traced functions
const tracedWrite = trace(function write(data) {
  const stream = fs.createWriteStream(FIFO_PATH, { flags: 'a' });
  stream.write(data + '\n');
  stream.end();
  return data;
}, 'write');

const tracedProcess = trace(function processData(input) {
  // Simulate some processing
  const processed = input.toUpperCase();
  const reversed = input.split('').reverse().join('');
  return { original: input, processed, reversed };
}, 'processData');

// Main application
async function main() {
  console.log('=== FIFO Writer Application ===');
  console.log(`Writing to: ${FIFO_PATH}`);
  
  // Test data
  const testData = [
    'hello world',
    'function tracing',
    'memory allocation',
    'node.js ipc demo'
  ];
  
  console.log('\nWriting test data...');
  for (const data of testData) {
    const result = tracedProcess(data);
    tracedWrite(JSON.stringify(result));
    
    // Simulate some work
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  console.log('\nWriter finished!');
}

// Handle errors
process.on('uncaughtException', (err) => {
  console.error('[ERROR]', err);
  process.exit(1);
});

// Run the application
if (require.main === module) {
  main().catch(console.error);
}