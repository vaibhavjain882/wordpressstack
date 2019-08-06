locals {
  albingcontroller = <<ALBING

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: alb-ingress-controller
  name: alb-ingress-controller
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alb-ingress-controller
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: alb-ingress-controller
    spec:
      containers:
        - args:
            - /server
            - --ingress-class=alb
            - --cluster-name=${lookup(var.vpc, "name")}
          env:
            - name: AWS_REGION
              value: eu-west-1
            - name: AWS_ACCESS_KEY_ID
              value: <AWS_ACCESS_KEY>
            - name: AWS_SECRET_ACCESS_KEY
              value: <AWS_SECRET_KEY>
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
          image: quay.io/coreos/alb-ingress-controller:1.0-beta.7
          imagePullPolicy: Always
          name: server
          resources: {}
          terminationMessagePath: /dev/termination-log
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      securityContext: {}
      terminationGracePeriodSeconds: 30
      serviceAccountName: alb-ingress
      serviceAccount: alb-ingress
ALBING
}

locals {
  alb_ing_rbac = <<ALBINGRBAC

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: alb-ingress-controller
  name: alb-ingress-controller
rules:
  - apiGroups:
      - ""
      - extensions
    resources:
      - configmaps
      - endpoints
      - events
      - ingresses
      - ingresses/status
      - services
    verbs:
      - create
      - get
      - list
      - update
      - watch
      - patch
  - apiGroups:
      - ""
      - extensions
    resources:
      - nodes
      - pods
      - secrets
      - services
      - namespaces
    verbs:
      - get
      - list
      - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: alb-ingress-controller
  name: alb-ingress-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: alb-ingress-controller
subjects:
  - kind: ServiceAccount
    name: alb-ingress
    namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: alb-ingress-controller
  name: alb-ingress
  namespace: kube-system
ALBINGRBAC
}
