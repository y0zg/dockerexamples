var express = require("express");

express()
  .get("*",function(req, res) {
    res.send("Hello World");
  })
  .listen(3000, function(err) {
    if (err) {
      console.error(err);
      return;
    }
    console.log("Server 3000 port litening");
    })
;
