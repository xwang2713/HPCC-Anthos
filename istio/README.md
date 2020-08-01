#ISTIO Configuration

## Anthos serivce mesh dashboard
Anthos service mesh dashboard in the Cloud Consoel will only work for istio "asm-gcp" profile but not "asm-multiple" profile. Reference "User interface" in Anthos Service Mesh supported feature. Grafana and Kiali are installed and user interfaces can be managed by user.

Default user/password:  admin/admin

### Add additional ports to Istio ingressgateway
```console
kubectl edit -n istio-system svc/istio-ingressgateway
```
Add following ports
```console
  - name: grafana
    nodePort: 30145
    port: 3000
    protocol: TCP
    targetPort: 3000
  - name: kiali
    nodePort: 30146
    port: 20001
    protocol: TCP
    targetPort: 20001
  - name: prometheus
    nodePort: 30147
    port: 9090
    protocol: TCP
    targetPort: 9090
  - name: eclwatch
    nodePort: 30148
    port: 8010
    protocol: TCP
    targetPort: 8010

```
To verify the content:
```console
kubectl get svc -n istio-system istio-ingressgateway -o yaml
```
Or check the service 
```console
kubectl get svc -n istio-system
```
### Get istio-ingressgateway external ip
Get istio-ingressgateway service EXTERAL-IP:
```console
kubectl get svc -n istio-system 
```

### Route Grafana request

```console
kubectl apply -f grafana-gateway.yaml
```
Get istio-ingressgateway service external ip:

Grafana dashboard URL: http://<istio-ingressgateway service external-ip>:3000/dashboard/db/istio-mesh-dashboard

### Route Kiali request
Create a Kiali secret for the first time:
```console
kubectl create secret generic kiali -n istio-system --from-literal=username=admin --from-literal=passphrase=admin
```
```console
kubectl apply -f kiali-gateway.yaml
```

### Route Prometheus request

```console
kubectl apply -f prometheus-gateway.yaml
```
### Route eclwatch request

```console
kubectl apply -f eclwatch-gateway.yaml
```
### istio-ingressgateway ip

```console
kubectl get svc istio-ingressgateway -n istio-system
```


