




apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.component1 }}
spec:
  selector:
    matchLabels:
      name: client-api
  replicas: {{ .Values.component1_replicas }}
  template:
    metadata:
      labels:
        name: client-api
        tier-name: client-api-tier
        application-name: OS-App
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 2000
      serviceAccountName: appdynamics-cluster-agent
      containers:
        - name: {{ .Values.component1 }}
          image: sashaz/java-services:v5
          imagePullPolicy: IfNotPresent
          resources:
            limits:
              cpu: 200m
              memory: 900M
            requests:
              cpu: 100m
              memory: 600M
          ports:
          - containerPort: 8080
      restartPolicy: Always






apiVersion: v1
kind: Service
metadata:
  name: client-api
spec:
  selector:
    name: client-api
  ports:
  - name: "8080"
    port: 8080
    targetPort: 8080
status:
  loadBalancer: {}
