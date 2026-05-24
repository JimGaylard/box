# AWS configurations
export AWS_REGION=ap-southeast-2
export AWS_DEFAULT_REGION=ap-southeast-2

# Source bash-my-aws if installed
if [ -e ~/.bash-my-aws ]
then
  for f in ~/.bash-my-aws/lib/*-functions
  do
    # shellcheck source=/dev/null
    source "$f"
  done
  # shellcheck source=/home/jgaylard/.bash-my-aws/bash_completion.sh
  source "$HOME"/.bash-my-aws/bash_completion.sh
fi

# Source aws-shortcuts if installed
# shellcheck source=/home/jgaylard/.aws-shortcuts/aws-shortcuts.sh
[ -e ~/.aws-shortcuts ] && source ~/.aws-shortcuts/aws-shortcuts.sh

alias console='xdg-open $(aws-console-url)'
