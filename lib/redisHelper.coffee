###
Created by massimo on 2014/4/14.
###
redis = require("redis")
client = redis.createClient()

###
设置session
@param sessionID
@param session
@param callback
###
exports.setSession = (sessionID, session, callback) ->
	if not session or Object.getOwnPropertyNames(session).length is 0
		callback null
	else
		client.set sessionID, JSON.stringify(session), (err) ->
			client.expire sessionID, 60 * 60 * 24 * 7, (err) ->
				callback err  if typeof callback is "function"

###
获取session值
@param sessionID
@param callback
###
exports.getSession = (sessionID, callback) ->
	if callback and typeof callback is "function"
		client.get sessionID, (err, result) ->
			if err
				callback err
			else
				redisResult = JSON.parse(result) or {}
				callback null, redisResult
	else
		throw new Error("need a callback function")

###
删除session
@param sessionId
###
exports.removeSession = (sessionId) ->
	client.del sessionId, (err, result) ->
		console.dir err if err