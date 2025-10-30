### Full structure of project

```
┌─────────────────┐
│   Git Push      │
│  (Developer)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Tekton         │
│  Pipeline       │
│  Triggered      │
└────────┬────────┘
         │
         ├──► Build Image
         ├──► Push to Registry
         ├──► Update dev/deployment-patch.yaml
         └──► Update qa/deployment-patch.yaml
                │
                ▼
         ┌──────────────┐
         │  Git Commit  │
         │  & Push      │
         └──────┬───────┘
                │
                ▼
         ┌──────────────────────┐
         │   ArgoCD Detects     │
         │   Changes (3 min)    │
         └──────┬───────────────┘
                │
                ├──► Deploy to dev (1 replica)
                └──► Deploy to qa (3 replicas)

### Project components           
###### 1. GitHub Webhook → Tekton Trigger

***

File: krci_event_listener.yaml

EventListener receives an HTTP POST request from GitHub (push event).

The tekton-triggers-sa service processes it and launches the github-push-trigger trigger.

📜 test.sh used locally to emulate a webhook:

bash test.sh

###### 2. Tekton Trigger System

File: krci_trigger.yaml

Defines which trigger will fire when an event is received:

Processes the GitHub webhook.

Checks that the push was to the main branch.

Extracts parameters (repo_url, commit_id, image, etc.) to pass to the pipeline.

krci_trigger_binding.yaml

Passes parameters from the webhook body to the template:

repo-url, revision, branch

Docker image name with commit_id and latest tags

krci_trigger_template.yaml

Creates PipelineRun, passing parameters to the app-ci-pipeline pipeline.

##### 3. Tekton Pipeline (CI)

File: krci_pipeline.yaml

Main tasks:

🧹 clean-source / clean-manifests — cleaning the workspace.

📥 clone-app-repo / clone-manifests — cloning source code and manifests.

🏗️ build — building and publishing a Docker image to DockerHub.

🧩 update-dev / update-qa — updating deployment-patch.yaml for two environments (dev, qa) with a new image tag.

🔁 git push — committing changes back to the manifests repository.

Result:
ArgoCD notices updates in the manifests repository and automatically updates the applications.

##### 4. PersistentVolumeClaims

krci_pvc.yaml — workspace for application source code.

krci_manifest_pvc.yaml — workspace for manifest repository.

Tekton uses PVC to store data between pipeline tasks.

##### 5. Service Account and RBAC

Files:

krci_service-account.yaml

krci_role_rolebinding.yaml

Provide:

Tekton Triggers access to create PipelineRun.

Secure execution of all tasks with namespace-restricted permissions.

##### 6. ArgoCD (CD)

After completing the ArgoCD CI pipeline:

Detects commits in the manifests repository.

Automatically synchronizes the cluster state.

Deploys the application in two environments:

dev → 1 replica

qa → 3 replicas

replicas

🧠 How it works step by step

Step    Description

1    Developer performs git push to GitHub
2    GitHub Webhook calls Tekton EventListener
3    Tekton Trigger launches PipelineRun
4    Pipeline builds Docker image and pushes to DockerHub
5	 Kubernetes manifests (deployment-patch.yaml) are updated
6    Changes are committed to the manifests repository
7    ArgoCD notices the update and applies the new versions to the cluster

🐳 Environment	Image Example

dev	elpaso5701/gitops_demo:latest
qa	elpaso5701/gitops_demo:f1eb375

🧰 Requirements

Kubernetes cluster (e.g., Minikube)

Tekton Pipelines + Tekton Triggers

ArgoCD

DockerHub account

GitHub repositories:

GitOps_demo (application code)

manifests (Kubernetes manifests)