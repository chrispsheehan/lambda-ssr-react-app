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
