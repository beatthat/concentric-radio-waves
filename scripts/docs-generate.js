const unpm = require('unity-npm-utils')
try {
    unpm.unityPackage.generateDocs().then(_ => console.log('doxygen complete'))
}
catch(err) {
    console.error(`error generating docs: ${err.message}\n${err.stack}`)
}
