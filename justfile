_default:
    just --list

build build_file_path auth_build_file_path:
    #!/usr/bin/env bash
    set -euo pipefail

    rm -f {{build_file_path}}
    rm -f {{auth_build_file_path}}
    npm run install-deps
    npm run build
    zip -r {{build_file_path}} app/dist app/node_modules > /dev/null
    zip -r {{auth_build_file_path}} auth/dist auth/node_modules > /dev/null

run:
    #!/usr/bin/env bash
    docker-compose up --build

file-sync bucket:
    #!/usr/bin/env bash
    aws s3 sync {{justfile_directory()}}/public/assets s3://{{bucket}}/public/assets --delete
    aws s3 cp s3://{{bucket}}/public/assets/styles/styles.scss s3://{{bucket}}/public/assets/styles/styles.scss --content-type "text/css" --metadata-directive REPLACE
    aws s3 sync {{justfile_directory()}}/public/static s3://{{bucket}}/public/static --delete --exact-timestamps

static-sync bucket cloudfront_id:
    #!/usr/bin/env bash
    just file-sync {{bucket}}
    aws cloudfront create-invalidation --distribution-id {{cloudfront_id}} --paths "/public/*"

check:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/tf
    terraform init
    terraform validate

format:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/tf
    terraform fmt --recursive

plan:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform plan -var lambda_zip_path=/a.zip -var auth_lambda_zip_path=/a.zip
