# Example: https://learn.hashicorp.com/tutorials/nomad/jobs-submit#author-a-job-file
job "docs" {
  datacenters = ["dc1"]

  group "example" {
    network {
      port "http" {
        static = "8080"
      }
    }
    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":8080",
          "-text",
          "hello world",
        ]
      }
    }
  }
}

