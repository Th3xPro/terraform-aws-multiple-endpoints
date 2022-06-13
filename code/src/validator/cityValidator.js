const { Validator } = require("./validator");
const { schema: getCity } = require("./schemas/getCity");
const { schema: postCity } = require("./schemas/postCity");
function valGetCity(data) {
  const validator = new Validator(getCity);
  console.log(data);
  console.log(typeof data);

  validator.validate(data);
}
function valPostCity(data) {
  const validator = new Validator(postCity);
  validator.validate(data);
}
module.exports = {
  valGetCity,
  valPostCity,
};
