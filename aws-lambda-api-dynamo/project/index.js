const AWS = require("aws-sdk");
AWS.config.update({
  region: "ap-southeast-1",
});
const dynamodb = new AWS.DynamoDB.DocumentClient();
const dynamodbTableName = process.env.DYNAMODB_TABLE;
const healthPath = "/health";
const productPath = "/product";
const productsPath = "/products";

exports.handler = async function (event) {
  console.log("Request event: ", event);
  let response;
  try {
    switch (true) {
      case event.httpMethod === "GET" && event.path === healthPath:
        // code
        response = buildResponse(200);
        break;
      case event.httpMethod === "GET" && event.path === productPath:
        response = await getProduct(JSON.parse(event.body).productId);
        break;
      case event.httpMethod === "GET" && event.path === productsPath:
        response = await getProducts();
        break;
      case event.httpMethod === "POST" && event.path === productPath:
        const body = await saveProduct(JSON.parse(JSON.stringify(event.body)));
        response = buildResponse(200, body);
        break;
      case event.httpMethod === "PATCH" && event.path === productPath:
        const requestBody = JSON.parse(JSON.parse(JSON.stringify(event.body)));
        response = await modifyProduct(
          requestBody.productId,
          requestBody.updateKey,
          requestBody.updateValue
        );
        break;
      case event.httpMethod === "DELETE" && event.path === productPath:
        response = await deleteProduct(JSON.parse(event.body).productId);
        break;
      default:
        response = buildResponse(404, "404 Not Found");
    }
    return response;
  } catch (err) {
    console.log(err);
  }
};

async function getProduct(productId) {
  const params = {
    TableName: dynamodbTableName,
    Key: {
      productId: productId,
    },
  };

  try {
    const response = await dynamodb.get(params).promise();

    // Check if the item was found
    if (!response.Item) {
      return buildResponse(404, "Product not found");
    }

    return buildResponse(200, response.Item);
  } catch (error) {
    console.error("Error during getProduct:", error);

    // Return a 500 Internal Server Error response
    return buildResponse(500, "Internal Server Error");
  }
}

async function getProducts() {
  const params = {
    TableName: dynamodbTableName,
  };
  const allProducts = await scanDynamoRecords(params, []);
  const body = {
    products: allProducts,
  };
  return buildResponse(200, body);
}

async function scanDynamoRecords(scanParams, itemArray) {
  try {
    const dynamoData = await dynamodb.scan(scanParams).promise();
    itemArray = itemArray.concat(dynamoData.Items);
    if (dynamoData.lastEvaluatedKey) {
      scanParams.ExclusiveStarkey = dynamoData.LastEvaluatedKey;
      return await scanDynamoRecords(scanParams, itemArray);
    }
    return itemArray;
  } catch (error) {
    console.log(
      "Do your custome error handling here. I am just gonna log it: ",
      error
    );
  }
}

async function saveProduct(requestBody) {
  const params = {
    TableName: dynamodbTableName,
    Item: JSON.parse(requestBody),
  };
  try {
    await dynamodb.put(params).promise();

    const body = {
      Operation: "Save",
      Message: "SUCCESS",
      Item: JSON.parse(requestBody),
    };

    return body;
  } catch (error) {
    console.log(
      "Do your custom error handling here. I am just gonna log it: ",
      error
    );
    const body = {
      Operation: "Can't Save",
      Message: "ERROR",
      Item: JSON.parse(requestBody),
    };

    return body;
  }
}

async function modifyProduct(productId, updateKey, updateValue) {
  const params = {
    TableName: dynamodbTableName,
    Key: {
      productId: productId,
    },
    UpdateExpression: `set ${updateKey} = :value`,
    ExpressionAttributeValues: {
      ":value": updateValue,
    },
    ReturnValues: "ALL_NEW", // Use ALL_NEW to get the updated item
  };

  try {
    const response = await dynamodb.update(params).promise();

    const body = {
      Operation: "UPDATE",
      Message: "SUCCESS",
      Item: response.Attributes, // Use Attributes to get the updated item
    };

    return buildResponse(200, body);
  } catch (error) {
    console.log(
      "Do your custom error handling here. I am just gonna log it: ",
      error
    );

    return buildResponse(500, "Internal Server Error");
  }
}

async function deleteProduct(productId) {
  const params = {
    TableName: dynamodbTableName,
    Key: {
      productId: productId,
    },
    ReturnValues: "ALL_OLD",
  };
  return await dynamodb
    .delete(params)
    .promise()
    .then(
      (response) => {
        const body = {
          Operation: "DELETE",
          Message: "SUCCESS",
          Item: response,
        };
        return buildResponse(200, body);
      },
      (error) => {
        console.log(
          "Do your custome error handling here. I am just gonna log it: ",
          error
        );
      }
    );
}

function buildResponse(statusCode, body) {
  return {
    statusCode: statusCode,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  };
}
