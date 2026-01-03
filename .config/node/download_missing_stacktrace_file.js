const fs = require('fs');
const path = require('path');

if (process.argv.length < 3) {
    console.log("Please provide a file path as an argument.");
    process.exit(1);
}

const filePath = process.argv[2];

fs.access(filePath, fs.constants.F_OK, async (err) => {
    if (err) {
        console.log(`File ${filePath} does not exist. Downloading from GitHub...`);

        // Get node_modules directory, then go up one level to get project root
        const projectRoot = path.dirname(filePath).split('node_modules')[0];
        const packageJsonPath = path.join(projectRoot, 'package.json');
        const packageJson = require(packageJsonPath);

        // Get repository info
        const repoInfo = packageJson.repository.url.split('/');
        const userName = repoInfo[repoInfo.length - 2];
        const repoName = repoInfo[repoInfo.length - 1].replace('.git', '');

        // Determine the package from the filePath
        const packageName = filePath.split('/')[filePath.split('/').indexOf('node_modules') + 1];
        const version = packageJson.dependencies[packageName];

        const url = `https://raw.githubusercontent.com/${userName}/${repoName}/${version}${filePath}`;

        const response = await fetch(url);
        if (response.ok) {
            const fileStream = fs.createWriteStream(filePath);
            response.body.pipe(fileStream);
        } else {
            console.log(`Failed to download file: ${response.status} ${response.statusText}`);
        }
    } else {
        console.log(`File ${filePath} exists`);
    }
});
