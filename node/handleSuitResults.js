'use strict';

const fs = require('fs');
const promisify = require('util').promisify;
const read = promisify(fs.readFile);

module.exports = async (resultsPath) => {
  const fileContent = await read(resultsPath);
  const results = JSON.parse(fileContent.toString('utf8'));
  const { 
    numPassedTests, 
    numFailedTests,
    numPendingTests,
    numTotalTests
  } = results;
  let preparedResults = {
    finalResult: results.success ? 'passed' : 'failed',
    numPassedTests, 
    numFailedTests,
    numPendingTests,
    numTotalTests
  };

  let resultMessages = results.testResults.map(({assertionResults}) => assertionResults);
  resultMessages = [].concat.apply([], resultMessages);
  resultMessages = resultMessages.map(({fullName, status}) => ({fullName, status}));

  preparedResults.results = resultMessages;

  return preparedResults;
}
