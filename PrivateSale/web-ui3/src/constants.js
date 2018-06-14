

export default {
  "*": {
    NETWORK_NAME: "testrpc",
    TOKEN_ADDRESS: "0x2e3f1ea34938c3262578dff85d5061d3eb651b4a",
    // check if this is our token
    EXPECTED_TOKEN_NAME: "STRAT TOKEN Private Sale",
    // Block number when token was deployed (this is used to filter events).
    DEPLOYMENT_BLOCK_NUMBER: 1
  },

  1: {
    NETWORK_NAME: "Main",
    TOKEN_ADDRESS: "0xe9ce29aeb9da5cecce8a56b71f56804d52f85dff",
    EXPECTED_TOKEN_NAME: "STRAT TOKEN Private Sale",
    DEPLOYMENT_BLOCK_NUMBER: 3416016
  },

  3: {
    NETWORK_NAME: "Ropsten",
    TOKEN_ADDRESS: "0xe9ce29aeb9da5cecce8a56b71f56804d52f85dff",
    EXPECTED_TOKEN_NAME: "STRAT TOKEN Private Sale",
    DEPLOYMENT_BLOCK_NUMBER: 3416016
  },

  42: {
    NETWORK_NAME: "Kovan",
    TOKEN_ADDRESS: "0x3000162dccb71e830cb1c2c6ed116b12aa4d9355",
    EXPECTED_TOKEN_NAME: "STRAT TOKEN Private Sale",
    DEPLOYMENT_BLOCK_NUMBER: 3390022
  },
}
