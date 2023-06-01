# Contributing <!-- omit in TOC -->

First of all, thank you for contributing to Meilisearch! The goal of this document is to provide everything you need to know in order to contribute to Meilisearch and its different integrations.

- [Assumptions](#assumptions)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Git Guidelines](#git-guidelines)
- [Release Process (for internal team only)](#release-process-for-internal-team-only)

## Assumptions

1. **You're familiar with [GitHub](https://github.com) and the [Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)(PR) workflow.**
2. **You've read the Meilisearch [documentation](https://docs.meilisearch.com) and the [README](/README.md).**
3. **You know about the [Meilisearch community](https://www.meilisearch.com/docs/learn/what_is_meilisearch/contact.html). Please use this for help.**

## How to Contribute

1. Make sure that the contribution you want to make is explained or detailed in a GitHub issue! Find an [existing issue](https://github.com/meilisearch/meilisearch-swift/issues/) or [open a new one](https://github.com/meilisearch/meilisearch-swift/issues/new).
2. Once done, [fork the meilisearch-swift repository](https://help.github.com/en/github/getting-started-with-github/fork-a-repo) in your own GitHub account. Ask a maintainer if you want your issue to be checked before making a PR.
3. [Create a new Git branch](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-and-deleting-branches-within-your-repository).
4. Review the [Development Workflow](#development-workflow) section that describes the steps to maintain the repository.
5. Make the changes on your branch.
6. [Submit the branch as a PR](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) pointing to the `main` branch of the main meilisearch-swift repository. A maintainer should comment and/or review your Pull Request within a few days. Although depending on the circumstances, it may take longer.<br>
 We do not enforce a naming convention for the PRs, but **please use something descriptive of your changes**, having in mind that the title of your PR will be automatically added to the next [release changelogs](https://github.com/meilisearch/meilisearch-swift/releases/).

## Development Workflow

### On a terminal <!-- omit in TOC -->

### Setup <!-- omit in TOC -->

You can set up your local environment natively or using `docker`, check out the [`docker-compose.yml`](/docker-compose.yml).

Example of running all the checks with docker:
```bash
docker-compose run --rm package bash -c "swift test && swiftlint"
```

To install dependencies:


```bash
swift build
```

To install `swiftlint`:

```
brew install swiftlint
```

### Tests and Linter <!-- omit in TOC -->

If you have a running Meilisearch instance at port `localhost:7700` with the following master key: `masterKey`, you will need to run the following command to test the package:

```bash
curl -L https://install.meilisearch.com | sh # download Meilisearch
./meilisearch --master-key=masterKey --no-analytics # run Meilisearch
swift test
```

If you do not have a Meilisearch instance with the previous mentioned parameters, you can run the test script that will automatically run a Docker container with Meilisearch and start the test:

```bash
./Scripts/run-test.sh
```

If you want to run the linter [`swiftlint`](https://github.com/realm/SwiftLint):

```bash
swift run swiftlint
```

If you want to fix your linting errors:

```bash
swift run swiftlint --fix
```

### Setup on Xcode <!-- omit in TOC -->

To build the project, if it's not already done, click on the play button in the top left corner of Xcode.

### Tests and linter <!-- omit in TOC -->

To launch the tests:
- Go to Product > Test
- Use the shortcut command + U

## Git Guidelines

### Git Branches <!-- omit in TOC -->

All changes must be made in a branch and submitted as PR.
We do not enforce any branch naming style, but please use something descriptive of your changes.

### Git Commits <!-- omit in TOC -->

As minimal requirements, your commit message should:
- be capitalized
- not finish by a dot or any other punctuation character (!,?)
- start with a verb so that we can read your commit message this way: "This commit will ...", where "..." is the commit message.
  e.g.: "Fix the home page button" or "Add more tests for create_index method"

We don't follow any other convention, but if you want to use one, we recommend [this one](https://chris.beams.io/posts/git-commit/).

### GitHub Pull Requests <!-- omit in TOC -->

Some notes on GitHub PRs:

- [Convert your PR as a draft](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/changing-the-stage-of-a-pull-request) if your changes are a work in progress: no one will review it until you pass your PR as ready for review.<br>
  The draft PR can be very useful if you want to show that you are working on something and make your work visible.
- The branch related to the PR must be **up-to-date with `main`** before merging. Fortunately, this project [integrates a bot](https://github.com/meilisearch/integration-guides/blob/main/resources/bors.md) to automatically enforce this requirement without the PR author having to do it manually.
- All PRs must be reviewed and approved by at least one maintainer.
- The PR title should be accurate and descriptive of the changes. The title of the PR will be indeed automatically added to the next [release changelogs](https://github.com/meilisearch/meilisearch-swift/releases/).

## Release Process (for the internal team only)

Meilisearch tools follow the [Semantic Versioning Convention](https://semver.org/).

### Automation to Rebase and Merge the PRs <!-- omit in TOC -->

This project integrates a bot that helps us manage pull requests merging.<br>
_[Read more about this](https://github.com/meilisearch/integration-guides/blob/main/resources/bors.md)._

### Automated Changelogs <!-- omit in TOC -->

This project integrates a tool to create automated changelogs.<br>
_[Read more about this](https://github.com/meilisearch/integration-guides/blob/main/resources/release-drafter.md)._

### How to Publish the Release <!-- omit in TOC -->

⚠️ Before doing anything, make sure you got through the guide about [Releasing an Integration](https://github.com/meilisearch/integration-guides/blob/main/resources/integration-release.md).

Make a PR updating the different versions with the new one on these files:
- [`Sources/MeiliSearch/Model/PackageVersion.swift`](/Sources/MeiliSearch/Model/PackageVersion.swift):
  ```swift
    private static let current = "X.X.X"
  ```
- [`.code-samples.meilisearch.yaml`](/.code-samples.meilisearch.yaml) on the line containing the following:
  ```ruby
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git", from: "X.X.X")
  ```
- [`README.md`](/README.md) on the line containing the following:
  ```ruby
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git", from: "X.X.X")
  ```


Once the changes are merged on `main`, you can publish the current draft release via the [GitHub interface](https://github.com/meilisearch/meilisearch-swift/releases): on this page, click on `Edit` (related to the draft release) > update the description (be sure you apply [these recommendations](https://github.com/meilisearch/integration-guides/blob/main/resources/integration-release.md#writting-the-release-description)) > when you are ready, click on `Publish release`.

GitHub Actions will be triggered and push the package to [CocoaPods](https://cocoapods.org/pods/meilisearch).

:warning: This error: `[!] Authentication token is invalid or unverified. Either verify it with the email that was sent or register a new session.` It will be raised when the authentication is expired. To fix the error, the Integrations team must do the authorization process again with the following:

1st step: Execute this in the repo's directory: `pod trunk register robot@meilisearch.com 'Meilisearch'`<br/>
2nd step: Confirm the link sent in the email.<br/>
3rd step: Run `pod trunk me --verbose` and take the token from `Authorization: Token XXXXXXXXXXXXXXXXXXXXXXXXXX`.<br/>
4th step: Update the token in the GitHub secrets interface `COCOAPODS_TRUNK_TOKEN`.<br/>

<hr>

Thank you again for reading this through. We can not wait to begin to work with you if you make your way through this contributing guide ❤️
