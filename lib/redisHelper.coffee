###
Created by massimo on 2014/4/14.
###
redis = require("redis")
client = redis.createClient()
_ = require("underscore")

###
设置session
@param sessionID
@param session
@param callback
###
exports.setSession = (sessionID, session, expireSeconds, cb) ->
    if not session or Object.getOwnPropertyNames(session).length is 0
        cb(null) if _.isFunction(cb)
    else
        client.set sessionID, JSON.stringify(session), (err) ->
            client.expire sessionID, expireSeconds, (err) ->
                cb err if _.isFunction(cb)

###
获取session值
@param sessionID
@param callback
###
exports.getSession = (sessionID, cb) ->
    if _.isFunction(cb)
        client.get sessionID, (err, result) ->
            return cb(err) if err
            redisResult = JSON.parse(result) or {}
            cb null, redisResult
    else
        throw new Error("need a callback function")

###
删除session
@param sessionId
###
exports.removeSession = (sessionId) ->
    client.del sessionId, (err, result) ->
        console.error(err) if err
