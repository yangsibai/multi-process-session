##multi-process-session

Support multi process session for express.

[![NPM](https://nodei.co/npm/multi-process-session.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/multi-process-session/)

This module is a simple session manager for study purpose. Please don't use it in production environment.

##Get started

    var cookieParser = require("cookieParser");
    var express = require("express");
    var app = express();
    app.use(cookieParser());

    var mps = require("multi-process-session");
    app.use(mps());

    app.get("/set-session", function(req, res){
        var key = req.query.key;
        var value = req.query.value;
        req.session.set(key, value);
        res.send(key + "=" + value);
    });

    app.get("/get-session", function(req, res){
        var key = req.query.key;
        res.send(req.session.get(key));
    });

    app.get("/clear-session", function(req, res){
        req.session.clear(function (err){
            if (!err) {
                res.send("session cleared");
            }
        });
    });

##options

    defaultOptions = {
        type: "cookie",
        expire: 604800, // seconds, default is 7 days
        secret: 'guess me if you can', // a secret for generate session id
        refresh: true, // refresh cookie expire date every time
        redisOptions: { // redis options is used to create reids client, check `redis` document to see detail
            host: '127.0.0.1',
            port: 6379
        }
    };

    var options = {};
    var mps = require("multi-process-session");
    app.use(mps(options));

##API

###Access session manager

`request.session` or `response.session`

###set(key, value)

session.set('foo', 'bar');

###get(key)

var val = session.get('key');

###clear

clear all key-value paired data.

###setGroupName(groupName)

Group name can used for group multiple sessions. It will be used to store all session ids together.

###clearGroupByName(groupName)

Clear all related sessions by the group name.


###License

MIT

