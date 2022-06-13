const aws = require("aws-sdk");
const s3Bucket = new aws.S3();

const S3Utils = (BUCKET_NAME) => {
  return {
    async get(fileName) {
      const params = {
        Bucket: BUCKET_NAME,
        Key: fileName,
      };

      let data = await s3Bucket.getObject(params).promise();
      if (!data) {
        throw new errors.InternalError(
          `Failed to get file ${fileName}, from ${BUCKET_NAME}`
        );
      }

      if (fileName.slice(fileName.length - 4, fileName.length) == "json") {
        data = data.Body.toString();
      }
      return data;
    },
    async wrtie(data, fileName) {
      const params = {
        Bucket: BUCKET_NAME,
        Body: JSON.stringify(data),
        Key: fileName,
      };
      const newFile = await s3Bucket.putObject(params).promise();
      if (!newFile) {
        throw new errors.InternalError(
          `There was an error inserting file ${fileName} in ${BUCKET_NAME}`
        );
      }
      return newFile;
    },
  };
};

module.exports = S3Utils;
