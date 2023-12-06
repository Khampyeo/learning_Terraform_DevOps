const express = require("express");
const app = require("./src/index");

const port = 3000;

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
