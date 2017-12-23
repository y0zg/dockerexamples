var express = require("express");

express()
 .get("*", function(req, res) {
    res.send("Blue Deployment");
 })
 .listen(3000)
