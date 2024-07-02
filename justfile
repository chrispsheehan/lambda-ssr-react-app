_default:
    just --list

_build_file:
    #!/usr/bin/env bash
    echo {{justfile_directory()}}/$(date +%s)-build.zip

build build_file_path:
    #!/usr/bin/env bash
    rm -f {{build_file_path}}
    npm i
    npm run build
    cp -r {{justfile_directory()}}/node_modules {{justfile_directory()}}/dist/node_modules
    cd dist
    zip -r {{build_file_path}} .

deploy:
    #!/usr/bin/env bash
    build_file_path=$(just _build_file)
    just build $build_file_path
    cd tf
    terraform apply -var lambda-zip-path=$build_file_path --replace aws_lambda_function.render


