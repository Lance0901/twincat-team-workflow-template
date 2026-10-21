# TwinCAT Project Instructions

## 適用範圍

本文件適用於本 Repository 內的所有人工與 Agent 工作。

規則衝突時，使用以下優先順序：

1. 人員與設備安全。
2. 使用者本次明確指示。
3. 本 `AGENTS.md` 與 `.harness/config.json`。
4. `docs/architecture/team-workflow.md`。
5. `STYLE_GUIDE.md` 與既有程式慣例。

## 開始工作前

必須先讀取：

1. `AGENTS.md`。
2. `PROJECT_STATE.md`。
3. `STYLE_GUIDE.md`。
4. `docs/architecture/team-workflow.md`。
5. `.harness/config.json`。
6. 本次 GitHub Issue、Pull Request、Comments 與 Acceptance Criteria。

開始修改前，必須確認：

- 目標與非目標。
- Base Commit 與目前 Commit SHA。
- 允許修改範圍與禁止範圍。
- 驗收條件與測試方式。
- Build 與 Runtime 的最高允許層級。

不得依賴聊天紀錄保存專案狀態。

## 修改規則

- 只做達成目標所需的最小變更。
- 保留既有 TwinCAT 架構、命名與 XML 結構。
- 不得把全專案格式化與行為變更放在同一個 Diff。
- 不得手動修改 Generated Files，例如 `.tmc`，除非專案規範明確要求。
- 未經明確核准，不得修改 `.plcproj`、`.tsproj`、Library、PLC Task、I/O Mapping、EtherCAT、Route 或 Target。
- 未經明確核准，不得刪除或搬移 POU、DUT、GVL、Interface 或專案項目。
- AmsNetId 必須從 IDE Target 動態取得。不得硬編碼。

## TwinCAT 驗證邊界

使用最低充分驗證層級：

- Level 0：靜態檢查。
- Level 1：Source Edit 與檔案一致性。
- Level 2：TwinCAT Project Load。
- Level 3：TwinCAT Build。
- Level 4：Activate Configuration。
- Level 5：Login／Download。
- Level 6：ADS Runtime 驗證。
- Level 7：PLC State Change 或 ADS Write。

Build 失敗後，停止所有 Runtime 操作。

Local Runtime 或 UMRT 只有在已核准的 `isolated-simulation` Target Profile 範圍內，才可使用 Standing Authorization。共享測試台與實機必須逐次取得真人核准。

Runtime 順序固定為：

```text
Build
  -> Activate Configuration
  -> Login / Download
  -> Connect ADS
  -> Set PLC State
  -> Read / Write Variables
```

## Git 與 Pull Request

- 不得直接 Push `main` 或 `release`。
- 不得使用 `git add .` 或 `git add -A`。
- Commit 與 Push 前必須列出 Stage 檔案、Commit Message 與目標分支。
- 未取得使用者明確同意前，不得 Commit、Push、建立 PR 或 Merge。
- 同事以 Pull Request 交付變更，並在 Reviewers 欄位指定真人整合者。
- Orca Review 必須綁定完整 Commit SHA。
- PR 新增 Commit 後，舊的 Orca Review 與真人 Approval 必須視為失效。
- 本專案不依賴 GitHub Actions。Build、測試與 Runtime 證據由本機 Harness 保存。

## 完成與交接

工作結束前必須記錄：

- 完成內容。
- 修改檔案。
- 測試與驗證結果。
- 關鍵決策。
- 已知風險。
- 未解問題。
- 下一個明確動作。
- Base Commit 與目前 Commit SHA。

Coordinator 必須更新 `PROJECT_STATE.md`。完整交接寫入 `docs/handover/`。變更與測試說明寫入 `docs/changes/`。

