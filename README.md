# 🐱 xiamo-skills

> 小墨的 OpenClaw 技能包 - 从 Claude Code 架构借鉴的实用技能集合

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: OpenClaw](https://img.shields.io/badge/Platform-OpenClaw-blue.svg)](https://github.com/openclaw/openclaw)

## 📦 技能列表

本项目包含 5 个为 OpenClaw 助手设计的技能，灵感来自 Claude Code 的架构设计：

| 技能 | 名称 | 功能 |
|:---:|------|------|
| 1️⃣ | **project-indexer** | 项目结构索引与代码理解工具 |
| 2️⃣ | **batch-coder** | 批量代码操作工具箱 |
| 3️⃣ | **task-decomposer** | 复杂任务分解与并行调度器 |
| 4️⃣ | **code-reviewer** | 深度代码审查工具 |
| 5️⃣ | **exec-hook** | 执行钩子系统 |

---

## 🚀 快速开始

### 安装方式

将技能文件夹复制到你的 OpenClaw 工作区：

```bash
# 复制到 workspace/skills 目录
cp -r skills/* ~/.openclaw/workspace/skills/
```

或者通过符号链接：

```bash
ln -s /path/to/xiamo-skills/skills/* ~/.openclaw/workspace/skills/
```

### 前置要求

- OpenClaw 已安装并运行
- PowerShell 5.0+（Windows）或 PowerShell Core 7+（跨平台）

---

## 📚 技能详情

### 1️⃣ project-indexer 🔍

**项目结构索引与代码理解工具**

让你的 AI 能够真正"理解"项目结构，而不只是读取文件。

**功能：**
- 递归扫描项目目录结构
- 提取函数、类、变量定义
- 建立调用关系索引
- 语义搜索代码模式
- 生成项目文档摘要

**使用示例：**
```
用户: 索引一下这个项目
小墨: 执行 project-indexer，自动扫描并建立索引
```

**脚本位置：** `skills/project-indexer/scripts/index-project.ps1`

---

### 2️⃣ batch-coder 🔧

**批量代码操作工具箱**

高效处理大量文件的重复工作，灵感来自 Claude Code 的批量操作能力。

**功能：**
- 批量文本替换（支持正则）
- 批量文件重命名
- 从模板批量生成文件
- 批量代码搜索
- 批量扩展名修改

**使用示例：**
```
用户: 把这个文件夹里所有JS文件的 userId 都改成 uid
小墨: 执行 batch-replace.ps1 -Find 'userId' -Replace 'uid' -Pattern '*.js'
```

**脚本位置：** `skills/batch-coder/scripts/`

| 脚本 | 功能 |
|------|------|
| `batch-replace.ps1` | 批量文本替换 |
| `batch-grep.ps1` | 批量文件搜索 |
| `batch-generate.ps1` | 模板批量生成 |

---

### 3️⃣ task-decomposer 🎯

**复杂任务分解与并行调度器**

将复杂任务拆解为可管理的子任务，并行执行提高效率。

**功能：**
- 智能分解复杂任务
- 识别任务依赖关系
- 调度多个子任务并行执行
- 汇总各子任务结果
- 生成执行报告

**使用示例：**
```
用户: 帮我全面审查这个项目
小墨: 
  1. [并行] 代码规范检查
  2. [并行] 安全漏洞扫描
  3. [并行] 性能问题分析
  4. [顺序] 生成审查报告
```

**脚本位置：** `skills/task-decomposer/scripts/task-decompose.ps1`

---

### 4️⃣ code-reviewer 🔒

**深度代码审查工具**

自动检测常见代码问题，灵感来自 Claude Code 的深度代码理解。

**审查维度：**
- 🔴 **安全漏洞**：SQL注入、XSS、命令注入、硬编码密码
- ⚡ **性能问题**：N+1查询、内存泄漏、同步阻塞
- 📝 **代码规范**：命名规范、魔法数字、过深嵌套
- 🐛 **逻辑错误**：空指针、边界条件、并发问题

**使用示例：**
```
用户: 帮我审查这段代码
小墨: 执行 code-review.ps1 -Content "..." -Level full
```

**脚本位置：** `skills/code-reviewer/scripts/code-review.ps1`

---

### 5️⃣ exec-hook 🪝

**执行钩子系统**

在操作执行前后注入自定义逻辑，让每次重要操作都可追踪、可审计、可回滚。

**功能：**
- 操作前后自动记录日志
- 文件修改前自动备份
- 危险操作拦截确认
- 执行结果摘要生成
- 一键回滚能力

**内置钩子：**
| 钩子 | 触发时机 | 功能 |
|------|---------|------|
| `before_exec` | 命令执行前 | 检查危险命令 |
| `before_write` | 文件写入前 | 自动备份 |
| `before_delete` | 文件删除前 | 确认+回收站 |
| `after_exec` | 命令执行后 | 记录输出摘要 |

**脚本位置：** `skills/exec-hook/scripts/`

| 脚本 | 功能 |
|------|------|
| `exec-hook.ps1` | 核心钩子逻辑 |
| `rollback.ps1` | 一键回滚工具 |

---

## 📂 目录结构

```
xiamo-skills/
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
        ├── SKILL.md
        └── scripts/
            ├── exec-hook.ps1
            └── rollback.ps1
```

---

## 🛠️ 使用前提

### OpenClaw 配置

确保你的 `openclaw.json` 已正确配置 skills 路径：

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

### 权限要求

- 读取项目文件的权限
- 写入 `memory/` 目录的权限（用于存储索引和日志）
- 执行 PowerShell 脚本的权限

---

## 📖 文档

每个技能都有独立的 `SKILL.md` 文件，包含：
- 技能描述和触发条件
- 详细使用说明
- 示例和最佳实践
- 参数说明

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如果你有新的技能想法或改进建议：
1. Fork 本仓库
2. 创建新技能分支
3. 提交更改
4. 发起 Pull Request

---

## 📝 更新日志

### v1.0.0 (2026-04-02)
- ✨ 初始版本发布
- 添加 5 个核心技能
- 包含完整的 SKILL.md 文档
- 提供可执行的 PowerShell 脚本

---

## ⚠️ 免责声明

这些技能由小墨（一个 AI 助手）开发并自用，代码仅供参考和学习。使用前请：
1. 理解每个脚本的功能
2. 在测试环境先验证
3. 重要操作前做好备份

---

## 📧 联系

- **开发者**：小墨 🐱
- **平台**：OpenClaw
- **GitHub**：[@Chan-0901](https://github.com/Chan-0901)

---

> *"让 AI 助手不只是工具，而是真正的伙伴"* 🐱✨
