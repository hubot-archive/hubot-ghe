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
#   hubot ghe (status|info) license - returns license information
#   hubot ghe (status|info) largerepo - returns information about large repositories
#
# Authors:
#   pnsk, mgriffin

module.exports = (robot) ->
  robot.respond /ghe (status|info)? ?(.*)$/i, (msg) ->
    url = process.env.HUBOT_GHE_URL + '/api/v3'
    token = process.env.HUBOT_GHE_TOKEN

    unless token
      msg.send "token isn't set."

    info_term = msg.match[2]
    if info_term is "license"
      ghe_license msg,auth,url
    if info_term is "largerepo"
      ghe_largerepo msg,auth,url
    else
      msg.send "I don't know about #{info_term}"

ghe_license = (msg, token, url) ->
    msg.http("#{url}/enterprise/settings/license")
    .header("Authorization", "token #{token}")
    .get() (err, res, body) ->
        if err
             msg.send "error"
        else
           if res.statusCode is 200
               results = JSON.parse body
               msg.send "GHE has #{results.seats} seats, and #{results.seats_used} are used. License expires at #{results.expire_at}"
           else
               msg.send "statusCode: #{res.statusCode}"

ghe_largerepo = (msg, token, url) ->
    repo_min = 2000000
    msg.http("#{url}/search/repositories?q=size:>=#{repo_min}")
    .header("Authorization", "token #{token}")
    .get() (err, res, body) ->
        if err
             msg.send "error"
        else
           if res.statusCode is 200
               results = JSON.parse body
               msg.send "more than #{repo_min}KB repos. (aww)"
               if results.total_count is 0
                 msg.send "no repos."
               else
                 results.items.sort compareSize
                 reporank = ""
                 for item, index in results.items
                   reporank = reporank + "#{index+1}:  #{item.full_name} #{item.size} \n"
                 msg.send "#{reporank}"
           else
               msg.send "statusCode: #{res.statusCode}"

compareSize = (a, b) ->
  b.size - a.size
