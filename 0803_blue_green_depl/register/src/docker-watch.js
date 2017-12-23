import Docker from "dockerode"
import get from "object-get"
import Promise from "bluebird"
import Etcd from "node-etcd"


const { DEBUG, ETCD_HOST, TTL } = process.env

console.log = DEBUG === "true" ? console.log : function(){}

const etcd = new Etcd(ETCD_HOST || "etcd")
const dockerClient = new Docker({socketPath: '/var/run/docker.sock'})
const docker = Promise.promisifyAll(dockerClient, {suffix: "Async"})

export default function syncContainers() {
  return docker.listContainersAsync({all: false})
    .map(container => Promise.promisifyAll(docker.getContainer(container.Id)))
    .map(container => container.inspectAsync())
    .map((data) => {
      const id = data.Id
      const env = get(data, "Config.Env")
      const DNSHost = data.Name ? data.Name.split("/").pop() : null
      const color = getEnv(env, "SERVICE_COLOR")
      const virtualHostsString = getEnv(env, "SERVICE_VIRTUAL_HOST")
      const virtualHosts = virtualHostsString ? virtualHostsString.split(",") : []
      const certsString = getEnv(env, "SERVICE_CERTS")
      const certs = certsString ? certsString.split(",") : []
      const tagsString = getEnv(env, "SERVICE_TAGS")
      const tags = tagsString ? tagsString.split(",") : []
      const port = getEnv(env, "SERVICE_PORT")
      const name = getEnv(env, "SERVICE_NAME")
      console.log(DNSHost, name, port, virtualHosts)
      if (!DNSHost) {
        return console.log(`Skipping ${DNSHost}: no host`)
      }

      if (!name) {
        return console.log(`Skipping ${name}: no SERVICE_NAME`)
      }

      if (!port) {
        return console.log(`Skipping ${data.Name}: no SERVICE_PORT`)
      }

      if (!virtualHosts.length) {
        return console.log(`Skipping ${data.Name}: no SERVICE_VIRTUAL_HOST`)
      }

      tags.forEach((tag) => {
        tag = tag.split(":")
        etcd.set(`services/${name}/tags/${tag[0]}`, tag[1], {ttl: TTL || 30, maxRetries: 0})
      })

      virtualHosts.forEach((host, i) => {
        etcd.set(`services/${name}/hosts/${host}/upstream/${color}/${id}`, `${DNSHost}:${port}`, {ttl: TTL || 30, maxRetries: 0})

        if (certs[i]) {
          etcd.set(`services/${name}/hosts/${host}/ssl`, true, {ttl: TTL || 30, maxRetries: 0})
          etcd.set(`services/${name}/hosts/${host}/cert`, certs[i], {ttl: TTL || 30, maxRetries: 0})
        }
      })

      console.log(`Registering ${data.Name}`)
    })
    .catch(err => console.log("ERROR", err))
}

function getEnv(envs, key) {
  if (!envs || !envs.length) { return null }
  const search = new RegExp(`^${key}`)

  return envs.filter(env => search.exec(env))
    // comes in as SOME_ENV=someval
    // keep anything after the first =
    .map((env) => env.split("=").splice(1).join("="))[0]
}
