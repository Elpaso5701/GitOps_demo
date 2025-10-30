#!/bin/bash


WEBHOOK_URL="http://localhost:8080"

GITHUB_SECRET="mygithubsecret"


read -r -d '' PAYLOAD << EOM
{
  "ref": "refs/heads/main",
  "repository": {
    "clone_url": "https://github.com/Elpaso5701/GitOps_demo.git",
    "full_name": "Elpaso5701/GitOps_demo",
    "name": "gitops_demo"
  },
  "head_commit": {
    "id": "f1eb375fab713ac25576f1899c37ceece7154461"
  }
}
EOM

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature: sha1=demo" \
  -d "$PAYLOAD"


echo
