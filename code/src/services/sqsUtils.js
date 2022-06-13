const AWS = require("aws-sdk");
const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });
const errors = require("./errors");

const SqsUtils = (SQS_NAME) => {
  console.log(SQS_NAME);
  return {
    async send(data) {
      console.log(data);
      const params = {
        MessageBody: JSON.stringify(data),
        QueueUrl: SQS_NAME,
      };
      console.log(params);
      sqs.sendMessage(params, function (err, data) {
        if (err) {
          console.log("error:", "failed to send message" + err);
          throw new errors.InternalError(
            `There was an error sending message to ${SQS_NAME}`
          );
        } else {
          console.log("Success", data.MessageId, data);
          return data;
        }
      });
    },
  };
};

module.exports = {
  SqsUtils,
};
