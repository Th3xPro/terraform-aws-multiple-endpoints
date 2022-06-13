const { DynamoUtils, dynamoDB } = require("../services/dynamoUtils");
const CityTable = process.env.cityTable;
const SettlerTable = process.env.settlerTable;
const dynamoUtils = DynamoUtils(CityTable);
const errors = require("../services/errors");

async function multipleWrite(cityItem, settlerItem = []) {
  try {
    const res = {};
    res.settlers = [
      settlerItem.map((obj) => {
        return {
          [obj.PutRequest.Item.name + " " + obj.PutRequest.Item.surname]:
            obj.PutRequest.Item.ID,
        };
      }),
    ];
    res.city = cityItem.ID;
    let itemOne = [];
    itemOne.push({
      PutRequest: {
        Item: cityItem,
      },
    });

    let params = {
      RequestItems: {
        [CityTable]: itemOne,
        [SettlerTable]: settlerItem,
      },
    };
    await dynamoDB.batchWrite(params).promise();
    return res;
  } catch (err) {
    console.log(err);
    throw new errors.InternalError(
      `There was an error writing data to table - ${CityTable} and ${SettlerTable}`
    );
  }
}

dynamoUtils.multipleWrite = multipleWrite;

module.exports = dynamoUtils;
