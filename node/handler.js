'use strict';

const os = require('os');
const path = require('path');
const fs = require('fs');
const promisify = require('util').promisify;
const write = promisify(fs.writeFile);
const mkDir = require('mkdirp-promise');
const rmDir = require('rimraf').sync;
const runCLI = require('jest-cli').runCLI;
const getResult = require('./handleSuitResults');

module.exports.run = async (event) => {
  const { body } = event;
  const { code, testCode } = JSON.parse(body);
  const tempDir = path.join(os.tmpdir(), 'jest');
  const testFilePath = path.join(tempDir, 'index.test.js');
  const testFileContent = [code, testCode].join("\n\n");
  const resultFilePath = path.join(tempDir, 'result.json');
  const jestFilePath = path.join(tempDir, 'jest.config.js');
  const jestConfig = {
    roots: ['./'],
    testRegex: '\\.test\\.js$',
    outputFile: resultFilePath,
    json: true
  };

  await mkDir(tempDir);
  await write(testFilePath, testFileContent);
  await write(jestFilePath, 'module.exports = { verbose: true };');

  await runCLI(jestConfig, [tempDir]);
  const data = await getResult(resultFilePath);

  fs.unlinkSync(testFilePath);
  fs.unlinkSync(resultFilePath);
  fs.unlinkSync(jestFilePath);
  rmDir(tempDir);

  return {
    statusCode: 200,
    body: JSON.stringify({data})
  };
};

