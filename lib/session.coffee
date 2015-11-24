redisHelper = require("./redisHelper")

class Session
    constructor: (@sid, @session)->
        @session ?= {}

    set: (key, value)->
        @session[key] = value
        @changed = true

    get: (key)->
        return @session[key]

    clear: (cb)->
        @session = {}
        redisHelper.removeSession @sid, cb

    setGroupName: (@groupName)->

    clearGroupByName: (name)->
        redisHelper.clearAllByName name

    save: (expire, cb)->
        redisHelper.setSession @sid, @session, expire, (err)=>
            if err
                cb err
            else
                if @groupName
                    redisHelper.addSessionIDByName @groupName, @sid, (err)=>
                        return cb(err) if err
                        @changed = false
                        cb null
                else
                    @changed = false
                    cb null

module.exports = Session
