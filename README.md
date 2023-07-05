# Green Kubernetes

Showcase repository to demonstrate sustainability projects for Kubernetes.

## Kepler

## Rightsizing with Vertical Pod Autoscaler

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

## Cluster Autoscaling with Karpenter

see https://karpenter.sh/v0.27.3/getting-started/getting-started-with-karpenter/

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.
