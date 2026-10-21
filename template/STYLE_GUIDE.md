# TwinCAT Structured Text Style Guide

本文件是初始預設。若現有專案已有一致且已核准的慣例，先記錄差異，再由真人整合者決定是否沿用。

## 格式

- 使用 4 個空白縮排。
- 不使用 Tab。
- 一行只處理一個主要動作。
- 不進行與需求無關的格式化。
- Comment 解釋原因、限制或安全條件。不要只重述程式碼。

## 宣告

宣告區順序固定為：

1. `VAR_INPUT`
2. `VAR_OUTPUT`
3. `VAR_IN_OUT`
4. `VAR`
5. `VAR_TEMP`

相同用途的變數放在一起。優先使用明確型別。不要以 Magic Number 表示 State、Mode 或 Error。

## 命名

- 沿用現有專案的型別與命名前綴。
- Boolean 名稱必須表達狀態或條件，例如 `bReady`、`bError`、`bEnable`。
- Function Block 使用 `FB_` 前綴。
- Function 使用 `F_` 前綴。
- Program 使用 `PRG_` 前綴。
- Interface 使用 `I_` 前綴。
- Enumeration 與型別命名必須具有 Domain 意義。

若現有專案使用不同前綴，不得在單一 PR 中混用兩套規則。

## 架構

使用下列單向依賴：

```text
PRG_Main / System
        -> Sequence / Application
        -> Domain / Machine Module
        -> Device Abstraction
        -> I/O Mapping / Hardware
```

- Domain 不得直接讀寫實體 I/O。
- Sequence 負責流程協調，不重複 Device 細節。
- Device Abstraction 封裝硬體差異。
- `PRG_Main` 只負責組態、生命週期與頂層協調。
- GVL 只存放跨模組且具有明確所有權的資料。
- 一個 POU 只承擔一個主要責任。

## State Machine

- 使用具名 ENUM。
- 每個 State 必須有清楚的進入、執行、完成與錯誤條件。
- Reset、Abort、Timeout 與錯誤復原行為必須明確。
- 不得在多個 CASE 分支重複寫入同一個輸出而沒有優先順序說明。

