var express = require("express");

express()
 .get("*", function(req, res) {
    res.send("API V2");
 })
 .listen(3000)
