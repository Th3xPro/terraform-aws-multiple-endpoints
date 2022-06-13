const { Schema: S, Rules: R } = require("../validatorUtils");

exports.schema = S.root("GET_SETTLERS_EVENT")
  .object({
    cityId: S.optional().string(),
  })
  .build();
