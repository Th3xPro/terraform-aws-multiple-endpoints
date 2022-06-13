const Responses = require("../services/responsesUtils");
const authorize = require("../services/auth");
const { v4: uuidv4 } = require("uuid");
const { executeCity } = require("../services/executeUtils");
const { valPostCity } = require("../validator/cityValidator");

function createSettler(data, cityId) {
  return data.map((obj) => {
    obj.ID = uuidv4();
    obj.cityId = cityId;
    return { PutRequest: { Item: obj } };
  });
}

function parseEvent(event) {
  const res =
    typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  valPostCity(res);
  res.ID = uuidv4();
  return res;
}

exports.handler = async (eventz) => {
  console.log("TUTAJ", event);
  const data = {};
  try {
    //Authorize
    // authorize(event.headers);
    //Defining route
    data.route = event.resource;

    //If body exists prepare for POST
    event.body &&
      ((data.city = parseEvent(event)),
      (data.settler = createSettler(data.city.settlers, data.city.ID)),
      delete data.city.settlers);

    //Getting path parameters
    data.params = event.pathParameters;

    //Execute
    const result = await executeCity(data);
    // Return the response
    return Responses._200({ message: "Success", result });
  } catch (error) {
    // Handle error
    console.log(error);
    return Responses.handleError(error);
  }
};
