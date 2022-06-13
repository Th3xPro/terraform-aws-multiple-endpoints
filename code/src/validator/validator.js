const jsonschema = require("jsonschema");
const errors = require("../services/errors");

class Validator {
  constructor(schema) {
    this.validator = new jsonschema.Validator();
    this.schema = schema;
  }

  addSchema(schema) {
    this.validator.addSchema(schema, schema.ID);
    return this;
  }
  validate(data) {
    if (!data || typeof data !== "object") {
      throw new errors.BadRequestError("Missing parameter request");
    }
    try {
      return this.validator.validate(data, this.schema, {
        throwError: true,
      });
    } catch (error) {
      if (error.name === "required") {
        throw new errors.BadRequestError("Missing Parameter request");
      }
      throw new errors.BadRequestError("Invalid Parameter request");
    }
  }
}
module.exports = {
  Validator,
};
