


apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.component4 }}
spec:
  selector:
    matchLabels:
      name: world-generator
  replicas: {{ .Values.component4_replicas }}
  template:
    metadata:
      labels:
        name: world-generator
        tier-name: world-generator-tier
        application-name: OS-App
    spec:
      serviceAccountName: appdynamics-cluster-agent
      containers:
        - name: {{ .Values.component4 }}
          image: sashaz/java-services:v5
          imagePullPolicy: IfNotPresent
          ports:
          - containerPort: 8080
          resources:
            requests:
              memory: "400M"
              cpu: "250m"
            limits:
              memory: "1000M"
              cpu: "500m"
      restartPolicy: Always

---
apiVersion: v1
kind: Service
metadata:
  name: world-generator
spec:
  selector:
    name: world-generator
  ports:
  - name: "8080"
    port: 8080
    targetPort: 8080
status:
  loadBalancer: {}
