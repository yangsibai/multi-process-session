redis = require("redis")
_ = require 'underscore'
client = null

class Session
    constructor: (@sid, options, cb)->
        unless client
            client = redis.createClient options
        client.get @sid, (err, result)=>
            return cb(err) if err
            @session = JSON.parse(result) or {}
            cb null

    set: (key, value)->
        @session[key] = value
        @changed = true

    get: (key)->
        return @session[key]

    del: (key)->
        delete @session[key]
        @changed = true

    clear: (cb)->
        @session = {}
        client.del @sid, cb

    setGroupName: (@groupName)->

    clearGroupByName: (name, cb)->
        skey = 'session:ids:' + name
        kicked_out_key = "session:k:ids:" + name
        client.smembers skey, (err, members)=>
            return cb(err) if err
            return cb(null) if members.length is 0
            afterAll = _.after members.length, cb
            _.each members, (sid)=>
                client.sadd kicked_out_key, sid, (err)=> # added to kicked_out keys
                    return cb err if err
                    client.del sid, (err)=>
                        return cb err if err
                        client.srem skey, sid, (err)->
                            return cb err if err
                            afterAll()

    isKickedOut: (sid)->


    save: (expire, cb)->
        return cb(null) unless @changed
        client.set @sid, JSON.stringify(@session), (err)=>
            return cb(err) if err
            client.expire @sid, expire, (err)=>
                return cb(err) if err
                if @groupName
                    client.sadd 'session:ids:' + @groupName, @sid, (err)=>
                        return cb(err) if err
                        @changed = false
                        cb null
                else
                    @changed = false
                    cb null

module.exports = Session
