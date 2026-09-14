# Lazy load NVM (Node Version Manager)
__node_commands=(nvm node npm npx yarn pnpm)
for cmd in $__node_commands; do
  eval "$cmd() {
    unset -f $__node_commands
    export NVM_DIR=\"\$HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
    [ -s \"\$NVM_DIR/bash_completion\" ] && . \"\$NVM_DIR/bash_completion\"
    \$0 \"\$@\"
  }"
done

# Global npm binaries (firebase, hubspot, …) without waking nvm: put the newest
# installed node's bin on PATH. One directory, nothing sourced, so shell start
# stays fast; the lazy functions above still own node/npm/npx/yarn/pnpm.
# (Resolving nvm's `default` alias needs nvm itself, so newest stands in.)
__nvm_node_bins=("$HOME"/.nvm/versions/node/v*/bin(Nn))
(( $#__nvm_node_bins )) && path=("$__nvm_node_bins[-1]" $path)
unset __nvm_node_bins
