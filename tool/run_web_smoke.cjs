// Run after building the WASM module and compiling tool/web_smoke.dart.
const path = require('node:path');
const output = path.resolve(process.argv[2] || 'build/web/build/out');
const createModule = require(path.join(output, 'reactphysics3d_dart.js'));
globalThis.self = globalThis;
createModule().then(module => {
  globalThis.rp3d = module;
  require(path.join(output, 'smoke.js'));
}).catch(error => {
  console.error(error);
  process.exit(1);
});
