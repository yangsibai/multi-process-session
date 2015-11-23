request = require("supertest")
should = require("should")
express = require("express")
cookieParser = require("cookie-parser")
mps = require("../lib/index")
sessionHelper = require('../lib/sessionHelper')

describe "multi process session test", ->
    app = express()
    app.use(cookieParser())
    app.use(mps())

    app.get "/", (req, res)->
        res.send "cookie has set"

    app.get "/set-session", (req, res)->
        key = req.query.key
        value = req.query.value
        req.session[key] = value
        res.send "set session => #{key} = #{value}"

    app.get "/get-session", (req, res)->
        key = req.query.key
        res.send req.session[key]

    app.get "/clear-session", (req, res)->
        res.session.clear()
        res.send "clear success"

    agent = request.agent(app)

    context 'session manage test', ->
        it "should save cookie", (done)->
            agent
            .get("/")
            .expect(200)
            .expect("set-cookie", /sid=.*/, done)

        it "should set session", (done)->
            agent
            .get("/set-session")
            .query
                key: "foo"
            .query
                value: "bar"
            .expect(200)
            .expect("set session => foo = bar", done)

        it "should get session", (done)->
            agent
            .get("/get-session")
            .query
                key: "foo"
            .expect("bar", done)

        it "should clear session", (done)->
            agent
            .get("/clear-session")
            .expect "clear success", (err)->
                should.not.exist(err)
                agent.get("/get-session")
                .query
                    key: "foo"
                .expect "", done

    context 'session helper test', ->
        secret = 'give me a hint'
        it 'should create sid', ->
            sessionHelper.genSID(secret).should.be.a.string
            should(sessionHelper.genSID(secret).length > 0)

