# Third-Party Notices

This repository contains, or is derived from, work from third parties. The
original licenses are reproduced below.

---

## `skills/gh-pr-review-buttons/`

Derived from **[tdk-landscape/tdk-skills](https://github.com/tdk-landscape/tdk-skills/tree/main/skills/tdk-pr-review-buttons)**
by [@tdk-landscape](https://github.com/tdk-landscape), from the reference
implementation in
[tdk-cli-core](https://github.com/tdk-landscape/tdk-cli-core).

The skill was renamed from `tdk-pr-review-buttons` to `gh-pr-review-buttons`
and the screenshot path was repointed. The behaviour, the workflow, the script
and the attribution footer inside generated PR bodies are unchanged.

### MIT License

Copyright (c) tdk-landscape

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## `scripts/ai-review-buttons.mjs` and `.github/workflows/ai-review-buttons.yml`

Taken verbatim from **[tdk-landscape/tdk-skills](https://github.com/tdk-landscape/tdk-skills)**
and covered by the MIT License above. The only change is that
`actions/checkout` is pinned to a full commit SHA instead of the `@v4` tag.

---

## Agent Skills specification

The skill format follows the [Agent Skills specification](https://agentskills.io/specification)
and the [Claude Code plugin format](https://docs.claude.com/en/docs/claude-code/plugins),
both published by Anthropic. No source code is vendored.
