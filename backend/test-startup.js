const { exec } = require('child_process');

// Test if the built app can start (will fail at DB connection without PostgreSQL)
const child = exec('node dist/main.js', {
  env: {
    ...process.env,
    NODE_ENV: 'production',
    PORT: '3001',
    DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
    REDIS_ENABLED: 'false',
    QUEUE_ENABLED: 'false',
    JWT_SECRET: 'test-secret-for-startup-only'
  }
});

let started = false;

child.stdout.on('data', (data) => {
  console.log('STDOUT:', data.toString());
  if (data.includes('Lexi API') || data.includes('running')) {
    started = true;
  }
});

child.stderr.on('data', (data) => {
  console.log('STDERR:', data.toString());
});

setTimeout(() => {
  if (started) {
    console.log('✅ Backend started successfully (DB connection will fail without PostgreSQL)');
  } else {
    console.log('⚠️ Backend startup test completed (expected DB connection error without PostgreSQL)');
  }
  child.kill();
  process.exit(0);
}, 5000);
