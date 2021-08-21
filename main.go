package main

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	log "github.com/sirupsen/logrus"
)

func main() {
	//This section will start the HTTP server and expose
	//any metrics on the /metrics endpoint.

	//Create a new instance of the foocollector and
	//register it with the prometheus client.
	processM := newProcessCollector()
	prometheus.MustRegister(processM)

	http.Handle("/metrics", promhttp.Handler())
	log.Info("Beginning to serve on port :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
