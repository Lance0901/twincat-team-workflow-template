# TwinCAT Team Workflow Template

這個 Repository 保存 BATW 的 TwinCAT 團隊協作初版模板。

模板同時支援：

- 使用 Orca 的整合者。
- 未使用 Orca 的開發同事。
- 人工開發流程。
- Codex、Claude 或其他 coding agent。
- TwinCAT Build、Local Runtime、UMRT 與受控實機驗證。

本流程不使用 GitHub Actions。GitHub 保存 Branch、Pull Request、Review 與 Commit 紀錄。Orca 在整合者電腦執行自動審核與 TwinCAT 驗證。真人整合者保留最終核准與合併權。

## AI 接手入口

如果你是接手本 Repository 的 AI，依序執行以下動作：

1. 讀取根目錄的 `AGENTS.md`、`README.md`、`CHANGELOG.md` 與 `VERSION`。
2. 讀取 `template/AGENTS.md`。
3. 讀取 `template/docs/architecture/team-workflow.md`。
4. 讀取 `template/.harness/config.json`。
5. 執行 `git status --short --branch`，確認目前 Branch 與既有修改。
6. 執行 `scripts/Test-Template.ps1`，建立修改前基準。
7. 只修改使用者要求的範圍。
8. 再次執行全部靜態驗證。
9. 更新 `CHANGELOG.md` 與 `VERSION`，但只在準備發布新版模板時執行。
10. 回報修改檔案、測試結果、風險與下一個動作。

不得把聊天紀錄當作專案狀態。規範、決策與驗證結果必須保存在 Repository、Pull Request 或 Harness artifacts。

## Repository 結構

```text
AGENTS.md                      # 維護本模板的 AI 指示
README.md                      # 完整導入與操作說明
CHANGELOG.md                   # 模板版本紀錄
VERSION                        # 模板版本
scripts/
  Install-TwinCATTeamWorkflow.ps1
  Test-Template.ps1
template/                      # 安裝到 TwinCAT Repository 的來源
  AGENTS.md
  PROJECT_STATE.md
  STYLE_GUIDE.md
  orca.yaml
  docs/
    architecture/
      team-workflow.md
    changes/
    handover/
  tools/
    Setup-Project.ps1
    Test-ProjectPolicy.ps1
  .harness/
    config.json
    cases/
    targets/
    runs/
```

## 核心原則

### Repository 是共同規範來源

共同規範必須保存在 TwinCAT Repository。不要只保存在 Orca、個人電腦或聊天紀錄。

`template/AGENTS.md` 是 Agent 的入口。它要求 Agent 繼續讀取：

- `PROJECT_STATE.md`
- `STYLE_GUIDE.md`
- `docs/architecture/team-workflow.md`
- `.harness/config.json`
- 本次 GitHub Issue、Pull Request 與 Comments

不同 coding agent 可以使用自己的 Adapter，但 Adapter 只能指向這些共同文件。不要複製整份規範，避免多份內容逐漸不一致。

### Orca 是整合工具，不是唯一入口

`template/orca.yaml` 只負責在 Orca worktree 建立時執行 `tools/Setup-Project.ps1`。

未使用 Orca 的同事可以直接執行相同指令：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\Setup-Project.ps1
```

因此，核心規範不依賴 Orca。

### PR 是同事的交付介面

同事完成修改後：

1. Push feature branch。
2. 建立 Draft Pull Request。
3. 完成自我檢查。
4. 將 PR 標示為 Ready for review。
5. 在 GitHub 的 Reviewers 欄位指定真人整合者。

建議使用 GitHub 的 Reviewer request。不要只在 Comment 輸入 `@username`。Reviewer request 有明確狀態，也較容易讓 Orca 查詢。

### Orca Review 綁定 Commit SHA

Orca 必須對 PR 的完整 Commit SHA 建立獨立 Review worktree。

每次 Review 至少記錄：

- Repository。
- PR number。
- 完整 Commit SHA。
- Policy 結果。
- Code Review 結果。
- TwinCAT Build 結果。
- Local、UMRT 或實機 Runtime 結果。
- Blocking findings。
- 未執行驗證及原因。
- Review timestamp。

PR 新增 Commit 後，舊 Review 結果立即失效。Orca 必須對新的 Commit SHA 重新審核。真人整合者也不得沿用舊 Approval。

## 安裝到既有 TwinCAT Repository

### 1. Clone 本 Repository

```powershell
git clone https://github.com/BATW/twincat-team-workflow-template.git
Set-Location .\twincat-team-workflow-template
```

Private Repository 需要有效的 GitHub 權限。

### 2. 先執行 Dry Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\Install-TwinCATTeamWorkflow.ps1 `
  -TargetRepo "<TwinCAT Repository 路徑>"
```

Dry Run 只列出預計新增、略過或衝突的檔案。它不會寫入 Target Repository。

### 3. 套用模板

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\Install-TwinCATTeamWorkflow.ps1 `
  -TargetRepo "<TwinCAT Repository 路徑>" `
  -Apply
```

若 Target Repository 已有同名且內容不同的檔案，安裝會停止。它不會默認覆寫。

只有在人工比較差異並確認後，才可使用：

```powershell
-Apply -Overwrite
```

### 4. 填寫專案資料

至少更新：

- `PROJECT_STATE.md` 的 Repository、Solution、PLC Project 與 TwinCAT XAE 版本。
- `STYLE_GUIDE.md` 與既有專案的差異。
- `docs/architecture/team-workflow.md` 的專案例外。
- `.harness/config.json` 的專案預設驗證層級。

不要從範例或其他專案複製 AmsNetId。

### 5. 驗證導入結果

在 Target Repository 根目錄執行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\Setup-Project.ps1
```

此指令只執行靜態 Policy 檢查。它不會開啟 TwinCAT XAE，也不會執行 Build 或 Runtime 操作。

### 6. Commit 導入內容

在 Commit 前：

1. 檢查 `git diff`。
2. 逐檔 Stage。不要使用 `git add .` 或 `git add -A`。
3. 確認沒有 `.env`、Credential、Route password 或機台敏感資料。
4. 建立 PR 並指定真人整合者。

## 新 TwinCAT Repository

對新專案也使用相同安裝腳本。先建立空 Repository 或 TwinCAT 專案，再將模板安裝到 Repository 根目錄。

不要直接把本模板 Repository 當成機台專案。`template/` 是待安裝來源，不是實際 PLC 工程。

## 工作角色

### 真人整合者

真人整合者負責：

- 核准架構與 Public Contract。
- 核准 `.plcproj`、`.tsproj`、Library、PLC Task、I/O Mapping 與 EtherCAT 變更。
- 核准 Target Profile 與 Standing Authorization。
- 核准共享測試台與實機 Runtime。
- 處理語意 Merge Conflict。
- 執行最終 PR Approval 與 Merge。

### Orca Coordinator

Orca Coordinator 負責：

- 將目標拆成可獨立驗收的工作包。
- 建立工作樹、Session、DAG 與檔案所有權。
- 掃描等待整合者 Review 的 PR。
- 建立獨立 Review worktree。
- 對固定 Commit SHA 執行 Review 與驗證。
- 更新 `PROJECT_STATE.md`。

Coordinator 可以套用已核准的 Runtime Policy，但不得代表真人建立或擴大授權。

### 執行者

執行者可以是同事或 coding agent。執行者只修改工作包允許的檔案，並提供可重現的驗證證據。

### 獨立 Reviewer

Reviewer 不得是同一工作包的實作者。Reviewer 必須輸出：

- `PASS`
- `REVISE`
- `STOP`

## 不使用 GitHub Actions 的審核流程

```text
同事 Push feature branch
    -> 建立或更新 Pull Request
    -> 指定真人整合者為 Reviewer
    -> Orca 定期掃描等待該整合者審核的 PR
    -> 建立隔離 Review worktree
    -> 鎖定 PR Commit SHA
    -> 執行 Policy、Code Review、Build 與核准的 Runtime 驗證
    -> 將 PASS／FAIL 與證據回寫 Pull Request
    -> 真人整合者核准或要求修改
```

Orca Automation 是排程觸發。若未設定排程，整合者可以手動啟動 Review。不要假設 Orca 原生接收 GitHub PR webhook。

沒有 GitHub Actions 時，建議在 GitHub 啟用以下 Branch Protection：

- 禁止直接 Push `main` 或 `release`。
- 合併前必須建立 Pull Request。
- 必須取得真人整合者 Approval。
- PR 新增 Commit 後撤銷舊 Approval。
- 高風險檔案使用 `CODEOWNERS` 要求指定人員審核。

Branch Protection 是 GitHub Repository 設定，不是 GitHub Actions。

## TwinCAT 驗證層級

| Level | 驗證內容 | 預設邊界 |
|---:|---|---|
| 0 | 靜態檢查 | 可自動執行 |
| 1 | Source Edit 與檔案一致性 | 可自動執行 |
| 2 | TwinCAT Project Load | 工作包必須允許 |
| 3 | TwinCAT Build | 必須通過 Hook 與專案政策 |
| 4 | Activate Configuration | Standing Authorization 或 Per-run Approval |
| 5 | Login／Download | Standing Authorization 或 Per-run Approval |
| 6 | ADS Runtime 驗證 | Target Profile、Case 與 Allowlist 必須通過 |
| 7 | PLC State Change 或 ADS Write | 嚴格限制於已核准範圍 |

Build 失敗後，必須停止所有後續 Runtime 操作。

Runtime 順序固定為：

```text
Build
  -> Activate Configuration
  -> Login / Download
  -> Connect ADS
  -> Set PLC State
  -> Read / Write Variables
```

AmsNetId 必須從 IDE Target 動態取得。不得硬編碼。

## Runtime 環境分類

| Environment Class | 適用環境 | Coordinator 權限 |
|---|---|---|
| `isolated-simulation` | 專用 Local Runtime 或 UMRT，沒有 Physical I/O、外部副作用及共享使用者 | 可在已核准 Target Profile 的 Allowlist 內自動執行 |
| `connected-testbench` | 測試 IPC、共用模擬器或測試設備 | 每次執行前取得真人核准 |
| `production-machine` | 實機、產線或可控制致動器的環境 | 每次執行前取得真人核准 |

Local 或 UMRT 不是自動安全。只有完整 Target Profile 可以提供 Standing Authorization。Profile 必須記錄：

- Runtime Kind。
- Environment Class。
- 預期 Target identity。
- 最高驗證層級。
- 允許動作。
- ADS Write Symbol allowlist。
- Physical I/O、外部副作用與共享狀態。
- 核准人與核准依據。

## 專案檔案所有權

一般工作包可以修改明確指定的：

- `.TcPOU`
- `.TcDUT`
- `.TcGVL`
- 測試程式
- 受控文件

以下項目需要專用工作包、獨立 Review 與真人核准：

- `.plcproj` 與 `.tsproj`
- POU、DUT、GVL 或 Interface 的新增、刪除或搬移
- Library Reference 與版本
- PLC Task 與 Cycle Time
- Boot Project
- I/O Mapping
- EtherCAT Topology 與裝置參數
- Route、Target 與 Runtime 設定

## 模板維護方式

### 修改來源

需要安裝到 TwinCAT Repository 的內容，只修改 `template/`。

根目錄文件負責說明如何維護與導入模板。不要把 Target Project 的狀態寫入本 Repository 的根目錄文件。

### 驗證模板

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-Template.ps1
```

驗證內容包括：

- 必要檔案存在。
- JSON 格式正確。
- Runtime approval 不得默認開啟。
- 高風險操作必須維持 `explicit`。
- `orca.yaml` 使用相對路徑。
- 模板不得包含 Windows 絕對路徑。
- Target Project 的 repo-native Policy 檢查通過。

### 發布模板版本

使用語意版本：

- Patch：文字修正或不改變 Policy 的改善。
- Minor：向下相容的新文件、檢查或流程。
- Major：不相容的安裝結構或 Policy 變更。

發布前更新：

- `VERSION`
- `CHANGELOG.md`
- `README.md`

## Definition of Done

模板變更只有在下列條件全部成立後才完成：

- 修改目的明確。
- 沒有固定開發者路徑或 AmsNetId。
- 沒有降低 Runtime 安全邊界。
- `scripts/Test-Template.ps1` 通過。
- `template/tools/Setup-Project.ps1` 通過。
- README 與實際操作一致。
- `CHANGELOG.md` 與 `VERSION` 已按發布範圍更新。
- Pull Request 已由非實作者 Review。

## 已知限制

- 本 Repository 不包含任何實際 TwinCAT Solution 或 PLC Project。
- 靜態驗證不代表 TwinCAT Build 通過。
- Orca 排程需要在整合者電腦保持可用。
- 不使用 GitHub Actions 時，GitHub 不會自行執行 TwinCAT Build。
- Orca Review 結果必須由整合者或自訂整合程式回寫 PR。
- 實際 Target Profile 必須在各 TwinCAT Repository 由真人建立並核准。

