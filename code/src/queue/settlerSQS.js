const { SqsUtils } = require("../services/sqsUtils");
const SETTLER_SQS_URL = process.env.SETTLER_SQS_URL;
const settlerSqsUtils = SqsUtils(SETTLER_SQS_URL);

module.exports = settlerSqsUtils;
