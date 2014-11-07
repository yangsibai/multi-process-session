##multi-process-session

Support multi process session for express.

[![NPM](https://nodei.co/npm/multi-process-session.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/multi-process-session/)


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
        req.session[key] = value;
        res.send(key + "=" + value);
    });

    app.get("/get-session", function(req, res){
        var key = req.query.key;
        res.send(req.session[key]);
    });

    app.get("/clear-session", function(req, res){
        req.session.clear();
        res.send("session cleared");
    });

##options

    defaultOptions = {
        type: "cookie",
        expire: 604800, // seconds, default is 7 days
        refresh: true // refresh cookie expire date every time
    };

    var options = {};
    var mps = require("multi-process-session");
    app.use(mps(options));
