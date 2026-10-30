# IAM Roles Anywhere container demo

コンテナ上の Spring Boot アプリが、IAM Roles Anywhere の `credential_process` 経由で S3 バケット一覧を取得する実験用プロジェクトです。

## 前提

- Docker（Docker Desktop / colima など。compose プラグインが無い環境では `docker compose` を `docker-compose` に読み替え）
- AWS 側で作成済みの Trust anchor、Profile、IAM role

IAM 側の Trust anchor には `certs/ca.crt` を登録し、Profile には利用する IAM role と、この証明書の subject または issuer に対応する principal tag / session policy を設定してください。実験用の権限として、対象 role に `s3:ListAllMyBuckets` を付与します。

## 起動

```sh
# certs/ に CA とクライアント証明書をコンテナ内で生成（既にあればスキップ）
docker compose run --rm certgen
# certs/ca.crt で AWS 側を設定（下記「AWS 側で必要な値」）
cp .env.example .env
# .env の ARN 3つを AWS 環境の値に変更
docker compose up --build
```

別のターミナルから確認します。

```sh
curl http://localhost:8080/buckets
```

`/buckets` のリクエストごとに AWS SDK が標準認証チェーンを使い、コンテナ内の `aws_signing_helper credential-process` が自己署名クライアント証明書で一時認証情報を取得します。

## AWS 側で必要な値

1. `certs/ca.crt` を Trust anchor の証明書として登録
2. IAM Roles Anywhere Profile を作成し、対象 IAM role を関連付け
3. Profile の session policy / principal tag 条件を実験用 role に合わせて設定
4. `.env` の `TRUST_ANCHOR_ARN`、`PROFILE_ARN`、`ROLE_ARN` を設定

自己署名 CA とクライアント証明書はローカル実験専用です。`certs/ca.key` と `certs/client.key` は Git にコミットしないでください。証明書を再生成した場合は Trust anchor に新しい `ca.crt` を登録し直します。

## 停止とクリーンアップ

```sh
docker compose down
rm -rf certs/ca.* certs/client.*
```

## テスト

ローカルに Java / Maven は不要です。`mvn package` は Docker のビルドステージで実行され、テストもそこで走ります。

```sh
docker compose build
```
