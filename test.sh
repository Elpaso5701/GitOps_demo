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
    "id": "60c2013c4507880bced634c9cb282797639d720f"
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
