# AWS configurations
export AWS_REGION=ap-southeast-2
export AWS_DEFAULT_REGION=ap-southeast-2

# Zsh native AWS CLI completions
if command -v aws_zsh_completer.sh &>/dev/null; then
  source $(which aws_zsh_completer.sh)
fi

# Source aws-shortcuts if installed
[ -e ~/.aws-shortcuts ] && source ~/.aws-shortcuts/aws-shortcuts.sh

alias console='xdg-open $(aws-console-url)'
