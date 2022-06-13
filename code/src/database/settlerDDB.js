const { DynamoUtils } = require("../services/dynamoUtils");
const SettlerTable = process.env.settlerTable;
const dynamoUtils = DynamoUtils(SettlerTable);

module.exports = dynamoUtils;
