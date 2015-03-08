# push2gitlab

Pushes Git repository to Gitlab.

## Usage

    push2gitlab [SOURCE] <GITLAB_URL> <NAMESPACE> <PROJECT_NAME> <TOKEN>

## Install

    TMP="$(mktemp -d)" \
      && git clone http://git.simpledrupalcloud.com/simpledrupalcloud/push2gitlab.git "${TMP}" \
      && sudo cp "${TMP}/push2gitlab.sh" /usr/local/bin/push2gitlab \
      && sudo chmod +x /usr/local/bin/push2gitlab

## License

**MIT**
