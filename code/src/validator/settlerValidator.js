const { Validator } = require("./validator");
const { schema: putSettler } = require("./schemas/putSettler");
const { schema: getSettler } = require("./schemas/getSettler");
const { schema: getSettlers } = require("./schemas/getSettlers");

function valPutSettler(data) {
  const validator = new Validator(putSettler);
  validator.validate(data);
}
function valGetSettler(data) {
  const validator = new Validator(getSettler);
  validator.validate(data);
}
function valGetSettlers(data) {
  const validator = new Validator(getSettlers);
  validator.validate(data);
}

module.exports = {
  valPutSettler,
  valGetSettler,
  valGetSettlers,
};
