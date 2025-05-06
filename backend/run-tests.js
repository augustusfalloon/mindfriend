const fs = require('fs');
const path = require('path');

const testDir = path.join(__dirname, 'tests');
const testFiles = fs.readdirSync(testDir).filter(f => f.endsWith('.test.js'));

let failures = 0;

for (const file of testFiles) {
  const fullPath = path.join(testDir, file);
  try {
    require(fullPath);
    console.log(`✅ ${file} passed`);
  } catch (err) {
    console.error(`❌ ${file} failed`);
    console.error(err.stack || err);
    failures++;
  }
}

if (failures > 0) {
  console.error(`\n❌ ${failures} test(s) failed`);
  process.exit(1);
} else {
  console.log('\n✅ All tests passed!');
}
