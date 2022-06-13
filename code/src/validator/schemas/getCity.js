const { Schema: S, Rules: R } = require("../validatorUtils");

exports.schema = S.root("GET_CITY_EVENT")
  .object({
    ID: S.required().string(),
  })
  .build();
