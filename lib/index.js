/**
 * Created by massimo on 2014/4/14.
 */

var redisHelper = require('./redisHelper');
var uuid = require('node-uuid');

/**
 * 配置session
 * @param app
 * @param type 类型: cookie 或 token
 */
module.exports = function (app, type) {
    app.use(function (req, res, next) {
        if (!type || type === 'cookie') {
            //cookie
            if (req.cookies) {
                var sid = req.cookies.sid;
                if (!sid) {
                    sid = uuid.v4();
                    res.cookie('sid', sid, {maxAge: 604800000}); //保存一周时间
                }
                res.on('finish', function () {
                    if (res.session) {
                        redisHelper.setSession(sid, res.session, function (err) {
                            if (err) {
                                console.error(err);
                            }
                        });
                    }
                });
                redisHelper.getSession(sid, function (err, session) {
                    if (err) {
                        console.dir(err);
                    }
                    else {
                        res.session = req.session = session;
                    }
                    next();
                });
            }
            else {
                throw new Error('no cookies,please add cookie support.');
            }
        }
        else {
            //token
            var token = req.query.Token;
            if (token) {
                res.on('finish', function () {
                    if (res.session) {
                        redisHelper.setSession(token, res.session, function (err) {
                                if (err) {
                                    console.error(err);
                                }
                            }
                        );
                    }
                });
                redisHelper.getSession(token, function (err, session) {
                    if (err) {
                        console.error(err);
                    }
                    else {
                        res.session = req.session = session;
                    }
                    next();
                });
            }
            else {
                next();
            }
        }
    });
};