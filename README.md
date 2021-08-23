# process_exporter custom prometheus metric exporter with Prometheus core components
This project consist with k8s manifests to deploy prometheus core components (Prometheus,AlertManager and Grafana) and a custom prometheus exporter written in Golang to list listening processes on Linux nodes

## Installation and Usage of process_exporter

process_exporter will listen on HTTP port 8080 by default

Build binary using go

```sh
go mod download
go build -o process_exporter
./process_exporter
```

Pre-requisite to build docker image, make sure you have logged into docker repo

Docker build
```sh
docker build -t <you_repo>/process_exporter:latest .
```
or
update docker_repo parameter in Makefile and run
```sh
make build
```
Docker run
> Special privileges required to get the host network metrics from docker container. Hence container will required to run
 with extended privileges using below docker arguments
`--network=host --pid=host --privileged`
```sh
docker run -d --network=host --pid=host --privileged <you_repo>/process_exporter:latest
```

## Prometheus, Alertmanager, Grafana and process_exporter deployment on K8s

All k8s manifests resides on `prometheus-deployment` under below folders

| Resource | Path |
| ------ | ------ |
| prometheus | [prometheus/clusterRole.yaml][PlDa]|
|  |[prometheus/configmap.yaml][PlDb]
|  |[prometheus/deployment.yaml][PlDc]
|  |[prometheus/service.yaml][PlDd]
| alertmanager |[alertmanager/configmap.yaml][PlDe]
|  |[alertmanager/deployment.yaml][PlDf]
|  |[alertmanager/service.yaml][PlDg]
| grafana |[grafana/configmap.yaml][PlDh]
|  |[grafana/deployment.yaml][PlDi]
|  |[grafana/service.yaml][PlDj]
| process-exporter |[process-exporter/daemonset.yaml][PlDk]
|  |[process-exporter/service.yaml][PlDl]

k8s deployment of all resources at once

```sh
make deploy
```

k8s remove all resources

```sh
make destroy
```

k8s deploy / update individual resources

```sh
make deploy-ns - #create k8 namespace
make deploy-prometheus - #create/update prometheus resources
make deploy-alertmanager - #create/update alertmanager resources
make deploy-grafana - #create/update process-exporter resources
make deploy-exporter - #create/update process-exporter resources
```

By default, each of below services will run on below ports accessible through deployed k8s node. (Services are exposed using nodePort for demo purpose)
`prometheus <node_ip>:30000`
`alertmanager <node_ip>:31000`
`grafana <node_ip:32000>`

Prometheus is configured with default alert rule to alert if `listening_processes_count{job="process-exporter"} > 18`
Alerts are configured with slack integration

Grafana deployement is pre-provisioned with prometheus datasource and dashbaord using configmap

   [PlDa]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/prometheus/clusterRole.yaml>
   [PlDb]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/prometheus/configmap.yaml>
   [PlDc]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/prometheus/deployment.yaml>
   [PlDd]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/prometheus/service.yaml>
   [PlDe]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/alertmanager/configmap.yaml>
   [PlDf]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/alertmanager/deployment.yaml>
   [PlDg]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/alertmanager/service.yaml>
   [PlDh]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/grafana/configmap.yaml>
   [PlDi]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/grafana/deployment.yaml>
   [PlDj]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/grafana/service.yaml>
   [PlDk]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/process-exporter/daemonset.yaml>
   [PlDl]: <https://github.com/kasunhanz/process-exporter/blob/main/prometheus-deployment/process-exporter/service.yaml>
