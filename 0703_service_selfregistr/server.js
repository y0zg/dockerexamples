var express = require("express");
require("./register");

express()
 .get("*", function(req, res) {
    res.send("Hello There");
 })
 .listen(3000, function(err) {
    if (err) {
      console.error(err);
      return;
    }

    console.log("Express Server listening on port 3000");
  })
;
