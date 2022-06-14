const authorize = require("../services/auth");
const { executeSQS } = require("../services/executeUtils");
const Responses = require("../services/responsesUtils");

exports.handler = async (event, context, callback) => {
  const data = {};
  try {
    //Authorize
    authorize(event.headers);
    //Defining route
    data.route = event.resource;

    //Getting body data
    data.body = event.body && event.body;

    //Getting path parameters
    data.params = event.pathParameters && event.pathParameters;

    //Execute
    const res = await executeSQS(data);

    return Responses._200({ message: "Success", res });
  } catch (error) {
    // Handle error
    console.log(error);
    return Responses.handleError(error);
  }
};
