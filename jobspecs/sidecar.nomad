# Example: https://www.nomadproject.io/docs/job-specification/connect#connect-stanza
job "countdash" {
  datacenters = ["dc1"]

  group "api" {
    network {
      mode = "bridge"
    }

    service {
      name = "count-api"
      port = "9001"

      connect {
        sidecar_service {}
      }

      check {
        expose   = true
        type     = "http"
        name     = "api-health"
        path     = "/health"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "web" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-api:v3"
      }
    }
  }

  group "dashboard" {
    network {
      mode = "bridge"

      # Bind on port 8000, forward to 9002 for task 'dashboard'
      port "http" {
        static = 8000
        to     = 9002
      }
    }

    service {
      name = "count-dashboard"
      port = "8000"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "count-api"
              local_bind_port  = 8080
            }
          }
        }
      }
    }

    task "dashboard" {
      driver = "docker"

      env {
        COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
      }

      config {
        image = "hashicorpnomad/counter-dashboard:v3"
      }
    }
  }
}

