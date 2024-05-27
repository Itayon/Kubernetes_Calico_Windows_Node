## Différente information de config

### Localisation fichier de conf

### Commande utile

- Voir les nodes disponible sur le cluster
```bash
kubectl get nodes
```

- Voir les pods disponible sur le cluster
```bash
kubectl get pods
```

- Connaitre les information d'une pods ou d'une nodes
```bash
kubectl describle pods/(nom de la pods)
kubectl describle node/(nom de la node)
```

- Lancer un pods depuis un fichier yaml
```bash
kubectl apply -f (nom du fichier).yaml
```

- Voir toute les pods disponible sur le cluster
```bash
kubectl get pods --all-namespaces
```
