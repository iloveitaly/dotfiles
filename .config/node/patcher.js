const path = require('path')

const Mod = require('module');

const req = Mod.prototype.require;

Mod.prototype.require = function () {
  // do some side-effect of your own
  console.log("hi")
  req.apply(this, arguments);
};

// const { Hook } = require('/Users/mike/.asdf/installs/nodejs/19.1.0/lib/node_modules/require-in-the-middle')

// // // lib/internal/debugger/inspect_repl.js
// new Hook(['internal/debugger/inspect', 'internal/debugger/inspect_repl', 'internal/debugger/inspect_client'], function (exports, name, basedir) {
//   // const version = require(path.join(basedir, 'package.json')).version

//   // console.log('loading %s@%s', name, version)
//   console.log("hi")

//   // expose the module version as a property on its exports object
//   // exports._version = version


//   // whatever you return will be returned by `require`
//   return exports
// })

// delete require.cache