# Green Kubernetes

Showcase repository to demonstrate sustainability projects for Kubernetes.

## Setup

```bash
export GITHUB_USER=lreimer
export GITHUB_TOKEN=

# for the GKE cluster setup
make create-gke-cluster
make bootstrap-gke-flux2

kubectl edit service kube-prometheus-stack-grafana -n monitoring
export GRAFANA_HOSTNAME=`kubectl get service kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"`

kubectl edit service goldilocks-dashboard -n goldilocks
export GOLDILOCKS_IP=`kubectl get service goldilocks-dashboard -n goldilocks -o jsonpath="{.status.loadBalancer.ingress[0].ip}"`

# for the EKS cluster setup
make create-eks-cluster
make bootstrap-eks-flux2

kubectl edit service kube-prometheus-stack-grafana -n monitoring
export GRAFANA_HOSTNAME=`kubectl get service kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"`
```

## Cluster Planning

Location + Node Types (CPU Arch)


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
open http://$GOLDILOCKS_IP:80
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

## Carbon Aware Scaling with Keda

- https://github.com/Azure/carbon-aware-keda-operator
- Watt Time 

## Kepler

Kepler (Kubernetes-based Efficient Power Level Exporter) uses eBPF to probe energy related system stats and exports as Prometheus metrics.

```bash
# the installation via Helm chart works, but is somewhat incomplete / outdated
# instead, the installation from source via YAML should be used
# only working on AWS, on GKE instances some host volumes can't be mounted

git clone https://github.com/sustainable-computing-io/kepler.git
cd kepler
make build-manifest OPTS="ESTIMATOR_SIDECAR_DEPLOY PROMETHEUS_DEPLOY MODEL_SERVER_DEPLOY"
kubectl apply -f _output/generated-manifest/deployment.yaml

kubectl get all -n kepler
```

## Prometheus Custom Metrics and HPA

_TODO_

## References

- Cloud Native Sustainabilty Roadmap
- https://www.techtarget.com/searchitoperations/feature/How-to-approach-sustainability-in-IT-operations
- https://www.redhat.com/en/blog/how-kepler-project-working-advance-environmentally-conscious-efforts

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.
