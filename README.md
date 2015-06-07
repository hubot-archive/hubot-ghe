# Hubot: GitHub Enterprise

Access your GitHub Enterprise instance through Hubot.

## Installation

In your hubot project repo, run:

`npm install hubot-ghe --save`

Then add **hubot-ghe** to your `external-scripts.json`:

```json
[
  "hubot-ghe"
]
```

## Configuration

**Note:** You must be a site administrator of your GitHub Enterprise appliance to create a token with the correct permissions.

Create a [personal access token](https://help.github.com/enterprise/2.2/user/articles/creating-an-access-token-for-command-line-use/#creating-a-token) and copy it to the `HUBOT_GHE_TOKEN` environment variable.

Copy your GitHub Enterprise URL to the `HUBOT_GHE_URL` environment variable.

```
export HUBOT_GHE_TOKEN=<your token>
export HUBOT_GHE_URL=<your URL>
```

## Sample Interaction

```
user1>> hubot ghe info license
hubot>> GHE has 20 seats, and 7 are used. License expires at 2015-07-01T00:00:00-07:00
```
