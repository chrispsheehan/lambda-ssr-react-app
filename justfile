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
    # zip -r {{build_file_path}} dist public/static node_modules
    zip -r {{build_file_path}} dist node_modules

deploy:
    #!/usr/bin/env bash
    build_file_path=$(just _build_file)
    just build $build_file_path
    cd tf
    terraform init
    terraform apply -auto-approve -var lambda-zip-path=$build_file_path --replace aws_lambda_function.render

destroy:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform destroy -auto-approve -var lambda-zip-path=/a.zip

check:
    #!/usr/bin/env bash
    cd tf
    terraform validate



