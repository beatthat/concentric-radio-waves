const unpm = require('unity-npm-utils')
const path = require('path')

const pkgRoot = path.join(__dirname, '..')

unpm.unityProject.installPackageToUnity(pkgRoot)
.then(info => {
	//console.log('success')
})
.catch(e => {
	console.log(`postinstall failed with error: ${e}`)
})
