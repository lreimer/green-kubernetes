# AWS specific variables
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION ?= eu-north-1

GITHUB_USER ?= lreimer

# https://app.electricitymaps.com/map?lang=de
# https://cloud.google.com/compute/docs/regions-zones?hl=de#available
GCP_PROJECT ?= cloud-native-experience-lab
GCP_REGION ?= europe-north1
GCP_ZONE ?= europe-north1-b

prepare-gke-cluster:
	@gcloud config set compute/region europe-west1
	@gcloud config set compute/zone europe-west1-b
	@gcloud config set container/use_client_certificate False

create-gke-cluster:
	@gcloud container clusters create green-gke-k8s \
		--release-channel=regular \
		--cluster-version=1.26 \
		--region=$(GCP_REGION) \
		--addons HttpLoadBalancing,HorizontalPodAutoscaling \
		--workload-pool=$(GCP_PROJECT).svc.id.goog \
		--num-nodes=1 \
		--min-nodes=1 --max-nodes=5 \
		--enable-autoscaling \
		--autoscaling-profile=optimize-utilization \
		--enable-vertical-pod-autoscaling \
		--machine-type=e2-medium \
		--image-type=UBUNTU_CONTAINERD \
		--logging=SYSTEM \
    	--monitoring=SYSTEM
	@kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@kubectl cluster-info

bootstrap-gke-flux2:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=green-kubernetes \
		--branch=main \
		--path=./clusters/green-gke-k8s \
		--read-write-key \
		--personal

create-eks-cluster:
	@eksctl create cluster -f green-eks-k8s.yaml

bootstrap-eks-flux2:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=green-kubernetes \
		--branch=main \
		--path=./clusters/green-eks-k8s \
		--read-write-key \
		--personal

delete-clusters: delete-eks-cluster delete-gke-cluster

delete-eks-cluster:
	@eksctl delete cluster --region=eu-north-1 --name=green-eks-k8s
	@aws cloudformation delete-stack --region eu-central-1 --stack-name eksctl-green-eks-k8s-cluster

delete-gke-cluster:
	@gcloud container clusters delete green-gke-k8s --region=$(GCP_REGION) --async --quiet
