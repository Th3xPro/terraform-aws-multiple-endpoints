// city -> event parse, settler, delete.city.settlers, params
// s3   -> event parse, params
// settler -> event parse, params
const { v4: uuidv4 } = require("uuid");
const { valPostCity } = require("../validator/cityValidator");
const { valPutSettler } = require("../validator/settlerValidator");

function createSettler(data, cityId) {
  return data.map((obj) => {
    obj.ID = uuidv4();
    obj.cityId = cityId;
    return { PutRequest: { Item: obj } };
  });
}
function parseEvent(event) {
  return event.body === "string" ? JSON.parse(event.body) : event.body;
}
function getEventData(event) {
  const data = {};
  console.log(event);
  try {
    switch (event.resource) {
      case "/city":
        data.city = parseEvent(event);
        valPostCity(data.city);
        data.city.ID = uuidv4();
        data.settler = createSettler(data.city.settlers, data.city.ID);
        delete data.city.settlers;
        data.params = event.pathParameters;
        console.log(data);
        return data;
      case "/settler":
        data.body = parseEvent(event);
        valPutSettler(data.body);
        data.body.ID = uuidv4();
        data.body.cityId = uuidv4();
        data.params = event.pathParameters;
        console.log(data);
        return data;
      default:
        data.params = event.pathParameters;
    }
  } catch (error) {
    console.log("BŁAD", error);
  }
}
module.exports = { getEventData };
// event.resource === "/city" &&
//     ((data.city = parseEvent(event)),
//     valPostCity(data),
//     (data.city.ID = uuidv4()),
//     (data.settler = createSettler(data.city.settlers, data.city.ID)),
//     delete data.city.settlers);
//   event.resource === "/settler" &&
//     (valPutSettler(data),
//     (data.body.ID = uuidv4()),
//     (data.body.cityId = uuidv4()));

//   data.params = event.pathParameters;
