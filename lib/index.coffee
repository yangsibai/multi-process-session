###
Created by massimo on 2014/4/14.
###
redisHelper = require("./redisHelper")
_ = require("underscore")
sessionHelper = require('./sessionHelper')

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

    clearGroup: ->
        unless @groupName
            throw new Error()
        redisHelper.clearAllByName @groupName

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

###
    session middleware
    @param {Object} options
    @param {String} [options.type="cookie"] session type: cookie or token
    @param {Number} [options.expire=604800] expire seconds
    @param {Boolean} [options.refresh=true] refresh every time
###
module.exports = (options) ->
    defaultOptions =
        type: "cookie"
        expire: 604800
        refresh: true # auto refresh cookie
        secret: 'guess me if you can'
    options = _.extend defaultOptions, options

    return (req, res, next)->
        sid = ""
        if options.type is "cookie" # is browser
            SESSION_ID = "sid"
            #cookie
            if req.cookies
                sid = req.cookies[SESSION_ID]
                unless sid
                    sid = sessionHelper.genSID(options.secret)
                    res.cookie SESSION_ID, sid, # save cookie
                        maxAge: options.expire * 1000
                else if options.refresh
                    res.cookie SESSION_ID, sid, # save cookie
                        maxAge: options.expire * 1000
            else
                throw new Error("no cookie support")
        else # is api
            sid = req.query.Token or sessionHelper.genSID(options.secret)

        res.on "finish", ->
            res.session and res.session.save options.expire, (err)->
                console.error err if err

        redisHelper.getSession sid, (err, session) ->
            if err
                console.error err
                next(err)
            else
                req.session = res.session = new Session(sid, session)
                next()
