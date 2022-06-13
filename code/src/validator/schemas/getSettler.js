const { Schema: S, Rules: R } = require("../validatorUtils");

exports.schema = S.root("GET_SETTLER_EVENT")
  .object({
    ID: S.required().string(),
  })
  .build();
