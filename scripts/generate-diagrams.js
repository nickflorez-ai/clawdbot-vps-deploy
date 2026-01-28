#!/usr/bin/env node
/**
 * Generate diagram images for documentation
 * Usage: node generate-diagrams.js
 */

const { renderMermaid, renderMermaidAscii } = require('beautiful-mermaid');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const OUTPUT_DIR = path.join(__dirname, '..', 'images');

const diagrams = {
  'content-flow': {
    title: 'How Content Enters The Library',
    mermaid: `graph TD
    A[Source Material] --> B[Research & Analysis]
    B --> C[Draft Document]
    C --> D[Pull Request]
    D --> E[Expert Review]
    E -->|Changes needed| C
    E -->|Approved| F[Approval]
    F --> G[Merge to Main]
    G --> H[In The Library]`
  },
  'governance-flow': {
    title: 'Governance Flow',
    mermaid: `graph LR
    A[Library Repo] --> B[Dispatch]
    B --> C[Agent]
    C --> D[Output Repo]
    D --> E[Human Approval]
    E --> F[Merged]`
  },
  'progressive-automation': {
    title: 'Progressive Automation Phases',
    mermaid: `graph TD
    subgraph Phase1[Phase 1: Human Approves All]
      A1[AI Work] --> B1[PR]
      B1 --> C1[Human Approval]
      C1 --> D1[Merge]
    end
    
    subgraph Phase2[Phase 2: AI Pre-Review]
      A2[AI Work] --> B2[PR]
      B2 --> C2[AI Review]
      C2 --> D2[Human Approval]
      D2 --> E2[Merge]
    end
    
    subgraph Phase3[Phase 3: AI-to-AI]
      A3[AI Work] --> B3[PR]
      B3 --> C3[AI Review]
      C3 --> D3[AI Approval]
      D3 --> E3[Human Spot-Check]
    end`
  },
  'workspace-flow': {
    title: 'Workspace Workflow',
    mermaid: `graph LR
    A[AI Creates Work] --> B{Inbox or PR?}
    B -->|Simple| C[inbox/]
    B -->|Complex| D[Pull Request]
    C --> E[You Review]
    D --> E
    E -->|Approved| F[approved/]
    E -->|Changes| G[Feedback to AI]
    G --> A`
  },
  'dispatch-architecture': {
    title: 'Dispatch Architecture',
    mermaid: `graph TD
    subgraph Library[Library Repos]
      L1[Guidelines]
      L2[Policies]
      L3[Specs]
    end
    
    L1 --> D[Central Dispatch]
    L2 --> D
    L3 --> D
    
    D --> A1[Agent: Spec Gen]
    D --> A2[Agent: Doc Writer]
    D --> A3[Agent: Validator]
    
    A1 --> O1[Specs Repo]
    A2 --> O2[Training Repo]
    A3 --> O3[Config Repo]
    
    O1 --> H[Human Approval]
    O2 --> H
    O3 --> H`
  }
};

async function main() {
  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  for (const [name, diagram] of Object.entries(diagrams)) {
    console.log(`Generating ${name}...`);
    
    // Generate SVG with dark theme
    let svg = await renderMermaid(diagram.mermaid, {
      theme: { bg: '#1a1a1a', fg: '#e5e5e5' }
    });
    
    // Inline CSS variables for PNG conversion (rsvg-convert doesn't support CSS vars)
    svg = svg
      .replace(/var\(--bg\)/g, '#1a1a1a')
      .replace(/var\(--fg\)/g, '#e5e5e5')
      .replace(/var\(--_text\)/g, '#e5e5e5')
      .replace(/var\(--_line\)/g, '#888888')
      .replace(/var\(--_arrow\)/g, '#aaaaaa')
      .replace(/var\(--_node-fill\)/g, '#2a2a2a')
      .replace(/var\(--_node-stroke\)/g, '#444444')
      .replace(/var\(--_text-sec\)/g, '#aaaaaa')
      .replace(/var\(--_text-muted\)/g, '#777777');
    
    const svgPath = path.join(OUTPUT_DIR, `${name}.svg`);
    fs.writeFileSync(svgPath, svg);
    console.log(`  ✓ ${name}.svg`);
    
    // Convert to PNG using rsvg-convert (smaller width for reasonable file size)
    const pngPath = path.join(OUTPUT_DIR, `${name}.png`);
    try {
      execSync(`rsvg-convert -w 500 -b white "${svgPath}" -o "${pngPath}"`);
      // Compress with pngquant if available
      try {
        execSync(`pngquant --force --ext .png "${pngPath}" 2>/dev/null`);
      } catch (e) { /* pngquant not installed, skip */ }
      console.log(`  ✓ ${name}.png`);
    } catch (err) {
      console.error(`  ✗ PNG conversion failed: ${err.message}`);
    }
    
    // Generate ASCII version
    try {
      const ascii = renderMermaidAscii(diagram.mermaid);
      const asciiPath = path.join(OUTPUT_DIR, `${name}.txt`);
      fs.writeFileSync(asciiPath, `${diagram.title}\n${'='.repeat(diagram.title.length)}\n\n${ascii}`);
      console.log(`  ✓ ${name}.txt`);
    } catch (err) {
      console.log(`  ⚠ ASCII not supported for this diagram type`);
    }
  }

  console.log('\nDone! Images saved to:', OUTPUT_DIR);
}

main().catch(console.error);
