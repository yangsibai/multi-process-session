###
Created by massimo on 2014/4/14.
###
_ = require("underscore")
sessionHelper = require('./sessionHelper')
Session = require('./session')

###
    session middleware
    @param {Object} options
    @param {String} [options.type="cookie"] session type: cookie or token
    @param {Number} [options.expire=604800] expire seconds
    @param {Boolean} [options.refresh=true] refresh every time
    @param {String} [options.secret="guess me if you can"]  secret for generate session id
    @param {Object} [options.redisOptions] options to create redis client
###
module.exports = (options) ->
    defaultOptions =
        type: "cookie"
        expire: 604800
        refresh: true # auto refresh cookie
        secret: 'guess me if you can'
        redisOptions:
            host: '127.0.0.1'
            port: 6379
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

        session = new Session sid, options.redisOptions, (err)->
            if err
                console.error err
                next(err)
            else
                req.session = res.session = session
                next()
