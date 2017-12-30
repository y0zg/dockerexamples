var express = require("express");

express()
 .get("*", function(req, res) {
    res.send("Hello World");
 })
 .listen(3000)
