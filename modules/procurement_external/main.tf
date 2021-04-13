



apiVersion: v1
kind: Service
metadata:
  name: web-api
spec:
  selector:
    name: web-api
  ports:
  - name: "8080"
    port: 8080
    targetPort: 8080
status:
  loadBalancer: {}

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.component5 }}
spec:
  selector:
    matchLabels:
      name: web-api
  replicas: {{ .Values.component5_replicas }}
  template:
    metadata:
      labels:
        name: web-api
        tier-name: web-api-tier
        application-name: OS-App
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 2000
      serviceAccountName: appdynamics-cluster-agent
      containers:
        - name: {{ .Values.component5 }}
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
