_default:
    just --list

_build_file:
    #!/usr/bin/env bash
    mkdir -p {{justfile_directory()}}/build
    echo {{justfile_directory()}}/build/$(date +%s)-build.zip

build build_file_path:
    #!/usr/bin/env bash
    rm -f {{build_file_path}}
    npm i
    npm run build
    zip -r {{build_file_path}} dist node_modules > /dev/null

static-sync bucket:
    #!/usr/bin/env bash
    aws s3 sync {{justfile_directory()}}/public/static s3://{{bucket}}/public/static --delete

deploy:
    #!/usr/bin/env bash
    build_file_path=$(just _build_file)
    just build $build_file_path
    cd tf
    terraform init
    terraform apply -auto-approve -var lambda-zip-path=$build_file_path
    static_files_bucket=$(terraform output -raw static_files_bucket)
    echo "copying files to $static_files_bucket"
    just static-sync $static_files_bucket

destroy:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform destroy -auto-approve -var lambda-zip-path=/a.zip

check:
    #!/usr/bin/env bash
    cd tf
    terraform validate

format:
    #!/usr/bin/env bash
    cd tf
    terraform fmt --recursive


plan:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform plan -var lambda-zip-path=/a.zip
