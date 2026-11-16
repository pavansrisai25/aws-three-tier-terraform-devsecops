# DevSecOps Security Assessment

**Scope:** static review of `main.tf`, `outputs.tf`, `provider.tf`, `variables.tf`, and the prior conversation's verification summary. No infrastructure operations were performed for this report.

## Evidence and limits


This assessment combines a static review of the Terraform source with the latest recorded Checkov scan and Terraform verification output.

### Checkov scan

- Tool: Checkov v3.4.5
- Command: `checkov -d . --framework terraform --compact`
- Result: 127 passed, 30 failed, 0 skipped
- Scan date: 16 November 2026

### Terraform verification

- `terraform fmt -check`: passed.
- `terraform validate`: successful.
- `terraform plan -no-color`: no changes; Terraform reported that the infrastructure matches the configuration.

These results establish configuration formatting, validity, and consistency with the refreshed Terraform state. They do not prove that every AWS service is healthy or that the application is production-ready.

### Scope limitations

The Checkov result is a static configuration assessment. It does not independently establish runtime behavior, target health, application-to-database connectivity, or actual billing.

The findings below should be interpreted as scanner findings requiring review, not automatically as confirmed exploitable vulnerabilities. No findings have been suppressed or claimed as remediated without evidence.

## Controls visible in source

The following controls are present in the reviewed Terraform. They are source observations, not independent tests of deployed AWS settings:

| Control | Source evidence | Assessment |
| --- | --- | --- |
| No direct internet route for DB subnets | DB route table has no default route | Reduces direct subnet egress; note subnet-group scope below. |
| RDS not publicly accessible | `publicly_accessible = false` | Appropriate private endpoint setting. |
| RDS and EC2 root storage encryption | RDS `storage_encrypted = true`; launch-template EBS `encrypted = true` | Encryption at rest configured. Key selection/default-key posture is not reviewed here. |
| IMDSv2 required | Both launch templates set `http_tokens = "required"` and hop limit 1 | Helps protect instance metadata access. |
| Tiered security-group references | Ingress/egress links use referenced security groups for tier traffic | Limits these paths by peer group and port. Legacy rules remain inline. |
| Default VPC security group restricted | Empty ingress and egress lists | Removes default-SG traffic rules in managed configuration. |
| RDS deletion protection and backups | `deletion_protection = true`; 7-day backup retention; final snapshot required | Helps prevent accidental deletion and supports recovery. |
| Load balancer deletion protection | Enabled on public and internal ALBs | Helps prevent accidental removal. |
| SSM managed instance access | EC2 role attaches `AmazonSSMManagedInstanceCore` | Supports managed access without an SSH ingress rule in these launch templates. |
| Invalid ALB headers dropped | `drop_invalid_header_fields = true` on both ALBs | Header hardening configured. |

## Resolved / addressed findings (source evidence only)

The current source reflects remediation for common static checks around IMDSv2, encrypted EBS/RDS storage, public database exposure, default security-group traffic, unrestricted inter-tier ingress, and deletion safeguards. Because no before/after Checkov reports were available, these are described as controls present in source, not as verified resolved Checkov findings.

## Latest Checkov findings

The scan reported 30 failed checks. The following breakdown records the findings without suppressing them.

| Finding | Count | Area |
|---|---:|---|
| CKV_AWS_130 | 2 | Public subnet public-IP assignment |
| CKV_AWS_260 | 2 | HTTP ingress rules |
| CKV_AWS_23 | 1 | Security-group rule description |
| CKV_AWS_382 | 1 | Unrestricted EC2 security-group egress |
| CKV_AWS_126 | 2 | EC2 detailed monitoring |
| CKV_AWS_135 | 2 | EC2 EBS optimization |
| CKV_AWS_79 | 2 | EC2 metadata configuration |
| CKV_AWS_8 | 2 | EC2 EBS encryption |
| CKV_AWS_91 | 2 | ALB access logging |
| CKV_AWS_2 | 2 | ALB HTTPS configuration |
| CKV_AWS_129 | 1 | RDS logging |
| CKV_AWS_118 | 1 | RDS enhanced monitoring |
| CKV_AWS_161 | 1 | RDS IAM authentication |
| CKV_AWS_157 | 1 | RDS Multi-AZ |
| CKV2_AWS_20 | 2 | ALB HTTP-to-HTTPS redirects |
| CKV2_AWS_28 | 1 | Public ALB WAF association |
| CKV2_AWS_11 | 1 | VPC Flow Logs |
| CKV_AWS_378 | 2 | HTTPS target-group communication |
| CKV_AWS_103 | 2 | ALB listener TLS policy |
| **Total** | **30** | |

### Finding disposition

- **Demonstration design trade-offs:** public subnet IP assignment and public HTTP ingress are consistent with the current web-tier design.
- **Legacy infrastructure:** the two retained EC2 instances account for several configuration findings. They are intentionally preserved rather than replaced solely to improve a static scan score.
- **Deferred security improvements:** HTTPS listeners and redirects, ALB access logs, WAF, VPC Flow Logs, and more restrictive egress should be evaluated before production use.
- **Database improvements:** RDS logging, enhanced monitoring, IAM authentication, and Multi-AZ require further design and cost review.

The scan result is recorded transparently. No claim is made that the project has zero security findings or is production-hardened.

## Accepted or deferred risks

| Risk | Current posture | Suggested follow-up |
| --- | --- | --- |
| Plain HTTP public and internal listeners | Port 80 public; port 8080 internal; no TLS listener/certificate in source | Add HTTPS with managed certificate and redirect policy before production use. |
| Public inbound HTTP | ALB security group allows TCP 80 from `0.0.0.0/0` | Intentional demo entry point; restrict or front with WAF/TLS as workload needs. |
| Broad HTTPS egress | Web and app groups permit TCP 443 to `0.0.0.0/0` | Restrict destinations with egress controls/endpoints where practical. |
| Single NAT Gateway | Both application subnets share one NAT in public A | Availability and cross-AZ traffic trade-off; consider per-AZ NAT for resilient production egress. |
| Database subnet-group breadth | Group includes app and DB subnets | Move to DB subnets only after confirming subnet/AZ requirements and migration impact. |
| Single-AZ RDS | `multi_az = false` | Accepted cost/availability trade-off for demo; assess Multi-AZ and recovery objectives for production. |
| Legacy EC2 lifecycle ignored | Both legacy instances use `ignore_changes = all` and remain ALB targets | Transitional preservation; establish a migration/removal plan and reconcile drift. |
| Credential handling/state | Password variable is sensitive, but state can retain sensitive data; password drift ignored | Use managed secret integration, secure remote state with encryption/locking/access controls, and explicit credential rotation. |
| No explicit ALB access logs, WAF, or flow logs in source | Not configured in reviewed files | Add logging and detection controls based on monitoring and retention requirements. |
| Demo app has no DB integration | App tier returns static HTML | Application behavior and database security testing remain outside this infrastructure source. |

These items are design risks for review. The Checkov findings above identify the checks that currently fail; the risk table also includes additional operational and architectural considerations. A finding's presence does not automatically mean the design is unsuitable for a demonstration, but it must be reviewed before production use.

## Validation and deployment evidence

Latest recorded verification: 16 November 2026.

### Terraform

- `terraform fmt -check`: passed.
- `terraform validate`: successful.
- `terraform plan -no-color`: no changes. Terraform reported that the infrastructure matches the configuration.

### Checkov

- Version: 3.4.5.
- Command: `checkov -d . --framework terraform --compact`
- Result: 127 passed, 30 failed, 0 skipped.
- Finding breakdown and dispositions: documented above.

### Evidence not established by these checks

- Current public URL response and application behavior.
- ALB target health and Auto Scaling Group health.
- Current SSM managed-node connectivity.
- Application-to-RDS connectivity and database integration.
- Actual AWS billing and cost estimate.

Do not treat Terraform plan equivalence or a static Checkov scan as proof of runtime health or production security. Repeat validation and scanning after future source changes, review every proposed infrastructure change, and record sanitized runtime and billing evidence when verified.