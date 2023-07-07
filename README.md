# Green Kubernetes

Showcase repository to demonstrate sustainability projects for Kubernetes.

## Setup

```bash
# for the GKE setup
export GITHUB_USER=lreimer
export GITHUB_TOKEN=

make create-gke-cluster
make bootstrap-gke-flux2

kubectl edit service kube-prometheus-stack-grafana -n monitoring
kubectl edit service goldilocks-dashboard -n goldilocks


```

## Kepler

## Workload Rightsizing with VPA and Goldilocks

```bash
# explicitly enable goldilocks for the default namespace
kubectl label ns default goldilocks.fairwinds.com/enabled=true

# create resource and the VPA in recommender mode
kubectl apply -f vpa/hamster.yaml
kubectl apply -f vpa/vpa.yaml

# display the container recommendations for CPU and memory
kubectl describe vpa hamster-vpa

# use Goldilocks dashboard to display recommendations
kubectl get service goldilocks-dashboard -n goldilocks
kubectl get service goldilocks-dashboard -n goldilocks -o json | jq '.status.loadBalancer.ingress[0].ip'
open http://<<INSERT_IP_HERE>>:80
```

## kube-green

Don't waste resources! Many workloads on dev/qa environments stay running during weekends,
non working hours or at night. _kube-green_ is a simple K8s addon to automatically shutdown
and restart resources based on when they are needed (or not).

```yaml
apiVersion: kube-green.com/v1alpha1
kind: SleepInfo
metadata:
  name: non-working-hours
spec:
  weekdays: "1-5"
  sleepAt: "18:00"
  wakeUpAt: "08:00"
  timeZone: "Europe/Rome"
  suspendCronJobs: true
  excludeRef:
    - apiVersion: "apps/v1"
      kind:       Deployment
      name:       no-sleep-deployment
    - matchLabels: 
        kube-green.dev/exclude: "true"
```

To see some details when the above `SleepInfo` resource will be schedules next, you can have
a look at the log output from the _kube-green-controller-manager_ pod.
```bash
kubectl logs pod/kube-green-controller-manager-5855848d7f-dftxd -n kube-green
```

## Cluster Rightsizing

Depending on the Cloud provider there are different options to autoscale and thus rightsize the cluster itself, so that the number of nodes is sufficient to handle the current load but not more.

```bash
# to trigger and watch a cluster ScaleUp
kubectl scale deployment inflate --replicas 5
kubectl get pods
kubectl describe pod inflate-644ff677b7-jgw8r
kubectl events
kubectl get nodes -w

# to trigger and watch a cluster ScaleDown
kubectl scale deployment inflate --replicas 0
kubectl get pods
kubectl events
kubectl get nodes -w
```

### Google GKE with Cluster Autoscaler

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

### AWS EKS with Karpenter

Karpenter automatically provisions new nodes in response to unschedulable pods. Karpenter does this by observing events within the Kubernetes cluster, and then sending commands to the underlying cloud provider. Currently, only EKS on AWS is supported. See https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/

To easily install EKS with Karpenter, the `eksctl` tool can be used because it brings Karpenter support. See https://eksctl.io/usage/eksctl-karpenter/

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.
