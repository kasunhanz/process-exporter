package main

import (
	"fmt"
	"os/exec"
	"strconv"

	"github.com/prometheus/client_golang/prometheus"
)

//Define a struct for you collector that contains pointers
//to prometheus descriptors for each metric you wish to expose.
//Note you can also include fields of other types if they provide utility
//but we just won't be exposing them as metrics.
type processCollector struct {
	listeningProcessesMetric *prometheus.Desc
}

//You must create a constructor for you collector that
//initializes every descriptor and returns a pointer to the collector
func newProcessCollector() *processCollector {
	return &processCollector{
		listeningProcessesMetric: prometheus.NewDesc("listening_processes_count",
			"Number of Listening Processes in a given node",
			nil, nil,
		),
	}
}

//Each and every collector must implement the Describe function.
//It essentially writes all descriptors to the prometheus desc channel.
func (collector *processCollector) Describe(ch chan<- *prometheus.Desc) {

	//Update this section with the each metric you create for a given collector
	ch <- collector.listeningProcessesMetric
}

//Collect implements required collect function for all prometheus collectors
func (collector *processCollector) Collect(ch chan<- prometheus.Metric) {

	//Implement logic here to determine proper metric value to return to prometheus
	//for each descriptor or call other functions that do so.
	//prometheus metric supports only float64
	var metricValue float64

	metricValue = float64(getListeningProcesses())

	//Write latest value for each metric in the prometheus metric channel.
	//Note that you can pass CounterValue, GaugeValue, or UntypedValue types here.
	ch <- prometheus.MustNewConstMetric(collector.listeningProcessesMetric, prometheus.CounterValue, metricValue)
	//ch <- prometheus.MustNewConstMetric(collector.barMetric, prometheus.CounterValue, metricValue2)

}

func getListeningProcesses() int {

	var out []byte
	var err error
	var output string

	//get all listening processes from lsof command
	out, err = exec.Command("sh", "-c", "lsof -i -n | egrep 'LISTEN' | wc -l | tr -d '\n'").Output()
	if err != nil {
		fmt.Printf("%s", err)
	}
	fmt.Println("lsof Command Successfully Executed")

	output = string(out[:])

	intVar, err := strconv.Atoi(output)

	if err != nil {
		fmt.Printf("%s", err)
	}
	//fmt.Println(intVar, err, reflect.TypeOf(intVar))

	fmt.Println(intVar)

	return intVar
}
