---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# M5 · Validate

## Control B.5.1 · 60 min

Test plan, results, SLOs, remediation log and customer sign-off

<!-- Speaker note: Validation turns delivery into accepted service evidence. -->

---

# Objectives

- Create a complete service validation test plan
- Include functional, integration, performance, resilience and security tests
- Define SLOs and performance evaluation criteria
- Record results and remediation items
- Produce customer sign-off evidence

<!-- Speaker note: Sign-off is the gate. Testing without recorded results and acceptance is not enough. -->

---

# Primer refresher

- Functional tests prove features work
- Integration tests prove services work together
- Performance tests prove capacity assumptions
- Resilience tests prove failure handling
- Security tests prove controls are effective

<!-- Speaker note: Keep the categories distinct. Newcomers often label every check as functional. -->

---

# Test plan coverage

| Category | Example |
| --- | --- |
| Functional | API and web user journeys |
| Integration | Web to API to worker flow |
| Performance | k6 or Azure Load Testing |
| Resilience | Chaos Studio or Litmus scenario |
| Security | Policy, secrets, image and RBAC checks |

<!-- Speaker note: Tools are options. The evidence requires the plan, results and evaluation, not a specific product choice. -->

---

# SLO thinking

- Availability target
- Latency target
- Error-rate threshold
- Recovery expectation
- Observability source
- Escalation threshold

<!-- Speaker note: Make SLOs measurable. Avoid statements like "fast" or "highly available". -->

---

# Walkthrough outline

1. Review deployed service and HLD assumptions
2. Draft test scenarios by category
3. Define SLOs and acceptance criteria
4. Run or simulate tests as the lab directs
5. Capture results and performance evaluation
6. Create remediation log
7. Prepare sign-off summary

<!-- Speaker note: Demo how to turn a failed test into a remediation log entry without derailing the lab. -->

---

# Results evidence

Capture:

- Test name and category
- Tool or method
- Expected result
- Actual result
- Pass/fail
- Evidence link or output snippet
- Remediation reference when failed

<!-- Speaker note: A table is often the fastest format. The trainer should be able to score it quickly. -->

---

# Customer sign-off

Sign-off should state:

- What was tested
- Which SLOs were evaluated
- Known exceptions
- Remediation ownership
- Acceptance decision
- Date and approver role

<!-- Speaker note: It can be a training artifact, but it should look like something usable in a customer engagement. -->

---

# Copilot + MCP

| Item | Used for |
| --- | --- |
| `test-plan` skill | Test plan and sign-off draft |
| Azure MCP | Live resource and monitoring context |
| Microsoft Docs MCP | Load, chaos and security guidance |

<!-- Speaker note: Copilot can generate broad plans; trainers must ensure the plan matches the actual deployed service. -->

---

# Facilitator pitfalls

- Testing only happy paths
- Forgetting resilience or security categories
- Missing performance evaluation
- Failing tests with no remediation log
- Treating sign-off as optional

<!-- Speaker note: If time is short, keep tests lightweight but preserve every evidence category. -->

---

# Validation checklist

- Test plan covers five categories → B.5.1
- Results recorded → B.5.1
- Performance evaluation completed → B.5.1
- Remediation log created → B.5.1
- Customer sign-off prepared → B.5.1

<!-- Speaker note: The customer sign-off is the gating evidence. Make sure every team produces it. -->

---

# Drive it yourself

```text
Invoke the test-plan skill for the Module B AKS deployment.
Create a B.5.1 test plan covering functional, integration, performance,
resilience or chaos, and security. Include SLOs, result fields,
performance evaluation, remediation log and customer sign-off.
```

<!-- Speaker note: Ask learners which test they would automate first and why. That bridges to M6 operations. -->
