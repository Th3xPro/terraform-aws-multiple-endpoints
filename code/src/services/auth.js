const errors = require("./errors");
const apiKey = "55xoMWXyaB9Yp5OnLo9Qj1nGCUris7P27FVfbbx6";
const authorize = (headers) => {
  if (headers["X-API-KEY"] != apiKey) {
    throw new errors.AuthorizationError("INVALID_STATE_TOKEN");
  }
};
module.exports = authorize;
