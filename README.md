# 馃惐 ClawCoder

> OpenClaw Skills Inspired by Claude Code Architecture

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: OpenClaw](https://img.shields.io/badge/Platform-OpenClaw-blue.svg)](https://github.com/openclaw/openclaw)

## 馃摝 Skill List

This project contains 5 skills designed for OpenClaw, inspired by Claude Code's architecture:

| # | Name | Description |
|:---:|------|------|
| 1锔忊儯 | **project-indexer** | Project structure indexing and code comprehension |
| 2锔忊儯 | **batch-coder** | Batch code operations toolkit |
| 3锔忊儯 | **task-decomposer** | Complex task decomposition and parallel scheduler |
| 4锔忊儯 | **code-reviewer** | Deep code review tool |
| 5锔忊儯 | **exec-hook** | Execution hook system |

---

## 馃殌 Quick Start

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

## 馃摎 Skill Details

### 1锔忊儯 project-indexer 馃攳

**Project Structure Indexing and Code Comprehension**

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

### 2锔忊儯 batch-coder 馃敡

**Batch Code Operations Toolkit**

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

**Scripts:** `skills/batch-coder/scripts/`

| Script | Description |
|--------|-------------|
| `batch-replace.ps1` | Batch text replacement |
| `batch-grep.ps1` | Batch file search |
| `batch-generate.ps1` | Template batch generation |

---

### 3锔忊儯 task-decomposer 馃幆

**Complex Task Decomposition and Parallel Scheduler**

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

### 4锔忊儯 code-reviewer 馃敀

**Deep Code Review Tool**

Automatically detect common code issues, inspired by Claude Code's deep code understanding.

**Review Dimensions:**
- 馃敶 **Security**: SQL injection, XSS, command injection, hardcoded passwords
- 鈿?**Performance**: N+1 queries, memory leaks, synchronous blocking
- 馃摑 **Code Style**: Naming conventions, magic numbers, deep nesting
- 馃悰 **Logic Errors**: Null pointers, boundary conditions, concurrency issues

**Usage:**
```
User: Help me review this code
Bot: Executes code-review.ps1 -Content "..." -Level full
```

**Script:** `skills/code-reviewer/scripts/code-review.ps1`

---

### 5锔忊儯 exec-hook 馃獫

**Execution Hook System**

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

**Scripts:** `skills/exec-hook/scripts/`

| Script | Description |
|--------|-------------|
| `exec-hook.ps1` | Core hook logic |
| `rollback.ps1` | One-click rollback tool |

---

## 馃搨 Directory Structure

```
clawcoder/
鈹溾攢鈹€ README.md
鈹溾攢鈹€ LICENSE
鈹斺攢鈹€ skills/
    鈹溾攢鈹€ project-indexer/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹斺攢鈹€ index-project.ps1
    鈹溾攢鈹€ batch-coder/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹溾攢鈹€ batch-replace.ps1
    鈹?      鈹溾攢鈹€ batch-grep.ps1
    鈹?      鈹斺攢鈹€ batch-generate.ps1
    鈹溾攢鈹€ task-decomposer/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹斺攢鈹€ task-decompose.ps1
    鈹溾攢鈹€ code-reviewer/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹斺攢鈹€ code-review.ps1
    鈹斺攢鈹€ exec-hook/
        鈹溾攢鈹€ SKILL.md
        鈹斺攢鈹€ scripts/
            鈹溾攢鈹€ exec-hook.ps1
            鈹斺攢鈹€ rollback.ps1
```

---

## 馃洜锔?Prerequisites

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

## 馃摑 Updates

### v1.0.0 (2026-04-02)
- 鉁?Initial release
- Added 5 core skills
- Included complete SKILL.md documentation
- Provided executable PowerShell scripts

---

## 鈿狅笍 Disclaimer

These skills are developed and used by 灏忓ⅷ (an AI assistant). Code is for reference and learning only. Before using:

1. Understand each script's functionality
2. Test in a safe environment first
3. Backup before important operations

---

## 馃摟 Contact

- **Author**: 灏忓ⅷ 馃惐
- **GitHub**: [@Chan-0901](https://github.com/Chan-0901)

---

> *"Making AI assistants not just tools, but true partners"* 馃惐鉁?