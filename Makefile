K8S_DIRECTORY=`pwd`
PROM_DIRECTORY="$(K8S_DIRECTORY)/prometheus-deployment"
docker_repo="gcr.io/ardent-turbine-289005"

build: #docker build commands here
	sudo docker build -t "$(docker_repo)/process_exporter:latest" "$(K8S_DIRECTORY)"
	sudo docker push $(docker_repo)/process_exporter:latest

deploy:
	#create k8 resources
	kubectl create ns monitoring

	#create prometheus resources
	kubectl create -f $(PROM_DIRECTORY)/prometheus/clusterRole.yaml
	kubectl create -f $(PROM_DIRECTORY)/prometheus/configmap.yaml
	kubectl create -f $(PROM_DIRECTORY)/prometheus/deployment.yaml
	kubectl create -f $(PROM_DIRECTORY)/prometheus/service.yaml

	#create process-exporter resources
	kubectl create -f $(PROM_DIRECTORY)/process-exporter/daemonset.yaml
	kubectl create -f $(PROM_DIRECTORY)/process-exporter/service.yaml

	#create alertmanager resources
	kubectl create -f $(PROM_DIRECTORY)/alertmanager/configmap.yaml
	kubectl create -f $(PROM_DIRECTORY)/alertmanager/deployment.yaml
	kubectl create -f $(PROM_DIRECTORY)/alertmanager/service.yaml

	#create grafana resources
	kubectl create -f $(PROM_DIRECTORY)/grafana/configmap.yaml
	kubectl create -f $(PROM_DIRECTORY)/grafana/deployment.yaml
	kubectl create -f $(PROM_DIRECTORY)/grafana/service.yaml


clean:
	#remove grafana
	kubectl delete svc grafana -n monitoring
	kubectl delete deployment grafana -n monitoring
	kubectl delete configmap grafana-config -n monitoring

	#remove alertmanager
	kubectl delete svc alertmanager -n monitoring
	kubectl delete deployment alertmanager -n monitoring
	kubectl delete configmap alertmanager-config -n monitoring

	#remove process-exporter
	kubectl delete svc process-exporter -n monitoring
	kubectl delete daemonset process-exporter -n monitoring
	
	#remove prometheus
	kubectl delete svc prometheus-service -n monitoring
	kubectl delete deployment prometheus-deployment -n monitoring
	kubectl delete configmap prometheus-server-conf -n monitoring

	#remove cluster-role
	kubectl delete clusterrole prometheus
	kubectl delete clusterrolebinding prometheus

	#remove namespace
	kubectl delete namespace monitoring

	