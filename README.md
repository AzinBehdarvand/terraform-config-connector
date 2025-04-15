# 🌐 Terraform + GKE Autopilot + Config Connector + OPA

This project demonstrates how to provision and secure Google Cloud resources using:

- ✅ **Google Kubernetes Engine (GKE) Autopilot**
- ✅ **Terraform** for infrastructure provisioning
- ✅ **Config Connector** to manage GCP resources from Kubernetes
- ✅ **Open Policy Agent (OPA)** for policy validation and compliance enforcement

---

## 🧰 Technologies Used

| Tool / Technology        | Purpose                                             |
|--------------------------|-----------------------------------------------------|
| **Terraform**            | Provisioning GKE and service account               |
| **GKE Autopilot**        | Fully managed Kubernetes with built-in scaling     |
| **Config Connector**     | Manage GCP resources via Kubernetes CRDs           |
| **Open Policy Agent (OPA)** | Evaluate custom policies on GCP resource specs |

---

## 🚀 Workflow Overview

### 1. Provision GKE Autopilot Cluster with Terraform

```bash
terraform init
terraform apply

#Terraform enables GCP APIs and provisions a GKE Autopilot cluster.

2. Install Config Connector on GKE
gcloud storage cp gs://configconnector-operator/latest/release-bundle.tar.gz .
tar zxvf release-bundle.tar.gz
kubectl apply -f operator-system/autopilot-configconnector-operator.yaml

3. Create Service Account & Bind Permissions (via Terraform)
terraform apply
#Then create a ConfigConnectorContext to link the GKE cluster with the service account:
# kcc-context.yaml
apiVersion: core.cnrm.cloud.google.com/v1beta1
kind: ConfigConnectorContext
metadata:
  name: configconnectorcontext.core.cnrm.cloud.google.com
  namespace: configconnector-operator-system
spec:
  googleServiceAccount: config-connector@training-platform-engineer.iam.gserviceaccount.com

4. Install Required CRDs (StorageBucket)
kubectl apply -f crd-storagebucket.yaml

5. Create GCS Bucket via Kubernetes
# k8s/bucket.yaml
apiVersion: storage.cnrm.cloud.google.com/v1beta1
kind: StorageBucket
metadata:
  name: demo-kcc-bucket
spec:
  location: EU
  uniformBucketLevelAccess: true

kubectl apply -f k8s/bucket.yaml

6. Enforce Policy with OPA
# policy/bucket-policy.rego
package validate.gcp.storage

deny[msg] if {
  input.kind.kind == "StorageBucket"
  not input.spec.location
  msg := "Bucket location must be set"
}

deny[msg] if {
  input.kind.kind == "StorageBucket"
  input.spec.location != "EU"
  msg := "Bucket location must be 'EU'"
}

#Export the Bucket as input:
kubectl get storagebucket demo-kcc-bucket -o json > tfplan.json
#Evaluate the policy:
opa eval --input tfplan.json --data policy/ --format pretty "data.validate.gcp.storage.deny"

#✅ If the result is [], the resource complies with your policy.



📁 Project Structure
terraform-config-connector/
├── main.tf
├── service-account.tf
├── kcc-context.yaml
├── crd-storagebucket.yaml
├── tfplan.json
├── policy/
│   └── bucket-policy.rego
├── k8s/
│   └── bucket.yaml
└── README.md

