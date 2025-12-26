# Team Task Manager

## 概要
簡易SaaS型タスク共有ツール。
ユーザーは複数の組織(ワークスペース)に所属し、タスクを管理できます。

## 構成
- **backend**: Ruby on Rails (API)
- **frontend**: Vue.js 3 + Vite
- **docs**: 設計書

## 使い方 (Setup)

### Backend
```bash
cd backend
bundle install
rails db:migrate
rails s
```
APIサーバーが `http://localhost:3000` で起動します。

### Frontend
```bash
cd frontend
npm install
npm run dev
```
フロントエンドが `http://localhost:5173` で起動します。
