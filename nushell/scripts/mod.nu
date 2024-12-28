
export use system.nu

# choses a folder from fzf list and cd's into it
export def --env f [] {
    # Usage: fd.exe [OPTIONS] [pattern] [path]...
    let destination = (fd --max-depth 3 --min-depth 1
    --type directory --hidden --ignore-vcs --exclude node_modules --exclude .git --exclude .venv --exclude __pycache__ --exclude .ruff_cache
    -- . # any name
    ~/Code #all these dirs
    ~/other-repos
    | fzf) # pipe it to fzf
    cd $destination
}