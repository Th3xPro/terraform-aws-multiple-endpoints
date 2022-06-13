const { SqsUtils } = require("../services/sqsUtils");
const CITY_SQS_URL = process.env.CITY_SQS_URL;
const citySqsUtils = SqsUtils(CITY_SQS_URL);

module.exports = citySqsUtils;
