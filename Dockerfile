FROM swift:5.7

COPY --from=norionomura/swiftlint:swift-5 /usr/bin/swiftlint /usr/local/bin/swiftlint
