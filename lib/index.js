/**
 * Created by massimo on 2014/4/14.
 */

var redisHelper = require('./redisHelper');
var uuid = require('node-uuid');

/**
 * 配置session
 * @param app
 */
module.exports = function (app) {
    app.use(function (req, res, next) {
        if (req.cookies) {
            var sid = req.cookies.mysid;
            if (!sid) {
                sid = uuid.v4();
                res.cookie('mysid', sid, {maxAge: 900000});
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
    });
};