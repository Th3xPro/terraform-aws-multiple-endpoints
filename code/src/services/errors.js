class CustomError extends Error {
  constructor(status, code, info, details = undefined) {
    super(code);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
    this.customStatus = status;
    this.customData = { code, info, details };
  }
  //NOT WORKING
  getErrorData() {
    return {
      status: this.customStatus || 500,
      data: this.customData,
    };
  }
}

class BadRequestError extends CustomError {
  constructor(details = undefined) {
    super(400, "BAD_REQUEST", "Invalid format", details);
  }
}
class AuthorizationError extends CustomError {
  constructor(info = "Unauthorized") {
    super(401, "AUTH", info);
  }
}
class NotFoundError extends CustomError {
  constructor(details = undefined) {
    super(404, "NOT_FOUND", "NO SUCH ENDPOINT", details);
  }
}
class InternalError extends CustomError {
  constructor(details = undefined) {
    super(500, "INTERNAL_ERROR", "UNKNOWN ERROR", details);
  }
}
Error.prototype.getErrorData = function () {
  // General error
  return {
    status: 500,
    data: {
      code: "T_INTERNAL",
      info: this.message || this.code,
    },
  };
};
module.exports = {
  CustomError,
  BadRequestError,
  AuthorizationError,
  NotFoundError,
  InternalError,
};
