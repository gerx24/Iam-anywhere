FROM debian:stable-slim
EXPOSE 9911
ADD https://rolesanywhere.amazonaws.com/releases/1.1.1/X86_64/Linux/aws_signing_helper /usr/local/bin/aws_signing_helper
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get --no-install-recommends install -y ca-certificates && \
    chmod +x /usr/local/bin/aws_signing_helper

ADD --chmod=777 serve.sh /usr/local/bin/serve.sh

CMD [ "serve.sh" ]
