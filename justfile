gha_repo := "https://github.com/aRustyDev/gha.git"
pre_commit_repo := "https://github.com/aRustyDev/pre-commit.git"
title := `git config remote.origin.url | sed 's/\.git$//' | sed 's|.*/||'`
root := `git rev-parse --show-toplevel`

init kind: setup-dev
    just workflows "{{ kind }}"
    just actions "{{ kind }}"
    just pre-commit "{{ kind }}"
    require("sed") -i '1i {{ title }}' README.md
    require("mdbook") init docs
    echo require("mustache") .github/templates/action.mustache > "{{ root }}/action.yml"

actions kind:
    git archive --remote="{{ gha_repo }}" "HEAD:actions/{{ kind }}" | tar -x

workflows kind:
    git archive --remote="{{ gha_repo }}" "HEAD:workflows/{{ kind }}" | tar -x

pre-commit kind:
    git archive --remote="{{ pre_commit_repo }}" "HEAD:pre-commit/{{ kind }}" | tar -x

[unix]
_sparse_checkout category kind:
    git clone --no-checkout "{{ gha_repo }}"
    git sparse-checkout init
    git sparse-checkout set "{{ category }}/{{ kind }}"
    git checkout main

[doc("https://nektosact.com/usage/index.html")]
validate:
    echo "Validation successful"
    require("act") push
    require("act") pull_request
    require("act") schedule
    require("act") -W '.github/workflows/'

list event="":
    require("act") -l "{{ event }}"

# Install local development tools
[macos]
setup-dev:
    require("brew") tap aRustyDev/tap
    require("brew") install act
    require("brew") install act_runner
    require("brew") install action-docs
    require("brew") install action-validator
    require("brew") install pinact
    require("brew") install mdbook
    require("brew") install mustache
    require("brew") install container-use
    require("brew") install just-mcp
    require("brew") install just-mcp
    just format-settings

format-settings:
    sed -i 's|/path/to/container-use|{{ require("container-use") }}|g' .zed/settings.json
    sed -i 's|/path/to/just-mcp|{{ require("just-mcp") }}|g' .zed/settings.json
    sed -i 's|/path/to/volta|{{ require("volta") }}|g' .zed/settings.json
    sed -i 's|/path/to/brew|{{ require("brew") }}|g' .zed/settings.json
    sed -i 's|GH_PAT|{{ require("brew") }}|g' .zed/settings.json
    op inject -i .zed/settings.json -o .zed/settings.json
