const aws = require("aws-sdk");
const dynamoDB = new aws.DynamoDB.DocumentClient();
const errors = require("./errors");
const DynamoUtils = (TABLE_NAME) => {
  return {
    async get(id) {
      const params = {
        TableName: [TABLE_NAME],
        Key: {
          ID: id,
        },
      };
      const data = await dynamoDB.get(params).promise();
      console.log(data);
      if (!data || !data.Item) {
        throw new errors.InternalError(
          `There was an error getting data of ID ${id} from ${TABLE_NAME}`
        );
      }
      return data.Item;
    },

    async put(data) {
      const res = { ID: data.ID };
      console.log(res);
      if (!data.ID) {
        throw new errors.BadRequestError(`No id included in data`);
      }
      const params = {
        TableName: [TABLE_NAME],
        Item: data,
      };
      await dynamoDB.put(params).promise();
      if (!res) {
        throw new errors.InternalError(
          `There was an error inserting data with id ${data.ID} in ${TABLE_NAME}`
        );
      }
      return res;
    },

    async getAll(cityId = null) {
      if (cityId != null) {
        const params = {
          TableName: [TABLE_NAME],
          Key: {
            cityId: [cityId],
          },
        };
        const data = await dynamoDB.get(params).promise();
        return data.Item;
      } else {
        const params = { TableName: [TABLE_NAME] };
        return dynamoDB
          .scan(params)
          .promise()
          .then((data) => data.Items)
          .catch((err) => {
            console.log(err);
            throw new errors.InternalError(
              `There was an error getting data from ${TABLE_NAME}`
            );
          });
      }
    },
  };
};

module.exports = {
  DynamoUtils,
  dynamoDB,
};
