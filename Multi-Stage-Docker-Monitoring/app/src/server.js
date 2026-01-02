const express = require("express");
const client = require("prom-client");

const app = express();
const PORT = process.env.PORT || 3000;
const APP_ENV = process.env.APP_ENV || "dev";

client.collectDefaultMetrics();

const httpCounter = new client.Counter({
  name: "http_requests_total",
  help: "Total HTTP requests",
  labelNames: ["method", "route", "status"]
});

app.use((req, res, next) => {
  res.on("finish", () => {
    httpCounter.labels(req.method, req.path, res.statusCode).inc();
  });
  next();
});

app.get("/", (req, res) => {
  res.json({ status: "OK", environment: APP_ENV });
});

app.get("/health", (req, res) => res.send("healthy"));

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(PORT, () =>
  console.log(`App running on port ${PORT}`)
);
