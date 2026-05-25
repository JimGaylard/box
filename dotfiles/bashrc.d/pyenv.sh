# Pyenv (Python Version Manager) settings
export PYENV_ROOT="$HOME/.pyenv"
if [ -z "$__PATH_INITIALIZED" ]; then
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
fi
eval "$(pyenv init -)"
