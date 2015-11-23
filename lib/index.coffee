###
Created by massimo on 2014/4/14.
###
redisHelper = require("./redisHelper")
_ = require("underscore")
sessionHelper = require('./sessionHelper')

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
        secret: 'guess me if you can'
    options = _.extend defaultOptions, options

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
                    sid = sessionHelper.genSID(options.secret)
                    res.cookie SESSION_ID, sid, # save cookie
                        maxAge: options.expire * 1000
            else
                throw new Error("no cookie support")
        else # is api
            sid = req.query.Token or sessionHelper.genSID(options.secret)

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
