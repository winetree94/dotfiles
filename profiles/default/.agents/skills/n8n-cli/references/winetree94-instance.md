# winetree94 n8n Instance

## Connection and CLI

- Instance URL: `https://n8n.winetree94.com`
- CLI path: `~/.local/share/mise/installs/node/24.15.0/bin/n8n-cli`
- The CLI is already configured with the instance URL and API key. Do not print, copy, or persist the API key.

## Opencode Go credential

- Name: `Opencode Go`
- Type: `openAiApi`
- ID: `7VqytVBoQBjkZumJ`

Use this credential ID for workflows that need the Opencode LLM. n8n previously auto-resolved it during workflow creation, but verify the credential still exists before relying on it in a new or updated workflow.

## Chatbot webhook limitation

On this self-hosted instance, `@n8n/n8n-nodes-langchain.chatTrigger` webhooks do not register. Both `/webhook/` and `/webhook-test/` return a 404 response indicating that the webhook is not registered.

For chatbot workflows, use this supported pattern instead:

1. Webhook
2. Basic LLM Chain
3. Respond to Webhook

Do not use Chat Trigger unless live verification shows that webhook registration has been fixed on the instance.
