var axios = require("axios");
var Etcd = require("node-etcd");
var etcd = new Etcd("etcd");

var container = process.env.CONTAINER

var options = {ttl: 10, maxRetries: 0};

register()
setInterval(function() {
  register()
}, 5000)

function register() {
  axios.get("http://" + container + ":80")
    .then(function(response) {
      console.log("got it", response)
      etcd.set("services/web/host", "test.com", options)
      etcd.set("services/web/port", 80, options)
      etcd.set("services/web/upstream/", options)
      etcd.set("services/web/upstream/" + container, true, options)
    })
    .catch(function(err) {
      console.log("error", err)
      etcd.del("services/web/host")
      etcd.del("services/web/port")
      etcd.del("services/web/upstream/")
      etcd.del("services/web/upstream/" + container)
    })
}
