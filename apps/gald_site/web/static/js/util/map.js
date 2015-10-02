export default function Map (object) {
    let map = new (window.Map)();

    if (object !== undefined) {
        Object.keys(object).forEach(function (key) {
            map.set(key, object[key]);
        });
    }

    return map;
};