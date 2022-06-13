const cityDDB = require("../database/cityDDB");
const S3 = require("../database/S3");
const settlerDDB = require("../database/settlerDDB");
const errors = require("./errors");
const {
  valGetSettler,
  valGetSettlers,
} = require("../validator/settlerValidator");
const { valGetCity } = require("../validator/cityValidator");
const citySQS = require("../queue/citySQS");
const settlerSQS = require("../queue/settlerSQS");
const s3SQS = require("../queue/s3SQS");

async function executeCity(data) {
  console.log("check data", data);
  switch (data.route) {
    case "/city/{ID}":
      valGetCity(data.params);
      return (result = await cityDDB.get(data.params.ID));
    case "/cities":
      return (result = await cityDDB.getAll());
    case "/city":
      return (result = await cityDDB.multipleWrite(data.city, data.settler));
    default:
      throw new errors.BadRequestError(`No such route exist - ${route}`);
  }
}
async function executeSettler(data) {
  console.log(data);
  switch (data.route) {
    case "/settler":
      return await settlerDDB.put(data.body);
    case "/settler/{ID}":
      valGetSettler(data.params);
      return await settlerDDB.get(data.params.ID);
    case "/settlers/{cityId}":
      valGetSettlers(data.params);
      return await cityDDB.get(data.params.cityId);
    case "/settlers":
      return await settlerDDB.getAll();
    default:
      throw new errors.BadRequestError(`No such route exist - ${route}`);
  }
}
async function executeS3(data) {
  console.log(data);
  switch (data.route) {
    case "POST":
      return await S3.wrtie(data.file, data.params);
    case "GET":
      return await S3.get(data.params);
    default:
      throw new errors.BadRequestError(`No such route exist - ${route}`);
  }
}
async function executeSQS(data) {
  switch (true) {
    case data.route.includes("cit"):
      return await citySQS.send(data);
    case data.route.includes("settler"):
      return await settlerSQS.send(data);
    case data.route.includes("file"):
      return await s3SQS.send(data);
    default:
      throw new errors.BadRequestError(`No such route exist - ${route}`);
  }
}
module.exports = { executeCity, executeSettler, executeS3, executeSQS };
