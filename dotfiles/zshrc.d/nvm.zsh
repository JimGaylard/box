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
