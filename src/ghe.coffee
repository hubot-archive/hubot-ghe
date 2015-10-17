# Description:
#   Access your GitHub Enterprise instance through Hubot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_GHE_URL
#   HUBOT_GHE_TOKEN
#
# Commands:
#   hubot ghe license - returns license information
#   hubot ghe stats issues - returns the number of open and closed issues
#   hubot ghe stats hooks - returns the number of active and inactive hooks
#   hubot ghe stats milestones - returns the number of open and closed milestones
#   hubot ghe stats orgs - returns the number of organizations, teams, team members, and disabled organizations
#   hubot ghe stats comments - returns the number of comments on issues, pull requests, commits, and gists
#   hubot ghe stats pages - returns the number of GitHub Pages sites
#   hubot ghe stats users - returns the number of suspended and admin users
#   hubot ghe stats gists - returns the number of private and public gists
#   hubot ghe stats pulls - returns the number of merged, mergeable, and unmergeable pull requests
#   hubot ghe stats repos - returns the number of organization-owned repositories, root repositories, forks, pushed commits, and wikis
#
# Authors:
#   pnsk, mgriffin

module.exports = (robot) ->
  url = process.env.HUBOT_GHE_URL + '/api/v3'
  token = process.env.HUBOT_GHE_TOKEN
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

  unless token
    robot.logger.error "GitHub Enterprise token isn't set."

  robot.respond /ghe license$/i, (msg) ->
    ghe_license msg,token,url

  robot.respond /ghe stats (.*)$/i, (msg) ->
    ghe_stats msg,token,url

ghe_license = (msg, token, url) ->
    msg.http("#{url}/enterprise/settings/license")
    .header("Authorization", "token #{token}")
    .get() (err, res, body) ->
        if err
             msg.send "error"
        else
           if res.statusCode is 200
               results = JSON.parse body
               msg.send "GHE has #{results.seats} seats, and #{results.seats_used} are used. License expires at #{results.expire_at}."
           else
               msg.send "statusCode: #{res.statusCode}"

ghe_stats = (msg, token, url) ->
  type = msg.match[1]
  msg.http("#{url}/enterprise/stats/#{type}")
  .header("Authorization", "token #{token}")
  .get() (err, res, body) ->
    if err
      msg.send "error"
    else
      if res.statusCode is 200
        results = JSON.parse body
        switch type
          when "issues" then msg.send "#{results.total_issues} issues; #{results.open_issues} open and #{results.closed_issues} closed."
          when "hooks" then msg.send "#{results.total_hooks} hooks; #{results.active_hooks} active and #{results.inactive_hooks} inactive."
          when "milestones" then msg.send "#{results.total_milestones} milestones; #{results.open_milestones} open and #{results.closed_milestones} closed."
          when "orgs" then msg.send "#{results.total_orgs} organizations; #{results.disabled_orgs} disabled.\n#{results.total_teams} teams with #{results.total_team_members} members."
          when "comments" then msg.send "#{results.total_commit_comments} commit comments.\n#{results.total_gist_comments} gist comments.\n#{results.total_issue_comments} issue comments.\n#{results.total_pull_request_comments} pull request comments.\n"
          when "pages" then msg.send "#{results.total_pages} pages."
          when "users" then msg.send "#{results.total_users} users; #{results.admin_users} admins and #{results.suspended_users} suspended."
          when "gists" then msg.send "#{results.total_gists} gists; #{results.private_gists} private and #{results.public_gists} public."
          when "pulls" then msg.send "#{results.total_pulls} pulls; #{results.merged_pulls} merged, #{results.mergable_pulls} mergable and #{results.unmergable_pulls} unmergable."
          when "repos" then msg.send "#{results.total_repos} repositories, #{results.root_repos} root and #{results.fork_repos} forks.\n#{results.org_repos} in organizations.\n#{results.total_pushes} pushes in total.\n#{results.total_wikis} wikis."
      else
        msg.send "statusCode: #{res.statusCode} -- #{body} -- type: #{type} -- #{msg.match[1]}"
