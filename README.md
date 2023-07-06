# Green Kubernetes

Showcase repository to demonstrate sustainability projects for Kubernetes.

## Kepler

## Workload Rightsizing with VPA and Goldilocks

```bash
kubectl apply -f vpa/hamster.yaml
kubectl apply -f vpa/vpa.yaml
kubectl describe vpa hamster-vpa

helm repo add fairwinds-stable https://charts.fairwinds.com/stable
kubectl create namespace goldilocks
helm install goldilocks --namespace goldilocks fairwinds-stable/goldilocks

kubectl edit service goldilocks-dashboard -n goldilocks
kubectl label ns default goldilocks.fairwinds.com/enabled=true
```

## kube-green

## Cluster Rightsizing

Depending on the Cloud provider there are different options to autoscale and thus rightsize the cluster itself, so that the number of nodes is sufficient to handle the current load but not more.

### GKE with Cluster Autoscaler

```bash
# create GKE cluster using gcloud CLI
gcloud container clusters create green-gke-k8s ... \
    # enable GKE addons such as HPA support
	--addons HttpLoadBalancing,HorizontalPodAutoscaling \
    
    # enable VPA support
	--enable-vertical-pod-autoscaling \

    # enable cluster autoscaling
    # use profile for moderate (Balanced) or aggessive (Optimize-utilization) mode
	--enable-autoscaling \
	--autoscaling-profile=optimize-utilization \
    
    # specify initial node pool size and scaling limits
	--num-nodes=1 \
	--min-nodes=1 --max-nodes=5 \
    
    # Ampere Altra Arm-Prozessor
    # currently only available in certain regions
    # see https://cloud.google.com/compute/docs/regions-zones?hl=de#available
    --machine-type=t2a-standard-4
```

### AWS with Karpenter

see https://karpenter.sh/v0.27.3/getting-started/getting-started-with-karpenter/

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.
