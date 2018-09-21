if [ $commands[kubectl] ]; then
  kubectl() {
    unfunction "$0"

    source <(kubectl completion zsh)

    $0 "$@"
  }
fi
