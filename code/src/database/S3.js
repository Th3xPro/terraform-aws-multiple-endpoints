const S3Utils = require("../services/s3Utils");
const bucketName = process.env.bucketName;
const s3Utils = S3Utils(bucketName);

module.exports = s3Utils;
