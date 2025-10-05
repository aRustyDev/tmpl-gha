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
