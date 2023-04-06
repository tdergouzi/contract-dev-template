module.exports = {
    skipFiles: [
      'mocks/',
      'interfaces/',
      'test/',
    ],
    istanbulReporter: ['html', 'lcov']
    // mocha: {
    //   reporter: 'hardhat-gas-reporter',
    //   reporterOptions: {
    //     excludeContracts: ['Example'],
    //   },
    // },
  };