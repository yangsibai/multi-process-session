redis = require("redis")
_ = require 'underscore'

class Session
    constructor: (@sid, options, cb)->
        @client = redis.createClient options
        @client.get @sid, (err, result)=>
            return cb(err) if err
            @session = JSON.parse(result) or {}
            cb null

    set: (key, value)->
        @session[key] = value
        @changed = true

    get: (key)->
        return @session[key]

    clear: (cb)->
        @session = {}
        @client.del @sid, cb

    setGroupName: (@groupName)->

    clearGroupByName: (name, cb)->
        @client.smembers 'session:ids:' + name, (err, members)=>
            return cb(err) if err
            return cb(null) if members.length is 0
            afterAll = _.after members.length, cb
            _.each members, (sid)=>
                @client.del sid, (err)->
                    if err
                        cb err
                    else
                        afterAll()

    save: (expire, cb)->
        return cb(null) unless @changed
        @client.set @sid, JSON.stringify(@session), (err)=>
            return cb(err) if err
            @client.expire @sid, expire, (err)=>
                return cb(err) if err
                if @groupName
                    @client.sadd 'session:ids:' + @groupName, @sid, (err)=>
                        return cb(err) if err
                        @changed = false
                        cb null
                else
                    @changed = false
                    cb null

module.exports = Session
