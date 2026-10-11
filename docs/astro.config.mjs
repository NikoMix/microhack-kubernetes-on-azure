// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import mermaid from "astro-mermaid";
import starlightLinksValidator from "starlight-links-validator";

// Published base URL. WS4's deploy workflow injects ASTRO_SITE (e.g. the GitHub
// Pages URL). ASTRO_BASE lets a project-site sub-path be supplied; it defaults to
// "/" so local builds and the internal link check stay green.
const site = process.env.ASTRO_SITE || "https://nikomix.github.io";
const base = process.env.ASTRO_BASE || "/";

// https://astro.build/config
export default defineConfig({
  site,
  base,
  // `astro-mermaid` must be registered before Starlight so it can transform
  // ```mermaid fences into client-rendered diagrams (no headless browser at build).
  integrations: [
    mermaid({
      theme: "default",
      autoTheme: true,
    }),
    starlight({
      title: "Kubernetes on Azure — Module B",
      description:
        "A 1-day, Train-the-Trainer MicroHack covering every Module B control of the " +
        "Kubernetes on Microsoft Azure Advanced Specialization.",
      tagline: "Train-the-Trainer · hands-on labs · GitHub Copilot + MCP",
      lastUpdated: true,
      pagination: true,
      plugins: [
        starlightLinksValidator({
          errorOnRelativeLinks: false,
          errorOnLocalLinks: false,
        }),
      ],
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/NikoMix/microhack-kubernetes-on-azure",
        },
      ],
      editLink: {
        baseUrl:
          "https://github.com/NikoMix/microhack-kubernetes-on-azure/edit/main/docs/",
      },
      customCss: ["./src/styles/custom.css"],
      sidebar: [
        {
          label: "Start here",
          items: [
            { label: "Course overview", slug: "overview" },
            { label: "One-day agenda", slug: "agenda" },
            { label: "Module B coverage map", slug: "coverage-map" },
          ],
        },
        {
          label: "Modules (M0–M6)",
          items: [
            { label: "M0 · Setup & bootstrap", slug: "modules/m0-setup" },
            { label: "M1 · Foundations & certification", slug: "modules/m1-foundations" },
            { label: "M2 · Workload assessment", slug: "modules/m2-assessment" },
            { label: "M3 · Design + Well-Architected Review", slug: "modules/m3-design" },
            { label: "M4 · Delivery", slug: "modules/m4-delivery" },
            { label: "M5 · Validate & test", slug: "modules/m5-validate" },
            { label: "M6 · Operate & document", slug: "modules/m6-operate" },
          ],
        },
        {
          label: "Trainer",
          items: [
            { label: "Facilitation", slug: "trainer/facilitation" },
            { label: "Delivery playbook", slug: "trainer/delivery-playbook" },
            { label: "Scoring rubric", slug: "trainer/scoring" },
            { label: "Troubleshooting", slug: "trainer/troubleshooting" },
            { label: "Prep checklist", slug: "trainer/prep-checklist" },
          ],
        },
        {
          label: "References",
          items: [
            { label: "K8s & AKS primer", slug: "references/primer" },
            { label: "kubectl cheat sheet", slug: "references/kubectl-cheat-sheet" },
            { label: "Certification map", slug: "references/certification" },
            { label: "Copilot agent, skills & MCP", slug: "references/copilot-mcp" },
            { label: "Glossary", slug: "references/glossary" },
          ],
        },
      ],
    }),
  ],
});
