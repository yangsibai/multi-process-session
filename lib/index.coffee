###
Created by massimo on 2014/4/14.
###
redisHelper = require("./redisHelper")
uuid = require("node-uuid")
_ = require("underscore")

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
        refresh: true
    options = {} if _.isUndefined(options)
    for key,value of defaultOptions
        options[key] = value if _.isUndefined(options[key])

    return (req, res, next)->
        sid = ""
        if options.type is "cookie" # is browser
            SESSION_ID = "sid"
            #cookie
            if req.cookies
                sid = req.cookies[SESSION_ID]
                if sid
                    if options.refresh
                        res.cookie SESSION_ID, sid, # save cookie
                            maxAge: options.expire * 1000
                else
                    sid = uuid.v4()
                    res.cookie SESSION_ID, sid, # save cookie
                        maxAge: options.expire *  1000
            else
                throw new Error("no cookie support")
        else # is api
            sid = req.query.Token or uuid.v4()

        res.on "finish", ->
            if res.session and JSON.stringify(res.session) isnt req._sessionStr
                redisHelper.setSession sid, res.session, options.expire

        redisHelper.getSession sid, (err, session) ->
            if err
                console.error err
                next(err)
            else
                req._sessionStr = JSON.stringify(session)
                res.session = req.session = session
                res.session.clear = ->
                    res.session = null
                    redisHelper.removeSession sid
                req.sessionId = res.sesionId = sid
                next()
