const express = require("express");
const cors = require("cors");

const app = express();

const { routes: useRoutes } = require("./user/route");

app.use(cors());
app.use(express.json());
app.use("/user", useRoutes);

module.exports = app;
