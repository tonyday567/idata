#!/bin/zsh

error () { echo "error: $@"; exit 1}

if [ "$#" -ge "1" ]; then
    WORKDIR="$(realpath $1)"
    if [ -d "$WORKDIR" ]; then
        error "directory already exists"
    fi
    else
    error "1st arg should be the name of the directory where to set up the environment"
fi

if ! command -v jupyter >/dev/null 2>&1; then
    error "run this in an environment where jupyter is installed";
fi

WORKDIR=xyzzy
echo $WORKDIR
cabal init  --non-interactive $WORKDIR -d "base,ihaskell"
cd $WORKDIR
cabal build --write-ghc-environment-files=always
local ghc_env_path="$(ls | grep -i ".ghc.environment")"
local haskell_kernel_dir="$(jupyter --data-dir)/kernels/haskell/"
mkdir -p $haskell_kernel_dir
cat > $haskell_kernel_dir/kernel.json << EOF
{
  "argv": [
    "cabal","exec", "--project-dir","$WORKDIR", "ihaskell",
    "kernel",
    "{connection_file}", "+RTS","-M3g","-N2", "-RTS"
  ],
  "display_name": "Haskell",
  "language": "haskell",
  "env": {
    "GHC_ENVIRONMENT": "$ghc_env_path"
  }
}
EOF
