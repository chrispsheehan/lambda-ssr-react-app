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
    zip -r {{build_file_path}} dist node_modules > /dev/null

static-sync bucket:
    #!/usr/bin/env bash
    aws s3 sync {{justfile_directory()}}/public/static s3://{{bucket}}/public/static --delete --exact-timestamps

deploy:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/tf/cdn
    terraform init
    terraform apply -auto-approve -var environment=$(just _environment) -var base_reference=$(just _base_reference)

    static_files_bucket=$(terraform output -raw static_files_bucket)
    static_files_cdn=$(terraform output -raw static_files_cdn)
    cloudfront_id=$(terraform output -raw cloudfront_id)

    export CLIENT_PUBLIC_PATH=$static_files_cdn
    export STAGE=$(just _environment)
    build_file_path=$(just _build_file)
    just build $build_file_path

    cd {{justfile_directory()}}/tf/ssr
    terraform init
    terraform apply -auto-approve -var environment=$(just _environment) -var base_reference=$(just _base_reference) --var lambda_zip_path=$build_file_path -var static_files_source=$static_files_cdn
    
    echo "copying files to $static_files_bucket"
    just static-sync $static_files_bucket
    aws cloudfront create-invalidation --distribution-id $cloudfront_id --paths "/*"

destroy:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform destroy -auto-approve -var lambda_zip_path=/a.zip

check:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/tf/cdn
    terraform init
    terraform validate
    cd {{justfile_directory()}}/tf/ssr
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
