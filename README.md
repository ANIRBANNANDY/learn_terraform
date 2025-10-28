# learn_terraform

## Credentials

This repository previously contained AWS keys in `main.tf`. Do NOT store real AWS credentials in Terraform files.

Recommended approaches (pick one):

- Use the AWS shared credentials file (recommended for local development). Create the file at `%USERPROFILE%\.aws\credentials` on Windows or `~/.aws/credentials` on Linux/macOS.
- Use environment variables in your shell: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
- Use an IAM role when running from EC2, ECS, or another AWS service.

I've added a template credentials file at `.aws/credentials` in this repo with placeholder values — replace the placeholders with your real keys locally (do NOT commit them).

PowerShell example (set env vars for the current session):

```powershell
$env:AWS_ACCESS_KEY_ID = "YOUR_AWS_ACCESS_KEY_ID"
$env:AWS_SECRET_ACCESS_KEY = "YOUR_AWS_SECRET_ACCESS_KEY"
# optional: AWS_SESSION_TOKEN if using temporary credentials
```

Verify your credentials with the AWS CLI (if installed):

```powershell
aws sts get-caller-identity
```

If you prefer using Terraform provider profiles, set the profile in your provider block or export `AWS_PROFILE`.

IMPORTANT: If the AWS keys that were in `main.tf` are active, rotate them immediately.