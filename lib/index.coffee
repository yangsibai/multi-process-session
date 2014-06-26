###
Created by massimo on 2014/4/14.
###
redisHelper = require("./redisHelper")
uuid = require("node-uuid")

###
配置session
@param app
@param type 类型: cookie 或 token
###
module.exports = (app, type) ->
	app.use (req, res, next) ->
		if not type or type is "cookie"
			#cookie
			if req.cookies
				sid = req.cookies.sid
				sid = uuid.v4()  unless sid
				res.cookie "sid", sid, #保存一周时间
					maxAge: 2592000000
				res.on "finish", ->
					if res.session
						redisHelper.setSession sid, res.session, (err) ->
							console.error err  if err
				redisHelper.getSession sid, (err, session) ->
					if err
						console.dir err
					else
						res.session = req.session = session
						res.session.clear = ->
							res.session = null
							redisHelper.removeSession sid
					next()
			else
				throw new Error("no cookies,please add cookie support.")
		else
			#token
			token = req.query.Token
			if token
				res.on "finish", ->
					if res.session
						redisHelper.setSession token, res.session, (err) ->
							console.error err  if err
				redisHelper.getSession token, (err, session) ->
					if err
						console.error err
					else
						res.session = req.session = session
					next()
			else
				next()