# Jim's terminal pushes to GitHub as Jim (2026-09-28).
#
# ~/.ssh/config on this Mac (not managed by box) sends github.com to
# ~/.ssh/ai-jg-tars with IdentityAgent none, so TARS pushes as ai-jg-tars.
# Without this override, Jim's own git would go the same way. Command-line
# options beat ~/.ssh/config, so interactive shells pin git's ssh to Jim's
# 1Password key. Claude sessions keep the ai-jg-tars value from
# ~/.claude/settings.json, which overrides the shell's.
#
# Quoting: git hands this string to sh, which eats one layer of quotes.
# The single quotes feed that shell; the double quotes inside them reach
# ssh's own -o tokenizer, which needs them for the space in "Group
# Containers". One layer only and ssh fails with "keyword identityagent
# extra arguments at end of line".
export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -o IdentityAgent='\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"' -i ~/.ssh/github_1p.pub"
