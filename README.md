# Log Toggle Time To Redmine

This program logs time worked from Toggl entries to Redmine.

## Installation

```
perl Makefile.PL
make
make install
```

## Configuration

You should create a config file with content similar to the following (replace
values with your actual values from Toggle/Redmine)

```yaml
---
global:
  api_key: 'your_toggl_api_key'
  redmine_url: 'https://redmine.inforuptcy.net'
  redmine_username: 'your_redmine_username'
  redmine_password: 'your_redmine_password'
  # Toggl Workspace Id
  workspace: '54321'
  # Toggl Client Id
  client: '12345'
```

## Running

You need to give the date for the time entries to copy, in YYYY-MM-DD format.

```
  toggl-log-to-redmine 2019-08-01
```

Alternatively, you can skip the config file and pass everything as a CLI
argument.  E.g.

```
  toggl-log-to-redmine \
    --api-key 'your-toggl-api-key'
    --redmine-url 'https://redmine.inforuptcy.net'
    --redmine-username 'your-redmine-username'
    --redmine-password 'your-redmine-password'
    --workspace '54321'
    --client '12345'
    2019-08-01
```

Note that you should only run this once per day or it will create duplicate
entries in Redmine.
