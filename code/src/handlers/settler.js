const Responses = require("../services/responsesUtils");
const { executeSettler } = require("../services/executeUtils");
const { v4: uuidv4 } = require("uuid");
const authorize = require("../services/auth");
const { valPutSettler } = require("../validator/settlerValidator");

function parseEvent(event) {
  const res =
    typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  valPutSettler(res);
  res.ID = uuidv4();
  res.cityId = uuidv4();
  return res;
}
exports.handler = async (event) => {
  const data = {};
  try {
    //Authorize
    authorize(event.headers);
    //Defining route
    data.route = event.resource;

    //Parsing event body
    event.body && (data.body = parseEvent(event));

    //Getting path parameters
    data.params = event.pathParameters;

    //Execute
    const result = await executeSettler(data);
    // Return the response
    return Responses._200({ message: "Success", result });
  } catch (error) {
    //Handle error
    console.log(error);
    return Responses.handleError(error);
  }
};
