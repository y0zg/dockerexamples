var Etcd = require("node-etcd");

var options = {ttl: 10, maxRetries: 0};

var etcd = new Etcd("etcd");

register()
setInterval(function() {
  register()
}, 5000)

function register() {
  etcd.set("services/web/host", "test.com", options)
  etcd.set("services/web/port", 3000, options)
  etcd.set("services/web/upstream/", options)
  etcd.set("services/web/upstream/" + process.env.HOSTNAME, true, options)
}
