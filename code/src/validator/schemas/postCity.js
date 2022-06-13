const { Schema: S, Rules: R } = require("../validatorUtils");
exports.schema = S.root("POST_CITY_EVENT")
  .object({
    name: R.requiredStringNotEmpty(),
    settlers: S.required().arrayOfObjects({
      name: R.requiredStringNotEmpty(),
      surname: R.requiredStringNotEmpty(),
      birth_date: R.requiredDate(),
      email: R.requiredStringNotEmpty(),
      phone: S.required().number(),
    }),
  })
  .build();
