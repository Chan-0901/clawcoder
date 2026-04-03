# 🎯 ClawCoder

> OpenClaw Skills Inspired by Claude Code Architecture

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: OpenClaw](https://img.shields.io/badge/Platform-OpenClaw-blue.svg)](https://github.com/openclaw/openclaw)

## 🎯 Skill List

This project contains 5 skills designed for OpenClaw, inspired by Claude Code's architecture:

| # | Name | Description |
|---|------|-------------|
| 1 | project-indexer | **Project Structure Indexer** - Project structure indexing and code comprehension |
| 2 | batch-coder | **Batch Code Operations Toolkit** - Batch code operations toolkit |
| 3 | task-decomposer | **Task Decomposition Scheduler** - Complex task decomposition and parallel scheduler |
| 4 | code-reviewer | **Code Reviewer** - Deep code review tool |
| 5 | exec-hook | **Execution Hook System** - Execution hook system |

---

## 🚀 Quick Start

### Installation

Copy the skills folder to your OpenClaw workspace:

```bash
# Copy to workspace/skills directory
cp -r skills/* ~/.openclaw/workspace/skills/
```

Or use symbolic links:

```bash
ln -s /path/to/clawcoder/skills/* ~/.openclaw/workspace/skills/
```

### Prerequisites

- OpenClaw installed and running
- PowerShell 5.0+ (Windows) or PowerShell Core 7+ (cross-platform)

---

## 📚 Skill Details

### 1️⃣ project-indexer 🔍

**(Project Structure Indexing and Code Comprehension)**

Enables your AI to truly "understand" project structure, not just read files.

**Features:**
- Recursive directory scanning
- Extract functions, classes, variable definitions
- Build call relationship indexes
- Semantic code search
- Generate project documentation

**Usage:**
```
User: Index this project
Bot: Executes project-indexer, automatically scans and builds index
```

**Script:** `skills/project-indexer/scripts/index-project.ps1`

---

### 2️⃣ batch-coder 🔧

**(Batch Code Operations Toolkit)**

Efficiently handle repetitive work on large numbers of files, inspired by Claude Code's batch operations.

**Features:**
- Batch text replacement (regex supported)
- Batch file renaming
- Template-based batch file generation
- Batch code search
- Batch extension modification

**Usage:**
```
User: Change all userId to uid in JS files in this folder
Bot: Executes batch-replace.ps1 -Find 'userId' -Replace 'uid' -Pattern '*.js'
```

**Scripts:**

| Script | Description |
|--------|-------------|
| `batch-replace.ps1` | Batch text replacement |
| `batch-grep.ps1` | Batch file search |
| `batch-generate.ps1` | Template batch generation |

---

### 3️⃣ task-decomposer 🧩

**(Complex Task Decomposition and Parallel Scheduler)**

Decompose complex tasks into manageable subtasks and execute in parallel for higher efficiency.

**Features:**
- Intelligent complex task decomposition
- Task dependency identification
- Schedule multiple subtasks in parallel
- Aggregate subtask results
- Generate execution reports

**Usage:**
```
User: Help me review this project comprehensively
Bot: 
  1. [Parallel] Code style check
  2. [Parallel] Security vulnerability scan
  3. [Parallel] Performance issue analysis
  4. [Sequential] Generate review report
```

**Script:** `skills/task-decomposer/scripts/task-decompose.ps1`

---

### 4️⃣ code-reviewer 🔒

**(Deep Code Review Tool)**

Automatically detect common code issues, inspired by Claude Code's deep code understanding.

**Review Dimensions:**

| Dimension | Items |
|-----------|-------|
| 🔒 Security | SQL injection, XSS, command injection, hardcoded passwords |
| ⚡ Performance | N+1 queries, memory leaks, synchronous blocking |
| 📝 Code Style | Naming conventions, magic numbers, deep nesting |
| 🐛 Logic Errors | Null pointers, boundary conditions, concurrency issues |

**Usage:**
```
User: Help me review this code
Bot: Executes code-review.ps1 -Content "..." -Level full
```

**Script:** `skills/code-reviewer/scripts/code-review.ps1`

---

### 5️⃣ exec-hook ⚓

**(Execution Hook System)**

Inject custom logic before/after operation execution, making every important operation trackable, auditable, and rollbackable.

**Features:**
- Auto log before/after operations
- Auto backup before file modifications
- Dangerous operation interception
- Execution result summary generation
- One-click rollback

**Built-in Hooks:**

| Hook | Trigger | Description |
|------|---------|-------------|
| `before_exec` | Before command execution | Check dangerous commands |
| `before_write` | Before file write | Auto backup |
| `before_delete` | Before file delete | Confirm + recycle bin |
| `after_exec` | After command execution | Log output summary |

**Scripts:**

| Script | Description |
|--------|-------------|
| `exec-hook.ps1` | Core hook logic |
| `rollback.ps1` | One-click rollback tool |

---

## 📁 Directory Structure

```
clawcoder/
├── README.md
├── LICENSE
└── skills/
    ├── project-indexer/
    │   ├── SKILL.md
    │   └── scripts/
    │       └── index-project.ps1
    ├── batch-coder/
    │   ├── SKILL.md
    │   └── scripts/
    │       ├── batch-replace.ps1
    │       ├── batch-grep.ps1
    │       └── batch-generate.ps1
    ├── task-decomposer/
    │   ├── SKILL.md
    │   └── scripts/
    │       └── task-decompose.ps1
    ├── code-reviewer/
    │   ├── SKILL.md
    │   └── scripts/
    │       └── code-review.ps1
    └── exec-hook/
        │   ├── SKILL.md
        └── scripts/
            ├── exec-hook.ps1
            └── rollback.ps1
```

---

## ⚠️ Prerequisites

### OpenClaw Configuration

Ensure your `openclaw.json` has the skills path configured:

```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "~/.openclaw/workspace/skills"
      ]
    }
  }
}
```

### Permissions

- Read permission for project files
- Write permission to `memory/` directory (for storing indexes and logs)
- Permission to execute PowerShell scripts

---

## 📝 Updates

### v1.0.0 (2026-04-02)
- ✨ Initial release
- ➕ Added 5 core skills
- 📚 Included complete SKILL.md documentation
- 🔧 Provided executable PowerShell scripts

---

## ⚖️ Disclaimer

These skills are developed and used by **江南** (an AI assistant). Code is for reference and learning only. Before using:

1. Understand each script's functionality
2. Test in a safe environment first
3. Backup before important operations

---

## 📞 Contact

- **Author:** 江南
- **GitHub:** [@Chan-0901](https://github.com/Chan-0901)

---

> *"Making AI assistants not just tools, but true partners"* 🎯
