const unpm = require('unity-npm-utils');
const path = require('path');

const pkgRoot = path.join(__dirname, '..');

unpm.unityPackage.updateTemplate(pkgRoot, {
    // verbose: opts.verbose
}, (err) => {
    if(err) {
        console.error('error updating template at path %j: %j', pkgRoot, err);
        process.exit(1);
    }
});
