/**
 * Created by massimo on 2014/4/14.
 */

var redis = require('redis'),
    client = redis.createClient();

/**
 * 设置session
 * @param sessionID
 * @param session
 * @param callback
 */
exports.setSession = function (sessionID, session, callback) {
    if (!session || Object.getOwnPropertyNames(session).length === 0) {
        callback(new Error('no session value'));
    }
    client.set(sessionID, JSON.stringify(session), function (err) {
        if (typeof callback === 'function') {
            callback(err);
        }
    });
};

/**
 * 获取session值
 * @param sessionID
 * @param callback
 */
exports.getSession = function (sessionID, callback) {
    if (callback && typeof callback === 'function') {
        client.get(sessionID, function (err, result) {
            if (err) {
                callback(err);
            }
            else {
                var redisResult = JSON.parse(result) || {};
                callback(null, redisResult);
            }
        });
    }
    else {
        throw new Error('need a callback function');
    }
};