# Run
FROM    maxdesiatov/swift-alpine

RUN     apk add -q --no-cache libgcc tini curl && \
        curl -L https://install.meilisearch.com | sh && \
        chmod +x meilisearch

COPY . .

ENTRYPOINT ["tini", "--"]
CMD ./meilisearch
