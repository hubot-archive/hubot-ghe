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
#   hubot ghe stats issues - returns issue information
#   hubot ghe stats hooks - returns hook information
#   hubot ghe stats milestones - returns milestone information
#   hubot ghe stats issues - returns user information
#
# Authors:
#   pnsk, mgriffin

module.exports = (robot) ->
  url = process.env.HUBOT_GHE_URL + '/api/v3'
  token = process.env.HUBOT_GHE_TOKEN
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

  unless token
    msg.send "token isn't set."

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
          when "issues" then msg.send "#{results.total_issues} issues in total; #{results.open_issues} open and #{results.closed_issues} closed."
          when "hooks" then msg.send "#{results.total_hooks} hooks in total; #{results.active_hooks} active and #{results.inactive_hooks} inactive."
          when "milestones" then msg.send "#{results.total_milestones} milestones in total; #{results.open_milestones} open and #{results.closed_milestones} closed."
          when "users" then msg.send "#{results.total_users} users, #{results.admin_users} admins and #{results.suspended_users} suspended."
      else
        msg.send "statusCode: #{res.statusCode} -- #{body} -- type: #{type} -- #{msg.match[1]}"
