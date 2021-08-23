.PHONY: deploy deploy-ns deploy-prometheus deploy-alertmanager deploy-exporter deploy-grafana

K8S_DIRECTORY=`pwd`
PROM_DIRECTORY="$(K8S_DIRECTORY)/prometheus-deployment"
docker_repo="gcr.io/ardent-turbine-289005"

build: #docker build commands here
	sudo docker build -t "$(docker_repo)/process_exporter:latest" "$(K8S_DIRECTORY)"
	sudo docker push $(docker_repo)/process_exporter:latest

deploy-ns:
	#create k8 resources
	kubectl create ns monitoring
deploy-prometheus:
	#create prometheus resources
	kubectl apply -f $(PROM_DIRECTORY)/prometheus/ --recursive

deploy-alertmanager:
	#create alertmanager resources
	kubectl apply -f $(PROM_DIRECTORY)/alertmanager/ --recursive

deploy-exporter:
	#create process-exporter resources
	kubectl apply -f $(PROM_DIRECTORY)/process-exporter/ --recursive

deploy-grafana:
	#create process-exporter resources
	kubectl apply -f $(PROM_DIRECTORY)/grafana/ --recursive

deploy: deploy-ns deploy-prometheus deploy-alertmanager deploy-exporter deploy-grafana


destroy:
	#remove grafana
	kubectl delete -f $(PROM_DIRECTORY)/grafana/ --recursive

	#remove alertmanager
	kubectl delete -f $(PROM_DIRECTORY)/alertmanager/ --recursive

	#remove process-exporter
	kubectl delete -f $(PROM_DIRECTORY)/process-exporter/ --recursive
	
	#remove prometheus
	kubectl delete -f $(PROM_DIRECTORY)/prometheus/ --recursive

	#remove namespace
	kubectl delete namespace monitoring

	