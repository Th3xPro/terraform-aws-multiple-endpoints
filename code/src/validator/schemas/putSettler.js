const { Schema: S, Rules: R } = require("../validatorUtils");

exports.schema = S.root("PUT_SETTLER_EVENT")
  .object({
    name: R.requiredStringNotEmpty(),
    surname: R.requiredStringNotEmpty(),
    birth_date: R.requiredDate(),
    email: R.requiredStringNotEmpty(),
    phone: S.required().number(),
  })
  .build();

const test = {
  name: "Maciej",
  surname: "Moczadło",
  birth_date: "1999-01-24",
  email: "maciej.moczadlo@o2.pl",
  phone: 504544322,
};
