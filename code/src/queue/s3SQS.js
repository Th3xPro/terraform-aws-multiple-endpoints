const { SqsUtils } = require("../services/sqsUtils");
const S3_SQS_URL = process.env.S3_SQS_URL;
const s3SqsUtils = SqsUtils(S3_SQS_URL);

module.exports = s3SqsUtils;
