###
Created by massimo on 2014/4/14.
###
redisHelper = require("./redisHelper")
uuid = require("node-uuid")
_ = require("underscore")

###
配置session
@param app
@param type 类型: cookie 或 token
###
module.exports = (app, type, expireHour) ->
	unless _.isNumber(expireHour)
		expireHour = 24 * 7

	app.use (req, res, next) ->
		sid = ""
		if _.isUndefined(type) or (type is "cookie") #browser
			#cookie
			if req.cookies
				sid = req.cookies.sid
				sid = uuid.v4()  unless sid
				res.cookie "sid", sid, #保存一周时间
					maxAge: 3600000 * expireHour
		else #api
			#token
			sid = req.query.Token or uuid.v4()

		if sid
			res.on "finish", ->
				if res.session
					redisHelper.setSession sid, res.session, expireHour
			redisHelper.getSession sid, (err, session) ->
				if err
					console.dir err
					next(err)
				else
					res.session = req.session = session
					res.session.clear = ->
						res.session = null
						redisHelper.removeSession sid
					req.sessionId = sid
					next()
		else
			res.session = req.session = {}
			next()
