## Different configuration information

### Conf file localization

### Commande

- View nodes available on the cluster
```bash
kubectl get nodes
```

- View pods available on the cluster
```bash
kubectl get pods
```

- Pod and node information
```bash
kubectl describle pods/(pod name)
kubectl describle node/(node name)
```

- Launching a pod from a yaml file
```bash
kubectl apply -f (file name).yaml
```

- View all pods available on the cluster
```bash
kubectl get pods --all-namespaces
```
