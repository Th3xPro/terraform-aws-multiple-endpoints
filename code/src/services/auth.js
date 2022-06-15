const errors = require("./errors");
const apiKey = "XBtgT2PnNy7hNnLJwXG45jltrvLacza5Dlf48en4";
const authorize = (headers) => {
  if (headers["X-API-KEY"] != apiKey) {
    throw new errors.AuthorizationError("INVALID_STATE_TOKEN");
  }
};
module.exports = authorize;
