# Team Task Manager - 設計書

## 1. 画面仕様書

### 1.1 ログイン画面 (LoginView)
**目的**: ユーザー認証

**入力項目**:
- Email (メールアドレス) - 必須、メール形式
- Password (パスワード) - 必須、最小6文字

**ボタン**:
- Login (ログイン) - 認証実行
- Sign Up (サインアップ) - 新規登録画面へ遷移

**エラー処理**:
- 認証失敗時: "Login failed" メッセージ表示
- 空欄入力時: フォームバリデーション

**遷移先**: ログイン成功 → Dashboard画面

---

### 1.2 サインアップ画面 (SignupView)
**目的**: 新規ユーザー登録

**入力項目**:
- Name (名前) - 必須
- Email (メールアドレス) - 必須、メール形式、一意性
- Password (パスワード) - 必須、最小6文字
- Password Confirmation (パスワード確認) - 必須、Passwordと一致

**ボタン**:
- Sign Up (登録) - ユーザー作成実行
- Back to Login (ログインへ戻る) - ログイン画面へ遷移

**エラー処理**:
- メール重複時: "Email already exists" エラー
- パスワード不一致時: バリデーションエラー
- 必須項目未入力時: フォームバリデーション

**遷移先**: 登録成功 → Dashboard画面

---

### 1.3 ダッシュボード画面 (DashboardView)
**目的**: タスク管理のメイン画面

**構成要素**:

#### ヘッダー
- アプリケーション名: "Team Task Manager"
- ユーザー名表示
- Logout (ログアウト) ボタン

#### サイドバー
- 組織一覧表示
- 選択中の組織をハイライト
- "Create Organization" (組織作成) ボタン

#### メインエリア
- **Team Progress パネル**: 担当者別進捗率表示
  - User (ユーザー名)
  - Total (総タスク数)
  - Done (完了タスク数)
  - Rate (進捗率) - プログレスバー付き
  
- **Task List**: タスク一覧
  - フィルター: Status (状態)、Category (カテゴリ)、Assignee (担当者)
  - "+ New Task" ボタン
  - タスクカード表示 (グリッドレイアウト)

**タスクカード**:
- Title (タイトル)
- Description (説明)
- Category (カテゴリ) - バッジ表示
- Status (状態) - "todo" / "done"
- Assignee (担当者) - "Assigned to: ユーザー名"
- アクション: Complete/Reopen、Edit、Delete

**モーダル (Create/Edit Task)**:
- Title (タイトル) - 必須
- Description (説明)
- Category (カテゴリ)
- Assignee (担当者) - ドロップダウン、全ユーザー表示
  - 非メンバーには "(will be invited)" 表示
- Save/Update ボタン
- Cancel ボタン

**エラー処理**:
- タイトル未入力時: バリデーションエラー
- 組織未選択時: "Please select an organization" メッセージ

---

## 2. モデル設計書

### 2.1 ER図

```
┌─────────────┐         ┌──────────────────┐         ┌──────────────┐
│    User     │         │   Membership     │         │Organization  │
├─────────────┤         ├──────────────────┤         ├──────────────┤
│ id          │◄───────┤ user_id          │        ┌┤ id           │
│ name        │         │ organization_id  ├───────►│ name         │
│ email       │         │ role             │        │ created_at   │
│ password_   │         │ created_at       │        │ updated_at   │
│   digest    │         │ updated_at       │        └──────────────┘
│ created_at  │         └──────────────────┘                │
│ updated_at  │                                              │
└─────────────┘                                              │
       │                                                     │
       │                                                     │
       │ assignee                                            │
       │                                                     │
       ▼                                                     ▼
┌─────────────┐                                    ┌──────────────────┐
│    Task     │                                    │ TaskStatistic    │
├─────────────┤                                    ├──────────────────┤
│ id          │                                    │ id               │
│ title       │                                    │ user_id          │
│ description │                                    │ organization_id  │
│ status      │                                    │ total_tasks      │
│ category    │                                    │ completed_tasks  │
│ assignee_id │                                    │ completion_rate  │
│ organization│                                    │ created_at       │
│   _id       │                                    │ updated_at       │
│ due_date    │                                    └──────────────────┘
│ created_at  │
│ updated_at  │
└─────────────┘
```

### 2.2 テーブル定義

#### users テーブル
| カラム名 | 型 | 制約 | 説明 |
|---------|-----|------|------|
| id | integer | PK | ユーザーID |
| name | string | NOT NULL | ユーザー名 |
| email | string | NOT NULL, UNIQUE | メールアドレス |
| password_digest | string | NOT NULL | 暗号化パスワード |
| created_at | datetime | NOT NULL | 作成日時 |
| updated_at | datetime | NOT NULL | 更新日時 |

**インデックス**: email (UNIQUE)

---

#### organizations テーブル
| カラム名 | 型 | 制約 | 説明 |
|---------|-----|------|------|
| id | integer | PK | 組織ID |
| name | string | NOT NULL | 組織名 |
| created_at | datetime | NOT NULL | 作成日時 |
| updated_at | datetime | NOT NULL | 更新日時 |

---

#### memberships テーブル (中間テーブル)
| カラム名 | 型 | 制約 | 説明 |
|---------|-----|------|------|
| id | integer | PK | メンバーシップID |
| user_id | integer | FK, NOT NULL | ユーザーID |
| organization_id | integer | FK, NOT NULL | 組織ID |
| role | string | | 役割 (owner/member) |
| created_at | datetime | NOT NULL | 作成日時 |
| updated_at | datetime | NOT NULL | 更新日時 |

**外部キー**: 
- user_id → users.id
- organization_id → organizations.id

**インデックス**: user_id, organization_id

---

#### tasks テーブル
| カラム名 | 型 | 制約 | 説明 |
|---------|-----|------|------|
| id | integer | PK | タスクID |
| title | string | NOT NULL | タスク名 |
| description | text | | 説明 |
| status | integer | DEFAULT 0 | 状態 (0:todo, 1:done) |
| category | string | | カテゴリ |
| assignee_id | integer | FK | 担当者ID |
| organization_id | integer | FK, NOT NULL | 組織ID |
| due_date | datetime | | 期限 (未使用) |
| created_at | datetime | NOT NULL | 作成日時 |
| updated_at | datetime | NOT NULL | 更新日時 |

**外部キー**: 
- assignee_id → users.id
- organization_id → organizations.id

**インデックス**: assignee_id, organization_id

---

#### task_statistics テーブル
| カラム名 | 型 | 制約 | 説明 |
|---------|-----|------|------|
| id | integer | PK | 統計ID |
| user_id | integer | FK, NOT NULL | ユーザーID |
| organization_id | integer | FK, NOT NULL | 組織ID |
| total_tasks | integer | | 総タスク数 |
| completed_tasks | integer | | 完了タスク数 |
| completion_rate | float | | 進捗率 (%) |
| created_at | datetime | NOT NULL | 作成日時 |
| updated_at | datetime | NOT NULL | 更新日時 |

**外部キー**: 
- user_id → users.id
- organization_id → organizations.id

**インデックス**: user_id, organization_id

---

### 2.3 リレーション

**User ↔ Organization (多対多)**
- 中間テーブル: Membership
- 1人のユーザーは複数の組織に所属可能
- 1つの組織は複数のユーザーを持つ

**Organization → Task (1対多)**
- 1つの組織は複数のタスクを持つ
- 1つのタスクは1つの組織に属する

**User → Task (1対多) - assignee**
- 1人のユーザーは複数のタスクを担当可能
- 1つのタスクは1人の担当者を持つ

**User + Organization → TaskStatistic (複合)**
- ユーザーと組織の組み合わせごとに統計データ

---

## 3. 機能設計書

### 3.1 認証機能

#### POST /auth/login
**目的**: ユーザーログイン

**リクエスト**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**レスポンス (成功)**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "username": "User Name"
}
```

**処理フロー**:
1. メールアドレスでユーザー検索
2. パスワード照合 (bcrypt)
3. JWT トークン生成
4. トークンとユーザー名を返却

**バリデーション**:
- email: 必須、存在確認
- password: 必須、正確性確認

**エラー**:
- 401 Unauthorized: 認証失敗

---

#### POST /users
**目的**: 新規ユーザー登録

**リクエスト**:
```json
{
  "name": "User Name",
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**レスポンス (成功)**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "User Name",
    "email": "user@example.com"
  }
}
```

**処理フロー**:
1. ユーザーデータバリデーション
2. パスワード暗号化 (bcrypt)
3. ユーザー作成
4. JWT トークン生成
5. トークンとユーザー情報を返却

**バリデーション**:
- name: 必須
- email: 必須、メール形式、一意性
- password: 必須、最小6文字
- password_confirmation: passwordと一致

**エラー**:
- 422 Unprocessable Entity: バリデーションエラー

---

#### GET /users/me
**目的**: 現在のユーザー情報取得

**ヘッダー**: `Authorization: Bearer <token>`

**レスポンス**:
```json
{
  "id": 1,
  "name": "User Name",
  "email": "user@example.com"
}
```

**処理フロー**:
1. JWT トークン検証
2. ユーザー情報取得
3. ユーザーデータ返却

**エラー**:
- 401 Unauthorized: トークン無効

---

### 3.2 組織管理機能

#### GET /organizations
**目的**: ユーザーが所属する組織一覧取得

**ヘッダー**: `Authorization: Bearer <token>`

**レスポンス**:
```json
[
  {
    "id": 1,
    "name": "Marketing Team",
    "created_at": "2025-12-25T10:00:00Z",
    "updated_at": "2025-12-25T10:00:00Z"
  }
]
```

**処理フロー**:
1. 認証ユーザー取得
2. ユーザーの組織一覧取得 (Membership経由)
3. 組織データ返却

---

#### POST /organizations
**目的**: 新規組織作成

**リクエスト**:
```json
{
  "name": "New Team"
}
```

**レスポンス**:
```json
{
  "id": 2,
  "name": "New Team",
  "created_at": "2025-12-25T11:00:00Z",
  "updated_at": "2025-12-25T11:00:00Z"
}
```

**処理フロー**:
1. 組織作成
2. 作成者をownerとしてMembership作成
3. 組織データ返却

**バリデーション**:
- name: 必須

---

#### GET /organizations/:id/users
**目的**: 組織メンバー一覧取得

**レスポンス**:
```json
[
  {
    "id": 1,
    "name": "User Name",
    "email": "user@example.com"
  }
]
```

**処理フロー**:
1. 組織存在確認
2. メンバーシップ確認 (アクセス権限)
3. 組織のユーザー一覧取得
4. ユーザーデータ返却

**エラー**:
- 403 Forbidden: アクセス権限なし
- 404 Not Found: 組織が存在しない

---

### 3.3 タスク管理機能

#### GET /organizations/:organization_id/tasks
**目的**: 組織のタスク一覧取得

**クエリパラメータ** (オプション):
- `status`: todo / done
- `assignee_id`: ユーザーID
- `category`: カテゴリ名

**レスポンス**:
```json
[
  {
    "id": 1,
    "title": "Implement Feature",
    "description": "Add new functionality",
    "status": "todo",
    "category": "Development",
    "assignee_id": 2,
    "organization_id": 1,
    "created_at": "2025-12-25T10:00:00Z",
    "updated_at": "2025-12-25T10:00:00Z"
  }
]
```

**処理フロー**:
1. 組織存在確認
2. メンバーシップ確認
3. タスク一覧取得
4. フィルタリング適用 (status, assignee_id, category)
5. タスクデータ返却

**エラー**:
- 403 Forbidden: アクセス権限なし

---

#### POST /organizations/:organization_id/tasks
**目的**: タスク作成

**リクエスト**:
```json
{
  "title": "New Task",
  "description": "Task description",
  "category": "Design",
  "assignee_id": 3
}
```

**レスポンス**:
```json
{
  "id": 2,
  "title": "New Task",
  "description": "Task description",
  "status": "todo",
  "category": "Design",
  "assignee_id": 3,
  "organization_id": 1,
  "created_at": "2025-12-25T12:00:00Z",
  "updated_at": "2025-12-25T12:00:00Z"
}
```

**処理フロー**:
1. 組織存在確認
2. メンバーシップ確認
3. **自動招待**: assigneeが組織メンバーでない場合、Membership作成
4. タスク作成 (デフォルトstatus: todo)
5. タスクデータ返却

**バリデーション**:
- title: 必須

**エラー**:
- 422 Unprocessable Entity: バリデーションエラー

---

#### PATCH /organizations/:organization_id/tasks/:id
**目的**: タスク更新

**リクエスト**:
```json
{
  "title": "Updated Task",
  "status": "done",
  "assignee_id": 4
}
```

**処理フロー**:
1. 組織存在確認
2. メンバーシップ確認
3. タスク存在確認
4. **自動招待**: 新しいassigneeが組織メンバーでない場合、Membership作成
5. タスク更新
6. タスクデータ返却

**エラー**:
- 404 Not Found: タスクが存在しない
- 422 Unprocessable Entity: バリデーションエラー

---

#### DELETE /organizations/:organization_id/tasks/:id
**目的**: タスク削除

**処理フロー**:
1. 組織存在確認
2. メンバーシップ確認
3. タスク存在確認
4. タスク削除

**レスポンス**: 204 No Content

---

### 3.4 統計機能

#### GET /organizations/:organization_id/statistics
**目的**: 組織の進捗統計取得

**レスポンス**:
```json
[
  {
    "id": 1,
    "user": {
      "id": 2,
      "name": "User Name"
    },
    "total_tasks": 10,
    "completed_tasks": 7,
    "completion_rate": 70.0,
    "created_at": "2025-12-25T13:00:00Z",
    "updated_at": "2025-12-25T13:00:00Z"
  }
]
```

**処理フロー**:
1. 組織存在確認
2. メンバーシップ確認
3. TaskStatisticデータ取得 (ユーザー情報含む)
4. 統計データ返却

**注意**: データは Rake タスクで事前集計

---

#### Rake Task: task:aggregate_progress
**目的**: タスク進捗率の集計

**実行方法**:
```bash
bin/rails task:aggregate_progress
```

**処理フロー**:
1. 全組織を取得
2. 各組織のメンバーを取得
3. 各メンバーごとに:
   - 総タスク数を集計 (assignee_id = user.id)
   - 完了タスク数を集計 (status = done)
   - 進捗率を計算 (completed / total * 100)
4. TaskStatisticレコードを作成/更新

**出力例**:
```
Processing Organization: Marketing Team
  User: John | Total: 10 | Done: 7 | Rate: 70.0%
  User: Alice | Total: 5 | Done: 5 | Rate: 100.0%
Aggregation Complete.
```

---

### 3.5 フロントエンド機能

#### リアルタイム更新 (Polling)
**実装**: 10秒ごとに自動更新

**対象**:
- タスク一覧 (`TaskList.vue`)
- 統計パネル (`StatisticsPanel.vue`)

**処理**:
```javascript
setInterval(() => {
  if (currentOrganization.value) {
    taskStore.fetchTasks(currentOrganization.value.id);
    orgStore.fetchStatistics(currentOrganization.value.id);
  }
}, 10000);
```

**メリット**:
- 複数ユーザーの変更を自動反映
- モーダル表示中は更新停止 (UX配慮)

---

#### 自動招待機能
**実装**: タスク割り当て時に自動メンバー追加

**処理フロー**:
1. ユーザーがタスクにassigneeを設定
2. Frontend: 全ユーザーリストから選択
   - 非メンバーには "(will be invited)" 表示
3. Backend: assigneeが組織メンバーでない場合
   - 自動的にMembershipレコード作成
4. ユーザーが組織メンバーとして追加される

**メリット**:
- 簡単な招待フロー
- タスク割り当てと同時に招待完了

---

## 4. 使用技術・ライブラリ一覧

### 4.1 バックエンド (Rails API)

| 技術/ライブラリ | バージョン | 用途 |
|---------------|-----------|------|
| Ruby | 3.3.6 | プログラミング言語 |
| Ruby on Rails | 8.1.0 | Webフレームワーク (APIモード) |
| SQLite3 | 2.4 | データベース |
| bcrypt | 3.1.7 | パスワード暗号化 |
| jwt | 2.10.2 | JWT認証トークン生成 |
| rack-cors | 2.0 | CORS設定 |
| RSpec | 3.13 | テストフレームワーク |

**主要機能**:
- RESTful API設計
- JWT認証
- ActiveRecord ORM
- Rakeタスク (バッチ処理)

---

### 4.2 フロントエンド (Vue SPA)

| 技術/ライブラリ | バージョン | 用途 |
|---------------|-----------|------|
| Vue.js | 3.5.13 | JavaScriptフレームワーク |
| Vite | 6.0.5 | ビルドツール |
| Pinia | 2.3.0 | 状態管理 |
| Vue Router | 4.5.0 | ルーティング |
| Axios | 1.7.9 | HTTP通信 |
| Pug | 3.0.3 | テンプレートエンジン |

**主要機能**:
- SPA (Single Page Application)
- Pugテンプレート (全コンポーネント)
- Pinia状態管理 (auth, task, organization)
- Polling (10秒間隔)

---

### 4.3 開発ツール

| ツール | 用途 |
|-------|------|
| Git | バージョン管理 |
| npm | パッケージ管理 (Frontend) |
| Bundler | Gem管理 (Backend) |

---

### 4.4 アーキテクチャ

**構成**:
```
Frontend (Vue SPA)
    ↓ HTTP/JSON
Backend (Rails API)
    ↓ ActiveRecord
Database (SQLite3)
```

**認証フロー**:
```
1. POST /auth/login → JWT発行
2. localStorage保存
3. 以降のリクエスト: Authorization: Bearer <token>
4. Backend: JWT検証 → @current_user設定
```

**データフロー**:
```
User Action (Vue)
    ↓
Pinia Store (状態管理)
    ↓
Axios (API通信)
    ↓
Rails Controller
    ↓
Model (ActiveRecord)
    ↓
Database
```

---

## 5. セキュリティ・認証設計

### 5.1 認証方式
- **JWT (JSON Web Token)** 使用
- トークン有効期限: 24時間
- HS256アルゴリズム

### 5.2 パスワード管理
- bcrypt暗号化 (cost: 12)
- 平文保存なし
- password_digest カラムに保存

### 5.3 CORS設定
- 開発環境: `origins "*"` (全許可)
- 本番環境: フロントエンドURLのみ許可推奨

### 5.4 アクセス制御
- 組織データ: メンバーシップ確認必須
- タスクデータ: 組織メンバーのみアクセス可能
- 統計データ: 組織メンバーのみ閲覧可能

---

## 6. 今後の拡張性

### 6.1 実装可能な機能
- タスクコメント機能
- ファイル添付
- タスク優先度設定
- 通知機能 (メール/プッシュ)
- Webhooks連携

### 6.2 スケーラビリティ
- PostgreSQL移行 (本番環境)
- Redis (キャッシュ/セッション)
- WebSocket (リアルタイム通信)
- バックグラウンドジョブ (Sidekiq)

---

**作成日**: 2025年12月26日  
**バージョン**: 1.0  
**作成者**: Team Task Manager Development Team
