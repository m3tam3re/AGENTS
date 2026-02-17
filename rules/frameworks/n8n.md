# n8n Workflow Automation Rules

## Workflow Design
- Start with a clear trigger: Webhook, Schedule, or Event source
- Keep workflows under 20 nodes for maintainability
- Group related logic with sub-workflows
- Use the "Switch" node for conditional branching
- Add "Wait" nodes between rate-limited API calls

## Node Naming
- Use verb-based names: `Fetch Users`, `Transform Data`, `Send Email`
- Prefix data nodes: `Get_`, `Set_`, `Update_`
- Prefix conditionals: `Check_`, `If_`, `When_`
- Prefix actions: `Send_`, `Create_`, `Delete_`
- Add version suffix to API nodes: `API_v1_Users`

## Error Handling
- Always add an Error Trigger node
- Route errors to a "Notify Failure" branch
- Log error details: `$json.error.message`, `$json.node.name`
- Send alerts on critical failures
- Add "Continue On Fail" for non-essential nodes

## Data Flow
- Use "Set" nodes to normalize output structure
- Reference previous nodes: `{{ $json.field }}`
- Use "Merge" node to combine multiple data sources
- Apply "Code" node for complex transformations
- Clean data before sending to external APIs

## Credential Security
- Store all secrets in n8n credentials manager
- Never hardcode API keys or tokens
- Use environment-specific credential sets
- Rotate credentials regularly
- Limit credential scope to minimum required permissions

## Testing
- Test each node independently with "Execute Node"
- Verify data structure at each step
- Mock external dependencies during development
- Log workflow execution for debugging
