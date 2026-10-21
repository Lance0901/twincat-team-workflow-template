# TwinCAT Team Workflow

## 目的

GitHub Pull Request 是同事交付變更的介面。Orca 是整合者本機的自動審核與 TwinCAT 驗證中心。真人整合者保留最終核准與合併權。

## 角色

### 真人整合者

- 核准架構、Public Contract 與高風險專案組態。
- 核准 Target Profile、Standing Authorization 與實機 Runtime。
- 處理具有語意差異的 Merge Conflict。
- 接受殘餘風險並執行最終 PR Approval。

### Orca Coordinator

- 將需求拆成可獨立驗收的工作包。
- 管理工作樹、Session、DAG、檔案所有權與證據。
- 對等待整合者審核的 PR 建立獨立 Review worktree。
- 對固定 Commit SHA 執行 Code Review、Build 與允許的 Runtime 驗證。
- 更新 `PROJECT_STATE.md`。

Coordinator 不得建立或擴大 Runtime 授權。

### 執行者

- 只修改工作包允許的檔案。
- 執行最低充分驗證。
- 提供修改、測試、風險與交接資料。

### 獨立 Reviewer

- 對照需求、Diff 與驗證證據。
- 輸出 `PASS`、`REVISE` 或 `STOP`。
- 不得同時是同一工作包的實作者。

## Pull Request 流程

```text
同事 Push feature branch
    -> 建立 Draft PR
    -> 完成後標示 Ready for review
    -> 在 Reviewers 欄位指定真人整合者
    -> Orca 掃描等待該整合者審核的 PR
    -> 建立獨立 Review worktree
    -> Checkout 固定 Commit SHA
    -> 執行 Policy、Code Review、Build 與核准的 Runtime 驗證
    -> 將 PASS／FAIL 與證據回寫 PR
    -> 真人整合者核准或要求修改
```

本流程不使用 GitHub Actions。

PR 新增 Commit 後，原 Review 結果失效。Orca 必須對新的 Commit SHA 重新審核。

## 工作包

每個工作包必須包含：

- GitHub Issue 或 PR。
- 目標與非目標。
- 必要脈絡。
- 相關檔案。
- 可修改範圍與禁止範圍。
- 相依關係。
- 驗收條件。
- 測試方式。
- 最高驗證層級。
- 真人核准需求。

只有互不相依且不修改相同檔案的工作包可以平行執行。共享 TwinCAT IDE、Target、Runtime、ADS Port 或設備的工作必須依序執行。

## Runtime 環境

| Environment Class | 環境 | 預設規則 |
|---|---|---|
| `isolated-simulation` | 專用 Local Runtime 或 UMRT | 可使用已核准 Target Profile 的 Standing Authorization |
| `connected-testbench` | 測試 IPC、共用模擬器或測試設備 | 每次執行前取得真人核准 |
| `production-machine` | 實機、產線或可控制致動器的環境 | 每次執行前取得真人核准 |

Target 名稱不能證明安全。Target Profile 必須記錄 Runtime Kind、AmsNetId、允許動作、ADS Write Symbol、驗證上限、環境副作用與核准證據。

## Review 輸出

每次 Orca Review 至少記錄：

- Repository 與 PR number。
- 完整 Commit SHA。
- `PASS`、`REVISE` 或 `STOP`。
- Policy 與 Code Review 結果。
- TwinCAT Build 結果。
- Local／UMRT／實機驗證狀態。
- Blocking findings。
- 尚未執行的驗證與原因。
- Review timestamp。

