#!/bin/bash

# Адрес твоего EventListener (замени на свой внешний адрес или localhost:8080 при port-forward)
WEBHOOK_URL="http://localhost:8080"

# Секрет, который ты указал в Tekton (если нужен HMAC, для простоты можно не использовать)
GITHUB_SECRET="mygithubsecret"

# Пример payload (можно изменить под свой TriggerBinding)
read -r -d '' PAYLOAD << EOM
{
  "ref": "refs/heads/main",
  "repository": {
    "clone_url": "https://github.com/Elpaso5701/GitOps_demo.git",
    "full_name": "Elpaso5701/GitOps_demo",
    "name": "gitops_demo"
  },
  "head_commit": {
    "id": "d61aea02dbe0f3184f25b16a8f0efcdc039854b8"
  }
}
EOM

# Отправка запроса (без подписи)
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature: sha1=demo" \
  -d "$PAYLOAD"

echo
