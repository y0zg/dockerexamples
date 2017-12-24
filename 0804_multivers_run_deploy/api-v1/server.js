var express = require("express");

express()
 .get("*", function(req, res) {
    res.send("API V1");
 })
 .listen(3000)
