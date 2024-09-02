_default:
    just --list

_build_file:
    #!/usr/bin/env bash
    mkdir -p {{justfile_directory()}}/build
    echo {{justfile_directory()}}/build/$(date +%s)-build.zip

_base_reference:
    #!/usr/bin/env bash
    echo chrispsheehan-lambda-ssr-react

_environment:
    #!/usr/bin/env bash
    echo dev

build build_file_path:
    #!/usr/bin/env bash
    rm -f {{build_file_path}}
    npm i
    npm run build
    rm -rf {{justfile_directory()}}/node_modules
    npm i --omit=dev
    zip -r {{build_file_path}} dist node_modules > /dev/null

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
    terraform plan -var lambda_zip_path=/a.zip

local-deploy:
    #!/usr/bin/env bash
    build_path="{{justfile_directory()}}/build.zip"
    rm -f $build_path
    just build $build_path
    cd tf
    terraform init
    terraform apply -var lambda_zip_path=$build_path
    STATIC_FILES_BUCKET=$(terraform output -raw static_files_bucket)
    CLOUDFRONT_ID=$(terraform output -raw cloudfront_id)
    WEB_URL=$(terraform output -raw web_url)
    just static-sync $STATIC_FILES_BUCKET $CLOUDFRONT_ID
    echo $WEB_URL