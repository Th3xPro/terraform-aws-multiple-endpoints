const Responses = require("./src/services/responsesUtils");
const authorize = require("./src/services/auth");
const { executeS3 } = require("./src/services/executeUtils");

function parseEvent(event) {
  return typeof event.body === "string" ? JSON.parse(event.body) : event.body;
}
exports.handler = async (event) => {
  console.log(event);
  const data = {};
  try {
    //Authorize
    authorize(event.headers);
    //Defining route
    data.route = event.httpMethod;

    //If body exists prepare for POST
    data.file = event.body && parseEvent(event);

    //Getting path parameters
    data.params = event.pathParameters.fileName || event.pathParameters.file;

    //Execute
    const result = await executeS3(data);
    // Return the response
    return Responses._200({ message: "Success", result });
  } catch (error) {
    // Handle error
    console.log(error);
    return Responses.handleError(error);
  }
};
